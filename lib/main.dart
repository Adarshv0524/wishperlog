import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishperlog/app/router.dart';
import 'package:wishperlog/core/background/connectivity_sync_coordinator.dart';
import 'package:wishperlog/core/background/work_manager_service.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/core/theme/app_theme.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/ai/data/ai_processing_service.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/features/overlay/overlay_bubble.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/sync/data/fcm_sync_service.dart';
import 'package:wishperlog/features/sync/data/firestore_note_sync_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[Main] === APP STARTUP ===');

  // Register FCM background handler before anything else.
  try {
    ensureFcmBackgroundHandlerRegistered();
    debugPrint('[Main] FCM background handler registered');
  } catch (e, st) {
    debugPrint('[Main] FCM handler error: $e');
    debugPrintStack(stackTrace: st);
  }

  // Load environment variables.
  try {
    debugPrint('[Main] Loading .env...');
    await AppEnv.load();
    debugPrint('[Main] .env loaded');
  } catch (e, st) {
    debugPrint('[Main] .env error: $e');
    debugPrintStack(stackTrace: st);
  }

  // Initialize Firebase.
  try {
    debugPrint('[Main] Initializing Firebase...');
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    debugPrint('[Main] Firebase initialized');
  } catch (e, st) {
    debugPrint('[Main] Firebase error: $e');
    debugPrintStack(stackTrace: st);
    rethrow;
  }

  // Set up dependency injection.
  try {
    debugPrint('[Main] Setting up dependency injection...');
    await init();
    debugPrint('[Main] DI container initialized');
  } catch (e, st) {
    debugPrint('[Main] DI setup error: $e');
    debugPrintStack(stackTrace: st);
    rethrow;
  }

  try {
    debugPrint('[Main] Hydrating overlay notifier...');
    await sl<OverlayNotifier>().hydrate();
    debugPrint('[Main] Overlay notifier hydrated');
  } catch (e, st) {
    debugPrint('[Main] Overlay hydration error: $e');
    debugPrintStack(stackTrace: st);
  }

  // Initialize Isar.
  try {
    await IsarNoteStore.instance.init();
  } catch (e, st) {
    debugPrint('[Main] Isar init error (non-fatal): $e');
    debugPrintStack(stackTrace: st);
  }

  // Hydrate theme.
  try {
    debugPrint('[Main] Hydrating theme...');
    await sl<ThemeCubit>().hydrate();
    debugPrint('[Main] Theme hydrated');
  } catch (e, st) {
    debugPrint('[Main] Theme hydrate error: $e');
    debugPrintStack(stackTrace: st);
  }

  // Initialize WorkManager (register callback only — tasks registered below).
  try {
    debugPrint('[Main] Initializing WorkManager...');
    await WorkManagerService.initialize();
    debugPrint('[Main] WorkManager initialized');
  } catch (e, st) {
    debugPrint('[Main] WorkManager error: $e');
    debugPrintStack(stackTrace: st);
  }

  debugPrint('[Main] === STARTUP COMPLETE, RUNNING APP ===');

  runApp(
    // OverlayNotifier exposed at the top so MaterialApp.builder can access it.
    ChangeNotifierProvider<OverlayNotifier>.value(
      value: sl<OverlayNotifier>(),
      child: BlocProvider<ThemeCubit>.value(
        value: sl<ThemeCubit>(),
        child: const MyApp(),
      ),
    ),
  );

  // Post-launch background tasks (non-blocking).
  unawaited(_postLaunchTasks());
}

Future<void> _postLaunchTasks() async {
  try {
    debugPrint('[Main] Registering WorkManager periodic syncs...');
    await WorkManagerService.registerPeriodicGoogleTasksSync();
    await WorkManagerService.registerTelegramDailyDigest();
    debugPrint('[Main] WorkManager & periodic syncs initialized');
  } catch (e) {
    debugPrint('[Main] WorkManager periodic registration error: $e');
  }

  try {
    debugPrint('[Main] Starting AI service...');
    sl<AiProcessingService>().start();
    debugPrint('[Main] AI service started');
  } catch (e) {
    debugPrint('[Main] AI service error: $e');
  }

  try {
    debugPrint('[Main] Starting connectivity coordinator...');
    await sl<ConnectivitySyncCoordinator>().start();
    debugPrint('[Main] Connectivity coordinator started');
  } catch (e) {
    debugPrint('[Main] Connectivity coordinator error: $e');
  }

  try {
    debugPrint('[Main] Starting Firestore background sync listener...');
    await sl<FirestoreNoteSyncService>().start();
    debugPrint('[Main] Firestore background sync listener started');
  } catch (e) {
    debugPrint('[Main] Firestore background sync listener error: $e');
  }

  try {
    debugPrint('[Main] Initializing FCM sync service...');
    await sl<FcmSyncService>().initialize();
    debugPrint('[Main] FCM sync service initialized');
  } catch (e) {
    debugPrint('[Main] FCM sync error: $e');
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return BlocProvider<CaptureUiController>.value(
          value: sl<CaptureUiController>(),
          child: MaterialApp.router(
            title: 'WhisperLog',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: router,
            // builder runs INSIDE MaterialApp (which provides an Overlay).
            builder: (context, child) {
              // Enforce system UI overlays.
              SystemChrome.setSystemUIOverlayStyle(
                themeMode == ThemeMode.dark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
              );
              return OverlayRootWrapper(
                child: child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}
