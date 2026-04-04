import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/features/sync/data/firestore_note_sync_service.dart';
import 'package:wishperlog/firebase_options.dart';

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

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _messageSub;

  Future<void> initialize() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    final token = await _messaging.getToken();
    if (token != null && token.isNotEmpty) {
      await _users.updateFcmToken(token);
    }

    _tokenRefreshSub ??= _messaging.onTokenRefresh.listen((token) async {
      await _users.updateFcmToken(token);
    });

    _messageSub ??= FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleRemoteMessage);
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
    _tokenRefreshSub = null;
    _messageSub = null;
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
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
