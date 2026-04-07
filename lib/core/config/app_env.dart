import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  static Future<void> load() async {
    try {
      if (kIsWeb) {
        return;
      }
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Missing or malformed .env should never crash startup.
    }
  }

  static String get geminiApiKey {
    final fromEnv = dotenv.maybeGet('GEMINI_API_KEY')?.trim();
    return fromEnv == null || fromEnv.isEmpty ? '' : fromEnv;
  }

  static String get telegramBotToken =>
      _readTelegramBotToken();

  static String get telegramBotUsername =>
      _readTelegramBotUsername();

  static String get googleWebClientId {
    final fromEnv = dotenv.maybeGet('GOOGLE_WEB_CLIENT_ID')?.trim();
    return fromEnv == null || fromEnv.isEmpty ? '' : fromEnv;
  }

  static String get groqApiKey {
    final fromEnv = dotenv.maybeGet('GROQ_API_KEY')?.trim();
    return fromEnv == null || fromEnv.isEmpty ? '' : fromEnv;
  }

  static String get huggingFaceApiKey {
    final fromEnv = dotenv.maybeGet('HUGGINGFACE_API_KEY')?.trim();
    return fromEnv == null || fromEnv.isEmpty ? '' : fromEnv;
  }

  static String _readTelegramBotToken() {
    const fromDefine = String.fromEnvironment(
      'TELEGRAM_BOT_TOKEN',
      defaultValue: '',
    );
    final trimmedDefine = fromDefine.trim();
    if (trimmedDefine.isNotEmpty) return trimmedDefine;
    final fromDotEnv = dotenv.maybeGet('TELEGRAM_BOT_TOKEN')?.trim();
    return fromDotEnv == null || fromDotEnv.isEmpty ? '' : fromDotEnv;
  }

  static String _readTelegramBotUsername() {
    const fromDefine = String.fromEnvironment(
      'TELEGRAM_BOT_USERNAME',
      defaultValue: '',
    );
    final trimmedDefine = fromDefine.trim();
    if (trimmedDefine.isNotEmpty) return trimmedDefine;
    final fromDotEnv = dotenv.maybeGet('TELEGRAM_BOT_USERNAME')?.trim();
    return fromDotEnv == null || fromDotEnv.isEmpty ? '' : fromDotEnv;
  }
}
