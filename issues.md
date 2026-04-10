# WishperLog Codebase Audit

Date: 2026-04-09

Scope:
- Reviewed all source/config files under `lib/` and `android/`.
- Reviewed binary launcher assets for presence only.
- Treated generated files such as `lib/shared/models/note.g.dart` and `lib/firebase_options.dart` as generated output/config, so issues are assigned to the handwritten code that uses them.

Validation:
- `flutter analyze`: clean.
- `flutter test`: failing.
- Current failing test signal: `test/widget_test.dart` triggers `NotInitializedError` from `flutter_dotenv` through `AppEnv -> GeminiNoteClassifier -> AiClassifierRouter -> CaptureService`.

Highest-risk themes:
- Overlay/background capture reliability is still fragile when Flutter is not fully alive.
- Data sync is duplicated across too many layers and will be hard to scale safely.
- Several user-facing flows are visually polished but functionally incomplete or misleading.
- Speech/search accuracy claims are stronger than the current wiring actually supports.

## Priority Backlog

## ISSUE-01 - P0 - Environment getters can crash before `.env` is loaded

- Severity: P0
- Area: bootstrap, DI, testing, background safety
- Files: `lib/core/config/app_env.dart:18`, `lib/core/config/app_env.dart:36`, `lib/core/config/app_env.dart:41`, `lib/core/config/app_env.dart:46`, `lib/core/config/app_env.dart:57`, `lib/core/config/app_env.dart:68`, `test/widget_test.dart:18`
- Problem: `AppEnv` getters call `dotenv.maybeGet(...)` directly even when `AppEnv.load()` has not run. That is why the existing widget test fails with `NotInitializedError`, and the same pattern can surface in any path that constructs AI/sync services before startup hydration.
- Impact: red tests, brittle DI, risk of background/isolated crashes, harder local development.
- Recommended fix: make `AppEnv` safe when dotenv is not initialized, or gate all service construction behind an explicit `AppEnv.load()` contract.

## ISSUE-02 - P0 - Web fallback storage path is still broken

- Severity: P0
- Area: storage, web compatibility
- Files: `lib/core/storage/isar_note_store.dart:24-68`
- Problem: the web fallback sets `_useFirestoreOnly = true` and `_isar = null`, but then still calls `_initCompleter!.complete(_isar!)` and returns `_isar!`.
- Impact: the advertised Firestore-only fallback cannot actually boot if Isar initialization fails on web.
- Recommended fix: change `init()` to support a nullable/non-Isar success path, or split initialization state so Firestore-only mode never dereferences `_isar`.

## ISSUE-03 - P0 - Overlay captures can be lost when the Flutter engine is not alive

- Severity: P0
- Area: Android overlay, background capture, reliability
- Files: `android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/OverlayForegroundService.kt:906-915`, `android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/NoteInputReceiver.kt:12-17`, `android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/NoteInputReceiver.kt:23-26`, `lib/features/overlay/overlay_notifier.dart:81-90`
- Problem: `NoteInputReceiver` is registered with `LocalBroadcastManager`, but `OverlayForegroundService.broadcastCapture()` uses `sendBroadcast(intent)`. On top of that, the receiver comment promises a SharedPreferences safety net, but no persistence path actually writes pending notes anywhere.
- Impact: voice/text captures from the Android overlay are at real risk of disappearing when the main Flutter channel is null or unavailable.
- Recommended fix: use one consistent delivery mechanism, add a real persistence fallback, and only clear pending items after confirmed Dart-side receipt.

## ISSUE-04 - P1 - Background capture enrichment does not fully sync and can time out

- Severity: P1
- Area: background processing, cloud sync
- Files: `lib/background_note_handler.dart:17-20`, `lib/background_note_handler.dart:112-113`, `lib/background_note_handler.dart:123-141`
- Problem: `_classifyAndUpdate()` claims to write back to Isar and Firestore, but it only updates Isar. The background isolate also self-parks for a hard-coded 60 seconds even if the batch takes longer.
- Impact: notes captured while the UI engine is dead can remain stale in Firestore, and long-running background batches can be cut off arbitrarily.
- Recommended fix: push the enriched note back to Firestore in the background path and replace the fixed-delay lifetime with an explicit completion-driven shutdown.

## ISSUE-05 - P1 - First-time overlay enable flow is broken

- Severity: P1
- Area: permissions, UX
- Files: `lib/features/overlay/overlay_notifier.dart:128-160`, `android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/MainActivity.kt:55-65`
- Problem: `OverlayNotifier.setEnabled(true)` opens the Android overlay settings screen and then immediately re-checks permission before the user can grant it.
- Impact: the first enable attempt usually fails silently and forces the user to come back and toggle again.
- Recommended fix: turn this into a resumable permission flow, or defer re-checking until the app resumes.

## ISSUE-06 - P1 - The Flutter dynamic island exists but is never mounted

- Severity: P1
- Area: capture feedback, UI wiring
- Files: `lib/main.dart:195-214`, `lib/shared/widgets/molecules/dynamic_notch_pill.dart:14-18`
- Problem: `CaptureUiController` is provided globally, but `UnifiedDynamicIsland` is never inserted into the widget tree.
- Impact: a major part of the capture/save feedback system is implemented but invisible inside the Flutter app, which makes the overlay flow feel inconsistent and unfinished.
- Recommended fix: mount the widget at the app shell level or remove the unused state/UI contract.

## ISSUE-07 - P1 - Speech-language settings do not apply to Flutter dictation flows

- Severity: P1
- Area: speech recognition accuracy, multilingual UX
- Files: `lib/features/settings/presentation/screens/settings_screen.dart:201-230`, `lib/features/settings/presentation/screens/settings_screen.dart:668-756`, `lib/features/home/presentation/screens/home_screen.dart:75-112`, `lib/features/capture/presentation/state/capture_ui_controller.dart:80-135`
- Problem: Settings writes speech preferences only to the native Android overlay channel, while the in-app Flutter dictation paths use separate `SpeechToText` calls with no language wiring and inconsistent offline behavior.
- Impact: users can select Hindi/Bengali/Tamil/etc. in Settings and still get the wrong recognizer behavior in the app itself.
- Recommended fix: centralize speech preferences and apply them to every capture path, not just the Android service.

## ISSUE-08 - P1 - Onboarding/setup screens are mostly cosmetic

- Severity: P1
- Area: onboarding flow, user trust
- Files: `lib/features/onboarding/presentation/screens/sign_in_screen.dart:53-78`, `lib/features/onboarding/presentation/screens/permissions_screen.dart:34-39`, `lib/features/onboarding/presentation/screens/permissions_screen.dart:81-165`
- Problem: after sign-in, the app shows a fake setup animation and a "permissions" screen that does not actually request or verify any permissions or integrations before sending the user to `/home`.
- Impact: the flow looks complete while leaving critical capabilities unresolved; it also trains users to ignore permission/setup messaging.
- Recommended fix: either make the flow real or rename/simplify it so the UI matches what the app actually does.

## ISSUE-09 - P1 - Sync architecture is duplicated, conflict-prone, and not scalable

- Severity: P1
- Area: data, database, sync architecture
- Files: `lib/features/notes/data/note_repository.dart:58-101`, `lib/core/storage/isar_note_store.dart:220-434`, `lib/features/sync/data/firestore_note_sync_service.dart:67-85`, `lib/features/sync/data/external_sync_service.dart:88-115`
- Problem: local save, Firestore push, Firestore pull, AI updates, and Google Tasks/Calendar sync are spread across several services with overlapping write responsibility. In fallback mode, Firestore paths read the full notes collection and filter in memory. The Firestore listener also writes the entire remote snapshot back into Isar wholesale.
- Impact: higher risk of last-write-wins bugs, poor scale, higher Firestore cost, and hard-to-debug state loops.
- Recommended fix: define one source-of-truth sync orchestrator, diff remote updates instead of replaying full collections, and move expensive filters into indexed queries.

## ISSUE-10 - P1 - Data model loses fidelity and uses query-unfriendly timestamp strings

- Severity: P1
- Area: data modeling, reporting, scheduling
- Files: `lib/shared/models/note.dart:118-156`, `lib/shared/models/note.dart:160-177`, `lib/shared/models/note_helpers.dart:246-259`
- Problem: note timestamps are serialized as ISO strings rather than typed Firestore timestamps, and `parseSource()` drops `googleTasks` and `googleCalendar` back to `homeWritingBox`.
- Impact: weaker server-side querying/sorting, more parsing fragility, and incorrect provenance after round-tripping synced notes.
- Recommended fix: use typed timestamp fields in Firestore and fully support every `CaptureSource` enum case in serialization/parsing.

## ISSUE-11 - P2 - Search will not scale smoothly and is weak for non-English text

- Severity: P2
- Area: search, smoothness, multilingual accuracy
- Files: `lib/features/search/presentation/search_screen.dart:123-129`, `lib/features/search/data/smart_note_search.dart:39-52`, `lib/features/search/data/smart_note_search.dart:200-248`
- Problem: every debounced query runs a synchronous full-corpus TF-IDF-style scan on the UI thread. Tokenization also strips anything outside ASCII letters/digits and uses only English stop words.
- Impact: UI jank as note count grows, poor results for Hindi/other non-Latin text, and mismatch with the app's multi-language speech settings.
- Recommended fix: move search off the UI isolate and use a tokenizer/index strategy that respects Unicode text.

## ISSUE-12 - P2 - Telegram formatting and linking have correctness gaps

- Severity: P2
- Area: Telegram UX, bot integration
- Files: `lib/shared/models/note_helpers.dart:30-44`, `lib/features/sync/data/telegram_service.dart:209-260`, `lib/features/sync/data/telegram_service.dart:390-392`
- Problem: `categoryEmoji()` returns plain labels instead of emojis/icons, so digest/find output is visually wrong. The fallback auto-link flow also uses `getUpdates`, which conflicts with webhook/server-style bot deployments.
- Impact: weaker bot presentation today and brittle Telegram linking if a backend worker/webhook is introduced.
- Recommended fix: return real glyphs or chips for category display and avoid client-side polling in environments that should be webhook-driven.

## ISSUE-13 - P2 - Settings wording and behavior are misleading in several places

- Severity: P2
- Area: settings UX, product flow
- Files: `lib/features/settings/presentation/screens/settings_screen.dart:313-318`, `lib/features/sync/data/external_sync_service.dart:88-115`, `lib/features/settings/presentation/screens/settings_screen.dart:590-600`, `lib/core/theme/theme_cubit.dart:14-22`
- Problem: `Sync now` only pulls Google Task completions even though a full sync API exists. The theme UI shows a binary light/dark switch even though `ThemeMode.system` is supported.
- Impact: users cannot trust what the controls say they do, and useful capability is hidden.
- Recommended fix: align labels to actual behavior or wire the controls to the full feature set.

## ISSUE-14 - P2 - Local digest notification support is incomplete

- Severity: P2
- Area: notifications, reminders
- Files: `lib/main.dart:112-116`, `lib/features/notifications/data/local_notification_service.dart:18-79`
- Problem: the app initializes local notifications and defines `showDigestReminder()`, but there is no scheduling/trigger path that actually uses it.
- Impact: the app asks for notification permission without delivering the device-side digest experience it describes.
- Recommended fix: either wire local digest scheduling into WorkManager/background flows or remove the permission prompt until the feature is real.

## ISSUE-15 - P2 - Capture affordances are incomplete or misleading

- Severity: P2
- Area: capture UX, widgets, folder flow
- Files: `lib/features/home/presentation/widgets/thought_canvas.dart:135-147`, `lib/features/notes/presentation/screens/folder_screen.dart:292-304`
- Problem: the home writing surface shows tag/reminder actions that do nothing, and the folder FAB opens a generic quick note editor that does not preserve the current folder category.
- Impact: the interface suggests precision controls that do not exist and creates avoidable category drift.
- Recommended fix: either implement the controls or remove them, and pre-seed quick-add from the active folder context.

## ISSUE-16 - P2 - The visual system is likely to jank on mid-range Android hardware

- Severity: P2
- Area: smoothness, rendering performance
- Files: `lib/shared/widgets/glass_pane.dart:41-119`, `lib/shared/widgets/mesh_gradient_background.dart:26-80`, `lib/features/notes/presentation/widgets/glass_note_card.dart:86`
- Problem: the UI stacks many `BackdropFilter`s, a continuously animating mesh background, and `IntrinsicHeight` inside scrollable note cards.
- Impact: expensive composition and layout work on long lists and older GPUs, especially in folders/settings where the glass effect is repeated heavily.
- Recommended fix: reduce live blur usage in list items, make the animated background optional, and remove `IntrinsicHeight` from repeated cards.

## ISSUE-17 - P1 - Android release/privacy readiness is not production-safe yet

- Severity: P1
- Area: Android release, privacy, data protection
- Files: `android/app/build.gradle.kts:35-40`, `android/app/src/main/AndroidManifest.xml:36-43`
- Problem: release builds still use the debug signing config, and `android:allowBackup="true"` is enabled even though the app stores notes, Telegram IDs, overlay preferences, and tokens in app data.
- Impact: shipping risk, poor release hygiene, and privacy exposure through Android backup/restore.
- Recommended fix: add real release signing and define an explicit backup policy before production distribution.

## ISSUE-18 - P3 - Dead and duplicate code paths are accumulating

- Severity: P3
- Area: maintainability, complexity
- Files: `lib/features/capture/data/note_save_service.dart:5-25`, `lib/features/notes/data/note_repository.dart:58-112`, `lib/features/overlay/overlay_bubble.dart:21-47`, `lib/features/overlay/overlay_notifier.dart:66-70`, `lib/features/onboarding/presentation/screens/splash_screen.dart`, `lib/features/notes/presentation/widgets/search_notes_modal.dart`, `lib/shared/widgets/molecules/dynamic_notch_pill.dart`
- Problem: deprecated wrappers are still active, multiple near-identical save/search/onboarding paths coexist, and some callback wiring is never used.
- Impact: more surface area to maintain, more places for subtle regressions, and slower iteration.
- Recommended fix: collapse onto one capture flow, one search flow, one onboarding flow, and delete unused presentation scaffolding.

## ISSUE-19 - P3 - There is no future-proof, non-disruptive ad/consent architecture yet

- Severity: P3
- Area: future scalability, monetization, compliance
- Files: `lib/features/home/presentation/screens/home_screen.dart`, `lib/features/notes/presentation/screens/folder_screen.dart`, `lib/features/settings/presentation/screens/settings_screen.dart`, `android/app/src/main/AndroidManifest.xml`
- Problem: I did not find any ad service, consent model, remote placement config, or reserved non-intrusive ad surfaces in the reviewed Flutter/Android code. All major screens are hand-laid full-bleed experiences.
- Impact: if ads are added later, they will likely require invasive retrofits that hurt UX unless the app first introduces consent, placement abstraction, and analytics boundaries.
- Recommended fix: design ad support as a first-class optional layer with consent gating, placement tokens, and layout-safe insertion points before monetization work begins.

## Validation Notes

- `flutter analyze` passed cleanly, which means the current issues are mostly runtime, architecture, UX, scalability, and platform-wiring problems rather than lint-level defects.
- `flutter test` failed because `AppEnv` can be read before dotenv initialization; the existing boot test in `test/widget_test.dart` is not green today.

## Coverage Appendix

Legend:
- `Issue(s)` means the file directly contributes to one or more issues above.
- `No direct issue logged` means it was reviewed and did not stand out as a primary defect owner.
- `Generated/Binary` means presence/config was checked, but no manual logic issue is assigned there.

### `lib/`

- `lib/main.dart` - ISSUE-06, ISSUE-14
- `lib/background_note_handler.dart` - ISSUE-04
- `lib/firebase_options.dart` - Generated config; no direct issue logged
- `lib/app/router.dart` - No blocking defect logged; route drift contributes to ISSUE-18
- `lib/core/config/app_env.dart` - ISSUE-01
- `lib/core/di/injection_container.dart` - ISSUE-01, ISSUE-18
- `lib/core/background/work_manager_service.dart` - No direct issue logged; background behavior depends on ISSUE-04 and ISSUE-14
- `lib/core/background/connectivity_sync_coordinator.dart` - No direct issue logged
- `lib/core/settings/app_preferences_repository.dart` - No direct issue logged
- `lib/core/storage/isar_note_store.dart` - ISSUE-02, ISSUE-09
- `lib/core/theme/app_colors.dart` - No direct issue logged
- `lib/core/theme/app_colors_x.dart` - No direct issue logged
- `lib/core/theme/app_theme.dart` - No direct issue logged
- `lib/core/theme/theme_cubit.dart` - ISSUE-13
- `lib/core/theme/app_springs.dart` - No direct issue logged
- `lib/core/theme/app_durations.dart` - No direct issue logged
- `lib/features/auth/data/repositories/user_repository.dart` - No direct blocker logged; token/storage concerns are adjacent to ISSUE-17
- `lib/features/ai/data/ai_classifier_router.dart` - ISSUE-01
- `lib/features/ai/data/ai_processing_service.dart` - ISSUE-09
- `lib/features/ai/data/gemini_note_classifier.dart` - ISSUE-01
- `lib/features/ai/data/groq_note_classifier.dart` - ISSUE-01
- `lib/features/capture/data/capture_service.dart` - ISSUE-01, ISSUE-09
- `lib/features/capture/data/note_save_service.dart` - ISSUE-18
- `lib/features/capture/presentation/state/capture_ui_controller.dart` - ISSUE-06, ISSUE-07
- `lib/features/capture/presentation/state/capture_ui_state.dart` - No direct issue logged
- `lib/features/home/presentation/home_screen_layout.dart` - No direct issue logged
- `lib/features/home/presentation/screens/home_screen.dart` - ISSUE-07, ISSUE-19
- `lib/features/home/presentation/widgets/folder_grid.dart` - No direct issue logged
- `lib/features/home/presentation/widgets/thought_canvas.dart` - ISSUE-15
- `lib/features/notes/data/note_repository.dart` - ISSUE-09, ISSUE-18
- `lib/features/notes/presentation/screens/folder_screen.dart` - ISSUE-15, ISSUE-19
- `lib/features/notes/presentation/screens/note_detail_screen.dart` - No direct blocker logged; formatting polish could improve
- `lib/features/notes/presentation/widgets/glass_note_card.dart` - ISSUE-16
- `lib/features/notes/presentation/widgets/search_notes_modal.dart` - ISSUE-18
- `lib/features/notifications/data/local_notification_service.dart` - ISSUE-14
- `lib/features/onboarding/presentation/screens/permissions_screen.dart` - ISSUE-08
- `lib/features/onboarding/presentation/screens/sign_in_screen.dart` - ISSUE-08
- `lib/features/onboarding/presentation/screens/splash_screen.dart` - ISSUE-18
- `lib/features/onboarding/presentation/screens/telegram_screen.dart` - No direct blocker logged; bot flow still depends on ISSUE-12
- `lib/features/overlay/overlay_bubble.dart` - ISSUE-18
- `lib/features/overlay/overlay_notifier.dart` - ISSUE-03, ISSUE-05, ISSUE-18
- `lib/features/overlay/presentation/system_banner_overlay.dart` - ISSUE-18
- `lib/features/overlay/quick_note_editor.dart` - No direct blocker logged; participates in ISSUE-15 flow mismatch
- `lib/features/search/data/smart_note_search.dart` - ISSUE-11
- `lib/features/search/presentation/search_screen.dart` - ISSUE-11
- `lib/features/settings/presentation/screens/settings_screen.dart` - ISSUE-07, ISSUE-13, ISSUE-19
- `lib/features/settings/presentation/widgets/digest_schedule_section.dart` - ISSUE-13
- `lib/features/sync/data/external_sync_service.dart` - ISSUE-09, ISSUE-13
- `lib/features/sync/data/fcm_sync_service.dart` - No direct blocker logged
- `lib/features/sync/data/firestore_note_sync_service.dart` - ISSUE-09
- `lib/features/sync/data/google_api_client.dart` - No direct issue logged
- `lib/features/sync/data/telegram_service.dart` - ISSUE-12
- `lib/shared/events/note_event_bus.dart` - No direct issue logged
- `lib/shared/models/enums.dart` - No direct issue logged
- `lib/shared/models/note.dart` - ISSUE-10
- `lib/shared/models/note.g.dart` - Generated Isar code; no manual issue assigned
- `lib/shared/models/note_helpers.dart` - ISSUE-10, ISSUE-12
- `lib/shared/models/user.dart` - No direct issue logged
- `lib/shared/widgets/atoms/category_color.dart` - No direct issue logged
- `lib/shared/widgets/glass_container.dart` - No direct issue logged
- `lib/shared/widgets/glass_page_background.dart` - No direct issue logged
- `lib/shared/widgets/glass_pane.dart` - ISSUE-16
- `lib/shared/widgets/glass_title_bar.dart` - No direct issue logged
- `lib/shared/widgets/mesh_gradient_background.dart` - ISSUE-16
- `lib/shared/widgets/molecules/dynamic_notch_pill.dart` - ISSUE-06, ISSUE-18
- `lib/shared/widgets/top_notch_message.dart` - ISSUE-18

### `android/`

- `android/settings.gradle.kts` - No direct issue logged
- `android/build.gradle.kts` - No direct issue logged
- `android/gradle.properties` - No direct issue logged
- `android/gradle/wrapper/gradle-wrapper.properties` - No direct issue logged
- `android/local.properties` - Local machine config; no repo logic issue assigned
- `android/app/build.gradle.kts` - ISSUE-17
- `android/app/src/main/AndroidManifest.xml` - ISSUE-17, ISSUE-19
- `android/app/src/debug/AndroidManifest.xml` - No direct issue logged
- `android/app/src/profile/AndroidManifest.xml` - No direct issue logged
- `android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/MainActivity.kt` - ISSUE-05
- `android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/FlutterEngineHolder.kt` - No direct issue logged
- `android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/OverlayForegroundService.kt` - ISSUE-03
- `android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/BackgroundNoteService.kt` - ISSUE-04
- `android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/NoteInputReceiver.kt` - ISSUE-03
- `android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/BootReceiver.kt` - No direct blocker logged
- `android/app/src/main/kotlin/com/adarshkumarverma/wishperlog/WishperlogApplication.kt` - No direct issue logged
- `android/app/src/main/res/values/colors.xml` - No direct issue logged
- `android/app/src/main/res/values/styles.xml` - No direct issue logged
- `android/app/src/main/res/values-night/styles.xml` - No direct issue logged
- `android/app/src/main/res/drawable/launch_background.xml` - No direct issue logged
- `android/app/src/main/res/drawable-v21/launch_background.xml` - No direct issue logged
- `android/app/src/main/res/mipmap-mdpi/ic_launcher.png` - Binary asset; presence reviewed only
- `android/app/src/main/res/mipmap-mdpi/ic_launcher_round.png` - Binary asset; presence reviewed only
- `android/app/src/main/res/mipmap-hdpi/ic_launcher.png` - Binary asset; presence reviewed only
- `android/app/src/main/res/mipmap-hdpi/ic_launcher_round.png` - Binary asset; presence reviewed only
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher.png` - Binary asset; presence reviewed only
- `android/app/src/main/res/mipmap-xhdpi/ic_launcher_round.png` - Binary asset; presence reviewed only
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png` - Binary asset; presence reviewed only
- `android/app/src/main/res/mipmap-xxhdpi/ic_launcher_round.png` - Binary asset; presence reviewed only
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png` - Binary asset; presence reviewed only
- `android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_round.png` - Binary asset; presence reviewed only

## Short Closing Note

The project has strong ambition and a lot of thoughtful UX work, but the biggest current problems are not styling problems. They are mostly reliability, trust, and architecture problems: getting capture events across Android/Flutter boundaries safely, making data sync coherent, and making the UI say only what the product can actually do today.
