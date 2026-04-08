# WhisperLog

WhisperLog is a local-first voice and text capture app with Android overlay capture, AI enrichment, Firestore mirroring, external Google integrations, and Telegram digest support.

The current codebase uses Isar as the local source of truth for reads and writes, while Firestore is the asynchronous cloud mirror and cross-device sync layer. Older SQLite-era documentation has been folded into the consolidated architecture notes so the repo now has one current blueprint instead of several competing summaries.

## What The App Does

- Capture voice or text from the Android overlay bubble or the main home canvas.
- Save notes locally first so the UI updates immediately.
- Enrich notes with AI classification, title extraction, category, priority, and date parsing.
- Mirror local changes to Firestore for backup and sync.
- Pull remote changes back into Isar through Firestore listeners and FCM-triggered refreshes.
- Create Google Calendar events and Google Tasks items for the right note categories.
- Send a Telegram daily digest from the device without requiring a bot backend.

## Current Blueprint

- Entry point: [lib/main.dart](lib/main.dart)
- Routing: [lib/app/router.dart](lib/app/router.dart)
- Overlay bridge: [lib/features/overlay/overlay_notifier.dart](lib/features/overlay/overlay_notifier.dart)
- Sync background jobs: [lib/core/background/work_manager_service.dart](lib/core/background/work_manager_service.dart)
- Telegram flow: [lib/features/sync/data/telegram_service.dart](lib/features/sync/data/telegram_service.dart)
- Shared enums and keys: [variables.md](variables.md)
- Full runtime wiring: [architecture.md](architecture.md)

## Recent Implementation Notes

- Overlay state is hydrated during app startup, and pending native-only captures are drained after launch.
- The native overlay now uses a fallback chain so note capture survives engine death and app resume gaps.
- Telegram connect supports both backend-assisted linking and a no-backend `getUpdates` fallback.
- WorkManager now tracks periodic Google Tasks sync, pending AI flush, and Telegram digest jobs.
- Firestore is a mirror, not the primary local read source.

## Setup

### Prerequisites

- Flutter SDK 3.11.4+
- Dart 3.11+
- Android SDK 31+ or Xcode 13+
- Firebase project with Authentication, Firestore, FCM, and Cloud Functions enabled
- Google Calendar and Google Tasks APIs enabled if you want external sync
- Gemini API key for enrichment
- Telegram bot token if you want digest and bot command features

### Quick Start

1. Install dependencies.
   ```bash
   flutter pub get
   ```

2. Configure environment values.
   - Use `.env` for non-Firebase secrets such as Gemini and Telegram values.
   - Do not put Firebase Android configuration in `.env`; Android uses `google-services.json` plus SHA-1 registration in Firebase Console.

3. Download Firebase files.
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`

4. Register the Android SHA-1 fingerprint in Firebase Console.
   ```bash
   cd android && ./gradlew signingReport
   ```

5. Deploy Cloud Functions if you use server-side enrichment or Telegram helpers.
   ```bash
   cd functions
   firebase deploy --only functions
   ```

6. Generate code and run the app.
   ```bash
   flutter pub run build_runner build
   flutter run
   ```

## Runtime Checklist

- Grant microphone permission for voice capture.
- Grant overlay permission on Android if you want the floating bubble.
- Sign in with Google before testing cloud sync or Google Calendar / Tasks integration.
- Confirm Firebase auth, Firestore rules, and Cloud Functions are configured before release testing.

## Troubleshooting

- If notes save locally but do not appear in Firestore immediately, check network connectivity and Firestore auth state.
- If overlay capture fails, confirm the Android overlay permission and microphone permission are both granted.
- If Telegram linking stalls, verify the bot token, check whether a backend poller is consuming updates, and retry the connect flow.
- If Google Calendar or Tasks are not created, confirm the note category and extracted date match the integration rules.

## Architecture And Reference Docs

- [architecture.md](architecture.md) covers the merged runtime topology, overlay flows, sync pipelines, Telegram flows, and operational notes.
- [variables.md](variables.md) lists enums, helpers, task names, and shared keys.

## Contributing

Before sending changes:

1. Run `flutter analyze`.
2. Run `dart format lib/`.
3. Test the app on an Android device.
4. Recheck the runtime docs if you changed routing, capture, sync, or background jobs.

## License

MIT License.
