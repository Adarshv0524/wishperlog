import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:isar/isar.dart';
import 'package:wishperlog/core/storage/isar_service.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class AiProcessingService {
  AiProcessingService({
    GeminiNoteClassifier? classifier,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarService? isarService,
    ExternalSyncService? externalSync,
  }) : _classifier = classifier ?? GeminiNoteClassifier(),
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _isarService = isarService ?? IsarService.instance,
       _externalSync = externalSync ?? ExternalSyncService();

  final GeminiNoteClassifier _classifier;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarService _isarService;
  final ExternalSyncService _externalSync;

  Timer? _timer;
  bool _running = false;

  void start() {
    _timer ??= Timer.periodic(const Duration(seconds: 8), (_) {
      _processPending();
    });
    _processPending();
  }

  Future<void> flushPendingQueue() async {
    await _processPending();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _processPending() async {
    if (_running) {
      return;
    }
    _running = true;

    try {
      final db = await _isarService.init();
      final pending = await db.notes
          .filter()
          .statusEqualTo(NoteStatus.pendingAi)
          .findAll();

      pending.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      for (final note in pending) {
        await _processOne(db, note);
      }
    } finally {
      _running = false;
    }
  }

  Future<void> _processOne(Isar db, Note note) async {
    try {
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

      await db.writeTxn(() async {
        await db.notes.put(externallySyncedNote);
      });

      await _syncToFirestore(externallySyncedNote);
    } catch (_) {
      // Keep note pending_ai. Background retries continue on next ticks.
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
