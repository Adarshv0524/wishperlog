# System Context Log (Code, Wiring, Routing)

Date: 2026-04-04
Scope: Current repository runtime context and implementation wiring

## 1. Repository Context

Primary app stack:
- Flutter/Dart mobile app (Android-first)
- Firebase Auth + Firestore
- SQLite local storage via sqflite
- WorkManager background jobs
- FCM push sync events
- Optional Cloud Functions complement

Core directories:
- lib/app: router and app shell wiring
- lib/core: configuration, DI, theme, background services, storage
- lib/features: business features (auth/capture/home/notes/overlay/sync/ai)
- lib/shared: domain model, UI primitives, event bus
- functions: Firebase Cloud Functions (Node.js)

## 2. Runtime Entrypoints

1) Main app process
- File: lib/main.dart
- Purpose: initialize platform services and run MaterialApp.router

2) Overlay process entrypoint
- File: lib/features/overlay_v1/presentation/overlay_entrypoint.dart
- Purpose: host floating capture notch UI in overlay context

3) WorkManager background callback
- File: lib/core/background/work_manager_service.dart
- Symbol: callbackDispatcher
- Purpose: execute periodic/one-off background sync and digest jobs

4) FCM background callback
- File: lib/features/sync/data/fcm_sync_service.dart
- Symbol: firebaseMessagingBackgroundHandler
- Purpose: process push-based note updates while app is backgrounded/killed

5) Server complement
- File: functions/index.js
- Purpose: optional cloud-side enrichment and Telegram operations

## 3. Main Startup Wiring (Sequential)

Source: lib/main.dart

1. ensureFcmBackgroundHandlerRegistered()
2. AppEnv.load()
3. Firebase.initializeApp()
4. WorkManagerService.initialize()
5. WorkManagerService.registerPeriodicGoogleTasksSync()
6. WorkManagerService.registerTelegramDailyDigest()
7. init() from DI container
8. ThemeCubit.hydrate()
9. OverlayCoordinator.hydrateAndRestore()
10. AiProcessingService.start()
11. ConnectivitySyncCoordinator.start()
12. FcmSyncService.initialize()
13. runApp(MyApp)

UI shell:
- MaterialApp.router
- routerConfig from lib/app/router.dart
- theme + darkTheme from AppTheme
- themeMode bound to ThemeCubit

## 4. Dependency Injection Map

Source: lib/core/di/injection_container.dart

Registered lazy singletons:
- AppPreferencesRepository
- UserRepository
- NoteRepository
- SpeechToText
- ExternalSyncService
- NoteEventBus
- CaptureService
- NoteSaveService
- OverlayV1Preferences
- OverlayCoordinator
- FirestoreNoteSyncService
- AiProcessingService
- FcmSyncService
- ConnectivitySyncCoordinator
- ThemeCubit

Important note:
- Overlay entrypoint currently creates CaptureService and SpeechToText directly, not via sl.

## 5. Routing and Guard Logic

Source: lib/app/router.dart

Routes:
- / -> SignInScreen
- /signin -> SignInScreen
- /permissions -> PermissionsScreen
- /telegram -> TelegramScreen
- /home -> HomeScreenLayout
- /folder -> FolderScreen (category from extra/query/path)
- /settings -> SettingsScreen
- /settings/overlay-customization -> OverlayCustomizationScreen

Redirect rules:
- If unauthenticated and target is not onboarding route, redirect to /
- If authenticated and target is onboarding route, redirect to /home
- On Firebase auth check exceptions, return null (no redirect)

## 6. Domain Model and Persistence

## 6.1 Note Entity

Source: lib/shared/models/note.dart

Fields:
- noteId, uid
- rawTranscript, title, cleanBody
- category, priority, extractedDate
- createdAt, updatedAt
- status
- aiModel
- gcalEventId, gtaskId
- source
- syncedAt

Enums:
- NoteCategory: tasks, reminders, ideas, followUp, journal, general
- NotePriority: high, medium, low
- NoteStatus: active, archived, pendingAi
- CaptureSource: voiceOverlay, textOverlay, homeWritingBox

## 6.2 Local Store (SQLite)

Source: lib/core/storage/sqlite_note_store.dart

DB:
- wishperlog_notes.db

Table notes columns:
- note_id (PK)
- uid
- raw_transcript
- title
- clean_body
- category
- priority
- extracted_date
- created_at
- updated_at
- status
- ai_model
- gcal_event_id
- gtask_id
- source
- synced_at

Indexes:
- idx_notes_status
- idx_notes_category
- idx_notes_updated_at
- idx_notes_priority

Reactive mechanism:
- broadcast stream changes used by repository watchers

## 6.3 Firestore Mirror

Collection path:
- users/{uid}/notes/{noteId}

Policy:
- local SQLite write first
- Firestore merge write best-effort
- local success should not depend on cloud

## 7. Capture Logic Wiring

## 7.1 Home Capture Path

Source: lib/features/home/presentation/screens/home_screen.dart

UI behavior:
- Text canvas supports multiline note drafting
- Long-press mic starts speech recognition
- Release mic stops recognition and can auto-save captured text
- Save button writes through NoteSaveService

Service path:
HomeScreen -> NoteSaveService.saveNote -> SqliteNoteStore.upsert -> NoteEventBus.emitNoteSaved -> optional Firestore set

UX feedback:
- showTopNotchSavedMessage overlay confirmation

## 7.2 Overlay Capture Path

Sources:
- lib/features/overlay_v1/overlay_coordinator.dart
- lib/features/overlay_v1/presentation/overlay_entrypoint.dart
- lib/features/capture/presentation/state/capture_ui_controller.dart
- lib/shared/widgets/molecules/dynamic_notch_pill.dart

Flow:
1. Settings toggle requests OS overlay permission if needed
2. OverlayCoordinator.showIdleBubble opens overlay window
3. Long press in overlay triggers CaptureUiController.startRecording
4. Release triggers stopRecording
5. State transitions: idle -> recording -> processing -> saved -> idle
6. CaptureService.ingestRawCapture persists local pending note and emits NoteSaved event

Overlay state persisted in SharedPreferences via OverlayV1Preferences:
- visible
- x/y position
- opacity
- size
- snapEnabled

## 8. AI and Enrichment Wiring

Source: lib/features/ai/data/ai_processing_service.dart

Inputs:
- NoteEventBus.onNoteSaved
- startup sweep of SqliteNoteStore.getPendingAiNotes()

Processing chain:
1. fetch note by id from SQLite
2. classify raw transcript using GeminiNoteClassifier
3. patch note fields and mark status active
4. invoke ExternalSyncService.syncExternalForNote
5. upsert to SQLite
6. mirror to Firestore

Concurrency controls:
- _inFlightNoteIds set prevents duplicate simultaneous processing per note
- _sweepRunning guard prevents overlapping sweeps

Failure policy:
- swallow errors, leave note pendingAi for future retry

## 9. External Sync Wiring

Source: lib/features/sync/data/external_sync_service.dart

Capabilities:
- Google Calendar event creation for reminder notes with extractedDate
- Google Tasks creation for task notes
- Google task completion back-sync to archive matching notes
- fuzzy duplicate check for calendar reminders

Writeback:
- updates note gcalEventId/gtaskId/syncedAt
- persists to SQLite and Firestore (depending on caller path)

## 10. Push Sync Wiring (FCM)

Source: lib/features/sync/data/fcm_sync_service.dart

Initialization:
- get token + update user doc
- subscribe to onTokenRefresh
- subscribe to onMessage and onMessageOpenedApp

Message contracts:
- type=note_status_changed, note_id, status -> FirestoreNoteSyncService.applyStatusFromPush
- type=note_updated, note_id -> FirestoreNoteSyncService.syncNoteById

Background path reuses same contracts in firebaseMessagingBackgroundHandler.

## 11. Background Job Wiring (WorkManager)

Source: lib/core/background/work_manager_service.dart

Task registry:
- wishperlog.periodic_google_tasks_sync
- wishperlog.flush_pending_ai
- wishperlog.telegram_daily_digest

Execution behavior in callbackDispatcher:
- loads env + initializes Firebase + initializes SQLite
- periodic_google_tasks_sync -> ExternalSyncService.syncGoogleTaskCompletions
- flush_pending_ai -> AiProcessingService.flushPendingQueue
- telegram_daily_digest -> _runTelegramDailyDigest

Digest details:
- digest time from prefs (default 09:00)
- once-per-day guard key digest.last_telegram_sent_date
- user telegram_chat_id from Firestore
- message sent via Telegram Bot API sendMessage

## 12. Connectivity Wiring

Source: lib/core/background/connectivity_sync_coordinator.dart

Behavior:
- monitors connectivity changes
- when transitioning offline -> online, schedules flush_pending_ai one-off task

## 13. Auth and User Profile Wiring

Source: lib/features/auth/data/repositories/user_repository.dart

Capabilities:
- Google sign-in via Firebase Auth credentials
- user profile upsert in Firestore users/{uid}
- updates digest_time, overlay flags/position, telegram_chat_id, fcm_token

Known integration note:
- overlay position keys in this repository differ from OverlayV1Preferences keys, so syncing strategy should be standardized.

## 14. Settings Wiring

Source: lib/features/settings/presentation/screens/settings_screen.dart

Responsibilities:
- theme toggles through ThemeCubit
- digest schedule update and worker re-registration
- notification permission request and token sync
- overlay enable/disable with robust permission handling
- manual sync trigger via ExternalSyncService.syncNow
- Telegram connect flow launcher

## 15. Shared UI and Theme Wiring

Theme:
- lib/core/theme/app_theme.dart
- lib/core/theme/theme_cubit.dart

Glass UI primitives:
- lib/shared/widgets/glass_container.dart
- lib/shared/widgets/glass_page_background.dart
- lib/shared/widgets/top_notch_message.dart

Category utilities:
- lib/shared/models/note_helpers.dart
- lib/shared/widgets/atoms/category_color.dart

## 16. Overlay-Specific UI Components

- DynamicNotchPill in lib/shared/widgets/molecules/dynamic_notch_pill.dart
- CaptureUiState/CaptureUiController in lib/features/capture/presentation/state/
- Home route compatibility wrapper in lib/features/home/presentation/home_screen_layout.dart

## 17. Cloud Functions Context

Source: functions/index.js

Implemented cloud-side operations include:
- Firestore trigger enrichPendingAiNote for pendingAi notes via Gemini
- Telegram-related utility logic for digest/update handling

Architecture consequence:
- both client-side AI processing and server-side AI processing exist concurrently; this must be intentionally coordinated to avoid duplicate enrich operations.

## 18. Current Architecture Risks and Drift Points

1. Dual enrichment path (client + cloud) can race and overwrite fields.
2. Home screen currently consolidates many responsibilities in one file (complexity risk).
3. Overlay process does not fully share DI bootstrap from main process.
4. Retry/error telemetry exists mostly via debug logs; persistent observability is limited.
5. UserRepository overlay_position persistence format diverges from OverlayV1Preferences key scheme.

## 19. Invariants (Must Hold)

1. Local save must complete before any network-dependent operation.
2. NoteSaved event must fire only after local persistence succeeds.
3. Router auth guard must keep protected routes inaccessible when unauthenticated.
4. Background handlers must initialize Firebase before Firestore operations.
5. Overlay toggles must only report enabled when overlay visibility is confirmed.

## 20. Suggested Immediate Normalization Plan

1. Declare one source of truth for AI enrichment (client or cloud) and gate the other.
2. Introduce a shared capture facade used by both Home and Overlay.
3. Split HomeScreen into dedicated components (canvas, controls, folder grid).
4. Standardize overlay position persistence keys between local prefs and user profile sync.
5. Add architecture conformance checks in CI (route table, DI registry, task names, message types).
