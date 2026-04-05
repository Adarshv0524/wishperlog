import 'package:fuzzy/fuzzy.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class LocalNoteSearch {
  static const Set<String> _stopWords = {
    'a',
    'an',
    'and',
    'are',
    'as',
    'at',
    'be',
    'but',
    'by',
    'for',
    'from',
    'i',
    'in',
    'is',
    'it',
    'me',
    'my',
    'of',
    'on',
    'or',
    'our',
    'so',
    'some',
    'something',
    'than',
    'that',
    'the',
    'their',
    'this',
    'to',
    'was',
    'we',
    'were',
    'what',
    'when',
    'where',
    'which',
    'with',
    'you',
    'your',
    'am',
    'am searching',
  };

  static List<Note> search(List<Note> notes, String query, {int limit = 50}) {
    final trimmed = query.trim();
    if (trimmed.isEmpty || notes.isEmpty) {
      return const <Note>[];
    }

    final terms = _meaningfulTerms(trimmed);
    if (terms.isEmpty) {
      return const <Note>[];
    }

    final fuzzy = Fuzzy<Note>(
      notes,
      options: FuzzyOptions<Note>(
        shouldNormalize: true,
        threshold: 0.42,
        tokenize: true,
        matchAllTokens: false,
        keys: [
          WeightedKey<Note>(
            name: 'title',
            weight: 4,
            getter: (note) => note.title,
          ),
          WeightedKey<Note>(
            name: 'cleanBody',
            weight: 3,
            getter: (note) => note.cleanBody,
          ),
          WeightedKey<Note>(
            name: 'rawTranscript',
            weight: 3,
            getter: (note) => note.rawTranscript,
          ),
          WeightedKey<Note>(
            name: 'category',
            weight: 2,
            getter: (note) => categoryLabel(note.category),
          ),
        ],
      ),
    );

    final ranked = <_LocalSearchHit>[];
    for (final result in fuzzy.search(trimmed, limit * 2)) {
      final note = result.item;
      final score = _score(note, terms);
      if (score <= 0) {
        continue;
      }
      ranked.add(_LocalSearchHit(note: note, score: score));
    }

    ranked.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return b.note.updatedAt.compareTo(a.note.updatedAt);
    });

    return ranked.take(limit).map((hit) => hit.note).toList();
  }

  static List<String> _meaningfulTerms(String query) {
    final normalized = _normalize(query);
    if (normalized.isEmpty) {
      return const <String>[];
    }

    return normalized
        .split(' ')
        .where((term) => term.length >= 3 && !_stopWords.contains(term))
        .toList(growable: false);
  }

  static int _score(Note note, List<String> terms) {
    final title = _normalize(note.title);
    final body = _normalize(note.cleanBody);
    final raw = _normalize(note.rawTranscript);
    final category = _normalize(categoryLabel(note.category));

    final combined = '$title $body $raw $category';
    var score = 0;
    var matchedTerms = 0;

    for (final term in terms) {
      final inTitle = title.contains(term);
      final inBody = body.contains(term);
      final inRaw = raw.contains(term);
      final inCategory = category.contains(term);

      if (inTitle || inBody || inRaw || inCategory) {
        matchedTerms += 1;
      }

      if (inTitle) score += 6;
      if (title.startsWith(term)) score += 4;
      if (inBody) score += 4;
      if (inRaw) score += 4;
      if (inCategory) score += 3;
    }

    if (matchedTerms == 0) {
      return 0;
    }

    if (terms.length > 1 && matchedTerms < 2) {
      return 0;
    }

    if (combined.contains(terms.join(' '))) {
      score += 4;
    }

    return score;
  }

  static String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }
}

class _LocalSearchHit {
  const _LocalSearchHit({required this.note, required this.score});

  final Note note;
  final int score;
}
