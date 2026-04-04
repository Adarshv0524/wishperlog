import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/storage/sqlite_note_store.dart';
import 'package:wishperlog/features/ai/data/ai_processing_service.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/firebase_options.dart';

class WorkManagerService {
  static const periodicTaskName = 'wishperlog.periodic_google_tasks_sync';
  static const periodicTaskUnique =
      'wishperlog.periodic_google_tasks_sync.unique';
  static const flushPendingTaskName = 'wishperlog.flush_pending_ai';
  static const flushPendingTaskUnique = 'wishperlog.flush_pending_ai.unique';
    static const telegramDigestTaskName = 'wishperlog.telegram_daily_digest';
    static const telegramDigestTaskUnique =
      'wishperlog.telegram_daily_digest.unique';

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

  static Future<void> registerTelegramDailyDigest() async {
    await Workmanager().registerPeriodicTask(
      telegramDigestTaskUnique,
      telegramDigestTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.update,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 20),
      initialDelay: const Duration(minutes: 5),
    );
  }
}

const _lastTelegramDigestDateKey = 'digest.last_telegram_sent_date';

String _localYmd(DateTime dt) {
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '${dt.year}-$m-$d';
}

int _priorityWeight(String priority) {
  switch (priority.toLowerCase()) {
    case 'high':
      return 0;
    case 'medium':
      return 1;
    default:
      return 2;
  }
}

bool _isWithinDigestWindow({
  required DateTime now,
  required TimeOfDay digestTime,
  int windowMinutes = 12,
}) {
  final nowMinutes = now.hour * 60 + now.minute;
  final digestMinutes = digestTime.hour * 60 + digestTime.minute;
  return (nowMinutes - digestMinutes).abs() <= windowMinutes;
}

Future<bool> _sendTelegramMessage({
  required String token,
  required String chatId,
  required String text,
}) async {
  final endpoint = Uri.parse('https://api.telegram.org/bot$token/sendMessage');
  final payload = {
    'chat_id': chatId,
    'text': text,
    'parse_mode': 'Markdown',
    'disable_web_page_preview': true,
  };

  for (var attempt = 0; attempt < 3; attempt++) {
    try {
      final response = await http
          .post(
            endpoint,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
    } catch (_) {
      // Retried below.
    }

    if (attempt < 2) {
      await Future<void>.delayed(Duration(seconds: 2 << attempt));
    }
  }

  return false;
}

Future<bool> _runTelegramDailyDigest() async {
  final prefs = await SharedPreferences.getInstance();
  final digestHour = prefs.getInt('prefs.digest_hour') ?? 9;
  final digestMinute = prefs.getInt('prefs.digest_minute') ?? 0;
  final now = DateTime.now();

  if (
      !_isWithinDigestWindow(
        now: now,
        digestTime: TimeOfDay(hour: digestHour, minute: digestMinute),
      )) {
    return true;
  }

  final ymd = _localYmd(now);
  final lastSentYmd = prefs.getString(_lastTelegramDigestDateKey);
  if (lastSentYmd == ymd) {
    return true;
  }

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return true;
  }

  final userDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();
  final chatId = (userDoc.data()?['telegram_chat_id'] ?? '').toString().trim();
  final token = AppEnv.telegramBotToken;
  if (chatId.isEmpty || token.isEmpty) {
    return true;
  }

  final notes = await SqliteNoteStore.instance.getAllNotes();
  final activeNotes = notes
      .where((n) => n.status == NoteStatus.active)
      .toList()
    ..sort((a, b) {
      final weightCompare =
          _priorityWeight(a.priority.name).compareTo(_priorityWeight(b.priority.name));
      if (weightCompare != 0) {
        return weightCompare;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });

  final top = activeNotes.take(8).toList();
  final lines = <String>['*WhisperLog Daily Digest*', ''];
  if (top.isEmpty) {
    lines.add('No active notes for today.');
  } else {
    for (var i = 0; i < top.length; i++) {
      final note = top[i];
      final icon = note.priority == NotePriority.high
          ? '🔴'
          : note.priority == NotePriority.medium
              ? '🟡'
              : '⚪';
      final title = note.title.trim().isEmpty ? 'Untitled note' : note.title.trim();
      lines.add('${i + 1}. $icon ${title.length > 80 ? '${title.substring(0, 80)}...' : title}');
    }
  }

  final sent = await _sendTelegramMessage(
    token: token,
    chatId: chatId,
    text: lines.join('\n'),
  );

  if (sent) {
    await prefs.setString(_lastTelegramDigestDateKey, ymd);
  }

  return sent;
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    try {
      await AppEnv.load();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await SqliteNoteStore.instance.init();

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

      if (task == WorkManagerService.telegramDigestTaskName) {
        final ok = await _runTelegramDailyDigest();
        return Future<bool>.value(ok);
      }

      return Future<bool>.value(true);
    } catch (_) {
      return Future<bool>.value(false);
    }
  });
}
