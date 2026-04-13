import 'dart:math' as math;
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

/// A matched search result with scoring metadata.
class SearchHit {
  const SearchHit({
    required this.note,
    required this.score,
    this.matchedField = '',
    this.snippet = '',
  });

  final Note note;
  final double score;
  final String matchedField;
  final String snippet;
}

/// Params object for isolate-safe searching.
class _SearchParams {
  const _SearchParams({
    required this.notes,
    required this.query,
    required this.nowMs,
    this.limit = 50,
  });

  final List<Note> notes;
  final String query;
  final int nowMs;
  final int limit;
}

class SmartNoteSearch {
  // ── Public API ────────────────────────────────────────────────────────────

  /// Synchronous search — call from isolate or when note count is small (<200).
  static List<SearchHit> searchSync(
    List<Note> notes,
    String query, {
    int limit = 50,
    DateTime? now,
  }) {
    return _searchInternal(_SearchParams(
      notes: notes,
      query: query,
      nowMs: (now ?? DateTime.now()).millisecondsSinceEpoch,
      limit: limit,
    ));
  }

  // ── Core logic (isolate-safe: no Flutter plugins) ─────────────────────────

  static List<SearchHit> _searchInternal(_SearchParams params) {
    final query = params.query.trim();
    if (query.isEmpty || params.notes.isEmpty) return const [];

    // 1. Parse category shorthand: "tasks:", "@ideas", "#reminders"
    NoteCategory? categoryFilter;
    String cleanQuery = query;
    final catMatch = RegExp(
      r'^(?:(@|#)(\w+)|(\w+):)\s*',
    ).firstMatch(query);
    if (catMatch != null) {
      final tag = (catMatch.group(2) ?? catMatch.group(3) ?? '').toLowerCase();
      categoryFilter = _parseShorthand(tag);
      if (categoryFilter != null) {
        cleanQuery = query.substring(catMatch.end).trim();
      }
    }

    final notes = categoryFilter == null
        ? params.notes
        : params.notes.where((n) => n.category == categoryFilter).toList();

    if (cleanQuery.isEmpty) {
      // Category filter only — return recency-sorted notes in that category.
      final sorted = [...notes]
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return sorted
          .take(params.limit)
          .map((n) => SearchHit(note: n, score: 1.0))
          .toList();
    }

    // 2. Tokenise query into terms
    final terms = _tokenise(cleanQuery);
    if (terms.isEmpty) return const [];

    // 3. IDF: inverse-document-frequency for each term across the corpus
    final idf = _computeIdf(notes, terms);

    // 4. Score each note
    final now = DateTime.fromMillisecondsSinceEpoch(params.nowMs);
    final hits = <SearchHit>[];

    for (final note in notes) {
      final result = _scoreNote(note, terms, idf, cleanQuery, now);
      if (result.score > 0) hits.add(result);
    }

    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits.take(params.limit).toList();
  }

  // ── Scoring ───────────────────────────────────────────────────────────────

  static SearchHit _scoreNote(
    Note note,
    List<String> terms,
    Map<String, double> idf,
    String rawQuery,
    DateTime now,
  ) {
    final fields = _noteFields(note);

    double total = 0;
    String bestField = '';
    String snippet = '';
    double bestFieldScore = 0;

    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final fieldWeight = entry.value.$1;
      final fieldText = entry.value.$2;
      final tokens = _tokenise(fieldText);
      if (tokens.isEmpty) continue;

      final tf = _computeTf(tokens);
      double fieldScore = 0;

      for (final term in terms) {
        final termTf = tf[term] ?? 0.0;
        if (termTf == 0) continue;
        final termIdf = idf[term] ?? 1.0;
        fieldScore += termTf * termIdf;
      }

      // Prefix bonus: term is a prefix of a word in the field
      final lowerField = fieldText.toLowerCase();
      for (final term in terms) {
        if (_hasPrefixMatch(lowerField, term)) {
          fieldScore += 0.4 * fieldWeight;
        }
      }

      // Exact phrase bonus
      if (terms.length > 1) {
        final phrase = terms.join(' ');
        if (lowerField.contains(phrase)) {
          fieldScore += 1.5 * fieldWeight;
        }
      }

      final weighted = fieldScore * fieldWeight;
      total += weighted;

      if (weighted > bestFieldScore) {
        bestFieldScore = weighted;
        bestField = fieldName;
        snippet = _extractSnippet(fieldText, terms.first);
      }
    }

    if (total == 0) return SearchHit(note: note, score: 0);

    // Recency decay: score × e^(-λ·days), half-life = 30 days
    const halfLifeDays = 30.0;
    final ageDays = now.difference(note.updatedAt).inHours / 24.0;
    final recencyMultiplier = math.exp(
      -(math.log(2) / halfLifeDays) * ageDays.clamp(0, 365),
    );

    // Small boost if ALL terms matched
    final allTermsCovered = terms.every((t) => _noteAllText(note).contains(t));
    if (allTermsCovered) total *= 1.25;

    final finalScore = total * (0.5 + 0.5 * recencyMultiplier);
    return SearchHit(
      note: note,
      score: finalScore,
      matchedField: bestField,
      snippet: snippet,
    );
  }

  // ── TF helpers ────────────────────────────────────────────────────────────

  static Map<String, double> _computeTf(List<String> tokens) {
    final counts = <String, int>{};
    for (final t in tokens) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
    final total = tokens.length.toDouble();
    return counts.map((k, v) => MapEntry(k, v / total));
  }

  static Map<String, double> _computeIdf(
      List<Note> notes, List<String> terms) {
    final N = notes.length.toDouble();
    final result = <String, double>{};
    for (final term in terms) {
      var df = 0;
      for (final note in notes) {
        if (_noteAllText(note).contains(term)) df++;
      }
      // Smoothed IDF
      result[term] = math.log((N + 1) / (df + 1)) + 1.0;
    }
    return result;
  }

  // ── Field map ─────────────────────────────────────────────────────────────

  /// Returns {fieldName: (weight, text)}
  static Map<String, (double, String)> _noteFields(Note note) {
    return {
      'title': (3.5, note.title),
      'translated_title': (3.2, note.translatedTitle ?? ''),
      'body': (2.5, note.cleanBody),
      'translated_body': (2.4, note.translatedContent ?? ''),
      'transcript': (1.8, note.rawTranscript),
      'category': (1.0, categoryLabel(note.category)),
    };
  }

  static String _noteAllText(Note note) {
    return '${note.title} ${note.translatedTitle ?? ''} ${note.cleanBody} ${note.translatedContent ?? ''} ${note.rawTranscript} ${categoryLabel(note.category)}'
        .toLowerCase();
  }

  // ── Tokeniser ─────────────────────────────────────────────────────────────

  static const _stopWords = {
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'but', 'by', 'for',
    'from', 'i', 'in', 'is', 'it', 'me', 'my', 'of', 'on', 'or',
    'our', 'so', 'the', 'their', 'this', 'to', 'was', 'we', 'were',
    'what', 'when', 'where', 'which', 'with', 'you', 'your', 'am',
    'that', 'than', 'some',
  };

  static List<String> _tokenise(String text) {
    final normalized = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 2 && !_stopWords.contains(t))
        .toList();

    if (normalized.isNotEmpty) return normalized;

    // Fallback for short non-Latin inputs that survive poorly through token filters.
    final raw = text.trim().toLowerCase();
    return raw.isEmpty ? const <String>[] : <String>[raw];
  }

  // ── Utility ───────────────────────────────────────────────────────────────

  static bool _hasPrefixMatch(String haystack, String prefix) {
    // Checks if `prefix` is the start of any word in `haystack`
    final pattern = RegExp(r'\b' + RegExp.escape(prefix));
    return pattern.hasMatch(haystack);
  }

  static String _extractSnippet(String text, String term, {int radius = 60}) {
    final lower = text.toLowerCase();
    final idx = lower.indexOf(term);
    if (idx < 0) {
      return text.length > radius * 2 ? '${text.substring(0, radius * 2)}…' : text;
    }
    final start = (idx - radius).clamp(0, text.length);
    final end = (idx + term.length + radius).clamp(0, text.length);
    final pre = start > 0 ? '…' : '';
    final post = end < text.length ? '…' : '';
    return '$pre${text.substring(start, end)}$post';
  }

  static NoteCategory? _parseShorthand(String tag) {
    return switch (tag) {
      'tasks' || 'task' || 't' => NoteCategory.tasks,
      'reminders' || 'reminder' || 'r' => NoteCategory.reminders,
      'ideas' || 'idea' => NoteCategory.ideas,
      'followup' || 'follow' || 'fu' => NoteCategory.followUp,
      'journal' || 'j' => NoteCategory.journal,
      'general' || 'g' => NoteCategory.general,
      _ => null,
    };
  }
}