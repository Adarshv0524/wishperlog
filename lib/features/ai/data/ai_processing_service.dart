import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wishperlog/core/storage/sqlite_note_store.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class AiProcessingService {
  AiProcessingService({
    GeminiNoteClassifier? classifier,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
     SqliteNoteStore? noteStore,
    ExternalSyncService? externalSync,
     NoteEventBus? noteEventBus,
  }) : _classifier = classifier ?? GeminiNoteClassifier(),
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _noteStore = noteStore ?? SqliteNoteStore.instance,
       _externalSync = externalSync ?? ExternalSyncService(),
       _noteEventBus = noteEventBus ?? NoteEventBus.instance;

  final GeminiNoteClassifier _classifier;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final SqliteNoteStore _noteStore;
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
      final pending = await _noteStore.getPendingAiNotes();

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
      final note = await _noteStore.getByNoteId(trimmedId);
      if (note == null || note.status != NoteStatus.pendingAi) {
        return;
      }

      final result = await _classifier.classify(note.rawTranscript);
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

      await _noteStore.upsert(externallySyncedNote);

      await _syncToFirestore(externallySyncedNote);
    } catch (_) {
      // Keep note as pendingAi and let future events/sweeps retry.
    } finally {
      _inFlightNoteIds.remove(trimmedId);
    }
  }

  Future<bool> _syncToFirestore(Note note) async {
    final user = _auth.currentUser;
    if (user == null) {
      return true;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.noteId)
          .set(note.toFirestoreJson(), SetOptions(merge: true));
      return true;
    } catch (_) {
      return false;
    }
  }
}
