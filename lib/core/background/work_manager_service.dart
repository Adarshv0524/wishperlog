import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/ai/data/ai_processing_service.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/features/sync/data/telegram_service.dart';
import 'package:wishperlog/shared/models/note.dart';
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
    static const telegramCommandTaskName = 'wishperlog.telegram_command_poll';
    static const telegramCommandTaskUnique =
      'wishperlog.telegram_command_poll.unique';

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
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
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
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
    final prefs = await SharedPreferences.getInstance();
    final digestSlots = _loadDigestTimes(prefs);
    final now = DateTime.now();
    final nextRun = _nextSlotRunAfter(
      now: now,
      slots: digestSlots,
      sentHmToday: const <String>{},
      allowToday: true,
    );

    await Workmanager().registerOneOffTask(
      telegramDigestTaskUnique,
      telegramDigestTaskName,
      initialDelay: _positiveDelay(now, nextRun),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 20),
    );
  }

  static Future<void> registerTelegramCommandPolling() async {
    await Workmanager().registerPeriodicTask(
      telegramCommandTaskUnique,
      telegramCommandTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 20),
      initialDelay: const Duration(minutes: 2),
    );
  }
}

const _lastTelegramDigestDateKey = 'digest.last_telegram_sent_date';
const _telegramCommandOffsetKey = 'telegram.command_offset';
const _digestTimesKey = 'prefs.digest_times';
const _digestHourKey = 'prefs.digest_hour';
const _digestMinuteKey = 'prefs.digest_minute';

String _localYmd(DateTime dt) {
  final m = dt.month.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  return '${dt.year}-$m-$d';
}

String _localHm(TimeOfDay t) {
  final h = t.hour.toString().padLeft(2, '0');
  final m = t.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _sentSlotsKeyForDay(String ymd) => 'digest.sent_slots.$ymd';

bool _isAfterDigestTime({
  required DateTime now,
  required TimeOfDay digestTime,
}) {
  final nowMinutes = now.hour * 60 + now.minute;
  final digestMinutes = digestTime.hour * 60 + digestTime.minute;
  return nowMinutes >= digestMinutes;
}

DateTime _atTimeOnDate(DateTime date, TimeOfDay time) {
  return DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

DateTime _nextSlotRunAfter({
  required DateTime now,
  required List<TimeOfDay> slots,
  required Set<String> sentHmToday,
  required bool allowToday,
}) {
  DateTime? best;

  if (allowToday) {
    for (final slot in slots) {
      final hm = _localHm(slot);
      if (sentHmToday.contains(hm)) continue;
      final candidate = _atTimeOnDate(now, slot);
      if (!candidate.isAfter(now)) continue;
      if (best == null || candidate.isBefore(best)) {
        best = candidate;
      }
    }
  }

  if (best != null) {
    return best;
  }

  final tomorrow = now.add(const Duration(days: 1));
  return _atTimeOnDate(tomorrow, slots.first);
}

Duration _positiveDelay(DateTime from, DateTime to) {
  final diff = to.difference(from);
  if (diff.isNegative) return Duration.zero;
  return diff;
}

Future<void> _scheduleRetryIn(Duration delay) async {
  await Workmanager().registerOneOffTask(
    WorkManagerService.telegramDigestTaskUnique,
    WorkManagerService.telegramDigestTaskName,
    initialDelay: delay,
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.replace,
    backoffPolicy: BackoffPolicy.exponential,
    backoffPolicyDelay: const Duration(minutes: 20),
  );
}

Future<void> _scheduleNextDigestAtConfiguredTime({
  required SharedPreferences prefs,
  required bool allowToday,
  Set<String> sentHmToday = const <String>{},
}) async {
  final digestSlots = _loadDigestTimes(prefs);
  final now = DateTime.now();
  final nextRun = _nextSlotRunAfter(
    now: now,
    slots: digestSlots,
    sentHmToday: sentHmToday,
    allowToday: allowToday,
  );
  await _scheduleRetryIn(_positiveDelay(now, nextRun));
}

List<TimeOfDay> _loadDigestTimes(SharedPreferences prefs) {
  final rawList = prefs.getStringList(_digestTimesKey) ?? const [];
  final minutes = <int>{};

  for (final raw in rawList) {
    final parsed = _parseHm(raw);
    if (parsed != null) {
      minutes.add(parsed.hour * 60 + parsed.minute);
    }
  }

  if (minutes.isEmpty) {
    final hour = prefs.getInt(_digestHourKey) ?? 9;
    final minute = prefs.getInt(_digestMinuteKey) ?? 0;
    minutes.add(hour * 60 + minute);
  }

  final sorted = minutes.toList()..sort();
  return sorted
      .map((m) => TimeOfDay(hour: m ~/ 60, minute: m % 60))
      .toList();
}

TimeOfDay? _parseHm(String value) {
  final parts = value.split(':');
  if (parts.length != 2) return null;
  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
    return null;
  }
  return TimeOfDay(hour: h, minute: m);
}

TimeOfDay? _pickDueUnsentSlot({
  required DateTime now,
  required List<TimeOfDay> slots,
  required Set<String> sentHm,
}) {
  TimeOfDay? chosen;

  for (final slot in slots) {
    final hm = _localHm(slot);
    if (sentHm.contains(hm)) continue;
    if (!_isAfterDigestTime(now: now, digestTime: slot)) continue;

    if (chosen == null) {
      chosen = slot;
      continue;
    }

    final c = chosen.hour * 60 + chosen.minute;
    final s = slot.hour * 60 + slot.minute;
    if (s > c) chosen = slot;
  }

  return chosen;
}

Future<bool> _runTelegramDailyDigest() async {
  final prefs = await SharedPreferences.getInstance();
  final digestSlots = _loadDigestTimes(prefs);
  final now = DateTime.now();
  final ymd = _localYmd(now);
  final sentSlotsKey = _sentSlotsKeyForDay(ymd);
  final sentHm = Set<String>.from(
    prefs.getStringList(sentSlotsKey) ?? const <String>[],
  );

  final dueSlot = _pickDueUnsentSlot(
    now: now,
    slots: digestSlots,
    sentHm: sentHm,
  );

  if (dueSlot == null) {
    await _scheduleNextDigestAtConfiguredTime(
      prefs: prefs,
      allowToday: true,
      sentHmToday: sentHm,
    );
    return true;
  }

  final dueSlotHm = _localHm(dueSlot);

  var chatId = (prefs.getString('telegram_chat_id') ?? '').trim();
  if (chatId.isEmpty) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      chatId = (userDoc.data()?['telegram_chat_id'] ?? '').toString().trim();
    }
  }

  final telegram = TelegramService();
  if (chatId.isEmpty || !telegram.isConfigured) {
    await _scheduleRetryIn(const Duration(minutes: 30));
    return true;
  }

  List<Note> allNotes;
  try {
    allNotes = await IsarNoteStore.instance.getAllActive();
  } catch (e) {
    debugPrint('[WorkManager] Telegram digest skipped: Isar read failed: $e');
    await _scheduleRetryIn(const Duration(minutes: 30));
    return true;
  }

  final todayYmd = _localYmd(now);
  final todayNotes = allNotes
      .where((n) => _localYmd(n.createdAt.toLocal()) == todayYmd)
      .toList();

  final sent = await telegram.sendDailyDigest(
    chatId: chatId,
    notes: todayNotes,
    localDate: now,
    maxItems: 3,
    topPriorityOnly: true,
    includeMediumFallback: true,
  );

  if (sent) {
    await prefs.setString(_lastTelegramDigestDateKey, ymd);
    sentHm.add(dueSlotHm);
    await prefs.setStringList(sentSlotsKey, sentHm.toList()..sort());
    await _scheduleNextDigestAtConfiguredTime(
      prefs: prefs,
      allowToday: true,
      sentHmToday: sentHm,
    );
  } else {
    await _scheduleRetryIn(const Duration(minutes: 30));
  }

  return sent;
}

Future<bool> _runTelegramCommandPoll() async {
  final prefs = await SharedPreferences.getInstance();
  final telegram = TelegramService();
  if (!telegram.isConfigured) return true;

  final commandMenuReady = prefs.getBool('telegram.commands_registered') ?? false;
  if (!commandMenuReady) {
    final ok = await telegram.registerDefaultCommands();
    if (ok) {
      await prefs.setBool('telegram.commands_registered', true);
    }
  }

  var chatId = (prefs.getString('telegram_chat_id') ?? '').trim();
  if (chatId.isEmpty) {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      chatId = (userDoc.data()?['telegram_chat_id'] ?? '').toString().trim();
      if (chatId.isNotEmpty) {
        await prefs.setString('telegram_chat_id', chatId);
      }
    }
  }

  if (chatId.isEmpty) return true;

  final currentOffset = prefs.getInt(_telegramCommandOffsetKey) ?? 0;
  final batch = await telegram.fetchCommandUpdates(offset: currentOffset);
  if (batch.nextOffset != currentOffset) {
    await prefs.setInt(_telegramCommandOffsetKey, batch.nextOffset);
  }

  if (batch.events.isEmpty) return true;

  List<Note> allNotes;
  try {
    allNotes = await IsarNoteStore.instance.getAllActive();
  } catch (_) {
    allNotes = const [];
  }

  final now = DateTime.now();
  final todayYmd = _localYmd(now);
  final todayNotes = allNotes
      .where((n) => _localYmd(n.createdAt.toLocal()) == todayYmd)
      .toList();

  for (final event in batch.events) {
    if (event.chatId != chatId) continue;

    switch (event.command) {
      case 'start':
        await telegram.sendConnectionConfirmation(chatId: chatId);
        break;
      case 'help':
        await telegram.sendMessage(
          chatId: chatId,
          text: telegram.buildHelpMessage(),
          replyToMessageId: event.messageId,
        );
        break;
      case 'status':
        final slots = _loadDigestTimes(prefs).map(_localHm).join(', ');
        await telegram.sendMessage(
          chatId: chatId,
          text: [
            '<b>WishperLog Status</b>',
            'Linked chat: <code>$chatId</code>',
            'Today notes: ${todayNotes.length}',
            'Digest slots: $slots',
          ].join('\n'),
          replyMarkup: telegram.buildPrimaryActionKeyboard(),
          disableWebPagePreview: true,
          replyToMessageId: event.messageId,
        );
        break;
      case 'digest':
        await telegram.sendPriorityBrief(
          chatId: chatId,
          notes: todayNotes,
          localDate: now,
        );
        break;
      case 'top':
        final top3 = telegram.selectDigestHighlights(
          notes: todayNotes,
          maxItems: 3,
          topPriorityOnly: true,
          includeMediumFallback: true,
        );
        await telegram.sendDailyDigest(
          chatId: chatId,
          notes: top3,
          localDate: now,
          maxItems: 3,
          topPriorityOnly: false,
          includeMediumFallback: true,
        );
        break;
      case 'today':
        await telegram.sendTodaySummaryCard(
          chatId: chatId,
          notes: todayNotes,
          localDate: now,
        );
        break;
      case 'slots':
        await telegram.sendScheduleSlots(
          chatId: chatId,
          slots: _loadDigestTimes(prefs).map(_localHm).toList(),
        );
        break;
      case 'stats':
        await telegram.sendStatsCard(
          chatId: chatId,
          notes: todayNotes,
          localDate: now,
        );
        break;
      case 'find':
        await telegram.sendFindResults(
          chatId: chatId,
          query: event.commandArgs,
          notes: allNotes,
        );
        break;
      case 'agenda':
        await telegram.sendAgenda(
          chatId: chatId,
          notes: allNotes,
          localNow: now,
        );
        break;
      case 'menu':
        await telegram.sendCommandMenuCard(chatId: chatId);
        break;
      case 'focus':
        final top1 = telegram.selectDigestHighlights(
          notes: todayNotes,
          maxItems: 1,
          topPriorityOnly: true,
          includeMediumFallback: true,
        );
        if (top1.isNotEmpty) {
          await telegram.sendFocusReminder(chatId: chatId, note: top1.first);
        } else {
          await telegram.sendQuickNudge(
            chatId: chatId,
            headline: 'No focus blocker found',
            detail: 'You are clear for now. Capture new notes and ask /digest later.',
            typingBeforeSend: true,
          );
        }
        break;
      case 'nudge':
        await telegram.sendNudgePack(chatId: chatId, notes: todayNotes);
        break;
      case 'ping':
        await telegram.sendDigestTestPing(chatId: chatId, localNow: now);
        break;
      default:
        break;
    }
  }

  return true;
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    try {
      await AppEnv.load();
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      try {
        await IsarNoteStore.instance.init();
      } catch (e) {
        debugPrint('[WorkManager] Isar init failed for task $task: $e');
        return Future<bool>.value(true);
      }

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

      if (task == WorkManagerService.telegramCommandTaskName) {
        final ok = await _runTelegramCommandPoll();
        return Future<bool>.value(ok);
      }

      return Future<bool>.value(true);
    } catch (_) {
      return Future<bool>.value(false);
    }
  });
}
