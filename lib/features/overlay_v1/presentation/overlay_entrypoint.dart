import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';
import 'package:wishperlog/core/theme/app_theme.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/shared/widgets/molecules/dynamic_notch_pill.dart';

@pragma('vm:entry-point')
Future<void> overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = AppPreferencesRepository();
  final mode = await prefs.getThemeMode();

  runApp(OverlayNotchApp(themeMode: mode));
}

class OverlayNotchApp extends StatelessWidget {
  const OverlayNotchApp({required this.themeMode, super.key});

  final ThemeMode themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: BlocProvider<CaptureUiController>(
        create: (_) => CaptureUiController(
          captureService: CaptureService(enableExternalSync: false),
          speechToText: SpeechToText(),
        ),
        child: const _OverlayNotchHome(),
      ),
    );
  }
}

class _OverlayNotchHome extends StatelessWidget {
  const _OverlayNotchHome();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
      body: SafeArea(
        child: Align(
          alignment: Alignment.center,
          child: GestureDetector(
            onLongPressStart: (_) => context.read<CaptureUiController>().startRecording(),
            onLongPressEnd: (_) => context.read<CaptureUiController>().stopRecording(),
            child: const DynamicNotchPill(),
          ),
        ),
      ),
    );
  }
}

