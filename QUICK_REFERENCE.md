# WhisperLog - Quick Reference Guide

## 📂 Project Structure at a Glance

```
wishperlog/
├── lib/
│   ├── main.dart                          # App entry point
│   ├── firebase_options.dart              # Firebase config
│   ├── app/
│   │   └── router.dart                    # GoRouter navigation (8 routes)
│   ├── core/                              # Infrastructure layer
│   │   ├── config/
│   │   │   └── app_env.dart               # Environment variables
│   │   ├── di/
│   │   │   └── injection_container.dart   # Service locator (GetIt)
│   │   ├── storage/
│   │   │   └── isar_service.dart          # Database singleton
│   │   ├── settings/
│   │   │   └── app_preferences_repository.dart # User prefs
│   │   ├── theme/
│   │   │   ├── app_theme.dart             # Material Design 3
│   │   │   └── theme_cubit.dart           # Theme state
│   │   └── background/
│   │       ├── work_manager_service.dart  # Background tasks
│   │       └── connectivity_sync_coordinator.dart # Network triggers
│   ├── features/                          # Feature modules
│   │   ├── auth/data/repositories/
│   │   │   └── user_repository.dart       # Auth + Firestore user
│   │   ├── capture/data/
│   │   │   └── capture_service.dart       # Note ingestion
│   │   ├── notes/data/
│   │   │   └── note_repository.dart       # CRUD + streams
│   │   ├── ai/data/
│   │   │   ├── ai_processing_service.dart # 8-sec polling loop
│   │   │   └── gemini_note_classifier.dart # Gemini AI
│   │   ├── sync/data/
│   │   │   ├── firestore_note_sync_service.dart      # Cloud sync
│   │   │   ├── external_sync_service.dart            # Google APIs
│   │   │   ├── fcm_sync_service.dart                 # Push notifications
│   │   │   └── google_api_client.dart                # OAuth HTTP client
│   │   ├── overlay_v1/                    # Floating bubble (Android)
│   │   │   ├── overlay_coordinator.dart   # Lifecycle manager
│   │   │   ├── domain/ (state models)
│   │   │   ├── data/ (preferences, logging)
│   │   │   └── presentation/ (UI, dialogs, screens)
│   │   ├── home/                          # Main screen
│   │   ├── settings/                      # Settings screen
│   │   └── notes/                         # Category folders
│   ├── shared/                            # Shared layer
│   │   ├── models/
│   │   │   ├── note.dart                  # Isar Note collection
│   │   │   ├── enums.dart                 # Category, Priority, Status
│   │   │   └── user.dart                  # User model
│   │   └── widgets/                       # Reusable UI
│   │       ├── glass_container.dart       # Glassmorphic component
│   │       └── glass_page_background.dart # Page styling
├── android/                               # Android native code
│   └── app/src/main/AndroidManifest.xml  # SYSTEM_ALERT_WINDOW permission
├── ios/                                   # iOS native code
├── pubspec.yaml                           # Dependencies (30 packages)
├── analysis_options.yaml                  # Linting rules
├── ARCHITECTURE.md                        # Full architecture doc
├── ARCHITECTURE_DIAGRAMS.md              # Mermaid diagrams
├── TOOLS_AND_TECHNOLOGIES.md             # Tech stack reference
└── SETUP_GUIDE.md                        # Development setup
```

---

## 🛠️ Key Technologies by Layer

### Presentation Layer
- **Flutter** + **Material Design 3** (Light/Dark themes)
- **GoRouter** (Type-safe navigation)
- **BLoC** (State management via ThemeCubit)

### State & Dependency Injection
- **GetIt** (Service locator with 12+ singletons)
- **ValueNotifier** (Reactive updates in overlay)
- **Streams** (Lazy watching in NoteRepository)

### Data Persistence
- **Isar** (Local NoSQL: Thread-safe, transactions, recovery)
- **SharedPreferences** (Settings: theme, time, overlay state)

### Cloud & Auth
- **Firebase Auth** + **Google Sign-In** (OAuth)
- **Cloud Firestore** (Cloud DB: users/{uid}/notes/{noteId})
- **FCM** (Push notifications & sync triggers)

### AI & Services
- **Google Gemini** (Note classification)
- **Google Calendar API** (Event sync)
- **Google Tasks API** (Task sync)
- **Fuzzy Search** (Reconciliation)

### Platform Integration
- **flutter_overlay_window** (Android overlay, v0.5.0)
- **speech_to_text** (Voice recognition, on-device)
- **permission_handler** (Runtime perms with fallback)
- **connectivity_plus** (Network monitoring)
- **workmanager** (Background tasks: 4-hour sync)

---

## 📊 Data Models

### Note (Isar Collection)
```dart
Note {
  String noteId           // Primary key (custom hash)
  String uid              // Firebase user ID
  String rawTranscript    // Original voice-to-text
  String title            // AI-derived or user title
  String cleanBody        // AI-processed content
  NoteCategory category   // 6 types
  NotePriority priority   // High|Medium|Low
  DateTime createdAt      // Capture time
  DateTime updatedAt      // Last modification
  NoteStatus status       // Active|Archived|PendingAi
  String aiModel          // Model used
  String? gcalEventId     // Google Calendar link
  String? gtaskId         // Google Tasks link
  CaptureSource source    // Voice|Text|HomeWritingBox
  DateTime? syncedAt      // Cloud sync timestamp
}
```

### Note Status Lifecycle
```
Creating (User voice/text input)
        ↓
PendingAi (Queued for AI)
        ↓
Active (AI processed, visible in folder)
        ↓
Archived (User-marked as done/deleted)
```

---

## 🔄 Core Data Flows

### Flow 1: Voice Capture (Overlay)
```
Long-Press Bubble
  ↓ [Check microphone permission]
  ↓ [Initialize SpeechToText with onDevice: true]
  ↓ [Recording in listening state - blue pulse]
Release
  ↓ [Stop listening]
  ↓ [CaptureService.ingestRawCapture(syncToCloud: false)]
  ↓ [Isar.writeTxn() - save locally]
  ↓ [_promotePendingNote() - queue for AI]
  ↓ [Show toast "Saved"]
```

### Flow 2: Home Screen To Cloud
```
Type in Thought Canvas
  ↓ [Hit "Save" button]
  ↓ [CaptureService.ingestRawCapture(syncToCloud: true)]
  ↓ [Isar.writeTxn()] - local save
  ↓ [_promotePendingNote()] - queue for AI (async)
  ↓ [Firestore.set()] - cloud backup (async, unwaited)
  ↓ [Show snackbar + update counts]
```

### Flow 3: AI Processing (Every 8 Seconds)
```
AiProcessingService.start()
  ↓ [Query: Isar.notes.filter().statusEqualTo(pendingAi)]
  ↓ For each pending:
      - GeminiNoteClassifier.classify()
      - Extract: title, category, priority, date
      - Isar.writeTxn() - update with status: active
      - _syncNoteToFirestore() (async)
  ↓ [Note now visible in Folder]
```

### Flow 4: Bi-directional Cloud Sync
```
Network Online
  ↓ [ConnectivitySyncCoordinator triggers]
  ↓ [AiProcessingService.flushPendingQueue()]
  ↓ [FirestoreNoteSyncService.syncNoteById()]
  ↓ [ExternalSync.syncExternalForNote()]
      - Google Calendar (if date extracted)
      - Google Tasks (if category == tasks)
  ↓ [FCM token registration]
```

---

## 🎯 Initialization Sequence

1. **main.dart**: WidgetsFlutterBinding.ensureInitialized()
2. **FCM**: ensureFcmBackgroundHandlerRegistered()
3. **Config**: AppEnv.load() from .env
4. **Firebase**: Firebase.initializeApp()
5. **Database**: IsarService.instance.init()
6. **BackgroundTasks**: WorkManager.initialize() + registerPeriodicSync()
7. **DI**: init() - Register 12+ singletons in GetIt
8. **Theme**: ThemeCubit.hydrate() - Load saved theme
9. **Overlay**: OverlayCoordinator.hydrateAndRestore() - Boot if enabled
10. **AI**: AiProcessingService.start() - 8-sec polling
11. **Connectivity**: ConnectivitySyncCoordinator.start() - Monitor network
12. **FCM**: FcmSyncService.initialize() - Listen for messages
13. **App**: runApp(MyApp) with GoRouter

---

## 🔐 Security & Permissions

### Android Permissions
- `INTERNET` - Cloud services
- `RECORD_AUDIO` - Voice capture
- `SYSTEM_ALERT_WINDOW` - Overlay display
- `ACCESS_NETWORK_STATE` - Connectivity check
- `WAKE_LOCK` - Background processing
- `RECEIVER_BOOT_COMPLETED` - Start on boot

### Firebase Security Rules
```
rules_version = '2';
service cloud.firestore {
  match /users/{userId} {
    allow read, write: if request.auth.uid == userId;
    match /notes/{noteId} {
      allow read, write: if request.auth.uid == userId;
    }
  }
}
```

### OAuth Scopes
- `email` - User email
- `profile` - User name & photo
- `Google Calendar API` - Create/modify events
- `Google Tasks API` - Create/modify tasks

---

## 🛣️ Navigation Routes

| Route | Screen | Purpose & Flow |
|-------|--------|----------------|
| `/` | SignInScreen | Default, redirects to home if authenticated |
| `/signin` | SignInScreen | Google OAuth entry point |
| `/permissions` | PermissionsScreen | Runtime permission flow |
| `/telegram` | TelegramScreen | Telegram bot integration |
| `/home` | HomeScreen | Main app after auth - Thought Canvas + category grid |
| `/folder` | FolderScreen | Category-based note list with edit sheet |
| `/settings` | SettingsScreen | App settings + Floating Capture toggle |
| `/settings/overlay-customization` | OverlayCustomizationScreen | Bubble appearance tuning (opacity, size, snap) |

---

## 💾 Persistence Layers

### Isar Database
- **Collection**: Note (primary model)
- **Location**: `getApplicationSupportDirectory()`
- **Transactions**: Atomic multi-record updates with `writeTxn()`
- **Queries**: Lazy watch streams with `.watch()`
- **Recovery**: Auto-purge & reinitialize on schema mismatch

### SharedPreferences
```
wishperlog.theme_mode          → "system" | "light" | "dark"
wishperlog.digest_hour         → 9 (default)
wishperlog.digest_minute       → 0 (default)
wishperlog_overlay.visible     → true | false
wishperlog_overlay.position_x  → double
wishperlog_overlay.position_y  → double
wishperlog_overlay.opacity     → 0.4 (default, 0.1-1.0)
wishperlog_overlay.size        → 56.0 (default, 40-80)
wishperlog_overlay.snap_enable → true (default)
```

### Firestore
- **Collection**: `users/{uid}/notes/{noteId}`
- **Merge Strategy**: `SetOptions(merge: true)` to avoid overwriting
- **Sync Trigger**: Network availability + 4-hour periodic task
- **Offline Queue**: Queued locally, synced when online

---

## 📱 UI Components

### Glassmorphic Design
- **GlassContainer**: Reusable frosted glass effect
  - `BackdropFilter` + `ImageFilter.blur()`
  - Adjustable opacity and border
- **GlassPageBackground**: Full-page frosted background
- **GlassNoteCard**: Note card with glass styling

### Overlay States
- **Idle**: 56dp circle, white 5% opacity, white icon
- **Listening**: Blue pulse (0.75-1.0 scale), 1.1× size, blue icon
- **Processing**: Orange indicator, 1.04× scale, hourglass icon
- **TextPanel**: Glassmorphic bottom sheet with auto-focused input

### Animations
- **EdgeSnap**: 260ms easing.outCubic for edge snap
- **Pulse**: 880ms repeating for listening state
- **Transition**: 220ms AnimatedSwitcher between bubble/text panel
- **Scale**: 140ms AnimatedScale for size changes

---

## 🔧 Common Commands

```bash
# Development
flutter pub get                               # Install dependencies
flutter analyze                               # Lint code
flutter run                                   # Run on device/emulator
flutter build apk --release                   # Build Android APK

# Code Generation
flutter pub run build_runner build            # Generate Isar schema
flutter pub run build_runner watch            # Watch for changes

# Database
# (Isar manages schema automatically)

# Testing
flutter test                                  # Run unit tests
flutter test integration_test/                # Run integration tests

# Cleanup
flutter clean                                 # Clean build outputs
dart fix --apply                             # Auto-fix Dart issues
```

---

## 📈 Performance Metrics

| Metric | Target | Implementation |
|--------|--------|-----------------|
| App Startup | < 3 seconds | Lazy DI, async init |
| Note Save | < 200ms | Isar transaction |
| AI Processing | 8-second polling | Background service |
| Cloud Sync | 4-hour periodic | WorkManager |
| Voice Capture | Real-time | On-device SpeechToText |
| UI Response | 60 FPS | Efficient streams, animated widgets |

---

## 🐛 Debugging Tips

### Enable Debug Logging
```dart
// In lib/features/overlay_v1/data/overlay_v1_logger.dart
OverlayV1Logger.event('event_name', {'key': 'value'});
```

### Check Isar Database
```dart
// In main.dart or any screen
final db = await IsarService.instance.init();
final allNotes = await db.notes.where().findAll();
debugPrint('Total notes: ${allNotes.length}');
```

### View Firebase Console
1. Go to https://console.firebase.google.com
2. Select "wishperlog" project
3. Browse collections under Firestore Database

### Check FCM Token
```dart
final db = await IsarService.instance.init();
final user = db.users.getByUid(FirebaseAuth.instance.currentUser?.uid);
debugPrint('FCM Token: ${user?.fcmToken}');
```

### Test Connectivity
```bash
flutter run --dart-define=LOG_LEVEL=debug    # Enable verbose logging
```

---

## 🚀 Deployment Checklist

- [ ] `flutter analyze` passes with zero issues
- [ ] All API keys in `.env` (not in code)
- [ ] Firebase project configured
- [ ] Google Calendar/Tasks scopes authorized
- [ ] Android SDK 35, iOS 12.0+
- [ ] Build APK: `flutter build apk --release --target-platform android-arm64`
- [ ] Test on real device (overlay requires physical phone)
- [ ] FCM token registration working
- [ ] Offline + online sync tested
- [ ] AI classification accuracy validated
- [ ] Google Calendar/Tasks bidirectional sync verified

---

## 📚 Documentation Links

- **Full Architecture**: [ARCHITECTURE.md](ARCHITECTURE.md)
- **Diagrams**: [ARCHITECTURE_DIAGRAMS.md](ARCHITECTURE_DIAGRAMS.md)
- **Tech Stack**: [TOOLS_AND_TECHNOLOGIES.md](TOOLS_AND_TECHNOLOGIES.md)
- **Setup Guide**: [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Dependencies**: [pubspec.yaml](pubspec.yaml)

---

## 👤 Developer Notes

- **Architecture Pattern**: Clean Architecture + BLoC
- **Data Philosophy**: Local-first with optional cloud backup
- **Error Handling**: Graceful degradation, detailed logging
- **Testing**: Unit tests, integration tests, manual device testing
- **Version Control**: Semantic versioning (MAJOR.MINOR.PATCH+BUILD)
- **Code Quality**: flutter_lints with strict analysis

---

**Last Updated**: April 4, 2026  
**WhisperLog Version**: 1.0.0+1  
**Flutter SDK**: ^3.11.4
