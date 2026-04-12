import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class FirestoreNoteSyncService {
  FirestoreNoteSyncService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore _isarNoteStore;

  bool _started = false;
  bool _isRestarting = false;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _noteSub;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;

    _authSub = _auth.idTokenChanges().listen(
      (user) {
        _attachUserListener(user);
      },
      onError: (Object error, StackTrace st) {
        debugPrint('[FirestoreNoteSyncService] Auth stream error: $error');
        debugPrintStack(stackTrace: st);
      },
    );

    await _attachUserListener(_auth.currentUser);
  }

  Future<void> stop() async {
    _started = false;
    await _noteSub?.cancel();
    await _authSub?.cancel();
    _noteSub = null;
    _authSub = null;
  }

  Future<void> _attachUserListener(User? user) async {
    await _noteSub?.cancel();
    _noteSub = null;

    final uid = user?.uid.trim() ?? '';
    if (uid.isEmpty) {
      debugPrint(
        '[FirestoreNoteSyncService] No authenticated user, listener idle',
      );
      return;
    }

    _noteSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .snapshots()
        .listen(
          (snapshot) async {
            try {
              final notes = snapshot.docs
                  .map(
                    (doc) => Note.fromFirestoreJson(
                      doc.data(),
                      uid: uid,
                      noteId: doc.id,
                    ),
                  )
                  .toList();
              await _isarNoteStore.putAll(notes);
            } catch (e, st) {
              debugPrint(
                '[FirestoreNoteSyncService] Snapshot process error: $e',
              );
              debugPrintStack(stackTrace: st);
            }
          },
          onError: (Object error, StackTrace st) async {
            debugPrint(
              '[FirestoreNoteSyncService] Snapshot listener error: $error',
            );
            debugPrintStack(stackTrace: st);
            final message = error.toString().toLowerCase();
            if (message.contains('permission-denied') ||
                message.contains('permission denied')) {
              await _noteSub?.cancel();
              _noteSub = null;
              return;
            }
            await _restartAfterDelay();
          },
        );
  }

  Future<void> _restartAfterDelay() async {
    if (_isRestarting || !_started) {
      return;
    }
    _isRestarting = true;
    try {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (_started) {
        await _attachUserListener(_auth.currentUser);
      }
    } finally {
      _isRestarting = false;
    }
  }

  Future<void> syncNoteById(String noteId, {String? uid}) async {
    final resolvedUid = uid ?? _auth.currentUser?.uid;
    if (resolvedUid == null || noteId.trim().isEmpty) {
      debugPrint(
        '[FirestoreNoteSyncService] Skipping syncNoteById: uid=$resolvedUid, noteId=$noteId',
      );
      return;
    }

    try {
      debugPrint(
        '[FirestoreNoteSyncService] Starting sync for note: $noteId (uid: $resolvedUid)',
      );

      final snap = await _firestore
          .collection('users')
          .doc(resolvedUid)
          .collection('notes')
          .doc(noteId)
          .get();

      if (!snap.exists) {
        debugPrint(
          '[FirestoreNoteSyncService] Note not found in Firestore: $noteId',
        );
        return;
      }

      final data = snap.data();
      if (data == null) {
        debugPrint('[FirestoreNoteSyncService] Note data is null: $noteId');
        return;
      }

      debugPrint(
        '[FirestoreNoteSyncService] Downloaded note from Firestore: $noteId',
      );

      final parsed = Note.fromFirestoreJson(
        data,
        uid: resolvedUid,
        noteId: noteId,
      );
      await _isarNoteStore.put(parsed);

      debugPrint(
        '[FirestoreNoteSyncService] Saved note to local Isar store: $noteId',
      );
    } catch (e, st) {
      debugPrint('[FirestoreNoteSyncService] ERROR syncing note $noteId: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> applyStatusFromPush({
    required String noteId,
    required String status,
  }) async {
    if (noteId.trim().isEmpty) {
      debugPrint(
        '[FirestoreNoteSyncService] Skipping applyStatusFromPush: empty noteId',
      );
      return;
    }

    try {
      debugPrint(
        '[FirestoreNoteSyncService] Applying status "$status" to note: $noteId',
      );

      final nextStatus = parseStatus(status);
      final existing = await _isarNoteStore.getByNoteId(noteId);
      if (existing == null) {
        debugPrint(
          '[FirestoreNoteSyncService] Note not found in local Isar store: $noteId',
        );
        return;
      }

      final updated = existing.copyWith(
        status: nextStatus,
        updatedAt: DateTime.now(),
        syncedAt: DateTime.now(),
      );

      await _isarNoteStore.put(updated);

      debugPrint(
        '[FirestoreNoteSyncService] Applied status change: $noteId → $nextStatus',
      );
    } catch (e, st) {
      debugPrint(
        '[FirestoreNoteSyncService] ERROR applying status to $noteId: $e',
      );
      debugPrintStack(stackTrace: st);
    }
  }
}
