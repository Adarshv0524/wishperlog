import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/enums.dart';

class LocalNotificationService {
  LocalNotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static const String digestChannelId = 'wishperlog_digest';
  static const String digestChannelName = 'Daily Digest';
  static const String digestChannelDescription =
      'Device-side daily digest reminders';

  static Future<void> initialize() async {
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings);

    const channel = AndroidNotificationChannel(
      digestChannelId,
      digestChannelName,
      description: digestChannelDescription,
      importance: Importance.high,
    );

    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.createNotificationChannel(channel);
    _initialized = true;
  }

  static Future<void> requestPermissionIfSupported() async {
    final androidImpl =
        _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidImpl?.requestNotificationsPermission();
  }

  static Future<void> showDigestReminder({
    required DateTime localNow,
    required List<Note> notes,
  }) async {
    await initialize();

    final total = notes.length;
    final high = notes.where((n) => n.priority == NotePriority.high).length;
    final medium = notes.where((n) => n.priority == NotePriority.medium).length;

    final title = 'WishperLog Daily Brief';
    final body = total == 0
        ? 'No pending notes right now. You are clear.'
        : high > 0
            ? '$high high priority and $total total note(s) need attention.'
            : '$medium medium priority and $total total note(s) pending.';

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        digestChannelId,
        digestChannelName,
        channelDescription: digestChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        category: AndroidNotificationCategory.reminder,
      ),
    );

    final id = _stableDigestId(localNow);
    await _plugin.show(id, title, body, details);
    debugPrint('[LocalNotificationService] Digest notification shown: id=$id');
  }

  static int _stableDigestId(DateTime now) {
    return now.year * 10000 + now.month * 100 + now.day;
  }
}
