import 'dart:async';

import 'package:flutter/foundation.dart' show compute, debugPrint, debugPrintStack;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/features/ai/data/groq_note_classifier.dart';
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
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance,
       _externalSync = externalSync ?? sl<ExternalSyncService>(),
       _noteEventBus = noteEventBus ?? NoteEventBus.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore _isarNoteStore;
  final ExternalSyncService _externalSync;
  final NoteEventBus _noteEventBus;

  StreamSubscription<String>? _noteSavedSubscription;
  final Set<String> _inFlightNoteIds = <String>{};
  bool _sweepRunning = false;

  void start() {
    Future.delayed(const Duration(seconds: 3), () => unawaited(_sweepPendingOnce()));
    _noteSavedSubscription ??= _noteEventBus.onNoteSaved.listen((noteId) {
      Future.delayed(const Duration(milliseconds: 200), () {
        unawaited(processNoteById(noteId));
      });
    });
  }

  Future<void> flushPendingQueue() async {
    await _sweepPendingOnce();
  }

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

      // Process up to 3 concurrently
      final chunks = <List<Note>>[];
      for (var i = 0; i < pending.length; i += 3) {
        chunks.add(pending.sublist(i, (i + 3).clamp(0, pending.length)));
      }
      for (final chunk in chunks) {
        await Future.wait(chunk.map((n) => processNoteById(n.noteId)));
      }
    } catch (_) {
    } finally {
      _sweepRunning = false;
    }
  }

  Future<void> processNoteById(String noteId) async {
    final trimmedId = noteId.trim();
    if (trimmedId.isEmpty || _inFlightNoteIds.contains(trimmedId)) return;

    _inFlightNoteIds.add(trimmedId);
    try {
      final note = await _isarNoteStore.getByNoteId(trimmedId);
      if (note == null || note.status != NoteStatus.pendingAi) return;

      // Run AI off the main thread using compute so the UI never janks.
      final result = await compute(
        _classifyInBackground,
        _ClassifyInput(
          transcript: note.rawTranscript,
          geminiKey: AppEnv.geminiApiKey,
          groqKey: AppEnv.groqApiKey,
        ),
      );
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

      // Tell island UI to refresh with resolved category/model.
      try {
        sl<CaptureUiController>().notifyExternalRecordingSaved(
          title: activeNote.title,
          category: activeNote.category,
          model: activeNote.aiModel.trim().isNotEmpty
              ? activeNote.aiModel
              : 'AI',
        );
      } catch (_) {}

      // Also notify native island directly.
      try {
        await sl<OverlayNotifier>().notifyNativeSaved(
          activeNote.title,
          activeNote.category,
        );
      } catch (_) {}

      // External sync + Firestore fire-and-forget.
      unawaited(_syncExternalAndFirestore(activeNote));
    } catch (e, st) {
      debugPrint('[AiProcessingService] Error processing $trimmedId: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      _inFlightNoteIds.remove(trimmedId);
    }
  }

  Future<void> _syncExternalAndFirestore(Note note) async {
    try {
      final externalResult = await _externalSync.syncExternalForNote(note);
      final synced = externalResult.note;
      if (externalResult.noteChanged) await _isarNoteStore.put(synced);
      await _syncToFirestore(synced);
    } catch (e) {
      debugPrint('[AiProcessingService] background sync error: $e');
    }
  }

  Future<bool> _syncToFirestore(Note note) async {
    var user = _auth.currentUser;
    // Wait for auth to hydrate in isolated contexts
    if (user == null) {
      try {
        user = await _auth
            .authStateChanges()
            .firstWhere((u) => u != null, orElse: () => null as User?)
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }

    final uid = user?.uid ?? note.uid;
    if (uid.isEmpty || uid == 'local_anonymous') {
      debugPrint(
        '[AiProcessingService] Firebase sync skipped: user not authenticated ($uid)',
      );
      return false; // Return false so it is retried later!
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
      debugPrint('[AiProcessingService] Firestore sync error: $e');
      return false;
    }
  }
}

class _ClassifyInput {
  const _ClassifyInput({
    required this.transcript,
    required this.geminiKey,
    required this.groqKey,
  });

  final String transcript;
  final String geminiKey;
  final String groqKey;
}

/// Runs in a separate Dart isolate. No Flutter plugin calls are allowed here.
Future<GeminiClassificationResult> _classifyInBackground(
  _ClassifyInput input,
) async {
  // Try Gemini first with a tight timeout.
  try {
    final gemini = GeminiNoteClassifier(apiKey: input.geminiKey);
    return await gemini.classify(input.transcript).timeout(
      const Duration(seconds: 8),
    );
  } catch (_) {}

  // Fallback to Groq.
  try {
    final groq = GroqNoteClassifier(apiKey: input.groqKey);
    final result = await groq.classify(input.transcript).timeout(
      const Duration(seconds: 8),
    );
    if (result != null) return result;
  } catch (_) {}

  // Local fallback. Never fails.
  final oneLine = input.transcript.replaceAll('\n', ' ').trim();
  return GeminiClassificationResult(
    title: oneLine.length <= 60 ? oneLine : '${oneLine.substring(0, 60)}...',
    category: NoteCategory.general,
    priority: NotePriority.medium,
    extractedDate: null,
    cleanBody: input.transcript.trim(),
    model: 'local-fallback',
    wasFallback: true,
  );
}
