import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
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
    bool syncToCloud = true,
  }) async {
    final trimmed = rawTranscript.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final db = await _isarService.init();

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

      if (!db.isOpen) {
        throw Exception('[CaptureService] Isar database is closed or not initialized');
      }

      debugPrint('[CaptureService] Saving note: $noteId (${trimmed.length} chars, source: $source)');
      
      for (var attempt = 0; attempt < 3; attempt++) {
        try {
          await db.writeTxn(() async {
            await db.notes.put(pending);
          });
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
      
      debugPrint('[CaptureService] Note saved successfully: $noteId');
      
      if (syncToCloud) {
        unawaited(_syncNoteToFirestore(pending));
      }

      unawaited(_promotePendingNote(noteId: noteId, rawTranscript: trimmed));
      return pending;
    } catch (error, stackTrace) {
      debugPrint('[CaptureService] ERROR during ingestRawCapture: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> _promotePendingNote({
    required String noteId,
    required String rawTranscript,
  }) async {
    try {
      final db = await _isarService.init();
      final matches = await db.notes.filter().noteIdEqualTo(noteId).findAll();
      final existing = matches.isEmpty ? null : matches.first;
      if (existing == null || existing.status == NoteStatus.archived) {
        return;
      }

      final aiResult = await _classifier.classify(rawTranscript);
      var next = existing.copyWith(
        title: aiResult.title,
        cleanBody: aiResult.cleanBody,
        category: aiResult.category,
        priority: aiResult.priority,
        extractedDate: aiResult.extractedDate,
        clearExtractedDate: aiResult.extractedDate == null,
        status: NoteStatus.active,
        aiModel: aiResult.model,
        updatedAt: DateTime.now(),
        syncedAt: DateTime.now(),
      );

      final externalSync = _externalSync;
      if (externalSync != null) {
        final externalResult = await externalSync.syncExternalForNote(next);
        next = externalResult.note;
      }

      await db.writeTxn(() async {
        await db.notes.put(next);
      });
      await _syncNoteToFirestore(next);
    } catch (_) {
      // Pending notes stay visible and will be retried by AI background service.
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