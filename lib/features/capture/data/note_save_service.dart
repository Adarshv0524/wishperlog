import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

/// Primary note save service: local save is required; cloud sync is best-effort.
class NoteSaveService {
  NoteSaveService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
    NoteEventBus? noteEventBus,
    AiClassifierRouter? aiRouter,
    ExternalSyncService? externalSync,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance,
       _noteEventBus = noteEventBus ?? NoteEventBus.instance,
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

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore _isarNoteStore;
  final NoteEventBus _noteEventBus;
  final AiClassifierRouter _aiRouter;
  final ExternalSyncService _externalSync;

  /// Saves a note locally and attempts cloud sync.
  /// Returns the saved Note when local persistence succeeds.
  Future<Note> saveNote({
    required String rawTranscript,
    required CaptureSource source,
    bool syncToCloud = true,
  }) async {
    final trimmed = rawTranscript.trim();
    if (trimmed.isEmpty) {
      throw Exception('[NoteSaveService] Empty transcript');
    }

    debugPrint('[NoteSaveService] Starting save: $source');

    final classification = await _aiRouter.classify(trimmed);

    // Step 1: Create note from AI output. If AI falls back, keep the note
    // pending so the existing retry pipeline can handle it server-side.
    final note = _createNote(
      transcript: trimmed,
      source: source,
      classification: classification,
    );

    // Step 2: Save to local SQLite storage - no debug print here to reduce spam
    await _saveToLocalStore(note);

    var finalNote = note;

    if (note.status == NoteStatus.active) {
      final externalResult = await _externalSync.syncExternalForNote(note);
      if (externalResult.noteChanged) {
        finalNote = externalResult.note;
        await _saveToLocalStore(finalNote);
      }
    }

    // Fire-and-forget emit to trigger event-driven AI processing.
    _noteEventBus.emitNoteSaved(finalNote.noteId);

    // Step 3: Save to Firebase (cloud) if requested - best effort only
    if (syncToCloud) {
      await _saveToFirebase(finalNote);
    }

    return finalNote;
  }

  /// Creates a Note object from raw transcript
  Note _createNote({
    required String transcript,
    required CaptureSource source,
    required GeminiClassificationResult classification,
  }) {
    final now = DateTime.now();
    final user = _auth.currentUser;
    final status = classification.wasFallback
        ? NoteStatus.pendingAi
        : NoteStatus.active;
    final noteId = '${now.microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';

    return Note(
      noteId: noteId,
      uid: user?.uid ?? 'local_anonymous',
      rawTranscript: transcript,
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
  }

  /// Saves note to local SQLite database
  Future<void> _saveToLocalStore(Note note) async {
    await _isarNoteStore.put(note);
  }

  /// Saves note to Firebase Firestore
  Future<void> _saveToFirebase(Note note) async {
    var user = _auth.currentUser;
    if (user == null) {
      try {
        user = await _auth
            .authStateChanges()
            .firstWhere((u) => u != null, orElse: () => null as User?)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }

    if (user == null) {
      debugPrint(
        '[NoteSaveService] Firebase save skipped: user not authenticated',
      );
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.noteId)
          .set(note.toFirestoreJson(), SetOptions(merge: true));
    } catch (e) {
      // Do not fail user save if local write already succeeded.
      debugPrint(
        '[NoteSaveService] Firebase sync deferred for ${note.noteId}: $e',
      );
    }
  }
}
