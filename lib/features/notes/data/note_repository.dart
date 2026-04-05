import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class NoteRepository {
  NoteRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
    AiClassifierRouter? aiRouter,
    ExternalSyncService? externalSync,
  }) : _auth = auth ?? safeFirebaseAuth(),
       _firestore = firestore ?? safeFirestore(),
       _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance,
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
  final IsarNoteStore _isarNoteStore;
  final AiClassifierRouter _aiRouter;
  final ExternalSyncService _externalSync;

  Future<void> savePendingFromHome(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final user = _auth?.currentUser;
    final classification = await _aiRouter.classify(text);
    final status = classification.wasFallback
        ? NoteStatus.pendingAi
        : NoteStatus.active;

    final note = Note(
      noteId: '${now.microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}',
      uid: user?.uid ?? 'local_anonymous',
      rawTranscript: text,
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
      source: CaptureSource.homeWritingBox,
      syncedAt: status == NoteStatus.active ? now : null,
    );

    await _isarNoteStore.put(note);

    if (note.status == NoteStatus.active) {
      final externalResult = await _externalSync.syncExternalForNote(note);
      if (externalResult.noteChanged) {
        await _isarNoteStore.put(externalResult.note);
        await _syncNoteToFirestore(externalResult.note);
        return;
      }
    }

    await _syncNoteToFirestore(note);
  }

  Stream<List<Note>> watchActiveByCategory(NoteCategory category) async* {
    yield* watchAllActive().map((notes) {
      return notes.where((note) => note.category == category).toList();
    });
  }

  Stream<List<Note>> watchAllActive() async* {
    yield* watchAllActiveLocal();
  }

  Stream<List<Note>> watchAllActiveLocal() {
    return _isarNoteStore.watchActive();
  }

  Stream<List<Note>> watchActiveByCategoryLocal(NoteCategory category) {
    return watchAllActiveLocal().map((notes) {
      return notes.where((note) => note.category == category).toList();
    });
  }

  Stream<Map<NoteCategory, int>> watchActiveCountsLocal() {
    return watchAllActiveLocal().map((notes) {
      final counts = <NoteCategory, int>{
        for (final category in kAllNoteCategories) category: 0,
      };
      for (final note in notes) {
        counts[note.category] = (counts[note.category] ?? 0) + 1;
      }
      return counts;
    });
  }

  Stream<int> watchPendingAiCount() async* {
    yield await _pendingAiCount();
    yield* _isarNoteStore.watchAll().asyncMap((_) => _pendingAiCount());
  }

  Stream<Note?> watchNoteById(String noteId) async* {
    yield await _findById(noteId);
    yield* _isarNoteStore.watchAll().asyncMap((_) => _findById(noteId));
  }

  Future<void> delete(String noteId) async {
    final note = await _findById(noteId);
    if (note == null) return;

    final updated = note.copyWith(
      status: NoteStatus.deleted,
      updatedAt: DateTime.now(),
    );

    await _isarNoteStore.put(updated);
    await _syncNoteToFirestore(updated);
  }

  Future<void> archive(String noteId) async {
    final note = await _findById(noteId);
    if (note == null) return;

    final updated = note.copyWith(
      status: NoteStatus.archived,
      updatedAt: DateTime.now(),
    );

    await _isarNoteStore.put(updated);
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

    await _isarNoteStore.put(updated);
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

    await _isarNoteStore.put(updated);
    await _syncNoteToFirestore(updated);
  }

  Future<Note?> _findById(String noteId) async {
    return _isarNoteStore.getByNoteId(noteId);
  }

  Future<int> _pendingAiCount() async {
    return _isarNoteStore.countPendingAi();
  }

  Future<void> _syncNoteToFirestore(Note note) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      debugPrint(
        '[NoteRepository] Firestore sync skipped: auth or firestore unavailable',
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
        '[NoteRepository] Firestore sync skipped: user not authenticated',
      );
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

      debugPrint(
        '[NoteRepository] Successfully synced to Firestore: ${note.noteId}',
      );
    } catch (e, st) {
      debugPrint(
        '[NoteRepository] ERROR syncing to Firestore: ${note.noteId}: $e',
      );
      debugPrintStack(stackTrace: st);
      // Firestore sync retries are handled in later phases.
    }
  }
}
