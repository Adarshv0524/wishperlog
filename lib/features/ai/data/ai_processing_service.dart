import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class AiProcessingService {
  AiProcessingService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
    ExternalSyncService? externalSync,
    NoteEventBus? noteEventBus,
    AiClassifierRouter? aiRouter,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance,
        _externalSync = externalSync ??
            (sl.isRegistered<ExternalSyncService>()
                ? sl<ExternalSyncService>()
                : ExternalSyncService()),
        _noteEventBus = noteEventBus ?? NoteEventBus.instance,
        _aiRouter = aiRouter ??
            (sl.isRegistered<AiClassifierRouter>()
                ? sl<AiClassifierRouter>()
                : AiClassifierRouter());

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore _isarNoteStore;
  final ExternalSyncService _externalSync;
  final NoteEventBus _noteEventBus;
  final AiClassifierRouter _aiRouter;

  StreamSubscription<String>? _noteSavedSubscription;
  final Set<String> _inFlightNoteIds = {};
  bool _sweepRunning = false;

  void start() {
    // Sweep existing pending notes shortly after startup
    Future.delayed(const Duration(seconds: 2), _sweepPendingOnce);
    // Listen for new saves
    _noteSavedSubscription ??= _noteEventBus.onNoteSaved.listen((noteId) {
      Future.delayed(const Duration(milliseconds: 300), () {
        unawaited(processNoteById(noteId));
      });
    });
  }

  Future<void> flushPendingQueue() => _sweepPendingOnce();

  void dispose() {
    _noteSavedSubscription?.cancel();
    _noteSavedSubscription = null;
  }

  Future<void> _sweepPendingOnce() async {
    if (_sweepRunning) return;
    _sweepRunning = true;
    try {
      final pending = await _isarNoteStore.getPendingAiNotes();
      if (pending.isEmpty) return;
      debugPrint('[AiProcessingService] Sweeping ${pending.length} pending notes');
      // Process in batches of 2 to avoid hammering Gemini
      for (var i = 0; i < pending.length; i += 2) {
        final chunk = pending.sublist(i, (i + 2).clamp(0, pending.length));
        await Future.wait(chunk.map((n) => processNoteById(n.noteId)));
        if (i + 2 < pending.length) {
          await Future<void>.delayed(const Duration(milliseconds: 500));
        }
      }
    } catch (e, st) {
      debugPrint('[AiProcessingService] sweep error: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      _sweepRunning = false;
    }
  }

  Future<void> processNoteById(String noteId) async {
    final id = noteId.trim();
    if (id.isEmpty || _inFlightNoteIds.contains(id)) return;

    _inFlightNoteIds.add(id);
    try {
      final note = await _isarNoteStore.getByNoteId(id);
      if (note == null) {
        debugPrint('[AiProcessingService] Note not found: $id');
        return;
      }
      if (note.status != NoteStatus.pendingAi) {
        debugPrint('[AiProcessingService] Skipping $id — status=${note.status.name}');
        return;
      }

      debugPrint('[AiProcessingService] Classifying: $id');

      // ── Run AI on the main isolate so plugin state & env vars are accessible ─
      // (google_generative_ai is stateless; safe to call here)
      final result = await _aiRouter.classify(note.rawTranscript);

      debugPrint('[AiProcessingService] Classified: $id → '
          'cat=${result.category.name} pri=${result.priority.name} '
          'model=${result.model} fallback=${result.wasFallback}');

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

      await _isarNoteStore.put(activeNote);
      debugPrint('[AiProcessingService] Saved to Isar: $id');

      // ── Notify UI ──────────────────────────────────────────────────────────
      try {
        sl<CaptureUiController>().notifyExternalRecordingSaved(
          title: activeNote.title,
          category: activeNote.category,
          model: activeNote.aiModel.trim().isNotEmpty ? activeNote.aiModel : 'AI',
          noteId: activeNote.noteId,
        );
      } catch (_) {}

      try {
        await sl<OverlayNotifier>().notifyNativeSaved(
          activeNote.title,
          activeNote.category,
        );
      } catch (_) {}

      // ── Background: Firestore + external sync (fire-and-forget) ───────────
      unawaited(_syncAll(activeNote));
    } catch (e, st) {
      debugPrint('[AiProcessingService] Error processing $id: $e');
      debugPrintStack(stackTrace: st);
      // Mark as active with fallback so it won't be retried forever
      try {
        final note = await _isarNoteStore.getByNoteId(id);
        if (note != null && note.status == NoteStatus.pendingAi) {
          await _isarNoteStore.put(note.copyWith(
            status: NoteStatus.active,
            aiModel: 'error-fallback',
            updatedAt: DateTime.now(),
          ));
        }
      } catch (_) {}
    } finally {
      _inFlightNoteIds.remove(id);
    }
  }

  // ── Sync helpers ──────────────────────────────────────────────────────────

  Future<void> _syncAll(Note note) async {
    await Future.wait([
      _syncToFirestore(note),
      _syncToExternal(note),
    ]);
  }

  Future<void> _syncToExternal(Note note) async {
    try {
      final changed = await _externalSync.syncNoteToExternal(note);
      if (changed != null && changed.noteId == note.noteId) {
        // External sync updated gtaskId or gcalEventId — persist those back
        await _isarNoteStore.put(changed);
        await _syncToFirestore(changed);
      }
    } catch (e) {
      debugPrint('[AiProcessingService] external sync error for ${note.noteId}: $e');
    }
  }

  Future<bool> _syncToFirestore(Note note) async {
    var user = _auth.currentUser;
    if (user == null) {
      try {
        user = await _auth
            .authStateChanges()
            .firstWhere((u) => u != null, orElse: () => null as User?)
            .timeout(const Duration(seconds: 3));
      } catch (_) {}
    }

    final uid = user?.uid ?? note.uid;
    if (uid.isEmpty || uid == 'local_anonymous') {
      debugPrint('[AiProcessingService] Firestore sync skipped: not authenticated');
      return false;
    }

    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(note.noteId)
          .set(note.toFirestoreJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      debugPrint('[AiProcessingService] Firestore error: $e');
      return false;
    }
  }
}