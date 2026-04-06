import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  static Future<void> load() async {
    try {
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
      _readDefineThenDotenv('TELEGRAM_BOT_TOKEN');

  static String get telegramBotUsername =>
      _readDefineThenDotenv('TELEGRAM_BOT_USERNAME');

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

  static String _readDefineThenDotenv(String key) {
    final fromDefine = String.fromEnvironment(key, defaultValue: '').trim();
    if (fromDefine.isNotEmpty) return fromDefine;
    final fromDotEnv = dotenv.maybeGet(key)?.trim();
    return fromDotEnv == null || fromDotEnv.isEmpty ? '' : fromDotEnv;
  }
}
