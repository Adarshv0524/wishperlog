import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';

class AiProcessingService {
  AiProcessingService({
    AiClassifierRouter? router,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
    ExternalSyncService? externalSync,
    NoteEventBus? noteEventBus,
  }) : _router = router ?? sl<AiClassifierRouter>(),
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance,
       _externalSync = externalSync ?? sl<ExternalSyncService>(),
       _noteEventBus = noteEventBus ?? NoteEventBus.instance;

  final AiClassifierRouter _router;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore _isarNoteStore;
  final ExternalSyncService _externalSync;
  final NoteEventBus _noteEventBus;

  StreamSubscription<String>? _noteSavedSubscription;
  final Set<String> _inFlightNoteIds = <String>{};
  bool _sweepRunning = false;

  void start() {
    unawaited(_sweepPendingOnce());
    _noteSavedSubscription ??= _noteEventBus.onNoteSaved.listen((noteId) {
      unawaited(processNoteById(noteId));
    });
  }

  Future<void> flushPendingQueue() async {
    await _sweepPendingOnce();
  }

  void dispose() {
    _noteSavedSubscription?.cancel();
    _noteSavedSubscription = null;
  }

  Future<void> _sweepPendingOnce() async {
    if (_sweepRunning) {
      return;
    }
    _sweepRunning = true;

    try {
      final pending = await _isarNoteStore.getPendingAiNotes();

      for (final note in pending) {
        await processNoteById(note.noteId);
      }
    } catch (_) {
      // Avoid crashing the UI if SQLite is temporarily unavailable during startup.
    } finally {
      _sweepRunning = false;
    }
  }

  Future<void> processNoteById(String noteId) async {
    final trimmedId = noteId.trim();
    if (trimmedId.isEmpty || _inFlightNoteIds.contains(trimmedId)) {
      return;
    }

    _inFlightNoteIds.add(trimmedId);
    try {
      final note = await _isarNoteStore.getByNoteId(trimmedId);
      if (note == null || note.status != NoteStatus.pendingAi) {
        return;
      }

      final result = await _router.classify(note.rawTranscript);
      final now = DateTime.now();

      final activeNote = note.copyWith(
        title: result.title,
        category: result.category,
        priority: result.priority,
        extractedDate: result.extractedDate,
        clearExtractedDate: result.extractedDate == null,
        cleanBody: result.cleanBody,
        aiModel: result.model,
        status: NoteStatus.active,
        updatedAt: now,
        syncedAt: now,
      );

      final externalResult = await _externalSync.syncExternalForNote(
        activeNote,
      );
      final externallySyncedNote = externalResult.note;

      await _isarNoteStore.put(externallySyncedNote);

      await _syncToFirestore(externallySyncedNote);
    } catch (e, st) {
      // Log the exact error to diagnose AI failures.
      debugPrint('[AiProcessingService] Error processing $trimmedId: $e');
      debugPrintStack(stackTrace: st);
      // Keep note as pendingAi and let future events/sweeps retry.
    } finally {
      _inFlightNoteIds.remove(trimmedId);
    }
  }

  Future<bool> _syncToFirestore(Note note) async {
    var user = _auth.currentUser;
    // Wait for auth to hydrate in isolated contexts
    if (user == null) {
      try {
        user = await _auth
            .authStateChanges()
            .firstWhere((u) => u != null, orElse: () => null as User?)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }

    final uid = user?.uid ?? note.uid;
    if (uid.isEmpty || uid == 'local_anonymous') {
      debugPrint(
        '[AiProcessingService] Firebase sync skipped: user not authenticated ($uid)',
      );
      return false; // Return false so it is retried later!
    }

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(note.noteId)
          .set(note.toFirestoreJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('[AiProcessingService] Firestore sync error: $e');
      return false;
    }
  }
}
