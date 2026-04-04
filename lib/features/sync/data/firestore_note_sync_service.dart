import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:wishperlog/core/storage/isar_service.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/enums.dart';

class FirestoreNoteSyncService {
  FirestoreNoteSyncService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarService? isarService,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _isarService = isarService ?? IsarService.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarService _isarService;

  Future<void> syncNoteById(String noteId, {String? uid}) async {
    final resolvedUid = uid ?? _auth.currentUser?.uid;
    if (resolvedUid == null || noteId.trim().isEmpty) {
      debugPrint('[FirestoreNoteSyncService] Skipping syncNoteById: uid=$resolvedUid, noteId=$noteId');
      return;
    }

    try {
      debugPrint('[FirestoreNoteSyncService] Starting sync for note: $noteId (uid: $resolvedUid)');
      
      final snap = await _firestore
          .collection('users')
          .doc(resolvedUid)
          .collection('notes')
          .doc(noteId)
          .get();

      if (!snap.exists) {
        debugPrint('[FirestoreNoteSyncService] Note not found in Firestore: $noteId');
        return;
      }

      final data = snap.data();
      if (data == null) {
        debugPrint('[FirestoreNoteSyncService] Note data is null: $noteId');
        return;
      }

      debugPrint('[FirestoreNoteSyncService] Downloaded note from Firestore: $noteId');
      
      final parsed = Note.fromFirestoreJson(data, uid: resolvedUid, noteId: noteId);
      final db = await _isarService.init();
      await db.writeTxn(() async {
        await db.notes.put(parsed);
      });
      
      debugPrint('[FirestoreNoteSyncService] Saved note to local database: $noteId');
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
      debugPrint('[FirestoreNoteSyncService] Skipping applyStatusFromPush: empty noteId');
      return;
    }

    try {
      debugPrint('[FirestoreNoteSyncService] Applying status "$status" to note: $noteId');
      
      final nextStatus = _parseStatus(status);
      final db = await _isarService.init();
      final existing = await db.notes.filter().noteIdEqualTo(noteId).findFirst();
      if (existing == null) {
        debugPrint('[FirestoreNoteSyncService] Note not found in local database: $noteId');
        return;
      }

      final updated = existing.copyWith(
        status: nextStatus,
        updatedAt: DateTime.now(),
        syncedAt: DateTime.now(),
      );

      await db.writeTxn(() async {
        await db.notes.put(updated);
      });
      
      debugPrint('[FirestoreNoteSyncService] Applied status change: $noteId → $nextStatus');
    } catch (e, st) {
      debugPrint('[FirestoreNoteSyncService] ERROR applying status to $noteId: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  NoteStatus _parseStatus(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'archived':
        return NoteStatus.archived;
      case 'pendingai':
      case 'pending_ai':
        return NoteStatus.pendingAi;
      case 'active':
      default:
        return NoteStatus.active;
    }
  }

}
