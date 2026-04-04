import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/storage/sqlite_note_store.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

/// Primary note save service: local save is required; cloud sync is best-effort.
class NoteSaveService {
  NoteSaveService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    SqliteNoteStore? noteStore,
    NoteEventBus? noteEventBus,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _noteStore = noteStore ?? SqliteNoteStore.instance,
        _noteEventBus = noteEventBus ?? NoteEventBus.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final SqliteNoteStore _noteStore;
  final NoteEventBus _noteEventBus;

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

    // Step 1: Create note
    final note = _createNote(trimmed, source);

    // Step 2: Save to local SQLite storage - no debug print here to reduce spam
    await _saveToLocalStore(note);

    // Fire-and-forget emit to trigger event-driven AI processing.
    _noteEventBus.emitNoteSaved(note.noteId);

    // Step 3: Save to Firebase (cloud) if requested - best effort only
    if (syncToCloud) {
      await _saveToFirebase(note);
    }

    return note;
  }

  /// Creates a Note object from raw transcript
  Note _createNote(String transcript, CaptureSource source) {
    final now = DateTime.now();
    final user = _auth.currentUser;
    final noteId = '${now.microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';

    return Note(
      noteId: noteId,
      uid: user?.uid ?? 'local_anonymous',
      rawTranscript: transcript,
      title: _deriveTitle(transcript),
      cleanBody: transcript,
      category: _deriveCategory(transcript),
      priority: NotePriority.medium,
      extractedDate: null,
      createdAt: now,
      updatedAt: now,
      status: NoteStatus.pendingAi,
      aiModel: '',
      gcalEventId: null,
      gtaskId: null,
      source: source,
      syncedAt: null,
    );
  }

  /// Saves note to local SQLite database
  Future<void> _saveToLocalStore(Note note) async {
    final db = await _noteStore.init();
    if (!db.isOpen) {
      throw Exception('[NoteSaveService] SQLite database is closed');
    }

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _noteStore.upsert(note);
        return; // Success
      } catch (e) {
        if (attempt < 2) {
          debugPrint(
            '[NoteSaveService] SQLite save failed (attempt ${attempt + 1}/3): $e',
          );
          await Future<void>.delayed(const Duration(milliseconds: 100));
        } else {
          debugPrint('[NoteSaveService] SQLite save failed after 3 attempts: $e');
          rethrow;
        }
      }
    }
  }

  /// Saves note to Firebase Firestore
  Future<void> _saveToFirebase(Note note) async {
    final user = _auth.currentUser;
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
      debugPrint('[NoteSaveService] Firebase sync deferred for ${note.noteId}: $e');
    }
  }

  /// Derives title from transcript (first line, max 60 chars)
  String _deriveTitle(String text) {
    final oneLine = text.replaceAll('\n', ' ').trim();
    if (oneLine.length <= 60) {
      return oneLine;
    }
    return '${oneLine.substring(0, 60).trimRight()}...';
  }

  /// Derives category from transcript content
  NoteCategory _deriveCategory(String text) {
    final lower = text.toLowerCase();
    if (RegExp(r'\b(todo|task|finish|complete|deadline|ship|submit)\b')
        .hasMatch(lower)) {
      return NoteCategory.tasks;
    }
    if (RegExp(r'\b(remind|reminder|tomorrow|later|call|meeting|at\s+\d)\b')
        .hasMatch(lower)) {
      return NoteCategory.reminders;
    }
    if (RegExp(r'\b(idea|brainstorm|concept|maybe build)\b').hasMatch(lower)) {
      return NoteCategory.ideas;
    }
    if (RegExp(r'\b(follow up|followup|ping|check back)\b').hasMatch(lower)) {
      return NoteCategory.followUp;
    }
    if (RegExp(r'\b(journal|today i|felt|mood|dear diary)\b')
        .hasMatch(lower)) {
      return NoteCategory.journal;
    }
    return NoteCategory.general;
  }
}

