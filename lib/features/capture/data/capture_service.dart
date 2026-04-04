import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/storage/sqlite_note_store.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class CaptureService {
  CaptureService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    SqliteNoteStore? noteStore,
    NoteEventBus? noteEventBus,
    bool enableExternalSync = true,
  }) : _auth = auth ?? _safeFirebaseAuth(),
       _firestore = firestore ?? _safeFirestore(),
       _noteStore = noteStore ?? SqliteNoteStore.instance,
       _noteEventBus = noteEventBus ?? NoteEventBus.instance;

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final SqliteNoteStore _noteStore;
  final NoteEventBus _noteEventBus;

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
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final now = DateTime.now();
      final user = _auth?.currentUser;
      final noteId = '${now.microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';

      final pending = Note(
        noteId: noteId,
        uid: user?.uid ?? 'local_anonymous',
        rawTranscript: trimmed,
        title: _fallbackTitle(trimmed),
        cleanBody: trimmed,
        category: _initialCategory(trimmed),
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


      debugPrint('[CaptureService] Saving note: $noteId (${trimmed.length} chars, source: $source)');
      
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          await _noteStore.upsert(pending);
          break;
        } catch (e) {
          if (attempt < 2) {
            debugPrint('[CaptureService] Transaction failed (attempt ${attempt + 1}/3), retrying: $e');
            await Future<void>.delayed(const Duration(milliseconds: 100));
          } else {
            debugPrint('[CaptureService] Transaction failed after 3 attempts');
            rethrow;
          }
        }
      }

      // Emit immediately after local commit to trigger event-driven AI processing.
      _noteEventBus.emitNoteSaved(pending.noteId);
      
      debugPrint('[CaptureService] Note saved successfully: $noteId');
      
      if (syncToCloud) {
        unawaited(_syncNoteToFirestore(pending));
      }
      return pending;
    } catch (error, stackTrace) {
      debugPrint('[CaptureService] ERROR during ingestRawCapture: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  NoteCategory _initialCategory(String text) {
    final lower = text.toLowerCase();
    if (RegExp(r'\b(todo|task|finish|complete|deadline|ship|submit)\b').hasMatch(lower)) {
      return NoteCategory.tasks;
    }
    if (RegExp(r'\b(remind|reminder|tomorrow|later|call|meeting|at\s+\d)\b').hasMatch(lower)) {
      return NoteCategory.reminders;
    }
    if (RegExp(r'\b(idea|brainstorm|concept|maybe build)\b').hasMatch(lower)) {
      return NoteCategory.ideas;
    }
    if (RegExp(r'\b(follow up|followup|ping|check back)\b').hasMatch(lower)) {
      return NoteCategory.followUp;
    }
    if (RegExp(r'\b(journal|today i|felt|mood|dear diary)\b').hasMatch(lower)) {
      return NoteCategory.journal;
    }
    return NoteCategory.general;
  }

  Future<void> _syncNoteToFirestore(Note note) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      debugPrint('[CaptureService] Firestore sync skipped: auth or firestore null');
      return;
    }

    final user = auth.currentUser;
    if (user == null) {
      debugPrint('[CaptureService] Firestore sync skipped: user not authenticated');
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
      
      debugPrint('[CaptureService] Successfully synced to Firestore: ${note.noteId}');
    } catch (e, st) {
      debugPrint('[CaptureService] ERROR syncing to Firestore: ${note.noteId}: $e');
      debugPrintStack(stackTrace: st);
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