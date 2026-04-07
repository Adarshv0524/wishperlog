import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/shared/models/enums.dart';
// import 'package:wishperlog/shared/models/note_helpers.dart';

class GeminiClassificationResult {
  const GeminiClassificationResult({
    required this.title,
    required this.category,
    required this.priority,
    required this.extractedDate,
    required this.cleanBody,
    required this.model,
    required this.wasFallback,
  });

  final String title;
  final NoteCategory category;
  final NotePriority priority;
  final DateTime? extractedDate;
  final String cleanBody;
  final String model;
  final bool wasFallback;
}

class GeminiNoteClassifier {
  GeminiNoteClassifier({String? apiKey, GenerativeModel? model})
      : _apiKey        = apiKey ?? AppEnv.geminiApiKey,
        _providedModel = model;

  // ─── System Prompt ─────────────────────────────────────────────────────────
  //
  // Design goals:
  //  • Zero hallucination: never invent facts, dates, or context.
  //  • Preserve intent: raw slang / shorthand must survive.
  //  • Strict JSON-only output so parsing never fails.
  //  • Unambiguous category and priority definitions.
  // ──────────────────────────────────────────────────────────────────────────
  static const String systemPrompt = r'''
You are a structured note-processing engine. Your ONLY output is a single raw JSON object — no markdown, no backticks, no prose before or after it.

════════════════════════════════════════
OUTPUT SCHEMA (all fields required)
════════════════════════════════════════
{
  "title":          "<string>",
  "clean_body":     "<string>",
  "category":       "<string>",
  "priority":       "<string>",
  "extracted_date": "<string|null>"
}

════════════════════════════════════════
FIELD RULES
════════════════════════════════════════

title
  • 3–9 words, written in the same language as the input.
  • Capture the single most important action or subject.
  • Do NOT start with filler like "Note about" or "Reminder to".
  • Do NOT use punctuation at the end.
  • Examples of good titles: "Call dentist this Friday", "Finish landing page hero", "Mom's birthday gift idea"

clean_body
  • Lightly edited version of the raw input.
  • Fix ONLY: obvious typos, clear grammatical errors, run-on punctuation.
  • Preserve: original language, tone, slang, abbreviations, emoji, bullet structure.
  • Do NOT: translate, summarise, expand, rewrite, or add missing context.

category  — choose EXACTLY one lowercase value:
  "tasks"      → Concrete action the user must DO (verb + object). Has a clear completion state.
                 Examples: "buy milk", "review PR", "book flight"
  "reminders"  → Time-sensitive or location-sensitive cue. Often contains "remind me", "don't forget", a specific date/time, or "when I".
                 Examples: "dentist at 3pm tomorrow", "call back John", "remind me to water plants"
  "ideas"      → Creative, speculative, or exploratory thought. No defined completion state.
                 Examples: "app idea for dog walkers", "blog post about flow states", "what if we use WebSockets"
  "follow-up"  → Needs a follow-up action with another person or system (email, meeting, response, check-in).
                 Examples: "follow up with Sarah on contract", "check if invoice was paid", "ask boss about PTO"
  "journal"    → Personal reflection, emotion, observation, or memory. No action required.
                 Examples: "had a great run today", "feeling overwhelmed with deadlines", "remembering grandma's cookies"
  "general"    → Factual note, reference info, or anything that clearly does not fit the above.
                 Examples: "WiFi password: sunshine99", "office address is 42 Park Ave", "npm install --legacy-peer-deps"

  DISAMBIGUATION RULES:
  • If note has BOTH a clear action AND a time → "reminders" wins over "tasks".
  • If note asks to follow up with a specific person → "follow-up" wins over "tasks".
  • If note is purely a feeling or personal reflection → "journal" even if it contains a verb.
  • When genuinely ambiguous, prefer the more specific category (tasks > general, reminders > tasks).

priority  — choose EXACTLY one lowercase value:
  "high"   → Urgent or time-critical; consequences if missed soon. Phrases: "asap", "urgent", "by EOD", "deadline", "critical", explicit near-term date.
  "medium" → Important but not immediately urgent. Default when no urgency signal is present.
  "low"    → Nice-to-have, background, or someday/maybe. Phrases: "eventually", "one day", "low priority", "whenever".

extracted_date
  • If the note implies a specific action date (explicit date, "tomorrow", "next Monday", "in 3 days", "this Friday"), return it as "YYYY-MM-DD" in ISO 8601.
  • Use today's approximate date context if needed (assume current date is the moment of capture).
  • If no action date is implied, return null.
  • Never invent a date. When vague ("someday", "soon", "later"), return null.

════════════════════════════════════════
STRICT RULES
════════════════════════════════════════
1. Output ONLY the JSON object. First character must be `{`, last must be `}`.
2. All string values must be properly JSON-escaped.
3. extracted_date must be a JSON string "YYYY-MM-DD" or the literal JSON null.
4. category and priority must be exactly one of the values listed — no capitalisation, no synonyms.
5. Never add extra fields to the JSON.
6. If the input is empty or pure noise (< 3 meaningful words), return:
   {"title":"Untitled note","clean_body":"","category":"general","priority":"low","extracted_date":null}
''';

  final String _apiKey;
  final GenerativeModel? _providedModel;

  bool get isConfigured => _providedModel != null || _apiKey.isNotEmpty;

  Future<GeminiClassificationResult> classify(String rawTranscript) async {
    final text = rawTranscript.trim();
    if (text.isEmpty) return _fallback(rawTranscript, model: 'none');
    if (!isConfigured) return _fallback(rawTranscript, model: 'offline-fallback');

    final model = _providedModel ??
        GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: _apiKey);

    const maxAttempts = 3;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await model.generateContent([
          Content.system(systemPrompt),
          Content.text('Raw input:\n$text'),
        ]).timeout(const Duration(seconds: 10));

        final payload = response.text?.trim();
        if (payload == null || payload.isEmpty) {
          return _fallback(rawTranscript, model: 'gemini-2.5-flash-lite');
        }

        return _parseOrFallback(
          rawTranscript: rawTranscript,
          payload: payload,
          model: 'gemini-2.5-flash-lite',
        );
      } catch (e) {
        final err = e.toString();
        final isRateLimit = err.contains('429') ||
            err.contains('quota') ||
            err.contains('rate') ||
            err.contains('RESOURCE_EXHAUSTED');
        if (isRateLimit && attempt < maxAttempts - 1) {
          await Future<void>.delayed(
              Duration(seconds: (attempt + 1) * 4));
          continue;
        }
        return _fallback(rawTranscript, model: 'gemini-2.5-flash-lite');
      }
    }
    return _fallback(rawTranscript, model: 'gemini-2.5-flash-lite');
  }

  // ── Parsing ────────────────────────────────────────────────────────────────

  GeminiClassificationResult _parseOrFallback({
    required String rawTranscript,
    required String payload,
    required String model,
  }) {
    try {
      // Strip accidental markdown fences
      var clean = payload
          .replaceAll(RegExp(r'^```[a-z]*\n?', multiLine: true), '')
          .replaceAll(RegExp(r'```$',          multiLine: true), '')
          .trim();

      // Extract first JSON object
      final start = clean.indexOf('{');
      final end   = clean.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) {
        return _fallback(rawTranscript, model: model);
      }
      clean = clean.substring(start, end + 1);

      final json = jsonDecode(clean) as Map<String, dynamic>;

      final title    = (json['title']      as String? ?? '').trim();
      final body     = (json['clean_body'] as String? ?? rawTranscript).trim();
      final catStr   = (json['category']   as String? ?? 'general').toLowerCase().trim();
      final priStr   = (json['priority']   as String? ?? 'medium').toLowerCase().trim();
      final dateStr  =  json['extracted_date'] as String?;

      final category = _parseCategory(catStr);
      final priority = _parsePriority(priStr);
      final date     = _parseDate(dateStr);

      return GeminiClassificationResult(
        title:         title.isEmpty ? _quickTitle(rawTranscript) : title,
        category:      category,
        priority:      priority,
        extractedDate: date,
        cleanBody:     body.isEmpty ? rawTranscript : body,
        model:         model,
        wasFallback:   false,
      );
    } catch (_) {
      return _fallback(rawTranscript, model: model);
    }
  }

  GeminiClassificationResult _fallback(String raw, {required String model}) {
    return GeminiClassificationResult(
      title:         _quickTitle(raw),
      category:      NoteCategory.general,
      priority:      NotePriority.medium,
      extractedDate: null,
      cleanBody:     raw,
      model:         model,
      wasFallback:   true,
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _quickTitle(String text) {
    final line = text.replaceAll('\n', ' ').trim();
    return line.length <= 70 ? line : '${line.substring(0, 70).trimRight()}…';
  }

  NoteCategory _parseCategory(String s) => switch (s) {
    'tasks'     => NoteCategory.tasks,
    'reminders' => NoteCategory.reminders,
    'ideas'     => NoteCategory.ideas,
    'follow-up' || 'follow_up' || 'followup' => NoteCategory.followUp,
    'journal'   => NoteCategory.journal,
    _           => NoteCategory.general,
  };

  NotePriority _parsePriority(String s) => switch (s) {
    'high' => NotePriority.high,
    'low'  => NotePriority.low,
    _      => NotePriority.medium,
  };

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty || s == 'null') return null;
    try {
      return DateTime.parse(s);
    } catch (_) {
      return null;
    }
  }
}