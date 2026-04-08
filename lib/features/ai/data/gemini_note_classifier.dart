import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/shared/models/enums.dart';

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
      : _apiKey = apiKey ?? AppEnv.geminiApiKey,
        _providedModel = model;

  // ─────────────────────────────────────────────────────────────────────────
  // SYSTEM PROMPT — v3
  // Goals:
  //   1. Actively correct STT mispronunciations / grammar before saving.
  //   2. Strict JSON-only output.
  //   3. Crystal-clear disambiguation rules to eliminate mis-categorisation.
  // ─────────────────────────────────────────────────────────────────────────
  static const String systemPrompt = r'''
You are an intelligent voice-note post-processor. You receive raw speech-to-text output which may contain mispronunciations, homophones, run-on sentences, filler words, and grammatical errors. Your job is to:
  A) Intelligently correct the text (see clean_body rules below).
  B) Classify it into a structured JSON object.

════════════════════════════════
OUTPUT — ONE raw JSON object only.
No markdown, no backticks, no prose.
First byte must be `{`, last byte `}`.
════════════════════════════════
{
  "title":          "<string: 3–9 words, imperative or noun-phrase>",
  "clean_body":     "<string: corrected note text>",
  "category":       "<string: tasks|reminders|ideas|follow-up|journal|general>",
  "priority":       "<string: high|medium|low>",
  "extracted_date": "<string YYYY-MM-DD | null>"
}

━━━ FIELD RULES ━━━━━━━━━━━━━━━

title
  • 3–9 words in input language.
  • Start with an action verb OR the main subject noun.
  • No trailing punctuation. No filler openings ("Note about", "Remind me to").
  • ✓ "Call dentist Friday" ✓ "Landing page hero section" ✓ "Mom birthday gift"

clean_body  ← ACTIVE CORRECTION REQUIRED
  • Fix ALL of the following from raw STT output:
    – Homophones / mispronunciations  (e.g. "meting" → "meeting", "contrack" → "contract")
    – Filler words  (e.g. "um", "uh", "like", "you know", "basically") — remove unless semantically relevant.
    – Repeated words  (e.g. "the the", "call call") — deduplicate.
    – Run-on fragments joined by "and" or "so" — break into separate sentences.
    – Missing capitalisation at sentence starts.
    – Obvious missing articles (a/an/the) only when unambiguous.
  • DO NOT: translate, summarise, add new context, change names, change numbers.
  • Preserve: tone, slang, emoji, technical jargon, proper nouns (even if unusual).

category — choose exactly ONE:
  "tasks"     → Clear action the user must complete (has a done state).
                Signals: "do", "buy", "fix", "send", "finish", "complete", "review".
  "reminders" → Time/location-sensitive nudge. Has a WHEN or WHERE.
                Signals: time words (tomorrow, 3pm, next week), "remind me", "don't forget", "when I get to".
  "ideas"     → Creative/exploratory thought. No defined done-state.
                Signals: "what if", "idea", "maybe we could", speculative language.
  "follow-up" → Requires action involving another person/system after an interaction.
                Signals: "follow up", "check with", "ask", "waiting for", "reply to", named person + verb.
  "journal"   → Personal reflection, emotion, memory, observation. Pure internal state.
                Signals: feelings, past tense reflections, "I feel", "I noticed", "today was".
  "general"   → Facts, references, credentials, recipes, addresses, code snippets, anything else.

  PRIORITY RULES (applied in order — first match wins):
  1. Both action AND explicit time → "reminders"
  2. Involves specific named person needing response → "follow-up"
  3. Pure internal feeling → "journal"
  4. Clear verb+object with done state → "tasks"
  5. Speculative/creative → "ideas"
  6. Otherwise → "general"

priority — choose exactly ONE:
  "high"   → Urgent. Signals: "asap", "urgent", "today", "by EOD", "deadline", "critical", date ≤ 3 days.
  "medium" → Default. Important but not immediately urgent.
  "low"    → Background. Signals: "eventually", "someday", "when I have time", "nice to have".

extracted_date
  • Return ISO 8601 "YYYY-MM-DD" if the note implies an action date.
  • Resolve relative dates ("tomorrow" = today+1, "next Monday", "in 3 days").
  • If vague ("soon", "later", "someday") → null.
  • Never invent a date. Null if uncertain.
  • Use today as the reference date (the note was captured right now).

════════════════════════════════
FALLBACK (use when input < 3 meaningful words or pure noise):
{"title":"Untitled note","clean_body":"","category":"general","priority":"low","extracted_date":null}
════════════════════════════════
''';

  final String _apiKey;
  final GenerativeModel? _providedModel;

  bool get isConfigured => _providedModel != null || _apiKey.isNotEmpty;

  Future<GeminiClassificationResult> classify(String rawTranscript) async {
    final text = rawTranscript.trim();
    if (text.isEmpty) return _fallback(rawTranscript, model: 'none');
    if (!isConfigured) {
      debugLog('[GeminiClassifier] API key not configured — using fallback');
      return _fallback(rawTranscript, model: 'offline-fallback');
    }

    final model = _providedModel ??
        GenerativeModel(
          model: 'gemini-2.5-flash-lite-preview-06-17',
          apiKey: _apiKey,
          generationConfig: GenerationConfig(
            temperature: 0.1,   // Low temperature for consistent structured output
            topK: 1,
            topP: 0.95,
            maxOutputTokens: 512,
          ),
        );

    const maxAttempts = 3;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await model.generateContent([
          Content.system(systemPrompt),
          Content.text('Today is ${_todayString()}.\nRaw STT input:\n$text'),
        ]).timeout(const Duration(seconds: 15));

        final payload = response.text?.trim();
        if (payload == null || payload.isEmpty) {
          debugLog('[GeminiClassifier] Empty response on attempt $attempt');
          continue;
        }

        final result = _parseOrFallback(
          rawTranscript: rawTranscript,
          payload: payload,
          model: 'gemini-2.5-flash-lite',
        );

        if (!result.wasFallback) {
          debugLog('[GeminiClassifier] OK: cat=${result.category.name} '
              'pri=${result.priority.name} title="${result.title}"');
        }
        return result;
      } catch (e) {
        final err = e.toString();
        debugLog('[GeminiClassifier] attempt=$attempt error: $err');
        final isRateLimit = err.contains('429') ||
            err.contains('quota') ||
            err.contains('RESOURCE_EXHAUSTED');
        if (isRateLimit && attempt < maxAttempts - 1) {
          await Future<void>.delayed(Duration(seconds: (attempt + 1) * 5));
          continue;
        }
        // Non-rate-limit error — bail immediately
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
      var clean = payload
          .replaceAll(RegExp(r'^```[a-z]*\n?', multiLine: true), '')
          .replaceAll(RegExp(r'```$', multiLine: true), '')
          .trim();

      final start = clean.indexOf('{');
      final end   = clean.lastIndexOf('}');
      if (start == -1 || end == -1 || end <= start) {
        debugLog('[GeminiClassifier] No JSON object found in payload');
        return _fallback(rawTranscript, model: model);
      }
      clean = clean.substring(start, end + 1);

      final json = jsonDecode(clean) as Map<String, dynamic>;

      final title   = (json['title']      as String? ?? '').trim();
      final body    = (json['clean_body'] as String? ?? rawTranscript).trim();
      final catStr  = (json['category']   as String? ?? 'general').toLowerCase().trim();
      final priStr  = (json['priority']   as String? ?? 'medium').toLowerCase().trim();
      final dateStr =  json['extracted_date'] as String?;

      return GeminiClassificationResult(
        title:         title.isEmpty ? _quickTitle(rawTranscript) : title,
        category:      _parseCategory(catStr),
        priority:      _parsePriority(priStr),
        extractedDate: _parseDate(dateStr),
        cleanBody:     body.isEmpty ? rawTranscript : body,
        model:         model,
        wasFallback:   false,
      );
    } catch (e) {
      debugLog('[GeminiClassifier] JSON parse error: $e');
      return _fallback(rawTranscript, model: model);
    }
  }

  GeminiClassificationResult _fallback(String raw, {required String model}) =>
      GeminiClassificationResult(
        title:         _quickTitle(raw),
        category:      NoteCategory.general,
        priority:      NotePriority.medium,
        extractedDate: null,
        cleanBody:     raw,
        model:         model,
        wasFallback:   true,
      );

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _quickTitle(String text) {
    final line = text.replaceAll('\n', ' ').trim();
    return line.length <= 72 ? line : '${line.substring(0, 72).trimRight()}…';
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  NoteCategory _parseCategory(String s) => switch (s) {
    'tasks'                                    => NoteCategory.tasks,
    'reminders'                                => NoteCategory.reminders,
    'ideas'                                    => NoteCategory.ideas,
    'follow-up' || 'follow_up' || 'followup'  => NoteCategory.followUp,
    'journal'                                  => NoteCategory.journal,
    _                                          => NoteCategory.general,
  };

  NotePriority _parsePriority(String s) => switch (s) {
    'high' => NotePriority.high,
    'low'  => NotePriority.low,
    _      => NotePriority.medium,
  };

  DateTime? _parseDate(String? s) {
    if (s == null || s.isEmpty || s == 'null') return null;
    try { return DateTime.parse(s); } catch (_) { return null; }
  }

  void debugLog(String msg) => debugPrint(msg);
}