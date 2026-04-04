# WhisperLog Architecture Documentation

## Project Overview

**WhisperLog** is a feature-rich voice and text logger application with AI-powered note categorization, cloud synchronization, and Google service integration. The app emphasizes local-first data storage with optional cloud backup and provides a floating overlay window for always-on voice capture on Android devices.

- **Target Platforms**: Android, iOS, Web, Windows, macOS, Linux
- **Architecture Pattern**: Clean Architecture with BLoC state management
- **Language**: Dart/Flutter
- **SDK Version**: ^3.11.4

---

## Core Technology Stack

### Frontend & UI Framework
- **Flutter**: Cross-platform mobile UI framework
- **Material Design 3**: Material design system with light/dark theme support
- **GoRouter**: Type-safe routing and navigation
- **BLoC**: State management pattern with `flutter_bloc`
- **GetIt**: Service locator for dependency injection

### Database & Storage
- **Isar**: Local NoSQL database for offline-first note storage
  - Thread-safe operations with transaction support
  - Automatic schema migration with recovery mechanism
  - Collections: `Note` (primary model)
- **SharedPreferences**: Key-value storage for user preferences and overlay settings

### Cloud & Backend Services
- **Firebase Core**: Base Firebase initialization
- **Firebase Authentication**: Google Sign-In for user authentication
- **Cloud Firestore**: Cloud database for note synchronization
  - Collection path: `users/{uid}/notes/{noteId}`
  - Bi-directional sync with local Isar database
- **Firebase Cloud Messaging (FCM)**: Real-time sync triggers and notifications
  - Token-based authentication
  - Background message handling

### AI & External Integrations
- **Google Generative AI (Gemini)**: AI-powered note classification
  - Extract title and clean content
  - Categorize notes (tasks, reminders, ideas, followUp, journal, general)
  - Priority inference
  - Date/time extraction for calendar events
- **Google APIs**:
  - **Google Calendar API**: Create/sync calendar events
  - **Google Tasks API**: Create/sync task items
  - OAuth authentication flow
- **Fuzzy Search**: Fuzzy string matching for external sync reconciliation

### Platform & System Integration
- **flutter_overlay_window**: Android overlay window for floating capture
- **permission_handler**: Runtime permission management (microphone, overlay)
- **speech_to_text**: On-device voice-to-text conversion
- **connectivity_plus**: Network state monitoring and offline detection
- **workmanager**: Background task scheduling and periodic sync

### Development & Build
- **flutter_lints**: Dart/Flutter linting rules
- **build_runner**: Code generation orchestrator
- **isar_generator**: Isar schema code generation
- **flutter_dotenv**: Environment variable management

---

## Application Architecture

### Entry Points

#### 1. Main Application (`lib/main.dart`)
- **Purpose**: Primary application bootstrap
- **Initialization Sequence**:
  ```
  1. WidgetsFlutterBinding.ensureInitialized()
  2. FCM background handler registration (ensureFcmBackgroundHandlerRegistered)
  3. Load environment variables (AppEnv.load())
  4. Initialize Firebase (Firebase.initializeApp)
  5. Initialize Isar local database (IsarService.instance.init)
  6. Setup WorkManager background tasks
  7. Initialize dependency injection (init() from injection_container)
  8. Hydrate theme mode (sl<ThemeCubit>().hydrate())
  9. Hydrate and restore overlay (sl<OverlayCoordinator>().hydrateAndRestore())
  10. Start AI processing service (sl<AiProcessingService>().start())
  11. Start connectivity sync coordinator (sl<ConnectivitySyncCoordinator>().start())
  12. Initialize FCM (sl<FcmSyncService>().initialize())
  13. Run main app with GoRouter
  ```
- **Entry Reference**: Overlay entry point stored as `_overlayEntrypointReference`

#### 2. Overlay Isolate Entry (`lib/features/overlay_v1/presentation/overlay_entrypoint.dart`)
- **Purpose**: Separate Flutter isolate for floating overlay window
- **Marked with**: `@pragma('vm:entry-point')`
- **Process**:
  1. Initialize Flutter binding
  2. Initialize Isar (graceful failure allowed)
  3. Boot `OverlayV1App` → `OverlayBubbleWidget`
  4. Runs in isolated process managed by `flutter_overlay_window`

---

## Layered Architecture

### 1. Core Layer (`lib/core/`)

#### Configuration (`core/config/`)
- **AppEnv**: Environment variable loader
  - `.env` file parser
  - Firebase configuration

#### Dependency Injection (`core/di/`)
- **injection_container.dart**: GetIt setup
- **Registered Singletons**:
  - `AppPreferencesRepository` - User preferences
  - `UserRepository` - Firebase auth & Firestore user management
  - `NoteRepository` - Note CRUD operations
  - `ExternalSyncService` - Google Calendar/Tasks sync
  - `CaptureService` - Note ingestion pipeline
  - `OverlayV1Preferences` - Overlay state persistence
  - `OverlayCoordinator` - Overlay lifecycle management
  - `FirestoreNoteSyncService` - Cloud sync service
  - `AiProcessingService` - Background AI processing
  - `FcmSyncService` - Firebase messaging
  - `ConnectivitySyncCoordinator` - Network-based sync triggers
  - `ThemeCubit` - Theme state management

#### Storage (`core/storage/`)
- **IsarService**: Isar database singleton
  - Thread-safe initialization with retry logic (20 attempts)
  - Automatic recovery from corrupted files
  - Schema version management
  - Supported collections: `Note`

#### Settings (`core/settings/`)
- **AppPreferencesRepository**: SharedPreferences wrapper
  - Theme mode (light|dark|system, default: system)
  - Digest time (hour/minute, default: 09:00)

#### Theme (`core/theme/`)
- **app_theme.dart**: Material Design 3 themes (light/dark)
- **theme_cubit.dart**: BLoC for theme state with persistence

#### Background Tasks (`core/background/`)
- **WorkManagerService**: Background task orchestration
  - Periodic Google Tasks sync: every 4 hours
  - Constraints: network connected, battery not low
  - Retry: exponential backoff (30-minute intervals)
- **ConnectivitySyncCoordinator**: Network change monitoring
  - Triggers flush of pending AI processing when online
  - Retries with exponential backoff (15-minute intervals)

---

### 2. Shared Layer (`lib/shared/`)

#### Data Models
- **Note** (`shared/models/note.dart`):
  - Isar collection with custom ID hashing
  - Fields:
    ```
    noteId (string, primary key via fastHash)
    uid (Firebase user ID or 'local_anonymous')
    rawTranscript (original voice-to-text)
    title (AI-derived or user-provided)
    cleanBody (AI-processed content)
    category (NoteCategory: tasks|reminders|ideas|followUp|journal|general)
    priority (NotePriority: high|medium|low)
    extractedDate (DateTime, optional)
    createdAt (DateTime)
    updatedAt (DateTime)
    status (NoteStatus: active|archived|pendingAi)
    aiModel (model name used for processing)
    gcalEventId (Google Calendar event link)
    gtaskId (Google Tasks list link)
    source (CaptureSource: voiceOverlay|textOverlay|homeWritingBox)
    syncedAt (last cloud sync timestamp)
    ```
  - **Custom ID Logic**: `fastHash()` - XOR-based hashing for Isar compatibility

- **Enums** (`shared/models/enums.dart`):
  - `NoteCategory`: 6 categories for note classification
  - `NotePriority`: 3 priority levels
  - `NoteStatus`: 3 states (active, archived, pendingAi)
  - `CaptureSource`: 3 capture origins

- **User** (`shared/models/user.dart`):
  - Firebase user data wrapper

#### Widgets & Utilities
- **shared/widgets/**: Reusable UI components
  - `GlassContainer`: Glassmorphic design component
  - `GlassPageBackground`: Page background with glass effect
  - `GlassNoteCard`: Reusable note card widget
- **shared/models/note_helpers.dart**: Utility functions for note operations

---

### 3. Features Layer (`lib/features/`)

#### Authentication Feature (`features/auth/`)
- **UserRepository**:
  - Google Sign-In integration
  - Firebase Auth state stream
  - Firestore user document management
  - FCM token registration and updates
  - Exception handling with developer-friendly errors (SHA-1 mismatch)
- **Onboarding Screens**:
  - SignInScreen: Google OAuth entry point
  - PermissionsScreen: Runtime permission requests
  - TelegramScreen: Telegram bot connection flow

#### Note Capture Feature (`features/capture/`)

**Data Layer**:
- **CaptureService**:
  - Main ingestion pipeline for voice/text
  - Operations:
    1. Validate and trim input text
    2. Generate unique noteId (timestamp + 20-bit random)
    3. Create Note with `status: pendingAi`
    4. Store in Isar with transaction
    5. Optional Firestore sync (controlled by `syncToCloud` parameter)
    6. Queue for AI processing via `_promotePendingNote()`
  - Dependencies: GeminiNoteClassifier, Firebase, IsarService
  - Error handling: Try-catch with detailed logging

- **CaptureNoteRepository**: Alternative capture path (legacy)

#### Notes Management Feature (`features/notes/`)

**Data Layer**:
- **NoteRepository**:
  - CRUD operations on Note collection
  - Key methods:
    - `savePendingFromHome(text)`: User-typed notes
    - `archive(noteId)`: Mark as archived
    - `unarchive(noteId)`: Restore archived notes
    - `watchActiveCounts()`: Stream of per-category counts
    - `watchActiveByCategory(category)`: Stream of category notes
    - `watchAllActive()`: Stream of all active notes
    - `watchPendingAiCount()`: Stream of pending count
  - Uses Isar transactions for atomicity
  - Firestore sync for cloud backup

**Presentation Layer**:
- **FolderScreen**: Category-based note list with:
  - Live note count updates
  - AI processing status banner
  - Note editing bottom sheet
  - Archive/unarchive actions

#### AI Processing Feature (`features/ai/`)

**Data Layer**:
- **AiProcessingService**:
  - Autonomous background processor
  - Periodic checking every 8 seconds
  - Operations per note:
    1. Find notes with `status: pendingAi`
    2. Call `GeminiNoteClassifier.classify()`
    3. Update note with AI results
    4. Sync to Firestore
  - Single instance prevents concurrent processing
  - Methods: `start()`, `flushPendingQueue()`, `dispose()`

- **GeminiNoteClassifier**:
  - Google Generative AI (Gemini) integration
  - Extracts:
    - Enhanced title from transcript
    - Category classification
    - Priority inference
    - Action items
    - Relevant dates for calendar/task sync

#### Synchronization Feature (`features/sync/`)

**Data Layer**:

1. **FirestoreNoteSyncService**:
   - Bi-directional cloud sync
   - Cloud path: `users/{uid}/notes/{noteId}`
   - Methods:
     - `syncNoteById()`: Fetch from cloud, update local
     - `applyStatusFromPush()`: Handle FCM status changes
     - `watchAndSyncArchive()`: Keep archive status in sync

2. **ExternalSyncService**:
   - Google Calendar & Google Tasks integration
   - Ensures OAuth sign-in is connected
   - Syncs active notes to Google services
   - Bidirectional sync for updates
   - Uses fuzzy matching for reconciliation
   - APIs: CalendarApi (v3), TasksApi (v1)

3. **FcmSyncService**:
   - Firebase Cloud Messaging integration
   - Lifecycle:
     - `initialize()`: Register FCM token to Firestore
     - `onMessage`: Handle foreground messages
     - `onMessageOpenedApp`: Handle notification taps
     - Background handler: Process messages while app closed
   - FCM token persisted in Firestore user document

4. **GoogleApiClient**:
   - Authenticated HTTP client for Google APIs
   - Uses GoogleSignIn for OAuth token management

#### Overlay Feature (`features/overlay_v1/`)

**Domain Layer** (`overlay_v1/domain/`):
- **OverlayV1State**:
  - `mode`: OverlayV1Mode (hidden|idle)
  - `position`: Offset (x, y coordinates)
  - `isVisible`: Computed property

- **OverlayBubbleConfig**:
  - `opacity`: 0.1-1.0 (default: 0.4)
  - `size`: 40-80 dp (default: 56)
  - `snapEnabled`: bool (default: true)

**Data Layer** (`overlay_v1/data/`):
- **OverlayV1Preferences**:
  - SharedPreferences persistence
  - Persisted state: visibility, position, opacity, size, snap settings

- **OverlayV1Logger**: Debug logging

**Presentation Layer** (`overlay_v1/presentation/`):

1. **OverlayCoordinator**:
   - Core orchestrator for overlay lifecycle
   - Methods:
     - `requestPermission()`: Two-stage fallback (FlutterOverlayWindow → Permission.systemAlertWindow)
     - `showIdleBubble()`: Boot overlay with current config
     - `hideOverlay()`: Close overlay and persist state
     - `updateBubbleConfig()`: Live config broadcast to isolate
     - `hydrate()`: Load state from SharedPreferences
     - `hydrateAndRestore()`: Load and show if enabled
   - Polling mechanism: 15 attempts × 300ms for permission checks
   - Detailed boot diagnostics and error logging

2. **OverlayBubbleWidget**:
   - State machine for bubble ↔ text panel transitions
   - Visual states:
     - **Idle**: White transparent circle, 56dp, icon: mic_none
     - **Listening**: Blue pulse, 1.1× scale, border prominence, icon: mic, haptic feedback
     - **Processing**: Orange indicator, 1.04× scale, icon: hourglass_bottom
   - Gestures:
     - **Drag**: Pan position with edge snapping (if snapEnabled)
     - **Long press**: Start voice capture (press) → finish (release)
     - **Tap/Double-tap**: Toggle text panel
   - Voice capture lifecycle:
     1. Check microphone permission
     2. Initialize speech_to_text with onDevice: true
     3. Listen and accumulate transcript with partialResults
     4. On release: stop listening, process, save to Isar
     5. Empty transcript filtering
   - Text panel lifecycle:
     1. Resize window from bubble to 240dp height
     2. Auto-focus text field
     3. Save → Isar ingestion with syncToCloud: false
   - Toast system: Auto-dismiss after 900ms
   - Dependencies: SpeechToText, CaptureService, FlutterOverlayWindow

3. **OverlayPermissionExplainerDialog**:
   - Glassmorphic dialog explaining SYSTEM_ALERT_WINDOW requirement
   - Shown before permission request

4. **OverlayCustomizationScreen**:
   - Settings screen for opacity/size/snap tuning
   - Real-time slider updates broadcast to active overlay

#### Home Screen Feature (`features/home/`)
- **HomeScreen**:
  - Large multiline "Thought Canvas" for quick text capture
  - Inline dictation controls with mic glow animation
  - Category grid with live note counts
  - Search integration
  - Voice support with animated listening state

#### Settings Feature (`features/settings/`)
- **SettingsScreen**:
  - Theme mode selection
  - Digest time configuration
  - Floating Capture toggle with permission auto-check
  - Telegram bot connection
  - Sync now trigger
  - Notification settings

---

## Data Flow Architecture

### 1. Voice Capture Lifecycle (Overlay)
```
User Long-Press Bubble
    ↓
_onLongPressStart()
    ↓
Mic permission check
    ↓
Initialize SpeechToText (onDevice: true)
    ↓
Visual: Listening state (blue pulse)
    ↓
Accumulate transcript via partialResults
    ↓
User Releases
    ↓
_onLongPressEnd()
    ↓
Stop listening
    ↓
[Empty filter] → discard if blank
    ↓
CaptureService.ingestRawCapture(syncToCloud: false)
    ↓
Isar.writeTxn() → save locally
    ↓
Show toast "Saved"
    ↓
Return to Idle state
```

### 2. Home Screen Text Capture Lifecycle
```
User types in Thought Canvas
    ↓
Hits "Save" button
    ↓
_saveWritingBox()
    ↓
CaptureService.ingestRawCapture(syncToCloud: true)
    ↓
Isar.writeTxn() → save locally
    ↓
_promotePendingNote() → queue for AI (async)
    ↓
Firestore.set() → sync to cloud (async, unwaited)
    ↓
Show snackbar "Note saved"
    ↓
Clear text field
```

### 3. AI Processing Lifecycle
```
AiProcessingService.start() → 8-second polling loop
    ↓
Query Isar: notes.filter().statusEqualTo(pendingAi).findAll()
    ↓
For each pending note:
  ├─ GeminiNoteClassifier.classify()
  ├─ Extract: title, category, priority, date, content
  └─ Update note fields
    ↓
Isar.writeTxn() → save updated note with status: active
    ↓
_syncNoteToFirestore() → cloud sync (async)
    ↓
Note now visible in Folder screens
```

### 4. Cloud Synchronization Lifecycle
```
Network State Change (Online)
    ↓
ConnectivitySyncCoordinator detects change
    ↓
Trigger: AiProcessingService.flushPendingQueue()
    ↓
ExternalSync.syncExternalForNote() for active notes
    ↓
FirestoreNoteSyncService.syncNoteById() for pending sync
    ↓
FCM registration and sync status updates
    ↓
All notes synced to cloud
```

---

## State Management Strategy

### BLoC Pattern
- **ThemeCubit**: Theme mode (light|dark|system)
  - Persists via SharedPreferences
  - Watches system theme if mode = system

### Reactive Streams
- **NoteRepository**: Isar lazy watch streams
  - `watchActiveCounts()`: Per-category sync with Firestore
  - `watchActiveByCategory()`: Real-time note list updates
  - `watchPendingAiCount()`: AI processing progress indicator
  - `watchAllActive()`: App-wide note stream

### ValueNotifier Pattern
- **OverlayCoordinator**:
  - `state`: OverlayV1State (mode, position)
  - `bubbleConfig`: OverlayBubbleConfig (opacity, size, snap)
  - Listeners broadcast changes to overlay isolate via `shareData()`

---

## Error Handling & Recovery

### Database Layer
- **Isar Corruption Recovery**:
  - Automatic purge and reinitialize on schema mismatch
  - 20-attempt retry with 50ms delays on lock conflicts
  - Graceful degradation if init fails temporarily

### Network Layer
- **Firestore Sync**:
  - Silent failures with exponential backoff retry
  - Connection monitoring via ConnectivityPlus
  - Manual "Sync Now" trigger in Settings

### Overlay Layer
- **Permission Fallback**:
  - Primary: `FlutterOverlayWindow.requestPermission()`
  - Fallback: `Permission.systemAlertWindow.request()`
  - Polling: 15 attempts × 300ms after request returns
- **Boot Diagnostics**:
  - Detailed `debugPrint()` logging of every step
  - Stack traces on exceptions
  - NavigatorObserver to catch unexpected routing

### Capture Layer
- **Input Validation**:
  - Trim whitespace
  - Filter empty strings
  - Unique noteId generation (timestamp + random)
- **Error Logging**:
  - Try-catch with stack trace capture
  - Context-aware debug messages

---

## Routing Architecture

### GoRouter Configuration (`lib/app/router.dart`)

| Route | Screen | Purpose |
|-------|--------|---------|
| `/` | SignInScreen | Default redirect |
| `/signin` | SignInScreen | Google OAuth entry |
| `/permissions` | PermissionsScreen | Runtime permission flow |
| `/telegram` | TelegramScreen | Telegram bot connection |
| `/home` | HomeScreen | Main app after auth |
| `/folder` | FolderScreen | Category-based note list |
| `/settings` | SettingsScreen | App settings & overlay toggle |
| `/settings/overlay-customization` | OverlayCustomizationScreen | Bubble appearance tuning |

### Auth Redirect Logic
```
FirebaseAuth.instance.currentUser != null?
  ├─ Yes → Navigate to /home
  └─ No  → Navigate to /signin
```

---

## Platform-Specific Considerations

### Android
- **Overlay**: flutter_overlay_window (v0.5.0)
  - Requires SYSTEM_ALERT_WINDOW permission
  - Separate isolate for window management
  - ForegroundServiceType: specialUse
- **Speech Recognition**: On-device via speech_to_text
- **Permissions**: Runtime via permission_handler

### iOS/Web/Desktop
- **Overlay**: Not available (graceful fallback)
- **Speech Recognition**: Supported via speech_to_text
- **Cloud Sync**: Full support via Firebase

---

## Security & Privacy

### Authentication
- **Firebase Auth**: Google Sign-In with SHA-1 verification
- **OAuth Scope**: Email and profile information
- **Token Management**: Automatic refresh via Firebase

### Data Storage
- **Local**: Isar with no built-in encryption
- **Cloud**: Firestore with user-scoped security rules
  - Rule: `request.auth.uid == userId` for user/{userId} access

### External APIs
- **Google APIs**: OAuth-authenticated HTTP client (google_sign_in)
- **FCM**: Server-to-client authentication via FCM token

---

## Performance Optimization

### Database
- **Lazy Initialization**: IsarService uses `Future<Isar>?` to avoid blocking
- **Transactions**: Batch operations with writeTxn()
- **Indexing**: Primary key on noteId via custom fastHash()

### Background Processing
- **AI Processing**: 8-second periodic polling (not real-time)
- **Sync Debouncing**: Exponential backoff (15-30 min intervals)
- **Network Monitoring**: Connectivity-based sync triggers

### UI
- **AnimatedSwitcher**: Efficient state transitions in overlay
- **Lazy Loading**: Stream builders for list rendering
- **SingleTickerProviderStateMixin**: Minimal animation controllers

---

## Testing Strategy

### Unit Tests
- Note model validation
- Capture service ingestion logic
- AI classification results
- Utility functions (category parsing, date extraction)

### Integration Tests
- Overlay lifecycle (permission → show → hide)
- Capture → AI processing → sync pipeline
- Cloud sync with offline handling
- External service integration

### Manual Testing Checklist
- [ ] Google Sign-In works without ApiException 10
- [ ] Overlay bubble appears as 56dp transparent circle
- [ ] Voice capture saves notes to local database
- [ ] Home canvas save writes to Firestore
- [ ] AI processing categorizes notes
- [ ] Floating capture toggle reads OS permission state
- [ ] Settings save/restore persist across restarts
- [ ] Offline mode captures locally, syncs when online
- [ ] Google Calendar/Tasks sync works bidirectionally

---

## Deployment & Versioning

### Current Version
- **App Version**: 1.0.0+1
- **Build Target**: Android SDK 35, iOS 12.0+

### Dependencies Updates
- **Outdated Packages**: 25 packages have newer versions
- **Constraint Flexibility**: Consider gradual upgrades per platform

---

## Future Enhancements

1. **Encryption**: End-to-end encryption for local and cloud storage
2. **Biometric Auth**: Fingerprint/face unlock for sensitive notes
3. **Batch Sync**: Optimize cloud sync with batching and compression
4. **Custom AI Models**: On-device Gemini Nano for privacy
5. **Voice Commands**: Gesture-based overlay interactions
6. **Multi-device Sync**: Real-time sync across multiple devices
7. **Note Sharing**: Collaborative note-taking features
8. **Widgets**: Home screen widgets for quick access
9. **Accessibility**: Screen reader and high-contrast support
10. **Analytics**: User behavior insights with privacy compliance

---

## Documentation References

- [Flutter Documentation](https://flutter.dev/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [Google APIs for Dart](https://pub.dev/packages/googleapis)
- [Isar Documentation](https://isar.dev/)
- [BLoC Pattern](https://bloclibrary.dev/)
- [GoRouter Documentation](https://pub.dev/packages/go_router)
