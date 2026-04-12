import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  /// Whether [load] has completed at least once.
  static bool _loaded = false;

  /// Must be called before accessing any getter. Safe to call more than once.
  static Future<void> load() async {
    if (_loaded) return;
    try {
      if (!kIsWeb) {
        await dotenv.load(fileName: '.env');
      }
    } catch (_) {
      // Missing / malformed .env must never crash startup or background isolates.
    } finally {
      _loaded = true;
    }
  }

  // ── Internal safe reader ────────────────────────────────────────────────────
  // Returns '' (not null, not throws) when dotenv has not been initialized or
  // the key is absent. This is the ONLY method that should touch dotenv.
  static String _safeGet(String key) {
    try {
      final v = dotenv.maybeGet(key)?.trim();
      return (v == null || v.isEmpty) ? '' : v;
    } catch (_) {
      // NotInitializedError or any other dotenv error → empty default.
      return '';
    }
  }

  // ── Getters ─────────────────────────────────────────────────────────────────

  static String get geminiApiKey => _safeGet('GEMINI_API_KEY');

  static String get groqApiKey => _safeGet('GROQ_API_KEY');

  static String get mistralApiKey => _safeGet('MISTRAL_API_KEY');

  static String get huggingFaceApiKey => _safeGet('HUGGINGFACE_API_KEY');

  static String get cerebrasApiKey => _safeGet('CEREBRAS_API_KEY');

  static String get googleWebClientId {
    const fromDefine = String.fromEnvironment(
      'GOOGLE_WEB_CLIENT_ID',
      defaultValue:
          '982731246537-6a8ov59qm6n6f6v7rakq4su2eje8g9au.apps.googleusercontent.com',
    );
    final trimmedDefine = fromDefine.trim();
    if (trimmedDefine.isNotEmpty) return trimmedDefine;
    return _safeGet('GOOGLE_WEB_CLIENT_ID');
  }

  static String get telegramBotToken {
    const fromDefine = String.fromEnvironment('TELEGRAM_BOT_TOKEN', defaultValue: '');
    final trimmedDefine = fromDefine.trim();
    if (trimmedDefine.isNotEmpty) return trimmedDefine;
    return _safeGet('TELEGRAM_BOT_TOKEN');
  }

  static String get telegramBotUsername {
    const fromDefine = String.fromEnvironment('TELEGRAM_BOT_USERNAME', defaultValue: '');
    final trimmedDefine = fromDefine.trim();
    if (trimmedDefine.isNotEmpty) return trimmedDefine;
    return _safeGet('TELEGRAM_BOT_USERNAME');
  }

  static String get telegramDeepLinkBase {
    const fromDefine = String.fromEnvironment('TELEGRAM_DEEP_LINK_BASE', defaultValue: '');
    final trimmedDefine = fromDefine.trim();
    if (trimmedDefine.isNotEmpty) return trimmedDefine;
    return _safeGet('TELEGRAM_DEEP_LINK_BASE');
  }
}