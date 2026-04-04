# WhisperLog Setup Guide (Phase 7)

This guide only covers the remaining setup tasks for the current app state.
It starts with the critical Google Sign-In SHA-1 fix for ApiException 10.

## 1) CRITICAL FIRST STEP: Fix Google Sign-In ApiException 10 (SHA-1)

If you see `ApiException: 10`, your Android app SHA-1 does not match Firebase config.

### 1.1 Copy-paste command to print debug SHA-1

Run this exactly in terminal:

```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Find the `SHA1:` line in the output.

### 1.2 Add SHA-1 in Firebase Console

1. Open Firebase Console -> your existing project.
2. Go to Project settings.
3. In Your apps, open your Android app.
4. Click Add fingerprint.
5. Paste the SHA-1 from terminal.
6. Save.

### 1.3 Replace google-services.json

1. In the same Android app section, download the new `google-services.json`.
2. Replace project file at:
   - `android/app/google-services.json`
3. The Android app now applies the Google Services Gradle plugin, so the config file must be the one from the same Firebase Android app entry.
4. Run:

```bash
flutter clean
flutter pub get
```

5. Rebuild and test sign-in again.
6. If the error still shows, uninstall the app from the device and run again so Android cannot reuse an old build artifact.

## 2) Configure Gemini API Key (Google AI Studio, not Vertex)

Use AI Studio free API key path only.

1. Open https://aistudio.google.com/
2. Create or select your API key.
3. Copy key value.
4. Put key in `.env`:

```text
GEMINI_API_KEY=your_ai_studio_key
```

## 3) Create Firestore Database

This step is mandatory for note sync.

1. Open Firebase Console.
2. Select your `wishperlog` project.
3. Go to `Build` -> `Firestore Database`.
4. Click `Create database`.
5. Choose a location close to your users.
6. Start in `Production mode`.
7. Open the `Rules` tab.
8. Paste these rules:

```text
rules_version = '2';
service cloud.firestore {
   match /databases/{database}/documents {
      match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;

         match /notes/{noteId} {
            allow read, write: if request.auth != null && request.auth.uid == userId;
         }
      }
   }
}
```

9. Click `Publish`.
10. When you save a note in WhisperLog, it will write to `users/{uid}/notes/{noteId}` automatically.

## 4) Configure Telegram Bot Token (for WorkManager polling)

No webhook setup is required.

1. Open Telegram and chat with `@BotFather`.
2. Run `/newbot` and complete bot creation.
3. Copy bot token.
4. Put values in `.env`:

```text
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_BOT_USERNAME=your_bot_username
```

The app polls Telegram `getUpdates` in periodic background work.

## 5) Confirm Google Web Client ID in .env

1. Open Google Cloud Console -> APIs and Services -> Credentials.
2. Open your existing Web OAuth client.
3. Copy Client ID.
4. Put in `.env`:

```text
GOOGLE_WEB_CLIENT_ID=your_web_client_id
```

## 6) Enable Google Calendar / Tasks APIs (if not already enabled)

1. Open Google Cloud Console for the same project.
2. APIs and Services -> Library.
3. Enable `Google Calendar API`.
4. Enable `Google Tasks API`.

## 7) Phase 8 Verification Checklist

- [ ] Google Sign-In works on device without ApiException 10.
- [ ] Sign-in failure with SHA mismatch shows friendly message in-app.
- [ ] Overlay bubble closes and reverts from the Truecaller banner with the X button.
- [ ] Overlay long-press starts on-device voice capture and saves note.
- [ ] Overlay double-tap opens the bottom text banner and Save returns to bubble.
- [ ] Home writing box is a large multiline Thought Canvas.
- [ ] Overlay customization updates bubble opacity in real time.
- [ ] New notes appear in the correct Folder category screen.
- [ ] Back arrow from Folder returns to Home.
- [ ] Back arrow from Settings returns to Home.
- [ ] Creating/updating notes writes documents under `users/{uid}/notes/{noteId}` in Firestore.

## 8) Useful Commands

```bash
flutter pub get
flutter analyze
flutter run
flutter build apk --release --target-platform android-arm64
```

## 9) Minimal .env example

```text
GEMINI_API_KEY=your_ai_studio_key
GOOGLE_WEB_CLIENT_ID=your_web_client_id
TELEGRAM_BOT_TOKEN=your_bot_token
TELEGRAM_BOT_USERNAME=your_bot_username
```
