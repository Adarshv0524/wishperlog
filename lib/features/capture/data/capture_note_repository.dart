import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wishperlog/core/storage/isar_service.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class CaptureNoteRepository {
  CaptureNoteRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarService? isarService,
  }) : _auth = auth ?? _safeFirebaseAuth(),
       _firestore = firestore ?? _safeFirestore(),
       _isarService = isarService ?? IsarService.instance;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final IsarService _isarService;

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

  Future<void> saveRawCapture({
    required String rawTranscript,
    required CaptureSource source,
  }) async {
    final trimmed = rawTranscript.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final user = _auth?.currentUser;
    final db = await _isarService.init();

    final note = Note(
      noteId: '${now.microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}',
      uid: user?.uid ?? 'local_anonymous',
      rawTranscript: trimmed,
      title: _deriveTitle(trimmed),
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
      await db.notes.put(note);
    });
    await _syncNoteToFirestore(note);
  }

  String _deriveTitle(String text) {
    final oneLine = text.replaceAll('\n', ' ').trim();
    if (oneLine.length <= 60) {
      return oneLine;
    }
    return '${oneLine.substring(0, 60).trimRight()}...';
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
      // Silent failure; normal sync pass will retry later.
    }
  }
}
