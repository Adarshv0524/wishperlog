import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';

class CaptureService {
  CaptureService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
    NoteEventBus? noteEventBus,
    bool enableExternalSync = true,
    AiClassifierRouter? aiRouter,
    ExternalSyncService? externalSync,
  }) : _auth = auth ?? _safeFirebaseAuth(),
       _firestore = firestore ?? _safeFirestore(),
       _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance,
       _noteEventBus = noteEventBus ?? NoteEventBus.instance,
       _enableExternalSync = enableExternalSync,
       _aiRouter =
           aiRouter ??
           (sl.isRegistered<AiClassifierRouter>()
               ? sl<AiClassifierRouter>()
               : AiClassifierRouter()),
       _externalSync =
           externalSync ??
           (sl.isRegistered<ExternalSyncService>()
               ? sl<ExternalSyncService>()
               : ExternalSyncService());

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final IsarNoteStore _isarNoteStore;
  final NoteEventBus _noteEventBus;
  final bool _enableExternalSync;
  final AiClassifierRouter _aiRouter;
  final ExternalSyncService _externalSync;

  static FirebaseAuth? _safeFirebaseAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseFirestore? _safeFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Future<Note?> ingestRawCapture({
    required String rawTranscript,
    required CaptureSource source,
    bool syncToCloud = true,
  }) async {
    final trimmed = rawTranscript.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final now = DateTime.now();
      final user = _auth?.currentUser;
      final noteId =
          '${now.microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';
      final classification = await _aiRouter.classify(trimmed);

      final status = classification.wasFallback
          ? NoteStatus.pendingAi
          : NoteStatus.active;

      final initialNote = Note(
        noteId: noteId,
        uid: user?.uid ?? 'local_anonymous',
        rawTranscript: trimmed,
        title: classification.title,
        cleanBody: classification.cleanBody,
        category: classification.category,
        priority: classification.priority,
        extractedDate: null,
        createdAt: now,
        updatedAt: now,
        status: status,
        aiModel: classification.model,
        gcalEventId: null,
        gtaskId: null,
        source: source,
        syncedAt: status == NoteStatus.active ? now : null,
      );

      debugPrint(
        '[CaptureService] Saving note: $noteId (${trimmed.length} chars, source: $source)',
      );

      await _isarNoteStore.put(initialNote);

      var finalNote = initialNote;

      if (_enableExternalSync && finalNote.status == NoteStatus.active) {
        final externalResult = await _externalSync.syncExternalForNote(
          finalNote,
        );
        if (externalResult.noteChanged) {
          finalNote = externalResult.note;
          await _isarNoteStore.put(finalNote);
        }
      }

      // Emit immediately after local commit to trigger event-driven AI processing.
      _noteEventBus.emitNoteSaved(finalNote.noteId);

      debugPrint('[CaptureService] Note saved successfully: $noteId');

      if (syncToCloud) {
        unawaited(_syncNoteToFirestore(finalNote));
      }
      return finalNote;
    } catch (error, stackTrace) {
      debugPrint('[CaptureService] ERROR during ingestRawCapture: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _syncNoteToFirestore(Note note) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      debugPrint(
        '[CaptureService] Firestore sync skipped: auth or firestore null',
      );
      return;
    }

    var user = auth.currentUser;
    if (user == null) {
      try {
        user = await auth
            .authStateChanges()
            .firstWhere((u) => u != null, orElse: () => null as User?)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }

    if (user == null) {
      debugPrint(
        '[CaptureService] Firestore sync skipped: user not authenticated',
      );
      return;
    }

    try {
      debugPrint('[CaptureService] Syncing note to Firestore: ${note.noteId}');

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.noteId)
          .set(note.toFirestoreJson(), SetOptions(merge: true));

      debugPrint(
        '[CaptureService] Successfully synced to Firestore: ${note.noteId}',
      );
    } catch (e, st) {
      debugPrint(
        '[CaptureService] ERROR syncing to Firestore: ${note.noteId}: $e',
      );
      debugPrintStack(stackTrace: st);
      // Firestore sync will be retried via existing sync flow.
    }
  }
}
