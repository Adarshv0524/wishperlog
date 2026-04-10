import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId   = 'wishperlog_digest';
  static const _channelName = 'Daily Digest';
  static const _notifId     = 1001;

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin  = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: darwin);

    await _plugin.initialize(settings);
  }

  /// Only called when the user has actually configured a digest schedule.
  /// ISSUE-14: the permission prompt now only fires from here so it is
  /// contextually motivated, not on cold boot.
  static Future<void> requestPermissionIfSupported() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: false);
      }
    } catch (e) {
      debugPrint('[LocalNotifications] Permission request error: $e');
    }
  }

  /// Schedules (or replaces) the daily digest reminder at [hour]:[minute] UTC.
  /// ISSUE-14: this is the missing scheduling path that makes the feature real.
  static Future<void> scheduleDigestReminder({
    required int hour,
    required int minute,
    String title  = 'WishperLog Daily Brief',
    String body   = 'Your morning note digest is ready.',
  }) async {
    try {
      await _plugin.cancel(_notifId);

      final now  = tz.TZDateTime.now(tz.UTC);
      var sched  = tz.TZDateTime.utc(now.year, now.month, now.day, hour, minute);
      if (sched.isBefore(now)) {
        sched = sched.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Daily WishperLog digest reminder',
        importance: Importance.defaultImportance,
        priority:   Priority.defaultPriority,
        silent:     true,
      );
      const details = NotificationDetails(android: androidDetails);

      await _plugin.zonedSchedule(
        _notifId,
        title,
        body,
        sched,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('[LocalNotifications] Digest scheduled at $hour:$minute UTC');
    } catch (e) {
      debugPrint('[LocalNotifications] scheduleDigestReminder error: $e');
    }
  }

  /// One-shot reminder at a specific date/time (e.g. from an extracted note date).
  static Future<void> showDigestReminder({
    required String title,
    String body = 'Check your WishperLog note.',
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'WishperLog note reminder',
        importance: Importance.high,
        priority:   Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);
      await _plugin.show(_notifId + 1, title, body, details);
    } catch (e) {
      debugPrint('[LocalNotifications] showDigestReminder error: $e');
    }
  }
}