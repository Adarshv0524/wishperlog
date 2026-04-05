import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class GeminiClassificationResult {
  GeminiClassificationResult({
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
  GeminiNoteClassifier({
    String? apiKey,
    GenerativeModel? model,
  })  : _apiKey = apiKey ?? AppEnv.geminiApiKey,
        _providedModel = model;

  static const String systemPrompt =
      '''Output ONLY a raw, valid JSON object. NO markdown formatting, NO backticks (```), NO explanations.
TEXT RULES:
1. Preserve original language, tone, slang, and intent. DO NOT translate, summarize, expand, or beautify.
2. Fix ONLY obvious typos, grammar, and punctuation.

REQUIRED SCHEMA:
{
  "title": "<string: concise, max 8 words, original language>",
  "clean_body": "<string: lightly edited text per rules>",
  "category": "<string: lowercase exact match: tasks, reminders, ideas, follow-up, journal, or general>",
  "priority": "<string: lowercase exact match: high, medium, or low (default: medium)>",
  "extracted_date": "<string or null: ISO8601 'YYYY-MM-DD' if an action date is implied, else null>"
}''';

  final String _apiKey;
  final GenerativeModel? _providedModel;

  bool get isConfigured => _providedModel != null || _apiKey.isNotEmpty;

  Future<GeminiClassificationResult> classify(String rawTranscript) async {
    final text = rawTranscript.trim();
    if (text.isEmpty) {
      return _fallback(rawTranscript, model: 'none');
    }

    if (!isConfigured) {
      return _fallback(rawTranscript, model: 'offline-fallback');
    }

    final model = _providedModel ??
        GenerativeModel(model: 'gemini-2.5-flash-lite', apiKey: _apiKey);

    const maxAttempts = 3;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final response = await model.generateContent([
          Content.text(systemPrompt),
          Content.text('Raw input: $text'),
        ]).timeout(const Duration(seconds: 7));

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
        final errorStr = e.toString();
        final isRateLimit = errorStr.contains('429') ||
            errorStr.contains('quota') ||
            errorStr.contains('rate limit') ||
            errorStr.contains('RESOURCE_EXHAUSTED');

        if (!isRateLimit || attempt >= maxAttempts - 1) {
          // Not a rate limit error or exhausted retries → graceful fallback
          return _fallback(rawTranscript, model: 'gemini-2.5-flash-lite');
        }

        // Try to parse "retry in Xs" from the error message
        Duration backoff = Duration(seconds: 2 * (attempt + 1));
        final retryMatch = RegExp(r'retry in (\d+(?:\.\d+)?)s').firstMatch(errorStr);
        if (retryMatch != null) {
          final seconds = double.tryParse(retryMatch.group(1) ?? '') ?? 0;
          backoff = Duration(milliseconds: (seconds * 1000).ceil() + 500);
        }

        await Future<void>.delayed(backoff);
      }
    }

    return _fallback(rawTranscript, model: 'gemini-2.5-flash-lite');
  }

  GeminiClassificationResult _parseOrFallback({
    required String rawTranscript,
    required String payload,
    required String model,
  }) {
    try {
      final jsonBody = _extractJson(payload);
      final decoded = jsonDecode(jsonBody);
      if (decoded is! Map<String, dynamic>) {
        return _fallback(rawTranscript, model: model);
      }

      final title = (decoded['title'] as String?)?.trim();
      final cleanBody = (decoded['clean_body'] as String?)?.trim();

      return GeminiClassificationResult(
        title: (title == null || title.isEmpty)
            ? _fallbackTitle(rawTranscript)
            : title,
        category: parseCategory(
          (decoded['category'] as String?) ?? NoteCategory.general.name,
        ),
        priority: parsePriority(
          (decoded['priority'] as String?) ?? NotePriority.medium.name,
        ),
        extractedDate: _parseDate(decoded['extracted_date']),
        cleanBody: (cleanBody == null || cleanBody.isEmpty)
            ? rawTranscript.trim()
            : cleanBody,
        model: model,
        wasFallback: false,
      );
    } catch (_) {
      return _fallback(rawTranscript, model: model);
    }
  }

  String _extractJson(String payload) {
    final noFence = payload
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final start = noFence.indexOf('{');
    final end = noFence.lastIndexOf('}');
    if (start >= 0 && end >= start) {
      return noFence.substring(start, end + 1);
    }
    return noFence;
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }
    final raw = value.toString().trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null') {
      return null;
    }
    return DateTime.tryParse(raw)?.toLocal();
  }

  GeminiClassificationResult _fallback(String rawTranscript, {required String model}) {
    final cleaned = rawTranscript.trim();
    return GeminiClassificationResult(
      title: _fallbackTitle(rawTranscript),
      category: NoteCategory.general,
      priority: NotePriority.medium,
      extractedDate: null,
      cleanBody: cleaned.isEmpty ? rawTranscript : cleaned,
      model: model,
      wasFallback: true,
    );
  }

  String _fallbackTitle(String text) {
    final oneLine = text.replaceAll('\n', ' ').trim();
    if (oneLine.isEmpty) {
      return 'Quick note';
    }
    if (oneLine.length <= 60) {
      return oneLine;
    }
    return '${oneLine.substring(0, 60).trimRight()}...';
  }
}
