# Current Phase: Phase 10 - Rendering Stabilization + Folder Recovery

# Architecture State
- 100% Client-Side / Zero-Cost
- No Cloud Functions, no Firebase CLI requirement, no Node.js runtime requirement, no paid Firebase plan requirement.
- Visual system has shifted to premium Glassmorphism:
  - Dynamic mesh/orb background now drives depth for all major app surfaces.
  - Reusable `GlassContainer` (ClipRRect + BackdropFilter + translucent gradient + subtle edge + shadow) is the standard card shell.
  - Onboarding, Home, Folder notes, bottom sheets, and Settings panels now use the glass layer.
- Capture is now unified through `CaptureService` for overlay and in-app capture flows.
- Capture pipeline now attempts immediate Gemini classification and folder assignment, then writes to Isar and syncs to `users/{uid}/notes/{noteId}`.
- If immediate classification fails, the note is safely persisted as `pendingAi` for automatic retry processing.
- Phase 10 rendering hardening:
  - In-app mic now has hold-state animation and guarded capture calls to avoid red crash widgets.
  - Overlay capture save operations are wrapped in isolate-safe exception guards.
  - Folder rendering path uses explicit loading/error/empty/list states with strict `ListView.builder` note rendering.
- AI classification remains in Flutter using Gemini with Google AI Studio keys (ai.google.dev), not Vertex AI billing flows.
- Scheduling and automation run on-device:
  - Daily 9 AM Telegram digest is sent by a local background scheduler (WorkManager or Android alarm manager).
  - 4-hour periodic background sync also polls Telegram Bot API getUpdates to process /start linking and callback button actions.
- Telegram integration is fully client-driven:
  - App sends digest via direct REST call to api.telegram.org sendMessage.
  - App consumes callback queries and commands by polling getUpdates.
- Google Sign-In now has graceful developer-error handling:
  - `ApiException: 10` / SHA-1 mismatch is mapped to a friendly in-app error message.
  - User-facing failure feedback uses a floating glass-style snackbar treatment.
- Overlay interaction now uses a strict bubble/banner state machine with hold-to-record animation states:
  - Bubble supports long-press voice capture and double-tap banner expansion.
  - Hold state scales bubble by ~15%, shifts to accent gradient, and adds pulsing glow.
  - Banner supports multiline text entry, Save, and an X close action that returns to the bubble.
  - Overlay customization now lives in a dedicated settings sub-screen.
- Firestore user schema is now enforced on sign-in with exact architectural fields:
  - `uid`, `email`, `display_name`
  - `google_tokens` map (`access_token`, `refresh_token`, `expiry`)
  - `telegram_chat_id`, `digest_time`, `overlay_position`, `overlay_visible`, `fcm_token`, `created_at`
- Firestore path strategy is fixed to:
  - User doc: `users/{uid}`
  - Notes subcollection: `users/{uid}/notes/{noteId}` (flat under user, filtered by note `category` field)
- Added Firestore rules to lock reads/writes to owner-only user paths.
- Firestore sync reliability was improved for note creation paths:
  - Home quick-create and overlay capture create paths now push documents to `users/{uid}/notes/{noteId}`.

# Completed Tasks
- Release pipeline was stabilized for Android SDK 35.
- Added reusable `MeshGradientBackground` and `GlassContainer` widgets.
- Rebuilt onboarding with premium glass cards, custom Google SVG sign-in pill, and contextual overlay-permission step.
- Applied glass UI to Home writing box, search pill, and 3x2 category grid.
- Applied glass UI to Folder note cards and edit bottom sheet.
- Applied glass UI to Settings panels.
- Rebuilt overlay flow around a bubble -> banner state machine with on-device speech mode enabled.
- Added reusable `GlassNoteCard` and integrated it into folder/category note rendering.
- Fixed back navigation flow:
  - Home now opens Folder/Settings using push navigation.
  - Folder and Settings back actions safely return to Home when needed.
- Added explicit Google sign-in SHA-1 mismatch handling for developer-friendly troubleshooting.
- Added dedicated overlay customization settings and live bubble opacity updates.
- Reworked the Home screen into a large multiline Thought Canvas with inline dictation controls.
- Fixed folder navigation to route using category enum via route `extra` and hydrate the folder screen with selected category context.
- Updated search and home folder navigation to pass selected category via `context.push('/folder', extra: selectedCategory)`.
- Added pending-AI processing banners so folder screens do not appear blank while AI is organizing notes.
- Unified raw capture ingestion in overlay and home through one service entrypoint.
- Upgraded Gemini prompt contract to enforce exact JSON keys: `title`, `category`, `priority`, `clean_body`, `extracted_date`.
- Fixed folder list rendering reliability:
  - Category-scoped stream remains enum-based (`categoryEqualTo(selectedCategory)`), and list UI now renders through a strict builder path.
- Added defensive note-card text fallbacks to avoid object/null rendering issues.
- Added concise `SETUP.md` with manual Firebase/Firestore steps and rules deployment instructions.
- Rewrote setup guide with SHA-1-first instructions and Firestore database creation steps.
- Background worker infrastructure exists for periodic and queued processing.
- Environment-based config handling is in place (Gemini, Telegram, Google web client id).
- Sign-in async context warning was fixed and analyzer is clean.
- Documentation has been pivoted to a strict zero-cost integration path.

# Verification
- flutter analyze is clean after the Phase 10 rendering and folder fixes.
- Release APK build succeeded for Android arm64 target.
- Debug APK build succeeded after the Phase 8 refactor.
- Added `flutter_svg` dependency and assets wiring for custom auth button icon.
- Linux runtime smoke launch is currently blocked locally due missing linker (`ld.lld`/`ld`) in system toolchain.
- Runtime behavior is resilient when optional env values are missing.

# Current MVP Status
- MVP is complete and release-capable.
- Architecture has been re-targeted to a free-tier, no-credit-card operating model.
- Core UX and reliability for auth, overlay capture, home writing, and back navigation have been strengthened in Phase 8.

# Optional Follow-Up Work
- Add integration tests for client-side Telegram polling and callback processing.
- Add guardrails for Telegram update offset persistence and idempotent callback handling.
- Add battery-impact benchmarking for daily + 4-hour background workers on target devices.
