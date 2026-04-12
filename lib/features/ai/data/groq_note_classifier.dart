import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

/// Groq Chat API classifier (OpenAI-compatible).
/// Primary model: llama-3.3-70b-versatile
/// Fallback model: llama-3.1-8b-instant (if 70b hits rate limit)
///
/// Uses the shared GeminiNoteClassifier.buildSystemPrompt() so both
/// providers use identical prompt logic including temporal context.
class GroqNoteClassifier {
  static const _baseUrl      = 'https://api.groq.com/openai/v1/chat/completions';
  static const _primaryModel = 'llama-3.3-70b-versatile';
  static const _fallbackModel = 'llama-3.1-8b-instant';
  static const List<String> supportedModels = [
    'llama-3.3-70b-versatile',
    'llama-3.1-8b-instant',
    'qwen3-32b',
    'llama-4-scout-17b-16e-instruct',
  ];

  final String _apiKey;

  GroqNoteClassifier({String? apiKey}) : _apiKey = apiKey ?? AppEnv.groqApiKey;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<GeminiClassificationResult?> classify(
    String rawTranscript, {
    String? modelName,
  }) async {
    if (!isConfigured || rawTranscript.trim().isEmpty) return null;

    final candidates = <String>{
      if (modelName != null && modelName.trim().isNotEmpty) modelName.trim(),
      _primaryModel,
      _fallbackModel,
      ...supportedModels,
    }.toList();

    for (final model in candidates) {
      final result = await _callApi(rawTranscript, model);
      if (result != null) return result;
      if (model == _primaryModel) {
        debugPrint('[GroqClassifier] Primary model failed, trying fallback model');
      }
    }
    return null;
  }

  Future<GeminiClassificationResult?> _callApi(String rawTranscript, String model) async {
    try {
      final systemPrompt = GeminiNoteClassifier.buildSystemPrompt();

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type':  'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user',   'content': 'Raw input: ${rawTranscript.trim()}'},
          ],
          'temperature':  0.2,
          'max_tokens':   512,
          // JSON mode — Groq supports this for llama models.
          'response_format': {'type': 'json_object'},
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 429) {
        debugPrint('[GroqClassifier] Rate limit hit on $model');
        return null; // caller will try fallback
      }

      if (response.statusCode != 200) {
        debugPrint('[GroqClassifier] API error ${response.statusCode} on $model: ${response.body}');
        return null;
      }

      final body    = jsonDecode(response.body) as Map<String, dynamic>;
      final content = (body['choices'] as List?)?.first?['message']?['content'] as String?;
      if (content == null || content.isEmpty) return null;

      return _parse(rawTranscript, content.trim(), model: 'groq-$model');
    } catch (e) {
      debugPrint('[GroqClassifier] classify error on $model: $e');
      return null;
    }
  }

  GeminiClassificationResult? _parse(String raw, String payload, {required String model}) {
    try {
      final noFence = payload
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll('```', '')
          .trim();
      final start = noFence.indexOf('{');
      final end   = noFence.lastIndexOf('}');
      if (start < 0 || end <= start) return null;

      final decoded   = jsonDecode(noFence.substring(start, end + 1)) as Map<String, dynamic>;
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
        priority:      parsePriority((decoded['priority']  as String?) ?? NotePriority.medium.name),
        extractedDate: _parseDate(decoded['extracted_date']),
        cleanBody:     cleanBody?.isNotEmpty == true ? cleanBody! : raw.trim(),
        model:         model,
        wasFallback:   false,
      );
    } catch (e) {
      debugPrint('[GroqClassifier] parse error: $e');
      return null;
    }
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