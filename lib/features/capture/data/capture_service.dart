import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wishperlog/core/storage/isar_service.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class CaptureService {
  CaptureService({
    GeminiNoteClassifier? classifier,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarService? isarService,
    ExternalSyncService? externalSync,
    bool enableExternalSync = true,
  }) : _classifier = classifier ?? GeminiNoteClassifier(),
       _auth = auth ?? _safeFirebaseAuth(),
       _firestore = firestore ?? _safeFirestore(),
       _isarService = isarService ?? IsarService.instance,
       _externalSync = enableExternalSync
           ? (externalSync ?? _safeExternalSync())
           : null;

  final GeminiNoteClassifier _classifier;
  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final IsarService _isarService;
  final ExternalSyncService? _externalSync;

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

  static ExternalSyncService? _safeExternalSync() {
    try {
      return ExternalSyncService();
    } catch (_) {
      return null;
    }
  }

  Future<Note?> ingestRawCapture({
    required String rawTranscript,
    required CaptureSource source,
  }) async {
    final trimmed = rawTranscript.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    final db = await _isarService.init();
    final now = DateTime.now();
    final user = _auth?.currentUser;
    final noteId = '${now.microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';

    try {
      final aiResult = await _classifier.classify(trimmed);

      var note = Note(
        noteId: noteId,
        uid: user?.uid ?? 'local_anonymous',
        rawTranscript: trimmed,
        title: aiResult.title,
        cleanBody: aiResult.cleanBody,
        category: aiResult.category,
        priority: aiResult.priority,
        extractedDate: aiResult.extractedDate,
        createdAt: now,
        updatedAt: now,
        status: NoteStatus.active,
        aiModel: aiResult.model,
        gcalEventId: null,
        gtaskId: null,
        source: source,
        syncedAt: now,
      );

      final externalSync = _externalSync;
      if (externalSync != null) {
        final externalResult = await externalSync.syncExternalForNote(note);
        note = externalResult.note;
      }

      await db.writeTxn(() async {
        await db.notes.put(note);
      });
      await _syncNoteToFirestore(note);
      return note;
    } catch (_) {
      final pending = Note(
        noteId: noteId,
        uid: user?.uid ?? 'local_anonymous',
        rawTranscript: trimmed,
        title: _fallbackTitle(trimmed),
        cleanBody: trimmed,
        category: NoteCategory.general,
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

      await db.writeTxn(() async {
        await db.notes.put(pending);
      });
      await _syncNoteToFirestore(pending);
      return pending;
    }
  }

  Future<void> _syncNoteToFirestore(Note note) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      return;
    }

    final user = auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.noteId)
          .set(note.toFirestoreJson(), SetOptions(merge: true));
    } catch (_) {
      // Firestore sync will be retried via existing sync flow.
    }
  }

  String _fallbackTitle(String text) {
    final oneLine = text.replaceAll('\n', ' ').trim();
    if (oneLine.length <= 60) {
      return oneLine;
    }
    return '${oneLine.substring(0, 60).trimRight()}...';
  }
}