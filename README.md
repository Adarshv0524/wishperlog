# WhisperLog

**Local-first voice and text capture app with AI-powered categorization, real-time cloud sync, and Android overlay window for seamless note-taking.**

[![Flutter](https://img.shields.io/badge/Flutter-3.11.4-blue?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](#license)
[![Dart](https://img.shields.io/badge/Dart-3.11-blue?logo=dart)](https://dart.dev)

---

## Features

### 📝 Note Capture
- **Voice Capture**: Long-press Android floating bubble for instant voice-to-text capture
- **Text Input**: Write directly in the app's thought canvas or overlay text panel
- **Offline-First**: Save instantly to local Isar database—no internet required
- **Real-Time Sync**: Notes automatically sync to Firestore when network available

### 🤖 AI-Powered Classification
- **Gemini Integration**: Automatic title extraction and note categorization
- **6 Smart Categories**: Tasks, Reminders, Ideas, Follow-ups, Journal, General
- **Priority Inference**: High/Medium/Low priority auto-detected
- **Date Extraction**: Automatic calendar date/time parsing from note content
- **Event-Driven Architecture**: AI processing and cloud sync trigger instantly and asynchronously upon local save, preserving battery life and eliminating polling.

### 📂 Organization & Search
- **Smart Folders**: Browse notes by category with real-time count badges
- **Fuzzy Search**: Full-text search across titles and note bodies
- **Edit & Update**: Modify notes inline with Firestore sync
- **Status Tracking**: Active, Pending AI, or Archived states

### ☁️ Cloud Synchronization
- **Firestore Integration**: Cloud backup and multi-device sync
- **FCM Push Notifications**: Real-time push triggers from other devices
- **Bi-directional Sync**: Changes on any device instantly reflect everywhere
- **Conflict Resolution**: Automatic merge with server-side timestamps

### 🔗 External Integrations
- **Google Calendar**: Auto-create calendar events from dated notes
- **Google Tasks**: Sync task-category notes to Google Tasks
- **Telegram Daily Digest**: Client-side scheduled WorkManager task delivers a 9 AM summary locally (No paid cloud functions required).

### 🎨 User Experience
- **Theme Support**: Light/Dark/System theme with persistent preference
- **Glass UI**: Modern glassmorphic design using Material Design 3
- **Android Overlay**: Floating bubble with draggable positioning and edge-snap physics
- **Permission Handling**: Graceful flows for microphone and overlay permissions

---

## Quick Start

### Prerequisites
- Flutter SDK 3.11.4+
- Dart 3.11+
- Android SDK 31+ or Xcode 13+
- Firebase project with Firestore + Authentication enabled

### Setup Steps

1. **Clone & Install**
   ```bash
   git clone <repo>
   cd wishperlog
   flutter pub get
   ```

2. **Configure Environment**
   ```bash
   cp .env.example .env
   # Edit .env with your credentials:
   # - GOOGLE_GEMINI_API_KEY
   # - TELEGRAM_BOT_USERNAME (optional)
   ```

3. **Firebase Setup**
   - Create Firebase project at console.firebase.google.com
   - Enable Google authentication and Firestore
   - Download google-services.json → android/app/
   - Configure iOS via Firebase Console

4. **Code Generation**
   ```bash
   flutter pub run build_runner build
   ```

5. **Run**
   ```bash
   flutter run
   ```

---

## Architecture

WhisperLog follows **Clean Architecture** with layers for Presentation, Features, and Data. See [ARCHITECTURE.md](ARCHITECTURE.md) for:
- Complete system diagrams (Mermaid)
- Database schemas (Isar + Firestore)
- Data pipeline flows
- Service descriptions
- 30-item tech stack reference

---

## Data Pipeline

### Save Flow (Local-First, Async Cloud)
1. User enters text/voice in Home Canvas or overlay bubble
2. CaptureService validates and creates Note with `status: pendingAi`
3. Note saved to **Isar database** instantly (< 50ms)
4. User sees "Saved" toast immediately
5. Background: event-driven AI orchestration invokes Gemini classification per newly saved note and updates status to `active`
6. Background: FirestoreNoteSyncService → pushes to `users/{uid}/notes/{noteId}`

**Guarantee**: Notes save instantly locally even if Firebase is offline.

### View & Search
- **Home Screen**: StreamBuilder on category counts (real-time updates)
- **Folder Screen**: StreamBuilder on filtered notes by category
- **Search**: Fuzzy matching across title + cleanBody fields

### Edit & Sync
- Modify note fields → NoteRepository.updateEditedNote()
- Isar transaction updates locally
- Firestore sync with `merge: true` (server timestamp conflict resolution)

---

## Project Structure

```
lib/
├── main.dart                    # App startup with 13-step init sequence
├── app/router.dart              # GoRouter with auth-based navigation
├── core/                        # DI, storage, config, themes
├── features/                    # Modular feature packages
│   ├── auth/                    # Google Sign-In & UserRepository
│   ├── capture/                 # CaptureService for ingestion
│   ├── notes/                   # NoteRepository & CRUD
│   ├── home/                    # HomeScreen with writing box
│   ├── folder/                  # FolderScreen (category view)
│   ├── overlay_v1/              # Floating bubble (separate isolate)
│   ├── ai/                      # AiProcessingService & Gemini
│   └── sync/                    # Firestore, FCM, ExternalSync services
└── shared/                      # Models, enums, reusable widgets
```

---

## Key Services

| Service | Purpose |
|---------|---------|
| **CaptureService** | Ingest raw transcripts → create Note objects |
| **NoteRepository** | Central CRUD interface for all note operations |
| **AiProcessingService** | Event-driven Gemini classify → set to active |
| **FirestoreNoteSyncService** | Bi-directional sync with conflict resolution |
| **OverlayCoordinator** | Manage floating bubble state & permissions |
| **ExternalSyncService** | Google Calendar/Tasks event creation |
| **FcmSyncService** | FCM token registration & message handling |

---

## Tech Stack

**Frontend**: Flutter 3.11.4 • Material Design 3 • GoRouter • BLoC  
**State**: GetIt • Streams • ValueNotifier  
**Storage**: Isar (local) • Firestore (cloud)  
**AI**: Google Gemini • Google Calendar/Tasks APIs  
**Platform**: flutter_overlay_window • speech_to_text • permission_handler  
**Utilities**: connectivity_plus • workmanager • flutter_dotenv  

See [ARCHITECTURE.md](ARCHITECTURE.md#tech-stack) for 30-item detailed reference.

---

## Troubleshooting

**"Unable to save note" error**: Check logs for `[CaptureService]` errors. Restart app to reinitialize. See [issues.md](issues.md) for debugging.

**Overlay not showing**: Grant "Display over other apps" permission in Android Settings.

**FCM not working**: Verify google-services.json is in android/app/ and Firebase project is properly configured.

**Notes not syncing**: Check internet connection. Ensure Firebase auth is initialized (check logs).

---

## Contributing

PRs welcome! Before submitting:
1. `flutter analyze` (zero issues)
2. `dart format lib/`
3. Test on Android device + simulator
4. Describe changes in PR

---

## License

MIT License. See LICENSE file.

---

**Made with ❤️ for seamless note-taking.**
