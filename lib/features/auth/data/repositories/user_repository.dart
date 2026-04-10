import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wishperlog/core/config/app_env.dart';

class SignInFriendlyException implements Exception {
  const SignInFriendlyException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UserRepository {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? (AppEnv.googleWebClientId.isEmpty ? null : AppEnv.googleWebClientId)
        : null,
  );

  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<auth.UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(provider);
        final user = userCredential.user;
        if (user == null) {
          throw Exception('Google sign in aborted');
        }

        await _upsertUserDocument(firebaseUser: user, googleAuth: null);

        return userCredential;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth.UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);

      await _upsertUserDocument(
        firebaseUser: userCredential.user!,
        googleAuth: googleAuth,
      );

      return userCredential;
    } on PlatformException catch (e) {
      final joined = '${e.code} ${e.message ?? ''}'.toLowerCase();
      if (joined.contains('10')) {
        throw const SignInFriendlyException(
          'Developer Error: SHA-1 mismatch. Please add your debug keystore SHA-1 to the Firebase Console and re-download google-services.json.',
        );
      }
      rethrow;
    }
  }

  Future<void> _upsertUserDocument({
    required auth.User firebaseUser,
    required GoogleSignInAuthentication? googleAuth,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final overlayX = prefs.getDouble('overlay.pos.x') ?? 0.0;
    final overlayY = prefs.getDouble('overlay.pos.y') ?? 0.0;

    final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await userDoc.get();
    final existingData = docSnapshot.data() ?? const <String, dynamic>{};
    final digestTime = (existingData['digest_time'] as String?) ?? '09:00';
    final digestTimes = (existingData['digest_times'] as List<dynamic>?)
        ?.map((value) => value.toString())
        .where((value) => value.trim().isNotEmpty)
        .toList();
    final data = {
      'uid': firebaseUser.uid,
      'email': firebaseUser.email ?? '',
      'display_name': firebaseUser.displayName ?? '',
      'google_tokens': {
        'access_token': googleAuth?.accessToken,
        'refresh_token': null,
        'expiry': null,
      },
      'telegram_chat_id': existingData['telegram_chat_id'] as String?,
      'digest_time': digestTime,
      'digest_times': digestTimes ?? [digestTime],
      'digest_times_utc':
          (existingData['digest_times_utc'] as List<dynamic>?)
              ?.map((value) => value.toString())
              .where((value) => value.trim().isNotEmpty)
              .toList() ??
          const <String>[],
      'timezone_offset_minutes':
          (existingData['timezone_offset_minutes'] as num?)?.toInt() ??
          DateTime.now().timeZoneOffset.inMinutes,
      'overlay_position': {'x': overlayX, 'y': overlayY},
      'overlay_visible': (existingData['overlay_visible'] as bool?) ?? true,
      'fcm_token': (existingData['fcm_token'] as String?) ?? '',
    };

    if (!docSnapshot.exists) {
      await userDoc.set({
        ...data,
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await userDoc.set(data, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  Stream<Map<String, dynamic>?> watchCurrentUserDocument() {
    return _firebaseAuth.authStateChanges().asyncExpand((user) {
      if (user == null) {
        return Stream.value(null);
      }
      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.data());
    });
  }

  Future<void> updateDigestTime(String digestTime) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }
    await _firestore.collection('users').doc(user.uid).set({
      'digest_time': digestTime,
      'digest_times': [digestTime],
      'timezone_offset_minutes': DateTime.now().timeZoneOffset.inMinutes,
    }, SetOptions(merge: true));
  }

  Future<void> updateDigestTimes(
    List<TimeOfDay> times, {
    List<String> utcSlots = const [],
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    final localSlots = times.map((t) => _formatTimeOfDay(t)).toList();
    final normalizedUtcSlots = utcSlots.isNotEmpty
        ? utcSlots
        : times.map(_toUtcSlot).toList();
    final data = <String, dynamic>{
      'digest_time': localSlots.first,
      'digest_times': localSlots,
      'digest_times_utc': normalizedUtcSlots,
      'timezone_offset_minutes': DateTime.now().timeZoneOffset.inMinutes,
      'updated_at': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set(data, SetOptions(merge: true));
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _toUtcSlot(TimeOfDay time) {
    final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    final totalMinutes = time.hour * 60 + time.minute;
    final shiftedMinutes = (totalMinutes - offsetMinutes) % (24 * 60);
    final normalized = shiftedMinutes < 0
        ? shiftedMinutes + (24 * 60)
        : shiftedMinutes;
    final hour = normalized ~/ 60;
    final minute = normalized % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  Future<void> updateOverlayVisibility(bool visible) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }
    await _firestore.collection('users').doc(user.uid).set({
      'overlay_visible': visible,
    }, SetOptions(merge: true));
  }

  Future<void> updateTelegramChatId(String chatId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }
    final normalized = chatId.trim();
    await _firestore.collection('users').doc(user.uid).set({
      'telegram_chat_id': normalized,
    }, SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();
    if (normalized.isEmpty) {
      await prefs.remove('telegram_chat_id');
    } else {
      await prefs.setString('telegram_chat_id', normalized);
    }
  }

  Future<void> writePendingTelegramToken({
    required String token,
    required DateTime expiresAt,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || token.trim().isEmpty) {
      return;
    }

    await _firestore.collection('users').doc(user.uid).set({
      'pending_telegram': {
        'token': token.trim(),
        'expires_at': Timestamp.fromDate(expiresAt.toUtc()),
      },
    }, SetOptions(merge: true));
  }

  Future<void> clearPendingTelegramToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }

    await _firestore.collection('users').doc(user.uid).set({
      'pending_telegram': FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  Future<void> updateFcmToken(String token) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || token.trim().isEmpty) {
      return;
    }
    await _firestore.collection('users').doc(user.uid).set({
      'fcm_token': token.trim(),
    }, SetOptions(merge: true));
  }

  Future<void> updateOverlayPosition({
    required double x,
    required double y,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }

    await _firestore.collection('users').doc(user.uid).set({
      'overlay_position': {'x': x, 'y': y},
    }, SetOptions(merge: true));
  }
}
