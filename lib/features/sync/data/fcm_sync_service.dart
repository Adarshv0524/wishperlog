import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/features/sync/data/firestore_note_sync_service.dart';
import 'package:wishperlog/firebase_options.dart';

bool _fcmBackgroundHandlerRegistered = false;

void ensureFcmBackgroundHandlerRegistered() {
  if (_fcmBackgroundHandlerRegistered) {
    return;
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  _fcmBackgroundHandlerRegistered = true;
}

class FcmSyncService {
  FcmSyncService({
    FirebaseMessaging? messaging,
    UserRepository? users,
    FirestoreNoteSyncService? noteSync,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _users = users ?? UserRepository(),
       _noteSync = noteSync ?? FirestoreNoteSyncService();

  final FirebaseMessaging _messaging;
  final UserRepository _users;
  final FirestoreNoteSyncService _noteSync;

  bool _initialized = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _messageSub;
  StreamSubscription<RemoteMessage>? _messageOpenedSub;

  Future<void> initialize() async {
    ensureFcmBackgroundHandlerRegistered();

    if (_initialized) {
      return;
    }
    _initialized = true;

    try {
      debugPrint('[FcmSyncService] Getting FCM token...');
      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('[FcmSyncService] Token retrieval timed out');
          return null;
        },
      );
      if (token != null && token.isNotEmpty) {
        debugPrint('[FcmSyncService] Got token, updating user...');
        await _users.updateFcmToken(token).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('[FcmSyncService] Token update timed out');
            return;
          },
        );
      }
    } catch (e) {
      debugPrint('[FcmSyncService] Error getting token: $e');
    }

    _tokenRefreshSub ??= _messaging.onTokenRefresh.listen((token) async {
      await _users.updateFcmToken(token);
    });

    _messageSub ??= FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
    _messageOpenedSub ??= FirebaseMessaging.onMessageOpenedApp.listen(
      _handleRemoteMessage,
    );
  }

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<NotificationSettings> getNotificationSettings() {
    return _messaging.getNotificationSettings();
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _messageSub?.cancel();
    await _messageOpenedSub?.cancel();
    _tokenRefreshSub = null;
    _messageSub = null;
    _messageOpenedSub = null;
    _initialized = false;
  }

  Future<void> _handleRemoteMessage(RemoteMessage message) async {
    final type = message.data['type'];
    final noteId = message.data['note_id'];
    final status = message.data['status'];

    if (type == 'note_status_changed' &&
        noteId is String &&
        noteId.trim().isNotEmpty &&
        status is String) {
      await _noteSync.applyStatusFromPush(noteId: noteId, status: status);
      return;
    }

    if (type == 'note_updated' &&
        noteId is String &&
        noteId.trim().isNotEmpty) {
      await _noteSync.syncNoteById(noteId);
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final noteSync = FirestoreNoteSyncService();

    final type = message.data['type'];
    final noteId = message.data['note_id'];
    final status = message.data['status'];

    if (type == 'note_status_changed' &&
        noteId is String &&
        noteId.trim().isNotEmpty &&
        status is String) {
      await noteSync.applyStatusFromPush(noteId: noteId, status: status);
      return;
    }

    if (type == 'note_updated' &&
        noteId is String &&
        noteId.trim().isNotEmpty) {
      await noteSync.syncNoteById(noteId);
    }
  } catch (error) {
    debugPrint('FCM background handler error: $error');
  }
}
