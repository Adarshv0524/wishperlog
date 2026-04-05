import 'package:flutter/foundation.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class MlToolkitService {
  MlToolkitService()
      : _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.45),
        _modelManager = OnDeviceTranslatorModelManager();

  final LanguageIdentifier _languageIdentifier;
  final OnDeviceTranslatorModelManager _modelManager;

  Future<MlDetectedLanguage?> detectLanguage(String text) async {
    final input = text.trim();
    if (input.isEmpty) return null;

    try {
      final candidates = await _languageIdentifier.identifyPossibleLanguages(input);
      if (candidates.isEmpty) return null;
      final top = candidates.first;
      if (top.languageTag == 'und') return null;
      return MlDetectedLanguage(
        languageTag: top.languageTag,
        confidence: top.confidence,
      );
    } catch (e) {
      debugPrint('[MlToolkitService] detectLanguage error: $e');
      return null;
    }
  }

  Future<bool> isTranslationModelDownloaded(String languageCode) async {
    final language = _toTranslateLanguage(languageCode);
    if (language == null) return false;
    try {
      return _modelManager.isModelDownloaded(language.bcpCode);
    } catch (e) {
      debugPrint('[MlToolkitService] isModelDownloaded error: $e');
      return false;
    }
  }

  Future<bool> downloadTranslationModel(String languageCode) async {
    final language = _toTranslateLanguage(languageCode);
    if (language == null) return false;
    try {
      return _modelManager.downloadModel(language.bcpCode);
    } catch (e) {
      debugPrint('[MlToolkitService] downloadModel error: $e');
      return false;
    }
  }

  Future<bool> deleteTranslationModel(String languageCode) async {
    final language = _toTranslateLanguage(languageCode);
    if (language == null) return false;
    try {
      return _modelManager.deleteModel(language.bcpCode);
    } catch (e) {
      debugPrint('[MlToolkitService] deleteModel error: $e');
      return false;
    }
  }

  TranslateLanguage? _toTranslateLanguage(String code) {
    final normalized = code.toLowerCase().replaceAll('_', '-');
    if (normalized.startsWith('en')) return TranslateLanguage.english;
    if (normalized.startsWith('hi')) return TranslateLanguage.hindi;
    if (normalized.startsWith('bn')) return TranslateLanguage.bengali;
    if (normalized.startsWith('ta')) return TranslateLanguage.tamil;
    if (normalized.startsWith('te')) return TranslateLanguage.telugu;
    if (normalized.startsWith('mr')) return TranslateLanguage.marathi;
    if (normalized.startsWith('gu')) return TranslateLanguage.gujarati;
    if (normalized.startsWith('kn')) return TranslateLanguage.kannada;
    // Malayalam and Punjabi are not currently exposed by this package version.
    if (normalized.startsWith('ml')) return null;
    if (normalized.startsWith('pa')) return null;
    if (normalized.startsWith('es')) return TranslateLanguage.spanish;
    if (normalized.startsWith('fr')) return TranslateLanguage.french;
    if (normalized.startsWith('de')) return TranslateLanguage.german;
    if (normalized.startsWith('ja')) return TranslateLanguage.japanese;
    return null;
  }
}

class MlDetectedLanguage {
  const MlDetectedLanguage({
    required this.languageTag,
    required this.confidence,
  });

  final String languageTag;
  final double confidence;
}
