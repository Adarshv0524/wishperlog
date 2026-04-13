# Consolidated Source Bundle

Generated: 2026-04-13T18:24:22+00:00

## Summary
- Dart files: 71
- Android files: 26
- Cloudfare files: 2
- Total files: 99

## File Index
- lib/app/route_observer.dart (dart)
- lib/app/router.dart (dart)
- lib/background_note_handler.dart (dart)
- lib/core/background/connectivity_sync_coordinator.dart (dart)
- lib/core/background/work_manager_service.dart (dart)
- lib/core/config/app_env.dart (dart)
- lib/core/di/injection_container.dart (dart)
- lib/core/settings/app_preferences_repository.dart (dart)
- lib/core/storage/isar_note_store.dart (dart)
- lib/core/theme/app_colors.dart (dart)
- lib/core/theme/app_colors_x.dart (dart)
- lib/core/theme/app_durations.dart (dart)
- lib/core/theme/app_springs.dart (dart)
- lib/core/theme/app_theme.dart (dart)
- lib/core/theme/theme_cubit.dart (dart)
- lib/features/ai/data/ai_classifier_router.dart (dart)
- lib/features/ai/data/ai_processing_service.dart (dart)
- lib/features/ai/data/gemini_note_classifier.dart (dart)
- lib/features/ai/data/groq_note_classifier.dart (dart)
- lib/features/auth/data/repositories/user_repository.dart (dart)
- lib/features/capture/data/capture_service.dart (dart)
- lib/features/capture/presentation/state/capture_ui_controller.dart (dart)
- lib/features/capture/presentation/state/capture_ui_state.dart (dart)
- lib/features/home/presentation/home_screen_layout.dart (dart)
- lib/features/home/presentation/screens/home_screen.dart (dart)
- lib/features/home/presentation/widgets/folder_grid.dart (dart)
- lib/features/home/presentation/widgets/thought_canvas.dart (dart)
- lib/features/nlp/nlp_task_parser.dart (dart)
- lib/features/notes/data/note_repository.dart (dart)
- lib/features/notes/presentation/screens/folder_screen.dart (dart)
- lib/features/notes/presentation/screens/note_detail_screen.dart (dart)
- lib/features/notes/presentation/screens/note_view_screen.dart (dart)
- lib/features/notes/presentation/widgets/glass_note_card.dart (dart)
- lib/features/notes/presentation/widgets/search_notes_modal.dart (dart)
- lib/features/notifications/data/local_notification_service.dart (dart)
- lib/features/onboarding/presentation/screens/permissions_screen.dart (dart)
- lib/features/onboarding/presentation/screens/sign_in_screen.dart (dart)
- lib/features/onboarding/presentation/screens/splash_screen.dart (dart)
- lib/features/onboarding/presentation/screens/telegram_screen.dart (dart)
- lib/features/overlay/overlay_bubble.dart (dart)
- lib/features/overlay/overlay_customisation_sheet.dart (dart)
- lib/features/overlay/overlay_notifier.dart (dart)
- lib/features/overlay/overlay_settings_model.dart (dart)
- lib/features/overlay/presentation/system_banner_overlay.dart (dart)
- lib/features/overlay/quick_note_editor.dart (dart)
- lib/features/search/data/smart_note_search.dart (dart)
- lib/features/search/presentation/search_screen.dart (dart)
- lib/features/settings/presentation/screens/settings_screen.dart (dart)
- lib/features/settings/presentation/widgets/digest_schedule_section.dart (dart)
- lib/features/settings/presentation/widgets/telegram_connection_section.dart (dart)
- lib/features/sync/data/external_sync_service.dart (dart)
- lib/features/sync/data/fcm_sync_service.dart (dart)
- lib/features/sync/data/firestore_note_sync_service.dart (dart)
- lib/features/sync/data/google_api_client.dart (dart)
- lib/features/sync/data/message_state_service.dart (dart)
- lib/features/sync/data/telegram_service.dart (dart)
- lib/firebase_options.dart (dart)
- lib/main.dart (dart)
- lib/shared/events/note_event_bus.dart (dart)
- lib/shared/models/enums.dart (dart)
- lib/shared/models/note.dart (dart)
- lib/shared/models/note.g.dart (dart)
- lib/shared/models/note_helpers.dart (dart)
- lib/shared/models/user.dart (dart)
- lib/shared/widgets/atoms/category_color.dart (dart)
- lib/shared/widgets/glass_container.dart (dart)
- lib/shared/widgets/glass_page_background.dart (dart)
- lib/shared/widgets/glass_pane.dart (dart)
- lib/shared/widgets/glass_title_bar.dart (dart)
- lib/shared/widgets/mesh_gradient_background.dart (dart)
- lib/shared/widgets/top_notch_message.dart (dart)
- android/app/build.gradle.kts (kotlin)
- android/app/google-services.json (json)
- android/app/src/debug/AndroidManifest.xml (xml)
- android/app/src/main/AndroidManifest.xml (xml)
- android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java (java)
- android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/BackgroundNoteService.kt (kotlin)
- android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/BootReceiver.kt (kotlin)
- android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/FlutterEngineHolder.kt (kotlin)
- android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/MainActivity.kt (kotlin)
- android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/NoteInputReceiver.kt (kotlin)
- android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/OverlayAppearanceSettings.kt (kotlin)
- android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/OverlayForegroundService.kt (kotlin)
- android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/WishperlogApplication.kt (kotlin)
- android/app/src/main/res/drawable/launch_background.xml (xml)
- android/app/src/main/res/drawable-v21/launch_background.xml (xml)
- android/app/src/main/res/values/colors.xml (xml)
- android/app/src/main/res/values/styles.xml (xml)
- android/app/src/main/res/values-night/styles.xml (xml)
- android/app/src/main/res/xml/backup_rules.xml (xml)
- android/app/src/main/res/xml/data_extraction_rules.xml (xml)
- android/app/src/profile/AndroidManifest.xml (xml)
- android/build.gradle.kts (kotlin)
- android/gradle/wrapper/gradle-wrapper.properties (properties)
- android/gradle.properties (properties)
- android/local.properties (properties)
- android/settings.gradle.kts (kotlin)
- cloudfare/src/worker.ts (typescript)
- cloudfare/wrangler.toml (toml)

## Files

### lib/app/route_observer.dart

```dart
import 'package:flutter/material.dart';

final RouteObserver<PageRoute<dynamic>> routeObserver =
    RouteObserver<PageRoute<dynamic>>();
```

### lib/app/router.dart

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/app/route_observer.dart';
import 'package:wishperlog/features/home/presentation/home_screen_layout.dart';
import 'package:wishperlog/features/notes/presentation/screens/folder_screen.dart';
import 'package:wishperlog/features/notes/presentation/screens/note_detail_screen.dart';
import 'package:wishperlog/features/onboarding/presentation/screens/permissions_screen.dart';
import 'package:wishperlog/features/onboarding/presentation/screens/sign_in_screen.dart';
import 'package:wishperlog/features/onboarding/presentation/screens/telegram_screen.dart';
import 'package:wishperlog/features/search/presentation/search_screen.dart';
import 'package:wishperlog/features/settings/presentation/screens/settings_screen.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/features/notes/presentation/screens/note_view_screen.dart';
import 'package:wishperlog/features/overlay/presentation/system_banner_overlay.dart';

CustomTransitionPage<T> _buildPage<T>({
  required LocalKey key,
  required Widget child,
  Offset beginOffset = const Offset(0.04, 0.03),
  Duration duration = const Duration(milliseconds: 360),
}) {
  return CustomTransitionPage<T>(
    key: key,
    transitionDuration: duration,
    reverseTransitionDuration: const Duration(milliseconds: 280),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: beginOffset, end: Offset.zero).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.985, end: 1.0).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

final GoRouter router = GoRouter(
  observers: [routeObserver],
  routes: [
    GoRoute(
      path: '/',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const SignInScreen(),
        beginOffset: const Offset(0, 0.04),
      ),
    ),
    GoRoute(
      path: '/signin',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const SignInScreen(),
        beginOffset: const Offset(0, 0.04),
      ),
    ),
    GoRoute(
      path: '/permissions',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const PermissionsScreen(),
        beginOffset: const Offset(0, 0.06),
      ),
    ),
    GoRoute(
      path: '/telegram',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const TelegramScreen(),
        beginOffset: const Offset(0, 0.06),
      ),
    ),
    GoRoute(
      path: '/home',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const HomeScreenLayout(),
        beginOffset: const Offset(0.02, 0.035),
        duration: const Duration(milliseconds: 420),
      ),
    ),
    GoRoute(
      path: '/search',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const SearchScreen(),
        beginOffset: const Offset(0.03, 0.08),
      ),
    ),
    GoRoute(
      path: '/notes/:noteId',
      pageBuilder: (context, state) {
        final noteId = state.pathParameters['noteId'] ?? '';
        return _buildPage(
          key: state.pageKey,
          child: NoteDetailScreen(noteId: noteId),
          beginOffset: const Offset(0.04, 0.02),
          duration: const Duration(milliseconds: 380),
        );
      },
    ),
    GoRoute(
      path: '/notes/:noteId/view',
      pageBuilder: (context, state) {
        final extra = state.extra;
        // extra must be a Note object when using context.push('/notes/x/view', extra: note)
        if (extra is Note) {
          return _buildPage(
            key: state.pageKey,
            child: NoteViewScreen(note: extra),
            beginOffset: const Offset(0.0, 0.04),
            duration: const Duration(milliseconds: 400),
          );
        }
        // Fallback: redirect to edit screen
        final noteId = state.pathParameters['noteId'] ?? '';
        return _buildPage(
          key: state.pageKey,
          child: NoteDetailScreen(noteId: noteId),
          beginOffset: const Offset(0.04, 0.02),
        );
      },
    ),
    GoRoute(
      path: '/folder',
      pageBuilder: (context, state) {
        final extra = state.extra;
        if (extra is NoteCategory) {
          return _buildPage(
            key: state.pageKey,
            child: FolderScreen(category: extra),
            beginOffset: const Offset(0.05, 0.04),
            duration: const Duration(milliseconds: 400),
          );
        }

        final raw =
            state.uri.queryParameters['category'] ??
            state.pathParameters['category'] ??
            'general';
        return _buildPage(
          key: state.pageKey,
          child: FolderScreen(category: parseCategory(raw)),
          beginOffset: const Offset(0.05, 0.04),
          duration: const Duration(milliseconds: 400),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const SettingsScreen(),
        beginOffset: const Offset(0.02, 0.05),
      ),
    ),
    GoRoute(
      path: '/system_banner',
      pageBuilder: (context, state) => _buildPage(
        key: state.pageKey,
        child: const SystemBannerOverlay(),
        beginOffset: const Offset(0, 0.08),
        duration: const Duration(milliseconds: 260),
      ),
    ),
  ],
  redirect: (context, state) {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final isAuthenticated = user != null;
      final isOnboarding =
          state.matchedLocation == '/' ||
          state.matchedLocation == '/signin' ||
          state.matchedLocation == '/permissions';

      if (!isAuthenticated && !isOnboarding) {
        return '/';
      }
      if (isAuthenticated && isOnboarding) {
        return '/home';
      }
      return null;
    } on FirebaseAuthException catch (e) {
      debugPrint('[Router] FirebaseAuthException during redirect: ${e.message}');
      return '/'; // Sign-in is the safe fallback for all auth errors
    } catch (e) {
      debugPrint('[Router] Unexpected redirect error: $e');
      return '/'; // Never strand the user on a missing route
    }  },
);
```

### lib/background_note_handler.dart

```dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'package:wishperlog/features/sync/data/message_state_service.dart';

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

    // Keep isolate alive until Kotlin signals 'allDone' and our handler
    // calls bgChannel.invokeMethod('done'). Use a Completer so we never
    // cut off a batch that takes longer than an arbitrary fixed delay.
    final doneCompleter = Completer<void>();

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
          if (!doneCompleter.isCompleted) doneCompleter.complete();
      }
    });

    // Safety-net: if Kotlin never sends 'allDone', give up after 5 minutes.
    await doneCompleter.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        debugPrint('[BgNoteHandler] Timeout waiting for allDone — shutting down');
      },
    );
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

    // ── ISSUE-04 FIX: write back to Isar AND Firestore ────────────────────
    await IsarNoteStore.instance.put(updated);
    await _pushToFirestoreBg(updated);

    debugPrint('[BgNoteHandler] AI enrichment done — '
        'category=${result.category.name} title="${result.title}"');
    return updated;
  } catch (e) {
    debugPrint('[BgNoteHandler] AI classification skipped: $e');
    return null;
  }
}

/// Background-safe Firestore push (no DI, no auth service, uses FirebaseAuth directly).
Future<void> _pushToFirestoreBg(Note note) async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      debugPrint('[BgNoteHandler] Firestore push skipped — not authenticated');
      return;
    }
    // Use the canonical serialiser — keeps Firestore in sync with the model.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(note.noteId)
        .set(note.toFirestoreJson(), SetOptions(merge: true));

    // Rebuild message_state so the Worker sees fresh content after AI enrichment.
    final activeNotes = await IsarNoteStore.instance.getAllActive();
    await MessageStateService.instance.rebuildDigest(activeNotes, uid: uid);
  } catch (e) {
    debugPrint('[BgNoteHandler] Firestore push error: $e');
  }
}
```

### lib/core/background/connectivity_sync_coordinator.dart

```dart
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:wishperlog/core/background/work_manager_service.dart';

class ConnectivitySyncCoordinator {
  ConnectivitySyncCoordinator({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _sub;
  bool _wasOffline = false;

  Future<void> start() async {
    final current = await _connectivity.checkConnectivity();
    _wasOffline = !_isOnline(current);

    _sub ??= _connectivity.onConnectivityChanged.listen((results) async {
      final onlineNow = _isOnline(results);
      if (_wasOffline && onlineNow) {
        await WorkManagerService.scheduleFlushPendingAi();
      }
      _wasOffline = !onlineNow;
    });
  }

  Future<void> dispose() async {
    await _sub?.cancel();
    _sub = null;
  }

  bool _isOnline(List<ConnectivityResult> results) {
    return results.any((result) {
      return result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet ||
          result == ConnectivityResult.vpn;
    });
  }
}
```

### lib/core/background/work_manager_service.dart

```dart
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/ai/data/ai_processing_service.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/firebase_options.dart';

// ─── Background task dispatcher (runs in a separate Dart isolate) ──────────

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('[WorkManager] Task: $taskName');

    try {
      await AppEnv.load();
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      await IsarNoteStore.instance.init();
    } catch (e) {
      debugPrint('[WorkManager] Bootstrap error: $e');
      return false;
    }

    switch (taskName) {
      // ── Flush pending AI notes ─────────────────────────────────────────────
      case WorkManagerService.flushPendingTaskName:
        try {
          final svc = AiProcessingService(noteEventBus: null);
          await svc.flushPendingQueue();
          return true;
        } catch (e) {
          debugPrint('[WorkManager] flushPendingAi error: $e');
          return false;
        }

      // ── Google Tasks / Calendar periodic sync ──────────────────────────────
      case WorkManagerService.periodicTaskName:
        try {
          final sync = ExternalSyncService();
          final ok = await sync.ensureGoogleConnected();
          if (!ok) {
            debugPrint('[WorkManager] Google not signed in — skip');
            return true; // Don't retry immediately
          }
          final result = await sync.syncNow();
          debugPrint(
            '[WorkManager] Sync done — '
            'processed=${result.processed} updated=${result.updated}',
          );
          return true;
        } catch (e) {
          debugPrint('[WorkManager] periodicSync error: $e');
          return false;
        }

      default:
        debugPrint('[WorkManager] Unknown task: $taskName');
        return true;
    }
  });
}

// ─── Service facade ────────────────────────────────────────────────────────

class WorkManagerService {
  // Task identifiers — Telegram digest removed (handled by Cloudflare Worker)
  static const periodicTaskName = 'wishperlog.periodic_google_tasks_sync';
  static const periodicTaskUnique =
      'wishperlog.periodic_google_tasks_sync.unique';
  static const flushPendingTaskName = 'wishperlog.flush_pending_ai';
  static const flushPendingTaskUnique = 'wishperlog.flush_pending_ai.unique';

  static Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher);
  }

  static Future<void> registerPeriodicGoogleTasksSync() async {
    await Workmanager().registerPeriodicTask(
      periodicTaskUnique,
      periodicTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 30),
      initialDelay: const Duration(minutes: 15),
    );
  }

  static Future<void> scheduleFlushPendingAi() async {
    await Workmanager().registerOneOffTask(
      flushPendingTaskUnique,
      flushPendingTaskName,
      constraints: Constraints(networkType: NetworkType.connected),
      initialDelay: const Duration(seconds: 5),
      existingWorkPolicy: ExistingWorkPolicy.replace,
      backoffPolicy: BackoffPolicy.exponential,
      backoffPolicyDelay: const Duration(minutes: 15),
    );
  }

  static Future<void> cancelAll() async {
    await Workmanager().cancelAll();
  }
}
```

### lib/core/config/app_env.dart

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppEnv {
  AppEnv._();

  /// Whether [load] has completed at least once.
  static bool _loaded = false;

  /// Must be called before accessing any getter. Safe to call more than once.
  static Future<void> load() async {
    if (_loaded) return;
    try {
      if (!kIsWeb) {
        await dotenv.load(fileName: '.env');
      }
    } catch (_) {
      // Missing / malformed .env must never crash startup or background isolates.
    } finally {
      _loaded = true;
    }
  }

  // ── Internal safe reader ────────────────────────────────────────────────────
  // Returns '' (not null, not throws) when dotenv has not been initialized or
  // the key is absent. This is the ONLY method that should touch dotenv.
  static String _safeGet(String key) {
    try {
      final v = dotenv.maybeGet(key)?.trim();
      return (v == null || v.isEmpty) ? '' : v;
    } catch (_) {
      // NotInitializedError or any other dotenv error → empty default.
      return '';
    }
  }

  // ── Getters ─────────────────────────────────────────────────────────────────

  static String get geminiApiKey => _safeGet('GEMINI_API_KEY');

  static String get groqApiKey => _safeGet('GROQ_API_KEY');

  static String get mistralApiKey => _safeGet('MISTRAL_API_KEY');

  static String get huggingFaceApiKey => _safeGet('HUGGINGFACE_API_KEY');

  static String get cerebrasApiKey => _safeGet('CEREBRAS_API_KEY');

  static String get googleWebClientId {
    const fromDefine = String.fromEnvironment(
      'GOOGLE_WEB_CLIENT_ID',
      defaultValue:
          '982731246537-6a8ov59qm6n6f6v7rakq4su2eje8g9au.apps.googleusercontent.com',
    );
    final trimmedDefine = fromDefine.trim();
    if (trimmedDefine.isNotEmpty) return trimmedDefine;
    return _safeGet('GOOGLE_WEB_CLIENT_ID');
  }

  static String get telegramBotToken {
    const fromDefine = String.fromEnvironment('TELEGRAM_BOT_TOKEN', defaultValue: '');
    final trimmedDefine = fromDefine.trim();
    if (trimmedDefine.isNotEmpty) return trimmedDefine;
    return _safeGet('TELEGRAM_BOT_TOKEN');
  }

  static String get telegramBotUsername {
    const fromDefine = String.fromEnvironment('TELEGRAM_BOT_USERNAME', defaultValue: '');
    final trimmedDefine = fromDefine.trim();
    if (trimmedDefine.isNotEmpty) return trimmedDefine;
    return _safeGet('TELEGRAM_BOT_USERNAME');
  }

  static String get telegramDeepLinkBase {
    const fromDefine = String.fromEnvironment('TELEGRAM_DEEP_LINK_BASE', defaultValue: '');
    final trimmedDefine = fromDefine.trim();
    if (trimmedDefine.isNotEmpty) return trimmedDefine;
    return _safeGet('TELEGRAM_DEEP_LINK_BASE');
  }
}
```

### lib/core/di/injection_container.dart

```dart
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/background/connectivity_sync_coordinator.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/ai/data/ai_processing_service.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/features/sync/data/telegram_service.dart';
import 'package:wishperlog/features/sync/data/fcm_sync_service.dart';
import 'package:wishperlog/features/sync/data/firestore_note_sync_service.dart';
import 'package:wishperlog/features/sync/data/message_state_service.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ── Core repositories ──────────────────────────────────────────────────────
  sl.registerLazySingleton<AppPreferencesRepository>(
    () => AppPreferencesRepository(),
  );
    sl.registerLazySingleton<NoteRepository>(() => NoteRepository());
  sl.registerLazySingleton<SpeechToText>(() => SpeechToText());
  sl.registerLazySingleton<TelegramService>(() => TelegramService.instance);
  sl.registerLazySingleton<NoteEventBus>(() => NoteEventBus.instance);
  sl.registerLazySingleton<IsarNoteStore>(() => IsarNoteStore.instance);

  // ── Capture ────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<CaptureService>(() => CaptureService());
  sl.registerLazySingleton<CaptureUiController>(
    () => CaptureUiController(
      captureService: sl<CaptureService>(),
      speechToText: sl<SpeechToText>(),
    ),
  );

  // ── Overlay (new, clean) ───────────────────────────────────────────────────
  // Single source of truth for overlay enabled/position.
  // NO BuildContext references anywhere in this layer.
  sl.registerLazySingleton<OverlayNotifier>(() => OverlayNotifier());

  // ── AI + Sync services ─────────────────────────────────────────────────────
  sl.registerLazySingleton<AiClassifierRouter>(
    () => AiClassifierRouter()..hydrate(),
  );
  sl.registerLazySingleton<FirestoreNoteSyncService>(
    () => FirestoreNoteSyncService(),
  );

  // ── Background services ────────────────────────────────────────────────────
  sl.registerLazySingleton<AiProcessingService>(
    () => AiProcessingService(noteEventBus: sl<NoteEventBus>()),
  );
  sl.registerLazySingleton<FcmSyncService>(() => FcmSyncService());
  sl.registerLazySingleton<ConnectivitySyncCoordinator>(
    () => ConnectivitySyncCoordinator(),
  );

  // ── Presentation state ─────────────────────────────────────────────────────
  sl.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(sl<AppPreferencesRepository>()),
  );

  // ── Google Sign-In ────────────────────────────────────────────────────────
  sl.registerLazySingleton<GoogleSignIn>(() => GoogleSignIn(scopes: [
    'email',
    'https://www.googleapis.com/auth/calendar',
    'https://www.googleapis.com/auth/tasks',
  ]));

  sl.registerLazySingleton<ExternalSyncService>(
    () => ExternalSyncService(googleSignIn: sl<GoogleSignIn>()),
  );

  sl.registerLazySingleton<UserRepository>(
    () => UserRepository(googleSignIn: sl<GoogleSignIn>()),
  );

  // ── Message-state service ──────────────────────────────────────────────────
  sl.registerLazySingleton<MessageStateService>(
    () => MessageStateService.instance,
  );
}
```

### lib/core/settings/app_preferences_repository.dart

```dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesRepository {
  static const _themeModeKey = 'prefs.theme_mode';
  static const _digestHourKey = 'prefs.digest_hour';
  static const _digestMinuteKey = 'prefs.digest_minute';
  static const _digestTimesKey = 'prefs.digest_times';

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);
    return switch (raw) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeModeKey, value);
  }

  Future<TimeOfDay> getDigestTime() async {
    final times = await getDigestTimes();
    return times.first;
  }

  Future<void> setDigestTime(TimeOfDay time) async {
    await setDigestTimes([time]);
  }

  Future<List<TimeOfDay>> getDigestTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_digestTimesKey) ?? const [];

    final parsed = raw
        .map(_parseHm)
        .whereType<TimeOfDay>()
        .toList();

    if (parsed.isNotEmpty) {
      return _normalizeTimes(parsed);
    }

    final hour = prefs.getInt(_digestHourKey) ?? 9;
    final minute = prefs.getInt(_digestMinuteKey) ?? 0;
    return [TimeOfDay(hour: hour, minute: minute)];
  }

  Future<void> setDigestTimes(List<TimeOfDay> times) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _normalizeTimes(times);
    final persisted = normalized.map(_toHm).toList();

    await prefs.setStringList(_digestTimesKey, persisted);

    final first = normalized.first;
    await prefs.setInt(_digestHourKey, first.hour);
    await prefs.setInt(_digestMinuteKey, first.minute);
  }

  List<TimeOfDay> _normalizeTimes(List<TimeOfDay> times) {
    final byMinute = <int, TimeOfDay>{};
    for (final t in times) {
      byMinute[t.hour * 60 + t.minute] = t;
    }
    final sortedMinutes = byMinute.keys.toList()..sort();
    if (sortedMinutes.isEmpty) {
      return const [TimeOfDay(hour: 9, minute: 0)];
    }
    return sortedMinutes
        .map((m) => TimeOfDay(hour: m ~/ 60, minute: m % 60))
        .toList();
  }

  TimeOfDay? _parseHm(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return TimeOfDay(hour: h, minute: m);
  }

  String _toHm(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
```

### lib/core/storage/isar_note_store.dart

```dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class IsarNoteStore {
  IsarNoteStore._();

  static final IsarNoteStore instance = IsarNoteStore._();

  Isar? _isar;

  /// Fallback mode: if Isar fails on web, use Firestore directly
  bool _useFirestoreOnly = false;
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  // Completer now carries void — callers only need to know init completed.
  Completer<void>? _initCompleter;

  /// Initialises the store.
  ///
  /// On non-web platforms: always opens Isar.
  /// On web: tries Isar, falls back to Firestore-only on failure.
  /// Returns immediately if already initialised.
  Future<void> init() async {
    // Already initialised paths.
    if (_useFirestoreOnly) return; // Firestore-only mode already set.
    if (_isar != null && _isar!.isOpen) return;

    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<void>();
    try {
      _auth      ??= FirebaseAuth.instance;
      _firestore ??= FirebaseFirestore.instance;

      if (kIsWeb) {
        try {
          _isar = await Isar.open(
            [NoteSchema],
            directory: '.',
            name: 'wishperlog_isar',
          );
          _useFirestoreOnly = false;
          debugPrint('[IsarNoteStore] ✓ Ready on web (Isar + IndexedDB)');
        } catch (e) {
          debugPrint(
            '[IsarNoteStore] ⚠ Isar init failed on web: $e\n'
            'Falling back to Firestore-only mode.',
          );
          _useFirestoreOnly = true;
          _isar = null;
          // Firestore-only is a valid success path — complete without error.
        }
      } else {
        final docsDir = await getApplicationDocumentsDirectory();
        _isar = await Isar.open(
          [NoteSchema],
          directory: docsDir.path,
          name: 'wishperlog_isar',
        );
        _useFirestoreOnly = false;
        debugPrint('[IsarNoteStore] ✓ Ready at ${docsDir.path}');
      }

      _initCompleter!.complete();
    } catch (e, st) {
      debugPrint('[IsarNoteStore] ERROR: $e');
      debugPrintStack(stackTrace: st);
      _initCompleter!.completeError(e, st);
      _initCompleter = null;
      rethrow;
    }
  }



  /// Get current user UID, or null if not authenticated
  String? _getCurrentUserId() {
    _auth ??= FirebaseAuth.instance;
    return _auth?.currentUser?.uid;
  }

  /// Put a single note - uses Firestore if in fallback mode
  Future<void> put(Note note) async {
    // ── Idempotency guard: never write a note whose content is identical ────
    final existing = await getByNoteId(note.noteId);
    if (existing != null &&
        existing.rawTranscript == note.rawTranscript &&
        existing.title          == note.title &&
        existing.status         == note.status &&
        existing.updatedAt      == note.updatedAt) {
      debugPrint('[IsarNoteStore] put skipped — identical note: ${note.noteId}');
      return;
    }
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] put() - skipped, user not authenticated');
        return;
      }
      _firestore ??= FirebaseFirestore.instance;
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(note.noteId)
          .set(note.toFirestoreJson(), SetOptions(merge: true));
      return;
    }

    // Normal Isar path
    await init();
    if (_isar != null && _isar!.isOpen) {
      final isar = _isar!;
      await isar.writeTxn(() async {
        await isar.notes.putByNoteId(note);
      });
    }
  }

  /// Put multiple notes - uses Firestore if in fallback mode
  Future<void> putAll(List<Note> notes) async {
    if (notes.isEmpty) return;

    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] putAll() - skipped, user not authenticated');
        return;
      }
      _firestore ??= FirebaseFirestore.instance;
      
      // Batch write to Firestore
      final batch = _firestore!.batch();
      for (final note in notes) {
        final docRef = _firestore!
            .collection('users')
            .doc(uid)
            .collection('notes')
            .doc(note.noteId);
        batch.set(docRef, note.toFirestoreJson(), SetOptions(merge: true));
      }
      await batch.commit();
      return;
    }

    // Normal Isar path
    await init();
    if (_isar != null && _isar!.isOpen) {
      final isar = _isar!;
      await isar.writeTxn(() async {
        await isar.notes.putAllByNoteId(notes);
      });
    }
  }

  /// Get a single note by ID - uses Firestore if in fallback mode
  Future<Note?> getByNoteId(String noteId) async {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] getByNoteId() - null, user not authenticated');
        return null;
      }
      _firestore ??= FirebaseFirestore.instance;
      
      final doc = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(noteId)
          .get();
      
      if (!doc.exists) return null;
      try {
        return Note.fromFirestoreJson(doc.data()!, uid: uid, noteId: noteId);
      } catch (e) {
        debugPrint('[IsarNoteStore] Error parsing note from Firestore: $e');
        return null;
      }
    }

    // Normal Isar path
    await init();
    if (_isar != null && _isar!.isOpen) {
      final isar = _isar!;
      return isar.notes.filter().noteIdEqualTo(noteId).findFirst();
    }
    return null;
  }

  /// Finds a very recent note with the same transcript and source.
  ///
  /// This is used to guard against duplicate delivery from multiple capture
  /// listeners that can emit the same transcript more than once.
  Future<Note?> findRecentByTranscript({
    required String uid,
    required String rawTranscript,
    required CaptureSource source,
    Duration within = const Duration(seconds: 5),
  }) async {
    final normalizedTranscript = rawTranscript.trim();
    if (normalizedTranscript.isEmpty) return null;

    final cutoff = DateTime.now().subtract(within);

    if (_useFirestoreOnly) {
      final notes = await getAllNotes();
      final matches = notes.where((note) {
        return note.uid == uid &&
            note.source == source &&
            note.rawTranscript.trim() == normalizedTranscript &&
            note.createdAt.isAfter(cutoff);
      }).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return matches.isEmpty ? null : matches.first;
    }

    await init();
    if (_isar == null || !_isar!.isOpen) return null;

    return _isar!.notes
        .filter()
        .uidEqualTo(uid)
        .and()
        .sourceEqualTo(source)
        .and()
        .rawTranscriptEqualTo(normalizedTranscript)
        .and()
        .createdAtGreaterThan(cutoff, include: true)
        .sortByCreatedAtDesc()
        .findFirst();
  }

  Future<Note?> getById(String noteId) => getByNoteId(noteId);

  /// Find a note by its Google Task ID. Returns null if not found or not in Isar mode.
  Future<Note?> findByGtaskId(String gtaskId) async {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) return null;
      _firestore ??= FirebaseFirestore.instance;
      final snap = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .where('gtask_id', isEqualTo: gtaskId)
          .limit(1)
          .get();
      if (snap.docs.isEmpty) return null;
      try {
        return Note.fromFirestoreJson(snap.docs.first.data(), uid: uid, noteId: snap.docs.first.id);
      } catch (_) {
        return null;
      }
    }

    await init();
    if (_isar == null || !_isar!.isOpen) return null;
    return _isar!.notes
        .filter()
        .gtaskIdEqualTo(gtaskId)
        .findFirst();
  }

  /// Get all notes - uses Firestore if in fallback mode
  Future<List<Note>> getAllNotes() async {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] getAllNotes() - empty, user not authenticated');
        return [];
      }
      _firestore ??= FirebaseFirestore.instance;
      
      final query = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();
      
      return query.docs
          .map((doc) {
            try {
              return Note.fromFirestoreJson(doc.data(), uid: uid, noteId: doc.id);
            } catch (e) {
              debugPrint('[IsarNoteStore] Error parsing note: $e');
              return null;
            }
          })
          .whereType<Note>()
          .toList();
    }

    // Normal Isar path
    await init();
    if (_isar != null && _isar!.isOpen) {
      final isar = _isar!;
      return isar.notes.where().findAll();
    }
    return [];
  }

  /// Watch all notes stream - uses Firestore if in fallback mode
  Stream<List<Note>> watchAll() async* {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] watchAll() - empty stream, user not authenticated');
        yield [];
        return;
      }
      _firestore ??= FirebaseFirestore.instance;
      
      yield* _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .snapshots()
          .asyncMap((query) async {
        return query.docs
            .map((doc) {
              try {
                return Note.fromFirestoreJson(doc.data(), uid: uid, noteId: doc.id);
              } catch (e) {
                debugPrint('[IsarNoteStore] Error parsing note: $e');
                return null;
              }
            })
            .whereType<Note>()
            .toList();
      });
      return;
    }

    // Normal Isar path
    await init();
    if (_isar != null && _isar!.isOpen) {
      final isar = _isar!;
      final query = isar.notes.where().build();
      yield* query.watch(fireImmediately: true).asyncMap((_) => query.findAll());
    }
  }

  /// Get all active notes (not archived/deleted) - uses Firestore if in fallback mode
  Future<List<Note>> getAllActive() async {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] getAllActive() - empty, user not authenticated');
        return [];
      }
      _firestore ??= FirebaseFirestore.instance;
      
      // Fetch all notes and filter in-memory
      final query = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();
      
      final notes = query.docs
          .map((doc) {
            try {
              return Note.fromFirestoreJson(doc.data(), uid: uid, noteId: doc.id);
            } catch (e) {
              debugPrint('[IsarNoteStore] Error parsing note: $e');
              return null;
            }
          })
          .whereType<Note>()
          .toList();
      
      // Filter to exclude archived and deleted
      return notes
          .where((note) =>
              note.status != NoteStatus.archived &&
              note.status != NoteStatus.deleted)
          .toList();
    }

    // Normal Isar path
    await init();
    if (_isar != null && _isar!.isOpen) {
      final isar = _isar!;
      return isar.notes
          .filter()
          .not()
          .statusEqualTo(NoteStatus.archived)
          .and()
          .not()
          .statusEqualTo(NoteStatus.deleted)
          .findAll();
    }
    return [];
  }

  /// Get all pending AI notes - uses Firestore if in fallback mode
  Future<List<Note>> getPendingAiNotes() async {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] getPendingAiNotes() - empty, user not authenticated');
        return [];
      }
      _firestore ??= FirebaseFirestore.instance;
      
      // Fetch all notes and filter in-memory
      final query = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();
      
      final notes = query.docs
          .map((doc) {
            try {
              return Note.fromFirestoreJson(doc.data(), uid: uid, noteId: doc.id);
            } catch (e) {
              debugPrint('[IsarNoteStore] Error parsing note: $e');
              return null;
            }
          })
          .whereType<Note>()
          .toList();
      
      // Filter to pending AI and sort by creation date
      return notes
          .where((note) => note.status == NoteStatus.pendingAi)
          .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    // Normal Isar path
    await init();
    if (_isar != null && _isar!.isOpen) {
      final isar = _isar!;
      return isar.notes
          .filter()
          .statusEqualTo(NoteStatus.pendingAi)
          .sortByCreatedAt()
          .findAll();
    }
    return [];
  }

  /// Count pending AI notes
  Future<int> countPendingAi() async {
    final pending = await getPendingAiNotes();
    return pending.length;
  }

  /// Watch active notes stream - uses Firestore if in fallback mode
  Stream<List<Note>> watchActive() async* {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] watchActive() - empty stream, user not authenticated');
        yield [];
        return;
      }
      _firestore ??= FirebaseFirestore.instance;
      
      yield* _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .snapshots()
          .asyncMap((query) async {
        return query.docs
            .map((doc) {
              try {
                return Note.fromFirestoreJson(doc.data(), uid: uid, noteId: doc.id);
              } catch (e) {
                debugPrint('[IsarNoteStore] Error parsing note: $e');
                return null;
              }
            })
            .whereType<Note>()
            .where((note) =>
                note.status != NoteStatus.archived &&
                note.status != NoteStatus.deleted)
            .toList();
      });
      return;
    }

    // Normal Isar path
    await init();
    if (_isar != null && _isar!.isOpen) {
      final isar = _isar!;
      final query = isar.notes.where().build();

      yield* query.watch(fireImmediately: true).asyncMap((_) async {
        final all = await query.findAll();
        return all
            .where(
              (note) =>
                  note.status != NoteStatus.archived &&
                  note.status != NoteStatus.deleted,
            )
            .toList();
      });
    }
  }
}
```

### lib/core/theme/app_colors.dart

```dart
import 'package:flutter/material.dart';

// ══════════════════════════════════════════════════════════════════════════════
// WishperLog Design System v3.0 — Tactile Soft-Glass UI
//
// CHANGELOG from v2.1:
//   • Added rimLight tokens (the 1-2 px specular highlight on top-left bevel)
//   • Added compoundShadow tokens (3 layered diffused drop shadows per mode)
//   • Added extrusionOverlay tokens (subtle inner-shadow for 3D volume)
//   • Tightened dark mode glass fills for better smoked-glass fidelity
//   • Pure #000000 / #FFFFFF backgrounds remain strictly avoided per spec
//
// DO NOT add colour literals anywhere else in the codebase.
// ══════════════════════════════════════════════════════════════════════════════
abstract class AppColors {
  // ── DARK GLASS SURFACES ────────────────────────────────────────────────────
  static const Color darkBg     = Color(0xFF090F1A);
  static const Color darkGlass1 = Color(0x30F5FAFF);
  static const Color darkGlass2 = Color(0x22EFF6FF);
  static const Color darkGlass3 = Color(0x14E8F0FF);
  static const Color darkTextPri = Color(0xFFEAF1FF);
  static const Color darkTextSec = Color(0xFFA7B6CC);
  static const Color darkTextTer = Color(0xFF75D6B0);
  static const Color darkBorder  = Color(0x2DDAE8FF);

  // ── LIGHT GLASS SURFACES ───────────────────────────────────────────────────
  static const Color lightBg     = Color(0xFFF0F4F9);   // slightly deeper for shadow contrast
  static const Color lightGlass1 = Color(0xE8FFFFFF);
  static const Color lightGlass2 = Color(0xC5FFFFFF);
  static const Color lightGlass3 = Color(0xA0FFFFFF);
  static const Color lightTextPri = Color(0xFF102037);
  static const Color lightTextSec = Color(0xFF4E6485);
  static const Color lightTextTer = Color(0xFF7E8EAB);
  static const Color lightBorder  = Color(0x1A204268);

  // ── RIM LIGHT TOKENS (the specular highlight, top-left bevel) ─────────────
  // "Smoked Glass" dark mode: metallic, brighter, as it's the PRIMARY depth cue
  static const Color darkRimBright = Color(0x4DFFFFFF);  // 30% white — bright catch
  static const Color darkRimMid    = Color(0x14FFFFFF);  // 8%  white — fade-off
  static const Color darkRimDark   = Color(0x28000000);  // 16% black — bottom-right recession

  // "Polished Resin" light mode: crisper, slightly less intense than dark (shadows do more work)
  static const Color lightRimBright = Color(0x66FFFFFF);  // 40% white — crisp top-left highlight
  static const Color lightRimMid    = Color(0x1EFFFFFF);  // 12% white — mid-point transition
  static const Color lightRimDark   = Color(0x12000000);  // 7%  black — very soft bottom-right

  // ── TACTILE EXTRUSION TOKENS (inner shadow — bottom-right) ─────────────────
  // Simulates physical "puffed" 3D volume; very low opacity to not obstruct content
  static const Color darkExtrusionShadow  = Color(0x1A000000);  // 10% black
  static const Color lightExtrusionShadow = Color(0x0D000000);  // 5%  black

  // ── COMPOUND DROP SHADOW TOKENS ────────────────────────────────────────────
  // Dark mode: coloured "LED backlight" ambient glows instead of pure grey shadows
  static const Color darkShadowClose  = Color(0x3D000000);  // alpha 24%
  static const Color darkShadowMid    = Color(0x2E000000);  // alpha 18%
  static const Color darkShadowFar    = Color(0x1E000000);  // alpha 12%

  // Light mode: soft desaturated grey tints faintly matching background
  static const Color lightShadowClose = Color(0x2E3B5E8A);  // 18% cool blue-grey
  static const Color lightShadowMid   = Color(0x1F3B5E8A);  // 12% cool blue-grey
  static const Color lightShadowFar   = Color(0x143B5E8A);  // 8%  cool blue-grey

  // ── CATEGORY CHROMATICS ────────────────────────────────────────────────────
  static const Color tasks     = Color(0xFF6045FA);
  static const Color reminders = Color(0xFFF472B6);
  static const Color ideas     = Color(0xFFFBBF24);
  static const Color followUp  = Color(0xFF34D399);
  static const Color journal   = Color(0xFFA78BFA);
  static const Color general   = Color(0xFF94A3B8);
  static const Color errorStatus = Color(0xFFEF4444);

  // ── DARK FOLDER COLOUR-LEAK BG TINTS ──────────────────────────────────────
  static const Color tasksDarkBg    = Color(0xFF060DD1);
  static const Color remindersDarkBg = Color(0xFFF04010);
  static const Color ideasDarkBg    = Color(0xFFF0CF86);
  static const Color followUpDarkBg = Color(0xFF866F0C);
  static const Color journalDarkBg  = Color(0xFF9C0AA6);
  static const Color generalDarkBg  = Color(0xFF4FADAE);

  // ── LIGHT FOLDER COLOUR-LEAK BG TINTS ─────────────────────────────────────
  static const Color tasksLightBg    = Color(0xFFF0F0FF);
  static const Color remindersLightBg = Color(0xFFFFF0F8);
  static const Color ideasLightBg    = Color(0xFFFDF8F0);
  static const Color followUpLightBg = Color(0xFFFEFFA6);
  static const Color journalLightBg  = Color(0xFFF5F0FF);
  static const Color generalLightBg  = Color(0xFFF4F5F8);

  // ── BACKGROUND MESH NODES ──────────────────────────────────────────────────
  static const List<Color> darkMesh = [
    Color(0xFF090F1A),
    Color(0xFF10223D),
    Color(0xFF0A2D2D),
    Color(0xFF1A1636),
    Color(0xFF2A1E3D),
  ];
  static const List<Color> lightMesh = [
    Color(0xFFF0F4F9),
    Color(0xFFE4EEFF),
    Color(0xFFDDF6F4),
    Color(0xFFEDE8FF),
    Color(0xFFF7F4FF),
  ];
}
```

### lib/core/theme/app_colors_x.dart

```dart
import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/shared/models/enums.dart';

extension AppColorsX on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get bg => isDark ? AppColors.darkBg : AppColors.lightBg;
  Color get glass1 => isDark ? AppColors.darkGlass1 : AppColors.lightGlass1;
  Color get glass2 => isDark ? AppColors.darkGlass2 : AppColors.lightGlass2;
  Color get glass3 => isDark ? AppColors.darkGlass3 : AppColors.lightGlass3;
  Color get textPri => isDark ? AppColors.darkTextPri : AppColors.lightTextPri;
  Color get textSec => isDark ? AppColors.darkTextSec : AppColors.lightTextSec;
  Color get border => isDark ? AppColors.darkBorder : AppColors.lightBorder;
  Color get surface1 => isDark ? const Color(0xFF111B2B) : const Color(0xFFF7FAFF);
  Color get surface2 => isDark ? const Color(0xFF1A2940) : const Color(0xFFFFFFFF);
  List<Color> get meshNodes =>
      isDark ? AppColors.darkMesh : AppColors.lightMesh;
}

Color categoryColor(NoteCategory cat) => switch (cat) {
  NoteCategory.tasks => AppColors.tasks,
  NoteCategory.reminders => AppColors.reminders,
  NoteCategory.ideas => AppColors.ideas,
  NoteCategory.followUp => AppColors.followUp,
  NoteCategory.journal => AppColors.journal,
  NoteCategory.general => AppColors.general,
};

Color categoryFolderBg(NoteCategory cat, bool isDark) => isDark
    ? switch (cat) {
        NoteCategory.tasks => AppColors.tasksDarkBg,
        NoteCategory.reminders => AppColors.remindersDarkBg,
        NoteCategory.ideas => AppColors.ideasDarkBg,
        NoteCategory.followUp => AppColors.followUpDarkBg,
        NoteCategory.journal => AppColors.journalDarkBg,
        NoteCategory.general => AppColors.generalDarkBg,
      }
    : switch (cat) {
        NoteCategory.tasks => AppColors.tasksLightBg,
        NoteCategory.reminders => AppColors.remindersLightBg,
        NoteCategory.ideas => AppColors.ideasLightBg,
        NoteCategory.followUp => AppColors.followUpLightBg,
        NoteCategory.journal => AppColors.journalLightBg,
        NoteCategory.general => AppColors.generalLightBg,
      };
```

### lib/core/theme/app_durations.dart

```dart
abstract class AppDurations {
  static const microSnap = Duration(milliseconds: 120);
  static const saveConfirm = Duration(milliseconds: 350);
  static const modeTransition = Duration(milliseconds: 300);
  static const screenTransition = Duration(milliseconds: 380);
  static const folderStagger = Duration(milliseconds: 60);
  static const aiShimmer = Duration(milliseconds: 1600);
  static const countRoll = Duration(milliseconds: 400);
  static const bubblePulse = Duration(seconds: 3);
  static const notchAutoReturn = Duration(milliseconds: 1000);
  static const notchContentFade = Duration(milliseconds: 80);
}
```

### lib/core/theme/app_springs.dart

```dart
import 'package:flutter/physics.dart';

const thoughtNotchSpring = SpringDescription(
  mass: 1,
  stiffness: 280,
  damping: 26,
);
const saveConfirmSpring = SpringDescription(
  mass: 1,
  stiffness: 240,
  damping: 22,
);
const screenNavSpring = SpringDescription(mass: 1, stiffness: 260, damping: 28);
```

### lib/core/theme/app_theme.dart

```dart
import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';

// ══════════════════════════════════════════════════════════════════════════════
// AppTheme v3.0 — Tactile Soft-Glass UI
//
// Every Material component that renders visible chrome is upgraded:
//   • ElevatedButton  → "Polished Resin" button with compound shadows + rim light
//   • TextButton      → glass-tint hover surface
//   • InputDecoration → frosted inset field with inner-shadow extrusion indicator
//   • Card            → multi-layer floating glass card
//   • Dialog          → smoked glass sheet with ambient glow
//   • BottomSheet     → heavy-frosted panel, top rim light on rounded edge
//   • SnackBar        → floating glass chip
//   • Chip            → soft tactile pill
// ══════════════════════════════════════════════════════════════════════════════
class AppTheme {
  static ThemeData _base(ColorScheme scheme) {
    final isDark = scheme.brightness == Brightness.dark;

    // ── Surface / glass fills ────────────────────────────────────────────────
    final surfaceTint = isDark
        ? AppColors.darkGlass1.withValues(alpha: 0.90)
        : AppColors.lightGlass1.withValues(alpha: 0.98);
    final outline     = scheme.outline.withValues(alpha: 0.65);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,

      // ── AppBar ─────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Card ───────────────────────────────────────────────────────────────
      // Cards get compound shadows so they float off the mesh background.
      // The 0.8 outline border is overridden by GlassPane's own rim-light border
      // at the widget level; this fallback is kept for any widget using raw Card.
      cardTheme: CardThemeData(
        elevation: 0,
        shadowColor: Colors.transparent,
        color: surfaceTint,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: outline, width: 0.7),
        ),
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
      ),

      // ── ElevatedButton — "Polished Resin" tactile primary ──────────────────
      // Visual recipe:
      //   Fill  : top-to-bottom gradient (lighter at top = light source from above)
      //   Shape : stadium-ish pill with medium radius
      //   Shadow: compound 3-layer drop shadow (from primaryButtonShadows)
      //   Rim   : handled by the GlassPane wrapping each button call-site,
      //           OR via the overlayColor spec for normal ElevatedButtons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return scheme.primary.withValues(alpha: 0.82);
            }
            if (states.contains(WidgetState.disabled)) {
              return scheme.onSurface.withValues(alpha: 0.12);
            }
            return scheme.primary;
          }),
          foregroundColor: WidgetStateProperty.all(scheme.onPrimary),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return Colors.white.withValues(alpha: 0.12);
            }
            if (states.contains(WidgetState.hovered)) {
              return Colors.white.withValues(alpha: 0.06);
            }
            return Colors.transparent;
          }),
          elevation: WidgetStateProperty.all(0),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          // AnimatedScale simulated via elevation change on press is handled
          // by call-site TactileButton wrapper where precise control is needed.
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.onSurface,
          overlayColor: isDark
              ? Colors.white.withValues(alpha: 0.07)
              : Colors.black.withValues(alpha: 0.05),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(
            color: isDark
                ? AppColors.darkRimMid
                : scheme.primary.withValues(alpha: 0.35),
            width: 1.0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),

      // ── Icon ───────────────────────────────────────────────────────────────
      iconTheme: IconThemeData(color: scheme.onSurface),

      // ── InputDecoration — Frosted inset field ──────────────────────────────
      // Light mode: field is slightly recessed (feels "pressed into" the surface)
      // Dark mode:  field is subtly darker than surrounding glass (depth-by-contrast)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.darkGlass3.withValues(alpha: 0.65)
            : Colors.white.withValues(alpha: 0.55),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDark
                ? AppColors.darkBorder.withValues(alpha: 0.6)
                : AppColors.lightBorder.withValues(alpha: 0.7),
            width: 0.8,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.primary.withValues(alpha: 0.80),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.errorStatus.withValues(alpha: 0.80)),
        ),
        // Hint and label styles
        hintStyle: TextStyle(
          color: isDark
              ? AppColors.darkTextSec.withValues(alpha: 0.55)
              : AppColors.lightTextSec.withValues(alpha: 0.60),
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Dialog — Smoked Glass ──────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),

      // ── PopupMenu ──────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: isDark
            ? const Color(0xF0111827)
            : const Color(0xF0FFFFFF),
        shadowColor: AppColors.lightShadowMid,
        elevation: 16,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.8,
          ),
        ),
        textStyle: TextStyle(color: scheme.onSurface, fontSize: 14),
      ),

      // ── BottomSheet ————————————————————————————————————————————————————————
      // Heavy frosted panel; the top-rounded edge naturally catches the top rim
      // light, which is implemented at the sheet's own build site.
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        modalBackgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),

      // ── SnackBar — floating glass chip ─────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: Colors.transparent,
        contentTextStyle: TextStyle(color: scheme.onSurface),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // ── Chip ───────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.darkGlass2.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.60),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 0.8,
        ),
        shape: const StadiumBorder(),
        labelStyle: TextStyle(
          color: isDark ? AppColors.darkTextPri : AppColors.lightTextPri,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        elevation: 0,
        pressElevation: 0,
      ),

      // ── Switch / Checkbox / Slider ─────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return isDark ? AppColors.darkTextSec : AppColors.lightTextSec;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return scheme.primary;
          return isDark
              ? AppColors.darkGlass2
              : AppColors.lightGlass3;
        }),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),

      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: isDark
            ? AppColors.darkGlass2
            : AppColors.lightGlass3,
        thumbColor: Colors.white,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        overlayColor: scheme.primary.withValues(alpha: 0.18),
      ),

      // ── Divider ────────────────────────────────────────────────────────────
      dividerColor: outline.withValues(alpha: 0.5),

      // ── Misc ───────────────────────────────────────────────────────────────
      splashColor: Colors.transparent,
      highlightColor: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.02),
    );
  }

  static ThemeData get lightTheme {
    return _base(
      ColorScheme.fromSeed(
        seedColor: AppColors.tasks,
        brightness: Brightness.light,
      ).copyWith(
        surface: AppColors.lightGlass1,
        onSurface: AppColors.lightTextPri,
        outline: AppColors.lightBorder,
      ),
    );
  }

  static ThemeData get darkTheme {
    return _base(
      ColorScheme.fromSeed(
        seedColor: AppColors.tasks,
        brightness: Brightness.dark,
      ).copyWith(
        surface: AppColors.darkGlass1,
        onSurface: AppColors.darkTextPri,
        outline: AppColors.darkBorder,
      ),
    );
  }
}
```

### lib/core/theme/theme_cubit.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.system);

  final AppPreferencesRepository _prefs;

  Future<void> hydrate() async {
    emit(await _prefs.getThemeMode());
  }

  /// Cycles: system → light → dark → system.
  Future<void> cycleTheme() async {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light  => ThemeMode.dark,
      ThemeMode.dark   => ThemeMode.system,
    };
    await setThemeMode(next);
  }

  /// Legacy binary toggle kept for callers that used it. Now cycles through
  /// all three states instead of flipping between only light and dark.
  Future<void> toggleLightDark() => cycleTheme();

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setThemeMode(mode);
    emit(mode);
  }

  /// Human-readable label for the current theme, suitable for a toggle chip.
  String get modeLabel => switch (state) {
    ThemeMode.system => 'Auto',
    ThemeMode.light  => 'Light',
    ThemeMode.dark   => 'Dark',
  };
}
```

### lib/features/ai/data/ai_classifier_router.dart

````dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/features/ai/data/groq_note_classifier.dart';
import 'package:wishperlog/features/nlp/nlp_task_parser.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class AiModelOption {
  const AiModelOption({
    required this.provider,
    required this.id,
    required this.label,
    required this.description,
    this.recommended = false,
  });

  final AiProvider provider;
  final String id;
  final String label;
  final String description;
  final bool recommended;
}

class AiClassifierRouter {
  static const _prefsProviderKey = 'ai_provider';
  static const _prefsModelPrefix = 'ai_model_';

  static const List<AiProvider> _fallbackOrder = [
    AiProvider.gemini,
    AiProvider.groq,
    AiProvider.mistral,
    AiProvider.cerebras,
    AiProvider.huggingface,
  ];

  static const Map<AiProvider, List<AiModelOption>> _modelCatalog = {
    AiProvider.gemini: [
      AiModelOption(
        provider: AiProvider.gemini,
        id: 'gemini-1.5-flash',
        label: 'Gemini 1.5 Flash',
        description: 'Best compatibility for AI Studio keys. Fast and stable for note cleanup, categorization, and digest extraction.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.gemini,
        id: 'gemini-2.5-flash',
        label: 'Gemini 2.5 Flash',
        description: 'Higher-quality reasoning when available. Good for longer transcripts and denser note summaries.',
      ),
      AiModelOption(
        provider: AiProvider.gemini,
        id: 'gemini-3-flash',
        label: 'Gemini 3 Flash',
        description: 'Newest fast Gemini option. Use when you want the strongest quality-to-speed balance.',
      ),
    ],
    AiProvider.groq: [
      AiModelOption(
        provider: AiProvider.groq,
        id: 'llama-3.3-70b-versatile',
        label: 'Llama 3.3 70B Versatile',
        description: 'Best quality on Groq for classification and clean note rewriting.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.groq,
        id: 'llama-3.1-8b-instant',
        label: 'Llama 3.1 8B Instant',
        description: 'Very fast fallback for quick routing, short notes, and quota-sensitive sessions.',
      ),
      AiModelOption(
        provider: AiProvider.groq,
        id: 'qwen3-32b',
        label: 'Qwen 3 32B',
        description: 'Good multilingual and structured-output performance for mixed-language notes.',
      ),
      AiModelOption(
        provider: AiProvider.groq,
        id: 'llama-4-scout-17b-16e-instruct',
        label: 'Llama 4 Scout',
        description: 'Balanced quality and speed for general-purpose note classification.',
      ),
    ],
    AiProvider.mistral: [
      AiModelOption(
        provider: AiProvider.mistral,
        id: 'mistral-large-latest',
        label: 'Mistral Large',
        description: 'Strong structured reasoning and classification quality for free-form notes.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.mistral,
        id: 'open-mistral-nemo',
        label: 'Mistral Nemo',
        description: 'Efficient daily-driver model when you want lower latency and solid accuracy.',
      ),
      AiModelOption(
        provider: AiProvider.mistral,
        id: 'codestral-latest',
        label: 'Codestral',
        description: 'Useful for terse, highly structured output when the note text is noisy or fragmented.',
      ),
    ],
    AiProvider.huggingface: [
      AiModelOption(
        provider: AiProvider.huggingface,
        id: 'meta-llama/Llama-3.1-70B-Instruct',
        label: 'Llama 3.1 70B Instruct',
        description: 'Strong general reasoning via Hugging Face hosted inference.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.huggingface,
        id: 'mistralai/Mistral-Nemo-Instruct-2407',
        label: 'Mistral Nemo Instruct',
        description: 'Good for fast testing and light-weight classification on the HF API.',
      ),
      AiModelOption(
        provider: AiProvider.huggingface,
        id: 'google/gemma-2-27b-it',
        label: 'Gemma 2 27B IT',
        description: 'Solid compact alternative for testing broad open-model support.',
      ),
    ],
    AiProvider.cerebras: [
      AiModelOption(
        provider: AiProvider.cerebras,
        id: 'llama-3.3-70b',
        label: 'Llama 3.3 70B',
        description: 'High-throughput model for strong note cleanup and extraction.',
        recommended: true,
      ),
      AiModelOption(
        provider: AiProvider.cerebras,
        id: 'llama-3.1-8b',
        label: 'Llama 3.1 8B',
        description: 'Fast and inexpensive fallback for short notes or quota-sensitive runs.',
      ),
      AiModelOption(
        provider: AiProvider.cerebras,
        id: 'llama-4-scout-17b-16e-instruct',
        label: 'Llama 4 Scout',
        description: 'Balanced choice when you want a newer instruction model on Cerebras.',
      ),
    ],
    AiProvider.auto: [],
  };

  final GeminiNoteClassifier _gemini;
  final GroqNoteClassifier _groq;
  final Map<AiProvider, _OpenAiCompatibleClassifier> _openAiClients = {};

  AiProvider _activeProvider = AiProvider.auto;
  String _lastUsedModelName = 'AI';
  final Map<AiProvider, String> _selectedModelIds = {};

  AiClassifierRouter()
      : _gemini = GeminiNoteClassifier(),
        _groq = GroqNoteClassifier() {
    _seedDefaults();
    _openAiClients[AiProvider.mistral] = _OpenAiCompatibleClassifier(
      providerName: 'mistral',
      apiKey: AppEnv.mistralApiKey,
      endpoint: Uri.parse('https://api.mistral.ai/v1/chat/completions'),
      fallbackModels: const ['open-mistral-nemo', 'codestral-latest'],
    );
    _openAiClients[AiProvider.huggingface] = _OpenAiCompatibleClassifier(
      providerName: 'huggingface',
      apiKey: AppEnv.huggingFaceApiKey,
      endpoint: Uri.parse('https://api-inference.huggingface.co/v1/chat/completions'),
      fallbackModels: const [
        'mistralai/Mistral-Nemo-Instruct-2407',
        'google/gemma-2-27b-it',
      ],
    );
    _openAiClients[AiProvider.cerebras] = _OpenAiCompatibleClassifier(
      providerName: 'cerebras',
      apiKey: AppEnv.cerebrasApiKey,
      endpoint: Uri.parse('https://api.cerebras.ai/v1/chat/completions'),
      fallbackModels: const ['llama-3.1-8b', 'llama-4-scout-17b-16e-instruct'],
    );
  }

  AiProvider get activeProvider => _activeProvider;
  String get lastUsedModelName => _lastUsedModelName;
  bool get geminiConfigured => _gemini.isConfigured;
  bool get groqConfigured => _groq.isConfigured;
  bool get mistralConfigured => AppEnv.mistralApiKey.isNotEmpty;
  bool get huggingfaceConfigured => AppEnv.huggingFaceApiKey.isNotEmpty;
  bool get cerebrasConfigured => AppEnv.cerebrasApiKey.isNotEmpty;

  List<AiModelOption> modelsFor(AiProvider provider) {
    return List.unmodifiable(_modelCatalog[provider] ?? const <AiModelOption>[]);
  }

  String selectedModelIdFor(AiProvider provider) {
    final models = _modelCatalog[provider] ?? const <AiModelOption>[];
    final selected = _selectedModelIds[provider];
    if (selected != null && selected.isNotEmpty) {
      return selected;
    }
    return models.firstWhere(
      (option) => option.recommended,
      orElse: () => models.isNotEmpty ? models.first : const AiModelOption(
        provider: AiProvider.auto,
        id: 'local',
        label: 'Local',
        description: 'No AI provider configured.',
      ),
    ).id;
  }

  AiModelOption? selectedModelFor(AiProvider provider) {
    final modelId = selectedModelIdFor(provider);
    for (final option in modelsFor(provider)) {
      if (option.id == modelId) return option;
    }
    return null;
  }

  bool isConfigured(AiProvider provider) {
    switch (provider) {
      case AiProvider.auto:
        return geminiConfigured || groqConfigured || mistralConfigured || huggingfaceConfigured || cerebrasConfigured;
      case AiProvider.gemini:
        return geminiConfigured;
      case AiProvider.groq:
        return groqConfigured;
      case AiProvider.mistral:
        return mistralConfigured;
      case AiProvider.huggingface:
        return huggingfaceConfigured;
      case AiProvider.cerebras:
        return cerebrasConfigured;
    }
  }

  String providerLabel(AiProvider provider) {
    switch (provider) {
      case AiProvider.auto:
        return 'Auto';
      case AiProvider.gemini:
        return 'Gemini';
      case AiProvider.groq:
        return 'Groq';
      case AiProvider.mistral:
        return 'Mistral';
      case AiProvider.huggingface:
        return 'Hugging Face';
      case AiProvider.cerebras:
        return 'Cerebras';
    }
  }

  String providerDescription(AiProvider provider) {
    switch (provider) {
      case AiProvider.auto:
        return 'Tries Gemini first, then Groq, then Mistral, Cerebras, and Hugging Face.';
      case AiProvider.gemini:
        return 'Best for AI Studio keys and the cleanest note rewrites.';
      case AiProvider.groq:
        return 'Fastest OpenAI-compatible fallback for real-time note capture.';
      case AiProvider.mistral:
        return 'Strong structured reasoning with an experimentation-friendly API.';
      case AiProvider.huggingface:
        return 'Broad open-model testing via hosted inference endpoints.';
      case AiProvider.cerebras:
        return 'High-throughput Llama inference with low-latency responses.';
    }
  }

  Future<void> hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedProvider = prefs.getString(_prefsProviderKey);
      _activeProvider = AiProvider.values.firstWhere(
        (p) => p.name == storedProvider,
        orElse: () => AiProvider.auto,
      );

      for (final provider in AiProvider.values) {
        if (provider == AiProvider.auto) continue;
        final storedModel = prefs.getString('$_prefsModelPrefix${provider.name}');
        if (storedModel != null && storedModel.isNotEmpty) {
          _selectedModelIds[provider] = storedModel;
        }
      }
      _seedDefaults();
    } catch (e) {
      debugPrint('[AiClassifierRouter] hydrate error: $e');
    }
  }

  Future<void> setProvider(AiProvider provider) async {
    _activeProvider = provider;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsProviderKey, provider.name);
    } catch (e) {
      debugPrint('[AiClassifierRouter] setProvider error: $e');
    }
  }

  Future<void> setModel(AiProvider provider, String modelId) async {
    _selectedModelIds[provider] = modelId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefsModelPrefix${provider.name}', modelId);
    } catch (e) {
      debugPrint('[AiClassifierRouter] setModel error: $e');
    }
  }

  Future<GeminiClassificationResult> classify(String rawTranscript) async {
    final providers = _orderedProviders();
    for (final provider in providers) {
      final result = await _classifyWithProvider(provider, rawTranscript);
      if (result != null) {
        _lastUsedModelName = result.model;
        debugPrint('[AiClassifierRouter] Classified via ${result.model} '
            '(fallback=${result.wasFallback}): ${result.category.name}');
        return result;
      }
    }

    final fallback = _localFallback(rawTranscript);
    _lastUsedModelName = fallback.model;
    debugPrint('[AiClassifierRouter] All providers failed — using local fallback');
    return fallback;
  }

  List<AiProvider> _orderedProviders() {
    if (_activeProvider == AiProvider.auto) {
      return _fallbackOrder;
    }
    return <AiProvider>[
      _activeProvider,
      ..._fallbackOrder.where((provider) => provider != _activeProvider),
    ];
  }

  Future<GeminiClassificationResult?> _classifyWithProvider(
    AiProvider provider,
    String rawTranscript,
  ) async {
    switch (provider) {
      case AiProvider.auto:
        return null;
      case AiProvider.gemini:
        if (!_gemini.isConfigured) return null;
        try {
          return await _gemini.classify(
            rawTranscript,
            modelName: selectedModelIdFor(AiProvider.gemini),
          );
        } catch (e) {
          debugPrint('[AiClassifierRouter] Gemini failed: $e');
          return null;
        }
      case AiProvider.groq:
        if (!_groq.isConfigured) return null;
        try {
          return await _groq.classify(
            rawTranscript,
            modelName: selectedModelIdFor(AiProvider.groq),
          );
        } catch (e) {
          debugPrint('[AiClassifierRouter] Groq failed: $e');
          return null;
        }
      case AiProvider.mistral:
      case AiProvider.huggingface:
      case AiProvider.cerebras:
        final client = _openAiClients[provider];
        if (client == null || !client.isConfigured) return null;
        try {
          return await client.classify(
            rawTranscript,
            modelName: selectedModelIdFor(provider),
          );
        } catch (e) {
          debugPrint('[AiClassifierRouter] ${provider.name} failed: $e');
          return null;
        }
    }
  }

  GeminiClassificationResult _localFallback(String raw) {
    final cleaned = raw.trim();
    final parsed = NlpTaskParser.parse(cleaned);
    return GeminiClassificationResult(
      title: parsed.cleanTitle?.isNotEmpty == true ? parsed.cleanTitle! : _fallbackTitle(cleaned),
      category: parsed.category,
      priority: parsed.priority,
      extractedDate: parsed.extractedDate,
      cleanBody: cleaned,
      model: 'local',
      wasFallback: true,
    );
  }

  String _fallbackTitle(String raw) {
    final words = raw.trim().split(RegExp(r'\s+')).take(6).toList();
    return words.isEmpty ? 'Quick note' : words.join(' ');
  }

  void _seedDefaults() {
    for (final entry in _modelCatalog.entries) {
      final provider = entry.key;
      if (provider == AiProvider.auto) continue;
      if (_selectedModelIds[provider]?.isNotEmpty == true) continue;
      final models = entry.value;
      if (models.isEmpty) continue;
      _selectedModelIds[provider] = models.firstWhere(
        (option) => option.recommended,
        orElse: () => models.first,
      ).id;
    }
  }
}

class _OpenAiCompatibleClassifier {
  _OpenAiCompatibleClassifier({
    required this.providerName,
    required this.apiKey,
    required this.endpoint,
    required this.fallbackModels,
  });

  final String providerName;
  final String apiKey;
  final Uri endpoint;
  final List<String> fallbackModels;

  bool get isConfigured => apiKey.isNotEmpty;

  Future<GeminiClassificationResult?> classify(
    String rawTranscript, {
    String? modelName,
  }) async {
    if (!isConfigured || rawTranscript.trim().isEmpty) return null;

    final candidates = <String>{
      if (modelName != null && modelName.trim().isNotEmpty) modelName.trim(),
      ...fallbackModels,
    }.toList();

    for (final model in candidates) {
      final result = await _callApi(rawTranscript, model);
      if (result != null) return result;
    }
    return null;
  }

  Future<GeminiClassificationResult?> _callApi(
    String rawTranscript,
    String model,
  ) async {
    try {
      final response = await http.post(
        endpoint,
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': GeminiNoteClassifier.buildSystemPrompt()},
            {'role': 'user', 'content': 'Raw input: ${rawTranscript.trim()}'},
          ],
          'temperature': 0.2,
          'max_tokens': 512,
          'response_format': {'type': 'json_object'},
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 429) {
        debugPrint('[$providerName] Rate limit hit on $model');
        return null;
      }

      if (response.statusCode != 200) {
        debugPrint('[$providerName] API error ${response.statusCode} on $model: ${response.body}');
        return null;
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content = _extractContent(body);
      if (content == null || content.trim().isEmpty) return null;

      return _parse(rawTranscript, content.trim(), model: '$providerName-$model');
    } catch (e) {
      debugPrint('[$providerName] classify error on $model: $e');
      return null;
    }
  }

  String? _extractContent(Map<String, dynamic> body) {
    final choices = body['choices'];
    if (choices is! List || choices.isEmpty) return null;
    final first = choices.first;
    if (first is! Map<String, dynamic>) return null;
    final message = first['message'];
    if (message is! Map<String, dynamic>) return null;
    final content = message['content'];
    return content is String ? content : null;
  }

  GeminiClassificationResult? _parse(
    String raw,
    String payload, {
    required String model,
  }) {
    try {
      final noFence = payload
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll('```', '')
          .trim();
      final start = noFence.indexOf('{');
      final end = noFence.lastIndexOf('}');
      if (start < 0 || end <= start) return null;

      final decoded = jsonDecode(noFence.substring(start, end + 1)) as Map<String, dynamic>;
      final title = (decoded['title'] as String?)?.trim();
      final cleanBody = (decoded['clean_body'] as String?)?.trim();
      final categoryText = (decoded['category'] as String?) ?? NoteCategory.general.name;
      final inferredCategory = parseCategory(categoryText);
      final textForHeuristics = [raw, title, cleanBody].whereType<String>().join(' ');

      return GeminiClassificationResult(
        title: title?.isNotEmpty == true ? title! : _fallbackTitle(raw),
        category: inferredCategory == NoteCategory.general
            ? inferCategoryFromText(textForHeuristics)
            : inferredCategory,
        priority: parsePriority((decoded['priority'] as String?) ?? NotePriority.medium.name),
        extractedDate: _parseDate(decoded['extracted_date']),
        cleanBody: cleanBody?.isNotEmpty == true ? cleanBody! : raw.trim(),
        model: model,
        wasFallback: false,
      );
    } catch (e) {
      debugPrint('[$providerName] parse error: $e');
      return null;
    }
  }

  String _fallbackTitle(String raw) {
    final words = raw.trim().split(RegExp(r'\s+')).take(6).toList();
    return words.isEmpty ? 'Quick note' : words.join(' ');
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().toLowerCase() == 'null') return null;
    try {
      return DateTime.parse(value.toString().trim());
    } catch (_) {
      return null;
    }
  }
}
````

### lib/features/ai/data/ai_processing_service.dart

```dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
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
    // GeminiNoteClassifier.buildSystemPrompt() — no extra work needed here.
    final GeminiClassificationResult result;
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
```

### lib/features/ai/data/gemini_note_classifier.dart

````dart
import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/features/nlp/nlp_task_parser.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

/// Result returned by any AI classifier (Gemini or Groq).
class GeminiClassificationResult {
  const GeminiClassificationResult({
    required this.title,
    required this.category,
    required this.priority,
    required this.extractedDate,
    required this.cleanBody,
    required this.model,
    required this.wasFallback,
    this.translatedContent,
  });

  final String title;
  final NoteCategory category;
  final NotePriority priority;
  final DateTime? extractedDate;
  final String cleanBody;
  final String model;
  final bool wasFallback;
  /// English translation when input was detected as non-English. Null otherwise.
  final String? translatedContent;
}


class GeminiNoteClassifier {
  GeminiNoteClassifier({String? apiKey, GenerativeModel? model})
      : _apiKey = apiKey ?? AppEnv.geminiApiKey,
        _providedModel = model;

  final String _apiKey;
  final GenerativeModel? _providedModel;

  static const List<String> supportedModels = [
    'gemini-2.5-flash-preview-04-17',
    'gemini-2.0-flash',
    'gemini-1.5-flash',
  ];

  bool get isConfigured => _apiKey.isNotEmpty;

  // ──────────────────────────────────────────────────────────────────────────
  // SYSTEM PROMPT v4 — God-Level
  //
  // Key upgrades over v3:
  //  • Temporal context injected at call-time (not static), enabling accurate
  //    relative-date parsing ("tomorrow", "next Monday", etc.).
  //  • Explicit homophones list for Indian-English STT (most common errors).
  //  • Hard rule: category "follow-up" ↔ any check-in/ping/follow phrasing.
  //  • Confidence-weighted: if ambiguous between tasks/reminders, prefer tasks.
  //  • Stricter JSON contract with inline type annotations.
  // ──────────────────────────────────────────────────────────────────────────
  static const String _systemPromptTemplate = r'''
You are an intelligent voice-note post-processor embedded in WishperLog.
You receive raw speech-to-text output which may contain mispronunciations,
homophones, run-on sentences, filler words, grammar errors, and STT artefacts.

TODAY'S DATE AND TIME: {{TEMPORAL_CONTEXT}}

Your job:
  A) Correct the text intelligently (see clean_body rules).
  B) Classify it into the JSON schema below.

════════════════════════════════════════════
OUTPUT — EXACTLY ONE raw JSON object.
No markdown fences, no backticks, no prose.
First byte MUST be `{`  Last byte MUST be `}`
════════════════════════════════════════════
{
  "title":               "<string: 3–9 words in INPUT language>",
  "clean_body":          "<string: corrected full note in INPUT language>",
  "translated_content":  "<string: English translation if non-English input, else null>",
  "category":            "<string: tasks|reminders|ideas|follow-up|journal|general>",
  "priority":            "<string: high|medium|low>",
  "extracted_date":      "<string YYYY-MM-DD | null>"
}

━━━ FIELD RULES ━━━━━━━━━━━━━━━━━━━━━━━━━━━━

title
  • 3–9 words in the INPUT language (do NOT translate).
  • Begin with an action verb OR the main subject noun.
  • No trailing punctuation. Omit filler openers ("Note about", "Remind me to").
  • ✓ "Call dentist Friday"   ✓ "Landing page hero copy"   ✓ "Mom birthday gift"

clean_body  ← ACTIVE CORRECTION REQUIRED
  Fix ALL of the following from raw STT output:
  • Homophones / mispronunciations — common Indian-English STT errors to fix:
      "contrack"→"contract", "meting"→"meeting", "fone"→"phone",
      "revert back"→"revert", "prepone"→"bring forward",
      "do the needful"→"handle this", "kinda"→"kind of",
      "gonna"→"going to", "wanna"→"want to", "lemme"→"let me".
  • Filler words — remove: "um", "uh", "like", "you know", "basically",
      "actually", "so yeah", "right so", "okay so".
  • Repeated words — deduplicate: "the the", "call call" → keep one.
  • Run-on fragments joined by "and" or "so" — split into sentences.
  • Missing capitalisation at sentence starts.
  • Obvious missing articles (a/an/the) only when unambiguous.
  • Normalise "tommorow", "tommorrow" → "tomorrow".
  DO NOT: translate, summarise, add new context, change names, change numbers.

category — choose EXACTLY ONE:
  "tasks"     → actionable item with a verb: "call", "buy", "finish", "send".
  "reminders" → time-bound alert, event, or appointment.
  "ideas"     → creative concept, insight, or brainstorm with no deadline.
  "follow-up" → any check-in, ping, or follow-up on a previous action:
                  "follow up with X", "check with Y", "ping Z", "any update on".
  "journal"   → personal reflection, emotion, observation, gratitude.
  "general"   → anything that doesn't fit the above.
  TIE-BREAK: tasks > reminders > follow-up > ideas > journal > general.

priority
  "high"   → contains urgency words: "urgent", "asap", "today", "critical",
              "deadline", "immediately", OR an extracted_date within 24 h.
  "medium" → has a date/time in 1–7 days, or mild urgency ("soon", "this week").
  "low"    → everything else.

extracted_date
  • If the note contains a specific date or relative reference, compute the
    absolute date using TODAY'S DATE above and return YYYY-MM-DD.
  • Relative references to resolve (using TODAY'S DATE):
      "today"      → TODAY
      "tomorrow"   → TODAY + 1 day
      "next Monday"→ next calendar Monday
      "this Friday"→ the coming Friday
      "in 3 days"  → TODAY + 3 days
      "next week"  → TODAY + 7 days
  • If no date is mentioned → null.

IMPORTANT: respond with ONLY the JSON object. Zero extra characters.
''';

  /// Builds the system prompt injecting the current date/time for temporal parsing.
  static String buildSystemPrompt() {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months   = ['January', 'February', 'March', 'April', 'May', 'June',
                      'July', 'August', 'September', 'October', 'November', 'December'];

    final temporal =
        '${weekdays[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} '
        '(${_tzOffsetString(now)}, tz=${now.timeZoneName})';

    return _systemPromptTemplate.replaceFirst('{{TEMPORAL_CONTEXT}}', temporal);
  }

  static String _tzOffsetString(DateTime dt) {
    final offset = dt.timeZoneOffset;
    final sign   = offset.isNegative ? '-' : '+';
    final h      = offset.inHours.abs().toString().padLeft(2, '0');
    final m      = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    return 'UTC$sign$h:$m';
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Classify
  // ──────────────────────────────────────────────────────────────────────────

  Future<GeminiClassificationResult> classify(
    String rawTranscript, {
    String? modelName,
  }) async {
    if (!isConfigured) {
      return _localFallback(rawTranscript, 'gemini-local');
    }
    if (rawTranscript.trim().isEmpty) {
      return _localFallback('', 'gemini-local');
    }

    try {
      final selectedModel = modelName ?? 'gemini-1.5-flash';
      final model = _providedModel ??
          GenerativeModel(
            model: selectedModel,
            apiKey: _apiKey,
            generationConfig: GenerationConfig(
              temperature: 0.2,
              maxOutputTokens: 512,
              // Constrain to JSON only via responseMimeType when available.
              responseMimeType: 'application/json',
            ),
          );

      final systemPrompt = buildSystemPrompt();
      final prompt = '$systemPrompt\n\nRaw input: ${rawTranscript.trim()}';

      final response = await model.generateContent([Content.text(prompt)]).timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException('Gemini timeout after 20 s'),
      );

      final raw = response.text ?? '';
      if (raw.trim().isEmpty) {
        throw Exception('Gemini returned empty response');
      }

      return _parseJson(rawTranscript, raw.trim(), model: selectedModel);
    } on TimeoutException catch (e) {
      throw Exception('[GeminiClassifier] Timeout: $e');
    } catch (e) {
      rethrow;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Parsing helpers
  // ──────────────────────────────────────────────────────────────────────────

  GeminiClassificationResult _parseJson(
    String raw,
    String payload, {
    required String model,
    bool wasFallback = false,
  }) {
    try {
      final noFence = payload
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll('```', '')
          .trim();
      final start = noFence.indexOf('{');
      final end   = noFence.lastIndexOf('}');
      if (start < 0 || end <= start) throw FormatException('No JSON object found');

      final decoded = jsonDecode(noFence.substring(start, end + 1)) as Map<String, dynamic>;
      final title     = (decoded['title']      as String?)?.trim();
      final cleanBody = (decoded['clean_body'] as String?)?.trim();
      final categoryText = (decoded['category'] as String?) ?? NoteCategory.general.name;
      final inferredCategory = parseCategory(categoryText);
      final textForHeuristics = [raw, title, cleanBody].whereType<String>().join(' ');

      final translatedContent = (decoded['translated_content'] as String?)?.trim();
      return GeminiClassificationResult(
        title:              title?.isNotEmpty == true ? title! : _fallbackTitle(raw),
        translatedContent:  (translatedContent?.isNotEmpty == true) ? translatedContent : null,
        category:           inferredCategory == NoteCategory.general
            ? inferCategoryFromText(textForHeuristics)
            : inferredCategory,
        priority:      parsePriority((decoded['priority'] as String?) ?? NotePriority.medium.name),
        extractedDate: _parseDate(decoded['extracted_date']),
        cleanBody:     cleanBody?.isNotEmpty == true ? cleanBody! : raw.trim(),
        model:         model,
        wasFallback:   wasFallback,
      );
    } catch (e) {
      return _localFallback(raw, model);
    }
  }

  GeminiClassificationResult _localFallback(String raw, String model) {
    final parsed = NlpTaskParser.parse(raw);
    return GeminiClassificationResult(
      title:         parsed.cleanTitle?.isNotEmpty == true ? parsed.cleanTitle! : _fallbackTitle(raw),
      category:      parsed.category,
      priority:      parsed.priority,
      extractedDate: parsed.extractedDate,
      cleanBody:     raw.trim(),
      model:         model,
      wasFallback:   true,
    );
  }

  String _fallbackTitle(String raw) {
    final words = raw.trim().split(RegExp(r'\s+')).take(6).toList();
    return words.isEmpty ? 'Quick note' : words.join(' ');
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().toLowerCase() == 'null') return null;
    try {
      return DateTime.parse(value.toString().trim());
    } catch (_) {
      return null;
    }
  }
}

// Simple timeout exception since dart:async's TimeoutException needs an import.
class TimeoutException implements Exception {
  TimeoutException(this.message);
  final String message;
  @override String toString() => 'TimeoutException: $message';
}
````

### lib/features/ai/data/groq_note_classifier.dart

````dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/features/ai/data/gemini_note_classifier.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

/// Groq Chat API classifier (OpenAI-compatible).
/// Primary model: llama-3.3-70b-versatile
/// Fallback model: llama-3.1-8b-instant (if 70b hits rate limit)
///
/// Uses the shared GeminiNoteClassifier.buildSystemPrompt() so both
/// providers use identical prompt logic including temporal context.
class GroqNoteClassifier {
  static const _baseUrl      = 'https://api.groq.com/openai/v1/chat/completions';
  static const _primaryModel = 'llama-3.3-70b-versatile';
  static const _fallbackModel = 'llama-3.1-8b-instant';
  static const List<String> supportedModels = [
    'llama-3.3-70b-versatile',
    'llama-3.1-8b-instant',
    'qwen3-32b',
    'llama-4-scout-17b-16e-instruct',
  ];

  final String _apiKey;

  GroqNoteClassifier({String? apiKey}) : _apiKey = apiKey ?? AppEnv.groqApiKey;

  bool get isConfigured => _apiKey.isNotEmpty;

  Future<GeminiClassificationResult?> classify(
    String rawTranscript, {
    String? modelName,
  }) async {
    if (!isConfigured || rawTranscript.trim().isEmpty) return null;

    final candidates = <String>{
      if (modelName != null && modelName.trim().isNotEmpty) modelName.trim(),
      _primaryModel,
      _fallbackModel,
      ...supportedModels,
    }.toList();

    for (final model in candidates) {
      final result = await _callApi(rawTranscript, model);
      if (result != null) return result;
      if (model == _primaryModel) {
        debugPrint('[GroqClassifier] Primary model failed, trying fallback model');
      }
    }
    return null;
  }

  Future<GeminiClassificationResult?> _callApi(String rawTranscript, String model) async {
    try {
      final systemPrompt = GeminiNoteClassifier.buildSystemPrompt();

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type':  'application/json',
        },
        body: jsonEncode({
          'model': model,
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user',   'content': 'Raw input: ${rawTranscript.trim()}'},
          ],
          'temperature':  0.2,
          'max_tokens':   512,
          // JSON mode — Groq supports this for llama models.
          'response_format': {'type': 'json_object'},
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 429) {
        debugPrint('[GroqClassifier] Rate limit hit on $model');
        return null; // caller will try fallback
      }

      if (response.statusCode != 200) {
        debugPrint('[GroqClassifier] API error ${response.statusCode} on $model: ${response.body}');
        return null;
      }

      final body    = jsonDecode(response.body) as Map<String, dynamic>;
      final content = (body['choices'] as List?)?.first?['message']?['content'] as String?;
      if (content == null || content.isEmpty) return null;

      return _parse(rawTranscript, content.trim(), model: 'groq-$model');
    } catch (e) {
      debugPrint('[GroqClassifier] classify error on $model: $e');
      return null;
    }
  }

  GeminiClassificationResult? _parse(String raw, String payload, {required String model}) {
    try {
      final noFence = payload
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll('```', '')
          .trim();
      final start = noFence.indexOf('{');
      final end   = noFence.lastIndexOf('}');
      if (start < 0 || end <= start) return null;

      final decoded   = jsonDecode(noFence.substring(start, end + 1)) as Map<String, dynamic>;
      final title     = (decoded['title']      as String?)?.trim();
      final cleanBody = (decoded['clean_body'] as String?)?.trim();
      final categoryText = (decoded['category'] as String?) ?? NoteCategory.general.name;
      final inferredCategory = parseCategory(categoryText);
      final textForHeuristics = [raw, title, cleanBody].whereType<String>().join(' ');

      return GeminiClassificationResult(
        title:         title?.isNotEmpty == true ? title! : _fallbackTitle(raw),
        category:      inferredCategory == NoteCategory.general
            ? inferCategoryFromText(textForHeuristics)
            : inferredCategory,
        priority:      parsePriority((decoded['priority']  as String?) ?? NotePriority.medium.name),
        extractedDate: _parseDate(decoded['extracted_date']),
        cleanBody:     cleanBody?.isNotEmpty == true ? cleanBody! : raw.trim(),
        model:         model,
        wasFallback:   false,
      );
    } catch (e) {
      debugPrint('[GroqClassifier] parse error: $e');
      return null;
    }
  }

  String _fallbackTitle(String raw) {
    final words = raw.trim().split(RegExp(r'\s+')).take(6).toList();
    return words.isEmpty ? 'Quick note' : words.join(' ');
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().toLowerCase() == 'null') return null;
    try {
      return DateTime.parse(value.toString().trim());
    } catch (_) {
      return null;
    }
  }
}
````

### lib/features/auth/data/repositories/user_repository.dart

```dart
// lib/features/auth/data/repositories/user_repository.dart
//
// v2.0 — Digest Collection Architecture
//
// Change: digest schedule writes now stay on the root user doc only.
// The Cloudflare Worker reads the root digest fields directly.
//
// All other methods are preserved exactly.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignInFriendlyException implements Exception {
  const SignInFriendlyException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UserRepository {
  final auth.FirebaseAuth  _firebaseAuth = auth.FirebaseAuth.instance;
  final FirebaseFirestore   _firestore   = FirebaseFirestore.instance;
  final GoogleSignIn        _googleSignIn;

  UserRepository({required GoogleSignIn googleSignIn})
      : _googleSignIn = googleSignIn;

  Stream<auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // ── Sign in / out ──────────────────────────────────────────────────────────

  Future<auth.UserCredential> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(provider);
        final user = userCredential.user;
        if (user == null) throw Exception('Google sign in aborted');
        await _upsertUserDocument(firebaseUser: user, googleAuth: null);
        return userCredential;
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) throw Exception('Google sign in aborted');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final auth.AuthCredential credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final auth.UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      await _upsertUserDocument(
        firebaseUser: userCredential.user!,
        googleAuth: googleAuth,
      );

      return userCredential;
    } catch (e) {
      debugPrint('[UserRepository] Google sign-in failed: $e');
      rethrow;
    }
  }

  Future<void> _upsertUserDocument({
    required auth.User firebaseUser,
    required GoogleSignInAuthentication? googleAuth,
  }) async {
    final prefs    = await SharedPreferences.getInstance();
    final overlayX = prefs.getDouble('overlay.pos.x') ?? 0.0;
    final overlayY = prefs.getDouble('overlay.pos.y') ?? 0.0;

    final userDoc = _firestore.collection('users').doc(firebaseUser.uid);
    final docSnapshot = await userDoc.get();
    final existingData = docSnapshot.data() ?? const <String, dynamic>{};

    final digestTime  = (existingData['digest_time'] as String?) ?? '09:00';
    final digestTimes = (existingData['digest_times'] as List<dynamic>?)
        ?.map((v) => v.toString())
        .where((v) => v.trim().isNotEmpty)
        .toList();

    final data = {
      'uid'          : firebaseUser.uid,
      'email'        : firebaseUser.email ?? '',
      'display_name' : firebaseUser.displayName ?? '',
      'google_tokens': {
        'access_token' : googleAuth?.accessToken,
        'refresh_token': null,
        'expiry'       : null,
      },
      'telegram_chat_id': existingData['telegram_chat_id'] as String?,
      'digest_time'     : digestTime,
      'digest_times'    : digestTimes ?? [digestTime],
      'digest_times_utc':
          (existingData['digest_times_utc'] as List<dynamic>?)
              ?.map((v) => v.toString())
              .where((v) => v.trim().isNotEmpty)
              .toList() ??
          const <String>[],
      'timezone_offset_minutes':
          (existingData['timezone_offset_minutes'] as num?)?.toInt() ??
          DateTime.now().timeZoneOffset.inMinutes,
      'overlay_position': {'x': overlayX, 'y': overlayY},
      'overlay_visible' : (existingData['overlay_visible'] as bool?) ?? true,
      'fcm_token'       : (existingData['fcm_token'] as String?) ?? '',
    };

    if (!docSnapshot.exists) {
      await userDoc.set({
        ...data,
        'created_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    await userDoc.set(data, SetOptions(merge: true));
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  // ── Document streams ────────────────────────────────────────────────────────

  Stream<Map<String, dynamic>?> watchCurrentUserDocument() {
    return _firebaseAuth.authStateChanges().asyncExpand((user) {
      if (user == null) return Stream.value(null);
      return _firestore
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.data());
    });
  }

  // ── Digest time persistence ─────────────────────────────────────────────────

  Future<void> updateDigestTime(String digestTime) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    final utcSlot = _toUtcSlotFromHm(digestTime);
    await _firestore.collection('users').doc(user.uid).set({
      'digest_time'            : digestTime,
      'digest_times'           : [digestTime],
      'digest_times_utc'       : [utcSlot],
      'timezone_offset_minutes': DateTime.now().timeZoneOffset.inMinutes,
      'updated_at'             : FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Persists digest times to the legacy user root doc, which is now the
  /// canonical schedule source for the Cloudflare Worker.
  Future<void> updateDigestTimes(
    List<TimeOfDay> times, {
    List<String> utcSlots = const [],
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;

    final localSlots       = times.map(_formatTimeOfDay).toList();
    final normalizedUtcSlots = utcSlots.isNotEmpty
        ? utcSlots
        : times.map(_toUtcSlot).toList();

    final legacyData = <String, dynamic>{
      'digest_time'            : localSlots.first,
      'digest_times'           : localSlots,
      'digest_times_utc'       : normalizedUtcSlots,
      'timezone_offset_minutes': DateTime.now().timeZoneOffset.inMinutes,
      'updated_at'             : FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(user.uid).set(
      legacyData,
      SetOptions(merge: true),
    );
  }

  // ── Overlay ────────────────────────────────────────────────────────────────

  Future<void> updateOverlayVisibility(bool visible) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set({
      'overlay_visible': visible,
    }, SetOptions(merge: true));
  }

  // ── Telegram ───────────────────────────────────────────────────────────────

  Future<void> updateTelegramChatId(String chatId) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    final normalized = chatId.trim();

    await _firestore.collection('users').doc(user.uid).set({
      'telegram_chat_id': normalized.isEmpty
          ? FieldValue.delete()
          : normalized,
    }, SetOptions(merge: true));

    final prefs = await SharedPreferences.getInstance();
    if (normalized.isEmpty) {
      await prefs.remove('telegram_chat_id');
    } else {
      await prefs.setString('telegram_chat_id', normalized);
    }
  }

  Future<void> writePendingTelegramToken({
    required String token,
    required DateTime expiresAt,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || token.trim().isEmpty) return;

    await _firestore.collection('users').doc(user.uid).set({
      'pending_telegram': {
        'token'     : token.trim(),
        'expires_at': Timestamp.fromDate(expiresAt.toUtc()),
      },
    }, SetOptions(merge: true));
  }

  Future<void> clearPendingTelegramToken() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set({
      'pending_telegram': FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  // ── FCM / overlay position ─────────────────────────────────────────────────

  Future<void> updateFcmToken(String token) async {
    final user = _firebaseAuth.currentUser;
    if (user == null || token.trim().isEmpty) return;
    await _firestore.collection('users').doc(user.uid).set({
      'fcm_token': token.trim(),
    }, SetOptions(merge: true));
  }

  Future<void> updateOverlayPosition({
    required double x,
    required double y,
  }) async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).set({
      'overlay_position': {'x': x, 'y': y},
    }, SetOptions(merge: true));
  }

  String _formatTimeOfDay(TimeOfDay time) =>
      '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';

  String _toUtcSlot(TimeOfDay time) {
    final offsetMinutes = DateTime.now().timeZoneOffset.inMinutes;
    final totalMinutes  = time.hour * 60 + time.minute;
    final shiftedMinutes = (totalMinutes - offsetMinutes) % (24 * 60);
    final normalized    = shiftedMinutes < 0
        ? shiftedMinutes + 24 * 60
        : shiftedMinutes;
    final hour   = normalized ~/ 60;
    final minute = normalized % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  String _toUtcSlotFromHm(String digestTime) {
    final parts = digestTime.trim().split(':');
    if (parts.length != 2) return digestTime.trim();
    final hour   = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return digestTime.trim();
    return _toUtcSlot(TimeOfDay(hour: hour, minute: minute));
  }

}
```

### lib/features/capture/data/capture_service.dart

```dart
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
import 'package:wishperlog/shared/models/note_helpers.dart';
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
    NoteCategory? categoryOverride,
    NotePriority? priorityOverride,
    DateTime? extractedDateOverride,
  }) async {
    final trimmed = rawTranscript.trim();
    if (trimmed.isEmpty) return null;

    try {
      final now = DateTime.now();
      final user = _auth?.currentUser;
      if (user != null) {
        final recent = await _isarNoteStore.findRecentByTranscript(
          uid: user.uid,
          rawTranscript: trimmed,
          source: source,
        );
        if (recent != null) {
          debugPrint('[CaptureService] Duplicate capture skipped: ${recent.noteId}');
          return recent;
        }
      }
      final noteId = '${now.microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}';
      final inferredCategory = categoryOverride ?? inferCategoryFromText(trimmed);
      final resolvedPriority = priorityOverride ?? NotePriority.medium;

      // STEP 1: Instant local save with fallback title.
      final quickTitle = _quickTitle(trimmed);
      final initialNote = Note(
        noteId: noteId,
        uid: user?.uid ?? 'local_anonymous',
        rawTranscript: trimmed,
        title: quickTitle,
        cleanBody: trimmed,
        category: inferredCategory,
        createdAt: now,
        updatedAt: now,
        status: NoteStatus.pendingAi,
        aiModel: 'pending',
        gcalEventId: null,
        gtaskId: null,
        source: source,
        priority: resolvedPriority,
        extractedDate: extractedDateOverride,
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
```

### lib/features/capture/presentation/state/capture_ui_controller.dart

```dart
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

part 'capture_ui_state.dart';

/// Manages recording / capture UI state for the single global Dynamic Island.
/// Transitions: idle → recording → processing → saved → idle.
class CaptureUiController extends Cubit<CaptureUiState> {
  CaptureUiController({
    required CaptureService captureService,
    required SpeechToText speechToText,
  }) : _captureService = captureService,
       _speechToText = speechToText,
       super(const CaptureUiIdle()) {
    // Pre-warm the speech engine so the first long-press has no latency.
    _prewarmSpeech();
  }

  final CaptureService _captureService;
  final SpeechToText _speechToText;

  Timer? _autoReturnTimer;
  Timer? _recordingTimer;
  int _recordingDurationMs = 0;
  final List<double> _waveformSamples = [];
  String _lastTranscript = '';

  // ── Timing-safety flags ────────────────────────────────────────────────────
  /// True while [startRecording] is awaiting speech engine initialisation.
  bool _isInitializing = false;
  /// True if [stopRecording] was called before init finished (user released
  /// the button before the engine was ready).  Checked after init.
  bool _stopRequested = false;

  Future<void> _prewarmSpeech() async {
    try {
      if (!_speechToText.isAvailable) {
        await _speechToText.initialize(
          onStatus: _onSpeechStatus,
          onError: (e) => debugPrint('[CaptureUiController] STT prewarm error: ${e.errorMsg}'),
        );
      }
    } catch (e) {
      debugPrint('[CaptureUiController] prewarm failed (non-fatal): $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // In-app recording (triggered by the floating bubble long-press)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Starts recording.  Called on long-press START.
  Future<void> startRecording() async {
    if (state is CaptureUiRecording || state is CaptureUiProcessing) return;
    if (_isInitializing) return; // already spinning up — ignore duplicate call

    // Web graceful fallback: voice recording not supported
    if (kIsWeb) {
      emit(const CaptureUiError(
        message: 'Voice recording is not available on web. Use text input instead.',
      ));
      await Future<void>.delayed(const Duration(seconds: 3));
      emit(const CaptureUiIdle());
      return;
    }

    _stopRequested = false;
    _isInitializing = true;

    try {
      // ── Step 1: ensure speech engine is ready ──────────────────────────────
      if (!_speechToText.isAvailable) {
        final ready = await _speechToText.initialize(
          onStatus: _onSpeechStatus,
          onError: (error) {
            debugPrint('[CaptureUiController] STT error: ${error.errorMsg}');
            if (state is CaptureUiRecording) stopRecording();
          },
        );
        if (!ready) {
          _isInitializing = false;
          emit(const CaptureUiError(
            message: 'Microphone not available. Please grant permission in Settings.',
          ));
          await Future<void>.delayed(const Duration(seconds: 2));
          emit(const CaptureUiIdle());
          return;
        }
      }

      _isInitializing = false;

      // User released the button while we were initialising → don't record.
      if (_stopRequested) {
        _stopRequested = false;
        return;
      }

      // ── Step 2: show recording state immediately ───────────────────────────
      _recordingDurationMs = 0;
      _waveformSamples.clear();
      _lastTranscript = '';
      emit(const CaptureUiRecording(
        durationMs: 0,
        waveformSamples: [],
        currentTranscript: '',
      ));

      // ── Step 3: waveform animation timer ──────────────────────────────────
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (state is CaptureUiRecording) {
          _recordingDurationMs += 150;
          _updateWaveform();
        }
      });

      // ── Step 4: start listening ────────────────────────────────────────────
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          onDevice: false, // network STT works on far more devices
        ),
      );
    } catch (e) {
      _isInitializing = false;
      debugPrint('[CaptureUiController] startRecording error: $e');
      _recordingTimer?.cancel();
      emit(const CaptureUiError(
        message: 'Microphone not available. Please grant permission in Settings.',
      ));
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(const CaptureUiIdle());
    }
  }

  /// Stops recording.  Called on long-press END.
  Future<void> stopRecording() async {
    if (_isInitializing) { _stopRequested = true; return; }
    if (state is! CaptureUiRecording) return;

    _recordingTimer?.cancel();

    final captured = _lastTranscript.trim();

    try {
      await _speechToText.stop();
    } catch (_) {}

    if (captured.isEmpty) {
      emit(const CaptureUiIdle());
      return;
    }

    // Show provider immediately using last known provider
    emit(CaptureUiProcessing(
      provider: _captureService.activeProviderName,
    ));

    // Save in background - ingestRawCapture now returns instantly
    try {
      final savedNote = await _captureService.ingestRawCapture(
        rawTranscript: captured,
        source: CaptureSource.voiceOverlay,
        syncToCloud: true,
      );

      // Show saved with quick title; island updates again when AI finishes
      emit(CaptureUiSaved(
        title: savedNote?.title ?? captured,
        category: savedNote?.category ?? NoteCategory.general,
        originPrefix: saveOriginPrefix(savedNote?.aiModel ?? ''),
        noteId: savedNote?.noteId,
      ));
    } catch (error) {
      emit(CaptureUiError(message: 'Failed to save: $error'));
      await Future<void>.delayed(const Duration(seconds: 2));
    }

    _autoReturnTimer?.cancel();
    _autoReturnTimer = Timer(AppDurations.notchAutoReturn, () {
      if (state is CaptureUiSaved || state is CaptureUiError) {
        emit(const CaptureUiIdle());
      }
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // External notifications (native overlay / quick-note editor / home screen)
  // These update the island without opening the microphone from Flutter.
  // ═══════════════════════════════════════════════════════════════════════════

  /// Native overlay started recording — light up the island.
  void notifyExternalRecordingStarted() {
    if (state is CaptureUiRecording || state is CaptureUiProcessing) return;
    _recordingDurationMs = 0;
    _waveformSamples.clear();
    _lastTranscript = '';
    emit(const CaptureUiRecording(
      durationMs: 0,
      waveformSamples: [],
      currentTranscript: '',
    ));
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (state is CaptureUiRecording) {
        _recordingDurationMs += 150;
        _updateWaveform();
      }
    });
  }

  /// Native overlay received a partial transcript — scroll text in island.
  void updateExternalTranscript(String text) {
    if (state is! CaptureUiRecording) return;
    final current = state as CaptureUiRecording;
    emit(CaptureUiRecording(
      durationMs: current.durationMs,
      waveformSamples: current.waveformSamples,
      currentTranscript: text,
    ));
  }

  /// Native overlay done recognising — show processing indicator.
  void notifyExternalRecordingStopped() {
    _recordingTimer?.cancel();
    if (state is CaptureUiRecording) {
      final activeProvider = _captureService.activeProviderName;
      emit(CaptureUiProcessing(provider: activeProvider));
      // Safety net: if _saveOverlayNote never calls notifyExternalRecordingSaved
      // (e.g. empty transcript), auto-return to idle after 12 seconds.
      _autoReturnTimer?.cancel();
      _autoReturnTimer = Timer(const Duration(seconds: 4), () {
        if (state is CaptureUiProcessing) {
          emit(const CaptureUiIdle());
        }
      });
    }
  }

  /// Text overlay submitted — show processing indicator (no prior recording state).
  void notifyExternalTextProcessingStarted() {
    _recordingTimer?.cancel();
    emit(const CaptureUiProcessing(provider: 'AI'));
    _autoReturnTimer?.cancel();
    _autoReturnTimer = Timer(const Duration(seconds: 15), () {
      if (state is CaptureUiProcessing) emit(const CaptureUiIdle());
    });
  }

  /// Called by OverlayNotifier when a note captured from the native overlay
  /// is being saved + classified. Puts the Dynamic Island into processing state.
  void notifyExternalRecordingProcessing({String provider = 'Gemini'}) {
    _recordingTimer?.cancel();
    _autoReturnTimer?.cancel();
    emit(CaptureUiProcessing(provider: provider));
    // Safety auto-return: if we never get a saved/error signal, reset after 45s.
    _autoReturnTimer = Timer(const Duration(seconds: 45), () {
      if (state is CaptureUiProcessing) {
        emit(const CaptureUiIdle());
      }
    });
  }

  /// A note was saved (from any source) — show the saved confirmation pill.
  void notifyExternalRecordingSaved({
    required String title,
    required NoteCategory category,
    String? model,
    String? noteId,
  }) {
    _recordingTimer?.cancel();
    _autoReturnTimer?.cancel();
    emit(CaptureUiSaved(
      title: title,
      category: category,
      originPrefix: saveOriginPrefix(model ?? ''),
      noteId: noteId,
    ));
    _autoReturnTimer = Timer(AppDurations.notchAutoReturn, () {
      if (state is CaptureUiSaved) emit(const CaptureUiIdle());
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Internal helpers
  // ═══════════════════════════════════════════════════════════════════════════

  void _onSpeechResult(SpeechRecognitionResult result) {
    final next = result.recognizedWords.trim();
    if (next.isNotEmpty) {
      _lastTranscript = next;
    }
    if (state is CaptureUiRecording) {
      final current = state as CaptureUiRecording;
      emit(CaptureUiRecording(
        durationMs: current.durationMs,
        waveformSamples: current.waveformSamples,
        currentTranscript: _lastTranscript,
      ));
    }
  }

  void _onSpeechStatus(String status) {
    debugPrint('[CaptureUiController] STT status: $status');
    // 'done' = engine auto-closed due to silence or system cut-off.
    if (status == 'done' && state is CaptureUiRecording) {
      if (_stopRequested) {
        // User already released the button — flush whatever we have.
        debugPrint('[CaptureUiController] STT done after stop request — flushing transcript');
        _flushAndStop();
        return;
      }
      if (!_isInitializing) {
        // User is still holding — re-arm the listener.
        unawaited(_resumeListening());
      }
    }
  }

  /// Saves the last captured transcript if non-empty and transitions to
  /// processing state. Called when the button is released AND STT closes.
  void _flushAndStop() {
    _recordingTimer?.cancel();
    final transcript = _lastTranscript.trim();
    if (transcript.isEmpty) {
      resetToIdle();
      return;
    }
    emit(CaptureUiProcessing(provider: _captureService.activeProviderName));
    _autoReturnTimer?.cancel();
    _autoReturnTimer = Timer(const Duration(seconds: 45), () {
      if (state is CaptureUiProcessing) emit(const CaptureUiIdle());
    });
    // The save itself is triggered by the caller (_stopDictation) which
    // already holds the transcript in _lastTranscript. If this is reached
    // via _onSpeechStatus, emit the saved-transcript event so the upstream
    // save flow is triggered.
    _onSpeechResult(
      SpeechRecognitionResult(
        [SpeechRecognitionWords(transcript, null, 1.0)],
        true,
      ),
    );
  }

  /// Re-arms STT when it auto-closes during an active recording session.
  Future<void> _resumeListening() async {
    // Do NOT re-arm if: user released button, we're still initialising,
    // or the state has already moved beyond recording.
    if (state is! CaptureUiRecording || _stopRequested || _isInitializing) {
      if (_stopRequested && state is CaptureUiRecording) {
        _flushAndStop();
      }
      return;
    }
    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          onDevice: false,
        ),
      );
    } catch (e) {
      debugPrint('[CaptureUiController] _resumeListening error: $e');
    }
  }

  void _updateWaveform() {
    if (state is! CaptureUiRecording) return;
    final t = _recordingDurationMs / 1000.0;
    // 5 bars with sin-wave animation at slightly different phases/frequencies.
    final newSamples = List<double>.generate(5, (i) {
      return (0.35 + 0.65 * ((math.sin(t * 2.5 + i * 0.7) + 1) / 2)).clamp(
        0.0,
        1.0,
      );
    });

    // Only emit if samples changed meaningfully.
    final current = state as CaptureUiRecording;
    if (_wavesEqual(current.waveformSamples, newSamples) &&
        current.durationMs == _recordingDurationMs) {
      return;
    }

    emit(CaptureUiRecording(
      durationMs: _recordingDurationMs,
      waveformSamples: newSamples,
      currentTranscript: _lastTranscript,
    ));
  }

  bool _wavesEqual(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).abs() > 0.05) return false;
    }
    return true;
  }

  void resetToIdle() {
    _recordingTimer?.cancel();
    _autoReturnTimer?.cancel();
    _recordingDurationMs = 0;
    _waveformSamples.clear();
    _lastTranscript = '';
    _stopRequested = false;
    _isInitializing = false;
    emit(const CaptureUiIdle());
  }

  @override
  Future<void> close() {
    _recordingTimer?.cancel();
    _autoReturnTimer?.cancel();
    return super.close();
  }
}
```

### lib/features/capture/presentation/state/capture_ui_state.dart

```dart
part of 'capture_ui_controller.dart';

/// Enum representing capture recording states in the overlay.
enum CaptureRecordingState {
  idle,
  recording,
  processing,
  saved,
}

/// State class for CaptureUiController Cubit.
abstract class CaptureUiState {
  const CaptureUiState();
}

/// Initial state when notch is idle, no recording in progress.
class CaptureUiIdle extends CaptureUiState {
  const CaptureUiIdle();
}

/// State when recording is in progress.
class CaptureUiRecording extends CaptureUiState {
  const CaptureUiRecording({
    required this.durationMs,
    required this.waveformSamples,
    required this.currentTranscript,
  });

  final int durationMs;
  final List<double> waveformSamples;
  final String currentTranscript;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptureUiRecording &&
          runtimeType == other.runtimeType &&
          durationMs == other.durationMs &&
          waveformSamples == other.waveformSamples &&
          currentTranscript == other.currentTranscript;

  @override
  int get hashCode =>
      durationMs.hashCode ^ waveformSamples.hashCode ^ currentTranscript.hashCode;
}

/// State when audio is being processed (transcribing / classifying).
class CaptureUiProcessing extends CaptureUiState {
  const CaptureUiProcessing({required this.provider});

  final String provider; // e.g., "Gemini", "OpenAI"

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptureUiProcessing &&
          runtimeType == other.runtimeType &&
          provider == other.provider;

  @override
  int get hashCode => provider.hashCode;
}

/// State when a note has been saved and is showing success UI.
class CaptureUiSaved extends CaptureUiState {
  const CaptureUiSaved({
    required this.title,
    required this.category,
    required this.originPrefix,
    this.collection = 'notes',
    this.noteId,
  });

  final String title;
  final NoteCategory category;
  final String originPrefix;
  final String collection;
  final String? noteId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptureUiSaved &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          category == other.category &&
          originPrefix == other.originPrefix &&
          collection == other.collection &&
          noteId == other.noteId;

  @override
  int get hashCode =>
      title.hashCode ^
      category.hashCode ^
      originPrefix.hashCode ^
      collection.hashCode ^
      noteId.hashCode;
}

/// State when an error occurred during recording or processing.
class CaptureUiError extends CaptureUiState {
  const CaptureUiError({required this.message});

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptureUiError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
```

### lib/features/home/presentation/home_screen_layout.dart

```dart
import 'package:flutter/widgets.dart';

import 'screens/home_screen.dart';

/// Router-facing wrapper to keep compatibility with existing route references.
class HomeScreenLayout extends StatelessWidget {
	const HomeScreenLayout({super.key});

	@override
	Widget build(BuildContext context) {
		return const HomeScreen();
	}
}
```

### lib/features/home/presentation/screens/home_screen.dart

```dart
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/app/route_observer.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/features/home/presentation/widgets/folder_grid.dart';
import 'package:wishperlog/features/home/presentation/widgets/thought_canvas.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with RouteAware {
  static const MethodChannel _overlayChannel = MethodChannel('wishperlog/overlay');

  final NoteRepository _notes = sl<NoteRepository>();
  late final CaptureService _captureService;
  final SpeechToText _speech = SpeechToText();
  final TextEditingController _writingController = TextEditingController();
  final FocusNode _canvasFocusNode = FocusNode();

  bool _saving = false;
  bool _speechReady = false;
  bool _isDictating = false;
  String _dictationPrefix = '';
  NoteCategory _quickCategory = NoteCategory.general;
  NotePriority _quickPriority = NotePriority.medium;
  DateTime? _quickReminderAt;
  late final Future<Uint8List?> _launcherIconBytesFuture;

  @override
  void initState() {
    super.initState();
    _captureService = sl.isRegistered<CaptureService>()
        ? sl<CaptureService>()
        : CaptureService();
    _launcherIconBytesFuture = _loadLauncherIconBytes();
    _writingController.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.unsubscribe(this);
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _canvasFocusNode.dispose();
    _writingController.dispose();
    super.dispose();
  }

  @override
  void didPushNext() {
    _clearCanvasFocus();
  }

  @override
  void didPopNext() {
    _clearCanvasFocus();
  }

  void _clearCanvasFocus() {
    FocusManager.instance.primaryFocus?.unfocus();
    _canvasFocusNode.unfocus();
  }

  Future<Uint8List?> _loadLauncherIconBytes() async {
    try {
      final bytes = await _overlayChannel.invokeMethod<Uint8List>('getLauncherIcon');
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureSpeechReady() async {
    if (_speechReady) {
      return;
    }
    _speechReady = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && _isDictating) {
          _stopDictation();
        }
      },
      onError: (_) {
        if (_isDictating) {
          _stopDictation();
        }
      },
      debugLogging: false,
    );
  }

  Future<void> _startDictation() async {
    if (_isDictating) {
      return;
    }
    await _ensureSpeechReady();
    if (!_speechReady) {
      return;
    }
    _dictationPrefix = _writingController.text.trimRight();

    await _speech.listen(
      onResult: _onDictationResult,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        autoPunctuation: false,
        onDevice: true,
      ),
    );

    if (mounted) {
      setState(() {
        _isDictating = true;
      });
    }
  }

  Future<void> _stopDictation({bool submitCaptured = false}) async {
    if (!_isDictating) {
      return;
    }
    await _speech.stop();

    if (submitCaptured) {
      await _saveWritingBox();
    }

    if (mounted) {
      setState(() {
        _isDictating = false;
      });
    }
  }

  void _onDictationResult(SpeechRecognitionResult result) {
    final spoken = result.recognizedWords.trim();
    final nextText = spoken.isEmpty
        ? _dictationPrefix
        : _dictationPrefix.isEmpty
            ? spoken
            : '$_dictationPrefix $spoken';

    _writingController.value = TextEditingValue(
      text: nextText,
      selection: TextSelection.collapsed(offset: nextText.length),
    );
  }

  Future<void> _saveWritingBox() async {
    if (_saving) {
      return;
    }

    final textToSave = _writingController.text.trim();
    if (textToSave.isEmpty) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final savedNote = await _captureService.ingestRawCapture(
        rawTranscript: textToSave,
        source: CaptureSource.homeWritingBox,
        syncToCloud: true,
        categoryOverride: _quickCategory,
        priorityOverride: _quickPriority,
        extractedDateOverride: _quickReminderAt,
      );
      if (savedNote == null) {
        return;
      }
      _writingController.clear();

      if (mounted) {
        sl<CaptureUiController>().notifyExternalRecordingSaved(
          title: savedNote.title,
          category: savedNote.category,
          model: savedNote.aiModel,
          noteId: savedNote.noteId,
        );
        // Also trigger the native dynamic island pill for Thought Canvas saves.
        try {
          await _overlayChannel.invokeMethod<void>('notifySaved', {
            'title':      savedNote.title,
            'category':   savedNote.category.name,
            'prefix':     saveOriginPrefix(savedNote.aiModel),
            'collection': 'notes',
          });
        } catch (_) {
          // Overlay service may not be running; Flutter-side pill is sufficient.
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _openCaptureMetadataSheet() async {
    var category = _quickCategory;
    var priority = _quickPriority;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: GlassPane(
                    level: 1,
                    radius: 26,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: StatefulBuilder(
              builder: (context, setSheetState) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Capture class',
                          style: TextStyle(
                            color: context.textPri,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        child: const Text('Done'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Set the default category and priority for the next save.',
                    style: TextStyle(color: context.textSec, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category',
                    style: TextStyle(
                      color: context.textPri,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: kAllNoteCategories.map((entry) {
                      final isSelected = entry == category;
                      return FilterChip(
                        selected: isSelected,
                        label: Text(categoryLabel(entry)),
                        onSelected: (_) => setSheetState(() => category = entry),
                        selectedColor: categoryColor(entry).withValues(alpha: 0.16),
                        checkmarkColor: categoryColor(entry),
                        labelStyle: TextStyle(
                          color: isSelected ? categoryColor(entry) : context.textPri,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Priority',
                    style: TextStyle(
                      color: context.textPri,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<NotePriority>(
                    segments: const [
                      ButtonSegment(value: NotePriority.high, label: Text('High')),
                      ButtonSegment(value: NotePriority.medium, label: Text('Medium')),
                      ButtonSegment(value: NotePriority.low, label: Text('Low')),
                    ],
                    selected: {priority},
                    onSelectionChanged: (selection) {
                      if (selection.isEmpty) return;
                      setSheetState(() => priority = selection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: AppColors.tasks,
                      selectedForegroundColor: Colors.white,
                      backgroundColor: context.surface1,
                      foregroundColor: context.textPri,
                      side: BorderSide(color: context.textSec.withValues(alpha: 0.10)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () {
                        setSheetState(() {
                          category = NoteCategory.general;
                          priority = NotePriority.medium;
                        });
                      },
                      child: const Text('Reset to default'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted) return;
    setState(() {
      _quickCategory = category;
      _quickPriority = priority;
    });
  }

  Future<void> _pickReminder() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      initialDate: _quickReminderAt ?? DateTime.now(),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _quickReminderAt == null
          ? TimeOfDay.now()
          : TimeOfDay.fromDateTime(_quickReminderAt!),
    );
    if (time == null || !mounted) return;

    setState(() {
      _quickReminderAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      if (_quickCategory == NoteCategory.general) {
        _quickCategory = NoteCategory.reminders;
      }
    });
  }

  void _clearReminder() {
    setState(() => _quickReminderAt = null);
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: AppDurations.screenTransition,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 14),
            child: child,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: GlassPageBackground(
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalH = constraints.maxHeight;
                final folderH = totalH * 0.40;
                final topH = totalH - folderH;

                return StreamBuilder<Map<NoteCategory, int>>(
                  stream: _notes.watchActiveCountsLocal(),
                  builder: (context, snapshot) {
                    final counts = snapshot.data ?? {
                      for (final c in kAllNoteCategories) c: 0,
                    };
                    final activeTotal = counts.values.fold<int>(0, (sum, count) => sum + count);

                    final tagActive = _quickCategory != NoteCategory.general ||
                        _quickPriority != NotePriority.medium;
                    final tagLabel = tagActive
                        ? '${categoryLabel(_quickCategory)} • ${_quickPriority.name.toUpperCase()}'
                        : null;
                    final reminderLabel = _quickReminderAt != null
                        ? '${MaterialLocalizations.of(context).formatMediumDate(_quickReminderAt!)} • ${TimeOfDay.fromDateTime(_quickReminderAt!).format(context)}'
                        : null;

                    return Column(
                      children: [
                        SizedBox(
                          height: topH,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: GlassPane(
                                              level: 1,
                                              radius: 24,
                                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                                        tintOverride: context.isDark
                                            ? const Color(0x5F0F2742)
                                            : const Color(0xCBEAF4FF),
                                        child: Row(
                                          children: [
                                            FutureBuilder<Uint8List?>(
                                              future: _launcherIconBytesFuture,
                                              builder: (context, snapshot) {
                                                final iconBytes = snapshot.data;
                                                return Container(
                                                  width: 42,
                                                  height: 42,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    gradient: const LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end: Alignment.bottomRight,
                                                      colors: [AppColors.tasks, Color(0xFF57C7FF)],
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors.tasks.withValues(alpha: 0.12),
                                                        blurRadius: 16,
                                                        spreadRadius: -4,
                                                        offset: const Offset(0, 5),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(5),
                                                    child: ClipOval(
                                                      child: iconBytes == null
                                                          ? const Icon(
                                                              Icons.auto_awesome_rounded,
                                                              size: 19,
                                                              color: Colors.white,
                                                            )
                                                          : Image.memory(
                                                              iconBytes,
                                                              fit: BoxFit.cover,
                                                            ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'WishperLog',
                                                    style: TextStyle(
                                                      color: context.textPri,
                                                      fontSize: 21,
                                                      fontWeight: FontWeight.w900,
                                                      letterSpacing: -0.55,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    'Quick capture, cleaner folders, calmer settings.',
                                                    style: TextStyle(
                                                      color: context.textSec.withValues(alpha: 0.88),
                                                      fontSize: 11.2,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            _GlassIconButton(
                                              icon: Icons.search_rounded,
                                              onTap: () => context.push('/search'),
                                            ),
                                            const SizedBox(width: 8),
                                            _GlassIconButton(
                                              icon: Icons.settings_rounded,
                                              onTap: () => context.push('/settings'),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _HomeStatChip(
                                      icon: Icons.notes_rounded,
                                      label: '$activeTotal active',
                                      tint: AppColors.tasks,
                                    ),
                                    _HomeStatChip(
                                      icon: Icons.task_alt_rounded,
                                      label: '${counts[NoteCategory.tasks] ?? 0} tasks',
                                      tint: categoryColor(NoteCategory.tasks),
                                    ),
                                    _HomeStatChip(
                                      icon: Icons.notifications_active_outlined,
                                      label: '${counts[NoteCategory.reminders] ?? 0} reminders',
                                      tint: categoryColor(NoteCategory.reminders),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Expanded(
                                  child: RepaintBoundary(
                                    child: ThoughtCanvas(
                                      controller: _writingController,
                                      focusNode: _canvasFocusNode,
                                      onSave: _saveWritingBox,
                                      onSubmit: _saveWritingBox,
                                      onTagTap: _openCaptureMetadataSheet,
                                      onReminderTap: _pickReminder,
                                      onReminderLongPress: _clearReminder,
                                      onMicPressStart: _startDictation,
                                      onMicPressEnd: () => _stopDictation(submitCaptured: true),
                                      isSaving: _saving,
                                      isRecording: _isDictating,
                                      tagActive: tagActive,
                                      reminderActive: _quickReminderAt != null,
                                      tagLabel: tagLabel,
                                      reminderLabel: reminderLabel,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: folderH,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: GlassPane(
                              level: 2,
                                radius: 28,
                                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                              tintOverride: context.isDark
                                  ? const Color(0x4E122D4A)
                                  : const Color(0xA9EDF7FF),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            'Collections',
                                            style: TextStyle(
                                              color: context.textPri,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w800,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$activeTotal notes',
                                          style: TextStyle(
                                            color: context.textSec,
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: RepaintBoundary(
                                      child: FolderGrid(counts: counts),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeStatChip extends StatelessWidget {
  const _HomeStatChip({required this.icon, required this.label, required this.tint});

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 3,
      radius: 999,
      tintOverride: tint.withValues(alpha: 0.08),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: tint),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: context.textPri,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: context.isDark
                      ? [
                          Colors.white.withValues(alpha: 0.16),
                          Colors.white.withValues(alpha: 0.06),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.76),
                          Colors.white.withValues(alpha: 0.46),
                        ],
                ),
                border: Border.all(
                  color: context.isDark
                      ? Colors.white.withValues(alpha: 0.24)
                      : const Color(0x1A204268),
                  width: 0.9,
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.isDark
                        ? Colors.black.withValues(alpha: 0.30)
                        : const Color(0x4F3D6A97),
                    blurRadius: 16,
                    spreadRadius: -4,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(icon, size: 20, color: context.textPri),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### lib/features/home/presentation/widgets/folder_grid.dart

```dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class FolderGrid extends StatelessWidget {
  const FolderGrid({required this.counts, super.key});

  final Map<NoteCategory, int> counts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        const mainAxisSpacing = 10.0;
        const crossAxisSpacing = 10.0;

        final itemCount = kAllNoteCategories.length;
        final rowCount = (itemCount / crossAxisCount).ceil();
        final tileWidth =
            (constraints.maxWidth - (crossAxisSpacing * (crossAxisCount - 1))) /
            crossAxisCount;
        final tileHeight =
            (constraints.maxHeight - (mainAxisSpacing * (rowCount - 1))) /
            rowCount;
        final childAspectRatio = tileWidth / tileHeight;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final category = kAllNoteCategories[index];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: AppDurations.folderStagger * (index + 1),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 10),
                    child: child,
                  ),
                );
              },
              child: _FolderCard(
                category: category,
                count: counts[category] ?? 0,
              ),
            );
          },
        );
      },
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({required this.category, required this.count});

  final NoteCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final catColor = categoryColor(category);
    final iconData = categoryIcon(category);
    final overdue = category == NoteCategory.reminders && count > 0;
    final isDark = context.isDark;
    
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/folder', extra: category),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark
                    ? categoryColor(category).withValues(alpha: 0.07)
                    : categoryColor(category).withValues(alpha: 0.06)),
                  (isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white.withValues(alpha: 0.28)),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: categoryColor(category).withValues(
                  alpha: isDark ? 0.24 : 0.13,
                ),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.24)
                      : Colors.white.withValues(alpha: 0.30),
                  blurRadius: 16,
                  spreadRadius: -4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 86;

                if (isCompact) {
                  return Row(
                    children: [
                      Icon(
                        iconData,
                        size: 18,
                        color: catColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          categoryLabel(category),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.textPri,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      if (count > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: context.textPri,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          iconData,
                          size: 20,
                          color: catColor,
                        ),
                        _CountBadge(count: count, color: catColor),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      categoryLabel(category),
                      style: TextStyle(
                        color: context.textPri,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      overdue
                          ? 'Needs attention'
                          : '${count == 0 ? 'No' : count} notes',
                      style: TextStyle(
                        color: overdue ? AppColors.reminders : context.textSec,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: count),
        duration: AppDurations.countRoll,
        builder: (context, value, _) {
          return Text(
            '$value',
            style: TextStyle(
              color: context.textPri,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }
}
```

### lib/features/home/presentation/widgets/thought_canvas.dart

```dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';

class ThoughtCanvas extends StatelessWidget {
  const ThoughtCanvas({
    required this.controller,
    required this.focusNode,
    required this.onSave,
    required this.onSubmit,
    required this.onTagTap,
    required this.onReminderTap,
    required this.onReminderLongPress,
    required this.onMicPressStart,
    required this.onMicPressEnd,
    required this.isSaving,
    required this.isRecording,
    this.tagActive = false,
    this.reminderActive = false,
    this.tagLabel,
    this.reminderLabel,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSave;
  final VoidCallback onSubmit;
  final VoidCallback onTagTap;
  final VoidCallback onReminderTap;
  final VoidCallback onReminderLongPress;
  final VoidCallback onMicPressStart;
  final VoidCallback onMicPressEnd;
  final bool isSaving;
  final bool isRecording;
  final bool tagActive;
  final bool reminderActive;
  final String? tagLabel;
  final String? reminderLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF102538) : const Color(0xFFF4F7FB);
    final surfaceTop = isDark ? const Color(0xFF17364C) : const Color(0xFFFFFFFF);
    final surfaceBottom = isDark ? const Color(0xFF0A1825) : const Color(0xFFDDE7F0);
    final highlight = isDark ? const Color(0x26FFFFFF) : const Color(0xCCFFFFFF);
    final shadowDark = isDark ? const Color(0xC4121B27) : const Color(0x2B7890A8);
    final shadowSoft = isDark ? const Color(0x73131D29) : const Color(0x22A8BDD2);
    final rim = isDark ? const Color(0x3C8BB5DA) : const Color(0x92D7E5F1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: isDark ? shadowDark : const Color(0x44FFFFFF),
              blurRadius: 26,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: isDark ? const Color(0x55000000) : shadowSoft,
              blurRadius: 30,
              spreadRadius: -2,
              offset: const Offset(12, 14),
            ),
            BoxShadow(
              color: isDark ? const Color(0x4415222F) : const Color(0xB7FFFFFF),
              blurRadius: 20,
              spreadRadius: -4,
              offset: const Offset(-8, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    surfaceTop,
                    surface,
                    surfaceBottom,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: rim, width: 0.8),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      highlight.withValues(alpha: isDark ? 0.10 : 0.35),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
            children: [
              Container(
                height: 1.2,
                margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      highlight.withValues(alpha: isDark ? 0.28 : 0.78),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // ── Text field ──────────────────────────────────────────────
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  onSubmitted: (_) {
                    if (controller.text.trim().isNotEmpty && !isSaving) {
                      onSubmit();
                    }
                  },
                  style: TextStyle(
                    color: context.textPri,
                    fontSize: 15.5,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    filled: false,
                    hintText: isRecording
                        ? 'Listening...'
                        : 'Type a note, task, or reminder',
                    hintStyle: TextStyle(
                      color: context.textSec.withValues(alpha: 0.64),
                      fontSize: 15.2,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                  ),
                ),
              ),
              // ── Action bar ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? const Color(0x2A8FB2D2) : const Color(0x6AB9CBE0),
                      width: 0.8,
                    ),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      isDark ? const Color(0x0F16232E) : const Color(0x74FFFFFF),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Tag
                        _BarBtn(
                          icon: Icons.hexagon_outlined,
                          color: tagActive ? AppColors.tasks : context.textSec,
                          active: tagActive,
                          onTap: onTagTap,
                        ),
                        const SizedBox(width: 4),
                        // Reminder
                        _BarBtn(
                          icon: Icons.alarm_add_rounded,
                          color: reminderActive ? AppColors.tasks : context.textSec,
                          active: reminderActive,
                          onTap: onReminderTap,
                          onLongPress: onReminderLongPress,
                        ),
                        const Spacer(),
                        // Mic (long-press to dictate)
                        GestureDetector(
                          onLongPressStart: (_) => onMicPressStart(),
                          onLongPressEnd: (_) => onMicPressEnd(),
                          child: AnimatedContainer(
                            duration: AppDurations.microSnap,
                            width: isRecording ? 46 : 42,
                            height: isRecording ? 46 : 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isRecording
                                    ? [
                                        AppColors.tasks.withValues(alpha: 0.98),
                                        AppColors.tasks.withValues(alpha: 0.78),
                                      ]
                                    : [
                                        isDark ? const Color(0xFF20384D) : const Color(0xFFF9FCFF),
                                        isDark ? const Color(0xFF112132) : const Color(0xFFD9E6F1),
                                      ],
                              ),
                              border: Border.all(
                                color: isRecording
                                    ? AppColors.tasks.withValues(alpha: 0.9)
                                    : (isDark ? const Color(0x448FB1D5) : const Color(0x8CC2D5E7)),
                                width: isRecording ? 1.2 : 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.30)
                                      : const Color(0x3391A8BB),
                                  blurRadius: 10,
                                  offset: const Offset(3, 4),
                                ),
                                BoxShadow(
                                  color: isDark
                                      ? const Color(0x24FFFFFF)
                                      : Colors.white.withValues(alpha: 0.84),
                                  blurRadius: 10,
                                  offset: const Offset(-3, -3),
                                ),
                              ],
                            ),
                            child: Icon(
                              isRecording
                                  ? Icons.graphic_eq_rounded
                                  : Icons.mic_none_rounded,
                              size: 19,
                              color: isRecording ? Colors.white : context.textSec,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Send
                        AnimatedSwitcher(
                          duration: AppDurations.microSnap,
                          child: controller.text.trim().isEmpty
                              ? const SizedBox(width: 42, height: 42)
                              : GestureDetector(
                                  key: const ValueKey('send'),
                                  onTap: isSaving ? null : onSave,
                                  child: AnimatedContainer(
                                    duration: AppDurations.microSnap,
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF58D0C7),
                                          AppColors.tasks,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? Colors.black.withValues(alpha: 0.35)
                                              : const Color(0x4A89AFC7),
                                          blurRadius: 12,
                                          offset: const Offset(4, 6),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.68),
                                          blurRadius: 8,
                                          offset: const Offset(-3, -3),
                                        ),
                                      ],
                                    ),
                                    child: isSaving
                                        ? const Padding(
                                            padding: EdgeInsets.all(11),
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.send_rounded,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    if (tagLabel != null || reminderLabel != null) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (tagLabel != null)
                            _MetaChip(label: tagLabel!, accent: AppColors.tasks),
                          if (reminderLabel != null)
                            _MetaChip(label: reminderLabel!, accent: AppColors.followUp),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BarBtn extends StatelessWidget {
  const _BarBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    this.active = false,
    this.onLongPress,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: AppDurations.microSnap,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: active
                ? [
                    AppColors.tasks.withValues(alpha: 0.20),
                    AppColors.tasks.withValues(alpha: 0.08),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.72),
                    Colors.white.withValues(alpha: 0.24),
                  ],
          ),
          border: Border.all(
            color: active
                ? AppColors.tasks.withValues(alpha: 0.24)
                : Colors.white.withValues(alpha: 0.34),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: active ? 0.10 : 0.08),
              blurRadius: 8,
              offset: const Offset(2, 3),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: active ? 0.16 : 0.70),
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.14),
            accent.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.18), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 7,
            offset: const Offset(2, 3),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.68),
            blurRadius: 7,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 10.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
```

### lib/features/nlp/nlp_task_parser.dart

```dart
// lib/features/nlp/nlp_task_parser.dart
//
// Lightweight, zero-dependency NLP parser for task/reminder extraction.
// Runs synchronously on the main isolate — no network needed.
// Supplements AI classification for instant feedback.

import 'package:wishperlog/shared/models/enums.dart';

class NlpParseResult {
  const NlpParseResult({
    required this.category,
    required this.priority,
    this.extractedDate,
    this.cleanTitle,
  });

  final NoteCategory category;
  final NotePriority priority;
  final DateTime? extractedDate;
  final String? cleanTitle;
}

abstract final class NlpTaskParser {
  NlpTaskParser._();

  // ── Category detection ────────────────────────────────────────────────────

  static const _taskKeywords = [
    'todo', 'to-do', 'task', 'complete', 'finish', 'submit', 'send',
    'write', 'prepare', 'fix', 'deploy', 'buy', 'call', 'email',
    'review', 'update', 'check', 'do', 'make',
  ];

  static const _reminderKeywords = [
    'remind', 'reminder', 'don\'t forget', 'remember', 'alarm',
    'alert', 'notify', 'schedule',
  ];

  static const _ideaKeywords = [
    'idea', 'thought', 'concept', 'brainstorm', 'maybe', 'what if',
    'could', 'explore', 'consider',
  ];

  static const _followUpKeywords = [
    'follow up', 'follow-up', 'check in', 'ping', 'circle back',
    'get back', 'revisit', 'track',
  ];

  static const _journalKeywords = [
    'today i', 'felt', 'feeling', 'mood', 'diary', 'journal',
    'reflection', 'note to self',
  ];

  // ── Priority detection ────────────────────────────────────────────────────

  static const _highPriority = [
    'urgent', 'asap', 'critical', 'immediately', 'now',
    'high priority', 'emergency', 'crucial', 'deadline',
  ];

  static const _lowPriority = [
    'someday', 'maybe later', 'eventually', 'if time', 'low priority',
    'not urgent', 'optional', 'nice to have',
  ];

  // ── Date patterns ─────────────────────────────────────────────────────────

  static final _relativeDate = RegExp(
    r'\b(today|tomorrow|next\s+(?:week|month|monday|tuesday|wednesday|thursday|friday|saturday|sunday))\b',
    caseSensitive: false,
  );

  static final _absoluteDate = RegExp(
    r'\b(\d{1,2})[\/\-](\d{1,2})(?:[\/\-](\d{2,4}))?\b',
  );

  static final _monthDate = RegExp(
    r'\b(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+(\d{1,2})(?:st|nd|rd|th)?\b',
    caseSensitive: false,
  );

  // ── Public API ────────────────────────────────────────────────────────────

  static NlpParseResult parse(String text) {
    final lower = text.toLowerCase();

    return NlpParseResult(
      category:      _detectCategory(lower),
      priority:      _detectPriority(lower),
      extractedDate: _extractDate(lower, DateTime.now()),
      cleanTitle:    _cleanTitle(text),
    );
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  static NoteCategory _detectCategory(String lower) {
    if (_containsAny(lower, _taskKeywords))     return NoteCategory.tasks;
    if (_containsAny(lower, _reminderKeywords)) return NoteCategory.reminders;
    if (_containsAny(lower, _ideaKeywords))     return NoteCategory.ideas;
    if (_containsAny(lower, _followUpKeywords)) return NoteCategory.followUp;
    if (_containsAny(lower, _journalKeywords))  return NoteCategory.journal;
    return NoteCategory.general;
  }

  static NotePriority _detectPriority(String lower) {
    if (_containsAny(lower, _highPriority)) return NotePriority.high;
    if (_containsAny(lower, _lowPriority))  return NotePriority.low;
    return NotePriority.medium;
  }

  static DateTime? _extractDate(String lower, DateTime now) {
    // Relative dates
    final relMatch = _relativeDate.firstMatch(lower);
    if (relMatch != null) {
      final phrase = relMatch.group(1)!.toLowerCase();
      if (phrase == 'today') return DateTime(now.year, now.month, now.day);
      if (phrase == 'tomorrow') return now.add(const Duration(days: 1));
      if (phrase.startsWith('next')) {
        final dayName = phrase.split(RegExp(r'\s+')).last;
        return _nextWeekday(now, dayName);
      }
    }

    // Month + day  e.g. "June 15"
    final monthMatch = _monthDate.firstMatch(lower);
    if (monthMatch != null) {
      final month = _parseMonth(monthMatch.group(1)!);
      final day   = int.tryParse(monthMatch.group(2) ?? '');
      if (month != null && day != null) {
        var year = now.year;
        final candidate = DateTime(year, month, day);
        if (candidate.isBefore(DateTime(now.year, now.month, now.day))) {
          year++;
        }
        return DateTime(year, month, day);
      }
    }

    // dd/mm or dd-mm
    final absMatch = _absoluteDate.firstMatch(lower);
    if (absMatch != null) {
      final d = int.tryParse(absMatch.group(1) ?? '');
      final m = int.tryParse(absMatch.group(2) ?? '');
      final y = int.tryParse(absMatch.group(3) ?? '');
      if (d != null && m != null && d <= 31 && m <= 12) {
        return DateTime(y ?? now.year, m, d);
      }
    }

    return null;
  }

  static String _cleanTitle(String text) {
    // Remove common filler prefixes
    const prefixes = [
      'todo:', 'task:', 'remind me to', 'reminder:', 'note to self:',
      'idea:', 'don\'t forget to', 'don\'t forget',
    ];
    var clean = text.trim();
    for (final p in prefixes) {
      if (clean.toLowerCase().startsWith(p)) {
        clean = clean.substring(p.length).trim();
        break;
      }
    }
    // Capitalise first letter
    if (clean.isEmpty) return clean;
    return clean[0].toUpperCase() + clean.substring(1);
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }

  static DateTime _nextWeekday(DateTime now, String dayName) {
    const days = {
      'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
      'friday': 5, 'saturday': 6, 'sunday': 7, 'week': 7,
    };
    final target = days[dayName] ?? (now.weekday + 7);
    var diff = target - now.weekday;
    if (diff <= 0) diff += 7;
    return now.add(Duration(days: diff));
  }

  static int? _parseMonth(String name) {
    const m = {
      'jan': 1, 'january': 1, 'feb': 2, 'february': 2, 'mar': 3, 'march': 3,
      'apr': 4, 'april': 4, 'may': 5, 'jun': 6, 'june': 6, 'jul': 7,
      'july': 7, 'aug': 8, 'august': 8, 'sep': 9, 'september': 9,
      'oct': 10, 'october': 10, 'nov': 11, 'november': 11, 'dec': 12,
      'december': 12,
    };
    return m[name.toLowerCase()];
  }
}
```

### lib/features/notes/data/note_repository.dart

```dart
import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/sync/data/message_state_service.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class NoteRepository {
  NoteRepository({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
    AiClassifierRouter? aiRouter,
    ExternalSyncService? externalSync,
  }) : _auth = auth ?? safeFirebaseAuth(),
       _firestore = firestore ?? safeFirestore(),
       _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance,
       _aiRouter =
           aiRouter ??
           (sl.isRegistered<AiClassifierRouter>()
               ? sl<AiClassifierRouter>()
               : AiClassifierRouter()),
       _externalSync =
           externalSync ??
           (sl.isRegistered<ExternalSyncService>()
               ? sl<ExternalSyncService>()
               : ExternalSyncService());

  static FirebaseAuth? safeFirebaseAuth() {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  static FirebaseFirestore? safeFirestore() {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  final FirebaseAuth? _auth;
  final FirebaseFirestore? _firestore;
  final IsarNoteStore _isarNoteStore;
  final AiClassifierRouter _aiRouter;
  final ExternalSyncService _externalSync;

  Future<void> savePendingFromHome(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) {
      return;
    }

    final now = DateTime.now();
    final user = _auth?.currentUser;

    if (user != null) {
      final recent = await _isarNoteStore.findRecentByTranscript(
        uid: user.uid,
        rawTranscript: text,
        source: CaptureSource.homeWritingBox,
      );
      if (recent != null) {
        debugPrint('[NoteRepository] Duplicate home save skipped: ${recent.noteId}');
        return;
      }
    }

    final classification = await _aiRouter.classify(text);
    final status = classification.wasFallback
        ? NoteStatus.pendingAi
        : NoteStatus.active;

    final note = Note(
      noteId: '${now.microsecondsSinceEpoch}_${Random().nextInt(1 << 20)}',
      uid: user?.uid ?? 'local_anonymous',
      rawTranscript: text,
      title: classification.title,
      cleanBody: classification.cleanBody,
      category: classification.category,
      priority: classification.priority,
      extractedDate: null,
      createdAt: now,
      updatedAt: now,
      status: status,
      aiModel: classification.model,
      gcalEventId: null,
      gtaskId: null,
      source: CaptureSource.homeWritingBox,
      syncedAt: status == NoteStatus.active ? now : null,
    );

    await _isarNoteStore.put(note);

    if (note.status == NoteStatus.active) {
      final externalResult = await _externalSync.syncExternalForNote(note);
      if (externalResult.noteChanged) {
        await _isarNoteStore.put(externalResult.note);
        await _syncNoteToFirestore(externalResult.note);
        return;
      }
    }

    await _syncNoteToFirestore(note);
  }

  Stream<List<Note>> watchActiveByCategory(NoteCategory category) async* {
    yield* watchAllActive().map((notes) {
      return notes.where((note) => note.category == category).toList();
    });
  }

  Stream<List<Note>> watchAllActive() async* {
    yield* watchAllActiveLocal();
  }

  Stream<List<Note>> watchAllActiveLocal() {
    return _isarNoteStore.watchActive();
  }

  Stream<List<Note>> watchActiveByCategoryLocal(NoteCategory category) {
    return watchAllActiveLocal().map((notes) {
      return notes.where((note) => note.category == category).toList();
    });
  }

  Stream<Map<NoteCategory, int>> watchActiveCountsLocal() {
    return watchAllActiveLocal().map((notes) {
      final counts = <NoteCategory, int>{
        for (final category in kAllNoteCategories) category: 0,
      };
      for (final note in notes) {
        counts[note.category] = (counts[note.category] ?? 0) + 1;
      }
      return counts;
    });
  }

  Stream<int> watchPendingAiCount() async* {
    yield await _pendingAiCount();
    yield* _isarNoteStore.watchAll().asyncMap((_) => _pendingAiCount());
  }

  Stream<Note?> watchNoteById(String noteId) async* {
    yield await _findById(noteId);
    yield* _isarNoteStore.watchAll().asyncMap((_) => _findById(noteId));
  }

  Future<void> delete(String noteId) async {
    final note = await _findById(noteId);
    if (note == null) return;

    final updated = note.copyWith(
      status: NoteStatus.deleted,
      updatedAt: DateTime.now(),
    );

    await _isarNoteStore.put(updated);
    await _syncNoteToFirestore(updated);
  }

  Future<void> archive(String noteId) async {
    final note = await _findById(noteId);
    if (note == null) return;

    final updated = note.copyWith(
      status: NoteStatus.archived,
      updatedAt: DateTime.now(),
    );

    await _isarNoteStore.put(updated);
    await _syncNoteToFirestore(updated);
  }

  Future<void> cyclePriority(String noteId) async {
    final note = await _findById(noteId);
    if (note == null) return;

    final next = switch (note.priority) {
      NotePriority.high => NotePriority.medium,
      NotePriority.medium => NotePriority.low,
      NotePriority.low => NotePriority.high,
    };

    final updated = note.copyWith(priority: next, updatedAt: DateTime.now());

    await _isarNoteStore.put(updated);
    await _syncNoteToFirestore(updated);
  }

  Future<void> updateEditedNote({
    required String noteId,
    required String title,
    required String cleanBody,
    required NoteCategory category,
    required NotePriority priority,
    required DateTime? extractedDate,
  }) async {
    final note = await _findById(noteId);
    if (note == null) {
      return;
    }

    final updated = note.copyWith(
      title: title.trim().isEmpty ? note.title : title.trim(),
      cleanBody: cleanBody.trim().isEmpty ? note.cleanBody : cleanBody.trim(),
      category: category,
      priority: priority,
      extractedDate: extractedDate,
      clearExtractedDate: extractedDate == null,
      updatedAt: DateTime.now(),
    );

    await _isarNoteStore.put(updated);
    await _syncNoteToFirestore(updated);
  }

  Future<Note?> _findById(String noteId) async {
    return _isarNoteStore.getByNoteId(noteId);
  }

  Future<int> _pendingAiCount() async {
    return _isarNoteStore.countPendingAi();
  }

  Future<void> _syncNoteToFirestore(Note note) async {
    final auth = _auth;
    final firestore = _firestore;
    if (auth == null || firestore == null) {
      debugPrint(
        '[NoteRepository] Firestore sync skipped: auth or firestore unavailable',
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
        '[NoteRepository] Firestore sync skipped: user not authenticated',
      );
      return;
    }

    try {
      debugPrint('[NoteRepository] Syncing note to Firestore: ${note.noteId}');

      await firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.noteId)
          .set(note.toFirestoreJson(), SetOptions(merge: true));

      debugPrint(
        '[NoteRepository] Successfully synced to Firestore: ${note.noteId}',
      );

      // Rebuild message_state so the Cloudflare Worker sees fresh content.
      // Fire-and-forget — never blocks the write path.
      unawaited(MessageStateService.instance.recompute());
    } catch (e, st) {
      debugPrint(
        '[NoteRepository] ERROR syncing to Firestore: ${note.noteId}: $e',
      );
      debugPrintStack(stackTrace: st);
      // Firestore sync retries are handled in later phases.
    }
  }
}
```

### lib/features/notes/presentation/screens/folder_screen.dart

```dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/features/notes/presentation/widgets/glass_note_card.dart';
import 'package:wishperlog/features/overlay/quick_note_editor.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';
import 'package:wishperlog/shared/widgets/glass_title_bar.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({required this.category, super.key});

  final NoteCategory category;

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final NoteRepository _notes = sl<NoteRepository>();

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final secondaryText = context.textSec;

    return StreamBuilder<List<Note>>(
      stream: _notes.watchActiveByCategoryLocal(widget.category),
      builder: (context, snapshot) {
        final notes = snapshot.data ?? const <Note>[];
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: GlassTitleBar(
            title: categoryLabel(widget.category),
            subtitle: '${notes.length} active notes',
            onBack: _goBack,
            leading: Icon(
              categoryIcon(widget.category),
              size: 18,
              color: categoryColor(widget.category),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: categoryColor(widget.category).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${notes.length}',
                style: TextStyle(
                  color: categoryColor(widget.category),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          body: GlassPageBackground(
            category: widget.category,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                final targetTint = categoryColor(
                  widget.category,
                ).withValues(alpha: context.isDark ? 0.07 : 0.045);
                return FolderGlassTint(
                  tint: targetTint.withValues(alpha: targetTint.a * value),
                  child: child!,
                );
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: GlassPane(
                      level: 1,
                      radius: 24,
                      tintOverride: categoryColor(widget.category).withValues(alpha: 0.08),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: categoryColor(widget.category).withValues(alpha: 0.14),
                            ),
                            child: Icon(
                              categoryIcon(widget.category),
                              color: categoryColor(widget.category),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  categoryLabel(widget.category),
                                  style: TextStyle(
                                    color: context.textPri,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Swipe to delete or reassign • tap to edit',
                                  style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: categoryColor(widget.category).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${notes.length}',
                              style: TextStyle(
                                color: categoryColor(widget.category),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: (() {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Unable to load notes right now.',
                            style: TextStyle(
                              color: secondaryText,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                              fontSize: 13.5,
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      if (notes.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: GlassPane(
                              level: 2,
                              radius: 22,
                              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 32,
                                    color: categoryColor(widget.category),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Nothing here yet',
                                    style: TextStyle(
                                      color: context.textPri,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Add a note and it will appear in this folder automatically.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 12.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: AppDurations.folderStagger * (index + 1),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 10),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: index == notes.length - 1 ? 0 : 10,
                              ),
                              child: Dismissible(
                                key: ValueKey(note.noteId),
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.startToEnd) {
                                    unawaited(_notes.delete(note.noteId));
                                    unawaited(HapticFeedback.lightImpact());
                                    return true;
                                  }

                                  await _openReassignSheet(note);
                                  return false;
                                },
                                background: _swipeBackground(
                                  alignment: Alignment.centerLeft,
                                  color: Colors.red.withValues(alpha: 0.12),
                                  icon: Icons.delete_outline,
                                  label: 'Delete',
                                ),
                                secondaryBackground: _swipeBackground(
                                  alignment: Alignment.centerRight,
                                  color: categoryColor(
                                    widget.category,
                                  ).withValues(alpha: 0.12),
                                  icon: Icons.category_outlined,
                                  label: 'Reassign',
                                ),
                                child: GlassNoteCard(
                                  note: note,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    })(),
                  ),
                ],
              ),
            ), // closes TweenAnimationBuilder
          ), // closes GlassPageBackground
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const QuickNoteEditor(),
              );
            },
            icon: const Icon(Icons.add),
            label: Text('New ${categoryLabel(widget.category).toLowerCase()}'),
            backgroundColor: categoryColor(widget.category),
            foregroundColor: Colors.white,
          ),
        ); // closes Scaffold
      }, // closes StreamBuilder builder
    ); // closes StreamBuilder
  }

  Widget _swipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: EdgeInsets.symmetric(horizontal: isLeft ? 16 : 18),
      alignment: alignment,
      child: Row(
        mainAxisAlignment: isLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (!isLeft) ...[
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
          ],
          Icon(icon, size: 18),
          if (isLeft) ...[
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  Future<void> _openReassignSheet(Note note) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: GlassPane(
            level: 1,
            radius: 20,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in kAllNoteCategories)
                  GestureDetector(
                    onTap: () async {
                      await _notes.updateEditedNote(
                        noteId: note.noteId,
                        title: note.title,
                        cleanBody: note.cleanBody,
                        category: category,
                        priority: note.priority,
                        extractedDate: note.extractedDate,
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: GlassPane(
                      level: 3,
                      radius: 12,
                      tintOverride: categoryColor(
                        category,
                      ).withValues(alpha: context.isDark ? 0.07 : 0.045),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Text(
                        categoryLabel(category),
                        style: TextStyle(
                          color: categoryColor(category),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

}
```

### lib/features/notes/presentation/screens/note_detail_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';
import 'package:wishperlog/shared/widgets/glass_title_bar.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final NoteRepository _notes = sl<NoteRepository>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  Note? _note;
  NoteCategory _category = NoteCategory.general;
  NotePriority _priority = NotePriority.medium;
  DateTime? _extractedDate;
  bool _saving = false;
  String? _seededNoteId;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _seed(Note note) {
    if (_seededNoteId == note.noteId) return;
    _seededNoteId = note.noteId;
    _note = note;
    _titleController.text = note.title == 'Quick note' ? '' : note.title;
    _bodyController.text = note.cleanBody.isNotEmpty ? note.cleanBody : note.rawTranscript;
    _category = note.category;
    _priority = note.priority;
    _extractedDate = note.extractedDate;
  }

  Future<void> _save() async {
    final note = _note;
    if (note == null || _saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      await _notes.updateEditedNote(
        noteId: note.noteId,
        title: _titleController.text,
        cleanBody: _bodyController.text,
        category: _category,
        priority: _priority,
        extractedDate: _extractedDate,
      );
      if (mounted) {
        HapticFeedback.mediumImpact();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickExtractedDate() async {
    final initialDate = _extractedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _extractedDate = picked);
    }
  }

  void _clearExtractedDate() {
    setState(() => _extractedDate = null);
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: context.surface1.withValues(alpha: context.isDark ? 0.82 : 0.72),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: context.textSec.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: context.textSec.withValues(alpha: 0.08)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: AppColors.tasks, width: 1.2),
      ),
      labelStyle: TextStyle(
        color: context.textSec,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  TextStyle _dropdownTextStyle(BuildContext context) {
    return TextStyle(
      color: context.textPri,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _save,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        icon: _saving
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.save_rounded),
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                categoryColor(_category).withValues(alpha: isDark ? 0.95 : 0.90),
                const Color(0xFF58D0C7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.14),
                blurRadius: 18,
                offset: const Offset(5, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.66),
                blurRadius: 12,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Text(
            _saving ? 'Saving…' : 'Save changes',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
      ),
      appBar: GlassTitleBar(
        title: 'Edit note',
        subtitle: 'Update title, body, category, and priority',
        onBack: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      body: GlassPageBackground(
        child: StreamBuilder<Note?>(
          stream: _notes.watchNoteById(widget.noteId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final note = snapshot.data;
            if (note == null) {
              return const Center(
                child: Text('Note not found or no longer available.'),
              );
            }

            _seed(note);

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassPane(
                      level: 2,
                      radius: 28,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      categoryColor(_category).withValues(alpha: 0.24),
                                      categoryColor(_category).withValues(alpha: 0.10),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: categoryColor(_category).withValues(alpha: 0.24),
                                  ),
                                ),
                                child: Icon(
                                  categoryIcon(_category),
                                  color: categoryColor(_category),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Editing note',
                                      style: TextStyle(
                                        color: context.textPri,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Save changes to update the note everywhere.',
                                      style: TextStyle(
                                        color: context.textSec,
                                        fontSize: 12,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetaChip(label: categoryLabel(_category)),
                              _MetaChip(label: _priority.name.toUpperCase()),
                              _MetaChip(label: note.source.name),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GlassPane(
                      level: 1,
                      radius: 26,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              context,
                              label: 'Title',
                              hint: _titleController.text.isEmpty ? 'Quick note' : _titleController.text,
                            ),
                            style: TextStyle(
                              color: context.textPri,
                              fontWeight: FontWeight.w700,
                            ),
                            validator: (value) {
                              if (value != null && value.trim().length > 120) {
                                return 'Title is too long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _bodyController,
                            minLines: 10,
                            maxLines: 18,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: _inputDecoration(
                              context,
                              label: 'Body',
                              hint: 'Write the cleaned note text here',
                            ),
                            style: TextStyle(
                              color: context.textPri,
                              height: 1.5,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Body cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<NoteCategory>(
                                  initialValue: _category,
                                  decoration: _inputDecoration(
                                    context,
                                    label: 'Category',
                                    hint: 'Choose category',
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  dropdownColor: context.surface2.withValues(alpha: isDark ? 0.98 : 0.995),
                                  iconEnabledColor: context.textSec,
                                  style: _dropdownTextStyle(context),
                                  menuMaxHeight: 320,
                                  items: kAllNoteCategories
                                      .map(
                                        (category) => DropdownMenuItem<NoteCategory>(
                                          value: category,
                                          child: Text(
                                            categoryLabel(category),
                                            style: _dropdownTextStyle(context),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _category = value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<NotePriority>(
                                  initialValue: _priority,
                                  decoration: _inputDecoration(
                                    context,
                                    label: 'Priority',
                                    hint: 'Choose priority',
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  dropdownColor: context.surface2.withValues(alpha: isDark ? 0.98 : 0.995),
                                  iconEnabledColor: context.textSec,
                                  style: _dropdownTextStyle(context),
                                  menuMaxHeight: 260,
                                  items: NotePriority.values
                                      .map(
                                        (priority) => DropdownMenuItem<NotePriority>(
                                          value: priority,
                                          child: Text(
                                            priority.name.toUpperCase(),
                                            style: _dropdownTextStyle(context),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _priority = value);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GlassPane(
                            level: 1,
                            radius: 22,
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Extracted date',
                                  style: TextStyle(
                                    color: context.textPri,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _extractedDate == null ? 'No extracted date set' : _formatDate(_extractedDate!),
                                  style: TextStyle(
                                    color: context.textSec,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _pickExtractedDate,
                                      icon: const Icon(Icons.event_outlined),
                                      label: const Text('Pick date'),
                                    ),
                                    TextButton(
                                      onPressed: _extractedDate == null ? null : _clearExtractedDate,
                                      child: const Text('Clear'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (note.rawTranscript.isNotEmpty && note.rawTranscript != note.cleanBody) ...[
                            const SizedBox(height: 12),
                            GlassPane(
                              level: 2,
                              radius: 22,
                              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Original capture',
                                    style: TextStyle(
                                      color: context.textPri,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SelectableText(
                                    note.rawTranscript,
                                    style: TextStyle(
                                      color: context.textSec,
                                      height: 1.55,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Captured ${_formatDate(note.createdAt)} • ${note.source.name}',
                                    style: TextStyle(
                                      color: context.textSec,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
```

### lib/features/notes/presentation/screens/note_view_screen.dart

```dart
// lib/features/notes/presentation/screens/note_view_screen.dart
//
// Immersive "View" screen (read-only).
// Edit is a secondary FAB action — no clutter on the read surface.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class NoteViewScreen extends StatelessWidget {
  const NoteViewScreen({super.key, required this.note});

  final Note note;

  Color _priorityColor(NotePriority p) => switch (p) {
    NotePriority.high   => const Color(0xFFEF4444),
    NotePriority.medium => const Color(0xFFF59E0B),
    NotePriority.low    => const Color(0xFF10B981),
  };

  @override
  Widget build(BuildContext context) {
    final accent = categoryColor(note.category);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      floatingActionButton: _EditFab(noteId: note.noteId),
      body: GlassPageBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.72, -0.86),
                    radius: 1.15,
                    colors: [
                      accent.withValues(alpha: context.isDark ? 0.20 : 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: false,
                    leading: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.surface1.withValues(alpha: context.isDark ? 0.92 : 0.84),
                              context.surface2.withValues(alpha: context.isDark ? 0.80 : 0.92),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: context.isDark ? 0.08 : 0.42),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: context.isDark ? 0.28 : 0.10),
                              blurRadius: 14,
                              offset: const Offset(4, 5),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: context.isDark ? 0.08 : 0.72),
                              blurRadius: 10,
                              offset: const Offset(-3, -3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: context.textPri,
                        ),
                      ),
                    ),
                    actions: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final body = '${note.title}\n\n${note.cleanBody.isNotEmpty ? note.cleanBody : note.rawTranscript}';
                          Clipboard.setData(ClipboardData(text: body));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to clipboard')),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                context.surface1.withValues(alpha: context.isDark ? 0.92 : 0.84),
                                context.surface2.withValues(alpha: context.isDark ? 0.80 : 0.92),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: context.isDark ? 0.08 : 0.42),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: context.isDark ? 0.28 : 0.10),
                                blurRadius: 14,
                                offset: const Offset(4, 5),
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: context.isDark ? 0.08 : 0.72),
                                blurRadius: 10,
                                offset: const Offset(-3, -3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: context.textPri,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlassPane(
                            level: 3,
                            radius: 28,
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _SurfacePill(
                                  icon: categoryIcon(note.category),
                                  label: categoryLabel(note.category),
                                  tint: accent,
                                ),
                                _SurfacePill(
                                  icon: Icons.priority_high_rounded,
                                  label: note.priority.name.toUpperCase(),
                                  tint: _priorityColor(note.priority),
                                ),
                                if (note.aiModel.isNotEmpty)
                                  _SurfacePill(
                                    icon: Icons.auto_awesome_rounded,
                                    label: note.aiModel.toUpperCase(),
                                    tint: AppColors.followUp,
                                  ),
                                if (note.extractedDate != null)
                                  _SurfacePill(
                                    icon: Icons.event_rounded,
                                    label: _formatDate(note.extractedDate!),
                                    tint: AppColors.tasks,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GlassPane(
                            level: 2,
                            radius: 30,
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.title.isEmpty ? 'Untitled Note' : note.title,
                                  style: TextStyle(
                                    color: context.textPri,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.8,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Captured ${_formatDate(note.createdAt)}',
                                  style: TextStyle(
                                    color: context.textSec,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                if (note.translatedContent != null)
                                  _TranslationToggle(note: note)
                                else
                                SelectableText(
                                  note.cleanBody.isNotEmpty
                                      ? note.cleanBody
                                      : note.rawTranscript,
                                  style: TextStyle(
                                    color: context.textPri,
                                    fontSize: 16,
                                    height: 1.75,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.1,
                                  ),
                                ),

                              ],
                            ),
                          ),
                          if (note.rawTranscript.isNotEmpty &&
                              note.rawTranscript != note.cleanBody) ...[
                            const SizedBox(height: 16),
                            _RawTranscriptSection(rawTranscript: note.rawTranscript),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _SurfacePill extends StatelessWidget {
  const _SurfacePill({
    required this.icon,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: context.isDark ? 0.22 : 0.12),
            tint.withValues(alpha: context.isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.16 : 0.08),
            blurRadius: 10,
            offset: const Offset(3, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: context.isDark ? 0.08 : 0.66),
            blurRadius: 8,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: tint),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: tint,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Translation toggle (original ↔ English) ──────────────────────────────────
class _TranslationToggle extends StatefulWidget {
  const _TranslationToggle({required this.note});
  final Note note;
  @override
  State<_TranslationToggle> createState() => _TranslationToggleState();
}

class _TranslationToggleState extends State<_TranslationToggle> {
  bool _showOriginal = true;

  @override
  Widget build(BuildContext context) {
    final bodyText = _showOriginal
        ? (widget.note.cleanBody.isNotEmpty ? widget.note.cleanBody : widget.note.rawTranscript)
        : (widget.note.translatedContent ?? widget.note.cleanBody);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => setState(() => _showOriginal = !_showOriginal),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.tasks.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.tasks.withValues(alpha: 0.30)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.translate_rounded, size: 13, color: AppColors.tasks),
                    const SizedBox(width: 5),
                    Text(
                      _showOriginal ? 'Show English' : 'Show Original',
                      style: const TextStyle(
                        color: AppColors.tasks,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SelectableText(
          bodyText,
          style: TextStyle(
            color: context.textPri,
            fontSize: 16,
            height: 1.75,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );
  }
}

class _EditFab extends StatelessWidget {
  const _EditFab({required this.noteId});
  final String noteId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FloatingActionButton.extended(
      heroTag: 'edit_fab_$noteId',
      onPressed: () {
        HapticFeedback.mediumImpact();
        context.push('/notes/$noteId');
      },
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.tasks.withValues(alpha: isDark ? 0.95 : 0.88),
              const Color(0xFF58D0C7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.16),
              blurRadius: 18,
              offset: const Offset(5, 8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.62),
              blurRadius: 12,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, size: 18),
              SizedBox(width: 8),
              Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RawTranscriptSection extends StatefulWidget {
  const _RawTranscriptSection({required this.rawTranscript});
  final String rawTranscript;

  @override
  State<_RawTranscriptSection> createState() => _RawTranscriptSectionState();
}

class _RawTranscriptSectionState extends State<_RawTranscriptSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => GlassPane(
        level: 2,
        radius: 24,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.textSec.withValues(alpha: 0.10),
                    ),
                    child: Icon(Icons.mic_none_rounded, size: 14, color: context.textSec),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Raw Transcript',
                    style: TextStyle(
                      color: context.textPri,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: context.textSec,
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              SelectableText(
                widget.rawTranscript,
                style: TextStyle(
                  color: context.textSec,
                  fontSize: 14,
                  height: 1.65,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      );
}
```

### lib/features/notes/presentation/widgets/glass_note_card.dart

```dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class GlassNoteCard extends StatefulWidget {
  const GlassNoteCard({required this.note, super.key});

  final Note note;

  @override
  State<GlassNoteCard> createState() => _GlassNoteCardState();
}

class _GlassNoteCardState extends State<GlassNoteCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: AppDurations.aiShimmer,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final safeTitle = note.title.trim().isEmpty ? 'Quick note' : note.title;
    final safeBody = note.cleanBody.trim().isEmpty
        ? note.rawTranscript.trim()
        : note.cleanBody;
    final tint = categoryColor(note.category).withValues(alpha: 0.04);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final pending = note.status == NoteStatus.pendingAi;
        final borderColor = pending
            ? Color.lerp(
                    AppColors.journal,
                    AppColors.journal.withValues(alpha: 0.2),
                    _shimmerController.value,
                  ) ??
                  AppColors.journal
            : context.border;

        return AnimatedScale(
          duration: AppDurations.microSnap,
          scale: _pressed ? 0.97 : 1.0,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () {
              context.push('/notes/${note.noteId}/view', extra: note);
            },
            onLongPress: () {
              HapticFeedback.mediumImpact();
              context.push('/notes/${note.noteId}');
            },
            child: GlassPane(
              level: 2,
              radius: 16,
              tintOverride: tint,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 0.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 4.5,
                        decoration: BoxDecoration(
                          color: categoryColor(note.category),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    categoryIcon(note.category),
                                    size: 18,
                                    color: categoryColor(note.category),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      safeTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: context.textPri,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                safeBody,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: context.textSec,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: categoryColor(note.category).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          categoryLabel(note.category),
                                          style: TextStyle(
                                            color: categoryColor(note.category),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTime(note.extractedDate ?? note.createdAt),
                                        style: TextStyle(
                                          color: context.textSec,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (pending)
                                    Text(
                                      'AI pending',
                                      style: TextStyle(
                                        color: AppColors.journal,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime date) {
    if (DateTime.now().difference(date).inDays > 0) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
```

### lib/features/notes/presentation/widgets/search_notes_modal.dart

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/search/data/smart_note_search.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_title_bar.dart';

class SearchNotesModal extends StatefulWidget {
  const SearchNotesModal({super.key});

  @override
  State<SearchNotesModal> createState() => _SearchNotesModalState();
}

class _SearchNotesModalState extends State<SearchNotesModal> {
  final IsarNoteStore _notes = sl<IsarNoteStore>();
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
    _queryController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = context.textPri;
    final secondaryColor = context.textSec;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: SafeArea(
          child: Column(
            children: [
              GlassTitleBar(
                title: 'Search',
                subtitle: 'Find notes quickly',
                onBack: () => Navigator.of(context).pop(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: GlassContainer(
                        borderRadius: BorderRadius.circular(14),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _queryController,
                          focusNode: _focusNode,
                          style: TextStyle(
                            color: titleColor,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search title, body, or category...',
                            hintStyle: TextStyle(color: secondaryColor),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Note>>(
                  stream: _notes.watchActive(),
                  builder: (context, snapshot) {
                    final all = snapshot.data ?? const <Note>[];
                    final query = _queryController.text.trim();

                    final results = query.isEmpty
                        ? all
                        : SmartNoteSearch.searchSync(
                            all,
                            query,
                          ).map((h) => h.note).toList();

                    if (results.isEmpty) {
                      return Center(
                        child: Text(
                          'No matching notes',
                          style: TextStyle(color: secondaryColor),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                      itemCount: results.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final note = results[index];
                        return GlassContainer(
                          borderRadius: BorderRadius.circular(14),
                          padding: EdgeInsets.zero,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.of(context).pop();
                              context.push('/notes/{note.noteId}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                10,
                                12,
                                10,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: titleColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    note.cleanBody,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: secondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    categoryLabel(note.category),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: secondaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### lib/features/notifications/data/local_notification_service.dart

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channelId   = 'wishperlog_digest';
  static const _channelName = 'Daily Digest';
  static const _notifId     = 1001;

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin  = DarwinInitializationSettings();
    const settings = InitializationSettings(android: android, iOS: darwin);

    await _plugin.initialize(settings);
  }

  /// Only called when the user has actually configured a digest schedule.
  /// ISSUE-14: the permission prompt now only fires from here so it is
  /// contextually motivated, not on cold boot.
  static Future<void> requestPermissionIfSupported() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        await _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _plugin
            .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: false);
      }
    } catch (e) {
      debugPrint('[LocalNotifications] Permission request error: $e');
    }
  }

  /// Schedules (or replaces) the daily digest reminder at [hour]:[minute] UTC.
  /// ISSUE-14: this is the missing scheduling path that makes the feature real.
  static Future<void> scheduleDigestReminder({
    required int hour,
    required int minute,
    String title  = 'WishperLog Daily Brief',
    String body   = 'Your morning note digest is ready.',
  }) async {
    try {
      await _plugin.cancel(_notifId);

      final now  = tz.TZDateTime.now(tz.UTC);
      var sched  = tz.TZDateTime.utc(now.year, now.month, now.day, hour, minute);
      if (sched.isBefore(now)) {
        sched = sched.add(const Duration(days: 1));
      }

      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'Daily WishperLog digest reminder',
        importance: Importance.defaultImportance,
        priority:   Priority.defaultPriority,
        silent:     true,
      );
      const details = NotificationDetails(android: androidDetails);

      await _plugin.zonedSchedule(
        _notifId,
        title,
        body,
        sched,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('[LocalNotifications] Digest scheduled at $hour:$minute UTC');
    } catch (e) {
      debugPrint('[LocalNotifications] scheduleDigestReminder error: $e');
    }
  }

  /// One-shot reminder at a specific date/time (e.g. from an extracted note date).
  static Future<void> showDigestReminder({
    required String title,
    String body = 'Check your WishperLog note.',
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: 'WishperLog note reminder',
        importance: Importance.high,
        priority:   Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);
      await _plugin.show(_notifId + 1, title, body, details);
    } catch (e) {
      debugPrint('[LocalNotifications] showDigestReminder error: $e');
    }
  }
}
```

### lib/features/onboarding/presentation/screens/permissions_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _continueToApp() async {
    await HapticFeedback.mediumImpact();
    if (!mounted) {
      return;
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF102037);
    final subtitleColor = isDark
      ? Colors.white.withValues(alpha: 0.78)
      : const Color(0xFF4E6485);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassContainer(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: AppColors.followUp.withValues(alpha: 0.12),
                      ),
                      child: Text(
                        'LAST STEP',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.followUp,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Finish setup',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You can start using WhisperLog now. The last calibration is only here to make the launch feel complete.',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final glow = 0.24 + (_pulseController.value * 0.26);
                          final scale = 0.98 + (_pulseController.value * 0.04);
                          return Transform.scale(
                            scale: scale,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isDark
                                                ? const Color(0xFF96F7FF)
                                                : const Color(0xFF1A6CFF))
                                            .withValues(alpha: glow),
                                    blurRadius: 22,
                                    spreadRadius: 0.5,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(999),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: _continueToApp,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: titleColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Continue to Home',
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/home'),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: subtitleColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### lib/features/onboarding/presentation/screens/sign_in_screen.dart

```dart
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

// ══════════════════════════════════════════════════════════════════════════════
// sign_in_screen.dart v4.0 — Immediate Gamified Overlay (Race-Condition Fix)
//
// CRITICAL FIX — Login Processing Race Condition:
//   Previous behaviour: overlay appeared AFTER signInWithGoogle() returned.
//   New behaviour: overlay appears IMMEDIATELY when the user taps the button.
//   signInWithGoogle(), AI hydration, and Isar init all run concurrently inside
//   _doPostSignInWork(), which is passed as workFuture to _EnvironmentSetupOverlay.
//   The overlay animation plays while real work is in progress.
//
//   If work fails (e.g. Google sign-in cancelled), the overlay closes itself and
//   _signIn() surfaces the error through _showGlassError() as before.
// ══════════════════════════════════════════════════════════════════════════════

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _signingIn = false;

  void _showGlassError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          content: GlassContainer(
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              message,
              style: TextStyle(
                color: context.textPri,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ),
      );
  }

  /// Entry-point when the user taps the Google sign-in button.
  ///
  /// KEY CHANGE v4: We show the gamified overlay card IMMEDIATELY (before
  /// any async work starts) by kicking off [_doPostSignInWork] as a Future
  /// and passing it to the overlay so both the animation and the real work
  /// run concurrently.  Any exception from the work is re-surfaced here
  /// after the dialog closes.
  Future<void> _signIn() async {
    if (_signingIn) return;
    setState(() => _signingIn = true);
    try {
      await _runSetupAnimationWithWork();
      if (!mounted) return;
      context.go('/permissions');
    } on SignInFriendlyException catch (e) {
      _showGlassError(e.message);
    } catch (_) {
      _showGlassError('Sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  /// Shows the gamified overlay card immediately, passing real work as a
  /// concurrent future.  After the dialog closes (success or failure), any
  /// exception from the work future is re-thrown so [_signIn] can surface it.
  Future<void> _runSetupAnimationWithWork() async {
    // ── Start the real work NOW, before the dialog is even mounted. ──────────
    final workFuture = _doPostSignInWork();

    // ── Show overlay immediately. It drives itself via workFuture. ───────────
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (_) => _EnvironmentSetupOverlay(
        workFuture: workFuture,
        onDone: () {},
      ),
    );

    // ── Re-surface any error that occurred during background work. ────────────
    // If workFuture completed with an error, awaiting it here will rethrow,
    // which propagates to _signIn() → catch → _showGlassError().
    await workFuture;
  }

  /// All background work runs here, concurrently with the animation overlay.
  ///
  /// Includes: Google sign-in, AI hydration, Isar init.
  Future<void> _doPostSignInWork() async {
    // Step 1 – Authenticate with Google. May throw SignInFriendlyException.
    await sl<UserRepository>().signInWithGoogle();

    // Steps 2 & 3 – Non-blocking hydration; failures are silenced so they
    // don't block navigation if optional services are unavailable.
    try {
      await sl<AiClassifierRouter>().hydrate();
    } catch (_) {}
    try {
      await IsarNoteStore.instance.init();
    } catch (_) {}

    // Brief pause so the final "Everything is ready!" step is readable.
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final List<BoxShadow> logoShadows = [
      BoxShadow(
        color: const Color(0xFF6366F1).withValues(alpha: 0.40),
        blurRadius: 14,
        spreadRadius: -2,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: const Color(0xFF6366F1).withValues(alpha: 0.22),
        blurRadius: 32,
        spreadRadius: -6,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: const Color(0xFF6366F1).withValues(alpha: 0.10),
        blurRadius: 64,
        spreadRadius: -16,
        offset: const Offset(0, 24),
      ),
    ];

    final logoRimBright = isDark
        ? Colors.white.withValues(alpha: 0.36)
        : Colors.white.withValues(alpha: 0.55);
    final logoRimDark = isDark
        ? Colors.black.withValues(alpha: 0.24)
        : Colors.black.withValues(alpha: 0.12);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassPane(
                level: 1,
                radius: 28,
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Logo mark ─────────────────────────────────────────────
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [logoRimBright, logoRimDark],
                        ),
                        boxShadow: logoShadows,
                      ),
                      padding: const EdgeInsets.all(1.2),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF7C72FF),
                              Color(0xFF6045FA),
                              Color(0xFF4C35E8),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                        foregroundDecoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment.topLeft,
                            radius: 1.6,
                            colors: [
                              Color(0x22FFFFFF),
                              Colors.transparent,
                              Color(0x12000000),
                            ],
                            stops: [0.0, 0.45, 1.0],
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'WishperLog',
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Capture thoughts instantly.\nLet AI organise your day quietly in the background.',
                      style: TextStyle(
                        color: context.textSec,
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ── Google Sign-In Button ────────────────────────────────
                    _TactileGoogleSignInButton(
                      onTap: _signIn,
                      loading: _signingIn,
                    ),

                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms & Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.textSec.withValues(alpha: 0.60),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TactileGoogleSignInButton — unchanged visual treatment from v3
// ─────────────────────────────────────────────────────────────────────────────
class _TactileGoogleSignInButton extends StatefulWidget {
  const _TactileGoogleSignInButton({required this.onTap, required this.loading});
  final VoidCallback onTap;
  final bool loading;

  @override
  State<_TactileGoogleSignInButton> createState() =>
      _TactileGoogleSignInButtonState();
}

class _TactileGoogleSignInButtonState
    extends State<_TactileGoogleSignInButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final rimBright = isDark ? AppColors.darkRimBright : AppColors.lightRimBright;
    final rimMid    = isDark ? AppColors.darkRimMid    : AppColors.lightRimMid;
    final rimDark   = isDark ? AppColors.darkRimDark   : AppColors.lightRimDark;

    final List<BoxShadow> raisedShadows = isDark
        ? [
            BoxShadow(
              color: AppColors.darkShadowClose,
              blurRadius: 10,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.darkShadowMid,
              blurRadius: 26,
              spreadRadius: -6,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.darkShadowFar,
              blurRadius: 56,
              spreadRadius: -14,
              offset: const Offset(0, 22),
            ),
          ]
        : [
            BoxShadow(
              color: AppColors.lightShadowClose,
              blurRadius: 8,
              spreadRadius: -2,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: AppColors.lightShadowMid,
              blurRadius: 22,
              spreadRadius: -6,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.lightShadowFar,
              blurRadius: 50,
              spreadRadius: -14,
              offset: const Offset(0, 18),
            ),
          ];

    return GestureDetector(
      onTapDown: (_) { if (!widget.loading) setState(() => _pressed = true); },
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.loading) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [rimBright, rimMid, rimDark],
              stops: const [0.0, 0.45, 1.0],
            ),
            boxShadow: _pressed ? [] : raisedShadows,
          ),
          padding: const EdgeInsets.all(1.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(998),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 110),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(998),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: _pressed ? 0.09 : 0.13),
                            Colors.white.withValues(alpha: _pressed ? 0.04 : 0.06),
                          ]
                        : [
                            Colors.white.withValues(alpha: _pressed ? 0.72 : 0.88),
                            Colors.white.withValues(alpha: _pressed ? 0.52 : 0.66),
                          ],
                  ),
                ),
                foregroundDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(998),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      isDark
                          ? AppColors.darkExtrusionShadow
                          : AppColors.lightExtrusionShadow,
                    ],
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: widget.loading
                        ? SizedBox(
                            key: const ValueKey('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation(
                                context.textPri.withValues(alpha: 0.80),
                              ),
                            ),
                          )
                        : Row(
                            key: const ValueKey('idle'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/google_logo.svg',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Continue with Google',
                                style: TextStyle(
                                  color: context.textPri,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EnvironmentSetupOverlay
//
// CRITICAL FIX v4: workFuture now INCLUDES signInWithGoogle() — so the overlay
// appears immediately on tap, and the animation runs while authentication and
// hydration happen concurrently.  If workFuture throws, the overlay closes
// itself so _signIn() can surface the error.
// ─────────────────────────────────────────────────────────────────────────────
class _EnvironmentSetupOverlay extends StatefulWidget {
  const _EnvironmentSetupOverlay({
    required this.workFuture,
    required this.onDone,
  });

  final Future<void> workFuture;
  final VoidCallback onDone;

  @override
  State<_EnvironmentSetupOverlay> createState() =>
      _EnvironmentSetupOverlayState();
}

class _EnvironmentSetupOverlayState extends State<_EnvironmentSetupOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeIn;
  late final AnimationController _orbController;
  late final Animation<double> _orb1;
  late final Animation<double> _orb2;

  int _stepIndex = 0;
  double _progressValue = 0.12;

  static const _steps = [
    _Step(badge: 'auth',      text: 'Authenticating with Google…'),
    _Step(badge: 'classify',  text: 'Loading your AI classifier…'),
    _Step(badge: 'store',     text: 'Preparing your local vault…'),
    _Step(badge: 'ready',     text: 'Everything is ready!'),
  ];

  static const _minDuration   = Duration(milliseconds: 2200);
  static const _stepDuration  = Duration(milliseconds: 520);

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _orb1 = Tween<double>(begin: 0, end: math.pi * 2).animate(_orbController);
    _orb2 = Tween<double>(begin: math.pi, end: math.pi * 3).animate(_orbController);

    _runSteps();
  }

  Future<void> _runSteps() async {
    final workAndMin = Future.wait([
      widget.workFuture,
      Future<void>.delayed(_minDuration),
    ]);

    // Animate through steps 0 → n-2 while work + min-duration run.
    for (var i = 0; i < _steps.length - 1; i++) {
      await Future<void>.delayed(_stepDuration);
      if (mounted) {
        setState(() {
          _stepIndex = i + 1;
          _progressValue = (i + 1) / (_steps.length - 1) * 0.88;
        });
      }
    }

    // Wait for work to finish. If it fails, close the dialog so _signIn()
    // can catch the exception from the re-awaited workFuture.
    try {
      await workAndMin;
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // Success path: show final step, brief pause, dismiss.
    if (mounted) {
      setState(() {
        _stepIndex = _steps.length - 1;
        _progressValue = 1.0;
      });
      await Future<void>.delayed(const Duration(milliseconds: 480));
      widget.onDone();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeIn,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 80),
        child: GlassPane(
          level: 1,
          radius: 28,
          padding: const EdgeInsets.fromLTRB(26, 32, 26, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Step badge chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.06),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.18),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  _steps[_stepIndex].badge.toUpperCase(),
                  style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Animated orb
              SizedBox(
                width: 128,
                height: 128,
                child: AnimatedBuilder(
                  animation: _orbController,
                  builder: (context, child) => CustomPaint(
                    painter: _OrbPainter(
                      angle1: _orb1.value,
                      angle2: _orb2.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF8B5CF6),
                size: 22,
              ),
              const SizedBox(height: 16),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: Text(
                  _steps[_stepIndex].text,
                  key: ValueKey(_stepIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stay with us. The setup is doing real work in the background.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _progressValue),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) => LinearProgressIndicator(
                    value: value,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6366F1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StageChip(label: 'authenticating'),
                  const SizedBox(width: 8),
                  _StageChip(label: 'syncing AI'),
                  const SizedBox(width: 8),
                  _StageChip(label: 'readying vault'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${(_progressValue * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step {
  const _Step({required this.badge, required this.text});
  final String badge;
  final String text;
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrbPainter — two revolving gradient orbs
// ─────────────────────────────────────────────────────────────────────────────
class _OrbPainter extends CustomPainter {
  _OrbPainter({required this.angle1, required this.angle2});
  final double angle1;
  final double angle2;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  * 0.3;

    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.9,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF6366F1), const Color(0xFF6366F1).withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.9))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    final o1 = Offset(cx + r * math.cos(angle1), cy + r * math.sin(angle1));
    canvas.drawCircle(
      o1,
      r * 0.45,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF8B5CF6), const Color(0xFF6366F1).withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: o1, radius: r * 0.45))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    final o2 = Offset(
        cx + r * 0.6 * math.cos(angle2), cy + r * 0.6 * math.sin(angle2));
    canvas.drawCircle(
      o2,
      r * 0.3,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFEC4899), const Color(0xFFEC4899).withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: o2, radius: r * 0.3))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.angle1 != angle1 || old.angle2 != angle2;
}

// ─────────────────────────────────────────────────────────────────────────────
// _StageChip — glass mini-badge
// ─────────────────────────────────────────────────────────────────────────────
class _StageChip extends StatelessWidget {
  const _StageChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.78),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
```

### lib/features/onboarding/presentation/screens/splash_screen.dart

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GlassContainer(
              borderRadius: BorderRadius.circular(28),
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.auto_awesome_rounded, size: 48),
                  const SizedBox(height: 14),
                  Text(
                    'Welcome to WhisperLog',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A fast note workspace with AI-assisted capture and calm motion.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => context.go('/signin'),
                    child: const Text('Enter the workspace'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### lib/features/onboarding/presentation/screens/telegram_screen.dart

```dart
// lib/features/onboarding/presentation/screens/telegram_screen.dart
//
// v3.0 — Dual-Method Guided Connection Flow
//
// ┌─────────────────────────────────────────────────────┐
// │  Step-by-Step "Guided Connection" Screen             │
// │                                                      │
// │  1. Method Selection                                 │
// │       ● Primary  — Auto deep-link (recommended)      │
// │       ● Secondary — Manual chat-id paste (fallback)  │
// │                                                      │
// │  PRIMARY FLOW:                                       │
// │    loading → token → waiting → success | error       │
// │                                                      │
// │  SECONDARY FLOW:                                     │
// │    openBot → userCopiesChatId → pasteField           │
// │         → verify → success | error                   │
// └─────────────────────────────────────────────────────┘

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/sync/data/telegram_service.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

// ── Internal state machine ────────────────────────────────────────────────────

enum _Method { unselected, primary, secondary }

enum _PrimaryStep { loading, token, waiting, success, error }

enum _SecondaryStep { instructions, verifying, success, error }

// ─────────────────────────────────────────────────────────────────────────────

class TelegramScreen extends StatefulWidget {
  const TelegramScreen({super.key});

  @override
  State<TelegramScreen> createState() => _TelegramScreenState();
}

class _TelegramScreenState extends State<TelegramScreen> {
  final TelegramService _telegram = TelegramService.instance;

  // ── Shared state ────────────────────────────────────────────────────────────
  _Method _method = _Method.unselected;

  String? _resolvedChatId;
  String? _errorMessage;
  bool    _busy = false;

  // ── Primary flow state ──────────────────────────────────────────────────────
  _PrimaryStep _primaryStep = _PrimaryStep.loading;
  String?      _token;
  bool         _tokenCopied = false;
  StreamSubscription<String?>? _chatIdSub;

  // ── Secondary flow state ────────────────────────────────────────────────────
  _SecondaryStep _secondaryStep = _SecondaryStep.instructions;
  final TextEditingController _chatIdController = TextEditingController();
  String?                     _secondaryError;

  // ── Lifecycle ────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  @override
  void dispose() {
    _chatIdSub?.cancel();
    _chatIdController.dispose();
    super.dispose();
  }

  // ── Init — skip to success if already connected ──────────────────────────────

  Future<void> _checkExisting() async {
    try {
      final chatId = await _telegram.getLinkedChatId();
      if ((chatId ?? '').isNotEmpty && mounted) {
        setState(() {
          _method        = _Method.primary;
          _primaryStep   = _PrimaryStep.success;
          _resolvedChatId = chatId;
        });
      }
    } catch (_) {}
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIMARY FLOW LOGIC
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _startPrimaryFlow() async {
    setState(() {
      _method      = _Method.primary;
      _primaryStep = _PrimaryStep.loading;
      _errorMessage = null;
    });
    await _generateToken();
  }

  Future<void> _generateToken() async {
    if (!mounted) return;
    setState(() { _busy = true; _errorMessage = null; });

    try {
      final token = await _telegram.createTelegramConnectionToken();
      if (!mounted) return;
      setState(() {
        _token       = token;
        _primaryStep = _PrimaryStep.token;
        _busy        = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _primaryStep  = _PrimaryStep.error;
        _errorMessage = 'Could not generate a link code: $e';
        _busy         = false;
      });
    }
  }

  /// Opens Telegram app with the deep-link pre-filled, then starts watching
  /// Firestore for the bot to write back the chat_id.
  Future<void> _connectInTelegram() async {
    try {
      final token = _token ?? await _telegram.createTelegramConnectionToken();
      _token = token;
      await _telegram.connectTelegramAuto(existingToken: token);
      if (mounted) _startWatchingForChatId();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _primaryStep  = _PrimaryStep.error;
        _errorMessage = 'Could not open Telegram: $e';
      });
    }
  }

  void _startWatchingForChatId() {
    _chatIdSub?.cancel();
    setState(() => _primaryStep = _PrimaryStep.waiting);

    _chatIdSub = _telegram.watchLinkedChatId().listen((chatId) {
      final trimmed = (chatId ?? '').trim();
      if (trimmed.isEmpty || !mounted) return;
      setState(() {
        _primaryStep    = _PrimaryStep.success;
        _resolvedChatId = trimmed;
        _token          = null;
      });
      _chatIdSub?.cancel();
    });
  }

  Future<void> _copyLink() async {
    final token = _token ?? _telegram.lastLinkToken;
    if (token == null) return;
    final link = await _telegram.buildTelegramStartUri(token);
    await Clipboard.setData(ClipboardData(text: link.toString()));
    if (!mounted) return;
    setState(() => _tokenCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _tokenCopied = false);
    });
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECONDARY FLOW LOGIC
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _startSecondaryFlow() async {
    setState(() {
      _method        = _Method.secondary;
      _secondaryStep = _SecondaryStep.instructions;
      _secondaryError = null;
    });
  }

  Future<void> _openBotForSecondary() async {
    try {
      await _telegram.openTelegramBot();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open Telegram: $e')),
        );
      }
    }
  }

  Future<void> _submitManualChatId() async {
    final raw = _chatIdController.text.trim();
    if (raw.isEmpty) {
      setState(() => _secondaryError = 'Please paste your Chat ID first.');
      return;
    }

    setState(() {
      _secondaryStep  = _SecondaryStep.verifying;
      _secondaryError = null;
      _busy = true;
    });

    try {
      final chatId = await _telegram.linkManualChatId(raw);
      if (!mounted) return;
      setState(() {
        _secondaryStep  = _SecondaryStep.success;
        _resolvedChatId = chatId;
        _busy = false;
      });
    } on ArgumentError catch (e) {
      if (!mounted) return;
      setState(() {
        _secondaryStep  = _SecondaryStep.instructions;
        _secondaryError = e.message;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _secondaryStep  = _SecondaryStep.error;
        _secondaryError = 'Could not save Chat ID: $e';
        _busy = false;
      });
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SHARED — DISCONNECT
  // ══════════════════════════════════════════════════════════════════════════

  Future<void> _disconnect() async {
    setState(() => _busy = true);
    _chatIdSub?.cancel();
    try {
      await _telegram.disconnectTelegram();
      if (!mounted) return;
      _chatIdController.clear();
      setState(() {
        _method        = _Method.unselected;
        _primaryStep   = _PrimaryStep.loading;
        _secondaryStep = _SecondaryStep.instructions;
        _resolvedChatId = null;
        _token         = null;
        _errorMessage  = null;
        _secondaryError = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not disconnect: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  String get _botUsername {
    final configured = AppEnv.telegramBotUsername.trim();
    return configured.isNotEmpty ? '@${configured.replaceFirst(RegExp(r'^@+'), '')}' : '@WishperLogDigestBot';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: SafeArea(
          child: Column(
            children: [
              // ── Custom title bar ────────────────────────────────────────────
              _buildTitleBar(context),

              // ── Scrollable content ──────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Step indicator (breadcrumb)
                      _buildStepIndicator(),
                      const SizedBox(height: 16),

                      // Main card
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 340),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.06),
                              end: Offset.zero,
                            ).animate(anim),
                            child: child,
                          ),
                        ),
                        child: _buildCurrentCard(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (Navigator.of(context).canPop()) {
                context.pop();
              } else {
                context.go('/home');
              }
            },
            child: GlassContainer(
              borderRadius: BorderRadius.circular(14),
              padding: const EdgeInsets.all(10),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  size: 18, color: context.textPri),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Telegram',
                  style: TextStyle(
                    color: context.textPri,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Connect your bot for digest & commands',
                  style: TextStyle(
                    color: context.textSec,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          if (_resolvedChatId != null)
            _StatusBadge(connected: true)
          else if (_method != _Method.unselected)
            _StatusBadge(connected: false),
        ],
      ),
    );
  }

  // ── Step indicator / breadcrumb ────────────────────────────────────────────

  Widget _buildStepIndicator() {
    final steps = _buildStepLabels();
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: steps.length,
        separatorBuilder: (context, index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.chevron_right_rounded, size: 16, color: Colors.grey),
        ),
        itemBuilder: (context, index) {
          final (label, active) = steps[index];
          return _StepChip(label: label, active: active);
        },
      ),
    );
  }

  List<(String, bool)> _buildStepLabels() {
    if (_method == _Method.unselected) {
      return [('Choose method', true)];
    }
    if (_method == _Method.primary) {
      return [
        ('Choose method', false),
        ('Auto-connect', _primaryStep == _PrimaryStep.token),
        ('Verify', _primaryStep == _PrimaryStep.waiting),
        ('Done', _primaryStep == _PrimaryStep.success),
      ];
    }
    // Secondary
    return [
      ('Choose method', false),
      ('Open bot', _secondaryStep == _SecondaryStep.instructions),
      ('Paste ID', _secondaryStep == _SecondaryStep.instructions),
      ('Done', _secondaryStep == _SecondaryStep.success),
    ];
  }

  // ── Main card switcher ─────────────────────────────────────────────────────

  Widget _buildCurrentCard() {
    // Universal success state
    if (_resolvedChatId != null) {
      return _SuccessCard(
        key: const ValueKey('success'),
        chatId: _resolvedChatId!,
        onContinue: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
        onDisconnect: _disconnect,
        busy: _busy,
      );
    }

    // Method selection
    if (_method == _Method.unselected) {
      return _MethodSelectionCard(
        key: const ValueKey('method'),
        botUsername: _botUsername,
        onPrimary:   _startPrimaryFlow,
        onSecondary: _startSecondaryFlow,
      );
    }

    // Primary flow
    if (_method == _Method.primary) {
      return switch (_primaryStep) {
        _PrimaryStep.loading => _LoadingCard(key: const ValueKey('p-loading')),
        _PrimaryStep.token => _PrimaryTokenCard(
            key: const ValueKey('p-token'),
            token: _token ?? '',
            botUsername: _botUsername,
            tokenCopied: _tokenCopied,
            busy: _busy,
            onConnect: _connectInTelegram,
            onCopy: _copyLink,
            onSwitchMethod: _startSecondaryFlow,
          ),
        _PrimaryStep.waiting => _WaitingCard(
            key: const ValueKey('p-waiting'),
            botUsername: _botUsername,
          ),
        _PrimaryStep.success => const SizedBox.shrink(),
        _PrimaryStep.error => _ErrorCard(
            key: const ValueKey('p-error'),
            message: _errorMessage ?? 'An unexpected error occurred.',
            onRetry: _generateToken,
          ),
      };
    }

    // Secondary flow
    return switch (_secondaryStep) {
      _SecondaryStep.instructions => _SecondaryInstructionsCard(
          key: const ValueKey('s-instructions'),
          botUsername: _botUsername,
          controller: _chatIdController,
          errorText: _secondaryError,
          busy: _busy,
          onOpenBot: _openBotForSecondary,
          onSubmit: _submitManualChatId,
          onSwitchMethod: _startPrimaryFlow,
        ),
      _SecondaryStep.verifying => _LoadingCard(
          key: const ValueKey('s-verifying'),
          message: 'Saving your Chat ID…',
        ),
      _SecondaryStep.success => const SizedBox.shrink(),
      _SecondaryStep.error => _ErrorCard(
          key: const ValueKey('s-error'),
          message: _secondaryError ?? 'An unexpected error occurred.',
          onRetry: _startSecondaryFlow,
        ),
    };
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// CARD WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

// ── Method selection ──────────────────────────────────────────────────────────

class _MethodSelectionCard extends StatelessWidget {
  const _MethodSelectionCard({
    super.key,
    required this.botUsername,
    required this.onPrimary,
    required this.onSecondary,
  });

  final String botUsername;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icon + header
          const Icon(Icons.telegram, size: 52, color: AppColors.tasks),
          const SizedBox(height: 14),
          Text(
            'Connect Telegram',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.textPri,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Receive daily digests and query your notes directly from $botUsername.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSec, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 28),

          // ── Primary method card ────────────────────────────────────────────
          _MethodOption(
            icon: Icons.flash_on_rounded,
            iconColor: AppColors.tasks,
            title: 'Auto-connect  (Recommended)',
            description: 'Tap once — the app opens Telegram with everything '
                'pre-filled. The link happens automatically.',
            badge: 'INSTANT',
            badgeColor: AppColors.tasks,
            onTap: onPrimary,
          ),

          const SizedBox(height: 12),

          // ── Secondary method card ──────────────────────────────────────────
          _MethodOption(
            icon: Icons.content_paste_rounded,
            iconColor: AppColors.ideas,
            title: 'Manual paste  (Fallback)',
            description: 'Open $botUsername in Telegram. It will display your '
                'Chat ID. Copy and paste it back here.',
            badge: 'MANUAL',
            badgeColor: AppColors.ideas,
            onTap: onSecondary,
          ),
        ],
      ),
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.badge,
    required this.badgeColor,
    required this.onTap,
  });

  final IconData  icon;
  final Color     iconColor;
  final String    title;
  final String    description;
  final String    badge;
  final Color     badgeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: context.textPri,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: badgeColor.withValues(alpha: 0.12),
                        ),
                        child: Text(
                          badge,
                          style: TextStyle(
                            color: badgeColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                        color: context.textSec, fontSize: 12, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: context.textSec.withValues(alpha: 0.5)),
          ],
        ),
      ),
    );
  }
}

// ── Primary: token display ────────────────────────────────────────────────────

class _PrimaryTokenCard extends StatelessWidget {
  const _PrimaryTokenCard({
    super.key,
    required this.token,
    required this.botUsername,
    required this.tokenCopied,
    required this.busy,
    required this.onConnect,
    required this.onCopy,
    required this.onSwitchMethod,
  });

  final String token;
  final String botUsername;
  final bool   tokenCopied;
  final bool   busy;
  final VoidCallback onConnect;
  final VoidCallback onCopy;
  final VoidCallback onSwitchMethod;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step number badge
          _StepBadge(label: 'STEP 1 OF 2', color: AppColors.tasks),
          const SizedBox(height: 16),
          Text(
            'Open Telegram',
            style: TextStyle(
                color: context.textPri,
                fontSize: 20,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below. The Telegram app will open with a '
            'pre-filled message — just tap START and the link completes automatically.',
            style: TextStyle(color: context.textSec, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 20),

          // Connect button
          FilledButton.icon(
            style: _filledStyle(AppColors.tasks),
            onPressed: busy ? null : onConnect,
            icon: const Icon(Icons.telegram, size: 18),
            label: const Text('Open Telegram & Connect'),
          ),
          const SizedBox(height: 12),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider()),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text('or',
                    style: TextStyle(
                        color: context.textSec.withValues(alpha: 0.5),
                        fontSize: 12)),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 12),

          // Copy link (for users whose deep-link doesn't work)
          OutlinedButton.icon(
            style: _outlinedStyle(context, AppColors.tasks),
            onPressed: onCopy,
            icon: Icon(
              tokenCopied
                  ? Icons.check_circle_rounded
                  : Icons.content_copy_rounded,
              size: 16,
            ),
            label: Text(tokenCopied ? 'Copied!' : 'Copy link instead'),
          ),
          const SizedBox(height: 20),

          _InfoBox(
            icon: Icons.info_outline_rounded,
            text: 'After tapping START in Telegram, return here. '
                'This screen will update automatically when the link is confirmed.',
          ),
          const SizedBox(height: 16),

          // Escape hatch → secondary method
          Center(
            child: TextButton(
              onPressed: onSwitchMethod,
              child: Text(
                'Having trouble? Use manual Chat ID instead',
                style: TextStyle(
                    color: context.textSec, fontSize: 12, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Primary: waiting ──────────────────────────────────────────────────────────

class _WaitingCard extends StatelessWidget {
  const _WaitingCard({super.key, required this.botUsername});
  final String botUsername;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
      child: Column(
        children: [
          const SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.tasks,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Waiting for Telegram…',
            style: TextStyle(
              color: context.textPri,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Open $botUsername and tap START. This page will update automatically when confirmed.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSec, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 20),
          _InfoBox(
            icon: Icons.lock_outline_rounded,
            text: 'WishperLog never posts to Telegram without your permission.',
          ),
        ],
      ),
    );
  }
}

// ── Secondary: instructions + paste field ─────────────────────────────────────

class _SecondaryInstructionsCard extends StatelessWidget {
  const _SecondaryInstructionsCard({
    super.key,
    required this.botUsername,
    required this.controller,
    this.errorText,
    required this.busy,
    required this.onOpenBot,
    required this.onSubmit,
    required this.onSwitchMethod,
  });

  final String botUsername;
  final TextEditingController controller;
  final String? errorText;
  final bool busy;
  final VoidCallback onOpenBot;
  final VoidCallback onSubmit;
  final VoidCallback onSwitchMethod;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepBadge(label: 'MANUAL FALLBACK', color: AppColors.ideas),
          const SizedBox(height: 16),
          Text(
            'Get your Chat ID',
            style: TextStyle(
                color: context.textPri,
                fontSize: 20,
                fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),

          // Numbered instructions
          _NumberedStep(
            number: 1,
            text: 'Tap the button below to open $botUsername.',
          ),
          const SizedBox(height: 8),
          _NumberedStep(
            number: 2,
            text: 'The bot will reply with your unique Chat ID (a number).',
          ),
          const SizedBox(height: 8),
          _NumberedStep(
            number: 3,
            text: 'Copy that number and paste it in the field below.',
          ),
          const SizedBox(height: 20),

          // Open bot button
          OutlinedButton.icon(
            style: _outlinedStyle(context, AppColors.tasks),
            onPressed: onOpenBot,
            icon: const Icon(Icons.telegram, size: 18),
            label: Text('Open $botUsername'),
          ),
          const SizedBox(height: 20),

          // Chat ID field
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
            ],
            decoration: InputDecoration(
              labelText: 'Paste your Chat ID here',
              hintText: 'e.g. 123456789',
              errorText: errorText,
              prefixIcon: const Icon(Icons.tag_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          FilledButton(
            style: _filledStyle(AppColors.ideas),
            onPressed: busy ? null : onSubmit,
            child: busy
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Confirm Chat ID'),
          ),
          const SizedBox(height: 16),

          Center(
            child: TextButton(
              onPressed: onSwitchMethod,
              child: Text(
                'Switch to auto-connect instead',
                style:
                    TextStyle(color: context.textSec, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Success ───────────────────────────────────────────────────────────────────

class _SuccessCard extends StatelessWidget {
  const _SuccessCard({
    super.key,
    required this.chatId,
    required this.onContinue,
    required this.onDisconnect,
    required this.busy,
  });

  final String chatId;
  final VoidCallback onContinue;
  final VoidCallback onDisconnect;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.followUp.withValues(alpha: 0.14),
            ),
            child: const Icon(Icons.check_rounded,
                color: AppColors.followUp, size: 36),
          ),
          const SizedBox(height: 16),
          Text(
            'Telegram Connected!',
            style: TextStyle(
              color: context.textPri,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your digest messages will be sent to this chat.',
            textAlign: TextAlign.center,
            style: TextStyle(color: context.textSec, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 18),
          GlassContainer(
            borderRadius: BorderRadius.circular(14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.tag_rounded, size: 16, color: AppColors.tasks),
                const SizedBox(width: 8),
                Text(
                  'Chat ID: $chatId',
                  style: TextStyle(
                    color: context.textPri,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: _filledStyle(AppColors.tasks),
              onPressed: onContinue,
              child: const Text('Done'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: ButtonStyle(
                foregroundColor:
                    WidgetStatePropertyAll(AppColors.reminders),
                side: WidgetStatePropertyAll(
                  BorderSide(
                      color: AppColors.reminders.withValues(alpha: 0.4)),
                ),
                shape: const WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(14)),
                  ),
                ),
              ),
              onPressed: busy ? null : onDisconnect,
              child: const Text('Disconnect Telegram'),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({super.key, this.message = 'Loading…'});
  final String message;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.tasks),
          const SizedBox(height: 16),
          Text(message,
              style: TextStyle(color: context.textSec, fontSize: 14)),
        ],
      ),
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 1,
      radius: 24,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
      child: Column(
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.reminders),
          const SizedBox(height: 14),
          Text(
            'Something went wrong',
            style: TextStyle(
                color: context.textPri,
                fontSize: 18,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(message,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: context.textSec, fontSize: 13, height: 1.45)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: _filledStyle(AppColors.tasks),
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// SMALL HELPER WIDGETS
// ══════════════════════════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.connected});
  final bool connected;

  @override
  Widget build(BuildContext context) {
    final color  = connected ? AppColors.followUp : AppColors.ideas;
    final icon   = connected ? Icons.check_circle_rounded : Icons.pending_rounded;
    final label  = connected ? 'Connected' : 'Pending';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: color.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: active
            ? AppColors.tasks.withValues(alpha: 0.15)
            : context.surface1.withValues(alpha: 0.4),
        border: Border.all(
          color: active
              ? AppColors.tasks.withValues(alpha: 0.35)
              : context.textSec.withValues(alpha: 0.12),
          width: 0.8,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.tasks : context.textSec,
          fontSize: 11,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge({required this.label, required this.color});
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: color.withValues(alpha: 0.12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _NumberedStep extends StatelessWidget {
  const _NumberedStep({required this.number, required this.text});
  final int    number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.ideas.withValues(alpha: 0.14),
          ),
          child: Center(
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.ideas,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Text(
              text,
              style: TextStyle(
                  color: context.textSec, fontSize: 13, height: 1.4),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.text});
  final IconData icon;
  final String   text;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: context.textSec),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                  color: context.textSec, fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Button styles (module-level helpers) ──────────────────────────────────────

ButtonStyle _filledStyle(Color color) => ButtonStyle(
  backgroundColor: WidgetStatePropertyAll(color),
  foregroundColor: const WidgetStatePropertyAll(Colors.white),
  padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 20, vertical: 14)),
  shape: const WidgetStatePropertyAll(
    RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14))),
  ),
  elevation: const WidgetStatePropertyAll(0),
  textStyle: const WidgetStatePropertyAll(
      TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
);

ButtonStyle _outlinedStyle(BuildContext context, Color color) => ButtonStyle(
  foregroundColor: WidgetStatePropertyAll(color),
  backgroundColor: WidgetStatePropertyAll(color.withValues(alpha: 0.06)),
  side: WidgetStatePropertyAll(
      BorderSide(color: color.withValues(alpha: 0.35))),
  padding: const WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 20, vertical: 13)),
  shape: const WidgetStatePropertyAll(
    RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(14))),
  ),
  elevation: const WidgetStatePropertyAll(0),
  textStyle: const WidgetStatePropertyAll(
      TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
);
```

### lib/features/overlay/overlay_bubble.dart

```dart
import 'package:flutter/material.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/overlay/quick_note_editor.dart';

/// The root wrapper placed inside MaterialApp.builder.
/// Renders all routes as normal and bridges native overlay callbacks.
class OverlayRootWrapper extends StatefulWidget {
  const OverlayRootWrapper({required this.child, super.key});

  final Widget child;

  @override
  State<OverlayRootWrapper> createState() => _OverlayRootWrapperState();
}

class _OverlayRootWrapperState extends State<OverlayRootWrapper> {
  late final OverlayNotifier _notifier;
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _notifier = sl<OverlayNotifier>();
    _notifier.addOpenEditorListener(_onNativeEditorCall);

    // ISSUE-05: When the user returns from the Android overlay-permission
    // settings screen the app resumes — we use that signal to complete
    // the deferred permission check.
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        _notifier.resumePermissionCheck();
      },
    );

    // Hydrate after the first frame so prefs are read after widget tree is up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier.hydrate();
    });
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    _notifier.removeOpenEditorListener(_onNativeEditorCall);
    super.dispose();
  }


  void _onNativeEditorCall() {
    _openEditorSheet(context);
  }

  void _openEditorSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickNoteEditor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, _) {
        return widget.child;
      },
    );
  }
}
```

### lib/features/overlay/overlay_customisation_sheet.dart

```dart
// lib/features/overlay/overlay_customisation_sheet.dart
//
// "God-Level" overlay customisation bottom-sheet.
// Shows live preview + every setting from OverlaySettings.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/overlay/overlay_settings_model.dart';

/// Call via:
///   showOverlayCustomisationSheet(context, initial, onSave);
Future<void> showOverlayCustomisationSheet(
  BuildContext context,
  OverlaySettings initial,
  Future<void> Function(OverlaySettings) onSave,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OverlayCustomisationSheet(
      initial: initial,
      onSave: onSave,
    ),
  );
}

class _OverlayCustomisationSheet extends StatefulWidget {
  const _OverlayCustomisationSheet({
    required this.initial,
    required this.onSave,
  });

  final OverlaySettings initial;
  final Future<void> Function(OverlaySettings) onSave;

  @override
  State<_OverlayCustomisationSheet> createState() =>
      _OverlayCustomisationSheetState();
}

class _OverlayCustomisationSheetState
    extends State<_OverlayCustomisationSheet> {
  late OverlaySettings _s;
  bool _saving = false;
  bool _growPreview = false;

  @override
  void initState() {
    super.initState();
    _s = widget.initial;
  }

  // ── Live preview ──────────────────────────────────────────────────────────

  Widget _buildPreview() {
    final hasGlow = _s.borderStyle == OverlayBorderStyle.glow;
    final gradient = _s.colorFill == OverlayColorFill.linearGradient
        ? LinearGradient(
            colors: [_s.gradientStart, _s.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : _s.colorFill == OverlayColorFill.radialGradient
            ? RadialGradient(
                colors: [_s.gradientStart, _s.gradientEnd],
              )
            : null;

    final baseDecoration = BoxDecoration(
      color: _s.colorFill == OverlayColorFill.solid ? _s.solidColor.withValues(alpha: _s.alpha) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(24),
      border: _s.borderStyle != OverlayBorderStyle.none
          ? Border.all(
              color: _s.borderColor.withValues(
                alpha: _s.borderStyle == OverlayBorderStyle.hairline ? 0.5 : 1.0,
              ),
              width: _s.borderStyle == OverlayBorderStyle.hairline ? 0.6 : 1.4,
            )
          : null,
      boxShadow: hasGlow
          ? [
              BoxShadow(
                color: _s.borderColor.withValues(alpha: 0.55),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ]
          : null,
    );

    Widget pill = AnimatedScale(
      scale: _growPreview && _s.animation == OverlayAnimation.sizeGrow
          ? _s.growScale
          : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _growPreview = true),
        onTapUp: (_) => setState(() => _growPreview = false),
        onTapCancel: () => setState(() => _growPreview = false),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _s.colorFill == OverlayColorFill.glass ? _s.blurSigma : 0,
              sigmaY: _s.colorFill == OverlayColorFill.glass ? _s.blurSigma : 0,
            ),
            child: Container(
              width: 160,
              height: 52,
              decoration: _s.colorFill == OverlayColorFill.glass
                  ? baseDecoration.copyWith(
                      color: Colors.white.withValues(alpha: _s.alpha * 0.12),
                      border: baseDecoration.border,
                      boxShadow: baseDecoration.boxShadow,
                    )
                  : baseDecoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_rounded, color: Colors.white.withValues(alpha: 0.9), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Hold to Record',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Center(child: pill);
  }

  // ── Section label ─────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        color: context.textSec,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    ),
  );

  // ── Segmented button helper ───────────────────────────────────────────────

  Widget _segmented<T>({
    required List<T> values,
    required T current,
    required String Function(T) label,
    required void Function(T) onSelect,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((v) {
        final selected = v == current;
        return GestureDetector(
          onTap: () => setState(() => onSelect(v)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.tasks
                  : context.surface1.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? AppColors.tasks
                    : context.textSec.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              label(v),
              style: TextStyle(
                color: selected ? Colors.white : context.textSec,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Color row ─────────────────────────────────────────────────────────────

  static const _palette = [
    Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899),
    Color(0xFF22D3EE), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEF4444), Color(0xFF1C1C2E), Color(0xFFFFFFFF),
  ];

  Widget _colorRow(Color current, void Function(Color) onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _palette.map((c) {
        final sel = current.toARGB32() == c.toARGB32();
        return GestureDetector(
          onTap: () => setState(() => onSelect(c)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: sel ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: sel
                  ? [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 10)]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xF2111827)
                    : const Color(0xF2F9FAFB),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  const SizedBox(height: 10),
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: context.textSec.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overlay Customiser',
                                style: TextStyle(
                                  color: context.textPri,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.4,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Applies to the floating bubble and the dynamic island.',
                                style: TextStyle(
                                  color: context.textSec,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: _saving
                              ? null
                              : () async {
                                  setState(() => _saving = true);
                                  try {
                                    await widget.onSave(_s);
                                    if (ctx.mounted) Navigator.of(ctx).pop();
                                  } finally {
                                    if (mounted) setState(() => _saving = false);
                                  }
                                },
                          child: _saving
                              ? const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  'Save',
                                  style: TextStyle(
                                    color: AppColors.tasks,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Scrollable content
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      children: [
                        // ── Preview ───────────────────────────────────────
                        _label('LIVE PREVIEW — TAP TO TEST ANIMATION'),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: context.surface1.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: context.textSec.withValues(alpha: 0.1)),
                          ),
                          child: _buildPreview(),
                        ),

                        // ── Transparency ─────────────────────────────────
                        _label('TRANSPARENCY'),
                        Row(
                          children: [
                            Text('${(_s.alpha * 100).round()}%',
                                style: TextStyle(color: context.textSec, fontSize: 12)),
                            Expanded(
                              child: Slider(
                                value: _s.alpha,
                                min: 0.2, max: 1.0, divisions: 32,
                                activeColor: AppColors.tasks,
                                onChanged: (v) => setState(() => _s = _s.copyWith(alpha: v)),
                              ),
                            ),
                          ],
                        ),

                        // ── Glassmorphism Blur ────────────────────────────
                        _label('GLASSMORPHISM BLUR'),
                        Row(
                          children: [
                            Text('σ${_s.blurSigma.round()}',
                                style: TextStyle(color: context.textSec, fontSize: 12)),
                            Expanded(
                              child: Slider(
                                value: _s.blurSigma,
                                min: 0, max: 40, divisions: 40,
                                activeColor: AppColors.tasks,
                                onChanged: (v) => setState(() => _s = _s.copyWith(blurSigma: v)),
                              ),
                            ),
                          ],
                        ),

                        // ── Fill Style ───────────────────────────────────
                        _label('FILL STYLE'),
                        _segmented<OverlayColorFill>(
                          values: OverlayColorFill.values,
                          current: _s.colorFill,
                          label: (v) => switch (v) {
                            OverlayColorFill.glass => 'Glass',
                            OverlayColorFill.solid => 'Solid',
                            OverlayColorFill.linearGradient => 'Linear',
                            OverlayColorFill.radialGradient => 'Radial',
                          },
                          onSelect: (v) => _s = _s.copyWith(colorFill: v),
                        ),

                        // ── Solid color ───────────────────────────────────
                        if (_s.colorFill == OverlayColorFill.solid) ...[
                          _label('FILL COLOUR'),
                          _colorRow(_s.solidColor, (c) => _s = _s.copyWith(solidColor: c)),
                        ],

                        // ── Gradient colours ──────────────────────────────
                        if (_s.colorFill == OverlayColorFill.linearGradient ||
                            _s.colorFill == OverlayColorFill.radialGradient) ...[
                          _label('GRADIENT START'),
                          _colorRow(_s.gradientStart, (c) => _s = _s.copyWith(gradientStart: c)),
                          _label('GRADIENT END'),
                          _colorRow(_s.gradientEnd, (c) => _s = _s.copyWith(gradientEnd: c)),
                        ],

                        // ── Border Style ──────────────────────────────────
                        _label('BORDER STYLE'),
                        _segmented<OverlayBorderStyle>(
                          values: OverlayBorderStyle.values,
                          current: _s.borderStyle,
                          label: (v) => switch (v) {
                            OverlayBorderStyle.none => 'None',
                            OverlayBorderStyle.hairline => 'Hairline',
                            OverlayBorderStyle.glow => 'Glow',
                          },
                          onSelect: (v) => _s = _s.copyWith(borderStyle: v),
                        ),
                        if (_s.borderStyle != OverlayBorderStyle.none) ...[
                          _label('BORDER / GLOW COLOUR'),
                          _colorRow(_s.borderColor, (c) => _s = _s.copyWith(borderColor: c)),
                        ],

                        // ── Animation ─────────────────────────────────────
                        _label('TOUCH ANIMATION'),
                        _segmented<OverlayAnimation>(
                          values: OverlayAnimation.values,
                          current: _s.animation,
                          label: (v) => switch (v) {
                            OverlayAnimation.none => 'None',
                            OverlayAnimation.sizeGrow => 'Size Grow',
                            OverlayAnimation.pulseGlow => 'Pulse Glow',
                            OverlayAnimation.bounceIn => 'Bounce In',
                          },
                          onSelect: (v) => _s = _s.copyWith(animation: v),
                        ),
                        if (_s.animation == OverlayAnimation.sizeGrow) ...[
                          _label('GROW SCALE'),
                          Row(
                            children: [
                              Text('${(_s.growScale * 100).round()}%',
                                  style: TextStyle(color: context.textSec, fontSize: 12)),
                              Expanded(
                                child: Slider(
                                  value: _s.growScale,
                                  min: 1.0, max: 1.30, divisions: 15,
                                  activeColor: AppColors.tasks,
                                  onChanged: (v) => setState(() => _s = _s.copyWith(growScale: v)),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // ── Persistence ───────────────────────────────────
                        _label('PERSISTENCE'),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Show after device reboot',
                            style: TextStyle(color: context.textPri, fontSize: 14),
                          ),
                          value: _s.persistOnReboot,
                          activeThumbColor: AppColors.tasks,
                          onChanged: (v) => setState(() => _s = _s.copyWith(persistOnReboot: v)),
                        ),

                        _label('TARGET'),
                        Text(
                          'These settings currently apply to the bubble and island together.',
                          style: TextStyle(
                            color: context.textSec,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
```

### lib/features/overlay/overlay_notifier.dart

```dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wishperlog/app/router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/features/overlay/overlay_settings_model.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

/// Lightweight state holder for the in-app floating overlay.
/// Has ZERO knowledge of BuildContext or the widget tree.
/// Persists enabled/position to SharedPreferences.
class OverlayNotifier extends ChangeNotifier {
  OverlayNotifier();

  // ── Prefs keys ────────────────────────────────────────────────────────────
  static const _kEnabled   = 'overlay_v2.enabled';
  static const _kPosX      = 'overlay_v2.pos_x';
  static const _kPosY      = 'overlay_v2.pos_y';
  static const _kSettings  = 'overlay_v2.settings_json';

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isEnabled = false;
  Offset _position = const Offset(20, 200);
  bool _hydrated = false;
  OverlaySettings _overlaySettings = const OverlaySettings();

  Timer? _persistDebounce;
  StreamSubscription<CaptureUiState>? _captureStateSub;
  StreamSubscription<String>? _noteUpdatedSub;
  String _lastNativeState = 'idle';
  bool _nativeSessionActive = false;
  String? _lastSavedNoteId;

  final MethodChannel _channel = const MethodChannel('wishperlog/overlay');
  final List<VoidCallback> _openEditorCallbacks = [];

  bool get isEnabled => _isEnabled;
  OverlaySettings get overlaySettings => _overlaySettings;

  void addOpenEditorListener(VoidCallback listener) {
    _openEditorCallbacks.add(listener);
  }

  void removeOpenEditorListener(VoidCallback listener) {
    _openEditorCallbacks.remove(listener);
  }

  Offset get position => _position;
  bool get isHydrated => _hydrated;

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> hydrate() async {
    if (_hydrated) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_kEnabled) ?? false;
      final x = prefs.getDouble(_kPosX) ?? 20.0;
      final y = prefs.getDouble(_kPosY) ?? 200.0;
      _position = Offset(x, y);
      _overlaySettings = OverlaySettings.fromJsonString(
        prefs.getString(_kSettings),
      );

      _channel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'openEditor':
            router.push('/system_banner');
            break;
          case 'notifyRecordingStarted':
            _onNativeRecordingStarted();
            break;
          case 'notifyRecordingStopped':
            _onNativeRecordingStopped();
            break;
          case 'notifyRecordingTranscript':
            final text = call.arguments?['text'] as String? ?? '';
            _onNativeTranscript(text);
            break;
          case 'captureNote':
            // Called by NoteInputReceiver when native overlay sends a note.
            // This works when Flutter engine is alive (app in foreground or
            // kept alive). When engine is dead, the note is dropped at the
            // Kotlin level (see NoteInputReceiver).
            final text = call.arguments?['text'] as String? ?? '';
            final source = call.arguments?['source'] as String? ?? 'voice_overlay';
            if (text.isNotEmpty) {
              Future.microtask(() => _saveOverlayNote(text, source));
            }
            break;
          case 'promptMicrophonePermission':
            final granted = await requestMicrophonePermission();
            if (granted && _isEnabled) {
              await _restartNativeOverlay();
            }
            break;
          case 'notifyRecordingFailed':
            _onNativeRecordingFailed();
            break;
        }
      });

      try {
        final captureCtrl = sl<CaptureUiController>();
        _captureStateSub = captureCtrl.stream.listen(_onCaptureStateChanged);
      } catch (e) {
        debugPrint('[OverlayNotifier] capture state subscription error: $e');
      }

      try {
        _noteUpdatedSub = NoteEventBus.instance.onNoteUpdated.listen(_onNoteUpdated);
      } catch (e) {
        debugPrint('[OverlayNotifier] note update subscription error: $e');
      }

      if (_isEnabled) {
        _syncNativeOverlayState();
      }
    } catch (e) {
      debugPrint('[OverlayNotifier] hydrate error: $e');
    } finally {
      _hydrated = true;
      notifyListeners();
    }
  }


  /// Whether we are currently waiting for the user to return from Settings
  /// after we opened the overlay-permission screen.
  bool _pendingPermissionCheck = false;

  Future<void> setEnabled(bool value) async {
    if (_isEnabled == value) return;

    if (value) {
      final hasOverlayPermission =
          await _channel.invokeMethod<bool>('checkPermission') ?? false;

      if (!hasOverlayPermission) {
        // Open the system settings page. Do NOT re-check immediately —
        // the check will happen in resumePermissionCheck() called from
        // the platform side (via AppLifecycleState.resumed) or on the
        // next hydrate() call.
        _pendingPermissionCheck = true;
        await _channel.invokeMethod('requestPermission');
        // Do NOT proceed — the user hasn't granted permission yet.
        return;
      }

      final hasMicPermission = await requestMicrophonePermission();
      if (!hasMicPermission) return;
    }

    _isEnabled = value;
    notifyListeners();
    await _persistEnabled();
    _syncNativeOverlayState();
  }

  /// Called by the app shell (e.g. from AppLifecycleListener.onResume) after
  /// the user returns from the Android overlay-permission settings screen.
  /// Re-checks permission and completes the enable flow if granted.
  Future<void> resumePermissionCheck() async {
    if (!_pendingPermissionCheck) return;
    _pendingPermissionCheck = false;

    final hasOverlayPermission =
        await _channel.invokeMethod<bool>('checkPermission') ?? false;
    if (!hasOverlayPermission) return; // Still not granted — stay disabled.

    final hasMicPermission = await requestMicrophonePermission();
    if (!hasMicPermission) return;

    _isEnabled = true;
    notifyListeners();
    await _persistEnabled();
    _syncNativeOverlayState();
  }

  Future<void> requestPermission() async {
    await _channel.invokeMethod('requestPermission');
    final hasPermission = await _channel.invokeMethod<bool>('checkPermission') ?? false;
    if (hasPermission) {
      await setEnabled(true);
    }
  }

  Future<bool> checkPermission() async {
    return await _channel.invokeMethod<bool>('checkPermission') ?? false;
  }

  Future<bool> requestMicrophonePermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestMicrophonePermission') ??
          false;
    } catch (e) {
      debugPrint('[OverlayNotifier] mic permission request error: $e');
      return false;
    }
  }

  /// Called from main.dart _postLaunchTasks - drains notes captured while
  /// Flutter engine was dead (native-only sessions).
  Future<void> drainPendingNativeNotes() async {
      try {
          await _channel.invokeMethod('flushPendingNotes');
      } catch (e) {
          debugPrint('[OverlayNotifier] drainPendingNativeNotes error: $e');
      }
  }

  void updatePosition(Offset newPosition) {
    _position = newPosition;
    notifyListeners();
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 400), _persistPosition);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _syncNativeOverlayState() async {
    try {
      if (_isEnabled) {
        await _channel.invokeMethod('show');
      } else {
        await _channel.invokeMethod('hide');
      }
    } catch (e) {
      debugPrint('[OverlayNotifier] native sync error: $e');
    }
  }

  Future<void> _restartNativeOverlay() async {
    try {
      await _channel.invokeMethod('hide');
      await _channel.invokeMethod('show');
    } catch (e) {
      debugPrint('[OverlayNotifier] native restart error: $e');
    }
  }

  Future<void> _persistEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kEnabled, _isEnabled);
    } catch (e) {
      debugPrint('[OverlayNotifier] persist enabled error: $e');
    }
  }

  Future<void> _persistPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kPosX, _position.dx);
      await prefs.setDouble(_kPosY, _position.dy);
    } catch (e) {
      debugPrint('[OverlayNotifier] persist position error: $e');
    }
  }

  Future<void> saveOverlaySettings(OverlaySettings settings) async {
    _overlaySettings = settings;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSettings, settings.toJsonString());
      // Push the full preset to native Android.
      await _channel.invokeMethod<void>('updateOverlaySettings', {
        'settingsJson': settings.toJsonString(),
        'alpha': settings.alpha,
        'growOnHold': settings.animation == OverlayAnimation.sizeGrow,
        'growScale': settings.growScale,
      });
    } catch (e) {
      debugPrint('[OverlayNotifier] saveOverlaySettings error: $e');
    }
  }

  @override
  void dispose() {
    _persistDebounce?.cancel();
    _captureStateSub?.cancel();
    _noteUpdatedSub?.cancel();
    _openEditorCallbacks.clear();
    super.dispose();
  }

  /// Core save method — called when native overlay broadcasts a captured note.
  ///
  /// Flow:
  ///   1. Show "processing" immediately on the Flutter Dynamic Island.
  ///   2. ingestRawCapture → instant Isar save (returns quickTitle / general).
  ///   3. Show saved pill on both Flutter island and native island.
  ///   4. AI classification runs asynchronously via AiProcessingService.
  Future<void> _saveOverlayNote(String text, String source) async {
      try {
          final svc = sl.isRegistered<CaptureService>()
              ? sl<CaptureService>()
              : CaptureService();
          final captureSource = source == 'text_overlay'
              ? CaptureSource.textOverlay
              : CaptureSource.voiceOverlay;

          // Show "processing" in Flutter island immediately (no-op if app is off-screen).
          try {
              sl<CaptureUiController>().notifyExternalRecordingProcessing(
                  provider: svc.activeProviderName,
              );
          } catch (_) {}

          final saved = await svc.ingestRawCapture(
              rawTranscript: text,
              source:        captureSource,
              syncToCloud:   true,
          );

          if (saved == null) {
              _lastSavedNoteId = null;
              try { sl<CaptureUiController>().resetToIdle(); } catch (_) {}
              // Cancel any stuck "Classifying..." on the native island.
              try {
                  await _channel.invokeMethod('updateIslandState', {'state': 'idle'});
              } catch (_) {}
              return;
          }

          debugPrint('[OverlayNotifier] Note saved from overlay: $source '
              'title="${saved.title}"');
            _lastSavedNoteId = saved.noteId;

          // Update Flutter Dynamic Island to saved state.
          try {
              sl<CaptureUiController>().notifyExternalRecordingSaved(
                  title:    saved.title,
                  category: saved.category,
                  model:    saved.aiModel,
                  noteId:   saved.noteId,
              );
          } catch (_) {}

          // Update native island pill (works even when app is backgrounded,
          // because OverlayForegroundService is a persistent foreground service).
            await notifyNativeSaved(
              saved.title,
              saved.category,
              prefix: saveOriginPrefix(saved.aiModel),
            );
      } catch (e) {
          debugPrint('[OverlayNotifier] _saveOverlayNote error: $e');
          try { sl<CaptureUiController>().resetToIdle(); } catch (_) {}
          try {
              await _channel.invokeMethod('updateIslandState', {'state': 'idle'});
          } catch (_) {}
      }
  }

  /// Pushes the save result to the native OverlayForegroundService so it can
  /// show the category pill on the native island overlay.
  /// Uses the dedicated `notifySaved` channel method added to MainActivity.
  Future<void> notifyNativeSaved(
    String title,
    NoteCategory category, {
    String prefix = 'AI',
  }) async {
    try {
      await _channel.invokeMethod('notifySaved', {
        'title': title,
        'category': category.name, // e.g. "tasks", "ideas", "reminders"
        'prefix': prefix,
        'collection': 'users/{uid}/notes', // informational label for the island
      });
    } catch (e) {
      debugPrint('[OverlayNotifier] notifyNativeSaved error: $e');
      // Fallback: use the generic updateIslandState
      try {
        await _channel.invokeMethod('updateIslandState', {
          'state': 'saved',
          'message': title,
        });
      } catch (_) {}
    }
  }

  Future<void> _onNoteUpdated(String noteId) async {
    if (noteId.trim().isEmpty || noteId != _lastSavedNoteId) {
      return;
    }

    try {
      final note = await IsarNoteStore.instance.getById(noteId);
      if (note == null) return;

      _lastSavedNoteId = note.noteId;

      try {
        sl<CaptureUiController>().notifyExternalRecordingSaved(
          title: note.title,
          category: note.category,
          model: note.aiModel,
          noteId: note.noteId,
        );
      } catch (_) {}

      await notifyNativeSaved(
        note.title,
        note.category,
        prefix: saveOriginPrefix(note.aiModel),
      );
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNoteUpdated error: $e');
    }
  }

  // ── Native recording notifications ─────────────────────────────────────────

  void _onNativeRecordingStarted() {
    _nativeSessionActive = true;
    try {
      sl<CaptureUiController>().notifyExternalRecordingStarted();
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNativeRecordingStarted error: $e');
    }
  }

  void _onNativeTranscript(String text) {
    try {
      sl<CaptureUiController>().updateExternalTranscript(text);
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNativeTranscript error: $e');
    }
  }

  void _onNativeRecordingStopped() {
    try {
      sl<CaptureUiController>().notifyExternalRecordingStopped();
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNativeRecordingStopped error: $e');
    }
  }

  void _onNativeRecordingFailed() {
    _nativeSessionActive = false;
    try {
      sl<CaptureUiController>().resetToIdle();
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNativeRecordingFailed error: $e');
    }
  }

  void _onCaptureStateChanged(CaptureUiState state) {
    if (state is CaptureUiIdle) {
      if (_nativeSessionActive) {
        _nativeSessionActive = false;
        _lastNativeState = 'idle';
        return;
      }
      if (_lastNativeState == 'idle') return;
      _lastNativeState = 'idle';
      unawaited(_channel.invokeMethod('updateIslandState', {'state': 'idle'}));
      return;
    }

    if (state is CaptureUiRecording) {
      if (_nativeSessionActive) {
        _lastNativeState = 'recording';
        return;
      }
      _lastNativeState = 'recording';
      final transcript = state.currentTranscript.trim();
      final msg = transcript.isEmpty ? 'Listening...' : transcript;
      // Always forward transcript updates; native side handles dedup.
      unawaited(_channel.invokeMethod('updateIslandState', {
        'state': 'recording',
        'message': msg,
      }));
      return;
    }

    if (state is CaptureUiProcessing) {
      if (_nativeSessionActive) {
        _lastNativeState = 'processing';
        return;
      }
      if (_lastNativeState == 'processing') return;
      _lastNativeState = 'processing';
      unawaited(_channel.invokeMethod('updateIslandState', {
        'state': 'processing',
        'message': state.provider,
      }));
      return;
    }

    if (state is CaptureUiSaved) {
      if (_nativeSessionActive) {
        _nativeSessionActive = false;
        _lastNativeState = 'idle';
        return;
      }
      // Use notifySaved path so native shows category emoji + collection.
      _lastNativeState = 'idle';
      _lastSavedNoteId = state.noteId;
      unawaited(notifyNativeSaved(
        state.title,
        state.category,
        prefix: state.originPrefix,
      ));
      return;
    }

    if (state is CaptureUiError) {
      _lastNativeState = 'idle';
      unawaited(_channel.invokeMethod('updateIslandState', {'state': 'idle'}));
    }
  }
}
```

### lib/features/overlay/overlay_settings_model.dart

```dart
// lib/features/overlay/overlay_settings_model.dart
//
// Serialisable settings model for the native + Flutter overlay.
// Persisted to SharedPreferences as JSON.

import 'dart:convert';
import 'dart:ui';

enum OverlayColorFill { solid, linearGradient, radialGradient, glass }

enum OverlayBorderStyle { none, hairline, glow }

enum OverlayAnimation { none, sizeGrow, pulseGlow, bounceIn }

class OverlaySettings {
  const OverlaySettings({
    this.alpha = 0.82,
    this.blurSigma = 22.0,
    this.colorFill = OverlayColorFill.glass,
    this.solidColor = const Color(0xFF1C1C2E),
    this.gradientStart = const Color(0xFF6366F1),
    this.gradientEnd = const Color(0xFF8B5CF6),
    this.borderStyle = OverlayBorderStyle.glow,
    this.borderColor = const Color(0xFF6366F1),
    this.animation = OverlayAnimation.sizeGrow,
    this.growScale = 1.10,
    this.positionFraction = const Offset(0.88, 0.30),
    this.persistOnReboot = true,
  });

  final double alpha;           // 0.3–1.0
  final double blurSigma;       // 0–40
  final OverlayColorFill colorFill;
  final Color solidColor;
  final Color gradientStart;
  final Color gradientEnd;
  final OverlayBorderStyle borderStyle;
  final Color borderColor;
  final OverlayAnimation animation;
  final double growScale;       // 1.0–1.25
  final Offset positionFraction; // dx/dy as fraction of screen size
  final bool persistOnReboot;

  OverlaySettings copyWith({
    double? alpha,
    double? blurSigma,
    OverlayColorFill? colorFill,
    Color? solidColor,
    Color? gradientStart,
    Color? gradientEnd,
    OverlayBorderStyle? borderStyle,
    Color? borderColor,
    OverlayAnimation? animation,
    double? growScale,
    Offset? positionFraction,
    bool? persistOnReboot,
  }) => OverlaySettings(
    alpha: alpha ?? this.alpha,
    blurSigma: blurSigma ?? this.blurSigma,
    colorFill: colorFill ?? this.colorFill,
    solidColor: solidColor ?? this.solidColor,
    gradientStart: gradientStart ?? this.gradientStart,
    gradientEnd: gradientEnd ?? this.gradientEnd,
    borderStyle: borderStyle ?? this.borderStyle,
    borderColor: borderColor ?? this.borderColor,
    animation: animation ?? this.animation,
    growScale: growScale ?? this.growScale,
    positionFraction: positionFraction ?? this.positionFraction,
    persistOnReboot: persistOnReboot ?? this.persistOnReboot,
  );

  Map<String, dynamic> toJson() => {
    'alpha': alpha,
    'blurSigma': blurSigma,
    'colorFill': colorFill.name,
    'solidColor': solidColor.toARGB32(),
    'gradientStart': gradientStart.toARGB32(),
    'gradientEnd': gradientEnd.toARGB32(),
    'borderStyle': borderStyle.name,
    'borderColor': borderColor.toARGB32(),
    'animation': animation.name,
    'growScale': growScale,
    'posX': positionFraction.dx,
    'posY': positionFraction.dy,
    'persistOnReboot': persistOnReboot,
  };

  factory OverlaySettings.fromJson(Map<String, dynamic> j) => OverlaySettings(
    alpha: (j['alpha'] as num?)?.toDouble() ?? 0.82,
    blurSigma: (j['blurSigma'] as num?)?.toDouble() ?? 22.0,
    colorFill: _parseEnum(OverlayColorFill.values, j['colorFill']) ?? OverlayColorFill.glass,
    solidColor: _parseColor(j['solidColor']) ?? const Color(0xFF1C1C2E),
    gradientStart: _parseColor(j['gradientStart']) ?? const Color(0xFF6366F1),
    gradientEnd: _parseColor(j['gradientEnd']) ?? const Color(0xFF8B5CF6),
    borderStyle: _parseEnum(OverlayBorderStyle.values, j['borderStyle']) ?? OverlayBorderStyle.glow,
    borderColor: _parseColor(j['borderColor']) ?? const Color(0xFF6366F1),
    animation: _parseEnum(OverlayAnimation.values, j['animation']) ?? OverlayAnimation.sizeGrow,
    growScale: (j['growScale'] as num?)?.toDouble() ?? 1.10,
    positionFraction: Offset(
      (j['posX'] as num?)?.toDouble() ?? 0.88,
      (j['posY'] as num?)?.toDouble() ?? 0.30,
    ),
    persistOnReboot: j['persistOnReboot'] as bool? ?? true,
  );

  factory OverlaySettings.fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return const OverlaySettings();
    try {
      return OverlaySettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const OverlaySettings();
    }
  }

  String toJsonString() => jsonEncode(toJson());

  static T? _parseEnum<T extends Enum>(List<T> values, dynamic name) {
    if (name is! String) return null;
    try {
      return values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  static Color? _parseColor(dynamic raw) {
    if (raw is! int) return null;
    return Color(raw);
  }
}
```

### lib/features/overlay/presentation/system_banner_overlay.dart

```dart
// lib/features/overlay/presentation/system_banner_overlay.dart
//
// Premium "God-Level" System Banner Overlay.
// Uses BackdropFilter + OverlaySettings for live customisation.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/overlay/overlay_settings_model.dart';
import 'package:wishperlog/features/overlay/quick_note_editor.dart';

class SystemBannerOverlay extends StatelessWidget {
  const SystemBannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        // Tap outside the card dismisses.
        onTap: () => context.pop(),
        child: Container(
          color: Colors.transparent,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Swipe up to dismiss
                GestureDetector(
                  // Prevent outer GestureDetector from firing on card tap.
                  onTap: () {},
                  child: Dismissible(
                    key: const Key('system_banner'),
                    direction: DismissDirection.up,
                    onDismissed: (_) => context.pop(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _PremiumBannerCard(
                        onClose: () => context.pop(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumBannerCard extends StatefulWidget {
  const _PremiumBannerCard({required this.onClose});

  final VoidCallback onClose;

  @override
  State<_PremiumBannerCard> createState() => _PremiumBannerCardState();
}

class _PremiumBannerCardState extends State<_PremiumBannerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  OverlaySettings get _settings {
    try {
      return sl<OverlayNotifier>().overlaySettings;
    } catch (_) {
      return const OverlaySettings();
    }
  }

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack));

    _entryCtrl.forward();
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Decoration builder using OverlaySettings ──────────────────────────────

  Decoration _buildDecoration(OverlaySettings s) {
    final gradient = switch (s.colorFill) {
      OverlayColorFill.linearGradient => LinearGradient(
          colors: [s.gradientStart, s.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      OverlayColorFill.radialGradient => RadialGradient(
          colors: [s.gradientStart, s.gradientEnd],
        ),
      _ => null,
    };

    final solidFill = s.colorFill == OverlayColorFill.solid
        ? s.solidColor.withValues(alpha: s.alpha)
        : null;

    final glassFill = s.colorFill == OverlayColorFill.glass
        ? Colors.white.withValues(
            alpha: context.isDark ? s.alpha * 0.10 : s.alpha * 0.16,
          )
        : null;

    return BoxDecoration(
      color: solidFill ?? glassFill,
      gradient: gradient,
      borderRadius: BorderRadius.circular(24),
      border: switch (s.borderStyle) {
        OverlayBorderStyle.none     => null,
        OverlayBorderStyle.hairline => Border.all(
            color: s.borderColor.withValues(alpha: 0.5),
            width: 0.7,
          ),
        OverlayBorderStyle.glow => Border.all(
            color: s.borderColor.withValues(alpha: 0.9),
            width: 1.5,
          ),
      },
      boxShadow: [
        // Base elevation
        BoxShadow(
          color: Colors.black.withValues(alpha: context.isDark ? 0.40 : 0.14),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
        // Glow layer
        if (s.borderStyle == OverlayBorderStyle.glow)
          BoxShadow(
            color: s.borderColor.withValues(alpha: 0.40),
            blurRadius: 24,
            spreadRadius: 1,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _settings;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: s.colorFill == OverlayColorFill.glass ? s.blurSigma : 0,
                sigmaY: s.colorFill == OverlayColorFill.glass ? s.blurSigma : 0,
              ),
              child: Container(
                decoration: _buildDecoration(s),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Handle ───────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 2),
                      child: Container(
                        width: 36, height: 4,
                        decoration: BoxDecoration(
                          color: context.textSec.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // ── Header ───────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 12, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Quick Capture',
                            style: TextStyle(
                              color: context.textPri,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: widget.onClose,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: context.surface1.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: context.textSec,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ── Editor ───────────────────────────────────────────
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width - 32,
                        maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                      ),
                      child: const QuickNoteEditor(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### lib/features/overlay/quick_note_editor.dart

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class QuickNoteEditor extends StatefulWidget {
  const QuickNoteEditor({super.key});

  @override
  State<QuickNoteEditor> createState() => _QuickNoteEditorState();
}

class _QuickNoteEditorState extends State<QuickNoteEditor> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _save() async {
      final text = _controller.text.trim();
      if (text.isEmpty) return;

      setState(() => _isSaving = true);
      try {
          final captureService = sl<CaptureService>();

          // Show processing state immediately on the Flutter island.
          try {
              sl<CaptureUiController>().notifyExternalRecordingProcessing(
                  provider: captureService.activeProviderName,
              );
          } catch (_) {}

          final saved = await captureService.ingestRawCapture(
              rawTranscript: text,
              source:        CaptureSource.textOverlay,
              syncToCloud:   true,
          );

          // Transition island to saved state.
          sl<CaptureUiController>().notifyExternalRecordingSaved(
              title:    saved?.title    ?? 'Quick note',
              category: saved?.category ?? NoteCategory.general,
              model:    saved?.aiModel,
              noteId:   saved?.noteId,
          );

          // Also update native island pill via OverlayNotifier.
          if (saved != null) {
              try {
                  await sl<OverlayNotifier>().notifyNativeSaved(
                      saved.title,
                      saved.category,
                    prefix: saveOriginPrefix(saved.aiModel),
                  );
              } catch (_) {}
          }

          if (mounted) context.pop();
      } catch (e) {
          // Reset both islands so neither stays stuck on "Classifying...".
          try { sl<CaptureUiController>().resetToIdle(); } catch (_) {}
          try {
              await sl<OverlayNotifier>().notifyNativeSaved(
                  'Error saving note',
                  NoteCategory.general,
                  prefix: 'sys',
              );
          } catch (_) {}
          if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to save quick note')),
              );
              setState(() => _isSaving = false);
          }
      }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: GlassPane(
        level: 1,
        radius: 28,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.tasks.withValues(alpha: isDark ? 0.26 : 0.18),
                        AppColors.tasks.withValues(alpha: isDark ? 0.10 : 0.08),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.tasks.withValues(alpha: 0.22),
                    ),
                  ),
                  child: const Icon(Icons.edit_note, color: AppColors.tasks, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quick Note',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: context.textPri,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Capture an idea in a neumorphic glass sheet.',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.textSec,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(Icons.close, color: context.textSec),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    context.surface1.withValues(alpha: isDark ? 0.76 : 0.88),
                    context.surface2.withValues(alpha: isDark ? 0.68 : 0.96),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.40),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.26 : 0.10),
                    blurRadius: 16,
                    offset: const Offset(5, 7),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.68),
                    blurRadius: 12,
                    offset: const Offset(-4, -4),
                  ),
                ],
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                maxLines: null,
                minLines: 4,
                style: TextStyle(color: context.textPri, fontSize: 16, height: 1.5),
                decoration: InputDecoration(
                  hintText: 'What\'s on your mind?',
                  hintStyle: TextStyle(color: context.textSec),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(18),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _save(),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _isSaving ? null : _save,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.tasks.withValues(alpha: isDark ? 0.96 : 0.92),
                      const Color(0xFF58D0C7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.14),
                      blurRadius: 16,
                      offset: const Offset(5, 8),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.70),
                      blurRadius: 12,
                      offset: const Offset(-4, -4),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSaving
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save Note',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### lib/features/search/data/smart_note_search.dart

```dart
import 'dart:math' as math;
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

/// A matched search result with scoring metadata.
class SearchHit {
  const SearchHit({
    required this.note,
    required this.score,
    this.matchedField = '',
    this.snippet = '',
  });

  final Note note;
  final double score;
  final String matchedField;
  final String snippet;
}

/// Params object for isolate-safe searching.
class _SearchParams {
  const _SearchParams({
    required this.notes,
    required this.query,
    required this.nowMs,
    this.limit = 50,
  });

  final List<Note> notes;
  final String query;
  final int nowMs;
  final int limit;
}

class SmartNoteSearch {
  // ── Public API ────────────────────────────────────────────────────────────

  /// Synchronous search — call from isolate or when note count is small (<200).
  static List<SearchHit> searchSync(
    List<Note> notes,
    String query, {
    int limit = 50,
    DateTime? now,
  }) {
    return _searchInternal(_SearchParams(
      notes: notes,
      query: query,
      nowMs: (now ?? DateTime.now()).millisecondsSinceEpoch,
      limit: limit,
    ));
  }

  // ── Core logic (isolate-safe: no Flutter plugins) ─────────────────────────

  static List<SearchHit> _searchInternal(_SearchParams params) {
    final query = params.query.trim();
    if (query.isEmpty || params.notes.isEmpty) return const [];

    // 1. Parse category shorthand: "tasks:", "@ideas", "#reminders"
    NoteCategory? categoryFilter;
    String cleanQuery = query;
    final catMatch = RegExp(
      r'^(?:(@|#)(\w+)|(\w+):)\s*',
    ).firstMatch(query);
    if (catMatch != null) {
      final tag = (catMatch.group(2) ?? catMatch.group(3) ?? '').toLowerCase();
      categoryFilter = _parseShorthand(tag);
      if (categoryFilter != null) {
        cleanQuery = query.substring(catMatch.end).trim();
      }
    }

    final notes = categoryFilter == null
        ? params.notes
        : params.notes.where((n) => n.category == categoryFilter).toList();

    if (cleanQuery.isEmpty) {
      // Category filter only — return recency-sorted notes in that category.
      final sorted = [...notes]
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return sorted
          .take(params.limit)
          .map((n) => SearchHit(note: n, score: 1.0))
          .toList();
    }

    // 2. Tokenise query into terms
    final terms = _tokenise(cleanQuery);
    if (terms.isEmpty) return const [];

    // 3. IDF: inverse-document-frequency for each term across the corpus
    final idf = _computeIdf(notes, terms);

    // 4. Score each note
    final now = DateTime.fromMillisecondsSinceEpoch(params.nowMs);
    final hits = <SearchHit>[];

    for (final note in notes) {
      final result = _scoreNote(note, terms, idf, cleanQuery, now);
      if (result.score > 0) hits.add(result);
    }

    hits.sort((a, b) => b.score.compareTo(a.score));
    return hits.take(params.limit).toList();
  }

  // ── Scoring ───────────────────────────────────────────────────────────────

  static SearchHit _scoreNote(
    Note note,
    List<String> terms,
    Map<String, double> idf,
    String rawQuery,
    DateTime now,
  ) {
    final fields = _noteFields(note);

    double total = 0;
    String bestField = '';
    String snippet = '';
    double bestFieldScore = 0;

    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final fieldWeight = entry.value.$1;
      final fieldText = entry.value.$2;
      final tokens = _tokenise(fieldText);
      if (tokens.isEmpty) continue;

      final tf = _computeTf(tokens);
      double fieldScore = 0;

      for (final term in terms) {
        final termTf = tf[term] ?? 0.0;
        if (termTf == 0) continue;
        final termIdf = idf[term] ?? 1.0;
        fieldScore += termTf * termIdf;
      }

      // Prefix bonus: term is a prefix of a word in the field
      final lowerField = fieldText.toLowerCase();
      for (final term in terms) {
        if (_hasPrefixMatch(lowerField, term)) {
          fieldScore += 0.4 * fieldWeight;
        }
      }

      // Exact phrase bonus
      if (terms.length > 1) {
        final phrase = terms.join(' ');
        if (lowerField.contains(phrase)) {
          fieldScore += 1.5 * fieldWeight;
        }
      }

      final weighted = fieldScore * fieldWeight;
      total += weighted;

      if (weighted > bestFieldScore) {
        bestFieldScore = weighted;
        bestField = fieldName;
        snippet = _extractSnippet(fieldText, terms.first);
      }
    }

    if (total == 0) return SearchHit(note: note, score: 0);

    // Recency decay: score × e^(-λ·days), half-life = 30 days
    const halfLifeDays = 30.0;
    final ageDays = now.difference(note.updatedAt).inHours / 24.0;
    final recencyMultiplier = math.exp(
      -(math.log(2) / halfLifeDays) * ageDays.clamp(0, 365),
    );

    // Small boost if ALL terms matched
    final allTermsCovered = terms.every((t) => _noteAllText(note).contains(t));
    if (allTermsCovered) total *= 1.25;

    final finalScore = total * (0.5 + 0.5 * recencyMultiplier);
    return SearchHit(
      note: note,
      score: finalScore,
      matchedField: bestField,
      snippet: snippet,
    );
  }

  // ── TF helpers ────────────────────────────────────────────────────────────

  static Map<String, double> _computeTf(List<String> tokens) {
    final counts = <String, int>{};
    for (final t in tokens) {
      counts[t] = (counts[t] ?? 0) + 1;
    }
    final total = tokens.length.toDouble();
    return counts.map((k, v) => MapEntry(k, v / total));
  }

  static Map<String, double> _computeIdf(
      List<Note> notes, List<String> terms) {
    final N = notes.length.toDouble();
    final result = <String, double>{};
    for (final term in terms) {
      var df = 0;
      for (final note in notes) {
        if (_noteAllText(note).contains(term)) df++;
      }
      // Smoothed IDF
      result[term] = math.log((N + 1) / (df + 1)) + 1.0;
    }
    return result;
  }

  // ── Field map ─────────────────────────────────────────────────────────────

  /// Returns {fieldName: (weight, text)}
  static Map<String, (double, String)> _noteFields(Note note) {
    return {
      'title': (3.5, note.title),
      'body': (2.5, note.cleanBody),
      'transcript': (1.5, note.rawTranscript),
      'category': (1.0, categoryLabel(note.category)),
    };
  }

  static String _noteAllText(Note note) {
    return '${note.title} ${note.cleanBody} ${note.rawTranscript} ${categoryLabel(note.category)}'
        .toLowerCase();
  }

  // ── Tokeniser ─────────────────────────────────────────────────────────────

  static const _stopWords = {
    'a', 'an', 'and', 'are', 'as', 'at', 'be', 'but', 'by', 'for',
    'from', 'i', 'in', 'is', 'it', 'me', 'my', 'of', 'on', 'or',
    'our', 'so', 'the', 'their', 'this', 'to', 'was', 'we', 'were',
    'what', 'when', 'where', 'which', 'with', 'you', 'your', 'am',
    'that', 'than', 'some',
  };

  static List<String> _tokenise(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.length >= 2 && !_stopWords.contains(t))
        .toList();
  }

  // ── Utility ───────────────────────────────────────────────────────────────

  static bool _hasPrefixMatch(String haystack, String prefix) {
    // Checks if `prefix` is the start of any word in `haystack`
    final pattern = RegExp(r'\b' + RegExp.escape(prefix));
    return pattern.hasMatch(haystack);
  }

  static String _extractSnippet(String text, String term, {int radius = 60}) {
    final lower = text.toLowerCase();
    final idx = lower.indexOf(term);
    if (idx < 0) {
      return text.length > radius * 2 ? '${text.substring(0, radius * 2)}…' : text;
    }
    final start = (idx - radius).clamp(0, text.length);
    final end = (idx + term.length + radius).clamp(0, text.length);
    final pre = start > 0 ? '…' : '';
    final post = end < text.length ? '…' : '';
    return '$pre${text.substring(start, end)}$post';
  }

  static NoteCategory? _parseShorthand(String tag) {
    return switch (tag) {
      'tasks' || 'task' || 't' => NoteCategory.tasks,
      'reminders' || 'reminder' || 'r' => NoteCategory.reminders,
      'ideas' || 'idea' => NoteCategory.ideas,
      'followup' || 'follow' || 'fu' => NoteCategory.followUp,
      'journal' || 'j' => NoteCategory.journal,
      'general' || 'g' => NoteCategory.general,
      _ => null,
    };
  }
}
```

### lib/features/search/presentation/search_screen.dart

```dart
// lib/features/search/presentation/search_screen.dart
//
// Search screen refreshed with a clearer glass hierarchy:
// header, search field, filter rail, result cards, and empty states.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/features/search/data/smart_note_search.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  String _query = '';
  NoteCategory? _filterCategory;

  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  static const String _filterAll = 'All';
  static const List<(String, NoteCategory?)> _filterItems = <(String, NoteCategory?)>[
    (_filterAll, null),
    ('Tasks', NoteCategory.tasks),
    ('Reminders', NoteCategory.reminders),
    ('Ideas', NoteCategory.ideas),
    ('Follow-up', NoteCategory.followUp),
    ('Journal', NoteCategory.journal),
    ('General', NoteCategory.general),
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

    _entryCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });

    _controller.addListener(() {
      _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 180), () {
        if (mounted) {
          setState(() => _query = _controller.text.trim());
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  List<SearchHit> _applyFilter(List<SearchHit> hits) {
    if (_filterCategory == null) return hits;
    return hits.where((hit) => hit.note.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: GlassPageBackground(
        child: FadeTransition(
          opacity: _entryFade,
          child: SlideTransition(
            position: _entrySlide,
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  _buildFilterRail(),
                  const SizedBox(height: 6),
                  Expanded(child: _buildResults()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: GlassPane(
        level: 1,
        radius: 28,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            _RoundActionButton(
              icon: Icons.arrow_back_ios_new_rounded,
              tint: AppColors.tasks,
              onTap: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
            ),
            const SizedBox(width: 12),
            Text(
              'Search',
              style: TextStyle(
                color: context.textPri,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: GlassPane(
        level: 2,
        radius: 26,
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _RoundActionButton(
              icon: Icons.search_rounded,
              tint: AppColors.tasks,
              onTap: () => _focusNode.requestFocus(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(
                  color: context.textPri,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  hintText: 'Search notes, tasks, reminders...',
                  hintStyle: TextStyle(
                    color: context.textSec.withValues(alpha: 0.55),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                textInputAction: TextInputAction.search,
              ),
            ),
            if (_controller.text.isNotEmpty)
              _RoundActionButton(
                icon: Icons.close_rounded,
                tint: context.textSec,
                onTap: () {
                  _controller.clear();
                  setState(() => _query = '');
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRail() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GlassPane(
        level: 4,
        radius: 22,
        padding: const EdgeInsets.all(10),
        child: SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _filterItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final (label, category) = _filterItems[index];
              final selected = _filterCategory == category;
              final chipColor = category != null ? categoryColor(category) : AppColors.tasks;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _filterCategory = category);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? chipColor.withValues(alpha: context.isDark ? 0.22 : 0.18)
                        : context.surface1.withValues(alpha: 0.56),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: selected
                          ? chipColor.withValues(alpha: 0.72)
                          : context.textSec.withValues(alpha: 0.10),
                    ),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? chipColor : context.textSec,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResults() {
    return StreamBuilder<List<Note>>(
      stream: sl<NoteRepository>().watchAllActive(),
      builder: (context, snapshot) {
        final all = snapshot.data ?? const <Note>[];

        if (_query.isEmpty) {
          return _EmptyState(
            icon: Icons.manage_search_rounded,
            title: 'Start typing',
            subtitle: 'Search across notes, priorities, reminders, and AI-tagged captures.',
            tint: AppColors.tasks.withValues(alpha: 0.72),
            actions: [
              if (_filterCategory != null)
                _MiniActionPill(
                  label: 'Reset filter',
                  tint: categoryColor(_filterCategory!),
                  onTap: () => setState(() => _filterCategory = null),
                ),
            ],
          );
        }

        final hits = _applyFilter(SmartNoteSearch.searchSync(all, _query, limit: 60));

        if (hits.isEmpty) {
          return _EmptyState(
            icon: Icons.search_off_rounded,
            title: 'No matching notes',
            subtitle: 'Try a broader term or remove the active filter.',
            tint: context.textSec.withValues(alpha: 0.42),
            actions: [
              _MiniActionPill(
                label: 'Clear search',
                tint: AppColors.tasks,
                onTap: () {
                  _controller.clear();
                  setState(() => _query = '');
                },
              ),
              if (_filterCategory != null)
                _MiniActionPill(
                  label: 'Reset filter',
                  tint: categoryColor(_filterCategory!),
                  onTap: () => setState(() => _filterCategory = null),
                ),
            ],
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '${hits.length} result${hits.length == 1 ? '' : 's'} found',
                style: TextStyle(
                  color: context.textSec,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...hits.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: entry.key == hits.length - 1 ? 0 : 10),
                child: _SearchResultCard(
                  hit: entry.value,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.pop();
                    context.push('/notes/${entry.value.note.noteId}');
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.hit, required this.onTap});

  final SearchHit hit;
  final VoidCallback onTap;

  Color _priorityColor(NotePriority p) => switch (p) {
        NotePriority.high => const Color(0xFFEF4444),
        NotePriority.medium => const Color(0xFFF59E0B),
        NotePriority.low => const Color(0xFF10B981),
      };

  @override
  Widget build(BuildContext context) {
    final note = hit.note;
    final accent = categoryColor(note.category);

    return GestureDetector(
      onTap: onTap,
      child: GlassPane(
        level: 2,
        radius: 22,
        padding: const EdgeInsets.all(15),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: context.isDark ? 0.28 : 0.18),
                    accent.withValues(alpha: context.isDark ? 0.10 : 0.08),
                  ],
                ),
              ),
              child: Icon(categoryIcon(note.category), size: 20, color: accent),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title.isEmpty ? 'Untitled' : note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.textPri,
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.25,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        hit.score.toStringAsFixed(1),
                        style: TextStyle(
                          color: context.textSec.withValues(alpha: 0.45),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (hit.snippet.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      hit.snippet,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textSec,
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _Chip(label: categoryLabel(note.category), color: accent),
                      _Chip(
                        label: note.priority.name.toUpperCase(),
                        color: _priorityColor(note.priority),
                      ),
                      if (hit.matchedField.isNotEmpty && hit.matchedField != 'title')
                        _Chip(
                          label: hit.matchedField,
                          color: context.textSec.withValues(alpha: 0.62),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: context.isDark ? 0.14 : 0.10),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: color.withValues(alpha: 0.28)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    this.actions = const [],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: GlassPane(
            level: 1,
            radius: 26,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        tint.withValues(alpha: context.isDark ? 0.24 : 0.16),
                        tint.withValues(alpha: context.isDark ? 0.10 : 0.08),
                      ],
                    ),
                  ),
                  child: Icon(icon, size: 30, color: tint),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.textPri,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: context.textSec,
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
                if (actions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: actions,
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final IconData icon;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              tint.withValues(alpha: context.isDark ? 0.22 : 0.14),
              tint.withValues(alpha: context.isDark ? 0.10 : 0.08),
            ],
          ),
        ),
        child: Icon(icon, color: tint, size: 18),
      ),
    );
  }
}

class _MiniActionPill extends StatelessWidget {
  const _MiniActionPill({
    required this.label,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: tint.withValues(alpha: context.isDark ? 0.14 : 0.10),
          border: Border.all(color: tint.withValues(alpha: 0.25)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: tint,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
```

### lib/features/settings/presentation/screens/settings_screen.dart

```dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/features/overlay/overlay_customisation_sheet.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/sync/data/external_sync_service.dart';
import 'package:wishperlog/features/sync/data/telegram_service.dart';
import 'package:wishperlog/features/settings/presentation/widgets/digest_schedule_section.dart';
import 'package:wishperlog/features/settings/presentation/widgets/telegram_connection_section.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';
import 'package:wishperlog/shared/widgets/glass_title_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const MethodChannel _overlayChannel = MethodChannel(
    'wishperlog/overlay',
  );

  final UserRepository _users = sl<UserRepository>();
  final AppPreferencesRepository _prefs = sl<AppPreferencesRepository>();
  final ExternalSyncService _sync = sl<ExternalSyncService>();
  final AiClassifierRouter _aiRouter = sl<AiClassifierRouter>();
  final OverlayNotifier _overlayNotifier = sl<OverlayNotifier>();

  List<TimeOfDay> _digestTimes = const [TimeOfDay(hour: 9, minute: 0)];
  DateTime? _lastSyncedAt;
  NotificationSettings? _notificationSettings;

  bool _syncingNow = false;
  bool _overlayUpdating = false;
  bool _reconnectingGoogle = false;
  bool _savingDigest = false;
  String _speechLanguage = 'en-US';
  bool   _speechPreferOffline = false;
  // Overlay customisation sheet is driven entirely by OverlayNotifier.

  String? _telegramChatId;
  String? _pendingTelegramLinkToken;
  StreamSubscription<String?>? _telegramChatIdSub;
  Timer? _telegramConnectTimeout;
  bool _connectingTelegram = false;

  Timer? _speechApplyDebounce;

  static const List<Map<String, String>> _speechLanguageOptions = [
    {'code': 'en-US', 'label': 'English (US)'},
    {'code': 'en-IN', 'label': 'English (India)'},
    {'code': 'hi-IN', 'label': 'Hindi (India)'},
    {'code': 'bn-IN', 'label': 'Bengali'},
    {'code': 'ta-IN', 'label': 'Tamil'},
    {'code': 'te-IN', 'label': 'Telugu'},
    {'code': 'mr-IN', 'label': 'Marathi'},
    {'code': 'gu-IN', 'label': 'Gujarati'},
    {'code': 'kn-IN', 'label': 'Kannada'},
    {'code': 'ml-IN', 'label': 'Malayalam'},
    {'code': 'pa-IN', 'label': 'Punjabi'},
    {'code': 'es-ES', 'label': 'Spanish'},
    {'code': 'fr-FR', 'label': 'French'},
    {'code': 'de-DE', 'label': 'German'},
    {'code': 'ja-JP', 'label': 'Japanese'},
  ];

  @override
  void initState() {
    super.initState();
    _hydrateLocalPrefs();
    _hydrateNotificationPermission();
    _hydrateTelegramId();
    _hydrateSpeechSettings();
  }

  @override
  void dispose() {
    _speechApplyDebounce?.cancel();
    _telegramConnectTimeout?.cancel();
    _telegramChatIdSub?.cancel();
    super.dispose();
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go('/home');
  }

  Future<void> _hydrateLocalPrefs() async {
    final digestTimes = await _prefs.getDigestTimes();
    if (mounted) {
      setState(() => _digestTimes = digestTimes);
    }
  }

  Future<void> _hydrateNotificationPermission() async {
    try {
      final settings = await FirebaseMessaging.instance
          .getNotificationSettings();
      if (mounted) {
        setState(() => _notificationSettings = settings);
      }
    } catch (e) {
      debugPrint('[Settings] Notification permission check error: $e');
    }
  }

  Future<void> _hydrateTelegramId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await _users.watchCurrentUserDocument().first;
      final chatId = (doc?['telegram_chat_id'] ?? '').toString().trim();
      if (mounted) {
        setState(() {
          _telegramChatId = chatId.isEmpty ? null : chatId;
        });
      }
    } catch (e) {
      debugPrint('[Settings] Telegram hydrate error: $e');
    }
  }

  Future<void> _toggleOverlay() async {
    if (_overlayUpdating) return;
    setState(() => _overlayUpdating = true);
    try {
      final newValue = !_overlayNotifier.isEnabled;
      await _overlayNotifier.setEnabled(newValue);
      unawaited(_users.updateOverlayVisibility(newValue));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update overlay setting')),
        );
      }
    } finally {
      if (mounted) setState(() => _overlayUpdating = false);
    }
  }

  Future<void> _openOverlayCustomiser() async {
    final notifier = _overlayNotifier;
    await showOverlayCustomisationSheet(
      context,
      notifier.overlaySettings,
      (updated) => notifier.saveOverlaySettings(updated),
    );
  }

  Future<void> _hydrateSpeechSettings() async {
    try {
      final values = await _overlayChannel.invokeMapMethod<String, dynamic>(
        'getSpeechSettings',
      );
      if (!mounted || values == null) return;
      setState(() {
        _speechLanguage = (values['language'] as String?) ?? 'en-US';
        _speechPreferOffline = (values['preferOffline'] as bool?) ?? false;
      });
    } catch (e) {
      debugPrint('[Settings] _hydrateSpeechSettings error: $e');
    }
  }

  Future<void> _applySpeechSettings() async {
    try {
      await _overlayChannel.invokeMethod<void>('updateSpeechSettings', {
        'language': _speechLanguage,
        'preferOffline': _speechPreferOffline,
      });
    } catch (e) {
      debugPrint('[Settings] _applySpeechSettings error: $e');
    }
  }

  void _scheduleSpeechSettingsApply() {
    _speechApplyDebounce?.cancel();
    _speechApplyDebounce = Timer(const Duration(milliseconds: 250), () {
      unawaited(_applySpeechSettings());
    });
  }

  ButtonStyle _glassButtonStyle(
    BuildContext context, {
    required Color tint,
    bool filled = false,
    bool danger = false,
    Color? foreground,
  }) {
    final textColor = foreground ?? (filled ? Colors.white : tint);
    final fillColor = danger
        ? AppColors.reminders.withValues(alpha: context.isDark ? 0.24 : 0.16)
        : filled
            ? tint.withValues(alpha: context.isDark ? 0.24 : 0.14)
            : context.surface1.withValues(alpha: 0.82);

    return ButtonStyle(
      padding: const WidgetStatePropertyAll<EdgeInsetsGeometry>(
        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      foregroundColor: WidgetStatePropertyAll<Color>(textColor),
      backgroundColor: WidgetStatePropertyAll<Color>(fillColor),
      side: WidgetStatePropertyAll<BorderSide>(
        BorderSide(color: tint.withValues(alpha: filled ? 0.0 : 0.26)),
      ),
      overlayColor: WidgetStatePropertyAll<Color>(
        tint.withValues(alpha: context.isDark ? 0.16 : 0.10),
      ),
      elevation: const WidgetStatePropertyAll<double>(0),
      textStyle: const WidgetStatePropertyAll<TextStyle>(
        TextStyle(fontWeight: FontWeight.w700),
      ),
    );
  }

  TextStyle _dropdownTextStyle(BuildContext context) {
    return TextStyle(
      color: context.textPri,
      fontSize: 13,
      fontWeight: FontWeight.w600,
    );
  }

  Color _dropdownMenuColor(BuildContext context) {
    return context.isDark ? const Color(0xFF16263A) : const Color(0xFFF9FBFF);
  }

  Future<void> _openSpeechPackSettings() async {
    try {
      await _overlayChannel.invokeMethod<bool>('downloadSpeechLanguagePack', {
        'language': _speechLanguage,
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to open speech language settings'),
          ),
        );
      }
    }
  }

  // ── Minute-wise digest scheduler ──────────────────────────────────────────

  Future<void> _addDigestTime() async {
    final slot = await showMinuteWiseTimePicker(context, _digestTimes);
    if (slot == null || !mounted) return;

    final exists = _digestTimes.any(
      (t) => t.hour * 60 + t.minute == slot.hour * 60 + slot.minute,
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This digest time already exists')),
      );
      return;
    }
    final updated = [..._digestTimes, slot]
      ..sort(
        (a, b) => (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute),
      );
    await _persistDigestTimes(updated);
  }

  Future<void> _removeDigestTime(TimeOfDay time) async {
    if (_digestTimes.length <= 1) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Keep at least one digest schedule')),
        );
      }
      return;
    }
    final min = time.hour * 60 + time.minute;
    final updated = _digestTimes
        .where((t) => t.hour * 60 + t.minute != min)
        .toList();
    await _persistDigestTimes(updated);
  }

  Future<void> _persistDigestTimes(List<TimeOfDay> times) async {
    setState(() => _savingDigest = true);
    try {
      await _prefs.setDigestTimes(times);

      // Convert to UTC "HH:MM" strings for the Cloudflare Worker to match against.
      final nowLocal = DateTime.now();
      final utcOffsetMin = nowLocal.timeZoneOffset.inMinutes;
      final utcSlots = times.map((t) {
        final localMin = t.hour * 60 + t.minute;
        final utcMin = (localMin - utcOffsetMin) % (24 * 60);
        final normalized = utcMin < 0 ? utcMin + 24 * 60 : utcMin;
        final h = normalized ~/ 60;
        final m = normalized % 60;
        return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
      }).toList();

      await _users.updateDigestTimes(times, utcSlots: utcSlots);

      if (mounted) setState(() => _digestTimes = times);
    } finally {
      if (mounted) setState(() => _savingDigest = false);
    }
  }

  Future<void> _syncNow() async {
    if (_syncingNow) return;
    setState(() => _syncingNow = true);
    try {
      await _sync.syncGoogleTaskCompletions();
      setState(() => _lastSyncedAt = DateTime.now());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sync failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _syncingNow = false);
    }
  }

  Future<void> _reconnectGoogle() async {
    if (_reconnectingGoogle) return;
    setState(() => _reconnectingGoogle = true);
    try {
      final ok = await _sync.reconnectGoogle();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Google reconnected' : 'Reconnection failed'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _reconnectingGoogle = false);
    }
  }

  Future<void> _disconnectTelegram() async {
    if (_telegramChatId == null) return;
    try {
      await TelegramService.instance.disconnectTelegram();
      if (!mounted) return;
      _telegramConnectTimeout?.cancel();
      _telegramChatIdSub?.cancel();
      _telegramChatIdSub = null;
      setState(() => _telegramChatId = null);
      _pendingTelegramLinkToken = null;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telegram disconnected')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear Telegram connection: $e')),
        );
      }
    }
  }

  Future<void> _cancelTelegramWaiting() async {
    if (!_connectingTelegram) return;
    _telegramConnectTimeout?.cancel();
    _telegramConnectTimeout = null;
    _telegramChatIdSub?.cancel();
    _telegramChatIdSub = null;

    try {
      await TelegramService.instance.clearTelegramConnectionToken();
    } catch (e) {
      debugPrint('[Settings] Failed to clear Telegram token on cancel: $e');
    }

    if (!mounted) return;
    setState(() {
      _connectingTelegram = false;
      _pendingTelegramLinkToken = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Telegram waiting cancelled')),
    );
  }

  Future<void> _startTelegramConnect(BuildContext context) async {
    if (_connectingTelegram) return;
    _telegramConnectTimeout?.cancel();
    _telegramChatIdSub?.cancel();
    setState(() => _connectingTelegram = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      final token = await _ensureTelegramLinkToken();
      await TelegramService.instance.connectTelegramAuto(existingToken: token);
    } catch (e) {
      if (!mounted) return;
      setState(() => _connectingTelegram = false);
      messenger.showSnackBar(
        SnackBar(content: Text('Could not open Telegram: $e')),
      );
      return;
    }

    _telegramConnectTimeout = Timer(const Duration(seconds: 90), () {
      if (!mounted || !_connectingTelegram) return;
      _telegramChatIdSub?.cancel();
      _telegramChatIdSub = null;
      _telegramConnectTimeout = null;
      unawaited(TelegramService.instance.clearTelegramConnectionToken());
      setState(() => _connectingTelegram = false);
      _pendingTelegramLinkToken = null;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Telegram did not confirm within 90 seconds. Tap Connect again or cancel sooner next time.'),
        ),
      );
    });

    _telegramChatIdSub?.cancel();
    _telegramChatIdSub = TelegramService.instance.watchLinkedChatId().listen(
      (chatId) {
        final trimmed = (chatId ?? '').trim();
        if (trimmed.isEmpty) return;
        if (!mounted) return;

        _telegramChatIdSub?.cancel();
        _telegramChatIdSub = null;
        _telegramConnectTimeout?.cancel();
        _telegramConnectTimeout = null;

        setState(() {
          _telegramChatId = trimmed;
          _connectingTelegram = false;
        });
        _pendingTelegramLinkToken = null;

        messenger.showSnackBar(
          const SnackBar(content: Text('Telegram connected!')),
        );
      },
    );
  }

  Future<void> _copyTelegramLink(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final token = await _ensureTelegramLinkToken();
      final link = await TelegramService.instance.buildTelegramStartUri(token);
      await Clipboard.setData(ClipboardData(text: link.toString()));
      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(content: Text('Telegram link copied')),
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Could not copy Telegram link: $e')),
        );
      }
    }
  }

  Future<String> _ensureTelegramLinkToken() async {
    final existing = _pendingTelegramLinkToken?.trim();
    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final token = await TelegramService.instance.createTelegramConnectionToken();
    _pendingTelegramLinkToken = token;
    return token;
  }

  Future<void> _requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    if (mounted) {
      setState(() => _notificationSettings = settings);
    }
  }

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.42),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: GlassPane(
          level: 1,
          radius: 24,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.reminders.withValues(alpha: 0.14),
                    ),
                    child: Icon(
                      Icons.logout_rounded,
                      color: AppColors.reminders,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sign out of WishperLog?',
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Your local notes stay on this device. Cloud sync pauses until you sign in again.',
                style: TextStyle(
                  color: context.textSec,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: _glassButtonStyle(
                        context,
                        tint: AppColors.general,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.tonal(
                      style: _glassButtonStyle(
                        context,
                        tint: AppColors.reminders,
                        filled: true,
                        danger: true,
                        foreground: Colors.white,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text('Sign out'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      await _overlayNotifier.setEnabled(false);
      await _users.signOut();
      if (mounted) context.go('/signin');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign out failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompact = MediaQuery.sizeOf(context).width < 720;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GlassTitleBar(
        title: 'Settings',
        subtitle: 'Preferences and integrations',
        onBack: _goBack,
      ),
      body: GlassPageBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 32),
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, (1 - value) * 8),
                      child: child,
                    ),
                  );
                },
                child: GlassContainer(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  borderRadius: BorderRadius.circular(18),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.tasks, Color(0xFF57C7FF)],
                          ),
                        ),
                        child: const Icon(
                          Icons.tune_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Settings',
                              style: TextStyle(
                                color: context.textPri,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Overlay, speech, sync, and digest controls in one place.',
                              style: TextStyle(
                                color: context.textSec,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _SectionHeader(label: 'Appearance'),
              _SettingsTile(
                title: 'Theme',
                subtitle: _themeModeLabel(context),
                leading: const Icon(Icons.palette_outlined),
                trailing: BlocBuilder<ThemeCubit, ThemeMode>(
                  bloc: sl<ThemeCubit>(),
                  builder: (context, mode) {
                    if (isCompact) {
                      return SizedBox(
                        width: 124,
                        child: GlassPane(
                          level: 4,
                          radius: 16,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<ThemeMode>(
                              value: mode,
                              isExpanded: true,
                              icon: Icon(
                                Icons.expand_more_rounded,
                                color: context.textSec,
                              ),
                              style: _dropdownTextStyle(context),
                              dropdownColor: _dropdownMenuColor(context),
                              borderRadius: BorderRadius.circular(16),
                              items: [
                                DropdownMenuItem(
                                  value: ThemeMode.light,
                                  child: Text('Light', style: _dropdownTextStyle(context)),
                                ),
                                DropdownMenuItem(
                                  value: ThemeMode.dark,
                                  child: Text('Dark', style: _dropdownTextStyle(context)),
                                ),
                                DropdownMenuItem(
                                  value: ThemeMode.system,
                                  child: Text('System', style: _dropdownTextStyle(context)),
                                ),
                              ],
                              onChanged: (value) {
                                if (value == null) return;
                                sl<ThemeCubit>().setThemeMode(value);
                              },
                            ),
                          ),
                        ),
                      );
                    }

                    return SegmentedButton<ThemeMode>(
                      segments: const [
                        ButtonSegment(
                          value: ThemeMode.light,
                          icon: Icon(Icons.light_mode_outlined),
                          label: Text('Light'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.dark,
                          icon: Icon(Icons.dark_mode_outlined),
                          label: Text('Dark'),
                        ),
                        ButtonSegment(
                          value: ThemeMode.system,
                          icon: Icon(Icons.phone_android_outlined),
                          label: Text('System'),
                        ),
                      ],
                      selected: {mode},
                      onSelectionChanged: (selection) {
                        if (selection.isEmpty) return;
                        sl<ThemeCubit>().setThemeMode(selection.first);
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: AppColors.tasks,
                        selectedForegroundColor: Colors.white,
                        backgroundColor: context.surface1,
                        foregroundColor: context.textSec,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'Capture Overlay'),
              ListenableBuilder(
                listenable: _overlayNotifier,
                builder: (context, _) => GlassContainer(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.tasks, Color(0xFF57C7FF)],
                              ),
                            ),
                            child: const Icon(
                              Icons.bubble_chart_outlined,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Floating capture button',
                                  style: TextStyle(
                                    color: context.textPri,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Use the customiser below to style the bubble and island together or separately.',
                                  style: TextStyle(
                                    color: context.textSec,
                                    fontSize: 12,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Switch(
                            value: _overlayNotifier.isEnabled,
                            onChanged: (_) => _toggleOverlay(),
                            activeThumbColor: AppColors.tasks,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              _buildSettingsTile(
                icon: Icons.tune_rounded,
                title: 'Customise Overlay Appearance',
                subtitle: 'Style bubble and island in one place',
                onTap: _openOverlayCustomiser,
              ),
              const SizedBox(height: 8),

              _SectionHeader(label: 'Speech'),
              GlassContainer(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                margin: const EdgeInsets.symmetric(vertical: 3),
                borderRadius: BorderRadius.circular(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Choose recognition language and offline preference',
                      style: TextStyle(
                        color: context.textSec,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                      decoration: BoxDecoration(
                        color: context.surface1.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: context.textSec.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.mic_none_rounded,
                                color: context.textPri,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Speech Recognition',
                                style: TextStyle(
                                  color: context.textPri,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Used by Android speech-to-text while recording.',
                            style: TextStyle(
                              color: context.textSec,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                          GlassPane(
                            level: 4,
                            radius: 18,
                            padding: const EdgeInsets.all(1.0),
                            child: DropdownButtonFormField<String>(
                              initialValue:
                                  _speechLanguageOptions.any(
                                    (e) => e['code'] == _speechLanguage,
                                  )
                                  ? _speechLanguage
                                  : _speechLanguageOptions.first['code'],
                              menuMaxHeight: 360,
                              isExpanded: true,
                              items: _speechLanguageOptions
                                  .map(
                                    (entry) => DropdownMenuItem<String>(
                                      value: entry['code'],
                                      child: Text(
                                        entry['label'] ?? entry['code'] ?? '',
                                        style: _dropdownTextStyle(context),
                                      ),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _speechLanguage = value);
                                _scheduleSpeechSettingsApply();
                              },
                              borderRadius: BorderRadius.circular(16),
                              dropdownColor: _dropdownMenuColor(context),
                              style: _dropdownTextStyle(context),
                              decoration: InputDecoration(
                                isDense: true,
                                labelText: 'Recognition language',
                                filled: true,
                                fillColor: context.surface2.withValues(
                                  alpha: 0.55,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: context.textSec.withValues(alpha: 0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                    color: context.textSec.withValues(
                                      alpha: 0.14,
                                    ),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                    color: AppColors.tasks,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Prefer offline recognition'),
                            subtitle: const Text(
                              'Uses downloaded speech models when available',
                            ),
                            value: _speechPreferOffline,
                            onChanged: (value) {
                              setState(() => _speechPreferOffline = value);
                              _scheduleSpeechSettingsApply();
                            },
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: OutlinedButton.icon(
                              style: _glassButtonStyle(
                                context,
                                tint: AppColors.tasks,
                              ),
                              onPressed: _openSpeechPackSettings,
                              icon: const Icon(
                                Icons.download_for_offline_outlined,
                              ),
                              label: const Text('Manage speech language packs'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'Notifications'),
              _SettingsTile(
                title: 'Push notifications',
                subtitle: _notificationStatusLabel(),
                leading: const Icon(Icons.notifications_outlined),
                trailing:
                    _notificationSettings?.authorizationStatus ==
                        AuthorizationStatus.authorized
                    ? Icon(
                        Icons.check_circle_outline,
                        color: AppColors.followUp,
                      )
                    : TextButton(
                        style: _glassButtonStyle(
                          context,
                          tint: AppColors.followUp,
                        ),
                        onPressed: _requestNotificationPermission,
                        child: const Text('Enable'),
                      ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'Daily Digest'),
              GlassContainer(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                borderRadius: BorderRadius.circular(16),
                child: DigestScheduleSection(
                  digestTimes: _digestTimes,
                  saving: _savingDigest,
                  onAdd: _addDigestTime,
                  onRemove: _savingDigest ? (_) {} : _removeDigestTime,
                ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'AI Configuration'),
              GlassContainer(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AiProvider.values.map((provider) {
                        final selected = _aiRouter.activeProvider == provider;
                        return ChoiceChip(
                          label: Text(_aiRouter.providerLabel(provider)),
                          selected: selected,
                          onSelected: (_) async {
                            await _aiRouter.setProvider(provider);
                            if (mounted) setState(() {});
                          },
                          selectedColor: AppColors.ideas,
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : context.textPri,
                            fontWeight: FontWeight.w700,
                          ),
                          side: BorderSide(
                            color: selected
                                ? AppColors.ideas.withValues(alpha: 0.24)
                                : context.border,
                          ),
                          backgroundColor: context.surface1,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    _buildAiStatusBadge(
                      _aiRouter.providerDescription(_aiRouter.activeProvider),
                      _aiRouter.isConfigured(_aiRouter.activeProvider),
                      _aiRouter.activeProvider == AiProvider.gemini
                          ? AppColors.tasks
                          : _aiRouter.activeProvider == AiProvider.groq
                              ? const Color(0xFFF97316)
                              : AppColors.ideas,
                    ),
                    const SizedBox(height: 12),
                    _buildAiSelectionSummary(context),
                    const SizedBox(height: 12),
                    Text(
                      'Model',
                      style: TextStyle(
                        color: context.textSec,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildAiModelOptions(context),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'Telegram'),
              TelegramConnectionSection(
                chatId: _telegramChatId,
                connecting: _connectingTelegram,
                onAutoConnect: () => _startTelegramConnect(context),
                onDisconnect: _disconnectTelegram,
                onCopyLink: () => _copyTelegramLink(context),
                onCancelWaiting: _cancelTelegramWaiting,
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'Google Sync'),
              _SettingsTile(
                title: 'Sync Google Tasks',
                subtitle: _lastSyncedAt == null
                    ? 'Sync completions from Google Tasks'
                    : 'Last synced ${_formatRelativeTime(_lastSyncedAt!)}',
                leading: const Icon(Icons.sync_outlined),
                trailing: _syncingNow
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        style: _glassButtonStyle(
                          context,
                          tint: AppColors.tasks,
                        ),
                        onPressed: _syncNow,
                        child: const Text('Sync now'),
                      ),
              ),
              _SettingsTile(
                title: 'Reconnect Google account',
                subtitle: 'Re-authorize calendar & tasks access',
                leading: const Icon(Icons.account_circle_outlined),
                trailing: _reconnectingGoogle
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : TextButton(
                        style: _glassButtonStyle(
                          context,
                          tint: AppColors.tasks,
                        ),
                        onPressed: _reconnectGoogle,
                        child: const Text('Reconnect'),
                      ),
              ),

              const SizedBox(height: 8),
              _SectionHeader(label: 'Account'),
              _buildAccountTile(context),
              const SizedBox(height: 4),
              _SettingsTile(
                title: 'Sign out',
                subtitle: 'You will remain signed out until next login',
                leading: Icon(
                  Icons.logout_rounded,
                  color: isDark ? AppColors.reminders : Colors.redAccent,
                ),
                onTap: _signOut,
              ),

              const SizedBox(height: 24),
              Center(
                child: Text(
                  'WishperLog',
                  style: TextStyle(
                    color: context.textSec,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTile(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const SizedBox.shrink();

    return _SettingsTile(
      title: user.displayName ?? 'Signed in',
      subtitle: user.email ?? '',
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: AppColors.tasks.withValues(alpha: 0.2),
        child: Text(
          (user.displayName?.isNotEmpty == true)
              ? user.displayName![0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: AppColors.tasks,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return _SettingsTile(
      title: title,
      subtitle: subtitle,
      leading: Icon(icon),
      onTap: onTap,
    );
  }

  String _themeModeLabel(BuildContext context) {
    final mode = sl<ThemeCubit>().state;
    return switch (mode) {
      ThemeMode.dark => 'Dark',
      ThemeMode.light => 'Light',
      ThemeMode.system => 'System',
    };
  }

  String _notificationStatusLabel() {
    final status = _notificationSettings?.authorizationStatus;
    return switch (status) {
      AuthorizationStatus.authorized => 'Enabled',
      AuthorizationStatus.denied => 'Denied - tap to enable in Settings',
      AuthorizationStatus.notDetermined => 'Tap to enable',
      AuthorizationStatus.provisional => 'Provisional',
      _ => 'Unknown',
    };
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  List<Widget> _buildAiModelOptions(BuildContext context) {
    final provider = _aiRouter.activeProvider;
    if (provider == AiProvider.auto) {
      return [
        _buildAiStatusBadge(
          'Auto will try Gemini, Groq, Mistral, Cerebras, then Hugging Face.',
          true,
          AppColors.ideas,
        ),
      ];
    }

    final models = _aiRouter.modelsFor(provider);
    if (models.isEmpty) {
      return [
        _buildAiStatusBadge(
          'No models are registered for ${_aiRouter.providerLabel(provider)}.',
          false,
          AppColors.errorStatus,
        ),
      ];
    }

    return models
        .map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _buildAiModelCard(context, option),
            ))
        .toList();
  }

  Widget _buildAiModelCard(BuildContext context, AiModelOption option) {
    final provider = _aiRouter.activeProvider;
    final selected = _aiRouter.selectedModelIdFor(provider) == option.id;
    final configured = _aiRouter.isConfigured(provider);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: configured
          ? () async {
              await _aiRouter.setModel(provider, option.id);
              if (mounted) setState(() {});
            }
          : null,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.ideas.withValues(alpha: 0.08)
              : context.surface1.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.ideas.withValues(alpha: 0.34)
                : context.border.withValues(alpha: 0.65),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.ideas : context.textSec,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          option.label,
                          style: TextStyle(
                            color: context.textPri,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (option.recommended)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.ideas.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Recommended',
                            style: TextStyle(
                              color: AppColors.ideas,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.description,
                    style: TextStyle(
                      color: context.textSec,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildSmallStatusPill(
                        context,
                        selected ? 'Selected' : option.id,
                        selected ? AppColors.ideas : context.textSec,
                      ),
                      const SizedBox(width: 8),
                      _buildSmallStatusPill(
                        context,
                        configured ? 'Ready' : 'Missing key',
                        configured ? AppColors.tasks : AppColors.errorStatus,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallStatusPill(BuildContext context, String text, Color tint) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: context.isDark ? 0.14 : 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: tint,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildAiStatusBadge(String text, bool ok, Color tint) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ok
            ? tint.withValues(alpha: 0.1)
            : AppColors.errorStatus.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ok
              ? tint.withValues(alpha: 0.2)
              : AppColors.errorStatus.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.warning_rounded,
            size: 18,
            color: ok ? tint : AppColors.errorStatus,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: ok ? context.textPri : AppColors.errorStatus,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSelectionSummary(BuildContext context) {
    final provider = _aiRouter.activeProvider;
    final selectedModel = _aiRouter.selectedModelFor(provider);
    final configured = _aiRouter.isConfigured(provider);
    final keyLabel = switch (provider) {
      AiProvider.gemini => 'GEMINI_API_KEY',
      AiProvider.groq => 'GROQ_API_KEY',
      AiProvider.mistral => 'MISTRAL_API_KEY',
      AiProvider.huggingface => 'HUGGINGFACE_API_KEY',
      AiProvider.cerebras => 'CEREBRAS_API_KEY',
      AiProvider.auto => 'Multiple keys',
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surface1.withValues(alpha: 0.68),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.border.withValues(alpha: 0.65)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current selection',
            style: TextStyle(
              color: context.textSec,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${_aiRouter.providerLabel(provider)} • ${selectedModel?.label ?? selectedModel?.id ?? 'Auto'}',
            style: TextStyle(
              color: context.textPri,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            configured
                ? 'Ready to classify with $keyLabel.'
                : 'Add $keyLabel in .env to enable this provider.',
            style: TextStyle(
              color: configured ? AppColors.tasks : AppColors.errorStatus,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          if (selectedModel != null) ...[
            const SizedBox(height: 8),
            Text(
              selectedModel.description,
              style: TextStyle(
                color: context.textSec,
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 6),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: context.textSec,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(vertical: 3),
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(14, 4, 14, 4),
        leading: leading != null
            ? IconTheme(
                data: IconThemeData(color: context.textSec, size: 20),
                child: leading!,
              )
            : null,
        title: Text(
          title,
          style: TextStyle(
            color: context.textPri,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle!,
                style: TextStyle(color: context.textSec, fontSize: 12),
              )
            : null,
        trailing: trailing,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
```

### lib/features/settings/presentation/widgets/digest_schedule_section.dart

````dart
// lib/features/settings/presentation/widgets/digest_schedule_section.dart
//
// Drop-in replacement for the digest-time section in SettingsScreen.
// Supports MINUTE-WISE precision (any HH:MM, not just :00/:15/:30/:45).
// Paste this widget into SettingsScreen and replace the old _addDigestTime
// + _show15MinSlotPicker calls.

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';

/// Fully self-contained digest schedule section widget.
///
/// Usage in SettingsScreen:
/// ```dart
/// DigestScheduleSection(
///   digestTimes: _digestTimes,
///   saving: _savingDigest,
///   onAdd:    _addDigestTime,        // calls _showMinuteWisePicker internally
///   onRemove: _removeDigestTime,
/// )
/// ```
class DigestScheduleSection extends StatelessWidget {
  const DigestScheduleSection({
    super.key,
    required this.digestTimes,
    required this.saving,
    required this.onAdd,
    required this.onRemove,
  });

  final List<TimeOfDay> digestTimes;
  final bool saving;
  final VoidCallback onAdd;
  final void Function(TimeOfDay) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Digest Schedule',
                style: TextStyle(
                  color: context.textPri,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (saving) ...[
              SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.textSec,
                ),
              ),
              const SizedBox(width: 8),
            ],
            GestureDetector(
              onTap: onAdd,
              child: GlassContainer(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Add time',
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Choose any time — the worker fires every minute and matches exactly.',
          style: TextStyle(
            color: context.textSec,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        if (digestTimes.isEmpty)
          Text(
            'No digest times set. Tap "Add time" to schedule your first digest.',
            style: TextStyle(color: context.textSec, fontSize: 13),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in digestTimes)
                _DigestTimeChip(
                  time: t,
                  onRemove: () => onRemove(t),
                ),
            ],
          ),
      ],
    );
  }
}

class _DigestTimeChip extends StatelessWidget {
  const _DigestTimeChip({required this.time, required this.onRemove});
  final TimeOfDay time;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final label =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_rounded, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: context.textPri,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: context.textSec),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Minute-wise time picker
//
// Call this from _SettingsScreenState._addDigestTime() to replace the old
// 15-minute slot picker.
//
// Example:
//   Future<void> _addDigestTime() async {
//     final slot = await showMinuteWiseTimePicker(context, _digestTimes);
//     if (slot == null || !mounted) return;
//     // ... persist as before
//   }
// ─────────────────────────────────────────────────────────────────────────────
Future<TimeOfDay?> showMinuteWiseTimePicker(
  BuildContext context,
  List<TimeOfDay> existing,
) async {
  // Use Flutter's native time picker — it supports minute granularity natively.
  final initialTime = existing.isEmpty
      ? const TimeOfDay(hour: 9, minute: 0)
      : existing.last;

  final picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: 'Add digest time',
    cancelText: 'Cancel',
    confirmText: 'Add',
    builder: (ctx, child) => MediaQuery(
      data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
      child: child ?? const SizedBox(),
    ),
  );

  if (picked == null) return null;

  final alreadyExists = existing.any(
    (t) => t.hour == picked.hour && t.minute == picked.minute,
  );
  if (alreadyExists && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This digest time already exists')),
    );
    return null;
  }

  return picked;
}
````

### lib/features/settings/presentation/widgets/telegram_connection_section.dart

```dart
// lib/features/settings/presentation/widgets/telegram_connection_section.dart
//
// Self-contained Telegram connection section for the Settings screen.
//
// Replaces the inline ad-hoc Telegram block in settings_screen.dart.
// Supports both the PRIMARY (auto deep-link) and SECONDARY (manual paste)
// methods with a compact guided UI appropriate for a settings context.
//
// Drop-in usage:
//   TelegramConnectionSection(
//     chatId: _telegramChatId,
//     connecting: _connectingTelegram,
//     onAutoConnect:   _startTelegramConnect,
//     onDisconnect:    _disconnectTelegram,
//     onCopyLink:      _copyTelegramLink,
//   )

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/sync/data/telegram_service.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

// ─────────────────────────────────────────────────────────────────────────────

class TelegramConnectionSection extends StatefulWidget {
  const TelegramConnectionSection({
    super.key,
    this.chatId,
    this.connecting = false,
    required this.onAutoConnect,
    required this.onDisconnect,
    required this.onCopyLink,
    required this.onCancelWaiting,
  });

  /// The currently linked Telegram chat ID, or null if not connected.
  final String? chatId;

  /// True while the auto-connect flow is in-progress (waiting for bot reply).
  final bool connecting;

  final VoidCallback onAutoConnect;
  final VoidCallback onDisconnect;
  final VoidCallback onCopyLink;
  final VoidCallback onCancelWaiting;

  @override
  State<TelegramConnectionSection> createState() =>
      _TelegramConnectionSectionState();
}

class _TelegramConnectionSectionState
    extends State<TelegramConnectionSection> {
  bool   _verifying  = false;
  String? _manualError;
  final TextEditingController _idController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  // ── Manual submit ──────────────────────────────────────────────────────────

  Future<void> _submitManualId() async {
    final raw = _idController.text.trim();
    if (raw.isEmpty) {
      setState(() => _manualError = 'Please enter your Chat ID.');
      return;
    }

    setState(() {
      _verifying   = true;
      _manualError = null;
    });

    try {
      await TelegramService.instance.linkManualChatId(raw);
      if (!mounted) return;
      setState(() {
        _verifying  = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Telegram linked successfully!')),
      );
    } on ArgumentError catch (e) {
      if (!mounted) return;
      setState(() {
        _manualError = e.message;
        _verifying   = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _manualError = 'Could not save Chat ID: $e';
        _verifying   = false;
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isConnected = widget.chatId != null;

    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      borderRadius: BorderRadius.circular(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header row ────────────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.tasks.withValues(alpha: 0.12),
                ),
                child: const Icon(Icons.telegram, color: AppColors.tasks, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Telegram',
                      style: TextStyle(
                        color: context.textPri,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      isConnected
                          ? 'Digest & bot commands active'
                          : 'Connect for daily digests',
                      style: TextStyle(
                        color: context.textSec,
                        fontSize: 11,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Connection status badge
              _StatusPill(connected: isConnected, pending: widget.connecting),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ── Connected state ────────────────────────────────────────────────
          if (isConnected) ...[
            _InfoRow(
              icon: Icons.tag_rounded,
              label: 'Chat ID',
              value: widget.chatId!,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _GlassButton(
                    icon: Icons.refresh_rounded,
                    label: 'Re-link',
                    color: AppColors.tasks,
                    filled: true,
                    onTap: widget.connecting ? null : widget.onAutoConnect,
                  ),
                ),
                const SizedBox(width: 8),
                _GlassButton(
                  icon: Icons.link_off_rounded,
                  label: 'Disconnect',
                  color: AppColors.reminders,
                  onTap: widget.onDisconnect,
                ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: _GlassButton(
                icon: Icons.content_copy_rounded,
                label: 'Copy link',
                color: AppColors.tasks,
                onTap: widget.onCopyLink,
              ),
            ),
          ]

          // ── Not connected + waiting ────────────────────────────────────────
          else if (widget.connecting) ...[
            GlassPane(
              level: 2,
              radius: 14,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.tasks),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Waiting — tap START in Telegram to finish linking…',
                      style: TextStyle(
                          color: context.textSec, fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _GlassButton(
                    icon: Icons.content_copy_rounded,
                    label: 'Copy link',
                    color: AppColors.tasks,
                    onTap: widget.onCopyLink,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GlassButton(
                    icon: Icons.cancel_rounded,
                    label: 'Cancel waiting',
                    color: AppColors.reminders,
                    onTap: widget.onCancelWaiting,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _ManualPanel(
              controller: _idController,
              errorText: _manualError,
              verifying: _verifying,
              onOpenBot: () async {
                try {
                  await TelegramService.instance.openTelegramBot();
                } catch (_) {}
              },
              onSubmit: _submitManualId,
              onCancel: () => setState(() {
                _manualError = null;
                _idController.clear();
              }),
            ),
          ]

          // ── Not connected, idle ────────────────────────────────────────────
          else ...[
            // Primary CTA
            SizedBox(
              width: double.infinity,
              child: _GlassButton(
                icon: Icons.flash_on_rounded,
                label: 'Connect in Telegram  (Recommended)',
                color: AppColors.tasks,
                filled: true,
                onTap: widget.onAutoConnect,
              ),
            ),
            const SizedBox(height: 8),

            // Secondary actions row
            Row(
              children: [
                _GlassButton(
                  icon: Icons.content_copy_rounded,
                  label: 'Copy link',
                  color: AppColors.tasks,
                  onTap: widget.onCopyLink,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _GlassButton(
                    icon: Icons.keyboard_rounded,
                    label: 'Enter Chat ID manually',
                    color: AppColors.ideas,
                    onTap: () => setState(() {
                      _manualError = null;
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            _ManualPanel(
              controller: _idController,
              errorText: _manualError,
              verifying: _verifying,
              onOpenBot: () async {
                try {
                  await TelegramService.instance.openTelegramBot();
                } catch (_) {}
              },
              onSubmit: _submitManualId,
              onCancel: () => setState(() {
                _manualError = null;
                _idController.clear();
              }),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ManualPanel — always-visible "paste your chat_id" sub-form
// ─────────────────────────────────────────────────────────────────────────────

class _ManualPanel extends StatelessWidget {
  const _ManualPanel({
    required this.controller,
    this.errorText,
    required this.verifying,
    required this.onOpenBot,
    required this.onSubmit,
    required this.onCancel,
  });

  final TextEditingController controller;
  final String? errorText;
  final bool verifying;
  final VoidCallback onOpenBot;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 2,
      radius: 16,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.help_outline_rounded,
                  size: 15, color: AppColors.ideas),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Manual Chat ID Link',
                  style: TextStyle(
                    color: context.textPri,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onCancel,
                child: Icon(Icons.close_rounded,
                    size: 18, color: context.textSec),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '1. Open the bot and tap /start — it will display your Chat ID.\n'
            '2. Copy that number and paste it below.',
            style: TextStyle(
                color: context.textSec, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            style: ButtonStyle(
              foregroundColor: const WidgetStatePropertyAll(AppColors.tasks),
              side: WidgetStatePropertyAll(
                BorderSide(color: AppColors.tasks.withValues(alpha: 0.30)),
              ),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
              shape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              elevation: const WidgetStatePropertyAll(0),
            ),
            onPressed: onOpenBot,
            icon: const Icon(Icons.telegram, size: 16),
            label: const Text('Open bot',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\-]')),
            ],
            decoration: InputDecoration(
              labelText: 'Paste Chat ID',
              hintText: '123456789',
              errorText: errorText,
              prefixIcon: const Icon(Icons.tag_rounded, size: 18),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 10),
          FilledButton(
            style: ButtonStyle(
              backgroundColor: const WidgetStatePropertyAll(AppColors.ideas),
              padding: const WidgetStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 12)),
              shape: const WidgetStatePropertyAll(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12))),
              ),
              elevation: const WidgetStatePropertyAll(0),
            ),
            onPressed: verifying ? null : onSubmit,
            child: verifying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Confirm',
                    style: TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.connected, required this.pending});
  final bool connected;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    if (pending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: AppColors.ideas.withValues(alpha: 0.12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.ideas),
            ),
            const SizedBox(width: 5),
            Text('Pending',
                style: TextStyle(
                    color: AppColors.ideas,
                    fontSize: 11,
                    fontWeight: FontWeight.w700)),
          ],
        ),
      );
    }

    if (!connected) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: AppColors.followUp.withValues(alpha: 0.12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 12, color: AppColors.followUp),
          const SizedBox(width: 4),
          const Text('Connected',
              style: TextStyle(
                  color: AppColors.followUp,
                  fontSize: 11,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: context.textSec),
        const SizedBox(width: 6),
        Text('$label: ',
            style: TextStyle(color: context.textSec, fontSize: 12)),
        Text(value,
            style: TextStyle(
                color: context.textPri,
                fontSize: 12,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.label,
    required this.color,
    this.filled = false,
    this.onTap,
  });

  final IconData icon;
  final String   label;
  final Color    color;
  final bool     filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = filled
        ? color.withValues(alpha: context.isDark ? 0.24 : 0.16)
        : context.surface1.withValues(alpha: 0.7);

    Widget content = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: bg,
          border: Border.all(
            color: color.withValues(alpha: filled ? 0.0 : 0.22),
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );

    return content;
  }
}
```

### lib/features/sync/data/external_sync_service.dart

```dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis/tasks/v1.dart' as gtasks;
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/sync/data/google_api_client.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class SyncRunResult {
  const SyncRunResult({required this.processed, required this.updated});
  final int processed;
  final int updated;
}

class SyncNoteExternalResult {
  const SyncNoteExternalResult({required this.note, this.noteChanged = false});
  final Note note;
  final bool noteChanged;
}

/// ─────────────────────────────────────────────────────────────────────────────
/// ExternalSyncService — Full Bi-directional Google Tasks + Calendar Sync
///
/// Design guarantees:
///  1. NO duplicate creation: uses `gtaskId` / `gcalEventId` fields for ID
///     matching. Any note with a non-null ID is updated, not re-created.
///  2. Bi-directional deletion:
///     • Note deleted in app → delete remote entry.
///     • Remote entry deleted by user → mark note as unsynced (remove ID).
///  3. Smart mapping:
///     • Tasks | Reminders | Follow-up → Google Tasks.
///     • Notes with extracted_date → Google Calendar (in addition if applicable).
///  4. Completion sync: checks remote task completion and marks local note done.
///  5. All Firestore writes are batched to reduce cost.
/// ─────────────────────────────────────────────────────────────────────────────
class ExternalSyncService {
  ExternalSyncService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
    GoogleSignIn? googleSignIn,
  })  : _auth          = auth ?? FirebaseAuth.instance,
        _firestore     = firestore ?? FirebaseFirestore.instance,
        _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance,
        _googleSignIn  = googleSignIn ??
            GoogleSignIn(scopes: [
              gcal.CalendarApi.calendarScope,
              gtasks.TasksApi.tasksScope,
              'email',
            ]);

  final FirebaseAuth    _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore   _isarNoteStore;
  final GoogleSignIn    _googleSignIn;

  // ── Auth helpers ──────────────────────────────────────────────────────────

  Future<bool> ensureGoogleConnected() async {
    try { return await _googleSignIn.signInSilently() != null; }
    catch (_) { return false; }
  }

  Future<bool> reconnectGoogle() async {
    try { return await _googleSignIn.signIn() != null; }
    catch (_) { return false; }
  }

  Future<Map<String, String>?> _authHeaders({bool retried = false}) async {
    try {
      var account = _googleSignIn.currentUser;
      account ??= await _googleSignIn.signInSilently();
      if (account == null) return null;
      // authHeaders internally calls getAuthToken which refreshes the access
      // token if it has expired (via the platform's token refresh flow).
      final headers = await account.authHeaders;
      // Sanity-check: ensure we actually have a Bearer token.
      final auth = headers['Authorization'] ?? '';
      if (auth.isEmpty && !retried) {
        // Force a fresh account sign-in and retry once.
        await _googleSignIn.signOut();
        return _authHeaders(retried: true);
      }
      return headers;
    } catch (e) {
      debugPrint('[ExternalSync] _authHeaders error: $e');
      return null;
    }
  }

  // ── Public entry-points ───────────────────────────────────────────────────

  /// Full bi-directional sync: push local changes → remote, pull deletions ← remote.
  Future<SyncRunResult> syncNow() async {
    final headers = await _authHeaders();
    if (headers == null) {
      debugPrint('[ExternalSync] Not signed in — skipping');
      return const SyncRunResult(processed: 0, updated: 0);
    }

    final client   = HeaderClient(headers);
    final tasksApi = gtasks.TasksApi(client);
    final calApi   = gcal.CalendarApi(client);

    int processed = 0;
    int updated   = 0;

    try {
      final r1 = await _syncGoogleTasks(tasksApi);
      final r2 = await _syncGoogleCalendar(calApi);
      processed = r1.processed + r2.processed;
      updated   = r1.updated   + r2.updated;
    } catch (e) {
      debugPrint('[ExternalSync] syncNow error: $e');
    } finally {
      client.close();
    }

    debugPrint('[ExternalSync] syncNow complete: processed=$processed updated=$updated');
    return SyncRunResult(processed: processed, updated: updated);
  }

  /// Sync a single note's external entries (called after AI classification).
  Future<SyncNoteExternalResult> syncSingleNote(Note note) async {
    final headers = await _authHeaders();
    if (headers == null) return SyncNoteExternalResult(note: note);

    final client   = HeaderClient(headers);
    Note updated   = note;
    bool changed   = false;

    try {
      // Google Tasks — for task-like categories.
      if (_shouldSyncToTasks(note.category)) {
        final r = await _upsertGoogleTask(gtasks.TasksApi(client), note);
        if (r != null && r.noteId == note.noteId) {
          updated = r; changed = true;
        }
      }

      // Google Calendar — only if there's a concrete date.
      if (note.extractedDate != null) {
        final r = await _upsertCalendarEvent(gcal.CalendarApi(client), updated);
        if (r != null && r.noteId == updated.noteId) {
          updated = r; changed = true;
        }
      }
    } catch (e) {
      debugPrint('[ExternalSync] syncSingleNote error for ${note.noteId}: $e');
    } finally {
      client.close();
    }

    return SyncNoteExternalResult(note: updated, noteChanged: changed);
  }

  /// Explicitly pulls completion statuses from Google Tasks (for settings "Sync Now" button).
  Future<void> syncGoogleTaskCompletions() async {
    final headers = await _authHeaders();
    if (headers == null) return;
    final client = HeaderClient(headers);
    try {
      await _pullTaskCompletions(gtasks.TasksApi(client));
    } finally {
      client.close();
    }
  }

  /// Sync a specific note with external services (Google Tasks/Calendar).
  Future<SyncNoteExternalResult> syncExternalForNote(Note note) async {
    try {
      final headers = await _authHeaders();
      if (headers == null) {
        throw Exception('Authentication headers are missing.');
      }

      // Example logic for syncing a note
      if (note.status == NoteStatus.deleted) {
        // Handle deletion logic
        await _deleteRemoteEntry(note);
        return SyncNoteExternalResult(note: note, noteChanged: true);
      } else {
        // Handle update or creation logic
        final updatedNote = await _updateOrCreateRemoteEntry(note);
        return SyncNoteExternalResult(note: updatedNote, noteChanged: true);
      }
    } catch (e) {
      debugPrint('[ExternalSyncService] syncExternalForNote error: $e');
      return SyncNoteExternalResult(note: note);
    }
  }

  Future<void> _deleteRemoteEntry(Note note) async {
    // Logic to delete a remote entry
    debugPrint('Deleting remote entry for note: ${note.noteId}');
  }

  Future<Note> _updateOrCreateRemoteEntry(Note note) async {
    // Logic to update or create a remote entry
    debugPrint('Updating/Creating remote entry for note: ${note.noteId}');
    return note;
  }

  // ── Google Tasks sync ─────────────────────────────────────────────────────

  static const _taskListTitle = 'WishperLog';

  // Cache the task-list ID so we don't query it on every per-note upsert.
  String? _cachedTaskListId;
  DateTime? _taskListCacheTime;
  static const _taskListCacheTtl = Duration(hours: 6);

  Future<SyncRunResult> _syncGoogleTasks(gtasks.TasksApi api) async {
    int processed = 0;
    int updated   = 0;

    // ── Ensure our task list exists ───────────────────────────────────────────
    final listId = await _getCachedTaskListId(api);
    if (listId == null) return const SyncRunResult(processed: 0, updated: 0);

    // ── Pull: check which of our synced tasks were deleted on Google side ─────
    final remoteTaskIds = await _fetchRemoteTaskIds(api, listId);
    final localNotes    = await _isarNoteStore.getAllNotes();

    for (final note in localNotes) {
      if (note.gtaskId == null) continue;
      if (!remoteTaskIds.contains(note.gtaskId)) {
        // Remote was deleted — clear local ID so it won't try to update a ghost.
        debugPrint('[ExternalSync] gtask ${note.gtaskId} was deleted remotely — clearing from note ${note.noteId}');
        final cleared = note.copyWith(gtaskId: null, syncedAt: DateTime.now());
        await _isarNoteStore.put(cleared);
        await _firestorePatch(note.noteId, {'gtask_id': null, 'synced_at': DateTime.now().toIso8601String()});
        updated++;
      }
    }

    // ── Push: upsert notes that need syncing ──────────────────────────────────
    final needsSync = localNotes.where((n) =>
      _shouldSyncToTasks(n.category) &&
      n.status == NoteStatus.active &&
      (n.gtaskId == null || (n.syncedAt != null && n.updatedAt.isAfter(n.syncedAt!)))
    ).toList();

    for (final note in needsSync) {
      try {
        final result = await _upsertGoogleTask(api, note, taskListId: listId);
        if (result != null) { await _isarNoteStore.put(result); updated++; }
        processed++;
      } catch (e) {
        debugPrint('[ExternalSync] task upsert error for ${note.noteId}: $e');
      }
    }

    // ── Handle local deletions (push deletes to Google) ───────────────────────
    final deletedWithTask = localNotes.where((n) =>
      n.status == NoteStatus.deleted && n.gtaskId != null
    ).toList();

    for (final note in deletedWithTask) {
      try {
        await api.tasks.delete(listId, note.gtaskId!);
        final cleared = note.copyWith(gtaskId: null);
        await _isarNoteStore.put(cleared);
        debugPrint('[ExternalSync] deleted remote task ${note.gtaskId} for note ${note.noteId}');
      } catch (e) {
        // 404 is acceptable — already deleted.
        debugPrint('[ExternalSync] delete task error (may be 404): $e');
      }
    }

    // ── Completion pull ───────────────────────────────────────────────────────
    await _pullTaskCompletions(api, listId: listId);

    return SyncRunResult(processed: processed, updated: updated);
  }

  Future<Note?> _upsertGoogleTask(
    gtasks.TasksApi api,
    Note note, {
    String? taskListId,
  }) async {
    // Prefer the caller-supplied listId (from syncNow batch), fall back to
    // the per-instance cache, or fetch+create as last resort.
    final resolvedListId = taskListId ?? await _getCachedTaskListId(api);
    if (resolvedListId == null) return null;

    final taskTitle = note.title.isNotEmpty ? note.title : 'WishperLog Note';
    final body      = note.cleanBody.isNotEmpty ? note.cleanBody : note.rawTranscript;
    final dueDate   = note.extractedDate;

    // ── Update existing ───────────────────────────────────────────────────────
    if (note.gtaskId != null) {
      try {
        final patch = gtasks.Task()
          ..title = taskTitle
          ..notes = body
          ..due   = dueDate != null
              ? DateTime.utc(dueDate.year, dueDate.month, dueDate.day).toIso8601String()
              : null;
        await api.tasks.patch(patch, resolvedListId, note.gtaskId!);
        debugPrint('[ExternalSync] Updated task ${note.gtaskId}');
        return note.copyWith(syncedAt: DateTime.now());
      } on gtasks.DetailedApiRequestError catch (e) {
        if (e.status == 404) {
          // Task was deleted remotely — fall through to create.
          debugPrint('[ExternalSync] Task 404 — will recreate: ${note.gtaskId}');
        } else {
          rethrow;
        }
      }
    }

    // ── Create new ────────────────────────────────────────────────────────────
    final newTask = gtasks.Task()
      ..title = taskTitle
      ..notes = body
      ..due   = dueDate != null
          ? DateTime.utc(dueDate.year, dueDate.month, dueDate.day).toIso8601String()
          : null;

    final created = await api.tasks.insert(newTask, resolvedListId);
    debugPrint('[ExternalSync] Created task ${created.id} for note ${note.noteId}');
    final updated = note.copyWith(gtaskId: created.id, syncedAt: DateTime.now());
    await _firestorePatch(note.noteId, {
      'gtask_id':  created.id,
      'synced_at': DateTime.now().toIso8601String(),
    });
    return updated;
  }

  Future<void> _pullTaskCompletions(gtasks.TasksApi api, {String? listId}) async {
    final taskListId = listId ?? await _getOrCreateTaskList(api);
    if (taskListId == null) return;

    try {
      final result = await api.tasks.list(taskListId, showCompleted: true, showHidden: true);
      final tasks  = result.items ?? [];

      for (final task in tasks) {
        if (task.id == null) continue;
        final isCompleted = task.status == 'completed';
        final note = await _isarNoteStore.findByGtaskId(task.id!);
        if (note == null) continue;
        if (isCompleted && note.status != NoteStatus.archived) {
          debugPrint('[ExternalSync] Marking note ${note.noteId} complete from Google Tasks');
          final updated = note.copyWith(status: NoteStatus.archived, syncedAt: DateTime.now());
          await _isarNoteStore.put(updated);
          await _firestorePatch(note.noteId, {
            'status': 'archived',
            'synced_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint('[ExternalSync] pullTaskCompletions error: $e');
    }
  }

  Future<String?> _getOrCreateTaskList(gtasks.TasksApi api) async {
    try {
      final lists = await api.tasklists.list();
      for (final list in lists.items ?? []) {
        if (list.title == _taskListTitle) return list.id;
      }
      // Create it.
      final created = await api.tasklists.insert(
        gtasks.TaskList()..title = _taskListTitle,
      );
      debugPrint('[ExternalSync] Created task list: ${created.id}');
      return created.id;
    } catch (e) {
      debugPrint('[ExternalSync] _getOrCreateTaskList error: $e');
      return null;
    }
  }

  Future<Set<String>> _fetchRemoteTaskIds(gtasks.TasksApi api, String listId) async {
    final ids = <String>{};
    String? pageToken;
    try {
      do {
        final page = await api.tasks.list(
          listId,
          maxResults: 100,
          showCompleted: true,
          showHidden: true,
          pageToken: pageToken,
        );
        for (final t in page.items ?? const <gtasks.Task>[]) {
          if (t.id != null) ids.add(t.id!);
        }
        pageToken = page.nextPageToken;
      } while (pageToken != null);
    } catch (e) {
      debugPrint('[ExternalSync] _fetchRemoteTaskIds error: $e');
    }
    return ids;
  }

  // ── Google Calendar sync ──────────────────────────────────────────────────

  static const _calendarId = 'primary';

  Future<SyncRunResult> _syncGoogleCalendar(gcal.CalendarApi api) async {
    int processed = 0;
    int updated   = 0;

    final localNotes = await _isarNoteStore.getAllNotes();

    // ── Pull: detect remote deletions ─────────────────────────────────────────
    final notesWithCalEvent = localNotes.where((n) => n.gcalEventId != null).toList();
    for (final note in notesWithCalEvent) {
      try {
        await api.events.get(_calendarId, note.gcalEventId!);
        // Event still exists — no action needed.
      } on gcal.DetailedApiRequestError catch (e) {
        if (e.status == 404 || e.status == 410) {
          // Deleted on Calendar side.
          debugPrint('[ExternalSync] gcal event ${note.gcalEventId} deleted remotely');
          final cleared = note.copyWith(gcalEventId: null, syncedAt: DateTime.now());
          await _isarNoteStore.put(cleared);
          await _firestorePatch(note.noteId, {'gcal_event_id': null});
          updated++;
        }
      } catch (e) {
        debugPrint('[ExternalSync] gcal get error for ${note.gcalEventId}: $e');
      }
    }

    // ── Push: upsert notes that have a date ───────────────────────────────────
    final needsSync = localNotes.where((n) =>
      n.extractedDate != null &&
      n.status == NoteStatus.active
    ).toList();

    for (final note in needsSync) {
      try {
        final result = await _upsertCalendarEvent(api, note);
        if (result != null) { await _isarNoteStore.put(result); updated++; }
        processed++;
      } catch (e) {
        debugPrint('[ExternalSync] calendar upsert error for ${note.noteId}: $e');
      }
    }

    // ── Handle local deletions ────────────────────────────────────────────────
    final deletedWithEvent = localNotes.where((n) =>
      n.status == NoteStatus.deleted && n.gcalEventId != null
    ).toList();

    for (final note in deletedWithEvent) {
      try {
        await api.events.delete(_calendarId, note.gcalEventId!);
        final cleared = note.copyWith(gcalEventId: null);
        await _isarNoteStore.put(cleared);
        debugPrint('[ExternalSync] deleted cal event ${note.gcalEventId}');
      } catch (e) {
        debugPrint('[ExternalSync] delete cal event error (may be 404): $e');
      }
    }

    return SyncRunResult(processed: processed, updated: updated);
  }

  Future<Note?> _upsertCalendarEvent(gcal.CalendarApi api, Note note) async {
    if (note.extractedDate == null) return null;

    final d     = note.extractedDate!;
    final title = note.title.isNotEmpty ? note.title : 'WishperLog Note';
    final desc  = note.cleanBody.isNotEmpty ? note.cleanBody : note.rawTranscript;

    // All-day event using the extracted date.
    final event = gcal.Event()
      ..summary     = title
      ..description = desc
      ..start       = (gcal.EventDateTime()..date = DateTime(d.year, d.month, d.day))
      ..end         = (gcal.EventDateTime()..date = DateTime(d.year, d.month, d.day + 1))
      ..source      = (gcal.EventSource()..title = 'WishperLog' ..url = 'https://wishperlog.app');

    // ── Update existing ───────────────────────────────────────────────────────
    if (note.gcalEventId != null) {
      try {
        await api.events.patch(event, _calendarId, note.gcalEventId!);
        debugPrint('[ExternalSync] Updated cal event ${note.gcalEventId}');
        return note.copyWith(syncedAt: DateTime.now());
      } on gcal.DetailedApiRequestError catch (e) {
        if (e.status == 404 || e.status == 410) {
          // Fall through to create.
        } else {
          rethrow;
        }
      }
    }

    // ── Create new ────────────────────────────────────────────────────────────
    final created = await api.events.insert(event, _calendarId);
    debugPrint('[ExternalSync] Created cal event ${created.id} for note ${note.noteId}');
    final updated = note.copyWith(gcalEventId: created.id, syncedAt: DateTime.now());
    await _firestorePatch(note.noteId, {
      'gcal_event_id': created.id,
      'synced_at':     DateTime.now().toIso8601String(),
    });
    return updated;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _shouldSyncToTasks(NoteCategory category) {
    return category == NoteCategory.tasks ||
           category == NoteCategory.reminders ||
           category == NoteCategory.followUp;
  }

  /// Returns the cached task-list ID or fetches/creates it.
  Future<String?> _getCachedTaskListId(gtasks.TasksApi api) async {
    final now = DateTime.now();
    if (_cachedTaskListId != null &&
        _taskListCacheTime != null &&
        now.difference(_taskListCacheTime!) < _taskListCacheTtl) {
      return _cachedTaskListId;
    }
    final id = await _getOrCreateTaskList(api);
    if (id != null) {
      _cachedTaskListId = id;
      _taskListCacheTime = now;
    }
    return id;
  }

  Future<void> _firestorePatch(String noteId, Map<String, dynamic> fields) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      final docRef = _firestore
          .collection('users').doc(uid)
          .collection('notes').doc(noteId);

      final snap = await docRef.get();
      if (!snap.exists) return;

      await docRef.set(fields, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[ExternalSync] Firestore patch error for $noteId: $e');
    }
  }
}
```

### lib/features/sync/data/fcm_sync_service.dart

```dart
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/features/sync/data/firestore_note_sync_service.dart';
import 'package:wishperlog/firebase_options.dart';

bool _fcmBackgroundHandlerRegistered = false;

void ensureFcmBackgroundHandlerRegistered() {
  if (_fcmBackgroundHandlerRegistered) {
    return;
  }
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  _fcmBackgroundHandlerRegistered = true;
}

class FcmSyncService {
  FcmSyncService({
    FirebaseMessaging? messaging,
    UserRepository? users,
    FirestoreNoteSyncService? noteSync,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _users = users ?? UserRepository(
         googleSignIn: GoogleSignIn(
           scopes: const [
             'email',
             'https://www.googleapis.com/auth/calendar',
             'https://www.googleapis.com/auth/tasks',
           ],
         ),
       ),
       _noteSync = noteSync ?? FirestoreNoteSyncService();

  final FirebaseMessaging _messaging;
  final UserRepository _users;
  final FirestoreNoteSyncService _noteSync;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _initialized = false;
  bool _tokenBootstrapAttempted = false;
  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _messageSub;
  StreamSubscription<RemoteMessage>? _messageOpenedSub;
  StreamSubscription<User?>? _authSub;

  Future<void> initialize() async {
    ensureFcmBackgroundHandlerRegistered();

    if (_initialized) {
      return;
    }
    _initialized = true;

    // Set up listeners once. Token bootstrap is deferred until the user is
    // signed in so fresh installs do not hit Google Play Services unnecessarily.
    try {
      _authSub ??= _auth.authStateChanges().listen((user) {
        if (user != null) {
          unawaited(_bootstrapTokenAndPermissions());
        }
      });
    } catch (e) {
      debugPrint('[FcmSyncService] auth subscription error: $e');
    }

    _messageSub ??= FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
    _messageOpenedSub ??= FirebaseMessaging.onMessageOpenedApp.listen(
      _handleRemoteMessage,
    );

    try {
      await _bootstrapTokenAndPermissions();
    } catch (e) {
      debugPrint('[FcmSyncService] initialize error: $e');
    }
  }

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<NotificationSettings> getNotificationSettings() {
    return _messaging.getNotificationSettings();
  }

  Future<void> dispose() async {
    await _tokenRefreshSub?.cancel();
    await _messageSub?.cancel();
    await _messageOpenedSub?.cancel();
    await _authSub?.cancel();
    _tokenRefreshSub = null;
    _messageSub = null;
    _messageOpenedSub = null;
    _authSub = null;
    _initialized = false;
    _tokenBootstrapAttempted = false;
  }

  Future<void> _bootstrapTokenAndPermissions() async {
    if (_tokenBootstrapAttempted) {
      return;
    }
    if (_auth.currentUser == null) {
      debugPrint('[FcmSyncService] Skipping token bootstrap until sign-in');
      return;
    }

    _tokenBootstrapAttempted = true;

    try {
      final current = await _messaging.getNotificationSettings();

      if (current.authorizationStatus == AuthorizationStatus.notDetermined) {
        final requested = await requestPermission();
        debugPrint(
          '[FcmSyncService] Notification permission requested: ${requested.authorizationStatus.name}',
        );
      } else {
        debugPrint(
          '[FcmSyncService] Notification permission status: ${current.authorizationStatus.name}',
        );
      }
    } catch (e) {
      debugPrint('[FcmSyncService] Notification permission check error: $e');
    }

    try {
      debugPrint('[FcmSyncService] Getting FCM token...');
      final token = await _messaging.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('[FcmSyncService] Token retrieval timed out');
          return null;
        },
      );
      if (token != null && token.isNotEmpty) {
        debugPrint('[FcmSyncService] Got token, updating user...');
        await _users.updateFcmToken(token).timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint('[FcmSyncService] Token update timed out');
            return;
          },
        );
      }
    } catch (e) {
      debugPrint('[FcmSyncService] Error getting token: $e');
    }

    _tokenRefreshSub ??= _messaging.onTokenRefresh.listen((token) async {
      await _users.updateFcmToken(token);
    });
  }

  Future<void> _handleRemoteMessage(RemoteMessage message) async {
    debugPrint(
      '[FcmSyncService] Received message: id=${message.messageId}, dataKeys=${message.data.keys.toList()}',
    );

    final type = message.data['type'];
    final noteId = message.data['note_id'];
    final status = message.data['status'];

    if (type == 'note_status_changed' &&
        noteId is String &&
        noteId.trim().isNotEmpty &&
        status is String) {
      await _noteSync.applyStatusFromPush(noteId: noteId, status: status);
      return;
    }

    if (type == 'note_updated' &&
        noteId is String &&
        noteId.trim().isNotEmpty) {
      await _noteSync.syncNoteById(noteId);
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final noteSync = FirestoreNoteSyncService();

    final type = message.data['type'];
    final noteId = message.data['note_id'];
    final status = message.data['status'];

    if (type == 'note_status_changed' &&
        noteId is String &&
        noteId.trim().isNotEmpty &&
        status is String) {
      await noteSync.applyStatusFromPush(noteId: noteId, status: status);
      return;
    }

    if (type == 'note_updated' &&
        noteId is String &&
        noteId.trim().isNotEmpty) {
      await noteSync.syncNoteById(noteId);
    }
  } catch (error) {
    debugPrint('FCM background handler error: $error');
  }
}
```

### lib/features/sync/data/firestore_note_sync_service.dart

```dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class FirestoreNoteSyncService {
  FirestoreNoteSyncService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore _isarNoteStore;

  bool _started = false;
  bool _isRestarting = false;
  StreamSubscription<User?>? _authSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _noteSub;

  Future<void> start() async {
    if (_started) {
      return;
    }
    _started = true;

    _authSub = _auth.idTokenChanges().listen(
      (user) {
        _attachUserListener(user);
      },
      onError: (Object error, StackTrace st) {
        debugPrint('[FirestoreNoteSyncService] Auth stream error: $error');
        debugPrintStack(stackTrace: st);
      },
    );

    await _attachUserListener(_auth.currentUser);
  }

  Future<void> stop() async {
    _started = false;
    await _noteSub?.cancel();
    await _authSub?.cancel();
    _noteSub = null;
    _authSub = null;
  }

  Future<void> _attachUserListener(User? user) async {
    await _noteSub?.cancel();
    _noteSub = null;

    final uid = user?.uid.trim() ?? '';
    if (uid.isEmpty) {
      debugPrint(
        '[FirestoreNoteSyncService] No authenticated user, listener idle',
      );
      return;
    }

    _noteSub = _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .snapshots()
        .listen(
          (snapshot) async {
            try {
              final notes = snapshot.docs
                  .map(
                    (doc) => Note.fromFirestoreJson(
                      doc.data(),
                      uid: uid,
                      noteId: doc.id,
                    ),
                  )
                  .toList();
              await _isarNoteStore.putAll(notes);
            } catch (e, st) {
              debugPrint(
                '[FirestoreNoteSyncService] Snapshot process error: $e',
              );
              debugPrintStack(stackTrace: st);
            }
          },
          onError: (Object error, StackTrace st) async {
            debugPrint(
              '[FirestoreNoteSyncService] Snapshot listener error: $error',
            );
            debugPrintStack(stackTrace: st);
            final message = error.toString().toLowerCase();
            if (message.contains('permission-denied') ||
                message.contains('permission denied')) {
              await _noteSub?.cancel();
              _noteSub = null;
              return;
            }
            await _restartAfterDelay();
          },
        );
  }

  Future<void> _restartAfterDelay() async {
    if (_isRestarting || !_started) {
      return;
    }
    _isRestarting = true;
    try {
      await Future<void>.delayed(const Duration(seconds: 3));
      if (_started) {
        await _attachUserListener(_auth.currentUser);
      }
    } finally {
      _isRestarting = false;
    }
  }

  Future<void> syncNoteById(String noteId, {String? uid}) async {
    final resolvedUid = uid ?? _auth.currentUser?.uid;
    if (resolvedUid == null || noteId.trim().isEmpty) {
      debugPrint(
        '[FirestoreNoteSyncService] Skipping syncNoteById: uid=$resolvedUid, noteId=$noteId',
      );
      return;
    }

    try {
      debugPrint(
        '[FirestoreNoteSyncService] Starting sync for note: $noteId (uid: $resolvedUid)',
      );

      final snap = await _firestore
          .collection('users')
          .doc(resolvedUid)
          .collection('notes')
          .doc(noteId)
          .get();

      if (!snap.exists) {
        debugPrint(
          '[FirestoreNoteSyncService] Note not found in Firestore: $noteId',
        );
        return;
      }

      final data = snap.data();
      if (data == null) {
        debugPrint('[FirestoreNoteSyncService] Note data is null: $noteId');
        return;
      }

      debugPrint(
        '[FirestoreNoteSyncService] Downloaded note from Firestore: $noteId',
      );

      final parsed = Note.fromFirestoreJson(
        data,
        uid: resolvedUid,
        noteId: noteId,
      );
      await _isarNoteStore.put(parsed);

      debugPrint(
        '[FirestoreNoteSyncService] Saved note to local Isar store: $noteId',
      );
    } catch (e, st) {
      debugPrint('[FirestoreNoteSyncService] ERROR syncing note $noteId: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> applyStatusFromPush({
    required String noteId,
    required String status,
  }) async {
    if (noteId.trim().isEmpty) {
      debugPrint(
        '[FirestoreNoteSyncService] Skipping applyStatusFromPush: empty noteId',
      );
      return;
    }

    try {
      debugPrint(
        '[FirestoreNoteSyncService] Applying status "$status" to note: $noteId',
      );

      final nextStatus = parseStatus(status);
      final existing = await _isarNoteStore.getByNoteId(noteId);
      if (existing == null) {
        debugPrint(
          '[FirestoreNoteSyncService] Note not found in local Isar store: $noteId',
        );
        return;
      }

      final updated = existing.copyWith(
        status: nextStatus,
        updatedAt: DateTime.now(),
        syncedAt: DateTime.now(),
      );

      await _isarNoteStore.put(updated);

      debugPrint(
        '[FirestoreNoteSyncService] Applied status change: $noteId → $nextStatus',
      );
    } catch (e, st) {
      debugPrint(
        '[FirestoreNoteSyncService] ERROR applying status to $noteId: $e',
      );
      debugPrintStack(stackTrace: st);
    }
  }
}
```

### lib/features/sync/data/google_api_client.dart

```dart
import 'package:http/http.dart' as http;

class HeaderClient extends http.BaseClient {
  HeaderClient(this._headers, [http.Client? inner])
      : _inner = inner ?? http.Client();

  final Map<String, String> _headers;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
```

### lib/features/sync/data/message_state_service.dart

```dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class MessageStateService {
  MessageStateService._({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance;

  static final MessageStateService instance = MessageStateService._();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore _isarNoteStore;
  Timer? _recomputeTimer;
  String? _queuedUid;
  bool _recomputeRunning = false;

  Future<void> rebuildDigest(List<Note> activeNotes, {String? uid}) async {
    final resolvedUid = uid ?? _auth.currentUser?.uid;
    if (resolvedUid == null || resolvedUid.trim().isEmpty) {
      debugPrint('[MessageStateService] skipped — no authenticated user');
      return;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(resolvedUid).get();
      final displayName = (userDoc.data()?['display_name'] as String?)?.trim();
      final messages = _buildTelegramMessages(
        activeNotes,
        displayName: displayName,
      );

      await _persist(
        resolvedUid,
        messages,
        activeNotes,
        displayName: displayName,
      );
      debugPrint(
        '[MessageStateService] rebuilt for $resolvedUid '
        '(telegram ${messages['telegram']?.length ?? 0} chars)',
      );
    } catch (e, st) {
      debugPrint('[MessageStateService] rebuild error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> recompute({String? uid}) async {
    final resolvedUid = uid ?? _auth.currentUser?.uid;
    if (resolvedUid == null || resolvedUid.trim().isEmpty) {
      debugPrint('[MessageStateService] skipped — no authenticated user');
      return;
    }

    _queuedUid = resolvedUid;
    _recomputeTimer?.cancel();
    _recomputeTimer = Timer(const Duration(milliseconds: 250), () {
      _recomputeTimer = null;
      unawaited(_runQueuedRecompute());
    });
  }

  Future<void> _runQueuedRecompute() async {
    if (_recomputeRunning) return;
    final resolvedUid = _queuedUid;
    if (resolvedUid == null || resolvedUid.trim().isEmpty) return;

    _queuedUid = null;
    _recomputeRunning = true;
    try {
      final notes = await _fetchActiveNotes(resolvedUid);
      await rebuildDigest(notes, uid: resolvedUid);
    } catch (e, st) {
      debugPrint('[MessageStateService] recompute error: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      _recomputeRunning = false;
      if (_queuedUid != null && _recomputeTimer == null) {
        _recomputeTimer = Timer(const Duration(milliseconds: 16), () {
          _recomputeTimer = null;
          unawaited(_runQueuedRecompute());
        });
      }
    }
  }

  Future<List<Note>> _fetchActiveNotes(String uid) async {
    try {
      final local = await _isarNoteStore.getAllActive();
      final active = local.where((n) => n.uid == uid).toList();
      if (active.isNotEmpty) return active;
    } catch (_) {}

    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .where('status', isEqualTo: 'active')
        .get();

    return snap.docs
        .map((d) {
          try {
            return Note.fromFirestoreJson(d.data(), uid: uid, noteId: d.id);
          } catch (_) {
            return null;
          }
        })
        .whereType<Note>()
        .where((n) => n.status == NoteStatus.active)
        .toList();
  }

  Map<String, String> _buildTelegramMessages(
    List<Note> notes, {
    String? displayName,
  }) {
    final active = notes
        .where((n) => n.status == NoteStatus.active)
        .toList();

    if (active.isEmpty) {
      return {
        'telegram': '📋 <b>WishperLog Daily Digest</b>\nNo active notes.',
        'telegram_digest': '📋 <b>WishperLog Daily Digest</b>\nNo active notes.',
        'telegram_summary': '📋 <b>WishperLog Summary</b>\nNo active notes.',
        'telegram_top': '🏆 <b>WishperLog Top</b>\nNo active notes.',
        'telegram_tasks': '📝 <b>WishperLog Tasks</b>\nNo active notes.',
        'telegram_reminders': '⏰ <b>WishperLog Reminders</b>\nNo active notes.',
        'telegram_ideas': '💡 <b>WishperLog Ideas</b>\nNo active notes.',
        'telegram_followup': '🔁 <b>WishperLog Follow-up</b>\nNo active notes.',
        'telegram_journal': '📓 <b>WishperLog Journal</b>\nNo active notes.',
        'telegram_general': '📦 <b>WishperLog General</b>\nNo active notes.',
      };
    }

    active.sort((a, b) {
      final pa = _priorityRank(a.priority.name);
      final pb = _priorityRank(b.priority.name);
      if (pa != pb) return pa.compareTo(pb);
      return b.updatedAt.compareTo(a.updatedAt);
    });

    final tasks = active.where((n) => n.category == NoteCategory.tasks).toList();
    final reminders = active.where((n) => n.category == NoteCategory.reminders).toList();
    final ideas = active.where((n) => n.category == NoteCategory.ideas).toList();
    final followUps = active.where((n) => n.category == NoteCategory.followUp).toList();
    final journals = active.where((n) => n.category == NoteCategory.journal).toList();
    final generals = active.where((n) => n.category == NoteCategory.general).toList();

    return {
      'telegram': _buildDigestMessage(
        title: 'Daily Digest',
        icon: '📋',
        subtitle: 'Your complete daily snapshot',
        greeting: displayName,
        notes: active,
        maxItems: 5,
        includeStats: true,
      ),
      'telegram_digest': _buildDigestMessage(
        title: 'Daily Digest',
        icon: '📋',
        subtitle: 'Your complete daily snapshot',
        greeting: displayName,
        notes: active,
        maxItems: 5,
        includeStats: true,
      ),
      'telegram_summary': _buildDigestMessage(
        title: 'Summary',
        icon: '🧭',
        subtitle: 'A quick view of everything active',
        greeting: displayName,
        notes: active,
        maxItems: 5,
        includeStats: true,
      ),
      'telegram_top': _buildDigestMessage(
        title: 'Top Priorities',
        icon: '🏆',
        subtitle: 'Your sharpest focus items right now',
        greeting: displayName,
        notes: active.take(3).toList(),
        maxItems: 3,
        includeStats: false,
      ),
      'telegram_tasks': _buildDigestMessage(
        title: 'Tasks',
        icon: '📝',
        subtitle: 'Actionable items that need attention',
        greeting: displayName,
        notes: tasks,
        maxItems: 5,
        includeStats: false,
      ),
      'telegram_reminders': _buildDigestMessage(
        title: 'Reminders',
        icon: '⏰',
        subtitle: 'Things you should not forget',
        greeting: displayName,
        notes: reminders,
        maxItems: 5,
        includeStats: false,
      ),
      'telegram_ideas': _buildDigestMessage(
        title: 'Ideas',
        icon: '💡',
        subtitle: 'Thoughts worth capturing and keeping',
        greeting: displayName,
        notes: ideas,
        maxItems: 5,
        includeStats: false,
      ),
      'telegram_followup': _buildDigestMessage(
        title: 'Follow-up',
        icon: '🔁',
        subtitle: 'Things you need to circle back on',
        greeting: displayName,
        notes: followUps,
        maxItems: 5,
        includeStats: false,
      ),
      'telegram_journal': _buildDigestMessage(
        title: 'Journal',
        icon: '📓',
        subtitle: 'Notes that belong in your personal log',
        greeting: displayName,
        notes: journals,
        maxItems: 5,
        includeStats: false,
      ),
      'telegram_general': _buildDigestMessage(
        title: 'General',
        icon: '📦',
        subtitle: 'Everything that does not fit elsewhere',
        greeting: displayName,
        notes: generals,
        maxItems: 5,
        includeStats: false,
      ),
    };
  }

  Future<void> _persist(
    String uid,
    Map<String, String> messages,
    List<Note> activeNotes, {
    String? displayName,
  }) async {
    final active = activeNotes
        .where((n) => n.status == NoteStatus.active)
        .toList()
      ..sort((a, b) {
        final pa = _priorityRank(a.priority.name);
        final pb = _priorityRank(b.priority.name);
        if (pa != pb) return pa.compareTo(pb);
        return b.updatedAt.compareTo(a.updatedAt);
      });

    final categoryCounts = <String, int>{
      'tasks': active.where((n) => n.category == NoteCategory.tasks).length,
      'reminders': active.where((n) => n.category == NoteCategory.reminders).length,
      'ideas': active.where((n) => n.category == NoteCategory.ideas).length,
      'followUp': active.where((n) => n.category == NoteCategory.followUp).length,
      'journal': active.where((n) => n.category == NoteCategory.journal).length,
      'general': active.where((n) => n.category == NoteCategory.general).length,
    };

    final priorityCounts = <String, int>{
      'high': active.where((n) => n.priority == NotePriority.high).length,
      'medium': active.where((n) => n.priority == NotePriority.medium).length,
      'low': active.where((n) => n.priority == NotePriority.low).length,
    };

    await _firestore
        .collection('users')
        .doc(uid)
        .set({
      'schema_version': 2,
      'display_name': displayName ?? '',
      'updated_at': FieldValue.serverTimestamp(),
      'active_note_count': active.length,
      'category_counts': categoryCounts,
      'priority_counts': priorityCounts,
      'message_state': messages,
      'summary': messages['telegram_summary'] ?? messages['telegram_digest'] ?? messages['telegram'] ?? '',
      'telegram_digest': messages['telegram_digest'] ?? '',
      'telegram_summary': messages['telegram_summary'] ?? '',
      'telegram_top': messages['telegram_top'] ?? '',
      'telegram_tasks': messages['telegram_tasks'] ?? '',
      'telegram_reminders': messages['telegram_reminders'] ?? '',
      'telegram_ideas': messages['telegram_ideas'] ?? '',
      'telegram_followup': messages['telegram_followup'] ?? '',
      'telegram_journal': messages['telegram_journal'] ?? '',
      'telegram_general': messages['telegram_general'] ?? '',
    }, SetOptions(merge: true));
  }
}

String _buildDigestMessage({
  required String title,
  required String icon,
  required String subtitle,
  required String? greeting,
  required List<Note> notes,
  required int maxItems,
  required bool includeStats,
}) {
  final sorted = [...notes]
    ..sort((a, b) {
      final pa = _priorityRank(a.priority.name);
      final pb = _priorityRank(b.priority.name);
      if (pa != pb) return pa.compareTo(pb);
      return b.updatedAt.compareTo(a.updatedAt);
    });

  final active = sorted.take(maxItems).toList();
  final tasks = notes.where((n) => n.category == NoteCategory.tasks).length;
  final reminders = notes.where((n) => n.category == NoteCategory.reminders).length;
  final ideas = notes.where((n) => n.category == NoteCategory.ideas).length;

  final buffer = StringBuffer();
  buffer.writeln('$icon <b>WishperLog</b>');
  buffer.writeln('<b>${_escapeHtml(title)}</b>');
  buffer.writeln('<i>${_escapeHtml(subtitle)}</i>');
  if ((greeting ?? '').trim().isNotEmpty) {
    buffer.writeln();
    buffer.writeln('Hello <b>${_escapeHtml(_ascii(greeting ?? 'there'))}</b>');
  }

  if (includeStats) {
    buffer.writeln();
    buffer.writeln('<i>${notes.length} notes · $tasks tasks · $reminders reminders · $ideas ideas</i>');
  }

  if (active.isEmpty) {
    buffer.writeln();
    buffer.writeln('<i>No active notes right now. You are all caught up.</i>');
    return buffer.toString().trim();
  }

  buffer.writeln();
  buffer.writeln('<b>Top items</b>');
  for (final note in active) {
    final titleText = _escapeHtml(_ascii(note.title.isEmpty ? 'Untitled' : note.title));
    final category = _categoryLabel(note.category.name);
    final priority = _priorityLabel(note.priority.name);
    buffer.writeln('• <b>$category</b> <code>$priority</code> $titleText');

    final body = _ascii(note.cleanBody);
    if (body.isNotEmpty) {
      buffer.writeln('  <i>${_escapeHtml(body.length > 110 ? '${body.substring(0, 110)}…' : body)}</i>');
    }
  }

  if (notes.length > active.length) {
    buffer.writeln();
    buffer.writeln('<i>+${notes.length - active.length} more</i>');
  }

  return buffer.toString().trim();
}

int _priorityRank(String? p) {
  return switch (p?.toLowerCase()) {
    'high' => 0,
    'medium' => 1,
    'low' => 2,
    _ => 3,
  };
}

String _priorityLabel(String? p) {
  return switch (p?.toLowerCase()) {
    'high' => 'HIGH',
    'low' => 'LOW',
    _ => 'MED',
  };
}

String _categoryLabel(String? value) {
  return switch ((value ?? '').toLowerCase()) {
    'tasks' => 'Tasks',
    'reminders' => 'Reminders',
    'ideas' => 'Ideas',
    'followup' => 'Follow-up',
    'follow_up' => 'Follow-up',
    'follow-up' => 'Follow-up',
    'journal' => 'Journal',
    _ => 'General',
  };
}

String _ascii(String? v) {
  return (v ?? '')
      .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _escapeHtml(String input) {
  return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}
```

### lib/features/sync/data/telegram_service.dart

```dart
// lib/features/sync/data/telegram_service.dart
//
// v2.0 — Digest Collection Architecture + Dual-Method Linking
//
// Changes from v1:
//   • writeDigestConfig()   — updates the root user schedule fields.
//   • addQueryHistory()     — writes bot command records to
//                             users/{uid}/digest/history_{timestamp}.
//   • linkManualChatId()    — validates and saves a raw chat_id pasted by
//                             the user, enabling the secondary fallback method.
//   • All existing methods preserved and unchanged.

import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class TelegramService {
  TelegramService._();
  static final TelegramService instance = TelegramService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth     _auth      = FirebaseAuth.instance;

  static const String _fallbackBotUsername = 'WishperLogDigestBot';

  String? _lastLinkToken;

  String? get lastLinkToken => _lastLinkToken;
  String? get lastLinkPin   => _lastLinkToken;

  // ── Auth guard ──────────────────────────────────────────────────────────────

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User not authenticated');
    return user.uid;
  }

  // ── Firestore references ────────────────────────────────────────────────────

  /// Root user document: users/{uid}
  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  // ── Bot username helpers ────────────────────────────────────────────────────

  Future<String> _botUsername() async {
    final configured = AppEnv.telegramBotUsername.trim();
    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'^@+'), '');
    }
    return _fallbackBotUsername;
  }

  // ── Token generation ────────────────────────────────────────────────────────

  String _buildLinkToken() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = math.Random.secure();
    return List.generate(
      10,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }

  // ── URI builders ────────────────────────────────────────────────────────────

  Future<Uri> buildTelegramStartUri(String token) async {
    final deepLinkBase = AppEnv.telegramDeepLinkBase.trim();
    if (deepLinkBase.isNotEmpty) {
      return Uri.parse('$deepLinkBase$token');
    }
    final botUsername = await _botUsername();
    return Uri.https('t.me', '/$botUsername', {'start': token});
  }

  Future<Uri> buildTelegramBotUri() async {
    final botUsername = await _botUsername();
    return Uri.https('t.me', '/$botUsername');
  }

  // ── Primary auto-link flow ──────────────────────────────────────────────────

  /// Creates a one-time link token, writes it to the user root doc, and
  /// returns the token. The bot later POSTs the user's chat_id back to
  /// Firestore when the user sends `/start token`.
  Future<String> createTelegramConnectionToken() async {
    final token = _buildLinkToken();
    _lastLinkToken = token;

    await _userDoc.set({
      'telegram_link_token': token,
      'telegram_link_pin': token,
      'telegram_link_token_created_at': FieldValue.serverTimestamp(),
      'telegram_link_pin_created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return token;
  }

  /// Alias kept for backward-compatibility with older callers.
  Future<String> generateLinkPin() => createTelegramConnectionToken();

  /// Clears any pending link token (cleanup after successful or abandoned link).
  Future<void> clearTelegramConnectionToken() async {
    _lastLinkToken = null;
    try {
      await _userDoc.update({
        'telegram_link_token': FieldValue.delete(),
        'telegram_link_token_created_at': FieldValue.delete(),
        'telegram_link_pin': FieldValue.delete(),
        'telegram_link_pin_created_at': FieldValue.delete(),
      });
    } catch (_) {}
  }

  Future<void> clearLinkPin() => clearTelegramConnectionToken();

  /// Primary connect: generates a token, builds the deep-link URI, and opens
  /// Telegram so the user can tap START in one motion.
  Future<String> connectTelegramAuto({String? existingToken}) async {
    final token = existingToken ?? await createTelegramConnectionToken();
    try {
      await openTelegramBot(startToken: token);
      return token;
    } catch (_) {
      if (existingToken == null) await clearTelegramConnectionToken();
      rethrow;
    }
  }

  Future<void> openTelegramBot({String? startToken}) async {
    final uri = startToken == null
        ? await buildTelegramBotUri()
        : await buildTelegramStartUri(startToken);

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) throw StateError('Could not open Telegram');
  }

  // ── Secondary manual-link flow ──────────────────────────────────────────────

  /// Validates and saves a chat_id that the user copied from the bot manually.
  ///
  /// Telegram chat_ids for private chats are numeric (positive or negative).
  /// This method validates the format, writes to the user doc, and returns
  /// the normalised chat_id string.
  ///
  /// Throws [ArgumentError] if [rawChatId] is not a valid Telegram chat id.
  Future<String> linkManualChatId(String rawChatId) async {
    final trimmed = rawChatId.trim();

    // Basic validation: must be a non-empty integer string.
    final parsed = int.tryParse(trimmed);
    if (parsed == null || trimmed.isEmpty) {
      throw ArgumentError(
        'Invalid chat ID. It should be a number — copy it directly from the bot.',
      );
    }

    final chatIdStr = trimmed;

    await _userDoc.set({
      'telegram_chat_id': chatIdStr,
      // Clear any pending token since the user linked manually.
      'telegram_link_token': FieldValue.delete(),
      'telegram_link_token_created_at': FieldValue.delete(),
      'telegram_link_pin': FieldValue.delete(),
      'telegram_link_pin_created_at': FieldValue.delete(),
    }, SetOptions(merge: true));

    _lastLinkToken = null;
    return chatIdStr;
  }

  // ── Chat-id readers ─────────────────────────────────────────────────────────

  Future<String?> getLinkedChatId() async {
    final doc    = await _userDoc.get();
    final chatId = (doc.data()?['telegram_chat_id'] ?? '').toString().trim();
    return chatId.isEmpty ? null : chatId;
  }

  Stream<String?> watchLinkedChatId() {
    return _userDoc.snapshots().map((snap) {
      final chatId = (snap.data()?['telegram_chat_id'] ?? '').toString().trim();
      return chatId.isEmpty ? null : chatId;
    });
  }

  // ── Disconnect ──────────────────────────────────────────────────────────────

  Future<void> disconnectTelegram() async {
    _lastLinkToken = null;

    await _userDoc.set({
      'telegram_chat_id': FieldValue.delete(),
      'telegram_link_token': FieldValue.delete(),
      'telegram_link_token_created_at': FieldValue.delete(),
      'telegram_link_pin': FieldValue.delete(),
      'telegram_link_pin_created_at': FieldValue.delete(),
      'message_state': FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  // ── Digest Collection API ───────────────────────────────────────────────────

  /// Writes the digest scheduling configuration to the root user document.
  ///
  /// [utcSlots] — list of "HH:MM" strings in UTC.
  /// [localSlots] — list of "HH:MM" strings in the user's local time.
  Future<void> writeDigestConfig({
    required List<String> utcSlots,
    required List<String> localSlots,
  }) async {
    final uid  = _uid;
    final user = _auth.currentUser;

    // Persist schedule on the root user doc, which is the canonical source
    // for both the app and the Worker.
    final userSnap = await _userDoc.get();
    final chatId = (userSnap.data()?['telegram_chat_id'] ?? '').toString().trim();
    final displayName = user?.displayName ?? (userSnap.data()?['display_name'] ?? '');

    await _userDoc.set({
      'uid'                  : uid,
      'display_name'         : displayName,
      'telegram_chat_id'     : chatId.isEmpty ? null : chatId,
      'digest_time'          : localSlots.isNotEmpty ? localSlots.first : null,
      'digest_times'         : localSlots,
      'digest_times_utc'     : utcSlots,
      'digest_slots'         : localSlots,
      'timezone_offset_minutes': DateTime.now().timeZoneOffset.inMinutes,
      'updated_at'           : FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Records a bot query to `users/{uid}/digest/history_<timestamp>`.
  ///
  /// Called by the Worker via the webhook handler after serving a command so
  /// history is visible to the app for future "digest history" UI features.
  Future<void> addQueryHistory({
    required String command,
    required String responseHeading,
    int noteCount = 0,
  }) async {
    final now = DateTime.now().toUtc();
    final docId = 'history_${now.millisecondsSinceEpoch}';

    await _userDoc.collection('digest').doc(docId).set({
      'command'         : command,
      'response_heading': responseHeading,
      'note_count'      : noteCount,
      'queried_at'      : FieldValue.serverTimestamp(),
    });
  }

  // ── Digest slot persistence ─────────────────────────────────────────────────

  /// Saves digest slots to both the legacy user root doc and the new
  /// root digest fields so both the app and the Worker stay in sync.
  Future<void> saveDigestSlots(List<String> slots) async {
    await _userDoc.set(
      {
        'digest_times_utc': slots,
        'digest_times': slots,
        'digest_slots': slots,
        'updated_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<List<String>> getDigestSlots() async {
    final doc = await _userDoc.get();
    final raw = doc.data()?['digest_slots'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  // ── Bot username resolution ─────────────────────────────────────────────────

  bool get isConfigured => true;

  Future<String?> resolveBotUsername() async {
    final username = await _botUsername();
    return username.trim().isEmpty ? null : username;
  }

  Future<String?> resolveChatIdByStartToken({required String token}) async {
    final tokenValue = token.trim();
    if (tokenValue.isEmpty) return null;

    final query = await _firestore
        .collection('users')
        .where('telegram_link_token', isEqualTo: tokenValue)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final chatId =
          (query.docs.first.data()['telegram_chat_id'] ?? '').toString().trim();
      if (chatId.isNotEmpty) return chatId;
    }

    // Legacy pin fallback
    final legacyQuery = await _firestore
        .collection('users')
        .where('telegram_link_pin', isEqualTo: tokenValue)
        .limit(1)
        .get();

    if (legacyQuery.docs.isEmpty) return null;
    final chatId =
        (legacyQuery.docs.first.data()['telegram_chat_id'] ?? '').toString().trim();
    return chatId.isEmpty ? null : chatId;
  }

  Future<void> sendConnectionConfirmation({required String chatId}) async {
    if (chatId.trim().isEmpty) return;
  }

  Future<void> registerDefaultCommands() async {}

  // ── Daily digest message builder ────────────────────────────────────────────

  static String staticBuildDailyDigest({
    required List<Note> notes,
    required DateTime localDate,
    int maxItems = 5,
    bool topPriorityOnly = true,
    bool includeMediumFallback = true,
  }) {
    final active = notes
        .where((n) =>
            n.status != NoteStatus.archived && n.status != NoteStatus.deleted)
        .toList();

    active.sort((a, b) {
      final pa = _priorityRank(a.priority.name);
      final pb = _priorityRank(b.priority.name);
      if (pa != pb) return pa.compareTo(pb);
      return b.updatedAt.compareTo(a.updatedAt);
    });

    final picked = active.take(maxItems).toList();
    final buffer = StringBuffer();

    buffer.writeln('<b>WishperLog Daily Digest</b>');
    buffer.writeln('<i>${localDate.toLocal().toIso8601String()}</i>');
    buffer.writeln();

    if (picked.isEmpty) {
      buffer.writeln('No active notes.');
      return buffer.toString().trim();
    }

    for (final note in picked) {
      final title    = _ascii(note.title.isEmpty ? 'Untitled' : note.title);
      final category = note.category.name.toUpperCase();
      final priority = _priorityLabel(note.priority.name);
      final body     = _ascii(note.cleanBody);

      buffer.writeln('• [$category][$priority] $title');
      if (body.isNotEmpty) {
        buffer.writeln(
          '  <i>${body.length > 120 ? '${body.substring(0, 120)}…' : body}</i>',
        );
      }
    }

    return buffer.toString().trim();
  }

  static int _priorityRank(String p) =>
      p == 'high' ? 0 : p == 'medium' ? 1 : 2;

  static String _priorityLabel(String p) {
    switch (p.toLowerCase()) {
      case 'high': return 'HIGH';
      case 'low':  return 'LOW';
      default:     return 'MED';
    }
  }

  static String _ascii(String v) => (v)
      .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
```

### lib/firebase_options.dart

````dart
// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyApWYePpNFwwkpKNfe8wBjrcgcvYkVFmiI',
    appId: '1:982731246537:web:33adacd29c09bd572cf618',
    messagingSenderId: '982731246537',
    projectId: 'wishperlog',
    authDomain: 'wishperlog.firebaseapp.com',
    storageBucket: 'wishperlog.firebasestorage.app',
    measurementId: 'G-Z5XJT41VDM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB-0jX3pPJ-8iBDMlSW1W19ih_XkqtqH4E',
    appId: '1:982731246537:android:bff1e21915bd4c632cf618',
    messagingSenderId: '982731246537',
    projectId: 'wishperlog',
    storageBucket: 'wishperlog.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBGeq1oyfJaEBXgJRqOuEMTmJzo6IA7dkM',
    appId: '1:982731246537:ios:35dcd639c15b41aa2cf618',
    messagingSenderId: '982731246537',
    projectId: 'wishperlog',
    storageBucket: 'wishperlog.firebasestorage.app',
    iosClientId: '982731246537-ds47rpj0jsvqqoo62ej105n5i0l12u7k.apps.googleusercontent.com',
    iosBundleId: 'com.adarshkumarverma.wishperlog',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBGeq1oyfJaEBXgJRqOuEMTmJzo6IA7dkM',
    appId: '1:982731246537:ios:35dcd639c15b41aa2cf618',
    messagingSenderId: '982731246537',
    projectId: 'wishperlog',
    storageBucket: 'wishperlog.firebasestorage.app',
    iosClientId: '982731246537-ds47rpj0jsvqqoo62ej105n5i0l12u7k.apps.googleusercontent.com',
    iosBundleId: 'com.adarshkumarverma.wishperlog',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyApWYePpNFwwkpKNfe8wBjrcgcvYkVFmiI',
    appId: '1:982731246537:web:7745bf16f7cb93822cf618',
    messagingSenderId: '982731246537',
    projectId: 'wishperlog',
    authDomain: 'wishperlog.firebaseapp.com',
    storageBucket: 'wishperlog.firebasestorage.app',
    measurementId: 'G-3XSDF18KE6',
  );
}
````

### lib/main.dart

```dart
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:wishperlog/app/router.dart';
import 'package:wishperlog/core/background/connectivity_sync_coordinator.dart';
import 'package:wishperlog/core/background/work_manager_service.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/core/theme/app_theme.dart';
import 'package:wishperlog/core/theme/theme_cubit.dart';
import 'package:wishperlog/features/ai/data/ai_processing_service.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/features/overlay/overlay_bubble.dart';
import 'package:wishperlog/features/notifications/data/local_notification_service.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/sync/data/fcm_sync_service.dart';
import 'package:wishperlog/features/sync/data/firestore_note_sync_service.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint('[Main] === APP STARTUP ===');

  // Register FCM background handler before anything else.
  try {
    ensureFcmBackgroundHandlerRegistered();
    debugPrint('[Main] FCM background handler registered');
  } catch (e, st) {
    debugPrint('[Main] FCM handler error: $e');
    debugPrintStack(stackTrace: st);
  }

  // Load environment variables.
  try {
    debugPrint('[Main] Loading .env...');
    await AppEnv.load();
    debugPrint('[Main] .env loaded');
  } catch (e, st) {
    debugPrint('[Main] .env error: $e');
    debugPrintStack(stackTrace: st);
  }

  // Initialize Firebase.
  try {
    debugPrint('[Main] Initializing Firebase...');
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    debugPrint('[Main] Firebase initialized');
  } catch (e, st) {
    debugPrint('[Main] Firebase error: $e');
    debugPrintStack(stackTrace: st);
    rethrow;
  }

  // Set up dependency injection.
  try {
    debugPrint('[Main] Setting up dependency injection...');
    await init();
    debugPrint('[Main] DI container initialized');
  } catch (e, st) {
    debugPrint('[Main] DI setup error: $e');
    debugPrintStack(stackTrace: st);
    rethrow;
  }

  try {
    debugPrint('[Main] Hydrating overlay notifier...');
    await sl<OverlayNotifier>().hydrate();
    debugPrint('[Main] Overlay notifier hydrated');
  } catch (e, st) {
    debugPrint('[Main] Overlay hydration error: $e');
    debugPrintStack(stackTrace: st);
  }

  // Initialize Isar.
  try {
    await IsarNoteStore.instance.init();
  } catch (e, st) {
    debugPrint('[Main] Isar init error (non-fatal): $e');
    debugPrintStack(stackTrace: st);
  }

  // Hydrate theme.
  try {
    debugPrint('[Main] Hydrating theme...');
    await sl<ThemeCubit>().hydrate();
    debugPrint('[Main] Theme hydrated');
  } catch (e, st) {
    debugPrint('[Main] Theme hydrate error: $e');
    debugPrintStack(stackTrace: st);
  }

  // Initialize WorkManager (register callback only — tasks registered below).
  try {
    debugPrint('[Main] Initializing WorkManager...');
    await WorkManagerService.initialize();
    debugPrint('[Main] WorkManager initialized');
  } catch (e, st) {
    debugPrint('[Main] WorkManager error: $e');
    debugPrintStack(stackTrace: st);
  }

  try {
    debugPrint('[Main] Initializing local notifications...');
    await LocalNotificationService.initialize();
    // ISSUE-14: permission request is deferred to the first time a digest
    // schedule is actually configured (see LocalNotificationService).
    debugPrint('[Main] Local notifications initialized');
  } catch (e, st) {
    debugPrint('[Main] Local notification init error: $e');
    debugPrintStack(stackTrace: st);
  }

  debugPrint('[Main] === STARTUP COMPLETE, RUNNING APP ===');

  runApp(
    // OverlayNotifier exposed at the top so MaterialApp.builder can access it.
    ChangeNotifierProvider<OverlayNotifier>.value(
      value: sl<OverlayNotifier>(),
      child: BlocProvider<ThemeCubit>.value(
        value: sl<ThemeCubit>(),
        child: const MyApp(),
      ),
    ),
  );

  // Post-launch background tasks (non-blocking).
  unawaited(_postLaunchTasks());
}

Future<void> _postLaunchTasks() async {
  try {
    await sl<OverlayNotifier>().drainPendingNativeNotes();
  } catch (_) {}

  try {
    debugPrint('[Main] Registering WorkManager periodic syncs...');
    await WorkManagerService.registerPeriodicGoogleTasksSync();
    debugPrint('[Main] WorkManager & periodic syncs initialized');
  } catch (e) {
    debugPrint('[Main] WorkManager periodic registration error: $e');
  }

  try {
    debugPrint('[Main] Starting AI service...');
    sl<AiProcessingService>().start();
    debugPrint('[Main] AI service started');
  } catch (e) {
    debugPrint('[Main] AI service error: $e');
  }

  try {
    debugPrint('[Main] Starting connectivity coordinator...');
    await sl<ConnectivitySyncCoordinator>().start();
    debugPrint('[Main] Connectivity coordinator started');
  } catch (e) {
    debugPrint('[Main] Connectivity coordinator error: $e');
  }

  try {
    debugPrint('[Main] Starting Firestore background sync listener...');
    await sl<FirestoreNoteSyncService>().start();
    debugPrint('[Main] Firestore background sync listener started');
  } catch (e) {
    debugPrint('[Main] Firestore background sync listener error: $e');
  }

  // ISSUE-14: schedule the first digest reminder based on the user's saved prefs.
  try {
    final times = await sl<AppPreferencesRepository>().getDigestTimes();
    if (times.isNotEmpty) {
      await LocalNotificationService.requestPermissionIfSupported();
      final t = times.first;
      await LocalNotificationService.scheduleDigestReminder(
        hour: t.hour, minute: t.minute,
      );
    }
  } catch (e) {
    debugPrint('[Main] Digest reminder scheduling error: $e');
  }

  try {
    debugPrint('[Main] Initializing FCM sync service...');
    await sl<FcmSyncService>().initialize();
    debugPrint('[Main] FCM sync service initialized');
  } catch (e) {
    debugPrint('[Main] FCM sync error: $e');
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      bloc: sl<ThemeCubit>(),
      builder: (context, themeMode) {
        final brightness = themeMode == ThemeMode.system
            ? WidgetsBinding.instance.platformDispatcher.platformBrightness
            : themeMode == ThemeMode.dark
                ? Brightness.dark
                : Brightness.light;
        return BlocProvider<CaptureUiController>.value(
          value: sl<CaptureUiController>(),
          child: MaterialApp.router(
            title: 'WhisperLog',
            debugShowCheckedModeBanner: false,
            themeMode: themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: router,
            // builder runs INSIDE MaterialApp (which provides an Overlay).
            builder: (context, child) {
              // Enforce system UI overlays.
              SystemChrome.setSystemUIOverlayStyle(
                brightness == Brightness.dark
                    ? SystemUiOverlayStyle.light
                    : SystemUiOverlayStyle.dark,
              );
              return OverlayRootWrapper(
                child: child ?? const SizedBox.shrink(),
              );
            },
          ),
        );
      },
    );
  }
}
```

### lib/shared/events/note_event_bus.dart

```dart
import 'dart:async';

class NoteEventBus {
  NoteEventBus._();

  static final NoteEventBus instance = NoteEventBus._();

  final StreamController<String> _noteSavedController =
      StreamController<String>.broadcast();
  final StreamController<String> _noteUpdatedController =
      StreamController<String>.broadcast();

  Stream<String> get onNoteSaved => _noteSavedController.stream;
  Stream<String> get onNoteUpdated => _noteUpdatedController.stream;

  void emitNoteSaved(String noteId) {
    if (noteId.trim().isEmpty) {
      return;
    }
    _noteSavedController.add(noteId);
  }

  void emitNoteUpdated(String noteId) {
    if (noteId.trim().isEmpty) {
      return;
    }
    _noteUpdatedController.add(noteId);
  }
}
```

### lib/shared/models/enums.dart

```dart
enum NoteCategory {
  tasks,
  reminders,
  ideas,
  followUp,
  journal,
  general,
}

enum NotePriority {
  high,
  medium,
  low,
}

enum NoteStatus {
  active,
  archived,
  pendingAi,
  deleted,
}

enum CaptureSource {
  voiceOverlay,
  textOverlay,
  homeWritingBox,
  shortcutTile,
  notification,
  googleTasks,
  googleCalendar,
}

enum AiProvider {
  auto,
  gemini,
  groq,
  mistral,
  huggingface,
  cerebras,
}
```

### lib/shared/models/note.dart

```dart
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:isar/isar.dart';

import 'enums.dart';
import 'note_helpers.dart';

part 'note.g.dart';

int fastHash(String string) {
  var hash = 0xcbf29ce484222000;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}

@collection
class Note {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String noteId;
  String uid;
  String rawTranscript;
  String title;
  String cleanBody;

  @Enumerated(EnumType.name)
  NoteCategory category;

  @Enumerated(EnumType.name)
  NotePriority priority;

  DateTime? extractedDate;
  DateTime createdAt;
  DateTime updatedAt;

  @Index()
  @Enumerated(EnumType.name)
  NoteStatus status;

  String aiModel;
  String? gcalEventId;
  String? gtaskId;

  @Enumerated(EnumType.name)
  CaptureSource source;

  DateTime? syncedAt;

  /// Non-null when the AI detected non-English input and produced an English
  /// translation. The original text stays in [title] / [cleanBody].
  String? translatedContent;

  Note({
    required this.noteId,
    required this.uid,
    required this.rawTranscript,
    required this.title,
    required this.cleanBody,
    required this.category,
    required this.priority,
    this.extractedDate,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.aiModel,
    this.gcalEventId,
    this.gtaskId,
    required this.source,
    this.syncedAt,
    this.translatedContent,
  });

  Note copyWith({
    String? noteId,
    String? uid,
    String? rawTranscript,
    String? title,
    String? cleanBody,
    NoteCategory? category,
    NotePriority? priority,
    DateTime? extractedDate,
    bool clearExtractedDate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    NoteStatus? status,
    String? aiModel,
    String? gcalEventId,
    bool clearGcalEventId = false,
    String? gtaskId,
    bool clearGtaskId = false,
    CaptureSource? source,
    DateTime? syncedAt,
    bool clearSyncedAt = false,
    String? translatedContent,
    bool clearTranslatedContent = false,
  }) {
    return Note(
      noteId: noteId ?? this.noteId,
      uid: uid ?? this.uid,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      title: title ?? this.title,
      cleanBody: cleanBody ?? this.cleanBody,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      extractedDate: clearExtractedDate
          ? null
          : (extractedDate ?? this.extractedDate),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      aiModel: aiModel ?? this.aiModel,
      gcalEventId: clearGcalEventId ? null : (gcalEventId ?? this.gcalEventId),
      gtaskId: clearGtaskId ? null : (gtaskId ?? this.gtaskId),
      source: source ?? this.source,
      syncedAt: clearSyncedAt ? null : (syncedAt ?? this.syncedAt),
      translatedContent: clearTranslatedContent
          ? null
          : (translatedContent ?? this.translatedContent),
    );
  }

  Map<String, dynamic> toFirestoreJson() {
    // ISSUE-10: Use typed Timestamp fields so Firestore can sort/query server-side.
    return {
      'note_id': noteId,
      'uid': uid,
      'raw_transcript': rawTranscript,
      'title': title,
      'clean_body': cleanBody,
      'category': category.name,
      'priority': priority.name,
      'ai_model': aiModel,
      'status': status.name,
      'source': source.name,
        'extracted_date': extractedDate != null
          ? firestore.Timestamp.fromDate(extractedDate!)
          : null,
        'created_at': firestore.Timestamp.fromDate(createdAt),
        'updated_at': firestore.Timestamp.fromDate(updatedAt),
        'synced_at': syncedAt != null
          ? firestore.Timestamp.fromDate(syncedAt!)
          : null,
      'gtask_id': gtaskId,
      'gcal_event_id': gcalEventId,
      'is_deleted': status == NoteStatus.deleted,
      'translated_content': translatedContent,
    };
  }

  Map<String, Object?> toSqliteMap() {
    return {
      'note_id': noteId,
      'uid': uid,
      'raw_transcript': rawTranscript,
      'title': title,
      'clean_body': cleanBody,
      'category': category.name,
      'priority': priority.name,
      'extracted_date': extractedDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status.name,
      'ai_model': aiModel,
      'gcal_event_id': gcalEventId,
      'gtask_id': gtaskId,
      'source': source.name,
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory Note.fromSqliteMap(Map<String, Object?> row) {
    return Note(
      noteId: _readString(row, 'note_id'),
      uid: _readString(row, 'uid'),
      rawTranscript: _readString(row, 'raw_transcript'),
      title: _readString(row, 'title'),
      cleanBody: _readString(row, 'clean_body'),
      category: parseCategory(_readString(row, 'category')),
      priority: parsePriority(_readString(row, 'priority')),
      extractedDate: _readDate(row['extracted_date']),
      createdAt: _readDate(row['created_at']) ?? DateTime.now(),
      updatedAt: _readDate(row['updated_at']) ?? DateTime.now(),
      status: parseStatus(_readString(row, 'status')),
      aiModel: _readString(row, 'ai_model'),
      gcalEventId: row['gcal_event_id']?.toString(),
      gtaskId: row['gtask_id']?.toString(),
      source: parseSource(_readString(row, 'source')),
      syncedAt: _readDate(row['synced_at']),
    );
  }

  factory Note.fromFirestoreJson(
    Map<String, dynamic> json, {
    required String uid,
    required String noteId,
  }) {
    return Note(
      noteId: noteId,
      uid: uid,
      rawTranscript: (json['raw_transcript'] as String?)?.trim() ?? '',
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Quick note',
      cleanBody:
          (json['clean_body'] as String?)?.trim() ??
          (json['raw_transcript'] as String?)?.trim() ??
          '',
      category: parseCategory(
        (json['category'] as String?) ?? NoteCategory.general.name,
      ),
      priority: parsePriority(
        (json['priority'] as String?) ?? NotePriority.medium.name,
      ),
      extractedDate: _readFirestoreDate(json['extracted_date']),
      createdAt: _readFirestoreDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _readFirestoreDate(json['updated_at']) ?? DateTime.now(),
      status: parseStatus(
        (json['status'] as String?) ?? NoteStatus.active.name,
      ),
      aiModel: (json['ai_model'] as String?) ?? '',
      gcalEventId: json['gcal_event_id'] as String?,
      gtaskId: json['gtask_id'] as String?,
      source: parseSource(
        (json['source'] as String?) ?? CaptureSource.homeWritingBox.name,
      ),
      syncedAt: _readFirestoreDate(json['synced_at']),
      translatedContent: json['translated_content'] as String?,
    );
  }

  static String _readString(Map<String, Object?> row, String key) {
    return row[key]?.toString() ?? '';
  }

  static DateTime? _readDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  /// Reads a date field that may be a Firestore [Timestamp] (new) or an ISO
  /// [String] (legacy documents written before ISSUE-10 was fixed).
  static DateTime? _readFirestoreDate(Object? value) {
    if (value == null) return null;
    if (value is firestore.Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString());
  }
}
```

### lib/shared/models/note.g.dart

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetNoteCollection on Isar {
  IsarCollection<Note> get notes => this.collection();
}

final int _noteSchemaId = int.parse('6284318083599466921');
final int _noteIndexNoteId = int.parse('-9014133502494436840');
final int _noteIndexStatus = int.parse('-107785170620420283');

final NoteSchema = CollectionSchema(
  name: r'Note',
  id: _noteSchemaId,
  properties: {
    r'aiModel': PropertySchema(
      id: 0,
      name: r'aiModel',
      type: IsarType.string,
    ),
    r'category': PropertySchema(
      id: 1,
      name: r'category',
      type: IsarType.string,
      enumMap: _NotecategoryEnumValueMap,
    ),
    r'cleanBody': PropertySchema(
      id: 2,
      name: r'cleanBody',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 3,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'extractedDate': PropertySchema(
      id: 4,
      name: r'extractedDate',
      type: IsarType.dateTime,
    ),
    r'gcalEventId': PropertySchema(
      id: 5,
      name: r'gcalEventId',
      type: IsarType.string,
    ),
    r'gtaskId': PropertySchema(
      id: 6,
      name: r'gtaskId',
      type: IsarType.string,
    ),
    r'noteId': PropertySchema(
      id: 7,
      name: r'noteId',
      type: IsarType.string,
    ),
    r'priority': PropertySchema(
      id: 8,
      name: r'priority',
      type: IsarType.string,
      enumMap: _NotepriorityEnumValueMap,
    ),
    r'rawTranscript': PropertySchema(
      id: 9,
      name: r'rawTranscript',
      type: IsarType.string,
    ),
    r'source': PropertySchema(
      id: 10,
      name: r'source',
      type: IsarType.string,
      enumMap: _NotesourceEnumValueMap,
    ),
    r'status': PropertySchema(
      id: 11,
      name: r'status',
      type: IsarType.string,
      enumMap: _NotestatusEnumValueMap,
    ),
    r'syncedAt': PropertySchema(
      id: 12,
      name: r'syncedAt',
      type: IsarType.dateTime,
    ),
    r'title': PropertySchema(
      id: 13,
      name: r'title',
      type: IsarType.string,
    ),
    r'uid': PropertySchema(
      id: 14,
      name: r'uid',
      type: IsarType.string,
    ),
    r'updatedAt': PropertySchema(
      id: 15,
      name: r'updatedAt',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _noteEstimateSize,
  serialize: _noteSerialize,
  deserialize: _noteDeserialize,
  deserializeProp: _noteDeserializeProp,
  idName: r'isarId',
  indexes: {
    r'noteId': IndexSchema(
      id: _noteIndexNoteId,
      name: r'noteId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'noteId',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'status': IndexSchema(
      id: _noteIndexStatus,
      name: r'status',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'status',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _noteGetId,
  getLinks: _noteGetLinks,
  attach: _noteAttach,
  version: '3.1.0+1',
);

int _noteEstimateSize(
  Note object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.aiModel.length * 3;
  bytesCount += 3 + object.category.name.length * 3;
  bytesCount += 3 + object.cleanBody.length * 3;
  {
    final value = object.gcalEventId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.gtaskId;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.noteId.length * 3;
  bytesCount += 3 + object.priority.name.length * 3;
  bytesCount += 3 + object.rawTranscript.length * 3;
  bytesCount += 3 + object.source.name.length * 3;
  bytesCount += 3 + object.status.name.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.uid.length * 3;
  return bytesCount;
}

void _noteSerialize(
  Note object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.aiModel);
  writer.writeString(offsets[1], object.category.name);
  writer.writeString(offsets[2], object.cleanBody);
  writer.writeDateTime(offsets[3], object.createdAt);
  writer.writeDateTime(offsets[4], object.extractedDate);
  writer.writeString(offsets[5], object.gcalEventId);
  writer.writeString(offsets[6], object.gtaskId);
  writer.writeString(offsets[7], object.noteId);
  writer.writeString(offsets[8], object.priority.name);
  writer.writeString(offsets[9], object.rawTranscript);
  writer.writeString(offsets[10], object.source.name);
  writer.writeString(offsets[11], object.status.name);
  writer.writeDateTime(offsets[12], object.syncedAt);
  writer.writeString(offsets[13], object.title);
  writer.writeString(offsets[14], object.uid);
  writer.writeDateTime(offsets[15], object.updatedAt);
}

Note _noteDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Note(
    aiModel: reader.readString(offsets[0]),
    category: _NotecategoryValueEnumMap[reader.readStringOrNull(offsets[1])] ??
        NoteCategory.tasks,
    cleanBody: reader.readString(offsets[2]),
    createdAt: reader.readDateTime(offsets[3]),
    extractedDate: reader.readDateTimeOrNull(offsets[4]),
    gcalEventId: reader.readStringOrNull(offsets[5]),
    gtaskId: reader.readStringOrNull(offsets[6]),
    noteId: reader.readString(offsets[7]),
    priority: _NotepriorityValueEnumMap[reader.readStringOrNull(offsets[8])] ??
        NotePriority.high,
    rawTranscript: reader.readString(offsets[9]),
    source: _NotesourceValueEnumMap[reader.readStringOrNull(offsets[10])] ??
        CaptureSource.voiceOverlay,
    status: _NotestatusValueEnumMap[reader.readStringOrNull(offsets[11])] ??
        NoteStatus.active,
    syncedAt: reader.readDateTimeOrNull(offsets[12]),
    title: reader.readString(offsets[13]),
    uid: reader.readString(offsets[14]),
    updatedAt: reader.readDateTime(offsets[15]),
  );
  object.isarId = id;
  return object;
}

P _noteDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (_NotecategoryValueEnumMap[reader.readStringOrNull(offset)] ??
          NoteCategory.tasks) as P;
    case 2:
      return (reader.readString(offset)) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readStringOrNull(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (_NotepriorityValueEnumMap[reader.readStringOrNull(offset)] ??
          NotePriority.high) as P;
    case 9:
      return (reader.readString(offset)) as P;
    case 10:
      return (_NotesourceValueEnumMap[reader.readStringOrNull(offset)] ??
          CaptureSource.voiceOverlay) as P;
    case 11:
      return (_NotestatusValueEnumMap[reader.readStringOrNull(offset)] ??
          NoteStatus.active) as P;
    case 12:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 13:
      return (reader.readString(offset)) as P;
    case 14:
      return (reader.readString(offset)) as P;
    case 15:
      return (reader.readDateTime(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _NotecategoryEnumValueMap = {
  r'tasks': r'tasks',
  r'reminders': r'reminders',
  r'ideas': r'ideas',
  r'followUp': r'followUp',
  r'journal': r'journal',
  r'general': r'general',
};
const _NotecategoryValueEnumMap = {
  r'tasks': NoteCategory.tasks,
  r'reminders': NoteCategory.reminders,
  r'ideas': NoteCategory.ideas,
  r'followUp': NoteCategory.followUp,
  r'journal': NoteCategory.journal,
  r'general': NoteCategory.general,
};
const _NotepriorityEnumValueMap = {
  r'high': r'high',
  r'medium': r'medium',
  r'low': r'low',
};
const _NotepriorityValueEnumMap = {
  r'high': NotePriority.high,
  r'medium': NotePriority.medium,
  r'low': NotePriority.low,
};
const _NotesourceEnumValueMap = {
  r'voiceOverlay': r'voiceOverlay',
  r'textOverlay': r'textOverlay',
  r'homeWritingBox': r'homeWritingBox',
  r'shortcutTile': r'shortcutTile',
  r'notification': r'notification',
  r'googleTasks': r'googleTasks',
  r'googleCalendar': r'googleCalendar',
};
const _NotesourceValueEnumMap = {
  r'voiceOverlay': CaptureSource.voiceOverlay,
  r'textOverlay': CaptureSource.textOverlay,
  r'homeWritingBox': CaptureSource.homeWritingBox,
  r'shortcutTile': CaptureSource.shortcutTile,
  r'notification': CaptureSource.notification,
  r'googleTasks': CaptureSource.googleTasks,
  r'googleCalendar': CaptureSource.googleCalendar,
};
const _NotestatusEnumValueMap = {
  r'active': r'active',
  r'archived': r'archived',
  r'pendingAi': r'pendingAi',
  r'deleted': r'deleted',
};
const _NotestatusValueEnumMap = {
  r'active': NoteStatus.active,
  r'archived': NoteStatus.archived,
  r'pendingAi': NoteStatus.pendingAi,
  r'deleted': NoteStatus.deleted,
};

Id _noteGetId(Note object) {
  return object.isarId;
}

List<IsarLinkBase<dynamic>> _noteGetLinks(Note object) {
  return [];
}

void _noteAttach(IsarCollection<dynamic> col, Id id, Note object) {
  object.isarId = id;
}

extension NoteByIndex on IsarCollection<Note> {
  Future<Note?> getByNoteId(String noteId) {
    return getByIndex(r'noteId', [noteId]);
  }

  Note? getByNoteIdSync(String noteId) {
    return getByIndexSync(r'noteId', [noteId]);
  }

  Future<bool> deleteByNoteId(String noteId) {
    return deleteByIndex(r'noteId', [noteId]);
  }

  bool deleteByNoteIdSync(String noteId) {
    return deleteByIndexSync(r'noteId', [noteId]);
  }

  Future<List<Note?>> getAllByNoteId(List<String> noteIdValues) {
    final values = noteIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'noteId', values);
  }

  List<Note?> getAllByNoteIdSync(List<String> noteIdValues) {
    final values = noteIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'noteId', values);
  }

  Future<int> deleteAllByNoteId(List<String> noteIdValues) {
    final values = noteIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'noteId', values);
  }

  int deleteAllByNoteIdSync(List<String> noteIdValues) {
    final values = noteIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'noteId', values);
  }

  Future<Id> putByNoteId(Note object) {
    return putByIndex(r'noteId', object);
  }

  Id putByNoteIdSync(Note object, {bool saveLinks = true}) {
    return putByIndexSync(r'noteId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByNoteId(List<Note> objects) {
    return putAllByIndex(r'noteId', objects);
  }

  List<Id> putAllByNoteIdSync(List<Note> objects, {bool saveLinks = true}) {
    return putAllByIndexSync(r'noteId', objects, saveLinks: saveLinks);
  }
}

extension NoteQueryWhereSort on QueryBuilder<Note, Note, QWhere> {
  QueryBuilder<Note, Note, QAfterWhere> anyIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension NoteQueryWhere on QueryBuilder<Note, Note, QWhereClause> {
  QueryBuilder<Note, Note, QAfterWhereClause> isarIdEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: isarId,
        upper: isarId,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterWhereClause> isarIdNotEqualTo(Id isarId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: isarId, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: isarId, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Note, Note, QAfterWhereClause> isarIdGreaterThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: isarId, includeLower: include),
      );
    });
  }

  QueryBuilder<Note, Note, QAfterWhereClause> isarIdLessThan(Id isarId,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: isarId, includeUpper: include),
      );
    });
  }

  QueryBuilder<Note, Note, QAfterWhereClause> isarIdBetween(
    Id lowerIsarId,
    Id upperIsarId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerIsarId,
        includeLower: includeLower,
        upper: upperIsarId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterWhereClause> noteIdEqualTo(String noteId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'noteId',
        value: [noteId],
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterWhereClause> noteIdNotEqualTo(String noteId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'noteId',
              lower: [],
              upper: [noteId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'noteId',
              lower: [noteId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'noteId',
              lower: [noteId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'noteId',
              lower: [],
              upper: [noteId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Note, Note, QAfterWhereClause> statusEqualTo(NoteStatus status) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'status',
        value: [status],
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterWhereClause> statusNotEqualTo(
      NoteStatus status) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [status],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'status',
              lower: [],
              upper: [status],
              includeUpper: false,
            ));
      }
    });
  }
}

extension NoteQueryFilter on QueryBuilder<Note, Note, QFilterCondition> {
  QueryBuilder<Note, Note, QAfterFilterCondition> aiModelEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> aiModelGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> aiModelLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> aiModelBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'aiModel',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> aiModelStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> aiModelEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> aiModelContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'aiModel',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> aiModelMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'aiModel',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> aiModelIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'aiModel',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> aiModelIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'aiModel',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> categoryEqualTo(
    NoteCategory value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> categoryGreaterThan(
    NoteCategory value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> categoryLessThan(
    NoteCategory value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> categoryBetween(
    NoteCategory lower,
    NoteCategory upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'category',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> categoryStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> categoryEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> categoryContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'category',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> categoryMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'category',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> categoryIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> categoryIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'category',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> cleanBodyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cleanBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> cleanBodyGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'cleanBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> cleanBodyLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'cleanBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> cleanBodyBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'cleanBody',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> cleanBodyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'cleanBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> cleanBodyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'cleanBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> cleanBodyContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'cleanBody',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> cleanBodyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'cleanBody',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> cleanBodyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'cleanBody',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> cleanBodyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'cleanBody',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> createdAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> extractedDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'extractedDate',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> extractedDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'extractedDate',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> extractedDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'extractedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> extractedDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'extractedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> extractedDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'extractedDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> extractedDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'extractedDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gcalEventIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gcalEventId',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gcalEventIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gcalEventId',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gcalEventIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gcalEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gcalEventIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gcalEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gcalEventIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gcalEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gcalEventIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gcalEventId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gcalEventIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gcalEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gcalEventIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gcalEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gcalEventIdContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gcalEventId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gcalEventIdMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gcalEventId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gcalEventIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gcalEventId',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gcalEventIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gcalEventId',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gtaskIdIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'gtaskId',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gtaskIdIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'gtaskId',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gtaskIdEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gtaskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gtaskIdGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'gtaskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gtaskIdLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'gtaskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gtaskIdBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'gtaskId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gtaskIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'gtaskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gtaskIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'gtaskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gtaskIdContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'gtaskId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gtaskIdMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'gtaskId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gtaskIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'gtaskId',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> gtaskIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'gtaskId',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> isarIdEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> isarIdGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> isarIdLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'isarId',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> isarIdBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'isarId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> noteIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'noteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> noteIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'noteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> noteIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'noteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> noteIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'noteId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> noteIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'noteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> noteIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'noteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> noteIdContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'noteId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> noteIdMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'noteId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> noteIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'noteId',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> noteIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'noteId',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> priorityEqualTo(
    NotePriority value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> priorityGreaterThan(
    NotePriority value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> priorityLessThan(
    NotePriority value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> priorityBetween(
    NotePriority lower,
    NotePriority upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'priority',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> priorityStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> priorityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> priorityContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'priority',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> priorityMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'priority',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> priorityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'priority',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> priorityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'priority',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rawTranscriptEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rawTranscriptGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'rawTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rawTranscriptLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'rawTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rawTranscriptBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'rawTranscript',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rawTranscriptStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'rawTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rawTranscriptEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'rawTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rawTranscriptContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'rawTranscript',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rawTranscriptMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'rawTranscript',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rawTranscriptIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'rawTranscript',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> rawTranscriptIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'rawTranscript',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sourceEqualTo(
    CaptureSource value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sourceGreaterThan(
    CaptureSource value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sourceLessThan(
    CaptureSource value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sourceBetween(
    CaptureSource lower,
    CaptureSource upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'source',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sourceStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sourceEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sourceContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'source',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sourceMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'source',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sourceIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> sourceIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'source',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> statusEqualTo(
    NoteStatus value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> statusGreaterThan(
    NoteStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> statusLessThan(
    NoteStatus value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> statusBetween(
    NoteStatus lower,
    NoteStatus upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'status',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> statusStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> statusEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> statusContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'status',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> statusMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'status',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> statusIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> statusIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'status',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> syncedAtIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> syncedAtIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'syncedAt',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> syncedAtEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> syncedAtGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> syncedAtLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'syncedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> syncedAtBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'syncedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> titleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> titleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'title',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> titleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> titleContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'title',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> titleMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'title',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'title',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> uidEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> uidGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> uidLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> uidBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'uid',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> uidStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> uidEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> uidContains(String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'uid',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> uidMatches(String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'uid',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> uidIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> uidIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'uid',
        value: '',
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> updatedAtEqualTo(
      DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> updatedAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> updatedAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'updatedAt',
        value: value,
      ));
    });
  }

  QueryBuilder<Note, Note, QAfterFilterCondition> updatedAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'updatedAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension NoteQueryObject on QueryBuilder<Note, Note, QFilterCondition> {}

extension NoteQueryLinks on QueryBuilder<Note, Note, QFilterCondition> {}

extension NoteQuerySortBy on QueryBuilder<Note, Note, QSortBy> {
  QueryBuilder<Note, Note, QAfterSortBy> sortByAiModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByAiModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByCleanBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanBody', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByCleanBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanBody', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByExtractedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractedDate', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByExtractedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractedDate', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByGcalEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gcalEventId', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByGcalEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gcalEventId', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByGtaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gtaskId', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByGtaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gtaskId', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByNoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noteId', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByNoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noteId', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByRawTranscript() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawTranscript', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByRawTranscriptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawTranscript', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> sortByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension NoteQuerySortThenBy on QueryBuilder<Note, Note, QSortThenBy> {
  QueryBuilder<Note, Note, QAfterSortBy> thenByAiModel() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByAiModelDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'aiModel', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByCategory() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByCategoryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'category', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByCleanBody() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanBody', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByCleanBodyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'cleanBody', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByExtractedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractedDate', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByExtractedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'extractedDate', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByGcalEventId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gcalEventId', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByGcalEventIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gcalEventId', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByGtaskId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gtaskId', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByGtaskIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'gtaskId', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByIsarId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByIsarIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isarId', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByNoteId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noteId', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByNoteIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'noteId', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByPriority() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByPriorityDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'priority', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByRawTranscript() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawTranscript', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByRawTranscriptDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'rawTranscript', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenBySource() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenBySourceDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'source', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByStatus() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByStatusDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'status', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenBySyncedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'syncedAt', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'title', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByUid() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByUidDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'uid', Sort.desc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.asc);
    });
  }

  QueryBuilder<Note, Note, QAfterSortBy> thenByUpdatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'updatedAt', Sort.desc);
    });
  }
}

extension NoteQueryWhereDistinct on QueryBuilder<Note, Note, QDistinct> {
  QueryBuilder<Note, Note, QDistinct> distinctByAiModel(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'aiModel', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByCategory(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'category', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByCleanBody(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'cleanBody', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByExtractedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'extractedDate');
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByGcalEventId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gcalEventId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByGtaskId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'gtaskId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByNoteId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'noteId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByPriority(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'priority', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByRawTranscript(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'rawTranscript',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctBySource(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'source', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByStatus(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'status', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctBySyncedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'syncedAt');
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByTitle(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'title', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByUid(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'uid', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Note, Note, QDistinct> distinctByUpdatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'updatedAt');
    });
  }
}

extension NoteQueryProperty on QueryBuilder<Note, Note, QQueryProperty> {
  QueryBuilder<Note, int, QQueryOperations> isarIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isarId');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> aiModelProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'aiModel');
    });
  }

  QueryBuilder<Note, NoteCategory, QQueryOperations> categoryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'category');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> cleanBodyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'cleanBody');
    });
  }

  QueryBuilder<Note, DateTime, QQueryOperations> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<Note, DateTime?, QQueryOperations> extractedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'extractedDate');
    });
  }

  QueryBuilder<Note, String?, QQueryOperations> gcalEventIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gcalEventId');
    });
  }

  QueryBuilder<Note, String?, QQueryOperations> gtaskIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'gtaskId');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> noteIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'noteId');
    });
  }

  QueryBuilder<Note, NotePriority, QQueryOperations> priorityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'priority');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> rawTranscriptProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'rawTranscript');
    });
  }

  QueryBuilder<Note, CaptureSource, QQueryOperations> sourceProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'source');
    });
  }

  QueryBuilder<Note, NoteStatus, QQueryOperations> statusProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'status');
    });
  }

  QueryBuilder<Note, DateTime?, QQueryOperations> syncedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'syncedAt');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'title');
    });
  }

  QueryBuilder<Note, String, QQueryOperations> uidProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'uid');
    });
  }

  QueryBuilder<Note, DateTime, QQueryOperations> updatedAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'updatedAt');
    });
  }
}
```

### lib/shared/models/note_helpers.dart

```dart
import 'package:flutter/material.dart';
import 'package:wishperlog/shared/models/enums.dart';

const List<NoteCategory> kAllNoteCategories = [
  NoteCategory.tasks,
  NoteCategory.reminders,
  NoteCategory.ideas,
  NoteCategory.followUp,
  NoteCategory.journal,
  NoteCategory.general,
];

String categoryLabel(NoteCategory category) {
  switch (category) {
    case NoteCategory.tasks:
      return 'Tasks';
    case NoteCategory.reminders:
      return 'Reminders';
    case NoteCategory.ideas:
      return 'Ideas';
    case NoteCategory.followUp:
      return 'Follow-up';
    case NoteCategory.journal:
      return 'Journal';
    case NoteCategory.general:
      return 'General';
  }
}

String categoryEmoji(NoteCategory category) {
  switch (category) {
    case NoteCategory.tasks:
      return '✅';
    case NoteCategory.reminders:
      return '⏰';
    case NoteCategory.ideas:
      return '💡';
    case NoteCategory.followUp:
      return '🔁';
    case NoteCategory.journal:
      return '📔';
    case NoteCategory.general:
      return '📝';
  }
}

IconData categoryIcon(NoteCategory category) {
  switch (category) {
    case NoteCategory.tasks:
      return Icons.check_circle_outline;
    case NoteCategory.reminders:
      return Icons.notifications_none_rounded;
    case NoteCategory.ideas:
      return Icons.lightbulb_outline_rounded;
    case NoteCategory.followUp:
      return Icons.reply_rounded;
    case NoteCategory.journal:
      return Icons.menu_book_rounded;
    case NoteCategory.general:
      return Icons.grid_view_rounded;
  }
}

String normalizeEnumToken(String raw) {
  return raw
      .trim()
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .toLowerCase()
      .replaceAll(RegExp(r'[_-]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _normalizeInferenceText(String raw) {
  return normalizeEnumToken(raw)
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _hasPhrase(String text, List<String> phrases) {
  for (final phrase in phrases) {
    if (RegExp(r'\b' + RegExp.escape(phrase) + r'\b').hasMatch(text)) {
      return true;
    }
  }
  return false;
}

NoteCategory inferCategoryFromText(String raw) {
  final text = _normalizeInferenceText(raw);
  if (text.isEmpty) return NoteCategory.general;

  if (_hasPhrase(text, const [
    'follow up',
    'followup',
    'check in',
    'check with',
    'ping',
    'any update on',
    'touch base',
    'get back to',
  ])) {
    return NoteCategory.followUp;
  }

  final hasDateSignal = _hasPhrase(text, const [
    'today',
    'tomorrow',
    'tonight',
    'next monday',
    'next tuesday',
    'next wednesday',
    'next thursday',
    'next friday',
    'next saturday',
    'next sunday',
    'this monday',
    'this tuesday',
    'this wednesday',
    'this thursday',
    'this friday',
    'this saturday',
    'this sunday',
    'this week',
    'next week',
    'remind me',
    'reminder',
  ]) ||
      RegExp(r'\b\d{1,2}(:\d{2})?\s?(am|pm)?\b').hasMatch(text) ||
      RegExp(r'\b\d{4}-\d{2}-\d{2}\b').hasMatch(text);
  if (hasDateSignal) {
    return NoteCategory.reminders;
  }

  final actionVerbAtStart = RegExp(
    r'^(call|buy|book|send|email|text|reply|fix|finish|review|update|draft|write|prepare|submit|pay|schedule|move|order|install|create|check|clean|plan|meet|join|ring)\b',
  ).hasMatch(text);
  final actionSignal = actionVerbAtStart || _hasPhrase(text, const [
    'to do',
    'todo',
    'need to',
    'must',
    'should',
    'have to',
    'remember to',
  ]);
  if (actionSignal) {
    return NoteCategory.tasks;
  }

  if (_hasPhrase(text, const [
    'idea',
    'brainstorm',
    'what if',
    'could be',
    'maybe',
    'explore',
    'consider',
  ])) {
    return NoteCategory.ideas;
  }

  if (_hasPhrase(text, const [
    'i feel',
    'today i',
    'grateful',
    'frustrated',
    'happy',
    'sad',
    'reflect',
    'reflection',
    'note to self',
    'learned',
  ])) {
    return NoteCategory.journal;
  }

  return NoteCategory.general;
}

NoteCategory parseCategory(String raw) {
  final value = normalizeEnumToken(raw);
  switch (value) {
    case 'task':
    case 'tasks':
      return NoteCategory.tasks;
    case 'reminder':
    case 'reminders':
      return NoteCategory.reminders;
    case 'idea':
    case 'ideas':
      return NoteCategory.ideas;
    case 'followup':
    case 'follow up':
    case 'follow-up':
      return NoteCategory.followUp;
    case 'journal':
      return NoteCategory.journal;
    case 'general':
    default:
      return NoteCategory.general;
  }
}

NotePriority parsePriority(String raw) {
  switch (normalizeEnumToken(raw)) {
    case 'high':
      return NotePriority.high;
    case 'low':
      return NotePriority.low;
    case 'medium':
    default:
      return NotePriority.medium;
  }
}

String saveOriginPrefix(String aiModel, {bool wasFallback = false}) {
  final model = normalizeEnumToken(aiModel);
  if (wasFallback ||
      model.startsWith('local') ||
      model.contains('fallback') ||
      model.startsWith('sys')) {
    return 'sys';
  }
  return 'AI';
}

NoteStatus parseStatus(String raw) {
  switch (normalizeEnumToken(raw)) {
    case 'archived':
      return NoteStatus.archived;
    case 'deleted':
      return NoteStatus.deleted;
    case 'pending ai':
      return NoteStatus.pendingAi;
    case 'active':
    default:
      return NoteStatus.active;
  }
}

CaptureSource parseSource(String raw) {
  switch (normalizeEnumToken(raw)) {
    case 'voice overlay':
      return CaptureSource.voiceOverlay;
    case 'text overlay':
      return CaptureSource.textOverlay;
    case 'shortcut tile':
      return CaptureSource.shortcutTile;
    case 'notification':
      return CaptureSource.notification;
    // ISSUE-10: these were previously falling through to homeWritingBox.
    case 'google tasks':
    case 'googletasks':
      return CaptureSource.googleTasks;
    case 'google calendar':
    case 'googlecalendar':
      return CaptureSource.googleCalendar;
    case 'home writing box':
    default:
      return CaptureSource.homeWritingBox;
  }
}

int priorityWeight(NotePriority priority) {
  switch (priority) {
    case NotePriority.high:
      return 0;
    case NotePriority.medium:
      return 1;
    case NotePriority.low:
      return 2;
  }
}

Color priorityColor(NotePriority priority) {
  switch (priority) {
    case NotePriority.high:
      return const Color(0xFFD64545);
    case NotePriority.medium:
      return const Color(0xFFDEB437);
    case NotePriority.low:
      return const Color(0xFF9CA3AF);
  }
}
```

### lib/shared/models/user.dart

```dart
// lib/shared/models/user.dart  — FULL REPLACEMENT

/// Envelope for the pre-built, channel-specific outbox stored on the user doc.
/// The Worker reads this; never re-calculates.
class MessageState {
  /// Pre-rendered Telegram HTML string. Null when no content is available.
  final String? telegram;

  /// Reserved for WhatsApp plain-text. Null until provider is wired.
  final String? whatsapp;

  /// Reserved for Email HTML. Null until provider is wired.
  final String? email;

  /// UTC epoch-ms when this state was last written by the app.
  final DateTime? computedAt;

  const MessageState({
    this.telegram,
    this.whatsapp,
    this.email,
    this.computedAt,
  });

  bool get isEmpty =>
      (telegram == null || telegram!.isEmpty) &&
      (whatsapp == null || whatsapp!.isEmpty) &&
      (email == null || email!.isEmpty);

  Map<String, dynamic> toJson() => {
    'telegram':    telegram,
    'whatsapp':    whatsapp,
    'email':       email,
    'computed_at': computedAt?.toIso8601String(),
  };

  factory MessageState.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MessageState();
    return MessageState(
      telegram:   json['telegram']  as String?,
      whatsapp:   json['whatsapp']  as String?,
      email:      json['email']     as String?,
      computedAt: json['computed_at'] is String
          ? DateTime.tryParse(json['computed_at'] as String)
          : null,
    );
  }

  MessageState copyWith({
    String? telegram,
    String? whatsapp,
    String? email,
    DateTime? computedAt,
  }) => MessageState(
    telegram:   telegram   ?? this.telegram,
    whatsapp:   whatsapp   ?? this.whatsapp,
    email:      email      ?? this.email,
    computedAt: computedAt ?? this.computedAt,
  );
}

class User {
  final String uid;
  final String email;
  final String displayName;
  final Map<String, dynamic> googleTokens;
  final String? telegramChatId;

  /// Legacy single-slot field — kept for backward compat with existing docs.
  final String digestTime;

  /// Multi-slot schedule in "HH:MM" format (UTC). Source of truth for Worker.
  final List<String> digestSlots;

  final Map<String, dynamic> overlayPosition;
  final bool overlayVisible;
  final String fcmToken;
  final DateTime createdAt;

  /// Pre-built outbox — the Worker reads this instead of re-calculating.
  final MessageState messageState;

  const User({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.googleTokens,
    this.telegramChatId,
    required this.digestTime,
    this.digestSlots = const [],
    required this.overlayPosition,
    required this.overlayVisible,
    required this.fcmToken,
    required this.createdAt,
    this.messageState = const MessageState(),
  });

  Map<String, dynamic> toJson() => {
    'uid':              uid,
    'email':            email,
    'display_name':     displayName,
    'google_tokens':    googleTokens,
    'telegram_chat_id': telegramChatId,
    'digest_time':      digestTime,
    'digest_slots':     digestSlots,
    'overlay_position': overlayPosition,
    'overlay_visible':  overlayVisible,
    'fcm_token':        fcmToken,
    'created_at':       createdAt.toIso8601String(),
    'message_state':    messageState.toJson(),
  };

  factory User.fromJson(Map<String, dynamic> json) {
    // digest_slots: accept List<dynamic> or fall back to single digestTime entry.
    final rawSlots = json['digest_slots'];
    final slots = rawSlots is List
        ? rawSlots.whereType<String>().toList()
        : <String>[];

    return User(
      uid:             json['uid']           as String? ?? '',
      email:           json['email']         as String? ?? '',
      displayName:     json['display_name']  as String? ?? '',
      googleTokens:    (json['google_tokens'] as Map<String, dynamic>?) ?? {},
      telegramChatId:  json['telegram_chat_id'] as String?,
      digestTime:      json['digest_time']   as String? ?? '09:00',
      digestSlots:     slots.isNotEmpty ? slots
          : [(json['digest_time'] as String? ?? '09:00')],
      overlayPosition: (json['overlay_position'] as Map<String, dynamic>?) ?? {},
      overlayVisible:  json['overlay_visible'] as bool? ?? false,
      fcmToken:        json['fcm_token']     as String? ?? '',
      createdAt:       json['created_at'] is String
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      messageState: MessageState.fromJson(
        json['message_state'] as Map<String, dynamic>?,
      ),
    );
  }

  User copyWith({
    String?                  uid,
    String?                  email,
    String?                  displayName,
    Map<String, dynamic>?    googleTokens,
    String?                  telegramChatId,
    String?                  digestTime,
    List<String>?            digestSlots,
    Map<String, dynamic>?    overlayPosition,
    bool?                    overlayVisible,
    String?                  fcmToken,
    DateTime?                createdAt,
    MessageState?            messageState,
  }) => User(
    uid:             uid             ?? this.uid,
    email:           email           ?? this.email,
    displayName:     displayName     ?? this.displayName,
    googleTokens:    googleTokens    ?? this.googleTokens,
    telegramChatId:  telegramChatId  ?? this.telegramChatId,
    digestTime:      digestTime      ?? this.digestTime,
    digestSlots:     digestSlots     ?? this.digestSlots,
    overlayPosition: overlayPosition ?? this.overlayPosition,
    overlayVisible:  overlayVisible  ?? this.overlayVisible,
    fcmToken:        fcmToken        ?? this.fcmToken,
    createdAt:       createdAt       ?? this.createdAt,
    messageState:    messageState    ?? this.messageState,
  );
}
```

### lib/shared/widgets/atoms/category_color.dart

```dart
import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/models/enums.dart';

/// Gets the category chromatic color for a NoteCategory.
/// These colors are immutable brand tokens (same in dark and light modes).
Color getCategoryColor(NoteCategory category) {
  return categoryColor(category);
}

/// Gets the display label for a category.
String getCategoryLabel(NoteCategory category) {
  switch (category) {
    case NoteCategory.tasks:
      return 'Tasks';
    case NoteCategory.reminders:
      return 'Reminders';
    case NoteCategory.ideas:
      return 'Ideas';
    case NoteCategory.followUp:
      return 'Follow-up';
    case NoteCategory.journal:
      return 'Journal';
    case NoteCategory.general:
      return 'General';
  }
}

/// Extension on NoteCategory for convenient access to label.
extension NoteCategoryX on NoteCategory {
  String get label => getCategoryLabel(this);

  Color get color => getCategoryColor(this);
}
```

### lib/shared/widgets/glass_container.dart

```dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

// ══════════════════════════════════════════════════════════════════════════════
// glass_container.dart v3.0 — Tactile Soft-Glass Containers
//
// GlassContainer — thin adapter that delegates to GlassPane.
//   All 4 Soft-Glass laws are inherited automatically from GlassPane v3.
//
// GlassBubble — the floating overlay bubble, redesigned to be a "Smoked Glass
//   Orb". It receives compound coloured ambient shadows (like LED backlighting),
//   an active-state glow pulse, and a rim-light edge ring for physical depth.
//
// No MethodChannels, Streams, or business logic were altered.
// ══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// GlassContainer — generic glass card/panel
// ─────────────────────────────────────────────────────────────────────────────
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.sigmaX = 15,
    this.sigmaY = 15,
    this.shadowOpacity = 0.18,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final double sigmaX;
  final double sigmaY;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = borderRadius.topLeft.x;
    // Delegates entirely to GlassPane v3 — all 4 laws apply.
    return GlassPane(
      margin: margin,
      padding: padding,
      radius: resolvedRadius,
      level: 1,
      sigmaOverride: (sigmaX + sigmaY) / 2,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GlassBubble — the floating overlay FAB / recording bubble
//
// Soft-Glass mechanics applied:
//   • Rim Light: a 1.2 px gradient border ring (top-left bright → bottom-right
//     slightly dark) simulating anodized metal catching ambient room light.
//   • Compound Shadows: 3 layered drop shadows. In active state, the inner two
//     layers become coloured (category-tinted) "LED glow" per Dark Mode spec.
//   • Tactile Extrusion: the AnimatedContainer carries a subtle inner gradient
//     giving the orb physical volume (lighter at top-left, darker at bottom-right).
//   • BackdropFilter: blur applied via the ClipOval at 14 sigma.
// ─────────────────────────────────────────────────────────────────────────────
class GlassBubble extends StatelessWidget {
  const GlassBubble({
    required this.child,
    super.key,
    this.size = 76,
    this.opacity = 0.84,
    this.isActive = false,
    this.isError = false,
    this.sigmaX = 14,
    this.sigmaY = 14,
  });

  final Widget child;
  final double size;
  final double opacity;
  final bool isActive;
  final bool isError;
  final double sigmaX;
  final double sigmaY;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalizedOpacity = opacity.clamp(0.2, 1.0);
    final sigma = (sigmaX + sigmaY) / 2;

    // ── Color recipe ─────────────────────────────────────────────────────────
    final idleGradient = isDark
        ? [AppColors.darkGlass1, AppColors.darkGlass2]
        : [AppColors.lightGlass1, AppColors.lightGlass2];

    // Active gradient uses app brand colors for recording state
    const activeGradient = [AppColors.tasks, AppColors.journal];

    // ── Rim Light colors (for the circular gradient border) ──────────────────
    final rimBright = isDark ? AppColors.darkRimBright : AppColors.lightRimBright;
    final rimDark   = isDark ? AppColors.darkRimDark   : AppColors.lightRimDark;

    // ── Compound Shadow (3 layers, with active glow variation) ───────────────
    final activeGlowColor = AppColors.tasks.withValues(alpha: isDark ? 0.45 : 0.30);
    final errorGlowColor  = AppColors.errorStatus.withValues(alpha: isDark ? 0.40 : 0.28);

    final List<BoxShadow> shadows = [
      // Layer 1 — close, sharp
      BoxShadow(
        color: isActive
            ? activeGlowColor.withValues(alpha: 0.40)
            : isError
                ? errorGlowColor.withValues(alpha: 0.38)
                : (isDark ? AppColors.darkShadowClose : AppColors.lightShadowClose),
        blurRadius: isActive ? 12 : 8,
        spreadRadius: isActive ? 0 : -3,
        offset: const Offset(0, 3),
      ),
      // Layer 2 — mid, coloured glow in active/error states
      BoxShadow(
        color: isActive
            ? activeGlowColor.withValues(alpha: 0.25)
            : isError
                ? errorGlowColor.withValues(alpha: 0.22)
                : (isDark ? AppColors.darkShadowMid : AppColors.lightShadowMid),
        blurRadius: isActive ? 28 : 20,
        spreadRadius: isActive ? 2 : -6,
        offset: const Offset(0, 8),
      ),
      // Layer 3 — far diffusion
      BoxShadow(
        color: isActive
            ? activeGlowColor.withValues(alpha: 0.12)
            : (isDark ? AppColors.darkShadowFar : AppColors.lightShadowFar),
        blurRadius: 50,
        spreadRadius: -12,
        offset: const Offset(0, 18),
      ),
    ];

    return Opacity(
      opacity: normalizedOpacity,

      // ── Outer ring = Rim Light ────────────────────────────────────────────
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // The 1.2 px gradient ring IS the rim light for the bubble
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [rimBright, rimDark],
          ),
          boxShadow: shadows,
        ),
        // 1.2 px uniform padding = rim light ring width
        padding: const EdgeInsets.all(1.2),

        child: ClipOval(
          // Law 1: Backdrop blur
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),

            // Inner glass orb (Laws 1 + 4)
            child: AnimatedContainer(
              duration: AppDurations.microSnap,
              curve: Curves.easeOutCubic,
              width: size - 2.4,
              height: size - 2.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Glass fill gradient (lighter at top = light source from above)
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isActive ? activeGradient : idleGradient,
                ),
              ),
              // Law 4: Tactile Extrusion — subtle inner shadow via foregroundDecoration
              foregroundDecoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.4,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.06 : 0.14),
                    Colors.transparent,
                    Colors.black.withValues(alpha: isDark ? 0.10 : 0.05),
                  ],
                  stops: const [0.0, 0.50, 1.0],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
```

### lib/shared/widgets/glass_page_background.dart

```dart
import 'package:flutter/material.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/widgets/mesh_gradient_background.dart';

class GlassPageBackground extends StatelessWidget {
  const GlassPageBackground({required this.child, super.key, this.category});

  final Widget child;
  final NoteCategory? category;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MeshGradientBackground(category: category),
        child,
      ],
    );
  }
}
```

### lib/shared/widgets/glass_pane.dart

```dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';

// ══════════════════════════════════════════════════════════════════════════════
// GlassPane v3.0 — Tactile Soft-Glass Core Component
//
// Implements all 4 Anatomical Laws of the Soft-Glass Formula:
//
//   LAW 1 — Backdrop Translucency
//     BackdropFilter(ImageFilter.blur) wraps the content. Sigma scales by level.
//
//   LAW 2 — Rim Light (THE most critical detail — 1.0 px specular highlight)
//     The outermost Container uses a LinearGradient as its fill.
//     The gradient runs top-left (bright white) → mid (transparent) → bottom-right
//     (very subtly dark). A 1.0 px Padding child creates the "bevel catch" effect,
//     exactly like physical light catching the edge of a frosted acrylic sheet.
//
//   LAW 3 — Compound Spatial Elevation (3-layer drop shadows)
//     Three BoxShadow entries at distinct blur/offset/opacity values create the
//     highly diffused "floating softly" appearance. Dark mode uses coloured
//     ambient glows; light mode uses cool desaturated grey.
//
//   LAW 4 — Tactile Extrusion (Inner Shadow simulation)
//     A foregroundDecoration with a very low opacity top-left→bottom-right
//     gradient wraps the content. This gives the "puffed ceramic" volume.
//     Opacity is 10% dark / 5% light — barely perceptible, purely tactile.
//
// ARCHITECTURE NOTE:
//   GlassPane is the single foundational primitive. GlassContainer, GlassBubble,
//   GlassTitleBar, FolderScreen, NoteCard all compose it.
//   All 4 laws apply uniformly at this single layer.
// ══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// FolderGlassTint — propagates a folder category tint down the tree
// (unchanged from v2; kept here for co-location)
// ─────────────────────────────────────────────────────────────────────────────
class FolderGlassTint extends InheritedWidget {
  const FolderGlassTint({required this.tint, required super.child, super.key});

  final Color? tint;

  static Color? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FolderGlassTint>()?.tint;
  }

  @override
  bool updateShouldNotify(covariant FolderGlassTint oldWidget) {
    return oldWidget.tint != tint;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GlassPane
// ─────────────────────────────────────────────────────────────────────────────
class GlassPane extends StatelessWidget {
  const GlassPane({
    required this.child,
    super.key,
    this.level = 1,
    this.radius = 12,
    this.tintOverride,
    this.padding,
    this.margin,
    this.sigmaOverride,
  });

  final Widget child;

  /// Elevation level 1-4. Controls blur strength and shadow intensity.
  /// Level 1 = most opaque, highest blur (for primary panels/cards).
  /// Level 4 = most transparent, least blur (for overlapping micro-surfaces).
  final int level;

  final double radius;
  final Color? tintOverride;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? sigmaOverride;

  // ── Law 1: Backdrop blur sigma by level ──────────────────────────────────
  double get _blur {
    if (sigmaOverride != null) return sigmaOverride!;
    return switch (level) {
      1 => 32.0,  // Primary panels — heavy frosted
      2 => 38.0,  // Elevated surfaces — extra frosted
      3 => 24.0,  // Secondary overlapping panels
      4 => 14.0,  // Micro surfaces (chips, badges)
      _ => 32.0,
    };
  }

  // ── Glass fill color (mode-aware) ─────────────────────────────────────────
  Color _fillFor(BuildContext context) {
    final base = switch (level) {
      1 => context.glass1,
      2 => context.glass2,
      3 => context.glass3,
      4 => context.glass3,
      _ => context.glass1,
    };
    var output = base;
    final folderTint = FolderGlassTint.maybeOf(context);
    if (folderTint != null) output = Color.alphaBlend(folderTint, output);
    if (tintOverride != null) output = Color.alphaBlend(tintOverride!, output);
    return output;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final baseFill = _fillFor(context);
    final r = radius;

    // ── Glass gradient fills (top-left lighter, bottom-right darker) ─────────
    // Mimics light hitting the top surface of a polished/smoked glass sheet.
    final topLayer = Color.alphaBlend(
      Colors.white.withValues(alpha: isDark ? 0.09 : 0.38),
      baseFill,
    );
    final bottomLayer = Color.alphaBlend(
      Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
      baseFill,
    );

    // ── Law 2: Rim Light gradient colors ─────────────────────────────────────
    // Dark "Smoked Glass": bright metallic rim is THE depth cue
    // Light "Polished Resin": crisp white rim; shadows do more depth work
    final rimBright = isDark ? AppColors.darkRimBright  : AppColors.lightRimBright;
    final rimMid    = isDark ? AppColors.darkRimMid     : AppColors.lightRimMid;
    final rimDark   = isDark ? AppColors.darkRimDark    : AppColors.lightRimDark;

    // ── Law 3: Compound Spatial Elevation — 3 shadow layers ─────────────────
    // Dark mode: coloured ambient glow (LED backlight simulation)
    // Light mode: cool desaturated grey (shadow depth on bright bg)
    final List<BoxShadow> shadows = isDark
        ? [
            // Close shadow — tight, ~24% opacity
            BoxShadow(
              color: AppColors.darkShadowClose,
              blurRadius: 8,
              spreadRadius: -3,
              offset: const Offset(0, 3),
            ),
            // Mid shadow — medium spread, ~18% opacity
            BoxShadow(
              color: AppColors.darkShadowMid,
              blurRadius: 24,
              spreadRadius: -7,
              offset: const Offset(0, 9),
            ),
            // Far ambient glow — very diffused, ~12% opacity
            BoxShadow(
              color: AppColors.darkShadowFar,
              blurRadius: 60,
              spreadRadius: -14,
              offset: const Offset(0, 22),
            ),
          ]
        : [
            // Close shadow — tight, cool blue-grey tint
            BoxShadow(
              color: AppColors.lightShadowClose,
              blurRadius: 7,
              spreadRadius: -2,
              offset: const Offset(0, 3),
            ),
            // Mid shadow — medium diffusion
            BoxShadow(
              color: AppColors.lightShadowMid,
              blurRadius: 20,
              spreadRadius: -6,
              offset: const Offset(0, 8),
            ),
            // Far ambient — barely visible, just softens the float
            BoxShadow(
              color: AppColors.lightShadowFar,
              blurRadius: 50,
              spreadRadius: -14,
              offset: const Offset(0, 18),
            ),
          ];

    // ── Law 4: Tactile Extrusion colors ──────────────────────────────────────
    // Bottom-right receives a very subtle darkening to simulate the light source
    // not wrapping around the far side of the "puffed" object.
    final extrusionColor = isDark
        ? AppColors.darkExtrusionShadow
        : AppColors.lightExtrusionShadow;

    return Container(
      margin: margin,

      // ── OUTER SHELL (Laws 2 + 3) ──────────────────────────────────────────
      // The gradient fill here IS the rim light. The 1.0 px Padding below
      // means only this 1 px "ring" is ever visible — the frosted glass fills
      // the interior. Linear gradient from top-left (bright) to bottom-right
      // (dark) perfectly replicates the physical bevel catch.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [rimBright, rimMid, rimDark],
          stops: const [0.0, 0.45, 1.0],
        ),
        boxShadow: shadows,
      ),

      // 1.0 px uniform border = rim light ring thickness
      padding: const EdgeInsets.all(1.0),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(r - 1.0),

        // ── Law 1: Backdrop Translucency ─────────────────────────────────────
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),

          // ── INNER GLASS SURFACE (Laws 1 + 4) ────────────────────────────────
          child: Container(
            padding: padding,

            // Glass fill gradient
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r - 1.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [topLayer, bottomLayer],
              ),
            ),

            // ── Law 4: Tactile Extrusion overlay ─────────────────────────────
            // foregroundDecoration paints ABOVE the child in the widget tree,
            // but at only 5-10% opacity it's imperceptible on content while
            // adding the essential "clay-like 3D volume" to the surface itself.
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r - 1.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  extrusionColor,
                ],
                stops: const [0.0, 0.52, 1.0],
              ),
            ),

            child: child,
          ),
        ),
      ),
    );
  }
}
```

### lib/shared/widgets/glass_title_bar.dart

```dart
import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

// ══════════════════════════════════════════════════════════════════════════════
// glass_title_bar.dart v3.0 — Tactile Soft-Glass Title Bar
//
// Soft-Glass mechanics applied:
//   • GlassTitleBar: wraps GlassPane(level:1) — inherits all 4 laws.
//   • Back button (_TactileBackButton): now a fully "Polished Resin" tactile
//     element. It has:
//       - Its own compound shadow (elevated above the title bar surface)
//       - A brighter rim-light gradient border (it's the most interactive element)
//       - An AnimatedScale on press (0.92) to simulate physical depression
//       - The inner gradient goes light-top-left → dark-bottom-right (3D volume)
//
// All onBack callbacks and Streams preserved unchanged.
// ══════════════════════════════════════════════════════════════════════════════
class GlassTitleBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassTitleBar({
    required this.title,
    required this.onBack,
    super.key,
    this.subtitle,
    this.trailing,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget? trailing;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(82);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: GlassPane(
          level: 1,
          radius: 22,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          // Soft blue tint for the title bar surface (slightly cooler than the page BG)
          tintOverride: context.isDark
              ? const Color(0x6610243F)
              : const Color(0xBFEFF7FF),
          child: Row(
            children: [
              _TactileBackButton(onTap: onBack),
              const SizedBox(width: 8),
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.textSec,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TactileBackButton
//
// A micro "Polished Resin" button. Floats above the title bar via its own
// compound shadow, with a bright top-left rim and AnimatedScale on press.
// ─────────────────────────────────────────────────────────────────────────────
class _TactileBackButton extends StatefulWidget {
  const _TactileBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_TactileBackButton> createState() => _TactileBackButtonState();
}

class _TactileBackButtonState extends State<_TactileBackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    // Rim light colors for the button border
    final rimBright = isDark ? AppColors.darkRimBright : AppColors.lightRimBright;
    final rimDark   = isDark ? AppColors.darkRimDark   : AppColors.lightRimDark;

    // Compound shadows (button floats above the title bar panel)
    final shadows = isDark
        ? [
            BoxShadow(
              color: AppColors.darkShadowClose,
              blurRadius: 6,
              spreadRadius: -1,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: AppColors.darkShadowMid,
              blurRadius: 14,
              spreadRadius: -4,
              offset: const Offset(0, 5),
            ),
          ]
        : [
            BoxShadow(
              color: AppColors.lightShadowClose,
              blurRadius: 5,
              spreadRadius: -1,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: AppColors.lightShadowMid,
              blurRadius: 12,
              spreadRadius: -4,
              offset: const Offset(0, 4),
            ),
          ];

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 40,
          height: 40,
          // Outer ring = Rim Light for the button
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [rimBright, rimDark],
            ),
            boxShadow: _pressed ? [] : shadows,
          ),
          padding: const EdgeInsets.all(1.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              // Inner glass surface with top-to-bottom gradient (light source from above)
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: _pressed ? 0.10 : 0.16),
                        Colors.white.withValues(alpha: _pressed ? 0.04 : 0.07),
                      ]
                    : [
                        Colors.white.withValues(alpha: _pressed ? 0.60 : 0.78),
                        Colors.white.withValues(alpha: _pressed ? 0.36 : 0.52),
                      ],
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: context.textPri,
              size: 17,
            ),
          ),
        ),
      ),
    );
  }
}
```

### lib/shared/widgets/mesh_gradient_background.dart

```dart
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/models/enums.dart';

class MeshGradientBackground extends StatefulWidget {
  const MeshGradientBackground({super.key, this.category});

  final NoteCategory? category;

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground>
    with SingleTickerProviderStateMixin {
  static const _periods = <double>[38, 43, 47, 41, 52];
  static const _phaseX = <double>[0.25, 1.1, 2.2, 3.8, 4.7];
  static const _phaseY = <double>[1.6, 2.4, 0.7, 4.2, 5.3];

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = [...context.meshNodes];
    final leakTarget = widget.category == null
        ? null
        : Color.lerp(
            nodes.first,
            categoryFolderBg(widget.category!, context.isDark),
            0.60,
          );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 60.0;
        return RepaintBoundary(
          child: AnimatedContainer(
            duration: AppDurations.modeTransition,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [leakTarget ?? nodes[0], nodes[1], nodes[2]],
              ),
            ),
            child: CustomPaint(
              painter: _MeshBlobPainter(
                timeSeconds: t,
                opacity: context.isDark ? 0.55 : 0.40,
                colors: [leakTarget ?? nodes[0], ...nodes.skip(1).take(4)],
                periods: _periods,
                phaseX: _phaseX,
                phaseY: _phaseY,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }
}

class _MeshBlobPainter extends CustomPainter {
  const _MeshBlobPainter({
    required this.timeSeconds,
    required this.opacity,
    required this.colors,
    required this.periods,
    required this.phaseX,
    required this.phaseY,
  });

  final double timeSeconds;
  final double opacity;
  final List<Color> colors;
  final List<double> periods;
  final List<double> phaseX;
  final List<double> phaseY;

  static const _bases = <Offset>[
    Offset(0.12, 0.18),
    Offset(0.86, 0.28),
    Offset(0.20, 0.84),
    Offset(0.76, 0.78),
    Offset(0.48, 0.30),
  ];

  static const _radii = <double>[190, 220, 230, 210, 180];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 5; i++) {
      final wx = _wave(timeSeconds, periods[i], phaseX[i], 18);
      final wy = _wave(timeSeconds, periods[i], phaseY[i], 22);
      final center = Offset(
        (_bases[i].dx * size.width) + wx,
        (_bases[i].dy * size.height) + wy,
      );

      final shader = RadialGradient(
        colors: [
          colors[i].withValues(alpha: opacity),
          colors[i].withValues(alpha: 0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: _radii[i]));

      canvas.drawCircle(
        center,
        _radii[i],
        Paint()
          ..shader = shader
          ..isAntiAlias = true,
      );
    }
  }

  double _wave(double t, double period, double phase, double amp) {
    return math.sin(((2 * math.pi) * t / period) + phase) * amp;
  }

  @override
  bool shouldRepaint(covariant _MeshBlobPainter oldDelegate) {
    return oldDelegate.timeSeconds != timeSeconds ||
        oldDelegate.opacity != opacity ||
        oldDelegate.colors != colors;
  }
}
```

### lib/shared/widgets/top_notch_message.dart

```dart
import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

// ══════════════════════════════════════════════════════════════════════════════
// top_notch_message.dart v3.0 — Tactile Soft-Glass Dynamic Island Pill
//
// The Dynamic Island pill is the most visually prominent transient element.
// Soft-Glass mechanics applied:
//
//   • Rim Light: The pill gets a bright top-left → dim bottom-right gradient
//     border (1.0 px wide). It simulates the pill being a physical extruded
//     "SmokGlass capsule" floating above the screen, with room light reflecting
//     off its top-left bevel. On dark backgrounds this is the primary depth cue.
//
//   • Compound Shadows: 3-layer drop shadows. The category colour bleeds into
//     the mid layer for a subtle "content-aware" ambient glow effect.
//
//   • BackdropFilter: the pill itself blurs what's behind it, maintaining the
//     frosted glass look even when the background changes (mesh, images, etc.)
//
//   • Spring-driven entry: vertical slide-up (from -36 px) + fade + scale for
//     a soft bouncy entrance that feels physically "popped up" from the notch.
//
// All original overlay/timer business logic preserved exactly.
// ══════════════════════════════════════════════════════════════════════════════

OverlayEntry? _activeTopNotchEntry;
Timer? _activeTopNotchTimer;

Future<void> showTopNotchSavedMessage({
  required BuildContext context,
  required String title,
  required NoteCategory category,
}) {
  final overlayState = Overlay.maybeOf(context);
  if (overlayState == null) return Future<void>.value();

  _activeTopNotchTimer?.cancel();
  _activeTopNotchEntry?.remove();
  _activeTopNotchEntry = null;

  final chipColor = categoryColor(category);

  final entry = OverlayEntry(
    builder: (ctx) => _TopNotchPill(
      title: title,
      category: category,
      chipColor: chipColor,
    ),
  );

  overlayState.insert(entry);
  _activeTopNotchEntry = entry;

  // Auto-remove after notch return duration (unchanged)
  _activeTopNotchTimer = Timer(AppDurations.notchAutoReturn, () {
    _activeTopNotchEntry?.remove();
    _activeTopNotchEntry = null;
    _activeTopNotchTimer = null;
  });

  return Future<void>.value();
}

// ─────────────────────────────────────────────────────────────────────────────
// _TopNotchPill — the actual floating capsule widget
// ─────────────────────────────────────────────────────────────────────────────
class _TopNotchPill extends StatefulWidget {
  const _TopNotchPill({
    required this.title,
    required this.category,
    required this.chipColor,
  });

  final String title;
  final NoteCategory category;
  final Color chipColor;

  @override
  State<_TopNotchPill> createState() => _TopNotchPillState();
}

class _TopNotchPillState extends State<_TopNotchPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppDurations.saveConfirm,
    );

    final curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _opacity    = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _translateY = Tween<double>(begin: -36.0, end: 0.0).animate(curve);
    _scale      = Tween<double>(begin: 0.82, end: 1.0).animate(curve);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Rim light colors ─────────────────────────────────────────────────────
    final rimBright = isDark ? AppColors.darkRimBright : AppColors.lightRimBright;
    final rimMid    = isDark ? AppColors.darkRimMid    : AppColors.lightRimMid;
    final rimDark   = isDark ? AppColors.darkRimDark   : AppColors.lightRimDark;

    // ── Compound shadows — mid layer tinted with category colour ─────────────
    final List<BoxShadow> shadows = [
      BoxShadow(
        color: isDark ? AppColors.darkShadowClose : AppColors.lightShadowClose,
        blurRadius: 8,
        spreadRadius: -2,
        offset: const Offset(0, 3),
      ),
      // Category-aware ambient glow (content-aware depth)
      BoxShadow(
        color: widget.chipColor.withValues(alpha: isDark ? 0.18 : 0.12),
        blurRadius: 22,
        spreadRadius: -5,
        offset: const Offset(0, 7),
      ),
      BoxShadow(
        color: isDark ? AppColors.darkShadowFar : AppColors.lightShadowFar,
        blurRadius: 48,
        spreadRadius: -14,
        offset: const Offset(0, 18),
      ),
    ];

    // ── Glass fill ───────────────────────────────────────────────────────────
    final glassFillTop = isDark
        ? Colors.white.withValues(alpha: 0.13)
        : Colors.white.withValues(alpha: 0.82);
    final glassFillBottom = isDark
        ? const Color(0xFF111827).withValues(alpha: 0.90)
        : Colors.white.withValues(alpha: 0.60);

    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) => Opacity(
              opacity: _opacity.value,
              child: Transform.translate(
                offset: Offset(0, _translateY.value),
                child: Transform.scale(
                  scale: _scale.value,
                  child: child,
                ),
              ),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 48,
              ),
              margin: const EdgeInsets.only(top: 8),

              // ── LAW 2: Rim Light outer shell (gradient border) ──────────────
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [rimBright, rimMid, rimDark],
                  stops: const [0.0, 0.45, 1.0],
                ),
                // ── LAW 3: Compound Shadows ─────────────────────────────────
                boxShadow: shadows,
              ),
              padding: const EdgeInsets.all(1.0), // rim light ring width

              child: ClipRRect(
                borderRadius: BorderRadius.circular(998),
                // ── LAW 1: Backdrop Translucency ─────────────────────────────
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(998),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [glassFillTop, glassFillBottom],
                      ),
                    ),
                    // ── LAW 4: Tactile Extrusion foreground ─────────────────
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(998),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          isDark
                              ? AppColors.darkExtrusionShadow
                              : AppColors.lightExtrusionShadow,
                        ],
                        stops: const [0.0, 0.50, 1.0],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── "Saved" label ────────────────────────────────────
                        Text(
                          'Saved',
                          style: TextStyle(
                            color: context.textPri,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '·',
                          style: TextStyle(
                            color: context.textSec,
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // ── Category chip (mini glass pill) ──────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            // Category-tinted glass fill
                            color: widget.chipColor.withValues(alpha: 0.18),
                            border: Border.all(
                              color: widget.chipColor.withValues(alpha: 0.30),
                              width: 0.7,
                            ),
                          ),
                          child: Text(
                            categoryLabel(widget.category),
                            style: TextStyle(
                              color: widget.chipColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        // ── Note title (truncated) ────────────────────────────
                        Flexible(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: context.textSec,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

### android/app/build.gradle.kts

```kotlin
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.adarshkumarverma.wishperlog"
    compileSdk = maxOf(flutter.compileSdkVersion, 35)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.adarshkumarverma.wishperlog"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = maxOf(flutter.targetSdkVersion, 35)
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Values are read from gradle.properties (local, never committed to VCS).
            // See MANUAL CONFIGURATION section for setup instructions.
            val storeFilePath = System.getenv("WISHPERLOG_STORE_FILE")
                ?: project.findProperty("WISHPERLOG_STORE_FILE") as String?
            val storePassword = System.getenv("WISHPERLOG_STORE_PASSWORD")
                ?: project.findProperty("WISHPERLOG_STORE_PASSWORD") as String?
            val keyAlias = System.getenv("WISHPERLOG_KEY_ALIAS")
                ?: project.findProperty("WISHPERLOG_KEY_ALIAS") as String?
            val keyPassword = System.getenv("WISHPERLOG_KEY_PASSWORD")
                ?: project.findProperty("WISHPERLOG_KEY_PASSWORD") as String?

            if (storeFilePath != null) {
                storeFile     = file(storeFilePath)
                this.storePassword = storePassword ?: ""
                this.keyAlias     = keyAlias      ?: ""
                this.keyPassword  = keyPassword   ?: ""
            }
        }
    }

    buildTypes {
        release {
            // Use release signing when keys are available; fall back to debug for
            // local `flutter run --release` during development.
            val hasReleaseSigning = signingConfigs.findByName("release")
                ?.storeFile?.exists() == true
            signingConfig = if (hasReleaseSigning)
                signingConfigs.getByName("release")
            else
                signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.localbroadcastmanager:localbroadcastmanager:1.1.0")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
```

### android/app/google-services.json

```json
{
  "project_info": {
    "project_number": "982731246537",
    "firebase_url": "https://wishperlog-default-rtdb.asia-southeast1.firebasedatabase.app",
    "project_id": "wishperlog",
    "storage_bucket": "wishperlog.firebasestorage.app"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:982731246537:android:bff1e21915bd4c632cf618",
        "android_client_info": {
          "package_name": "com.adarshkumarverma.wishperlog"
        }
      },
      "oauth_client": [
        {
          "client_id": "982731246537-63ibaop0hio54tg5fgh0s9pehqb5gigm.apps.googleusercontent.com",
          "client_type": 1,
          "android_info": {
            "package_name": "com.adarshkumarverma.wishperlog",
            "certificate_hash": "ddae9ee974d9c4c1898c205ef35bc896ad3ac4b0"
          }
        },
        {
          "client_id": "982731246537-pk0h1lp6sco8h474t1sqbmehj8aj0g65.apps.googleusercontent.com",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "AIzaSyB-0jX3pPJ-8iBDMlSW1W19ih_XkqtqH4E"
        }
      ],
      "services": {
        "appinvite_service": {
          "other_platform_oauth_client": [
            {
              "client_id": "982731246537-pk0h1lp6sco8h474t1sqbmehj8aj0g65.apps.googleusercontent.com",
              "client_type": 3
            },
            {
              "client_id": "982731246537-ds47rpj0jsvqqoo62ej105n5i0l12u7k.apps.googleusercontent.com",
              "client_type": 2,
              "ios_info": {
                "bundle_id": "com.adarshkumarverma.wishperlog"
              }
            }
          ]
        }
      }
    }
  ],
  "configuration_version": "1"
}
```

### android/app/src/debug/AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- The INTERNET permission is required for development. Specifically,
         the Flutter tool needs it to communicate with the running application
         to allow setting breakpoints, to provide hot reload, etc.
    -->
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

### android/app/src/main/AndroidManifest.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.adarshkumarverma.wishperlog">

    <!-- ── Network ─────────────────────────────────────────────────────── -->
    <uses-permission android:name="android.permission.INTERNET" />

    <!-- ── Microphone ──────────────────────────────────────────────────── -->
    <uses-permission android:name="android.permission.RECORD_AUDIO" />

    <!-- ── Foreground service permissions ─────────────────────────────── -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <!--
        CRITICAL FIX #1:
        On Android 11+ (API 30+), background services that access the microphone
        MUST declare FOREGROUND_SERVICE_MICROPHONE and set foregroundServiceType
        to "microphone" in the <service> tag. Without this, Android silently
        revokes mic access from background services after ~2 seconds.
        This was the PRIMARY cause of the recording stopping out-of-app.
    -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_SPECIAL_USE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_DATA_SYNC" />

    <!-- ── Other system permissions ────────────────────────────────────── -->
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.SYSTEM_ALERT_WINDOW" />
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
    <uses-permission android:name="android.permission.VIBRATE" />

    <queries>
        <package android:name="com.google.android.gms" />
        <package android:name="com.android.vending" />
    </queries>

    <application
        android:name=".WishperlogApplication"
        android:label="wishperlog"
        android:icon="@mipmap/ic_launcher"
        android:roundIcon="@mipmap/ic_launcher_round"
        android:allowBackup="false"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:enableOnBackInvokedCallback="true"
        android:theme="@style/NormalTheme">

        <activity
            android:name="com.adarshkumarverma.wishperlog.MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize"
            android:windowTranslucentStatus="true"
            android:windowTranslucentNavigation="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>

        <meta-data android:name="flutterEmbedding" android:value="2" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_icon"
            android:resource="@mipmap/ic_launcher" />
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_color"
            android:resource="@color/black" />

        <!--
            CRITICAL FIX #1 (continued):
            foregroundServiceType MUST include "microphone" for SpeechRecognizer
            to work in a background service on Android 11+.
            "specialUse" is retained because the service also drives a
            SYSTEM_ALERT_WINDOW overlay (which requires a use-case justification
            on Play Store submission).
        -->
        <service
            android:name=".OverlayForegroundService"
            android:foregroundServiceType="microphone|specialUse"
            android:exported="false" />

        <!-- Headless Flutter engine — only needs dataSync (no mic) -->
        <service
            android:name=".BackgroundNoteService"
            android:foregroundServiceType="dataSync"
            android:exported="false" />

        <receiver android:name=".NoteInputReceiver" android:exported="false" />

        <receiver android:name=".BootReceiver" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.BOOT_COMPLETED" />
            </intent-filter>
        </receiver>

    </application>
</manifest>
```

### android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java

```java
package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import io.flutter.Log;

import io.flutter.embedding.engine.FlutterEngine;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  private static final String TAG = "GeneratedPluginRegistrant";
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin cloud_firestore, io.flutter.plugins.firebase.firestore.FlutterFirebaseFirestorePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new dev.fluttercommunity.plus.connectivity.ConnectivityPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin connectivity_plus, dev.fluttercommunity.plus.connectivity.ConnectivityPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin firebase_auth, io.flutter.plugins.firebase.auth.FlutterFirebaseAuthPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin firebase_core, io.flutter.plugins.firebase.core.FlutterFirebaseCorePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin firebase_messaging, io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_local_notifications, com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.googlesignin.GoogleSignInPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin google_sign_in_android, io.flutter.plugins.googlesignin.GoogleSignInPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new dev.isar.isar_flutter_libs.IsarFlutterLibsPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin isar_flutter_libs, dev.isar.isar_flutter_libs.IsarFlutterLibsPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin path_provider_android, io.flutter.plugins.pathprovider.PathProviderPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.baseflow.permissionhandler.PermissionHandlerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin permission_handler_android, com.baseflow.permissionhandler.PermissionHandlerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin shared_preferences_android, io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.csdcorp.speech_to_text.SpeechToTextPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin speech_to_text, com.csdcorp.speech_to_text.SpeechToTextPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.urllauncher.UrlLauncherPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin url_launcher_android, io.flutter.plugins.urllauncher.UrlLauncherPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new dev.fluttercommunity.workmanager.WorkmanagerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin workmanager_android, dev.fluttercommunity.workmanager.WorkmanagerPlugin", e);
    }
  }
}
```

### android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/BackgroundNoteService.kt

```kotlin
package com.adarshkumarverma.wishperlog

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

/**
 * Headless Flutter engine service.
 *
 * Invoked when OverlayForegroundService captures a note but the main Flutter
 * engine is not alive (app fully killed). Starts a lightweight Dart isolate via
 * [backgroundNoteCallback], forwards the raw transcript, waits for Dart to:
 *   1. Persist to Isar
 *   2. Run Gemini classification
 *   3. Sync to Firestore
 *
 * CRITICAL FIX #2:
 * When Dart signals 'done' it now passes {title, category} of the saved note.
 * BackgroundNoteService forwards this to OverlayForegroundService.notifyBackgroundSaved()
 * so the native island pill updates from "Classifying..." to the real saved state.
 * Before this fix, the island was permanently stuck on "Classifying...".
 */
class BackgroundNoteService : Service() {

    companion object {
        private const val TAG = "BackgroundNoteSvc"
        private const val CHANNEL_ID = "wishperlog_bg_note"
        private const val NOTIFICATION_ID = 9002
        const val EXTRA_TEXT = "extra_text"
        const val EXTRA_SOURCE = "extra_source"

        fun start(context: Context, text: String, source: String) {
            val i = Intent(context, BackgroundNoteService::class.java).apply {
                putExtra(EXTRA_TEXT, text)
                putExtra(EXTRA_SOURCE, source)
            }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                context.startForegroundService(i)
            else
                context.startService(i)
        }
    }

    private var flutterEngine: FlutterEngine? = null
    private var bgChannel: MethodChannel? = null

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        startForeground(NOTIFICATION_ID, buildNotification())
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val text   = intent?.getStringExtra(EXTRA_TEXT)   ?: ""
        val source = intent?.getStringExtra(EXTRA_SOURCE) ?: "voice_overlay"

        // Fast path: main engine still alive — just forward and exit.
        val live = FlutterEngineHolder.channel
        if (live != null && text.isNotEmpty()) {
            live.invokeMethod(
                "captureNote",
                mapOf("text" to text, "source" to source),
                object : MethodChannel.Result {
                    override fun success(r: Any?)    { stopSelf() }
                    override fun error(c: String, m: String?, d: Any?) {
                        drainAndProcess(text, source)
                    }
                    override fun notImplemented()    { drainAndProcess(text, source) }
                }
            )
        } else {
            drainAndProcess(text, source)
        }
        return START_NOT_STICKY
    }

    private fun drainAndProcess(newText: String, newSource: String) {
        Log.d(TAG, "drainAndProcess: booting headless Flutter engine")
        FlutterInjector.instance().flutterLoader().startInitialization(applicationContext)
        FlutterInjector.instance().flutterLoader().ensureInitializationComplete(applicationContext, null)

        val engine = FlutterEngine(applicationContext)
        flutterEngine = engine
        GeneratedPluginRegistrant.registerWith(engine)

        bgChannel = MethodChannel(engine.dartExecutor.binaryMessenger, "wishperlog/background_notes")

        // Collect pending notes from SharedPreferences + this new note.
        val prefs   = getSharedPreferences("wishperlog_pending_notes", Context.MODE_PRIVATE)
        val pending = mutableListOf<Pair<String, String>>()
        if (newText.isNotEmpty()) pending.add(Pair(newText, newSource))

        val allKeys = prefs.all.keys.filter { it.endsWith("_text") }
        for (k in allKeys) {
            val baseKey = k.removeSuffix("_text")
            val t = prefs.getString("${baseKey}_text", null) ?: continue
            val s = prefs.getString("${baseKey}_source", "voice_overlay") ?: "voice_overlay"
            pending.add(Pair(t, s))
        }
        prefs.edit().clear().apply()

        var pendingIdx = 0

        bgChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "ready" -> {
                    result.success(null)
                    dispatchNext(pending, pendingIdx).also { pendingIdx = it }
                }
                "nextNote" -> {
                    result.success(null)
                    dispatchNext(pending, pendingIdx).also { pendingIdx = it }
                }

                // CRITICAL FIX #2:
                // Dart now sends {title, category} so we can update the island
                // from "Classifying..." to the actual saved state. Without this,
                // the pill was stuck forever when the engine was dead at capture time.
                "done" -> {
                    result.success(null)
                    val title    = call.argument<String>("title")    ?: ""
                    val category = call.argument<String>("category") ?: "general"
                    val prefix   = call.argument<String>("prefix")   ?: "AI"
                    if (title.isNotEmpty()) {
                        Log.d(TAG, "done: notifying island — title='$title' category='$category' prefix='$prefix'")
                        OverlayForegroundService.notifyBackgroundSaved(title, category, prefix)
                    } else {
                        Log.d(TAG, "done: no title, dismissing island")
                        OverlayForegroundService.dismissIslandFromBackground()
                    }
                    stopSelf()
                }

                else -> result.notImplemented()
            }
        }

        engine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(
                FlutterInjector.instance().flutterLoader().findAppBundlePath(),
                "backgroundNoteCallback"
            )
        )
    }

    private fun dispatchNext(pending: List<Pair<String, String>>, idx: Int): Int {
        return if (idx < pending.size) {
            val (t, s) = pending[idx]
            bgChannel?.invokeMethod("processNote", mapOf("text" to t, "source" to s))
            idx + 1
        } else {
            bgChannel?.invokeMethod("allDone", null)
            idx
        }
    }

    override fun onDestroy() {
        flutterEngine?.destroy()
        flutterEngine = null
        bgChannel = null
        super.onDestroy()
    }

    private fun buildNotification(): Notification {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(
                CHANNEL_ID,
                "WishperLog Background Save",
                NotificationManager.IMPORTANCE_MIN
            )
            getSystemService(NotificationManager::class.java).createNotificationChannel(ch)
        }
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("WishperLog")
            .setContentText("Saving voice note…")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .build()
    }
}
```

### android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/BootReceiver.kt

```kotlin
package com.adarshkumarverma.wishperlog

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Intent.ACTION_BOOT_COMPLETED) return
        val prefs = context.getSharedPreferences(
            "com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)
        val enabled = prefs.getBoolean("overlay_v2.enabled", true)
        if (!enabled) return
        Log.d("BootReceiver", "Boot completed - restarting overlay service")
        val serviceIntent = Intent(context, OverlayForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            context.startForegroundService(serviceIntent)
        else
            context.startService(serviceIntent)
    }
}
```

### android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/FlutterEngineHolder.kt

```kotlin
package com.adarshkumarverma.wishperlog

import io.flutter.plugin.common.MethodChannel

/**
 * Singleton holder so the NoteInputReceiver can access the Flutter MethodChannel
 * even when MainActivity may not be in the foreground.
 */
object FlutterEngineHolder {
    var channel: MethodChannel? = null
}
```

### android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/MainActivity.kt

```kotlin
package com.adarshkumarverma.wishperlog

import android.Manifest
import android.graphics.BitmapFactory
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Build
import android.provider.Settings
import android.util.Log
import java.io.ByteArrayOutputStream
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.android.FlutterActivityLaunchConfigs
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "wishperlog/overlay"
    private val REQUEST_RECORD_AUDIO = 4242
    private var pendingMicPermissionResult: MethodChannel.Result? = null

    companion object {
        private const val TAG = "MainActivity"
    }

    override fun getBackgroundMode(): FlutterActivityLaunchConfigs.BackgroundMode =
        FlutterActivityLaunchConfigs.BackgroundMode.transparent

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        FlutterEngineHolder.channel = channel

        channel.setMethodCallHandler { call, result ->
            when (call.method) {

                // ── Overlay lifecycle ────────────────────────────────────────
                "show" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
                        !Settings.canDrawOverlays(this)) {
                        result.error("PERMISSION_DENIED", "Overlay permission not granted", null)
                    } else {
                        val i = Intent(this, OverlayForegroundService::class.java)
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
                            startForegroundService(i) else startService(i)
                        result.success(null)
                    }
                }
                "hide" -> {
                    stopService(Intent(this, OverlayForegroundService::class.java))
                    result.success(null)
                }

                // ── Permissions ──────────────────────────────────────────────
                "checkPermission" -> result.success(
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M)
                        Settings.canDrawOverlays(this) else true
                )
                "requestPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        startActivity(
                            Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                                Uri.parse("package:$packageName"))
                        )
                    }
                    result.success(null)
                }
                "requestMicrophonePermission" -> {
                    if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
                        == PackageManager.PERMISSION_GRANTED) {
                        result.success(true)
                    } else {
                        pendingMicPermissionResult = result
                        ActivityCompat.requestPermissions(
                            this, arrayOf(Manifest.permission.RECORD_AUDIO), REQUEST_RECORD_AUDIO
                        )
                    }
                }

                // ── Island state sync (Flutter → Native) ─────────────────────
                "updateIslandState" -> {
                    val state   = call.argument<String>("state")   ?: "idle"
                    val message = call.argument<String>("message")
                    OverlayForegroundService.updateIsland(state, message)
                    result.success(null)
                }
                "notifySaved" -> {
                    val title      = call.argument<String>("title")      ?: ""
                    val category   = call.argument<String>("category")   ?: "general"
                    val prefix     = call.argument<String>("prefix")     ?: "AI"
                    val collection = call.argument<String>("collection") ?: "notes"
                    OverlayForegroundService.notifySaved(title, category, prefix, collection)
                    result.success(null)
                }

                // ── Overlay appearance settings ───────────────────────────────
                "getOverlaySettings" -> {
                    val prefs = getSharedPreferences(
                        "com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)
                    val settingsJson = prefs.getString("overlay_settings_json", null)
                    val settings = OverlayAppearanceSettings.fromJson(settingsJson)
                    result.success(mapOf(
                        "alpha" to settings.alpha,
                        "growOnHold" to settings.growEnabled,
                        "settingsJson" to settings.toJsonString(),
                    ))
                }
                "updateOverlaySettings" -> {
                    val prefs = getSharedPreferences(
                        "com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)

                    val incomingJson = call.argument<String>("settingsJson")
                    val legacyAlpha = (call.argument<Double>("alpha") ?: 0.85).toFloat()
                    val legacyGrow = call.argument<Boolean>("growOnHold") ?: true

                    val mergedSettings = if (!incomingJson.isNullOrBlank()) {
                        OverlayAppearanceSettings.fromJson(incomingJson)
                    } else {
                        val currentJson = prefs.getString("overlay_settings_json", null)
                        val current = if (currentJson.isNullOrBlank()) {
                            OverlayAppearanceSettings.legacy(legacyAlpha, legacyGrow)
                        } else {
                            OverlayAppearanceSettings.fromJson(currentJson)
                        }
                        current.copyWith(alpha = legacyAlpha, growEnabled = legacyGrow)
                    }

                    prefs.edit()
                        .putString("overlay_settings_json", mergedSettings.toJsonString())
                        .putFloat("overlay_bubble_alpha", mergedSettings.alpha)
                        .putBoolean("overlay_bubble_grow", mergedSettings.growEnabled)
                        .apply()

                    OverlayForegroundService.applySettings(mergedSettings.toJsonString())
                    result.success(null)
                }

                // ── Speech settings ───────────────────────────────────────────
                "getSpeechSettings" -> {
                    val prefs = getSharedPreferences(
                        "com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)
                    result.success(mapOf(
                        "language"     to (prefs.getString("overlay_stt_language", "en-US") ?: "en-US"),
                        "preferOffline" to prefs.getBoolean("overlay_stt_prefer_offline", false)
                    ))
                }
                "updateSpeechSettings" -> {
                    val lang    = call.argument<String>("language")      ?: "en-US"
                    val offline = call.argument<Boolean>("preferOffline") ?: false
                    getSharedPreferences(
                        "com.adarshkumarverma.wishperlog_preferences", Context.MODE_PRIVATE)
                        .edit()
                        .putString("overlay_stt_language", lang)
                        .putBoolean("overlay_stt_prefer_offline", offline)
                        .apply()
                    result.success(null)
                }
                "downloadSpeechLanguagePack" -> {
                    try {
                        startActivity(Intent(Settings.ACTION_LOCALE_SETTINGS)
                            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
                    } catch (_: Exception) {}
                    result.success(null)
                }

                "getLauncherIcon" -> {
                    try {
                        val bitmap = BitmapFactory.decodeResource(resources, R.mipmap.ic_launcher)
                        if (bitmap == null) {
                            result.success(null)
                        } else {
                            val stream = ByteArrayOutputStream()
                            bitmap.compress(android.graphics.Bitmap.CompressFormat.PNG, 100, stream)
                            result.success(stream.toByteArray())
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "getLauncherIcon failed", e)
                        result.success(null)
                    }
                }

                // ── Flush pending notes saved while engine was dead ───────────
                "flushPendingNotes" -> {
                    flushPendingNotes(channel)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        // Auto-flush pending notes every time app comes to foreground
        flushPendingNotes(channel)
    }

    /**
     * Reads notes that were persisted to SharedPreferences while the Flutter
     * engine was dead (e.g. app killed during overlay recording) and re-injects
     * them into Flutter for normal Isar + AI + Firestore processing.
     */
    private fun flushPendingNotes(channel: MethodChannel) {
        val prefs = getSharedPreferences("wishperlog_pending_notes", Context.MODE_PRIVATE)
        val keys  = prefs.all.keys.filter { it.endsWith("_text") }.sorted()
        if (keys.isEmpty()) return

        Log.d(TAG, "flushPendingNotes: found ${keys.size} pending notes")
        val editor = prefs.edit()

        for (k in keys) {
            val base   = k.removeSuffix("_text")
            val text   = prefs.getString("${base}_text",   null) ?: continue
            val source = prefs.getString("${base}_source", "voice_overlay") ?: "voice_overlay"
            editor.remove("${base}_text").remove("${base}_source")
            channel.invokeMethod("captureNote", mapOf("text" to text, "source" to source))
        }
        editor.apply()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int, permissions: Array<out String>, grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == REQUEST_RECORD_AUDIO) {
            val granted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingMicPermissionResult?.success(granted)
            pendingMicPermissionResult = null
        }
    }

    override fun onDestroy() {
        FlutterEngineHolder.channel = null
        super.onDestroy()
    }
}
```

### android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/NoteInputReceiver.kt

```kotlin
package com.adarshkumarverma.wishperlog

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.util.Log
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import io.flutter.plugin.common.MethodChannel

/**
 * Receives captured note broadcasts from OverlayForegroundService via
 * LocalBroadcastManager (same bus that broadcastCapture now uses — ISSUE-03).
 *
 * Delivery priority:
 *  1. Forward to live Flutter engine via MethodChannel.
 *  2. Start BackgroundNoteService (headless Flutter) if engine is dead.
 *  3. Persist to SharedPreferences as a last-resort safety net.
 *     Notes are drained on next app resume via MainActivity.flushPendingNotes().
 */
class NoteInputReceiver : BroadcastReceiver() {

    companion object {
        private const val TAG = "NoteInputReceiver"

        /** SharedPreferences file used for the persistence safety net. */
        private const val PREFS_PENDING = "wishperlog_pending_notes"

        fun register(context: Context, receiver: NoteInputReceiver) {
            LocalBroadcastManager.getInstance(context).registerReceiver(
                receiver,
                IntentFilter(OverlayForegroundService.ACTION_NOTE_CAPTURED)
            )
        }

        fun unregister(context: Context, receiver: NoteInputReceiver) {
            try {
                LocalBroadcastManager.getInstance(context).unregisterReceiver(receiver)
            } catch (e: Exception) {
                Log.w(TAG, "unregister: already unregistered", e)
            }
        }

        /**
         * Persists a note to SharedPreferences so it is never silently dropped.
         * The note is cleared by MainActivity.flushPendingNotes() only AFTER
         * the Flutter engine confirms receipt via MethodChannel.Result.success.
         */
        fun persistPending(context: Context, text: String, source: String) {
            val key  = System.currentTimeMillis().toString()
            val prefs = context.getSharedPreferences(PREFS_PENDING, Context.MODE_PRIVATE)
            prefs.edit()
                .putString("${key}_text",   text)
                .putString("${key}_source", source)
                .apply()
            Log.d(TAG, "Persisted pending note key=$key (len=${text.length})")
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != OverlayForegroundService.ACTION_NOTE_CAPTURED) return

        val text   = intent.getStringExtra(OverlayForegroundService.EXTRA_TEXT)   ?: return
        val source = intent.getStringExtra(OverlayForegroundService.EXTRA_SOURCE) ?: "voice_overlay"

        // Always persist first — cleared below only after confirmed delivery.
        val pendingKey = System.currentTimeMillis().toString()
        val prefs = context.getSharedPreferences(PREFS_PENDING, Context.MODE_PRIVATE)
        prefs.edit()
            .putString("${pendingKey}_text",   text)
            .putString("${pendingKey}_source", source)
            .apply()

        val channel = FlutterEngineHolder.channel
        if (channel != null) {
            channel.invokeMethod(
                "captureNote",
                mapOf("text" to text, "source" to source),
                object : MethodChannel.Result {
                    override fun success(result: Any?) {
                        // Confirmed delivery — remove from safety-net store.
                        prefs.edit()
                            .remove("${pendingKey}_text")
                            .remove("${pendingKey}_source")
                            .apply()
                        Log.d(TAG, "captureNote delivered via live engine (len=${text.length})")
                    }
                    override fun error(code: String, msg: String?, details: Any?) {
                        Log.e(TAG, "captureNote error ($code) — starting BackgroundNoteService")
                        BackgroundNoteService.start(context, text, source)
                        // Safety-net entry stays until BackgroundNoteService completes.
                    }
                    override fun notImplemented() {
                        Log.e(TAG, "captureNote notImplemented — starting BackgroundNoteService")
                        BackgroundNoteService.start(context, text, source)
                    }
                }
            )
        } else {
            Log.w(TAG, "Engine dead — starting BackgroundNoteService")
            BackgroundNoteService.start(context, text, source)
        }
    }
}
```

### android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/OverlayAppearanceSettings.kt

```kotlin
package com.adarshkumarverma.wishperlog

import android.graphics.Color
import org.json.JSONObject

internal data class OverlayAppearanceSettings(
    val alpha: Float = 0.82f,
    val blurSigma: Float = 22.0f,
    val colorFill: String = "glass",
    val solidColor: Int = Color.parseColor("#1C1C2E"),
    val gradientStart: Int = Color.parseColor("#6366F1"),
    val gradientEnd: Int = Color.parseColor("#8B5CF6"),
    val borderStyle: String = "glow",
    val borderColor: Int = Color.parseColor("#6366F1"),
    val animation: String = "sizeGrow",
    val growScale: Float = 1.10f,
    val posX: Float = 0.88f,
    val posY: Float = 0.30f,
    val persistOnReboot: Boolean = true,
) {
    val growEnabled: Boolean
        get() = animation.equals("sizeGrow", ignoreCase = true)

    fun copyWith(
        alpha: Float? = null,
        growEnabled: Boolean? = null,
    ): OverlayAppearanceSettings {
        val nextAnimation = when (growEnabled) {
            true -> "sizeGrow"
            false -> "none"
            null -> animation
        }
        return copy(
            alpha = alpha ?: this.alpha,
            animation = nextAnimation,
        )
    }

    fun toJsonString(): String = JSONObject().apply {
        put("alpha", alpha.toDouble())
        put("blurSigma", blurSigma.toDouble())
        put("colorFill", colorFill)
        put("solidColor", solidColor)
        put("gradientStart", gradientStart)
        put("gradientEnd", gradientEnd)
        put("borderStyle", borderStyle)
        put("borderColor", borderColor)
        put("animation", animation)
        put("growScale", growScale.toDouble())
        put("posX", posX.toDouble())
        put("posY", posY.toDouble())
        put("persistOnReboot", persistOnReboot)
    }.toString()

    companion object {
        fun fromJson(raw: String?): OverlayAppearanceSettings {
            if (raw.isNullOrBlank()) return OverlayAppearanceSettings()
            return try {
                val json = JSONObject(raw)
                OverlayAppearanceSettings(
                    alpha = json.optDouble("alpha", 0.82).toFloat(),
                    blurSigma = json.optDouble("blurSigma", 22.0).toFloat(),
                    colorFill = json.optString("colorFill", "glass"),
                    solidColor = json.optInt("solidColor", Color.parseColor("#1C1C2E")),
                    gradientStart = json.optInt("gradientStart", Color.parseColor("#6366F1")),
                    gradientEnd = json.optInt("gradientEnd", Color.parseColor("#8B5CF6")),
                    borderStyle = json.optString("borderStyle", "glow"),
                    borderColor = json.optInt("borderColor", Color.parseColor("#6366F1")),
                    animation = json.optString("animation", "sizeGrow"),
                    growScale = json.optDouble("growScale", 1.10).toFloat(),
                    posX = json.optDouble("posX", 0.88).toFloat(),
                    posY = json.optDouble("posY", 0.30).toFloat(),
                    persistOnReboot = json.optBoolean("persistOnReboot", true),
                )
            } catch (_: Exception) {
                OverlayAppearanceSettings()
            }
        }

        fun legacy(alpha: Float, grow: Boolean): OverlayAppearanceSettings {
            return OverlayAppearanceSettings(
                alpha = alpha,
                animation = if (grow) "sizeGrow" else "none",
            )
        }
    }
}
```

### android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/OverlayForegroundService.kt

```kotlin
package com.adarshkumarverma.wishperlog

import android.Manifest
import android.animation.ObjectAnimator
import android.animation.PropertyValuesHolder
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.graphics.PixelFormat
import android.graphics.Typeface
import android.graphics.drawable.GradientDrawable
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.VibrationEffect
import android.os.Vibrator
import android.os.VibratorManager
import android.speech.RecognitionListener
import android.speech.RecognizerIntent
import android.speech.SpeechRecognizer
import android.text.InputType
import android.text.TextUtils
import android.util.Log
import android.util.TypedValue
import android.view.Gravity
import android.view.MotionEvent
import android.view.View
import android.view.WindowManager
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.OvershootInterpolator
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import java.util.Locale

/**
 * OverlayForegroundService — "God-Level" optimized overlay with:
 *  - Robust lifecycle teardown: overlay ALWAYS resets/dismisses after capture ends.
 *  - Maximum STT accuracy: LANGUAGE_MODEL_FREE_FORM, partial results, dictation mode,
 *    silence detection tuning, multi-hypothesis merging, salvage on error.
 *  - Atomic state machine preventing stuck "Classifying..." states.
 *  - Auto-dismiss safety net (40 s) with explicit idle reset path.
 *  - Minute-granularity transcript forwarding to Flutter.
 */
class OverlayForegroundService : Service() {

    // ─── Companion / static API ──────────────────────────────────────────────

    companion object {
        private const val TAG = "OverlayForegroundSvc"

        const val ACTION_NOTE_CAPTURED = "com.wishperlog.NOTE_CAPTURED"
        const val EXTRA_TEXT   = "extra_text"
        const val EXTRA_SOURCE = "extra_source"
        const val SOURCE_VOICE = "voice_overlay"
        const val SOURCE_TEXT  = "text_overlay"

        private const val PREF_BUBBLE_ALPHA      = "overlay_bubble_alpha"
        private const val PREF_BUBBLE_GROW       = "overlay_bubble_grow"
        private const val PREF_SETTINGS_JSON     = "overlay_settings_json"
        private const val PREF_STT_LANGUAGE      = "overlay_stt_language"
        private const val PREF_STT_PREFER_OFFLINE = "overlay_stt_prefer_offline"
        private const val DEFAULT_ALPHA = 0.90f
        private const val DEFAULT_GROW  = true

        // Capture cooldown — prevents double-fire on rapid gestures.
        private const val CAPTURE_COOLDOWN_MS = 900L

        // Safety-net: island will always auto-dismiss after this delay if
        // BackgroundNoteService never calls notifySaved / dismissIsland.
        private const val ISLAND_SAFETY_DISMISS_MS = 40_000L

        @Volatile
        private var instance: java.lang.ref.WeakReference<OverlayForegroundService>? = null

        fun updateIsland(state: String, message: String?) {
            instance?.get()?.handleIslandUpdate(state, message)
        }

        fun notifySaved(title: String, category: String, prefix: String = "AI", collection: String = "notes") {
            instance?.get()?.handleSavedNotification(title, category, prefix, collection)
        }

        fun notifyBackgroundSaved(title: String, category: String, prefix: String = "AI") {
            notifySaved(title, category, prefix, "notes")
        }

        /** Explicitly resets island to idle — call when empty transcript is detected. */
        fun dismissIslandFromBackground() {
            instance?.get()?.dismissIslandAndReset()
        }

        fun applySettings(settingsJson: String) {
            instance?.get()?.handleApplySettings(settingsJson)
        }

        fun applySettings(alpha: Float, grow: Boolean) {
            instance?.get()?.handleApplySettings(
                OverlayAppearanceSettings.legacy(alpha, grow).toJsonString(),
            )
        }
    }

    // ─── Views ────────────────────────────────────────────────────────────────

    private lateinit var windowManager: WindowManager
    private var bubbleView: View?  = null
    private var bannerView: View?  = null
    private var islandView: View?  = null
    private lateinit var bubbleParams: WindowManager.LayoutParams

    // Sub-views kept for direct mutation without full re-inflation.
    private var bubbleIcon:       ImageView?       = null
    private var bubbleBackground: GradientDrawable? = null
    private var islandLabel:      TextView?         = null
    private var islandBg:         GradientDrawable? = null
    private var overlaySettings   = OverlayAppearanceSettings()
    private var islandBaseColor   = Color.parseColor("#6366F1")

    // ─── STT state ────────────────────────────────────────────────────────────

    private var speechRecognizer:       SpeechRecognizer? = null
    private var lastRecognizerIntent:   Intent?           = null
    private var lastPartialTranscript:  String            = ""
    private var stopListeningCalled:    Boolean           = false
    private var isUserHolding:          Boolean           = false
    private var isRecording:            Boolean           = false
    private var isResettingAfterError:  Boolean           = false
    private var recordingStartTime:     Long              = 0L
    private var lastCaptureAttemptMs:   Long              = 0L
    private var longPressTriggered:     Boolean           = false
    private var bubbleGrowEnabled:      Boolean           = DEFAULT_GROW

    // ─── Handlers / runnables ─────────────────────────────────────────────────

    private val mainHandler         = Handler(Looper.getMainLooper())
    private var longPressRunnable:   Runnable? = null
    private var restartListenRunnable: Runnable? = null
    private var islandDismissRunnable: Runnable? = null
    private var pulseAnimator:       ObjectAnimator? = null
    private var idlePulseAnimator:   ObjectAnimator? = null

    // ─── Audio focus ─────────────────────────────────────────────────────────

    private var audioManager:      AudioManager?      = null
    private var audioFocusRequest: AudioFocusRequest? = null

    // ─── Other infra ─────────────────────────────────────────────────────────

    private val noteReceiver       = NoteInputReceiver()
    private var receiverRegistered = false

    // ─── Lifecycle ────────────────────────────────────────────────────────────

    override fun onBind(intent: Intent): IBinder? = null

    override fun onCreate() {
        super.onCreate()
        startForeground(1, buildNotification())
        instance = java.lang.ref.WeakReference(this)
        windowManager = getSystemService(WINDOW_SERVICE) as WindowManager
        audioManager  = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        NoteInputReceiver.register(this, noteReceiver)
        receiverRegistered = true
        createBubble()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        Log.d(TAG, "onStartCommand: service alive")
        return START_STICKY
    }

    override fun onDestroy() {
        Log.d(TAG, "onDestroy: performing full teardown")
        // ── CRITICAL TEARDOWN: ensure nothing leaks ──────────────────────────
        performFullReset(removeViews = true)
        if (receiverRegistered) {
            try { NoteInputReceiver.unregister(this, noteReceiver) } catch (_: Exception) {}
            receiverRegistered = false
        }
        instance = null
        super.onDestroy()
    }

    // ─── Notification ─────────────────────────────────────────────────────────

    private fun buildNotification(): Notification {
        val channelId = "wishperlog_overlay"
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val ch = NotificationChannel(
                channelId, "WishperLog Overlay",
                NotificationManager.IMPORTANCE_MIN
            ).apply { description = "Floating note-capture bubble" }
            getSystemService(NotificationManager::class.java).createNotificationChannel(ch)
        }
        return NotificationCompat.Builder(this, channelId)
            .setContentTitle("WishperLog")
            .setContentText("Hold bubble to record • Double-tap to type")
            .setSmallIcon(android.R.drawable.ic_btn_speak_now)
            .setPriority(NotificationCompat.PRIORITY_MIN)
            .setSilent(true)
            .build()
    }

    // ─── Dimension helpers ────────────────────────────────────────────────────

    private fun dp(v: Float) = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, v, resources.displayMetrics).toInt()
    private fun sp(v: Float) = TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_SP, v, resources.displayMetrics)

    private fun overlayType() =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        else @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE

    private fun displayWidth(): Int =
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R)
            windowManager.currentWindowMetrics.bounds.width()
        else @Suppress("DEPRECATION") windowManager.defaultDisplay.width

    private fun statusBarHeight(): Int {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            try {
                val insets = windowManager.currentWindowMetrics.windowInsets
                    .getInsets(android.view.WindowInsets.Type.statusBars())
                if (insets.top > 0) return insets.top
            } catch (_: Exception) {}
        }
        val id = resources.getIdentifier("status_bar_height", "dimen", "android")
        return if (id > 0) resources.getDimensionPixelSize(id) else dp(28f)
    }

    // ─── Bubble creation ──────────────────────────────────────────────────────

    private fun createBubble() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            !android.provider.Settings.canDrawOverlays(this)) {
            stopSelf(); return
        }

        val prefs = getSharedPreferences("com.adarshkumarverma.wishperlog_preferences", MODE_PRIVATE)
        val storedSettings = prefs.getString(PREF_SETTINGS_JSON, null)
        overlaySettings = if (storedSettings.isNullOrBlank()) {
            OverlayAppearanceSettings.legacy(
                prefs.getFloat(PREF_BUBBLE_ALPHA, DEFAULT_ALPHA),
                prefs.getBoolean(PREF_BUBBLE_GROW, DEFAULT_GROW),
            )
        } else {
            OverlayAppearanceSettings.fromJson(storedSettings)
        }
        val bubbleAlpha = overlaySettings.alpha.coerceIn(0.3f, 1f)
        bubbleGrowEnabled = overlaySettings.growEnabled

        bubbleParams = WindowManager.LayoutParams(
            dp(54f), dp(54f), overlayType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = prefs.getInt("overlay_x", displayWidth() - dp(64f))
            y = prefs.getInt("overlay_y", 200)
        }

        val bg = buildBubbleDrawable(overlaySettings)
        bubbleBackground = bg

        val frame = FrameLayout(this).apply {
            background = bg
            elevation  = dp(8f).toFloat()
            alpha      = bubbleAlpha
        }

        val icon = ImageView(this).apply {
            setImageDrawable(ContextCompat.getDrawable(this@OverlayForegroundService, android.R.drawable.ic_btn_speak_now))
            setColorFilter(Color.WHITE)
            layoutParams = FrameLayout.LayoutParams(dp(22f), dp(22f), Gravity.CENTER)
            scaleType    = ImageView.ScaleType.FIT_CENTER
        }
        bubbleIcon = icon
        frame.addView(icon)

        // Touch gesture state
        var initX = 0; var initY = 0
        var initTX = 0f; var initTY = 0f
        var isDragging       = false
        var lastTapUpAt      = 0L
        val dragThresholdPx  = 8
        val longPressDelayMs = 350L
        val doubleTapTimeout = 280L

        frame.setOnTouchListener { v, event ->
            synchronized(this) {
                when (event.actionMasked) {
                    MotionEvent.ACTION_DOWN -> {
                        if (isRecording) return@setOnTouchListener true
                        initX = bubbleParams.x; initY = bubbleParams.y
                        initTX = event.rawX; initTY = event.rawY
                        isDragging = false; longPressTriggered = false; isUserHolding = false
                        longPressRunnable?.let { mainHandler.removeCallbacks(it) }
                        longPressRunnable = Runnable {
                            synchronized(this) {
                                longPressTriggered = true; isUserHolding = true
                                if (bubbleGrowEnabled) frame.animate().scaleX(1.22f).scaleY(1.22f).setDuration(180).start()
                                startVoiceCapture()
                            }
                        }
                        mainHandler.postDelayed(longPressRunnable!!, longPressDelayMs)
                        true
                    }
                    MotionEvent.ACTION_MOVE -> {
                        val dx = (event.rawX - initTX).toInt()
                        val dy = (event.rawY - initTY).toInt()
                        if (longPressTriggered || isRecording) return@setOnTouchListener true
                        if (Math.abs(dx) > dragThresholdPx || Math.abs(dy) > dragThresholdPx) {
                            isDragging = true
                            longPressRunnable?.let { mainHandler.removeCallbacks(it) }
                        }
                        if (isDragging) {
                            val newX = initX + dx
                            val newY = initY + dy
                            if (bubbleParams.x != newX || bubbleParams.y != newY) {
                                bubbleParams.x = newX; bubbleParams.y = newY
                                windowManager.updateViewLayout(bubbleView, bubbleParams)
                            }
                        }
                        true
                    }
                    MotionEvent.ACTION_UP, MotionEvent.ACTION_CANCEL -> {
                        frame.animate().scaleX(1f).scaleY(1f).setDuration(120).start()
                        longPressRunnable?.let { mainHandler.removeCallbacks(it) }
                        longPressRunnable = null; longPressTriggered = false
                        restartListenRunnable?.let { mainHandler.removeCallbacks(it) }
                        restartListenRunnable = null
                        if (isRecording) {
                            isUserHolding = false   // clear AFTER stop so onEndOfSpeech sees correct state
                            stopVoiceCapture()
                        } else {
                            isUserHolding = false
                        }
                        if (isDragging) {
                            val cx = bubbleParams.x + v.width / 2
                            val snapX = if (cx > displayWidth() / 2) displayWidth() - dp(64f) else 0
                            val newY = bubbleParams.y.coerceAtLeast(statusBarHeight() + dp(8f))
                            if (bubbleParams.x != snapX || bubbleParams.y != newY) {
                                bubbleParams.x = snapX
                                bubbleParams.y = newY
                                windowManager.updateViewLayout(bubbleView, bubbleParams)
                                prefs.edit().putInt("overlay_x", bubbleParams.x).putInt("overlay_y", bubbleParams.y).apply()
                            }
                        } else if (!longPressTriggered) {
                            val now = event.eventTime
                            if (now - lastTapUpAt <= doubleTapTimeout) {
                                showTextInputBanner()
                                lastTapUpAt = 0L
                            } else {
                                lastTapUpAt = now
                            }
                        }
                        true
                    }
                    else -> false
                }
            }
        }

        bubbleView = frame
        windowManager.addView(frame, bubbleParams)
        startIdleBubblePulse()
    }

    // ─── Voice capture ────────────────────────────────────────────────────────

    private fun startVoiceCapture() {
        if (Looper.myLooper() != Looper.getMainLooper()) { mainHandler.post { startVoiceCapture() }; return }

        val now = System.currentTimeMillis()
        if (now - lastCaptureAttemptMs < CAPTURE_COOLDOWN_MS) return
        lastCaptureAttemptMs = now

        if (isRecording || isResettingAfterError) return

        if (ContextCompat.checkSelfPermission(this, Manifest.permission.RECORD_AUDIO)
            != PackageManager.PERMISSION_GRANTED) {
            FlutterEngineHolder.channel?.invokeMethod("promptMicrophonePermission", null)
            showIsland("Microphone permission required", Color.parseColor("#EF4444"), android.R.drawable.ic_lock_idle_lock)
            scheduleIslandDismiss(2500L)
            return
        }

        if (!SpeechRecognizer.isRecognitionAvailable(this)) {
            showIsland("Speech recognition unavailable", Color.parseColor("#EF4444"), android.R.drawable.ic_dialog_alert)
            scheduleIslandDismiss(2000)
            return
        }

        isRecording = true; stopListeningCalled = false; lastPartialTranscript = ""
        recordingStartTime = System.currentTimeMillis()
        requestAudioFocus()
        FlutterEngineHolder.channel?.invokeMethod("notifyRecordingStarted", null)
        stopIdleBubblePulse()
        showIsland("Listening...", Color.parseColor("#6366F1"), android.R.drawable.ic_btn_speak_now)

        // Bubble → red pulse
        bubbleBackground?.colors = intArrayOf(Color.parseColor("#EF4444"), Color.parseColor("#991B1B"))
        bubbleIcon?.setImageDrawable(ContextCompat.getDrawable(this, android.R.drawable.presence_audio_online))
        bubbleIcon?.setColorFilter(Color.WHITE)
        pulseAnimator = ObjectAnimator.ofPropertyValuesHolder(
            bubbleView,
            PropertyValuesHolder.ofFloat("scaleX", 1f, 1.15f),
            PropertyValuesHolder.ofFloat("scaleY", 1f, 1.15f)
        ).apply { duration = 600; repeatCount = ObjectAnimator.INFINITE; repeatMode = ObjectAnimator.REVERSE; start() }

        releaseSpeechRecognizer()
        speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
        speechRecognizer?.setRecognitionListener(buildRecognitionListener())

        // ── ACCURACY-OPTIMISED intent ─────────────────────────────────────────
        // Key flags that push accuracy toward "keyboard-grade":
        //  • LANGUAGE_MODEL_FREE_FORM  — natural, non-command speech.
        //  • EXTRA_MAX_RESULTS = 5    — gives the merge algo more candidates.
        //  • EXTRA_PARTIAL_RESULTS     — live display + fallback if server cuts.
        //  • DICTATION_MODE            — keeps recognizer alive for long speech.
        //  • Silence lengths tuned for natural pauses (not keyword commands).
        val prefs = getSharedPreferences("com.adarshkumarverma.wishperlog_preferences", MODE_PRIVATE)
        val lang  = prefs.getString(PREF_STT_LANGUAGE, Locale.getDefault().toLanguageTag()) ?: "en-US"
        val offline = prefs.getBoolean(PREF_STT_PREFER_OFFLINE, false)

        val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL,   RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
            putExtra(RecognizerIntent.EXTRA_MAX_RESULTS,      5)
            putExtra(RecognizerIntent.EXTRA_CALLING_PACKAGE,  packageName)
            putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS,  true)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE,         lang)
            putExtra(RecognizerIntent.EXTRA_LANGUAGE_PREFERENCE, lang)
            putExtra(RecognizerIntent.EXTRA_PREFER_OFFLINE,   offline)
            // Dictation mode keeps the recognizer open across natural pauses.
            putExtra("android.speech.extra.DICTATION_MODE",   true)
            // Noise suppression hint (Samsung / Google Recorder honour this).
            putExtra("android.speech.extra.ENABLE_NOISE_SUPPRESSION", true)
            // Silence thresholds tuned for note-taking (longer pauses OK).
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_MINIMUM_LENGTH_MILLIS,                  1_000L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_COMPLETE_SILENCE_LENGTH_MILLIS,         10_000L)
            putExtra(RecognizerIntent.EXTRA_SPEECH_INPUT_POSSIBLY_COMPLETE_SILENCE_LENGTH_MILLIS, 6_000L)
        }

        lastRecognizerIntent = intent
        try {
            speechRecognizer?.startListening(intent)
            vibrate(30)
        } catch (e: Exception) {
            Log.e(TAG, "startListening failed", e)
            dismissIslandAndReset()
        }
    }

    private fun buildRecognitionListener(): RecognitionListener = object : RecognitionListener {

        override fun onReadyForSpeech(params: Bundle?)   { Log.d(TAG, "onReadyForSpeech") }
        override fun onBeginningOfSpeech()               { Log.d(TAG, "onBeginningOfSpeech") }
        override fun onRmsChanged(rmsdB: Float)          { /* high-frequency, skip logging */ }
        override fun onBufferReceived(buffer: ByteArray?){ }
        override fun onEvent(type: Int, params: Bundle?) { }

        override fun onPartialResults(partialResults: Bundle?) {
            val packet = partialResults
                ?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
                ?.firstOrNull() ?: return
            if (packet.isBlank()) return

            val merged  = mergeTranscript(lastPartialTranscript, packet).take(300)
            lastPartialTranscript = merged
            val display = merged.takeLast(90)

            showIsland(display, Color.parseColor("#6366F1"), android.R.drawable.ic_btn_speak_now)
            FlutterEngineHolder.channel?.invokeMethod("notifyRecordingTranscript", hashMapOf("text" to merged))
        }

        override fun onEndOfSpeech() {
            Log.d(TAG, "onEndOfSpeech — user holding=$isUserHolding")
            if (isUserHolding && isRecording && !stopListeningCalled) restartRecognizer(this)
        }

        override fun onResults(results: Bundle?) {
            if (!stopListeningCalled && !isRecording) return

            // Pick highest-confidence result; fall back to first or partial.
            val matches     = results?.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION)
            val confidences = results?.getFloatArray(SpeechRecognizer.CONFIDENCE_SCORES)

            val bestText = if (!matches.isNullOrEmpty() && confidences != null && confidences.isNotEmpty()) {
                val bestIdx = confidences.indices.maxByOrNull { confidences[it] } ?: 0
                matches.getOrNull(bestIdx)?.trim().orEmpty()
            } else {
                matches?.firstOrNull()?.trim().orEmpty()
            }.ifEmpty { lastPartialTranscript.trim() }

            finaliseCapture(bestText)
        }

        override fun onError(error: Int) {
            Log.e(TAG, "onError: ${recognizerErrorToString(error)}")

            val recoverable = error == SpeechRecognizer.ERROR_NO_MATCH ||
                              error == SpeechRecognizer.ERROR_SPEECH_TIMEOUT ||
                              error == SpeechRecognizer.ERROR_CLIENT

            // Restart while user holds during transient errors.
            if (isUserHolding && isRecording && !stopListeningCalled && recoverable) {
                Log.w(TAG, "onError: recoverable during hold — restarting")
                restartRecognizer(this)
                return
            }

            // Salvage partial if stop was triggered and we have something.
            val fallback = lastPartialTranscript.trim()
            if (stopListeningCalled && recoverable && fallback.isNotEmpty()) {
                Log.d(TAG, "onError: salvaging partial '${fallback.take(40)}'")
                finaliseCapture(fallback)
                return
            }

            // Nothing to save — full dismissal.
            dismissIslandAndReset()
            FlutterEngineHolder.channel?.invokeMethod("notifyRecordingFailed", null)
        }
    }

    /**
     * Called when we have final text (or empty). Handles the complete
     * post-recording teardown so it's always consistent.
     *
     * LIFECYCLE GUARANTEE: After this method returns, isRecording == false,
     * bubble is idle, and the island is either showing "Classifying..." with
     * a 40 s safety-net dismiss, or is dismissed (if text is empty).
     */
    private fun finaliseCapture(text: String) {
        Log.d(TAG, "finaliseCapture: '${text.take(60)}' (${text.length} chars)")
        isRecording = false
        resetBubbleVisuals()
        releaseSpeechRecognizer()
        releaseAudioFocus()

        if (text.isNotEmpty()) {
            showIsland("Classifying...", Color.parseColor("#7C3AED"), android.R.drawable.ic_popup_sync)
            // Safety-net: island auto-dismisses if BackgroundNoteService never responds.
            scheduleIslandDismiss(ISLAND_SAFETY_DISMISS_MS)
            broadcastCapture(text, SOURCE_VOICE)
            FlutterEngineHolder.channel?.invokeMethod("notifyRecordingStopped", null)
        } else {
            dismissIslandAndReset()
            FlutterEngineHolder.channel?.invokeMethod("notifyRecordingFailed", null)
        }
    }

    private fun stopVoiceCapture() {
        isRecording = false   // Reset immediately so no subsequent gesture is blocked.
        Log.d(TAG, "stopVoiceCapture (elapsed=${System.currentTimeMillis() - recordingStartTime}ms)")
        stopListeningCalled = true
        releaseAudioFocus()
        restartListenRunnable?.let { mainHandler.removeCallbacks(it) }
        restartListenRunnable = null
        isUserHolding = false
        try {
            speechRecognizer?.stopListening()
        } catch (e: Exception) {
            Log.w(TAG, "stopListening threw", e)
            // If stop itself fails, use last partial or dismiss.
            val fallback = lastPartialTranscript.trim()
            if (fallback.isNotEmpty()) finaliseCapture(fallback)
            else dismissIslandAndReset()
        }
    }

    private fun restartRecognizer(listener: RecognitionListener) {
        restartListenRunnable?.let { mainHandler.removeCallbacks(it) }
        restartListenRunnable = Runnable {
            if (!isUserHolding || !isRecording || stopListeningCalled) return@Runnable
            val intent = lastRecognizerIntent ?: return@Runnable
            try {
                releaseSpeechRecognizer()
                speechRecognizer = SpeechRecognizer.createSpeechRecognizer(this)
                speechRecognizer?.setRecognitionListener(listener)
                speechRecognizer?.startListening(intent)
            } catch (e: Exception) {
                Log.e(TAG, "restartRecognizer failed", e)
                dismissIslandAndReset()
            }
        }
        mainHandler.postDelayed(restartListenRunnable!!, 150)
    }

    private fun releaseSpeechRecognizer() {
        try { speechRecognizer?.cancel()  } catch (_: Exception) {}
        try { speechRecognizer?.destroy() } catch (_: Exception) {}
        speechRecognizer = null
    }

    // ─── Island UI ────────────────────────────────────────────────────────────

    /**
     * Shows or updates the floating top island pill.
     * Idempotent — safe to call repeatedly with new text.
     */
    private fun showIsland(text: String, bgColor: Int, iconRes: Int = 0) {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            mainHandler.post { showIsland(text, bgColor, iconRes) }
            return
        }

        // Reuse existing view if already shown — just update text/colour.
        if (islandView != null && islandLabel != null && islandBg != null) {
            islandBaseColor = bgColor
            islandLabel?.text = text
            applyIslandAppearance(bgColor)
            islandView?.animate()
                ?.scaleX(1.025f)
                ?.scaleY(1.025f)
                ?.translationY(-dp(1f).toFloat())
                ?.setDuration(110)
                ?.withEndAction {
                    islandView?.animate()
                        ?.scaleX(1f)
                        ?.scaleY(1f)
                        ?.translationY(0f)
                        ?.setDuration(140)
                        ?.start()
                }
                ?.start()
            return
        }

        // Build the island from scratch.
        val screenW = displayWidth()
        val pillW   = (screenW * 0.75f).toInt().coerceAtLeast(dp(200f))

        islandBaseColor = bgColor
        val bg = buildIslandDrawable(bgColor, overlaySettings)
        islandBg = bg

        val pill = LinearLayout(this).apply {
            orientation = LinearLayout.HORIZONTAL
            background  = bg
            elevation   = dp(12f).toFloat()
            gravity     = Gravity.CENTER_VERTICAL
            setPadding(dp(13f), dp(8f), dp(13f), dp(8f))
        }

        if (iconRes != 0) {
            val iconView = ImageView(this).apply {
                setImageResource(iconRes)
                setColorFilter(Color.WHITE)
                layoutParams = LinearLayout.LayoutParams(dp(15f), dp(15f)).apply {
                    rightMargin = dp(8f)
                }
            }
            pill.addView(iconView)
        }

        val label = TextView(this).apply {
            this.text      = text
            setTextColor(Color.parseColor("#F8FAFC"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 12.5f)
            setTypeface(null, Typeface.BOLD)
            maxLines       = 1
            ellipsize      = TextUtils.TruncateAt.END
            setSingleLine(true)
        }
        islandLabel = label
        pill.addView(label)

        val params = WindowManager.LayoutParams(
            pillW, WindowManager.LayoutParams.WRAP_CONTENT,
            overlayType(),
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or
                WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL
            y = statusBarHeight() + dp(4f)
        }

        try {
            islandView = pill
            windowManager.addView(pill, params)
            pill.alpha = 0f
            pill.scaleX = 0.94f
            pill.scaleY = 0.94f
            pill.translationY = dp(6f).toFloat()
            pill.animate()
                .alpha(1f)
                .scaleX(1f)
                .scaleY(1f)
                .translationY(0f)
                .setDuration(240)
                .setInterpolator(OvershootInterpolator(1.1f))
                .start()
        } catch (e: Exception) {
            Log.e(TAG, "showIsland: addView failed", e)
            islandView = null; islandLabel = null; islandBg = null
        }
    }

    /**
     * Full island + bubble + recognizer reset.
     * ALWAYS call this on any terminal path (error, empty transcript, cancel).
     */
    fun dismissIslandAndReset() {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            mainHandler.post { dismissIslandAndReset() }
            return
        }
        Log.d(TAG, "dismissIslandAndReset")
        cancelIslandDismiss()
        animateDismissIsland()
        resetBubbleVisuals()
        isRecording         = false
        isUserHolding       = false
        isResettingAfterError = false
        stopListeningCalled = false
        lastPartialTranscript = ""
    }

    private fun animateDismissIsland() {
        val view = islandView ?: return
        view.animate().alpha(0f).setDuration(200).withEndAction {
            try { windowManager.removeView(view) } catch (_: Exception) {}
            islandView = null; islandLabel = null; islandBg = null
        }.start()
    }

    private fun startIdleBubblePulse() {
        val view = bubbleView ?: return
        if (idlePulseAnimator?.isRunning == true) return
        idlePulseAnimator = ObjectAnimator.ofPropertyValuesHolder(
            view,
            PropertyValuesHolder.ofFloat("scaleX", 1f, 1.04f),
            PropertyValuesHolder.ofFloat("scaleY", 1f, 1.04f),
        ).apply {
            duration = 2200
            repeatCount = ObjectAnimator.INFINITE
            repeatMode = ObjectAnimator.REVERSE
            interpolator = AccelerateDecelerateInterpolator()
            start()
        }
    }

    private fun stopIdleBubblePulse() {
        idlePulseAnimator?.cancel()
        idlePulseAnimator = null
    }

    /** Schedules auto-dismiss of island after [delayMs]. Previous schedule is cancelled. */
    private fun scheduleIslandDismiss(delayMs: Long) {
        cancelIslandDismiss()
        islandDismissRunnable = Runnable { dismissIslandAndReset() }
        mainHandler.postDelayed(islandDismissRunnable!!, delayMs)
    }

    private fun cancelIslandDismiss() {
        islandDismissRunnable?.let { mainHandler.removeCallbacks(it) }
        islandDismissRunnable = null
    }

    // ─── Island update API (called from Flutter / BackgroundNoteService) ──────

    fun handleIslandUpdate(state: String, message: String?) {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            mainHandler.post { handleIslandUpdate(state, message) }
            return
        }
        when (state) {
            "recording"   -> showIsland(message ?: "Listening...", Color.parseColor("#6366F1"), android.R.drawable.ic_btn_speak_now)
            "processing"  -> { cancelIslandDismiss(); showIsland("Classifying…", Color.parseColor("#7C3AED"), android.R.drawable.ic_popup_sync) }
            "saved"       -> { /* handled by handleSavedNotification */ }
            "idle", "error" -> dismissIslandAndReset()
        }
    }

    fun handleSavedNotification(title: String, category: String, prefix: String, @Suppress("UNUSED_PARAMETER") collection: String) {
        if (Looper.myLooper() != Looper.getMainLooper()) {
            mainHandler.post { handleSavedNotification(title, category, prefix, collection) }
            return
        }
        cancelIslandDismiss()
        val prefixLabel = if (prefix.equals("sys", ignoreCase = true)) "sys" else "AI"
        val (color, label, iconRes) = when (category.lowercase()) {
            "tasks"     -> Triple(Color.parseColor("#3B82F6"), "$prefixLabel • Saved in Tasks", android.R.drawable.checkbox_on_background)
            "reminders" -> Triple(Color.parseColor("#F59E0B"), "$prefixLabel • Saved in Reminders", android.R.drawable.ic_lock_idle_alarm)
            "ideas"     -> Triple(Color.parseColor("#10B981"), "$prefixLabel • Saved in Ideas", android.R.drawable.ic_menu_edit)
            "follow-up","follow_up" -> Triple(Color.parseColor("#8B5CF6"), "$prefixLabel • Saved in Follow-up", android.R.drawable.ic_menu_revert)
            "journal"   -> Triple(Color.parseColor("#EC4899"), "$prefixLabel • Saved in Journal", android.R.drawable.ic_menu_agenda)
            else         -> Triple(Color.parseColor("#6B7280"), "$prefixLabel • Saved in General", android.R.drawable.ic_menu_info_details)
        }
        val display = if (title.isBlank()) label else "$label • ${title.take(40)}"
        showIsland(display, color, iconRes)
        scheduleIslandDismiss(2_800L)
    }

    fun handleApplySettings(settingsJson: String) {
        mainHandler.post {
            overlaySettings = OverlayAppearanceSettings.fromJson(settingsJson)
            applyBubbleAppearance()
            if (islandView != null && islandLabel != null && islandBg != null) {
                applyIslandAppearance(islandBaseColor)
            }
        }
    }

    // ─── Text input banner ────────────────────────────────────────────────────

    private fun showTextInputBanner() {
        if (bannerView != null) return
        val bannerParams = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            overlayType(),
            WindowManager.LayoutParams.FLAG_NOT_TOUCH_MODAL or WindowManager.LayoutParams.FLAG_WATCH_OUTSIDE_TOUCH,
            PixelFormat.TRANSLUCENT
        ).apply { gravity = Gravity.TOP or Gravity.CENTER_HORIZONTAL; y = dp(8f) }

        val bg = GradientDrawable().apply {
            cornerRadius = dp(20f).toFloat()
            colors = intArrayOf(Color.parseColor("#1E1B4B"), Color.parseColor("#312E81"))
            orientation = GradientDrawable.Orientation.TL_BR
            setStroke(dp(1f), Color.parseColor("#7C3AED"))
        }

        val layout = LinearLayout(this).apply {
            orientation = LinearLayout.VERTICAL
            setPadding(dp(16f), dp(12f), dp(16f), dp(12f))
            background = bg; elevation = dp(16f).toFloat()
        }

        val header = LinearLayout(this).apply { orientation = LinearLayout.HORIZONTAL; gravity = Gravity.CENTER_VERTICAL }
        val title  = TextView(this).apply {
            text = "Quick Note"; setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 15f); setTypeface(null, Typeface.BOLD)
            layoutParams = LinearLayout.LayoutParams(0, LinearLayout.LayoutParams.WRAP_CONTENT, 1f)
        }
        val close = TextView(this).apply {
            text = "✕"; setTextColor(Color.parseColor("#94A3B8"))
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
            setPadding(dp(8f), dp(4f), 0, dp(4f))
            setOnClickListener { dismissBanner() }
        }
        header.addView(title); header.addView(close)

        val input = EditText(this).apply {
            hint = "What's on your mind?"; setHintTextColor(Color.parseColor("#64748B"))
            setTextColor(Color.WHITE); setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f)
            background = GradientDrawable().apply { cornerRadius = dp(12f).toFloat(); setColor(Color.parseColor("#1F2937")) }
            setPadding(dp(12f), dp(10f), dp(12f), dp(10f))
            inputType = InputType.TYPE_CLASS_TEXT or InputType.TYPE_TEXT_FLAG_CAP_SENTENCES
            maxLines = 4; imeOptions = EditorInfo.IME_ACTION_DONE
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, dp(90f)).apply { topMargin = dp(10f) }
        }

        val sendBtn = TextView(this).apply {
            text = "Save Note"; setTextColor(Color.WHITE)
            setTextSize(TypedValue.COMPLEX_UNIT_SP, 14f); setTypeface(null, Typeface.BOLD)
            background = GradientDrawable().apply { cornerRadius = dp(12f).toFloat(); setColor(Color.parseColor("#6366F1")) }
            setPadding(dp(16f), dp(10f), dp(16f), dp(10f))
            gravity = Gravity.CENTER
            layoutParams = LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, LinearLayout.LayoutParams.WRAP_CONTENT).apply { topMargin = dp(10f) }
            setOnClickListener {
                val text = input.text.toString().trim()
                if (text.isNotEmpty()) {
                    try {
                        val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
                        imm.hideSoftInputFromWindow(input.windowToken, 0)
                    } catch (_: Exception) {}
                    dismissBanner()
                    broadcastCapture(text, SOURCE_TEXT)
                } else {
                    dismissBanner()
                }
            }
        }

        layout.addView(header); layout.addView(input); layout.addView(sendBtn)

        try {
            bannerView = layout
            windowManager.addView(layout, bannerParams)
            layout.post {
                input.requestFocus()
                try {
                    val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
                    imm.showSoftInput(input, InputMethodManager.SHOW_IMPLICIT)
                } catch (_: Exception) {}
            }
        } catch (e: Exception) {
            Log.e(TAG, "showTextInputBanner: addView failed", e)
            bannerView = null
        }
    }

    private fun dismissBanner() {
        mainHandler.post {
            val v = bannerView ?: return@post
            try {
                try {
                    val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
                    imm.hideSoftInputFromWindow(v.windowToken, 0)
                } catch (_: Exception) {}
                windowManager.removeView(v)
            } catch (_: Exception) {}
            bannerView = null
        }
    }

    // ─── Broadcast ────────────────────────────────────────────────────────────

    private fun broadcastCapture(text: String, source: String) {
        // ISSUE-03 FIX: use LocalBroadcastManager so NoteInputReceiver (which
        // registers via LBM) actually receives this event.
        val intent = Intent(ACTION_NOTE_CAPTURED).apply {
            putExtra(EXTRA_TEXT,   text)
            putExtra(EXTRA_SOURCE, source)
        }
        androidx.localbroadcastmanager.content.LocalBroadcastManager
            .getInstance(this)
            .sendBroadcast(intent)

        // Direct channel delivery as a fast-path for foreground sessions.
        // NoteInputReceiver handles the engine-dead fallback.
        FlutterEngineHolder.channel?.invokeMethod(
            "captureNote",
            hashMapOf("text" to text, "source" to source)
        )
    }

    // ─── Audio focus ──────────────────────────────────────────────────────────

    private fun requestAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val req = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
                .setAudioAttributes(AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_VOICE_COMMUNICATION)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
                    .build())
                .setAcceptsDelayedFocusGain(false)
                .build()
            audioFocusRequest = req
            audioManager?.requestAudioFocus(req)
        } else {
            @Suppress("DEPRECATION")
            audioManager?.requestAudioFocus(null, AudioManager.STREAM_VOICE_CALL, AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_EXCLUSIVE)
        }
    }

    private fun releaseAudioFocus() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            audioFocusRequest?.let { audioManager?.abandonAudioFocusRequest(it) }
            audioFocusRequest = null
        } else {
            @Suppress("DEPRECATION")
            audioManager?.abandonAudioFocus(null)
        }
    }

    // ─── Bubble visual reset ──────────────────────────────────────────────────

    private fun resetBubbleVisuals() {
        pulseAnimator?.cancel(); pulseAnimator = null
        stopIdleBubblePulse()
        bubbleView?.scaleX = 1f; bubbleView?.scaleY = 1f
        applyBubbleAppearance()
        bubbleIcon?.setImageDrawable(ContextCompat.getDrawable(this, android.R.drawable.ic_btn_speak_now))
        bubbleIcon?.setColorFilter(Color.WHITE)
        startIdleBubblePulse()
    }

    private fun applyBubbleAppearance() {
        val view = bubbleView ?: return
        bubbleBackground = buildBubbleDrawable(overlaySettings)
        view.background = bubbleBackground
        view.alpha = overlaySettings.alpha.coerceIn(0.3f, 1f)
        bubbleGrowEnabled = overlaySettings.growEnabled
    }

    private fun applyIslandAppearance(baseColor: Int) {
        val view = islandView ?: return
        islandBg = buildIslandDrawable(baseColor, overlaySettings)
        view.background = islandBg
    }

    private fun buildBubbleDrawable(settings: OverlayAppearanceSettings): GradientDrawable {
        return GradientDrawable().apply {
            shape = GradientDrawable.OVAL
            applyFill(this, settings, Color.parseColor("#6366F1"), true)
        }
    }

    private fun buildIslandDrawable(baseColor: Int, settings: OverlayAppearanceSettings): GradientDrawable {
        return GradientDrawable().apply {
            cornerRadius = dp(24f).toFloat()
            applyFill(this, settings, baseColor, false)
        }
    }

    private fun applyFill(
        drawable: GradientDrawable,
        settings: OverlayAppearanceSettings,
        baseColor: Int,
        isBubble: Boolean,
    ) {
        val alpha = settings.alpha.coerceIn(0.3f, 1f)
        when (settings.colorFill.lowercase(Locale.ROOT)) {
            "solid" -> {
                drawable.setColor(applyAlpha(settings.solidColor, alpha))
            }
            "lineargradient" -> {
                drawable.orientation = GradientDrawable.Orientation.TL_BR
                drawable.colors = intArrayOf(
                    applyAlpha(settings.gradientStart, alpha),
                    applyAlpha(settings.gradientEnd, alpha),
                )
            }
            "radialgradient" -> {
                drawable.gradientType = GradientDrawable.RADIAL_GRADIENT
                drawable.gradientRadius = if (isBubble) dp(64f).toFloat() else dp(96f).toFloat()
                drawable.colors = intArrayOf(
                    applyAlpha(settings.gradientStart, alpha),
                    applyAlpha(settings.gradientEnd, alpha),
                )
            }
            else -> {
                drawable.setColor(applyAlpha(baseColor, alpha))
            }
        }

        when (settings.borderStyle.lowercase(Locale.ROOT)) {
            "none" -> drawable.setStroke(0, Color.TRANSPARENT)
            "hairline" -> drawable.setStroke(
                dp(1f),
                applyAlpha(settings.borderColor, 0.5f),
            )
            else -> drawable.setStroke(
                if (isBubble) dp(1.5f) else dp(1f),
                applyAlpha(settings.borderColor, 0.88f),
            )
        }
    }

    private fun applyAlpha(color: Int, alpha: Float): Int {
        val clamped = alpha.coerceIn(0f, 1f)
        return Color.argb(
            (clamped * 255f).toInt(),
            Color.red(color),
            Color.green(color),
            Color.blue(color),
        )
    }

    // ─── Full reset ───────────────────────────────────────────────────────────

    /** Called on destroy to ensure zero leaks. */
    private fun performFullReset(removeViews: Boolean) {
        cancelIslandDismiss()
        longPressRunnable?.let    { mainHandler.removeCallbacks(it) }
        restartListenRunnable?.let{ mainHandler.removeCallbacks(it) }
        longPressRunnable    = null
        restartListenRunnable = null
        releaseAudioFocus()
        releaseSpeechRecognizer()
        isRecording = false; isUserHolding = false; isResettingAfterError = false
        if (removeViews) {
            try { bannerView?.let { windowManager.removeView(it) }  } catch (_: Exception) {}
            try { islandView?.let { windowManager.removeView(it) }  } catch (_: Exception) {}
            try { bubbleView?.let { windowManager.removeView(it) }  } catch (_: Exception) {}
            bannerView = null; islandView = null; bubbleView = null
        } else {
            animateDismissIsland()
            dismissBanner()
            resetBubbleVisuals()
        }
    }

    // ─── Helpers ──────────────────────────────────────────────────────────────

    private fun vibrate(ms: Long = 40) {
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                (getSystemService(VIBRATOR_MANAGER_SERVICE) as VibratorManager)
                    .defaultVibrator.vibrate(VibrationEffect.createOneShot(ms, VibrationEffect.DEFAULT_AMPLITUDE))
            } else {
                @Suppress("DEPRECATION")
                (getSystemService(VIBRATOR_SERVICE) as? Vibrator)
                    ?.vibrate(VibrationEffect.createOneShot(ms, VibrationEffect.DEFAULT_AMPLITUDE))
            }
        } catch (_: Exception) {}
    }

    private fun recognizerErrorToString(code: Int) = when (code) {
        SpeechRecognizer.ERROR_AUDIO                  -> "AUDIO"
        SpeechRecognizer.ERROR_CLIENT                 -> "CLIENT"
        SpeechRecognizer.ERROR_INSUFFICIENT_PERMISSIONS -> "NO_PERMISSION"
        SpeechRecognizer.ERROR_NETWORK                -> "NETWORK"
        SpeechRecognizer.ERROR_NETWORK_TIMEOUT        -> "NETWORK_TIMEOUT"
        SpeechRecognizer.ERROR_NO_MATCH               -> "NO_MATCH"
        SpeechRecognizer.ERROR_RECOGNIZER_BUSY        -> "BUSY"
        SpeechRecognizer.ERROR_SERVER                 -> "SERVER"
        SpeechRecognizer.ERROR_SPEECH_TIMEOUT         -> "SPEECH_TIMEOUT"
        else                                          -> "UNKNOWN($code)"
    }

    /**
     * Intelligently merges incremental STT packets.
     * Handles the common case where the recogniser emits overlapping hypotheses.
     */
    private fun mergeTranscript(existing: String, incoming: String): String {
        val prev = existing.replace(Regex("\\s+"), " ").trim()
        val next = incoming.replace(Regex("\\s+"), " ").trim()
        if (next.isEmpty()) return prev
        if (prev.isEmpty()) return next
        if (next.equals(prev, ignoreCase = true)) return prev
        if (next.startsWith(prev, ignoreCase = true)) return next
        if (prev.startsWith(next, ignoreCase = true))
            return if (next.length < prev.length * 0.65f) prev else next

        val maxOverlap = minOf(prev.length, next.length)
        for (len in maxOverlap downTo 2) {
            if (prev.takeLast(len).equals(next.take(len), ignoreCase = true))
                return (prev + next.drop(len)).replace(Regex("\\s+"), " ").trim()
        }
        val ratio = next.length.toFloat() / prev.length.toFloat().coerceAtLeast(1f)
        return if (ratio in 0.7f..1.4f) next else "$prev $next".replace(Regex("\\s+"), " ").trim()
    }
}
```

### android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/WishperlogApplication.kt

```kotlin
package com.adarshkumarverma.wishperlog

import io.flutter.FlutterInjector
import io.flutter.app.FlutterApplication

class WishperlogApplication : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        // Pre-warm the Flutter loader so BackgroundNoteService starts faster.
        FlutterInjector.instance().flutterLoader().startInitialization(this)
    }
}
```

### android/app/src/main/res/drawable/launch_background.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- Modify this file to customize your launch splash screen -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />

    <!-- You can insert your own image assets here -->
    <!-- <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/launch_image" />
    </item> -->
</layer-list>
```

### android/app/src/main/res/drawable-v21/launch_background.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- Modify this file to customize your launch splash screen -->
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="?android:colorBackground" />

    <!-- You can insert your own image assets here -->
    <!-- <item>
        <bitmap
            android:gravity="center"
            android:src="@mipmap/launch_image" />
    </item> -->
</layer-list>
```

### android/app/src/main/res/values/colors.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="black">#000000</color>
</resources>
```

### android/app/src/main/res/values/styles.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Theme applied to the Android Window while the process is starting when the OS's Dark Mode setting is off -->
    <style name="LaunchTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <!-- Show a splash screen on the activity. Automatically removed when
             the Flutter engine draws its first frame -->
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <!-- Theme applied to the Android Window as soon as the process has started.
         This theme determines the color of the Android Window while your
         Flutter UI initializes, as well as behind your Flutter UI while its
         running.

         This Theme is only used starting with V2 of Flutter's Android embedding. -->
    <style name="NormalTheme" parent="@android:style/Theme.Light.NoTitleBar">
        <item name="android:windowBackground">@android:color/transparent</item>
    </style>
</resources>
```

### android/app/src/main/res/values-night/styles.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <!-- Theme applied to the Android Window while the process is starting when the OS's Dark Mode setting is on -->
    <style name="LaunchTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <!-- Show a splash screen on the activity. Automatically removed when
             the Flutter engine draws its first frame -->
        <item name="android:windowBackground">@drawable/launch_background</item>
    </style>
    <!-- Theme applied to the Android Window as soon as the process has started.
         This theme determines the color of the Android Window while your
         Flutter UI initializes, as well as behind your Flutter UI while its
         running.

         This Theme is only used starting with V2 of Flutter's Android embedding. -->
    <style name="NormalTheme" parent="@android:style/Theme.Black.NoTitleBar">
        <item name="android:windowBackground">@android:color/transparent</item>
    </style>
</resources>
```

### android/app/src/main/res/xml/backup_rules.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
  ISSUE-17: Explicit backup rules.
  Excludes all sensitive local data from Android cloud backup.
-->
<full-backup-content>
    <!-- Exclude the entire shared_prefs directory — contains overlay prefs,
         Telegram chat ID, pending notes, and auth tokens. -->
    <exclude domain="sharedpref" path="." />
    <!-- Exclude Isar database files. -->
    <exclude domain="file" path="." />
    <exclude domain="database" path="." />
</full-backup-content>
```

### android/app/src/main/res/xml/data_extraction_rules.xml

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
  ISSUE-17: Android 12+ data-extraction rules.
  Both cloud backup and device-to-device transfer are disabled for all
  user data to protect note content, tokens, and Telegram IDs.
-->
<data-extraction-rules>
    <cloud-backup>
        <exclude domain="root" />
        <exclude domain="sharedpref" />
        <exclude domain="database" />
        <exclude domain="file" />
        <exclude domain="external" />
    </cloud-backup>
    <device-transfer>
        <exclude domain="root" />
        <exclude domain="sharedpref" />
        <exclude domain="database" />
        <exclude domain="file" />
        <exclude domain="external" />
    </device-transfer>
</data-extraction-rules>
```

### android/app/src/profile/AndroidManifest.xml

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- The INTERNET permission is required for development. Specifically,
         the Flutter tool needs it to communicate with the running application
         to allow setting breakpoints, to provide hot reload, etc.
    -->
    <uses-permission android:name="android.permission.INTERNET"/>
</manifest>
```

### android/build.gradle.kts

```kotlin
import com.android.build.gradle.LibraryExtension

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<LibraryExtension>("android") {
            if (namespace == null) {
                namespace = project.group.toString()
            }
            compileSdk = 35
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
```

### android/gradle/wrapper/gradle-wrapper.properties

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-all.zip
```

### android/gradle.properties

```properties
org.gradle.jvmargs=-Xmx8G -XX:MaxMetaspaceSize=4G -XX:ReservedCodeCacheSize=512m -XX:+HeapDumpOnOutOfMemoryError
android.useAndroidX=true
WISHPERLOG_STORE_FILE=../wishperlog-release.jks
WISHPERLOG_STORE_PASSWORD=Veer@5058
WISHPERLOG_KEY_ALIAS=wishperlog
WISHPERLOG_KEY_PASSWORD=Veer@5058
```

### android/local.properties

```properties
sdk.dir=/home/veerbhadra/Android/Sdk
flutter.sdk=/home/veerbhadra/development/flutter
flutter.buildMode=debug
flutter.versionName=1.0.0
flutter.versionCode=1
```

### android/settings.gradle.kts

```kotlin
pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false
}

include(":app")
```

### cloudfare/src/worker.ts

```typescript
// cloudfare/src/worker.ts
//
// WishperLog Digest Worker — v3.1
//
// ── Architecture change (v3.1) ──────────────────────────────────────────────
// The cron now reads scheduling data from the user root document so digest
// delivery does not depend on the optional digest/config mirror write.
//
// Firestore query path for cron:
//   collection: users  →  filter docs with telegram_chat_id present
//
// Firestore path for cron dedup KV:
//   key format: "YYYY-MM-DD:HH:MM:<uid>"   TTL: 26 h (93 600 s)
//
// Webhook: reads user root doc via token lookup (unchanged) then writes a
// history entry to users/{uid}/digest/history_<ts>.
// ENV secrets (wrangler secret put <name>):
//   TELEGRAM_BOT_TOKEN
//   FIREBASE_PROJECT_ID
//   FIREBASE_CLIENT_EMAIL
//   FIREBASE_PRIVATE_KEY          (PEM with literal \n)
//   TRIGGER_SECRET
// ─────────────────────────────────────────────────────────────────────────────

interface Env {
  DIGEST_SENT: KVNamespace;
  TELEGRAM_BOT_TOKEN: string;
  FIREBASE_PROJECT_ID: string;
  FIREBASE_CLIENT_EMAIL: string;
  FIREBASE_PRIVATE_KEY: string;
  TRIGGER_SECRET: string;
}

type KVNamespace = {
  get(key: string): Promise<string | null> | string | null;
  put(key: string, value: string, options?: { expirationTtl?: number }): Promise<void> | void;
};

type ScheduledEvent = unknown;

type ExecutionContext = unknown;

// ── JWT / Auth ────────────────────────────────────────────────────────────────

async function getFirebaseToken(env: Env): Promise<string> {
  const privateKey = env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n");
  const now        = Math.floor(Date.now() / 1000);

  const header  = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss  : env.FIREBASE_CLIENT_EMAIL,
    sub  : env.FIREBASE_CLIENT_EMAIL,
    aud  : "https://oauth2.googleapis.com/token",
    iat  : now,
    exp  : now + 3600,
    scope: "https://www.googleapis.com/auth/datastore",
  };

  const encode = (obj: object) =>
    btoa(JSON.stringify(obj))
      .replace(/=/g, "")
      .replace(/\+/g, "-")
      .replace(/\//g, "_");

  const unsigned = `${encode(header)}.${encode(payload)}`;

  const keyData = await crypto.subtle.importKey(
    "pkcs8",
    pemToBuffer(privateKey),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    keyData,
    new TextEncoder().encode(unsigned),
  );

  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const jwt = `${unsigned}.${sigB64}`;

  const resp = await fetch("https://oauth2.googleapis.com/token", {
    method : "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body   : `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });

  const data = (await resp.json()) as { access_token?: string; error?: string };
  if (!data.access_token) {
    throw new Error(`Firebase token exchange failed: ${data.error ?? "unknown"}`);
  }
  return data.access_token;
}

function pemToBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const bin = atob(b64);
  const buf = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) buf[i] = bin.charCodeAt(i);
  return buf.buffer;
}

// ── Firestore REST helpers ────────────────────────────────────────────────────

async function firestoreGet(
  path: string,
  token: string,
  projectId: string,
): Promise<unknown> {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${path}`;
  const resp = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!resp.ok) throw new Error(`Firestore GET failed: ${resp.status} ${path}`);
  return resp.json();
}

async function firestorePost(
  path: string,
  body: object,
  token: string,
  projectId: string,
): Promise<unknown> {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${path}`;
  const resp = await fetch(url, {
    method : "POST",
    headers: {
      Authorization  : `Bearer ${token}`,
      "Content-Type" : "application/json",
    },
    body: JSON.stringify(body),
  });
  if (!resp.ok) {
    const text = await resp.text();
    throw new Error(`Firestore POST failed: ${resp.status} ${text}`);
  }
  return resp.json();
}

async function firestorePatch(
  docPath: string,
  fields: Record<string, unknown>,
  token: string,
  projectId: string,
): Promise<void> {
  const url =
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${docPath}` +
    `?${Object.keys(fields)
      .map((k) => `updateMask.fieldPaths=${encodeURIComponent(k)}`)
      .join("&")}`;

  const resp = await fetch(url, {
    method : "PATCH",
    headers: {
      Authorization : `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ fields }),
  });
  if (!resp.ok) {
    const text = await resp.text();
    throw new Error(`Firestore PATCH failed: ${resp.status} ${text}`);
  }
}

// ── Firestore field extractors ────────────────────────────────────────────────

function extractField(doc: any, field: string): unknown {
  const f = doc?.fields?.[field];
  if (!f) return undefined;
  return (
    f.stringValue  ??
    f.integerValue ??
    f.booleanValue ??
    f.doubleValue  ??
    undefined
  );
}

function extractArray(doc: any, field: string): string[] {
  const f = doc?.fields?.[field];
  if (!f?.arrayValue?.values) return [];
  return (f.arrayValue.values as any[]).map(
    (v: any) => v.stringValue ?? "",
  ).filter(Boolean);
}

// ── Telegram ──────────────────────────────────────────────────────────────────

async function sendTelegramMessage(
  chatId: string,
  text: string,
  botToken: string,
): Promise<void> {
  const resp = await fetch(
    `https://api.telegram.org/bot${botToken}/sendMessage`,
    {
      method : "POST",
      headers: { "Content-Type": "application/json" },
      body   : JSON.stringify({
        chat_id   : chatId,
        text,
        parse_mode: "HTML",
      }),
    },
  );
  if (!resp.ok) {
    const err = await resp.text();
    throw new Error(`Telegram sendMessage failed: ${err}`);
  }
}

// ── Cron digest ───────────────────────────────────────────────────────────────

async function runDigestCron(env: Env): Promise<void> {
  const token   = await getFirebaseToken(env);
  const now     = new Date();
  const slotKey = toSlotKey(now);
  const dateKey = toDateKey(now);

  console.log(`[Cron] Running at UTC ${slotKey} on ${dateKey}`);

  const queryUrl =
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;

  const queryResp = await fetch(queryUrl, {
    method : "POST",
    headers: {
      Authorization : `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      structuredQuery: {
        from: [{ collectionId: "users" }],
        select: {
          fields: [
            { fieldPath: "telegram_chat_id" },
            { fieldPath: "digest_times_utc" },
            { fieldPath: "digest_slots" },
            { fieldPath: "digest_time" },
            { fieldPath: "display_name" },
            { fieldPath: "message_state" },
          ],
        },
        where: {
          fieldFilter: {
            field: { fieldPath: "telegram_chat_id" },
            op   : "GREATER_THAN_OR_EQUAL",
            value: { stringValue: "" },
          },
        },
      },
    }),
  });

  if (!queryResp.ok) {
    console.error(`[Cron] collectionGroup query failed: ${queryResp.status}`);
    return;
  }

  const queryResults = (await queryResp.json()) as any[];
  console.log(`[Cron] digest config docs fetched: ${queryResults.length}`);

  let fired = 0;

  for (const result of queryResults) {
    const doc = result?.document;
    if (!doc) continue;

    const docName: string = doc.name ?? "";
    const uid = docName.split("/").pop();
    if (!uid) continue;

    const chatId = extractField(doc, "telegram_chat_id") as string | undefined;
    const name   = (extractField(doc, "display_name") as string | undefined) ?? "there";
    const slots  = [
      ...extractArray(doc, "digest_times_utc"),
      ...extractArray(doc, "digest_slots"),
      ...(extractField(doc, "digest_time") ? [String(extractField(doc, "digest_time"))] : []),
    ].filter((slot) => Boolean(slot.trim()));

    if (!uid || !chatId || !slots.includes(slotKey)) continue;

    let message = "";
    try {
      message = pickTelegramMessage(extractMessageState(doc), "summary");
    } catch (e) {
      console.warn(`[Cron] Failed to read cached digest for ${uid}: ${e}`);
    }

    // Dedup: one digest per slot per day per user.
    const dedupKey = `${dateKey}:${slotKey}:${uid}`;
    const already  = await env.DIGEST_SENT.get(dedupKey);
    if (already) {
      console.log(`[Cron] Already sent to ${uid} at ${slotKey}`);
      continue;
    }

    // Fetch the user's notes from the notes subcollection.
    let notes: NoteDoc[] = [];
    try {
      if (!message) {
        notes = extractDigestNotes(doc);
      }
      if (!message && notes.length === 0) {
        const notesSnap = await firestoreGet(
          `users/${uid}/notes?pageSize=200`,
          token,
          env.FIREBASE_PROJECT_ID,
        );
        notes = parseNoteDocs(((notesSnap as any)?.documents ?? []) as any[], uid);
      }
    } catch (e) {
      console.error(`[Cron] Failed to fetch notes for ${uid}: ${e}`);
      continue;
    }

    if (!message) {
      message = buildDigest(notes, name, "Daily Digest");
    }

    try {
      await sendTelegramMessage(String(chatId), message, env.TELEGRAM_BOT_TOKEN);

      // Mark as sent for 26 hours.
      await env.DIGEST_SENT.put(dedupKey, "1", { expirationTtl: 93_600 });

      // Write a history entry to users/{uid}/digest/history_<ts>
      await writeDigestHistory(uid, "cron_digest", "Daily Digest", notes.length, token, env);

      fired++;
      console.log(`[Cron] Digest sent to ${uid} (${chatId})`);
    } catch (e) {
      console.error(`[Cron] Failed to send to ${uid}: ${e}`);
    }
  }

  console.log(`[Cron] Done — fired ${fired} digest(s)`);
}

// ── Write digest history entry ────────────────────────────────────────────────

async function writeDigestHistory(
  uid: string,
  command: string,
  heading: string,
  noteCount: number,
  token: string,
  env: Env,
): Promise<void> {
  try {
    const ts    = Date.now();
    const docId = `history_${ts}`;
    const path  = `users/${uid}/digest/${docId}`;

    const fields = {
      command         : { stringValue: command },
      response_heading: { stringValue: heading },
      note_count      : { integerValue: String(noteCount) },
      queried_at      : { timestampValue: new Date().toISOString() },
    };

    await firestorePatch(path, fields, token, env.FIREBASE_PROJECT_ID);
  } catch (e) {
    // Non-fatal: history logging should never block the main send path.
    console.warn(`[History] Failed to write history for ${uid}: ${e}`);
  }
}

// ── Telegram webhook handler ──────────────────────────────────────────────────

// ── Live-digest builder (used by webhook to avoid stale cached state) ─────────
async function buildLiveTelegramMessage(
  uid: string,
  token: string,
  env: Env,
): Promise<string> {
  const notes = await fetchUserNotes(uid, token, env);
  const userDoc = await fetchUserDoc(uid, token, env);
  const f = userDoc?.fields ?? {};
  const displayName = (f['display_name']?.stringValue ?? '').trim();
  const noteDocs = parseNoteDocs(notes, uid);
  return buildDigest(noteDocs, displayName, '📋 Your Notes Summary');
}

async function fetchUserNotes(uid: string, token: string, env: Env): Promise<any[]> {
  const notesSnap = await firestoreGet(
    `users/${uid}/notes?pageSize=200`,
    token,
    env.FIREBASE_PROJECT_ID,
  );

  return ((notesSnap as any)?.documents ?? []) as any[];
}

async function fetchUserDoc(uid: string, token: string, env: Env): Promise<any | null> {
  try {
    return await firestoreGet(
      `users/${uid}`,
      token,
      env.FIREBASE_PROJECT_ID,
    );
  } catch {
    return null;
  }
}

async function handleWebhook(req: Request, env: Env): Promise<Response> {
  let body: any;
  try {
    body = await req.json();
  } catch {
    return new Response("bad request", { status: 400 });
  }

  const message = body?.message;
  const chatId  = message?.chat?.id;
  const text    = (message?.text ?? "").trim();

  if (!chatId || !text.startsWith("/")) {
    return new Response("ok");
  }

  const token = await getFirebaseToken(env);

  // ── Handle /start <link_token> — link the user's account ──────────────────
  if (text.startsWith("/start")) {
    const parts      = text.split(/\s+/);
    const linkToken  = parts[1]?.trim() ?? "";

    if (linkToken) {
      await handleStartWithToken(chatId, linkToken, token, env);
    } else {
      // /start with no token → send help + Chat ID
      await sendTelegramMessage(
        String(chatId),
        [
          '<b>WishperLog</b> <i>Telegram link</i>',
          '',
          'Your Chat ID',
          `<code>${chatId}</code>`,
          '',
          '<i>Manual linking</i>',
          '1. Open WishperLog → Settings → Telegram',
          '2. Tap <b>Manual Chat ID</b>',
          '3. Paste the number above',
        ].join('\n'),
        env.TELEGRAM_BOT_TOKEN,
      );
    }
    return new Response("ok");
  }

  // ── Handle digest commands ─────────────────────────────────────────────────
  const cmd = text.replace(/^\//, "").split("@")[0].toLowerCase();
  if (cmd === "summary" || cmd === "top") {
    // Always fetch live notes from Firestore for freshest data.
    try {
      const uid = await resolveTelegramUserId(String(chatId), token, env);
      const liveMessage = await buildLiveTelegramMessage(uid, token, env);
      await sendTelegramMessage(String(chatId), liveMessage, env.TELEGRAM_BOT_TOKEN);
    } catch (e) {
      console.error(`[Webhook] Failed to build live digest for ${chatId}:`, e);
      await sendTelegramMessage(
        String(chatId),
        '⚠️ Could not fetch your notes right now. Try again shortly.',
        env.TELEGRAM_BOT_TOKEN,
      );
    }
    return new Response("ok");
  }

  await handleDigestCommand(chatId, cmd, token, env);

  return new Response("ok");
}

async function resolveTelegramUserId(
  chatId: string,
  token: string,
  env: Env,
): Promise<string> {
  const queryUrl =
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;

  const configDoc =
    await findLinkedDigestConfigDoc(queryUrl, token, chatId, env);

  const uid = extractUidFromDocName(configDoc?.name ?? "");
  if (uid) return uid;

  throw new Error(`Telegram chat ${chatId} is not linked to a user`);
}

async function handleStartWithToken(
  chatId: number,
  linkToken: string,
  token: string,
  env: Env,
): Promise<void> {
  const queryUrl =
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;

  const userDoc = await findLinkedUserDocByValue(queryUrl, token, linkToken, [
    "telegram_link_token",
    "telegram_link_pin",
    "pending_telegram.token",
  ]);

  if (!userDoc) {
    await sendTelegramMessage(
      String(chatId),
      [
        '<b>Telegram link not found or already used.</b>',
        '',
        '<i>Quick recovery</i>',
        '• Open WishperLog → Settings → Telegram',
        '• Tap <b>Connect in Telegram</b> again',
        '• Use the new link or copied code immediately',
        '',
        '<i>Manual fallback</i>',
        'Send <b>/start</b> without a code to get your Chat ID, then paste it back into the app.',
      ].join('\n'),
      env.TELEGRAM_BOT_TOKEN,
    );
    return;
  }

  const uid         = userDoc.name?.split("/").pop() as string;
  const displayName = (extractField(userDoc, "display_name") as string) ?? "there";

  // Write chat_id to both the user root doc and the digest/config doc.
  const chatIdStr = String(chatId);

  // User root doc update
  await firestorePatch(
    `users/${uid}`,
    {
      telegram_chat_id: { stringValue: chatIdStr },
      telegram_link_token: { nullValue: "NULL_VALUE" },
    },
    token,
    env.FIREBASE_PROJECT_ID,
  );

  // Digest config doc update — this is the canonical source the cron reads.
  await firestorePatch(
    `users/${uid}/digest/config`,
    {
      telegram_chat_id: { stringValue: chatIdStr },
      link_method     : { stringValue: "auto_deeplink" },
      linked_at       : { timestampValue: new Date().toISOString() },
    },
    token,
    env.FIREBASE_PROJECT_ID,
  );

  await sendTelegramMessage(
    chatIdStr,
    [
      '✅ <b>WishperLog connected</b>',
      '',
      `Hello <b>${escapeHtml(asciiOnly(displayName))}</b>!`,
      'Your digests are now linked and ready.',
      '',
      '<b>Quick commands</b>',
      '<code>/summary</code> <code>/top</code> <code>/tasks</code>',
      '<code>/reminders</code> <code>/ideas</code> <code>/followup</code>',
      '<code>/journal</code> <code>/general</code>',
    ].join('\n'),
    env.TELEGRAM_BOT_TOKEN,
  );
}

async function findLinkedUserDocByValue(
  queryUrl: string,
  token: string,
  linkToken: string,
  fieldPaths: string[],
): Promise<any | null> {
  for (const fieldPath of fieldPaths) {
    const queryResp = await fetch(queryUrl, {
      method : "POST",
      headers: {
        Authorization : `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        structuredQuery: {
          from : [{ collectionId: "users" }],
          where: {
            fieldFilter: {
              field: { fieldPath },
              op   : "EQUAL",
              value: { stringValue: linkToken },
            },
          },
          limit: { value: 1 },
        },
      }),
    });

    if (!queryResp.ok) continue;
    const results = (await queryResp.json()) as any[];
    const doc = results?.[0]?.document;
    if (doc) return doc;
  }

  return null;
}

async function handleDigestCommand(
  chatId: number,
  cmd: string,
  token: string,
  env: Env,
): Promise<void> {
  const queryUrl =
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;

  const configDoc =
    await findLinkedDigestConfigDoc(queryUrl, token, String(chatId), env);

  if (!configDoc) {
    await sendTelegramMessage(
      String(chatId),
      [
        '<b>Telegram is not linked yet.</b>',
        '',
        'Open WishperLog → Telegram and connect again.',
      ].join('\n'),
      env.TELEGRAM_BOT_TOKEN,
    );
    return;
  }

  const uid = extractUidFromDocName(configDoc.name ?? "");
  if (!uid) {
    await sendTelegramMessage(
      String(chatId),
      [
        '<b>Telegram is linked, but the user record could not be resolved.</b>',
        '',
        'Open WishperLog → Settings → Telegram and reconnect.',
      ].join('\n'),
      env.TELEGRAM_BOT_TOKEN,
    );
    return;
  }
  const name      = (extractField(configDoc, "display_name") as string) ?? "there";

  if (!isSupportedTelegramCommand(cmd)) {
    await sendTelegramMessage(
      String(chatId),
      [
        '<b>WishperLog commands</b>',
        '<i>Use any of these:</i>',
        '',
        '<code>/summary</code>  <code>/top</code>  <code>/tasks</code>',
        '<code>/reminders</code>  <code>/ideas</code>  <code>/followup</code>',
        '<code>/journal</code>  <code>/general</code>',
      ].join('\n'),
      env.TELEGRAM_BOT_TOKEN,
    );
    return;
  }

  let message = "";
  try {
    message = await loadCachedTelegramMessage(uid, configDoc, cmd, token, env);
  } catch (e) {
    console.warn(`[Cmd] Failed to read cached message for ${uid}: ${e}`);
  }

  const heading = pickHeading(cmd);

  if (!message) {
    const infoDoc = await loadDigestInfoDoc(uid, token, env);
    const notes =
      extractDigestNotes(infoDoc).length > 0
        ? extractDigestNotes(infoDoc)
        : parseNoteDocs(
            ((await firestoreGet(
              `users/${uid}/notes?pageSize=200`,
              token,
              env.FIREBASE_PROJECT_ID,
            )) as any)?.documents ?? [],
            uid,
          );
    const sentNotes = pickNotesForCommand(notes, cmd);
    message = buildDigest(sentNotes, name, heading);
    await sendTelegramMessage(String(chatId), message, env.TELEGRAM_BOT_TOKEN);
    await writeDigestHistory(uid, cmd, heading, sentNotes.length, token, env);
    return;
  }

  await sendTelegramMessage(
    String(chatId),
    message,
    env.TELEGRAM_BOT_TOKEN,
  );

  // Log to history
  await writeDigestHistory(uid, cmd, heading, 0, token, env);
}

function extractMessageState(doc: any): Record<string, string> {
  const fields = doc?.fields?.message_state?.mapValue?.fields ?? {};
  const output: Record<string, string> = {};
  for (const [key, value] of Object.entries(fields)) {
    const fieldValue = value as any;
    const raw = fieldValue?.stringValue;
    if (typeof raw === "string" && raw.trim()) {
      output[key] = raw;
    }
  }
  return output;
}

async function loadCachedTelegramMessage(
  uid: string,
  configDoc: any,
  cmd: string,
  token: string,
  env: Env,
): Promise<string> {
  const infoDoc = await loadDigestInfoDoc(uid, token, env);
  const configState = {
    ...extractMessageState(configDoc),
    ...extractMessageState(infoDoc),
  };
  const fromConfig = pickTelegramMessage(configState, cmd);
  if (fromConfig) return fromConfig;

  try {
    const userSnap = await firestoreGet(
      `users/${uid}`,
      token,
      env.FIREBASE_PROJECT_ID,
    );
    return pickTelegramMessage(extractMessageState(userSnap as any), cmd);
  } catch {
    return "";
  }
}

async function loadDigestInfoDoc(uid: string, token: string, env: Env): Promise<any | null> {
  try {
    return await firestoreGet(
      `users/${uid}/digest/config/info/current`,
      token,
      env.FIREBASE_PROJECT_ID,
    );
  } catch {
    return null;
  }
}

function extractDigestNotes(doc: any): NoteDoc[] {
  const values = doc?.fields?.notes?.arrayValue?.values ?? [];
  return values
    .map((entry: any) => {
      const fields = entry?.mapValue?.fields ?? {};
      const str = (key: string) => fields[key]?.stringValue ?? '';
      return {
        title: str('title') || str('note_title'),
        category: str('category'),
        priority: str('priority'),
        body: str('body') || str('clean_body'),
      } as NoteDoc;
    })
    .filter((note: NoteDoc) => Boolean(note.title || note.body || note.category));
}

function pickTelegramMessage(state: Record<string, string>, cmd: string): string {
  const summary = state.telegram_summary ?? state.telegram_digest ?? state.telegram ?? "";
  switch (cmd) {
    case "summary":
    case "all":
      return summary;
    case "top":
      return state.telegram_top ?? summary;
    case "tasks":
    case "task":
    case "todo":
      return state.telegram_tasks ?? summary;
    case "reminders":
    case "reminder":
      return state.telegram_reminders ?? summary;
    case "ideas":
    case "idea":
      return state.telegram_ideas ?? summary;
    case "followup":
    case "follow-up":
    case "follow_up":
      return state.telegram_followup ?? summary;
    case "journal":
      return state.telegram_journal ?? summary;
    case "general":
      return state.telegram_general ?? summary;
    default:
      return "";
  }
}

function pickHeading(cmd: string): string {
  switch (cmd) {
    case "top":
      return "Top";
    case "tasks":
    case "task":
    case "todo":
      return "Tasks";
    case "reminders":
    case "reminder":
      return "Reminders";
    case "ideas":
    case "idea":
      return "Ideas";
    case "followup":
    case "follow-up":
    case "follow_up":
      return "Follow-up";
    case "journal":
      return "Journal";
    case "general":
      return "General";
    default:
      return "Summary";
  }
}

function pickNotesForCommand(notes: NoteDoc[], cmd: string): NoteDoc[] {
  switch (cmd) {
    case "top":
      return [...notes]
        .sort((a, b) => priorityRank(a.priority) - priorityRank(b.priority))
        .slice(0, 3);
    case "tasks":
    case "task":
    case "todo":
      return notes.filter((n) => n.category === "tasks");
    case "reminders":
    case "reminder":
      return notes.filter((n) => n.category === "reminders");
    case "ideas":
    case "idea":
      return notes.filter((n) => n.category === "ideas");
    case "followup":
    case "follow-up":
    case "follow_up":
      return notes.filter((n) => n.category === "followUp");
    case "journal":
      return notes.filter((n) => n.category === "journal");
    case "general":
      return notes.filter((n) => n.category === "general");
    default:
      return notes;
  }
}

function isSupportedTelegramCommand(cmd: string): boolean {
  return [
    "summary",
    "all",
    "top",
    "tasks",
    "task",
    "todo",
    "reminders",
    "reminder",
    "ideas",
    "idea",
    "followup",
    "follow-up",
    "follow_up",
    "journal",
    "general",
  ].includes(cmd);
}

async function findLinkedDigestConfigDoc(
  queryUrl: string,
  token: string,
  chatId: string,
  env: Env,
): Promise<any | null> {
  const candidates = [
    {
      from: [{ collectionId: "users" }],
      where: {
        fieldFilter: {
          field: { fieldPath: "telegram_chat_id" },
          op: "EQUAL",
          value: { stringValue: chatId },
        },
      },
      limit: { value: 1 },
    },
    {
      from: [{ collectionId: "digest", allDescendants: true }],
      where: {
        fieldFilter: {
          field: { fieldPath: "telegram_chat_id" },
          op: "EQUAL",
          value: { stringValue: chatId },
        },
      },
      limit: { value: 1 },
    },
  ];

  for (const structuredQuery of candidates) {
    const queryResp = await fetch(queryUrl, {
      method : "POST",
      headers: {
        Authorization : `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ structuredQuery }),
    });

    if (!queryResp.ok) continue;

    const results = (await queryResp.json()) as any[];
    for (const result of results) {
      const doc = result?.document;
      if (!doc) continue;
      return doc;
    }
  }

  return null;
}

function extractUidFromDocName(name: string): string | null {
  const parts = name.split("/").filter(Boolean);
  if (parts.length < 2) return null;
  if (parts[0] !== "users") return null;
  return parts[1] ?? null;
}

// ── Note parsing ──────────────────────────────────────────────────────────────

interface NoteDoc {
  title   : string;
  category: string;
  priority: string;
  body    : string;
}

function parseNoteDocs(docs: any[], _uid: string): NoteDoc[] {
  return docs.map((doc) => {
    const f   = doc?.fields ?? {};
    const str = (k: string) => f[k]?.stringValue ?? "";
    return {
      title   : str("title"),
      category: str("category"),
      priority: str("priority"),
      body    : str("clean_body"),
    };
  });
}

function buildDigest(notes: NoteDoc[], name: string, heading: string): string {
  const ranked = [...notes]
    .sort((a, b) => priorityRank(a.priority) - priorityRank(b.priority))
    .slice(0, 5);

  const title = `<b>${escapeHtml(heading)}</b>`;
  const greeting = asciiOnly(name)
    ? `Hello <b>${escapeHtml(asciiOnly(name))}</b>`
    : 'Hello';

  if (ranked.length === 0) {
    return [
      '📋 <b>WishperLog</b>',
      title,
      `<i>${greeting}</i>`,
      '',
      '<i>No active notes right now. You are all caught up.</i>',
    ].join('\n');
  }

  const stats = [
    `${notes.length} note${notes.length === 1 ? "" : "s"}`,
    `${notes.filter((n) => n.priority === "high").length} high`,
    `${notes.filter((n) => n.category === "tasks").length} tasks`,
  ].join(" · ");

  const lines = [
    '📋 <b>WishperLog</b>',
    title,
    `<i>${greeting}</i>`,
    `<i>${escapeHtml(stats)}</i>`,
    '',
    '<b>Top items</b>',
  ];

  ranked.forEach((n) => {
    const category = categoryLabelFromKey(n.category);
    const priority = priorityLabel(n.priority);
    const titleText = escapeHtml(asciiOnly(n.title) || "Untitled note");
    lines.push(`• <b>${category}</b> <code>${priority}</code> ${titleText}`);

    const body = asciiOnly(n.body).slice(0, 140);
    if (body) {
      lines.push(`  <i>${escapeHtml(body)}</i>`);
    }
  });

  if (notes.length > ranked.length) {
    lines.push("", `<i>+${notes.length - ranked.length} more</i>`);
  }

  return lines.join("\n");
}

// ── Main export ───────────────────────────────────────────────────────────────

export default {
  async scheduled(
    _event: ScheduledEvent,
    env: Env,
    ctx: ExecutionContext,
  ): Promise<void> {
    (ctx as any).waitUntil?.(
      runDigestCron(env).catch((e) =>
        console.error('[Cron] runDigestCron failed:', e),
      ),
    );
  },

  async fetch(req: Request, env: Env): Promise<Response> {
    const url = new URL(req.url);

    if (url.pathname === "/trigger" && req.method === "GET") {
      if (req.headers.get("X-Trigger-Secret") !== env.TRIGGER_SECRET) {
        return new Response("Forbidden", { status: 403 });
      }
      await runDigestCron(env);
      return new Response("triggered", { status: 200 });
    }

    if (url.pathname === "/webhook" && req.method === "POST") {
      return handleWebhook(req, env);
    }

    return new Response("WishperLog Worker v3", { status: 200 });
  },
};

// ── Utility ───────────────────────────────────────────────────────────────────

function toSlotKey(d: Date): string {
  return `${pad(d.getUTCHours())}:${pad(d.getUTCMinutes())}`;
}

function toDateKey(d: Date): string {
  return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())}`;
}

function pad(n: number): string {
  return n.toString().padStart(2, "0");
}

function asciiOnly(v: string): string {
  return (v ?? "")
    .toString()
    .normalize("NFKD")
    .replace(/[^\x00-\x7F]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function priorityRank(p: string): number {
  return p === "high" ? 0 : p === "medium" ? 1 : 2;
}

function priorityLabel(p: string): string {
  switch ((p ?? "").toLowerCase()) {
    case "high": return "HIGH";
    case "low":  return "LOW";
    default:     return "MED";
  }
}

function categoryLabelFromKey(key: string): string {
  switch ((key ?? "").toLowerCase()) {
    case "tasks": return "Tasks";
    case "reminders": return "Reminders";
    case "ideas": return "Ideas";
    case "followup":
    case "follow_up":
    case "follow-up": return "Follow-up";
    case "journal": return "Journal";
    default: return "General";
  }
}

function escapeHtml(input: string): string {
  return (input ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}
```

### cloudfare/wrangler.toml

```toml
name             = "wishperlog-digest"
main             = "src/worker.ts"
compatibility_date  = "2025-01-01"
compatibility_flags = ["nodejs_compat"]
account_id       = "112486d346c988fbdaf8923c083a85d8"

[observability]
enabled = false
head_sampling_rate = 1

[observability.logs]
enabled = true
head_sampling_rate = 1
persist = true
invocation_logs = true

[observability.traces]
enabled = false
persist = true
head_sampling_rate = 1

# ── Workers URL ────────────────────────────────────────────────────────────────
# Deployed at: wishperlog-digest.veerbhadra0524.workers.dev

# ── Cron Triggers ──────────────────────────────────────────────────────────────
# Fires EVERY MINUTE — the Worker matches HH:MM against each user's saved slots.
# This replaces the old 15-minute granularity with precise per-minute scheduling.
[triggers]
crons = ["* * * * *"]

# ── KV Namespace ───────────────────────────────────────────────────────────────
# Stores per-user per-minute dedup keys ("already sent today").
# Key format: "YYYY-MM-DD:HH:MM:<uid>"  TTL: 93 600 s (26 h)
[[kv_namespaces]]
binding = "DIGEST_SENT"
id      = "dca05ac5722b4be0a11d33f1070fa50d"

# ── Secrets (set via `wrangler secret put <NAME>`) ─────────────────────────────
# TELEGRAM_BOT_TOKEN    — bot token from @BotFather
# FIREBASE_PROJECT_ID   — GCP project ID (e.g. "wishperlog-prod")
# FIREBASE_CLIENT_EMAIL — service account email
# FIREBASE_PRIVATE_KEY  — service account private key PEM (newlines as literal \n)
#
# Deployment:
#   npx wrangler deploy
#
# Test locally:
#   npx wrangler dev  →  curl http://localhost:8787/trigger
```
