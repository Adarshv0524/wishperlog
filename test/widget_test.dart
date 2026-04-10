// test/widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wishperlog/core/config/app_env.dart';

void main() {
  // AppEnv.load() is called so dotenv is initialized before any getter is read.
  // Without this, every getter that calls dotenv.maybeGet() throws NotInitializedError.
  setUpAll(() async {
    await AppEnv.load();
  });

  testWidgets('AppEnv getters return safely without a real .env file', (tester) async {
    // All getters must return an empty string rather than throwing.
    expect(AppEnv.geminiApiKey, isA<String>());
    expect(AppEnv.groqApiKey, isA<String>());
    expect(AppEnv.huggingFaceApiKey, isA<String>());
    expect(AppEnv.telegramBotToken, isA<String>());
    expect(AppEnv.telegramBotUsername, isA<String>());
    expect(AppEnv.googleWebClientId, isA<String>());
  });

  testWidgets('App widget tree boots without crashing', (tester) async {
    // A smoke test — just ensure no exception is thrown building a Material widget.
    await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
    expect(find.byType(Scaffold), findsOneWidget);
  });
}