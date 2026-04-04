import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/storage/sqlite_note_store.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class NoteRepository {
  NoteRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    SqliteNoteStore? noteStore,
  })  : _auth = auth ?? safeFirebaseAuth(),
        _firestore = firestore ?? safeFirestore(),
        _noteStore = noteStore ?? SqliteNoteStore.instance;

  static FirebaseAuth? safeFirebaseAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseFirestore? safeFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final SqliteNoteStore _noteStore;

  Future<void> savePendingFromHome(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final user = _auth?.currentUser;
    final note = Note(
      noteId: '${now.microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}',
      uid: user?.uid ?? 'local_anonymous',
      rawTranscript: text,
      title: _deriveTitle(text),
      cleanBody: text,
      category: NoteCategory.general,
      priority: NotePriority.medium,
      extractedDate: null,
      createdAt: now,
      updatedAt: now,
      status: NoteStatus.pendingAi,
      aiModel: '',
      gcalEventId: null,
      gtaskId: null,
      source: CaptureSource.homeWritingBox,
      syncedAt: null,
    );

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _noteStore.upsert(note);
        break;
      } catch (e) {
        if (attempt < 2) {
          debugPrint('[NoteRepository] Txn failed (${attempt + 1}/3): $e');
          await Future<void>.delayed(const Duration(milliseconds: 100));
        } else {
          rethrow;
        }
      }
    }
    await _syncNoteToFirestore(note);
  }

  Stream<Map<NoteCategory, int>> watchActiveCounts() async* {
    yield await _activeCountsSnapshot();

    await for (final _ in _noteStore.changes) {
      try {
        yield await _activeCountsSnapshot();
      } catch (e) {
        debugPrint('[NoteRepository] Error in watchActiveCounts snapshot: $e');
        yield <NoteCategory, int>{
          for (final category in kAllNoteCategories) category: 0,
        };
      }
    }
  }

  Stream<List<Note>> watchActiveByCategory(NoteCategory category) async* {
    yield await _activeByCategorySnapshot(category);

    await for (final _ in _noteStore.changes) {
      try {
        yield await _activeByCategorySnapshot(category);
      } catch (e) {
        debugPrint('[NoteRepository] Error in watchActiveByCategory snapshot: $e');
        yield [];
      }
    }
  }

  Stream<List<Note>> watchAllActive() async* {
    yield await _allActiveSorted();

    await for (final _ in _noteStore.changes) {
      try {
        yield await _allActiveSorted();
      } catch (e) {
        debugPrint('[NoteRepository] Error in watchAllActive snapshot: $e');
        yield [];
      }
    }
  }

  Stream<int> watchPendingAiCount() async* {
    yield await _pendingAiCount();

    await for (final _ in _noteStore.changes) {
      try {
        yield await _pendingAiCount();
      } catch (e) {
        debugPrint('[NoteRepository] Error in watchPendingAiCount snapshot: $e');
        yield 0;
      }
    }
  }

  Stream<Note?> watchNoteById(String noteId) async* {
    yield await _findById(noteId);

    await for (final _ in _noteStore.changes) {
      try {
        yield await _findById(noteId);
      } catch (e) {
        debugPrint('[NoteRepository] Error in watchNoteById($noteId): $e');
        yield null;
      }
    }
  }

  Future<void> archive(String noteId) async {
    final note = await _findById(noteId);
    if (note == null) return;

    final updated = note.copyWith(
      status: NoteStatus.archived,
      updatedAt: DateTime.now(),
    );

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _noteStore.upsert(updated);
        break;
      } catch (e) {
        if (attempt < 2) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        } else {
          rethrow;
        }
      }
    }
    await _syncNoteToFirestore(updated);
  }

  Future<void> cyclePriority(String noteId) async {
    final note = await _findById(noteId);
    if (note == null) return;

    final next = switch (note.priority) {
      NotePriority.high => NotePriority.medium,
      NotePriority.medium => NotePriority.low,
      NotePriority.low => NotePriority.high,
    };

    final updated = note.copyWith(priority: next, updatedAt: DateTime.now());

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await _noteStore.upsert(updated);
        break;
      } catch (e) {
        if (attempt < 2) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
        } else {
          rethrow;
        }
      }
    }
    await _syncNoteToFirestore(updated);
  }

  Future<void> updateEditedNote({
    required String noteId,
    required String title,
    required String cleanBody,
    required NoteCategory category,
    required NotePriority priority,
    required DateTime? extractedDate,
  }) async {
    final note = await _findById(noteId);
    if (note == null) {
      return;
    }

    final updated = note.copyWith(
      title: title.trim().isEmpty ? note.title : title.trim(),
      cleanBody: cleanBody.trim().isEmpty ? note.cleanBody : cleanBody.trim(),
      category: category,
      priority: priority,
      extractedDate: extractedDate,
      clearExtractedDate: extractedDate == null,
      updatedAt: DateTime.now(),
    );

    await _noteStore.upsert(updated);
    await _syncNoteToFirestore(updated);
  }

  Future<Note?> _findById(String noteId) async {
    return _noteStore.getByNoteId(noteId);
  }

  Future<List<Note>> _allActiveSorted() async {
    return _visibleNotesSnapshot();
  }

  Future<List<Note>> _visibleNotesSnapshot() async {
    return _noteStore.getActiveNotes();
  }

  Future<List<Note>> _activeByCategorySnapshot(NoteCategory category) async {
    final notes = await _visibleNotesSnapshot();
    return notes.where((note) => note.category == category).toList();
  }

  Future<Map<NoteCategory, int>> _activeCountsSnapshot() async {
    final notes = await _visibleNotesSnapshot();

    final counts = <NoteCategory, int>{
      for (final category in kAllNoteCategories) category: 0,
    };
    for (final note in notes) {
      counts[note.category] = (counts[note.category] ?? 0) + 1;
    }
    return counts;
  }

  Future<int> _pendingAiCount() async {
    return _noteStore.countPendingAi();
  }

  Future<void> _syncNoteToFirestore(Note note) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      debugPrint('[NoteRepository] Firestore sync skipped: auth or firestore unavailable');
      return;
    }

    final user = auth.currentUser;
    if (user == null) {
      debugPrint('[NoteRepository] Firestore sync skipped: user not authenticated');
      return;
    }

    try {
      debugPrint('[NoteRepository] Syncing note to Firestore: ${note.noteId}');
      
        await firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.noteId)
          .set(note.toFirestoreJson(), SetOptions(merge: true));
      
      debugPrint('[NoteRepository] Successfully synced to Firestore: ${note.noteId}');
    } catch (e, st) {
      debugPrint('[NoteRepository] ERROR syncing to Firestore: ${note.noteId}: $e');
      debugPrintStack(stackTrace: st);
      // Firestore sync retries are handled in later phases.
    }
  }

  String _deriveTitle(String text) {
    final oneLine = text.replaceAll('\n', ' ').trim();
    if (oneLine.length <= 60) {
      return oneLine;
    }
    return '${oneLine.substring(0, 60).trimRight()}...';
  }
}
