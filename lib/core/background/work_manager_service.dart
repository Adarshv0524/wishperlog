import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/ai/data/ai_processing_service.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/firebase_options.dart';

// ─── Background task dispatcher (runs in a separate Dart isolate) ──────────

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('[WorkManager] Task: $taskName');

    try {
      await AppEnv.load();
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      await IsarNoteStore.instance.init();
    } catch (e) {
      debugPrint('[WorkManager] Bootstrap error: $e');
      return false;
    }

    switch (taskName) {
      // ── Flush pending AI notes ─────────────────────────────────────────────
      case WorkManagerService.flushPendingTaskName:
        try {
          final svc = AiProcessingService(noteEventBus: null);
          await svc.flushPendingQueue();
          return true;
        } catch (e) {
          debugPrint('[WorkManager] flushPendingAi error: $e');
          return false;
        }

      // ── Google Tasks / Calendar periodic sync ──────────────────────────────
      case WorkManagerService.periodicTaskName:
        try {
          final sync = ExternalSyncService();
          final ok   = await sync.ensureGoogleConnected();
          if (!ok) {
            debugPrint('[WorkManager] Google not signed in — skip');
            return true; // Don't retry immediately
          }
          final result = await sync.syncNow();
          debugPrint('[WorkManager] Sync done — '
              'processed=${result.processed} updated=${result.updated}');
          return true;
        } catch (e) {
          debugPrint('[WorkManager] periodicSync error: $e');
          return false;
        }

      default:
        debugPrint('[WorkManager] Unknown task: $taskName');
        return true;
    }
  });
}

// ─── Service facade ────────────────────────────────────────────────────────

class WorkManagerService {
  // Task identifiers — Telegram digest removed (handled by Cloudflare Worker)
  static const periodicTaskName   = 'wishperlog.periodic_google_tasks_sync';
  static const periodicTaskUnique = 'wishperlog.periodic_google_tasks_sync.unique';
  static const flushPendingTaskName   = 'wishperlog.flush_pending_ai';
  static const flushPendingTaskUnique = 'wishperlog.flush_pending_ai.unique';

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> registerPeriodicGoogleTasksSync() async {
    await Workmanager().registerPeriodicTask(
      periodicTaskUnique,
      periodicTaskName,
      frequency:            const Duration(hours: 4),
      constraints:          Constraints(
        networkType:         NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy:   ExistingPeriodicWorkPolicy.keep,
      backoffPolicy:        BackoffPolicy.exponential,
      backoffPolicyDelay:   const Duration(minutes: 30),
      initialDelay:         const Duration(minutes: 15),
    );
  }

  static Future<void> scheduleFlushPendingAi() async {
    await Workmanager().registerOneOffTask(
      flushPendingTaskUnique,
      flushPendingTaskName,
      constraints:        Constraints(networkType: NetworkType.connected),
      initialDelay:       const Duration(seconds: 5),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy:      BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}