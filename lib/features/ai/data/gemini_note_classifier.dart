import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

/// Result returned by any AI classifier (Gemini or Groq).
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

  final String _apiKey;
  final GenerativeModel? _providedModel;

  static const List<String> supportedModels = [
    'gemini-3-flash',
    'gemini-2.5-flash',
    'gemini-1.5-flash',
  ];

  bool get isConfigured => _apiKey.isNotEmpty;

  // ──────────────────────────────────────────────────────────────────────────
  // SYSTEM PROMPT v4 — God-Level
  //
  // Key upgrades over v3:
  //  • Temporal context injected at call-time (not static), enabling accurate
  //    relative-date parsing ("tomorrow", "next Monday", etc.).
  //  • Explicit homophones list for Indian-English STT (most common errors).
  //  • Hard rule: category "follow-up" ↔ any check-in/ping/follow phrasing.
  //  • Confidence-weighted: if ambiguous between tasks/reminders, prefer tasks.
  //  • Stricter JSON contract with inline type annotations.
  // ──────────────────────────────────────────────────────────────────────────
  static const String _systemPromptTemplate = r'''
You are an intelligent voice-note post-processor embedded in WishperLog.
You receive raw speech-to-text output which may contain mispronunciations,
homophones, run-on sentences, filler words, grammar errors, and STT artefacts.

TODAY'S DATE AND TIME: {{TEMPORAL_CONTEXT}}

Your job:
  A) Correct the text intelligently (see clean_body rules).
  B) Classify it into the JSON schema below.

════════════════════════════════════════════
OUTPUT — EXACTLY ONE raw JSON object.
No markdown fences, no backticks, no prose.
First byte MUST be `{`  Last byte MUST be `}`
════════════════════════════════════════════
{
  "title":          "<string: 3–9 words>",
  "clean_body":     "<string: corrected full note>",
  "category":       "<string: tasks|reminders|ideas|follow-up|journal|general>",
  "priority":       "<string: high|medium|low>",
  "extracted_date": "<string YYYY-MM-DD | null>"
}

━━━ FIELD RULES ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

title
  • 3–9 words in the INPUT language (do NOT translate).
  • Begin with an action verb OR the main subject noun.
  • No trailing punctuation. Omit filler openers ("Note about", "Remind me to").
  • ✓ "Call dentist Friday"   ✓ "Landing page hero copy"   ✓ "Mom birthday gift"

clean_body  ← ACTIVE CORRECTION REQUIRED
  Fix ALL of the following from raw STT output:
  • Homophones / mispronunciations — common Indian-English STT errors to fix:
      "contrack"→"contract", "meting"→"meeting", "fone"→"phone",
      "revert back"→"revert", "prepone"→"bring forward",
      "do the needful"→"handle this", "kinda"→"kind of",
      "gonna"→"going to", "wanna"→"want to", "lemme"→"let me".
  • Filler words — remove: "um", "uh", "like", "you know", "basically",
      "actually", "so yeah", "right so", "okay so".
  • Repeated words — deduplicate: "the the", "call call" → keep one.
  • Run-on fragments joined by "and" or "so" — split into sentences.
  • Missing capitalisation at sentence starts.
  • Obvious missing articles (a/an/the) only when unambiguous.
  • Normalise "tommorow", "tommorrow" → "tomorrow".
  DO NOT: translate, summarise, add new context, change names, change numbers.

category — choose EXACTLY ONE:
  "tasks"     → actionable item with a verb: "call", "buy", "finish", "send".
  "reminders" → time-bound alert, event, or appointment.
  "ideas"     → creative concept, insight, or brainstorm with no deadline.
  "follow-up" → any check-in, ping, or follow-up on a previous action:
                  "follow up with X", "check with Y", "ping Z", "any update on".
  "journal"   → personal reflection, emotion, observation, gratitude.
  "general"   → anything that doesn't fit the above.
  TIE-BREAK: tasks > reminders > follow-up > ideas > journal > general.

priority
  "high"   → contains urgency words: "urgent", "asap", "today", "critical",
              "deadline", "immediately", OR an extracted_date within 24 h.
  "medium" → has a date/time in 1–7 days, or mild urgency ("soon", "this week").
  "low"    → everything else.

extracted_date
  • If the note contains a specific date or relative reference, compute the
    absolute date using TODAY'S DATE above and return YYYY-MM-DD.
  • Relative references to resolve (using TODAY'S DATE):
      "today"      → TODAY
      "tomorrow"   → TODAY + 1 day
      "next Monday"→ next calendar Monday
      "this Friday"→ the coming Friday
      "in 3 days"  → TODAY + 3 days
      "next week"  → TODAY + 7 days
  • If no date is mentioned → null.

IMPORTANT: respond with ONLY the JSON object. Zero extra characters.
''';

  /// Builds the system prompt injecting the current date/time for temporal parsing.
  static String buildSystemPrompt() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months   = ['January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'];

    final temporal =
        '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} '
        '(${_tzOffsetString(now)})';

    return _systemPromptTemplate.replaceFirst('{{TEMPORAL_CONTEXT}}', temporal);
  }

  static String _tzOffsetString(DateTime dt) {
    final offset = dt.timeZoneOffset;
    final sign   = offset.isNegative ? '-' : '+';
    final h      = offset.inHours.abs().toString().padLeft(2, '0');
    final m      = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return 'UTC$sign$h:$m';
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Classify
  // ──────────────────────────────────────────────────────────────────────────

  Future<GeminiClassificationResult> classify(
    String rawTranscript, {
    String? modelName,
  }) async {
    if (!isConfigured) {
      return _localFallback(rawTranscript, 'gemini-local');
    }
    if (rawTranscript.trim().isEmpty) {
      return _localFallback('', 'gemini-local');
    }

    try {
      final selectedModel = modelName ?? 'gemini-1.5-flash';
      final model = _providedModel ??
          GenerativeModel(
            model: selectedModel,
            apiKey: _apiKey,
            generationConfig: GenerationConfig(
              temperature: 0.2,
              maxOutputTokens: 512,
              // Constrain to JSON only via responseMimeType when available.
              responseMimeType: 'application/json',
            ),
          );

      final systemPrompt = buildSystemPrompt();
      final prompt = '$systemPrompt\n\nRaw input: ${rawTranscript.trim()}';

      final response = await model.generateContent([Content.text(prompt)]).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('Gemini timeout after 20 s'),
      );

      final raw = response.text ?? '';
      if (raw.trim().isEmpty) {
        throw Exception('Gemini returned empty response');
      }

      return _parseJson(rawTranscript, raw.trim(), model: selectedModel);
    } on TimeoutException catch (e) {
      throw Exception('[GeminiClassifier] Timeout: $e');
    } catch (e) {
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Parsing helpers
  // ──────────────────────────────────────────────────────────────────────────

  GeminiClassificationResult _parseJson(
    String raw,
    String payload, {
    required String model,
    bool wasFallback = false,
  }) {
    try {
      final noFence = payload
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll('```', '')
          .trim();
      final start = noFence.indexOf('{');
      final end   = noFence.lastIndexOf('}');
      if (start < 0 || end <= start) throw FormatException('No JSON object found');

      final decoded = jsonDecode(noFence.substring(start, end + 1)) as Map<String, dynamic>;
      final title     = (decoded['title']      as String?)?.trim();
      final cleanBody = (decoded['clean_body'] as String?)?.trim();
      final categoryText = (decoded['category'] as String?) ?? NoteCategory.general.name;
      final inferredCategory = parseCategory(categoryText);
      final textForHeuristics = [raw, title, cleanBody].whereType<String>().join(' ');

      return GeminiClassificationResult(
        title:         title?.isNotEmpty == true ? title! : _fallbackTitle(raw),
        category:      inferredCategory == NoteCategory.general
            ? inferCategoryFromText(textForHeuristics)
            : inferredCategory,
        priority:      parsePriority((decoded['priority'] as String?) ?? NotePriority.medium.name),
        extractedDate: _parseDate(decoded['extracted_date']),
        cleanBody:     cleanBody?.isNotEmpty == true ? cleanBody! : raw.trim(),
        model:         model,
        wasFallback:   wasFallback,
      );
    } catch (e) {
      return _localFallback(raw, model);
    }
  }

  GeminiClassificationResult _localFallback(String raw, String model) {
    return GeminiClassificationResult(
      title:         _fallbackTitle(raw),
      category:      inferCategoryFromText(raw),
      priority:      NotePriority.medium,
      extractedDate: null,
      cleanBody:     raw.trim(),
      model:         model,
      wasFallback:   true,
    );
  }

  String _fallbackTitle(String raw) {
    final words = raw.trim().split(RegExp(r'\s+')).take(6).toList();
    return words.isEmpty ? 'Quick note' : words.join(' ');
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().toLowerCase() == 'null') return null;
    try {
      return DateTime.parse(value.toString().trim());
    } catch (_) {
      return null;
    }
  }
}

// Simple timeout exception since dart:async's TimeoutException needs an import.
class TimeoutException implements Exception {
  TimeoutException(this.message);
  final String message;
  @override String toString() => 'TimeoutException: $message';
}