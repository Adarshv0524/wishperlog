import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class CaptureService {
  CaptureService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
    NoteEventBus? noteEventBus,
    AiClassifierRouter? aiRouter,
  }) : _auth = auth ?? _safeFirebaseAuth(),
       _firestore = firestore ?? _safeFirestore(),
       _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance,
       _noteEventBus = noteEventBus ?? NoteEventBus.instance,
       _aiRouter =
           aiRouter ??
           (sl.isRegistered<AiClassifierRouter>()
               ? sl<AiClassifierRouter>()
               : AiClassifierRouter());

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final IsarNoteStore _isarNoteStore;
  final NoteEventBus _noteEventBus;
  final AiClassifierRouter _aiRouter;

  String get activeProviderName => _aiRouter.lastUsedModelName;

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

  Future<Note?> ingestRawCapture({
    required String rawTranscript,
    required CaptureSource source,
    bool syncToCloud = true,
  }) async {
    final trimmed = rawTranscript.trim();
    if (trimmed.isEmpty) return null;

    try {
      final now = DateTime.now();
      final user = _auth?.currentUser;
      final noteId = '${now.microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';

      // STEP 1: Instant local save with fallback title.
      final quickTitle = _quickTitle(trimmed);
      final initialNote = Note(
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

      await _isarNoteStore.put(initialNote);

      debugPrint('[CaptureService] Saved instantly: $noteId');

      // STEP 2: Emit saved event for immediate UI confirmation.
      _noteEventBus.emitNoteSaved(noteId);

      // STEP 3: Fire-and-forget cloud sync.
      if (syncToCloud) {
        unawaited(_syncNoteToFirestore(initialNote));
      }

      return initialNote;
    } catch (error, stackTrace) {
      debugPrint('[CaptureService] ERROR during ingestRawCapture: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Instant local title from first 60 chars - no network, no AI.
  String _quickTitle(String text) {
    final oneLine = text.replaceAll('\n', ' ').trim();
    if (oneLine.length <= 60) return oneLine;
    return '${oneLine.substring(0, 60).trimRight()}...';
  }

  Future<void> _syncNoteToFirestore(Note note) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      debugPrint(
        '[CaptureService] Firestore sync skipped: auth or firestore null',
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
        '[CaptureService] Firestore sync skipped: user not authenticated',
      );
      return;
    }

    try {
      debugPrint('[CaptureService] Syncing note to Firestore: ${note.noteId}');

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.noteId)
          .set(note.toFirestoreJson(), SetOptions(merge: true));

      debugPrint(
        '[CaptureService] Successfully synced to Firestore: ${note.noteId}',
      );
    } catch (e, st) {
      debugPrint(
        '[CaptureService] ERROR syncing to Firestore: ${note.noteId}: $e',
      );
      debugPrintStack(stackTrace: st);
      // Firestore sync will be retried via existing sync flow.
    }
  }
}
