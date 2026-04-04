import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:wishperlog/core/storage/isar_service.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class NoteRepository {
  NoteRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarService? isarService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _isarService = isarService ?? IsarService.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarService _isarService;

  Future<Isar> _db() => _isarService.init();

  Future<void> savePendingFromHome(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final user = _auth.currentUser;
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

    final db = await _db();
    if (!db.isOpen) {
      throw Exception('[NoteRepository] Isar database is closed');
    }
    
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await db.writeTxn(() async {
          await db.notes.put(note);
        });
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
    final db = await _db();
    yield await _activeCountsSnapshot(db);

    await for (final _ in db.notes.watchLazy()) {
      yield await _activeCountsSnapshot(db);
    }
  }

  Stream<List<Note>> watchActiveByCategory(NoteCategory category) async* {
    final db = await _db();
    yield await _activeByCategorySnapshot(db, category);

    await for (final _ in db.notes.watchLazy()) {
      yield await _activeByCategorySnapshot(db, category);
    }
  }

  Stream<List<Note>> watchAllActive() async* {
    final db = await _db();
    yield await _allActiveSorted(db);

    await for (final _ in db.notes.watchLazy()) {
      yield await _allActiveSorted(db);
    }
  }

  Stream<int> watchPendingAiCount() async* {
    final db = await _db();
    yield await _pendingAiCount(db);

    await for (final _ in db.notes.watchLazy()) {
      yield await _pendingAiCount(db);
    }
  }

  Future<void> archive(String noteId) async {
    final db = await _db();
    if (!db.isOpen) throw Exception('[NoteRepository] Isar closed');
    
    final note = await _findById(db, noteId);
    if (note == null) return;

    final updated = note.copyWith(
      status: NoteStatus.archived,
      updatedAt: DateTime.now(),
    );

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await db.writeTxn(() async {
          await db.notes.put(updated);
        });
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
    final db = await _db();
    if (!db.isOpen) throw Exception('[NoteRepository] Isar closed');
    
    final note = await _findById(db, noteId);
    if (note == null) return;

    final next = switch (note.priority) {
      NotePriority.high => NotePriority.medium,
      NotePriority.medium => NotePriority.low,
      NotePriority.low => NotePriority.high,
    };

    final updated = note.copyWith(priority: next, updatedAt: DateTime.now());

    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        await db.writeTxn(() async {
          await db.notes.put(updated);
        });
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
    final db = await _db();
    final note = await _findById(db, noteId);
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

    await db.writeTxn(() async {
      await db.notes.put(updated);
    });
    await _syncNoteToFirestore(updated);
  }

  Future<Note?> _findById(Isar db, String noteId) async {
    return db.notes
        .filter()
        .noteIdEqualTo(noteId)
        .findFirst();
  }

  Future<List<Note>> _allActiveSorted(Isar db) async {
    return _visibleNotesSnapshot(db);
  }

  Future<List<Note>> _visibleNotesSnapshot(Isar db) async {
    final notes = await db.notes.where().findAll();
    notes.removeWhere((note) => note.status == NoteStatus.archived);
    _sortNotes(notes);
    return notes;
  }

  Future<List<Note>> _activeByCategorySnapshot(
    Isar db,
    NoteCategory category,
  ) async {
    final notes = await _visibleNotesSnapshot(db);
    return notes.where((note) => note.category == category).toList();
  }

  Future<Map<NoteCategory, int>> _activeCountsSnapshot(Isar db) async {
    final notes = await _visibleNotesSnapshot(db);

    final counts = <NoteCategory, int>{
      for (final category in kAllNoteCategories) category: 0,
    };
    for (final note in notes) {
      counts[note.category] = (counts[note.category] ?? 0) + 1;
    }
    return counts;
  }

  Future<int> _pendingAiCount(Isar db) async {
    return db.notes.filter().statusEqualTo(NoteStatus.pendingAi).count();
  }

  Future<void> _syncNoteToFirestore(Note note) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('[NoteRepository] Firestore sync skipped: user not authenticated');
      return;
    }

    try {
      debugPrint('[NoteRepository] Syncing note to Firestore: ${note.noteId}');
      
      await _firestore
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

  void _sortNotes(List<Note> notes) {
    notes.sort((a, b) {
      final p = priorityWeight(a.priority).compareTo(priorityWeight(b.priority));
      if (p != 0) {
        return p;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
  }

  String _deriveTitle(String text) {
    final oneLine = text.replaceAll('\n', ' ').trim();
    if (oneLine.length <= 60) {
      return oneLine;
    }
    return '${oneLine.substring(0, 60).trimRight()}...';
  }
}
