import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:wishperlog/app/router.dart';
import 'package:wishperlog/core/background/work_manager_service.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/background/connectivity_sync_coordinator.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';
import 'package:wishperlog/core/storage/isar_service.dart';
import 'package:wishperlog/core/theme/app_theme.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/ai/data/ai_processing_service.dart';
import 'package:wishperlog/features/capture/overlay/overlay_capture_app.dart';
import 'package:wishperlog/features/capture/overlay/overlay_window_controller.dart';
import 'package:wishperlog/features/sync/data/fcm_sync_service.dart';
import 'firebase_options.dart';

const MethodChannel _hardwareChannel = MethodChannel('wishperlog/hardware');
StreamSubscription<dynamic>? _overlayBridgeSub;
bool _overlaySurfaceReady = false;
bool _pendingHardwareStart = false;

@pragma('vm:entry-point')
void overlayMain() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IsarService.instance.init();
  runApp(const OverlayCaptureApp());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await WorkManagerService.initialize();
  await WorkManagerService.registerPeriodicGoogleTasksSync();
  await IsarService.instance.init();
  await init();
  await sl<ThemeCubit>().hydrate();
  sl<AiProcessingService>().start();
  await sl<ConnectivitySyncCoordinator>().start();
  await sl<FcmSyncService>().initialize();
  _setupOverlayBridgeListener();
  _setupHardwareBridge();
  runApp(const MyApp());
}

void _setupOverlayBridgeListener() {
  _overlayBridgeSub?.cancel();
  _overlayBridgeSub = FlutterOverlayWindow.overlayListener.listen((raw) async {
    if (raw is! Map) {
      return;
    }

    final type = raw['type'];
    if (type != 'overlay_surface_ready') {
      return;
    }

    _overlaySurfaceReady = true;
    if (!_pendingHardwareStart) {
      return;
    }

    _pendingHardwareStart = false;
    await FlutterOverlayWindow.shareData({
      'type': 'hardware_volume_down',
      'phase': 'start',
    });
  });
}

void _setupHardwareBridge() {
  _hardwareChannel.setMethodCallHandler((call) async {
    if (call.method != 'volumeDownLongPress') {
      return;
    }

    final args = (call.arguments as Map?) ?? const {};
    final phase = (args['phase'] as String?) ?? 'unknown';
    final volumeShortcutEnabled = await sl<AppPreferencesRepository>()
        .isVolumeShortcutEnabled();
    if (!volumeShortcutEnabled) {
      return;
    }

    debugPrint('Hardware volume-down long press: $phase');

    if (phase == 'start') {
      final granted = await OverlayWindowController.ensurePermission();
      if (granted && !await FlutterOverlayWindow.isActive()) {
        _overlaySurfaceReady = false;
        _pendingHardwareStart = true;
        await OverlayWindowController.showBubble();
        await OverlayWindowController.requestSurfaceProbe();
        return;
      }

      if (!_overlaySurfaceReady) {
        _pendingHardwareStart = true;
        await OverlayWindowController.requestSurfaceProbe();
        return;
      }
    }

    if (phase == 'end' && !_overlaySurfaceReady) {
      _pendingHardwareStart = false;
      return;
    }

    await FlutterOverlayWindow.shareData({
      'type': 'hardware_volume_down',
      'phase': phase,
    });
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, mode) {
          return MaterialApp.router(
            title: 'WhisperLog',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: mode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
