import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/firebase_options.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

/// Dart entry-point for [BackgroundNoteService].
///
/// Boots a minimal Flutter environment (no widgets), initialises Firebase +
/// Isar, then receives raw transcripts from Kotlin via a MethodChannel,
/// persists them, runs AI classification, and syncs to Firestore — all while
/// the main UI is completely absent.
///
/// CRITICAL FIX #2:
/// After all notes are processed, sends the last saved note's {title, category}
/// back to Kotlin via the 'done' call. BackgroundNoteService forwards this to
/// OverlayForegroundService.notifyBackgroundSaved(), resolving the permanently
/// stuck "Classifying..." island.
@pragma('vm:entry-point')
Future<void> backgroundNoteCallback() async {
  // Minimal binding — no UI, no widget tree.
  WidgetsFlutterBinding.ensureInitialized();

  const bgChannel = MethodChannel('wishperlog/background_notes');

  // Track last successfully saved note so we can report it to the island.
  String lastTitle = '';
  String lastCategory = 'general';
  String lastPrefix = 'AI';

  try {
    debugPrint('[BgNoteHandler] Initialising…');
    await AppEnv.load();

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await IsarNoteStore.instance.init();

    final aiRouter       = AiClassifierRouter();
    await aiRouter.hydrate();
    final captureService = CaptureService(aiRouter: aiRouter);

    debugPrint('[BgNoteHandler] Ready — signalling Kotlin');

    // Tell Kotlin the Dart side is ready.
    await bgChannel.invokeMethod<void>('ready');

    bgChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'processNote':
          final text   = (call.arguments as Map)['text']   as String? ?? '';
          final srcStr = (call.arguments as Map)['source'] as String? ?? 'voice_overlay';
          final source = srcStr == 'text_overlay'
              ? CaptureSource.textOverlay
              : CaptureSource.voiceOverlay;

          if (text.isNotEmpty) {
            debugPrint('[BgNoteHandler] Processing note (len=${text.length})');
            try {
              final note = await captureService.ingestRawCapture(
                rawTranscript: text,
                source: source,
                syncToCloud: true,
              );
              if (note != null) {
                final enriched = await _classifyAndUpdate(note, aiRouter);
                // CRITICAL FIX #2: track result so we can pass it in 'done'.
                if (enriched != null) {
                  lastTitle = enriched.title;
                  lastCategory = enriched.category.name;
                    lastPrefix = saveOriginPrefix(enriched.aiModel);
                } else {
                  // ingestRawCapture succeeded but AI failed — use quick title.
                  lastTitle = note.title;
                  lastCategory = note.category.name;
                    lastPrefix = 'sys';
                }
              }
            } catch (e, st) {
              debugPrint('[BgNoteHandler] Error processing note: $e');
              debugPrintStack(stackTrace: st);
            }
          }
          // Tell Kotlin we're ready for the next one.
          await bgChannel.invokeMethod<void>('nextNote');

        case 'allDone':
            debugPrint('[BgNoteHandler] All notes processed — '
              'title="$lastTitle" category="$lastCategory"');
          // CRITICAL FIX #2: pass title + category so Kotlin can update the
          // island from "Classifying..." to the real saved state.
          await bgChannel.invokeMethod<void>('done', {
            'title':    lastTitle,
            'category': lastCategory,
            'prefix':   lastPrefix,
          });
      }
    });

    // Keep isolate alive until Kotlin calls 'done'.
    await Future<void>.delayed(const Duration(seconds: 60));
  } catch (e, st) {
    debugPrint('[BgNoteHandler] Fatal error: $e');
    debugPrintStack(stackTrace: st);
    // Signal done with empty title so island dismisses rather than staying stuck.
    await bgChannel.invokeMethod<void>('done', {'title': '', 'category': 'general'})
        .catchError((_) {});
  }
}

/// Runs Gemini classification on [note] and writes the enriched version back
/// to Isar + Firestore. Returns the enriched [Note] on success, null on failure.
Future<Note?> _classifyAndUpdate(Note note, AiClassifierRouter aiRouter) async {
  try {
    final result = await aiRouter.classify(note.rawTranscript);
    final updated = note.copyWith(
      title:         result.title,
      cleanBody:     result.cleanBody,
      category:      result.category,
      priority:      result.priority,
      extractedDate: result.extractedDate,
      aiModel:       result.model,
      status:        NoteStatus.active,
      updatedAt:     DateTime.now(),
    );
    await IsarNoteStore.instance.put(updated);
    debugPrint('[BgNoteHandler] AI enrichment done — '
        'category=${result.category.name} title="${result.title}"');
    return updated;
  } catch (e) {
    debugPrint('[BgNoteHandler] AI classification skipped: $e');
    // Leave note as pendingAi — AiProcessingService picks it up on next launch.
    return null;
  }
}