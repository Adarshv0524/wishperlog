// lib/features/ai/data/unified_ai_classifier.dart
// Unified AI classifier supporting Groq, Mistral, Cerebras, and HuggingFace
// Consolidated from previous Gemini and OpenAI-compatible implementations

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class UnifiedAiClassificationResult {
  const UnifiedAiClassificationResult({
    required this.title,
    required this.translatedTitle,
    required this.category,
    required this.priority,
    required this.cleanBody,
    required this.model,
    this.translatedContent,
    this.extractedDate,
    this.wasFallback = false,
  });

  final String title;
  final String? translatedTitle;
  final NoteCategory category;
  final NotePriority priority;
  final String cleanBody;
  final String model;
  final String? translatedContent;
  final DateTime? extractedDate;
  final bool wasFallback;
}

/// Unified classifier for all AI providers (Groq, Mistral, Cerebras, HuggingFace).
/// 
/// Key features:
/// - Single powerful system prompt across all providers
/// - Consistent JSON parsing and field extraction
/// - Automatic model fallback strategy
/// - Temporal context injection for better date parsing
/// - Multilingual support with translation extraction
/// - Structured output for consistent note classification
class UnifiedAiClassifier {
  const UnifiedAiClassifier({
    required this.providerName,
    required this.apiKey,
    required this.endpoint,
    this.primaryModels = const [],
    this.fallbackModels = const [],
  });

  final String providerName;
  final String apiKey;
  final Uri endpoint;
  final List<String> primaryModels;
  final List<String> fallbackModels;

  bool get isConfigured => apiKey.isNotEmpty;

  /// Build the ultra-powerful system prompt for consistent, high-quality classification.
  /// This prompt emphasizes:
  /// - Precise title generation
  /// - Multi-language support with translation
  /// - Deep category inference
  /// - Temporal awareness with relative date parsing
  /// - Structured output in JSON format
  static String buildSystemPrompt({
    String? userLocation,
    String? userContext,
  }) {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final temporal =
        '${weekdays[now.weekday - 1]} ${now.day} ${months[now.month - 1]} '
        '${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')} '
        '(UTC${now.timeZoneOffset.isNegative ? '-' : '+'}${now.timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:'
        '${(now.timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')})';

    final envLines = <String>[
      'NOW: $temporal',
      if ((userLocation ?? '').isNotEmpty) 'LOCATION: $userLocation',
      if ((userContext ?? '').isNotEmpty) 'USER_CONTEXT: $userContext',
    ].join('\n');

    return '''YOU ARE WISHPERLOG'S INTELLIGENT NOTE CLASSIFIER AND OPTIMIZER.

YOUR MISSION:
Parse user voice/text input into actionable, properly categorized, and multilingual notes.
Return ONLY valid JSON—no prose, markdown, code fences, or explanations.

─── STEP 0 — PHONETIC CORRECTION (MANDATORY, RUNS BEFORE ALL OTHER STEPS) ────────────────
You are an expert at repairing messy speech-to-text transcripts.
Before classifying, silently correct ALL phonetic transcription errors.
Common substitutions (apply these and any other obvious speech-to-text artefacts) just example , you can apply your logic to correct any similar errors:
  "toesday"    → "Tuesday"
  "wendsday"   → "Wednesday"
  "thrusday"   → "Thursday"
  "fri day"    → "Friday"
  "saterday"   → "Saturday"
  "febuary"    → "February"
  "janurary"   → "January"
  "remined"    → "remind"
  "calander"   → "calendar"
  "importent"  → "important"
Use the NOW context below to anchor relative dates:
  "next Tuesday" when today is Tuesday, 14 Apr 2026 → 21 Apr 2026.
  "tomorrow"                                        → 15 Apr 2026.
  "this Friday"                                     → 17 Apr 2026.
Perform correction silently — do NOT include a "corrected" field in output.

ENVIRONMENT CONTEXT:
$envLines

SUPPORTED CATEGORIES: tasks | reminders | ideas | follow_up | journal | general
PRIORITY LEVELS: high | medium | low

OUTPUT SCHEMA (ALL FIELDS REQUIRED):
{
  "title": "<concise 5-8 word imperative title in INPUT LANGUAGE>",
  "translated_title": "<English translation of title IF input is non-English; null if already English>",
  "clean_body": "<polished version preserving INPUT LANGUAGE, fix grammar/clarity, max 500 chars>",
  "category": "<one of: tasks, reminders, ideas, follow_up, journal, general>",
  "priority": "<high | medium | low>",
  "extracted_date": "<ISO 8601 datetime or null if no date mentioned>",
  "translated_content": "<English translation of clean_body IF input is non-English; null if already English>"
}

CLASSIFICATION RULES:

1. TITLE GENERATION:
   - Imperative mood preferred: "buy milk", "call mom", "plan trip"
   - 5-8 words max, clear and scannable
   - In the user's original language
   - Start with action verb when possible

2. LANGUAGE & TRANSLATION:
   - Preserve original language in title and clean_body
   - If user speaks Hindi, Telugu, Tamil, Malayalam, Marathi, or any non-English language:
     * ALWAYS populate translated_title with natural English equivalent
     * ALWAYS populate translated_content with full English translation
   - If input is already English:
     * Set translated_title to null
     * Set translated_content to null
   - Translations must be semantically accurate and idiomatic (not literal)

3. CATEGORY INFERENCE:
   - tasks      → Action-oriented: starts with verb, "to-do", "karna hai", "cheyyali", "cheyali"
   - reminders  → Time-bound awareness: "remind me", "yaad rakhna", "remind", "alert"
   - follow_up  → Needs investigation: "follow up", "puchna hai", "check on", "verify"
   - ideas      → Exploratory: "what if", "kya agar", "brainstorm", "consider", "imagine"
   - journal    → Reflective/emotional: "I feel", "today I learned", "grateful for", "reflective tone"
   - general    → Fallback if no strong match; informational notes, miscellaneous
   
   Use context + keywords to rank category confidence. If unsure, default to 'general'.

4. PRIORITY INFERENCE:
   - HIGH    → Urgent, deadline-driven, safety-critical, "ASAP", "urgent", "immediately"
   - MEDIUM  → Standard, typical tasks with normal importance
   - LOW     → Someday/maybe, vague future, backlog, exploratory, "when possible"
   
   Default to MEDIUM unless strong urgency signals present.

5. DATE EXTRACTION (run AFTER phonetic correction from Step 0):
   - Parse absolute: "2024-03-15", "March 15", "next Monday"
   - Parse relative: "tomorrow", "next week", "in 3 days", "kal", "parson", "hafte mein"
   - Use NOW context to resolve: "next Tuesday" when NOW is Tue 14 Apr 2026 → 21 Apr 2026.
   - Phonetic date words ("toesday", "wendsday") are already corrected before this step runs.
   - Return ISO 8601 format or null if unresolvable.
   - ALWAYS include time component when a time is stated; otherwise use T09:00:00Z as default.

6. TEXT CLEANING:
   - Fix obvious typos, stutter repetition: "I umm I want" → "I want"
   - Remove filler words: "like", "um", "uh", "basically", "you know"
   - Improve grammar while preserving intent and original language
   - Keep emotional tone if reflective/journal entry
   - Max 500 chars; if longer, summarize key points

7. MULTILINGUAL ROBUSTNESS:
   - Accept mixed-language input: "kya agar we could meet tomorrow at coffee?"
   - Detect primary language by word count; classify accordingly
   - Translate coherently even with code-switching
   - Preserve original language in output fields; provide English in translated_* fields

EXAMPLE INPUTS & EXPECTED OUTPUTS:

INPUT 1 (Hindi): "kal mohan ko call krna reminder do"
OUTPUT:
{
  "title": "Mohan ko call karna",
  "translated_title": "Call Mohan",
  "clean_body": "Mohan ko kal call karna hai",
  "translated_content": "Need to call Mohan tomorrow",
  "category": "reminders",
  "priority": "medium",
  "extracted_date": "2025-04-15T00:00:00Z",
  "category_confidence": 0.95
}

INPUT 2 (English): "Buy groceries tomorrow morning before 10am"
OUTPUT:
{
  "title": "Buy groceries tomorrow morning",
  "translated_title": null,
  "clean_body": "Buy groceries tomorrow morning before 10 AM",
  "translated_content": null,
  "category": "tasks",
  "priority": "medium",
  "extracted_date": "2025-04-15T10:00:00Z"
}

INPUT 3 (Mixed): "what if we could integrate AI for better note search?"
OUTPUT:
{
  "title": "Integrate AI for note search",
  "translated_title": null,
  "clean_body": "Consider integrating AI capabilities for enhanced note search functionality",
  "translated_content": null,
  "category": "ideas",
  "priority": "low",
  "extracted_date": null
}

FINAL RULES:
- Always return valid JSON (no extra formatting, no markdown)
- All fields must be present (use null for undefined translations or dates)
- Be generous with translations for non-English input
- Favor user intent over grammatical perfection
- If ambiguous, choose the most actionable classification
- Never make assumptions about dates beyond the examples provided
''';
  }

  /// Classify a transcript using this provider.
  Future<UnifiedAiClassificationResult?> classify(
    String rawTranscript, {
    String? modelName,
  }) async {
    if (!isConfigured || rawTranscript.trim().isEmpty) return null;

    final candidates = <String>{
      if (modelName != null && modelName.trim().isNotEmpty) modelName.trim(),
      ...primaryModels,
      ...fallbackModels,
    }.toList();

    for (final model in candidates) {
      final result = await _callApi(rawTranscript, model);
      if (result != null) return result;
      if (model == primaryModels.firstOrNull) {
        debugPrint(
            '[$providerName] Primary model $model failed, trying fallback');
      }
    }
    return null;
  }

  /// Call the provider's API and parse the response.
  Future<UnifiedAiClassificationResult?> _callApi(
    String rawTranscript,
    String model,
  ) async {
    try {
      final response = await http
          .post(
            endpoint,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {
                  'role': 'system',
                  'content': buildSystemPrompt(),
                },
                {
                  'role': 'user',
                  'content': 'Raw input: ${rawTranscript.trim()}',
                },
              ],
              'temperature': 0.2,
              'max_tokens': 800,
              // Groq and Mistral support JSON response format.
              // Cerebras and HuggingFace extract JSON from freeform output.
              if (_supportsJsonResponseFormat(providerName))
                'response_format': {'type': 'json_object'},
            }),
          )
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 429) {
        debugPrint('[$providerName] Rate limit on $model');
        return null;
      }

      if (response.statusCode != 200) {
        debugPrint(
            '[$providerName] API error ${response.statusCode}: ${response.body}');
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content = _extractContent(body);
      if (content == null || content.trim().isEmpty) return null;

      return _parseResponse(rawTranscript, content.trim(),
          model: '$providerName-$model');
    } catch (e) {
      debugPrint('[$providerName] classify on $model: $e');
      return null;
    }
  }

  /// Extract the message content from provider response.
  String? _extractContent(Map<String, dynamic> body) {
    final choices = body['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final first = choices.first;
    if (first is! Map<String, dynamic>) return null;
    final message = first['message'];
    if (message is! Map<String, dynamic>) return null;
    return message['content'] as String?;
  }

  /// Parse JSON response from provider.
  UnifiedAiClassificationResult? _parseResponse(
    String raw,
    String payload, {
    required String model,
  }) {
    try {
      // Remove markdown code fences if present.
      final noFence = payload
          .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      // Extract first complete JSON object.
      final start = noFence.indexOf('{');
      final end = noFence.lastIndexOf('}');
      if (start < 0 || end <= start) {
        debugPrint('[$providerName] No JSON in response');
        return null;
      }

      final decoded =
          jsonDecode(noFence.substring(start, end + 1)) as Map<String, dynamic>;

      final title = (decoded['title'] as String?)?.trim();
      final translatedTitle = (decoded['translated_title'] as String?)?.trim();
      final translatedContent =
          (decoded['translated_content'] as String?)?.trim();
      final cleanBody = (decoded['clean_body'] as String?)?.trim();
      final categoryText =
          (decoded['category'] as String?) ?? NoteCategory.general.name;
      final priorityText =
          (decoded['priority'] as String?) ?? NotePriority.medium.name;

      final inferredCategory = parseCategory(categoryText);
      final textForHeuristics =
          [raw, title, cleanBody].whereType<String>().join(' ');

      return UnifiedAiClassificationResult(
        title: title?.isNotEmpty == true ? title! : _fallbackTitle(raw),
        translatedTitle:
            translatedTitle?.isNotEmpty == true ? translatedTitle : null,
        translatedContent:
            translatedContent?.isNotEmpty == true ? translatedContent : null,
        category: inferredCategory == NoteCategory.general
            ? inferCategoryFromText(textForHeuristics)
            : inferredCategory,
        priority: parsePriority(priorityText),
        extractedDate: _parseDate(decoded['extracted_date']),
        cleanBody: cleanBody?.isNotEmpty == true ? cleanBody! : raw.trim(),
        model: model,
        wasFallback: false,
      );
    } catch (e) {
      debugPrint('[$providerName] Parse error: $e');
      return null;
    }
  }

  String _fallbackTitle(String raw) {
    final words = raw.trim().split(RegExp(r'\s+')).take(8).toList();
    return words.isEmpty ? 'Quick note' : words.join(' ');
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().toLowerCase() == 'null') {
      return null;
    }
    try {
      return DateTime.parse(value.toString().trim());
    } catch (_) {
      return null;
    }
  }

  static bool _supportsJsonResponseFormat(String provider) {
    final name = provider.toLowerCase();
    return name == 'groq' || name == 'mistral';
  }
}
