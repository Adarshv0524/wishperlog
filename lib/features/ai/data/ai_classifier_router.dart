import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/features/ai/data/groq_note_classifier.dart';
import 'package:wishperlog/shared/models/enums.dart';

/// Routes classification requests through the active provider with automatic
/// fallback: Gemini → Groq → local (no enrichment).
class AiClassifierRouter {
  static const _prefsKey = 'ai_provider';

  final GeminiNoteClassifier _gemini;
  final GroqNoteClassifier _groq;
  AiProvider _activeProvider = AiProvider.auto;

  AiClassifierRouter()
      : _gemini = GeminiNoteClassifier(),
        _groq = GroqNoteClassifier();

  AiProvider get activeProvider => _activeProvider;

  bool get geminiConfigured => _gemini.isConfigured;
  bool get groqConfigured => _groq.isConfigured;

  /// Load preference from SharedPreferences
  Future<void> hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      _activeProvider = AiProvider.values.firstWhere(
        (p) => p.name == stored,
        orElse: () => AiProvider.auto,
      );
    } catch (e) {
      debugPrint('[AiClassifierRouter] hydrate error: $e');
    }
  }

  /// Persist chosen provider
  Future<void> setProvider(AiProvider provider) async {
    _activeProvider = provider;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, provider.name);
    } catch (e) {
      debugPrint('[AiClassifierRouter] setProvider error: $e');
    }
  }

  /// Classify a note using the configured provider chain.
  Future<GeminiClassificationResult> classify(String rawTranscript) async {
    switch (_activeProvider) {
      case AiProvider.groq:
        return await _tryGroq(rawTranscript) ?? _localFallback(rawTranscript);
      case AiProvider.gemini:
        return await _gemini.classify(rawTranscript);
      case AiProvider.huggingface:
      case AiProvider.auto:
        // Try Gemini first, then Groq, then local
        try {
          return await _gemini.classify(rawTranscript);
        } catch (e) {
          debugPrint('[AiClassifierRouter] Gemini failed, trying Groq: $e');
          return await _tryGroq(rawTranscript) ?? _localFallback(rawTranscript);
        }
    }
  }

  Future<GeminiClassificationResult?> _tryGroq(String rawTranscript) async {
    if (!_groq.isConfigured) return null;
    try {
      return await _groq.classify(rawTranscript);
    } catch (e) {
      debugPrint('[AiClassifierRouter] Groq failed: $e');
      return null;
    }
  }

  GeminiClassificationResult _localFallback(String raw) {
    final cleaned = raw.trim();
    final oneLine = cleaned.replaceAll('\n', ' ');
    return GeminiClassificationResult(
      title: oneLine.length <= 60 ? oneLine : '${oneLine.substring(0, 60)}...',
      category: NoteCategory.general,
      priority: NotePriority.medium,
      extractedDate: null,
      cleanBody: cleaned,
      model: 'local-fallback',
      wasFallback: true,
    );
  }
}
