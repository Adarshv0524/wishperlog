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

  static String get telegramBotUsername {
    final fromEnv = dotenv.maybeGet('TELEGRAM_BOT_USERNAME')?.trim();
    return fromEnv == null || fromEnv.isEmpty ? '' : fromEnv;
  }

  static String get googleWebClientId {
    final fromEnv = dotenv.maybeGet('GOOGLE_WEB_CLIENT_ID')?.trim();
    return fromEnv == null || fromEnv.isEmpty ? '' : fromEnv;
  }
}
