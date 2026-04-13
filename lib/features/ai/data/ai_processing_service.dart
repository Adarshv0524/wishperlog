import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/features/ai/data/unified_ai_classifier.dart';
import 'package:wishperlog/features/sync/data/message_state_service.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// AiProcessingService — orchestrates the full note enrichment pipeline.
///
/// Pipeline for each note:
///   1. Fetch raw note from Isar (status = pendingAi).
///   2. Classify via AiClassifierRouter (Gemini → Groq → local fallback).
///      Temporal context (today's date/time) is auto-injected by the router.
///   3. Update note in Isar + Firestore with enriched fields.
///   4. Kick off ExternalSyncService.syncSingleNote() to push to Google.
///   5. Emit NoteEventBus.emitNoteUpdated() for UI refresh.
///
/// Concurrency: max 2 notes in-flight to avoid hammering APIs.
/// ─────────────────────────────────────────────────────────────────────────────
class AiProcessingService {
  AiProcessingService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
    ExternalSyncService? externalSync,
    NoteEventBus? noteEventBus,
    AiClassifierRouter? aiRouter,
  })  : _auth          = auth     ?? FirebaseAuth.instance,
        _firestore     = firestore ?? FirebaseFirestore.instance,
        _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance,
        _externalSync  = externalSync  ??
            (sl.isRegistered<ExternalSyncService>()
                ? sl<ExternalSyncService>()
                : ExternalSyncService()),
        _noteEventBus  = noteEventBus ?? NoteEventBus.instance,
        _aiRouter      = aiRouter ??
            (sl.isRegistered<AiClassifierRouter>()
                ? sl<AiClassifierRouter>()
                : AiClassifierRouter());

  final FirebaseAuth       _auth;
  final FirebaseFirestore  _firestore;
  final IsarNoteStore      _isarNoteStore;
  final ExternalSyncService _externalSync;
  final NoteEventBus       _noteEventBus;
  final AiClassifierRouter _aiRouter;

  StreamSubscription<String>? _noteSavedSub;
  final Set<String> _inFlight  = {};
  bool _sweepRunning            = false;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  void start() {
    // Sweep any notes that were saved before AI was ready (e.g. app restart).
    Future<void>.delayed(const Duration(seconds: 2), _sweepPendingOnce);

    // Listen for new saves and process them immediately.
    _noteSavedSub ??= _noteEventBus.onNoteSaved.listen((noteId) {
      Future<void>.delayed(const Duration(milliseconds: 300), () {
        unawaited(processNoteById(noteId));
      });
    });
  }

  Future<void> flushPendingQueue() => _sweepPendingOnce();

  void dispose() {
    _noteSavedSub?.cancel();
    _noteSavedSub = null;
    _inFlight.clear();
  }

  // ── Sweep ────────────────────────────────────────────────────────────────────

  Future<void> _sweepPendingOnce() async {
    if (_sweepRunning) return;
    _sweepRunning = true;
    try {
      final pending = await _isarNoteStore.getPendingAiNotes();
      if (pending.isEmpty) return;
      debugPrint('[AiProcessingService] Sweeping ${pending.length} pending notes');
      // Process in batches of 2 — avoids hammering Gemini quota.
      for (var i = 0; i < pending.length; i += 2) {
        final chunk = pending.sublist(i, (i + 2).clamp(0, pending.length));
        await Future.wait(chunk.map((n) => processNoteById(n.noteId)));
      }
    } catch (e) {
      debugPrint('[AiProcessingService] _sweepPendingOnce error: $e');
    } finally {
      _sweepRunning = false;
    }
  }

  // ── Core processing ───────────────────────────────────────────────────────────

  Future<void> processNoteById(String noteId) async {
    if (_inFlight.contains(noteId)) return;
    _inFlight.add(noteId);
    try {
      final note = await _isarNoteStore.getById(noteId);
      // Guard: if the background handler already enriched the note
      // (status = active, aiModel != ''), skip re-classification.
      if (note != null &&
          note.status != NoteStatus.pendingAi &&
          note.aiModel.isNotEmpty) {
        debugPrint('[AiProcessingService] Skipping already-active note: $noteId');
        return;
      }
      if (note == null) {
        debugPrint('[AiProcessingService] Note $noteId not found — skipping');
        return;
      }
      if (note.status != NoteStatus.pendingAi) {
        debugPrint('[AiProcessingService] Note $noteId not pendingAi (${note.status}) — skipping');
        return;
      }
      await _processNote(note);
    } catch (e) {
      debugPrint('[AiProcessingService] processNoteById error for $noteId: $e');
      // Mark as synced with original content to avoid getting stuck in pending.
      await _markFallback(noteId);
    } finally {
      _inFlight.remove(noteId);
    }
  }

  Future<void> _processNote(Note note) async {
    debugPrint('[AiProcessingService] Classifying note ${note.noteId}');

    // ── STEP 1: Classify ───────────────────────────────────────────────────────
    // Temporal context is auto-injected by AiClassifierRouter via
    // UnifiedAiClassifier.buildSystemPrompt() — no extra work needed here.
    final UnifiedAiClassificationResult result;
    try {
      result = await _aiRouter.classify(note.rawTranscript);
    } catch (e) {
      debugPrint('[AiProcessingService] classify failed for ${note.noteId}: $e');
      await _markFallback(note.noteId);
      return;
    }

    // ── STEP 2: Build enriched note ────────────────────────────────────────────
    final enriched = note.copyWith(
      title:              result.title,
      cleanBody:          result.cleanBody,
      translatedContent:  result.translatedContent,
      translatedTitle:    result.translatedTitle,
      category:           result.category,
      priority:           result.priority,
      extractedDate:      result.extractedDate,
      aiModel:            result.model,
      status:             NoteStatus.active,
      updatedAt:          DateTime.now(),
    );

    // ── STEP 3: Persist locally ────────────────────────────────────────────────
    await _isarNoteStore.put(enriched);
    debugPrint('[AiProcessingService] Saved enriched note ${enriched.noteId} '
        '[${enriched.category.name}] via ${enriched.aiModel}');

    // ── STEP 4: Push to Firestore ──────────────────────────────────────────────
    unawaited(_pushToFirestore(enriched));

    // ── STEP 5: External sync (Google Tasks / Calendar) ────────────────────────
    unawaited(_externalSync.syncSingleNote(enriched).then((r) {
      if (r.noteChanged) {
        unawaited(_isarNoteStore.put(r.note));
        unawaited(_pushToFirestore(r.note));
      }
    }).catchError((e) {
      debugPrint('[AiProcessingService] externalSync error for ${enriched.noteId}: $e');
    }));

    // ── STEP 6: Notify UI ──────────────────────────────────────────────────────
    _noteEventBus.emitNoteUpdated(enriched.noteId);

    unawaited(MessageStateService.instance.recompute(uid: enriched.uid));
  }

  Future<void> _markFallback(String noteId) async {
    try {
      final note = await _isarNoteStore.getById(noteId);
      if (note == null || note.status != NoteStatus.pendingAi) return;
      final fallback = note.copyWith(
        status:    NoteStatus.active,
        aiModel:   'local',
        updatedAt: DateTime.now(),
      );
      await _isarNoteStore.put(fallback);
      unawaited(_pushToFirestore(fallback));
      _noteEventBus.emitNoteUpdated(noteId);
      unawaited(MessageStateService.instance.recompute(uid: fallback.uid));
    } catch (e) {
      debugPrint('[AiProcessingService] _markFallback error for $noteId: $e');
    }
  }

  Future<void> _pushToFirestore(Note note) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    try {
      await _firestore
          .collection('users').doc(uid)
          .collection('notes').doc(note.noteId)
          .set(_noteToFirestoreMap(note), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[AiProcessingService] Firestore push error for ${note.noteId}: $e');
    }
  }

  Map<String, dynamic> _noteToFirestoreMap(Note note) => {
    'note_id':        note.noteId,
    'uid':            note.uid,
    'raw_transcript': note.rawTranscript,
    'translated_content': note.translatedContent,
    'translated_title': note.translatedTitle,
    'title':          note.title,
    'clean_body':     note.cleanBody,
    'category':       note.category.name,
    'priority':       note.priority.name,
    'ai_model':       note.aiModel,
    'status':         note.status.name,
    'source':         note.source.name,
    'extracted_date': note.extractedDate?.toIso8601String(),
    'created_at':     note.createdAt.toIso8601String(),
    'updated_at':     note.updatedAt.toIso8601String(),
    'synced_at':      note.syncedAt?.toIso8601String(),
    'gtask_id':       note.gtaskId,
    'gcal_event_id':  note.gcalEventId,
    'is_deleted':     note.status == NoteStatus.deleted,
  };
}