import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/storage/isar_service.dart';
import 'package:wishperlog/features/ai/data/ai_processing_service.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/firebase_options.dart';

class WorkManagerService {
  static const periodicTaskName = 'wishperlog.periodic_google_tasks_sync';
  static const periodicTaskUnique =
      'wishperlog.periodic_google_tasks_sync.unique';
  static const flushPendingTaskName = 'wishperlog.flush_pending_ai';
  static const flushPendingTaskUnique = 'wishperlog.flush_pending_ai.unique';

  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
  }

  static Future<void> registerPeriodicGoogleTasksSync() async {
    await Workmanager().registerPeriodicTask(
      periodicTaskUnique,
      periodicTaskName,
      frequency: const Duration(hours: 4),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 30),
      initialDelay: const Duration(minutes: 20),
    );
  }

  static Future<void> scheduleFlushPendingAi() async {
    await Workmanager().registerOneOffTask(
      flushPendingTaskUnique,
      flushPendingTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: const Duration(seconds: 3),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    try {
      await AppEnv.load();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await IsarService.instance.init();

      if (task == WorkManagerService.periodicTaskName) {
        final external = ExternalSyncService();
        await external.syncGoogleTaskCompletions();
        return Future<bool>.value(true);
      }

      if (task == WorkManagerService.flushPendingTaskName) {
        final ai = AiProcessingService(externalSync: ExternalSyncService());
        await ai.flushPendingQueue();
        return Future<bool>.value(true);
      }

      return Future<bool>.value(true);
    } catch (_) {
      return Future<bool>.value(false);
    }
  });
}
