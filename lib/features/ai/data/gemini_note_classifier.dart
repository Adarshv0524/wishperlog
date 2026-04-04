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
      'You are a personal note classifier. Return JSON with title, category, priority, clean_body, extracted_date. '
      'Return ONLY valid JSON with these exact keys: "title", "category", "priority", "clean_body", "extracted_date". '
      'Allowed category values: Tasks, Reminders, Ideas, Follow-up, Journal, General. '
      'Allowed priority values: high, medium, low. '
      'Use null when extracted_date is unknown. No markdown, no extra keys.';

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

    final response = await model.generateContent([
      Content.text(systemPrompt),
      Content.text('Raw input: $text'),
    ]);

    final payload = response.text?.trim();
    if (payload == null || payload.isEmpty) {
      return _fallback(rawTranscript, model: 'gemini-2.5-flash-lite');
    }

    return _parseOrFallback(
      rawTranscript: rawTranscript,
      payload: payload,
      model: 'gemini-2.5-flash-lite',
    );
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
        category: parseCategory((decoded['category'] as String?) ?? 'General'),
        priority: parsePriority((decoded['priority'] as String?) ?? 'medium'),
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
