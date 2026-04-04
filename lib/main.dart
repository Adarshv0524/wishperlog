import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishperlog/app/router.dart';
import 'package:wishperlog/core/background/work_manager_service.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/background/connectivity_sync_coordinator.dart';
import 'package:wishperlog/core/theme/app_theme.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/ai/data/ai_processing_service.dart';
import 'package:wishperlog/features/overlay_v1/overlay_coordinator.dart';
import 'package:wishperlog/features/overlay_v1/presentation/overlay_entrypoint.dart';
import 'package:wishperlog/features/sync/data/fcm_sync_service.dart';
import 'firebase_options.dart';

final _overlayEntrypointReference = overlayMain;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[Main] === APP STARTUP ===');
  
  try {
    ensureFcmBackgroundHandlerRegistered();
    debugPrint('[Main] FCM background handler registered');
  } catch (e, st) {
    debugPrint('[Main] FCM handler error: $e');
    debugPrintStack(stackTrace: st);
  }

  try {
    debugPrint('[Main] Loading .env...');
    await AppEnv.load();
    debugPrint('[Main] .env loaded');
  } catch (e, st) {
    debugPrint('[Main] .env error: $e');
    debugPrintStack(stackTrace: st);
  }

  try {
    debugPrint('[Main] Initializing Firebase...');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    debugPrint('[Main] Firebase initialized');
  } catch (e, st) {
    debugPrint('[Main] Firebase error: $e');
    debugPrintStack(stackTrace: st);
    rethrow;
  }

  try {
    debugPrint('[Main] Initializing WorkManager...');
    await WorkManagerService.initialize();
    debugPrint('[Main] WorkManager initialized');
  } catch (e, st) {
    debugPrint('[Main] WorkManager error: $e');
    debugPrintStack(stackTrace: st);
  }

  try {
    debugPrint('[Main] Registering periodic sync...');
    await WorkManagerService.registerPeriodicGoogleTasksSync();
    debugPrint('[Main] Periodic sync registered');
  } catch (e, st) {
    debugPrint('[Main] Periodic sync error: $e');
    debugPrintStack(stackTrace: st);
  }

  try {
    debugPrint('[Main] Registering Telegram digest worker...');
    await WorkManagerService.registerTelegramDailyDigest();
    debugPrint('[Main] Telegram digest worker registered');
  } catch (e, st) {
    debugPrint('[Main] Telegram digest worker error: $e');
    debugPrintStack(stackTrace: st);
  }

  try {
    debugPrint('[Main] Setting up dependency injection...');
    await init();
    debugPrint('[Main] DI container initialized');
  } catch (e, st) {
    debugPrint('[Main] DI setup error: $e');
    debugPrintStack(stackTrace: st);
    rethrow;
  }

  _overlayEntrypointReference;

  try {
    debugPrint('[Main] Hydrating theme...');
    await sl<ThemeCubit>().hydrate();
    debugPrint('[Main] Theme hydrated');
  } catch (e, st) {
    debugPrint('[Main] Theme hydration error: $e');
    debugPrintStack(stackTrace: st);
  }

  try {
    debugPrint('[Main] Hydrating and restoring overlay...');
    await sl<OverlayCoordinator>().hydrateAndRestore();
    debugPrint('[Main] Overlay hydrated and restored');
  } catch (e, st) {
    debugPrint('[Main] Overlay hydration error: $e');
    debugPrintStack(stackTrace: st);
  }

  try {
    debugPrint('[Main] Starting AI service...');
    sl<AiProcessingService>().start();
    debugPrint('[Main] AI service started');
  } catch (e, st) {
    debugPrint('[Main] AI service error: $e');
    debugPrintStack(stackTrace: st);
  }

  try {
    debugPrint('[Main] Starting connectivity coordinator...');
    await sl<ConnectivitySyncCoordinator>().start();
    debugPrint('[Main] Connectivity coordinator started');
  } catch (e, st) {
    debugPrint('[Main] Connectivity coordinator error: $e');
    debugPrintStack(stackTrace: st);
  }

  try {
    debugPrint('[Main] Initializing FCM sync service...');
    await sl<FcmSyncService>().initialize();
    debugPrint('[Main] FCM sync service initialized');
  } catch (e, st) {
    debugPrint('[Main] FCM sync service error: $e');
    debugPrintStack(stackTrace: st);
  }

  debugPrint('[Main] === STARTUP COMPLETE, RUNNING APP ===');
  runApp(const MyApp());
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
            builder: (context, child) {
              // Show splash/loading screen briefly during initialization
              return child ?? const SizedBox.expand(
                child: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
