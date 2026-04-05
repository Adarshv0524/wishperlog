import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
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
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance,
       _noteEventBus = noteEventBus ?? NoteEventBus.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore _isarNoteStore;
  final NoteEventBus _noteEventBus;

  /// Saves a note locally and attempts cloud sync.
  /// Returns the saved Note when local persistence succeeds.
  Future<Note> saveNote({
    required String rawTranscript,
    required CaptureSource source,
    bool syncToCloud = true,
  }) async {
    final trimmed = rawTranscript.trim();
    if (trimmed.isEmpty) throw Exception('[NoteSaveService] Empty transcript');

    debugPrint('[NoteSaveService] Starting save: $source');

    final now = DateTime.now();
    final user = _auth.currentUser;
    final noteId = '${now.microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';

    // Instant local save - no AI await
    final oneLine = trimmed.replaceAll('\n', ' ').trim();
    final quickTitle = oneLine.length <= 60 ? oneLine : '${oneLine.substring(0, 60).trimRight()}...';

    final note = Note(
      noteId: noteId,
      uid: user?.uid ?? 'local_anonymous',
      rawTranscript: trimmed,
      title: quickTitle,
      cleanBody: trimmed,
      category: NoteCategory.general,
      priority: NotePriority.medium,
      extractedDate: null,
      createdAt: now,
      updatedAt: now,
      status: NoteStatus.pendingAi,
      aiModel: 'pending',
      gcalEventId: null,
      gtaskId: null,
      source: source,
      syncedAt: null,
    );

    await _saveToLocalStore(note);

    _noteEventBus.emitNoteSaved(note.noteId);

    if (syncToCloud) unawaited(_saveToFirebase(note));

    return note;
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
