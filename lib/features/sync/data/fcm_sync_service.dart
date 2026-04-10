import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
       _users = users ?? UserRepository(
         googleSignIn: GoogleSignIn(
           scopes: const [
             'email',
             'https://www.googleapis.com/auth/calendar',
             'https://www.googleapis.com/auth/tasks',
           ],
         ),
       ),
       _noteSync = noteSync ?? FirestoreNoteSyncService();

  final FirebaseMessaging _messaging;
  final UserRepository _users;
  final FirestoreNoteSyncService _noteSync;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _initialized = false;
  bool _tokenBootstrapAttempted = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _messageSub;
  StreamSubscription<RemoteMessage>? _messageOpenedSub;
  StreamSubscription<User?>? _authSub;

  Future<void> initialize() async {
    ensureFcmBackgroundHandlerRegistered();

    if (_initialized) {
      return;
    }
    _initialized = true;

    // Set up listeners once. Token bootstrap is deferred until the user is
    // signed in so fresh installs do not hit Google Play Services unnecessarily.
    try {
      _authSub ??= _auth.authStateChanges().listen((user) {
        if (user != null) {
          unawaited(_bootstrapTokenAndPermissions());
        }
      });
    } catch (e) {
      debugPrint('[FcmSyncService] auth subscription error: $e');
    }

    _messageSub ??= FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
    _messageOpenedSub ??= FirebaseMessaging.onMessageOpenedApp.listen(
      _handleRemoteMessage,
    );

    try {
      await _bootstrapTokenAndPermissions();
    } catch (e) {
      debugPrint('[FcmSyncService] initialize error: $e');
    }
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
    await _authSub?.cancel();
    _tokenRefreshSub = null;
    _messageSub = null;
    _messageOpenedSub = null;
    _authSub = null;
    _initialized = false;
    _tokenBootstrapAttempted = false;
  }

  Future<void> _bootstrapTokenAndPermissions() async {
    if (_tokenBootstrapAttempted) {
      return;
    }
    if (_auth.currentUser == null) {
      debugPrint('[FcmSyncService] Skipping token bootstrap until sign-in');
      return;
    }

    _tokenBootstrapAttempted = true;

    try {
      final current = await _messaging.getNotificationSettings();

      if (current.authorizationStatus == AuthorizationStatus.notDetermined) {
        final requested = await requestPermission();
        debugPrint(
          '[FcmSyncService] Notification permission requested: ${requested.authorizationStatus.name}',
        );
      } else {
        debugPrint(
          '[FcmSyncService] Notification permission status: ${current.authorizationStatus.name}',
        );
      }
    } catch (e) {
      debugPrint('[FcmSyncService] Notification permission check error: $e');
    }

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
  }

  Future<void> _handleRemoteMessage(RemoteMessage message) async {
    debugPrint(
      '[FcmSyncService] Received message: id=${message.messageId}, dataKeys=${message.data.keys.toList()}',
    );

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
