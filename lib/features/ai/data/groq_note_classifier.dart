import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

/// Calls Groq Chat API (OpenAI-compatible) to classify notes.
/// Uses llama-3.3-70b-versatile by default.
class GroqNoteClassifier {
  static const _baseUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  final String _apiKey;

  GroqNoteClassifier({String? apiKey}) : _apiKey = apiKey ?? AppEnv.groqApiKey;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<GeminiClassificationResult?> classify(String rawTranscript) async {
    if (!isConfigured || rawTranscript.trim().isEmpty) return null;

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {'role': 'system', 'content': GeminiNoteClassifier.systemPrompt},
            {'role': 'user', 'content': 'Raw input: ${rawTranscript.trim()}'},
          ],
          'temperature': 0.3,
          'max_tokens': 512,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        debugPrint('[GroqClassifier] API error ${response.statusCode}: ${response.body}');
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content = (body['choices'] as List?)?.first?['message']?['content'] as String?;
      if (content == null || content.isEmpty) return null;

      return _parse(rawTranscript, content.trim());
    } catch (e) {
      debugPrint('[GroqClassifier] classify error: $e');
      return null;
    }
  }

  GeminiClassificationResult? _parse(String raw, String payload) {
    try {
      final noFence = payload
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();
      final start = noFence.indexOf('{');
      final end = noFence.lastIndexOf('}');
      if (start < 0 || end < start) return null;

      final decoded = jsonDecode(noFence.substring(start, end + 1)) as Map<String, dynamic>;
      final title = (decoded['title'] as String?)?.trim();
      final cleanBody = (decoded['clean_body'] as String?)?.trim();
      return GeminiClassificationResult(
        title: (title == null || title.isEmpty) ? _fallbackTitle(raw) : title,
        category: parseCategory((decoded['category'] as String?) ?? NoteCategory.general.name),
        priority: parsePriority((decoded['priority'] as String?) ?? NotePriority.medium.name),
        extractedDate: _parseDate(decoded['extracted_date']),
        cleanBody: (cleanBody == null || cleanBody.isEmpty) ? raw.trim() : cleanBody,
        model: 'groq/$_model',
        wasFallback: false,
      );
    } catch (_) {
      return null;
    }
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final raw = value.toString().trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null') return null;
    return DateTime.tryParse(raw)?.toLocal();
  }

  String _fallbackTitle(String text) {
    final oneLine = text.replaceAll('\n', ' ').trim();
    if (oneLine.length <= 60) return oneLine;
    return '${oneLine.substring(0, 60).trimRight()}...';
  }
}
