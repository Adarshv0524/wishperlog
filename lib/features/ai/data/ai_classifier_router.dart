import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/features/ai/data/groq_note_classifier.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

/// Routes classification requests through the active provider with automatic
/// fallback chain: Gemini → Groq → local (no enrichment).
///
/// The fallback is SEAMLESS — callers receive a valid result regardless of
/// which provider handled it.  `result.wasFallback` and `result.model`
/// expose which path was taken for logging/debugging.
class AiClassifierRouter {
  static const _prefsKey = 'ai_provider';

  final GeminiNoteClassifier _gemini;
  final GroqNoteClassifier   _groq;
  AiProvider _activeProvider     = AiProvider.auto;
  String     _lastUsedModelName  = 'AI';

  AiClassifierRouter()
      : _gemini = GeminiNoteClassifier(),
        _groq   = GroqNoteClassifier();

  AiProvider get activeProvider    => _activeProvider;
  String     get lastUsedModelName => _lastUsedModelName;
  bool get geminiConfigured => _gemini.isConfigured;
  bool get groqConfigured   => _groq.isConfigured;

  /// Load persisted provider preference.
  Future<void> hydrate() async {
    try {
      final prefs  = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      _activeProvider = AiProvider.values.firstWhere(
        (p) => p.name == stored,
        orElse: () => AiProvider.auto,
      );
    } catch (e) {
      debugPrint('[AiClassifierRouter] hydrate error: $e');
    }
  }

  Future<void> setProvider(AiProvider provider) async {
    _activeProvider = provider;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, provider.name);
    } catch (e) {
      debugPrint('[AiClassifierRouter] setProvider error: $e');
    }
  }

  /// Classify [rawTranscript] using the configured provider chain.
  ///
  /// Temporal context (current date/time) is automatically injected
  /// inside [GeminiNoteClassifier.buildSystemPrompt()] — no extra work needed.
  Future<GeminiClassificationResult> classify(String rawTranscript) async {
    GeminiClassificationResult result;

    switch (_activeProvider) {
      case AiProvider.groq:
        result = await _tryGroq(rawTranscript) ?? _localFallback(rawTranscript);
        break;

      case AiProvider.gemini:
        try {
          result = await _gemini.classify(rawTranscript);
        } catch (e) {
          debugPrint('[AiClassifierRouter] Gemini forced-mode failed: $e');
          result = _localFallback(rawTranscript);
        }
        break;

      case AiProvider.huggingface:
      case AiProvider.auto:
        // Try Gemini first, seamlessly fall through to Groq, then local.
        result = await _tryGeminiThenGroq(rawTranscript);
        break;
    }

    _lastUsedModelName = result.model;
    debugPrint('[AiClassifierRouter] Classified via ${result.model} '
        '(fallback=${result.wasFallback}): ${result.category.name}');
    return result;
  }

  // ─── Internal routing helpers ──────────────────────────────────────────────

  Future<GeminiClassificationResult> _tryGeminiThenGroq(String raw) async {
    // ── Step 1: Gemini ────────────────────────────────────────────────────────
    if (_gemini.isConfigured) {
      try {
        return await _gemini.classify(raw);
      } catch (e) {
        debugPrint('[AiClassifierRouter] Gemini failed → trying Groq. Error: $e');
      }
    }

    // ── Step 2: Groq fallback ─────────────────────────────────────────────────
    final groqResult = await _tryGroq(raw);
    if (groqResult != null) return groqResult;

    // ── Step 3: Local (no-AI) fallback ────────────────────────────────────────
    debugPrint('[AiClassifierRouter] Both AI providers failed — using local fallback');
    return _localFallback(raw);
  }

  Future<GeminiClassificationResult?> _tryGroq(String raw) async {
    if (!_groq.isConfigured) return null;
    try {
      return await _groq.classify(raw);
    } catch (e) {
      debugPrint('[AiClassifierRouter] Groq failed: $e');
      return null;
    }
  }

  /// Zero-AI local fallback — returns raw text with "general" category.
  GeminiClassificationResult _localFallback(String raw) {
    final cleaned = raw.trim();
    final words   = cleaned.split(RegExp(r'\s+')).take(6).toList();
    final title   = words.isEmpty ? 'Quick note' : words.join(' ');
    return GeminiClassificationResult(
      title:         title,
      category:      inferCategoryFromText(cleaned),
      priority:      NotePriority.medium,
      extractedDate: null,
      cleanBody:     cleaned,
      model:         'local',
      wasFallback:   true,
    );
  }
}