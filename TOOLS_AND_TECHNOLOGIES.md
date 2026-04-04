# WhisperLog - Complete Tools & Technologies Reference

## Overview
WhisperLog is a full-stack Flutter application leveraging a modern technology stack for local-first note capture, AI-powered classification, and cloud synchronization.

---

## Frontend & UI Framework

### 1. **Flutter** (v3.11.4+)
- **Purpose**: Cross-platform mobile development framework
- **Targets**: Android, iOS, Web, Windows, macOS, Linux
- **Key Features**:
  - Hot reload for rapid development
  - Single codebase for multiple platforms
  - Rich widget library with Material Design 3 support
- **Package**: `flutter:sdk`

### 2. **Material Design 3**
- **Purpose**: Modern design system with light/dark themes
- **Implementation**: `flutter/material.dart`
- **Features**:
  - Responsive layouts
  - Glassmorphic effects via `BackdropFilter`
  - Theme switching at runtime
  - Semantic color system

### 3. **Flutter BLoC** (v9.1.1)
- **Purpose**: State management pattern implementation
- **Used For**:
  - `ThemeCubit`: Light/dark/system theme state
  - Event-driven state transitions
  - Separation of UI and business logic
- **Documentation**: https://bloclibrary.dev/

### 4. **GoRouter** (v17.2.0)
- **Purpose**: Type-safe, declarative routing and navigation
- **Routes**: 8 main routes defined in `lib/app/router.dart`
- **Features**:
  - Automatic redirect logic based on auth state
  - Deep linking support
  - Route parameters with type safety
  - Nested routes support

---

## State Management & Dependency Injection

### 5. **GetIt** (v9.2.1)
- **Purpose**: Service locator for dependency injection
- **Usage**:
  - Centralized service registration
  - Lazy singleton pattern for all services
  - `final sl = GetIt.instance;`
- **Registered Services**: 12+ repositories, services, and cubits
- **File**: `lib/core/di/injection_container.dart`

### 6. **ValueNotifier & Listeners**
- **Purpose**: Reactive state updates in overlay
- **Used In**: `OverlayCoordinator`
  - `state`: OverlayV1State (mode, position)
  - `bubbleConfig`: OverlayBubbleConfig (opacity, size, snap)
- **Pattern**: Observer pattern for change notifications

### 7. **Streams (Dart)**
- **Purpose**: Async data streams for reactive programming
- **Used In**:
  - `NoteRepository.watchActiveCounts()`
  - `NoteRepository.watchActiveByCategory()`
  - `FirebaseAuth.authStateChanges()`
- **Features**: Lazy evaluation, backpressure handling, error propagation

---

## Local Data Storage

### 8. **Isar** (v3.1.0+1)
- **Purpose**: Fast local NoSQL database for Flutter
- **Collection**: `Note` (Isar collection)
- **Key Features**:
  - Zero-copy access for performance
  - Transactions with `writeTxn()`
  - Full-text search capability
  - Automatic schema management
  - Thread-safe operations
- **Schema**: Generated via `isar_generator`
- **File**: `lib/core/storage/isar_service.dart`
- **Recovery**: Automatic purge & reinitialize on schema mismatch

### 9. **SharedPreferences** (v2.5.3)
- **Purpose**: Light-weight key-value storage for user preferences
- **Stored Data**:
  - Theme mode preference (light|dark|system)
  - Digest time (hour/minute)
  - Overlay state (visibility, position, opacity, size, snap)
- **Wrapper**: `AppPreferencesRepository`, `OverlayV1Preferences`
- **Performance**: In-memory caching with periodic disk sync

---

## Cloud & Authentication

### 10. **Firebase Core** (v4.6.0)
- **Purpose**: Firebase SDK initialization
- **Configuration**: `FirebaseOptions` from `firebase_options.dart`
- **Initialization**: Single instance pattern with error handling

### 11. **Firebase Authentication** (v6.3.0)
- **Purpose**: User identity and access management
- **Provider**: Google Sign-In (OAuth 2.0)
- **Features**:
  - Token management (automatic refresh)
  - Auth state streams
  - User metadata
- **Repository**: `UserRepository` (lib/features/auth/data/repositories/user_repository.dart)
- **Error Handling**: SHA-1 validation for development setup

### 12. **Google Sign-In** (v6.1.5)
- **Purpose**: OAuth authentication via Google accounts
- **Scope**: Email, profile information
- **Flow**:
  1. User taps "Sign in with Google"
  2. OAuth browser flow launches
  3. Token exchanged for Firebase auth
  4. User document created in Firestore
- **Package**: `google_sign_in`

### 13. **Cloud Firestore** (v6.2.0)
- **Purpose**: Cloud NoSQL database with real-time sync
- **Database Structure**:
  ```
  users/{uid}
    ├── email (string)
    ├── displayName (string)
    ├── photoUrl (string)
    ├── fcmToken (string)
    └── notes/{noteId} (subcollection)
        ├── noteId (string)
        ├── uid (string)
        ├── title (string)
        ├── cleanBody (string)
        ├── category (string)
        ├── priority (string)
        ├── createdAt (timestamp)
        ├── status (string)
        ├── syncedAt (timestamp)
        └── ... (20+ fields)
  ```
- **Security Rules**: User-scoped access via `request.auth.uid == userId`
- **Service**: `FirestoreNoteSyncService`

### 14. **Firebase Cloud Messaging** (v16.0.2)
- **Purpose**: Real-time push notifications and sync triggers
- **Features**:
  - Foreground message handling
  - Background message processing
  - Token registration in Firestore
  - FCM topic subscriptions
- **Service**: `FcmSyncService`
- **Use Cases**:
  - Sync notifications from other devices
  - Reminder triggers
  - Note share notifications (future)

---

## AI & Machine Learning

### 15. **Google Generative AI (Gemini)** (v0.4.7)
- **Purpose**: AI-powered note classification and enhancement
- **Provider**: Google AI Studio (via API key from `.env`)
- **Operations**:
  - Extract enhanced title from raw transcript
  - Classify notes into 6 categories (tasks, reminders, ideas, followUp, journal, general)
  - Infer priority levels (high, medium, low)
  - Extract action items and dates
  - Parse calendar/task relevant information
- **Implementation**: `GeminiNoteClassifier`
- **Processing**: Runs autonomously every 8 seconds via `AiProcessingService`
- **Model**: Uses latest Gemini model via API

### 16. **Google APIs for Dart** (v14.0.0)
- **Purpose**: Programmatic access to Google services
- **Sub-packages**:
  - **Google Calendar API (v3)**: Create calendar events from notes with extracted dates
  - **Google Tasks API (v1)**: Create task list items from task-category notes
- **Authentication**: OAuth 2.0 via `GoogleSignIn`
- **Implementation**: `ExternalSyncService`
- **Usage**: Bidirectional sync (push note data, pull updates)

### 17. **Fuzzy** (v0.5.1)
- **Purpose**: Fuzzy string matching for reconciliation
- **Use Case**: Match local notes with external Google Calendar/Tasks events to prevent duplication
- **Algorithm**: Levenshtein distance-based scoring
- **File**: Used in `ExternalSyncService` for `syncExternalForNote()`

---

## Speech & Audio

### 18. **speech_to_text** (v7.0.0)
- **Purpose**: Speech-to-text conversion and voice input
- **Platform Support**: Android (on-device), iOS, Web
- **Configuration**:
  - `onDevice: true` for offline recognition (no cloud upload)
  - `partialResults: true` for real-time transcription
  - Locale: En-US (default)
- **Usage**:
  - Long-press overlay bubble to start listening
  - Real-time transcript update in listening state
  - Empty string filtering before save
- **Integration**: `OverlayBubbleWidget` (lib/features/overlay_v1/presentation/widgets/overlay_bubble_widget.dart)
- **Error Handling**: Graceful fallback if speech recognition unavailable

---

## Platform Integrations

### 19. **flutter_overlay_window** (v0.5.0)
- **Purpose**: Android floating overlay window for always-on capture
- **Platform**: Android only (graceful fallback on other platforms)
- **Features**:
  - Separate Flutter isolate for overlay rendering
  - Draggable window with snap-to-edge physics
  - Configurable window size and opacity
  - Data sharing between main app and overlay isolate
- **Permissions**: `SYSTEM_ALERT_WINDOW` (Android 8.0+)
- **Service**: Managed by `OverlayCoordinator`
- **Entry Point**: `@pragma('vm:entry-point')` in `overlay_entrypoint.dart`

### 20. **permission_handler** (v11.3.1+)
- **Purpose**: Runtime permission requests for Android/iOS
- **Permissions Managed**:
  - `Permission.systemAlertWindow` (overlay display)
  - `Permission.microphone` (voice capture)
  - `Permission.notification` (FCM messages)
- **Fallback Mechanism**:
  - Primary: `FlutterOverlayWindow.requestPermission()`
  - Fallback: `Permission.systemAlertWindow.request()`
  - Polling: 15 attempts × 300ms for verification
- **Usage**: `_PermissionHandler` in settings and overlay

### 21. **connectivity_plus** (v6.1.5)
- **Purpose**: Network connectivity state monitoring
- **Detection**: WiFi, Mobile, Bluetooth, VPN, None
- **Usage**: Trigger cloud sync when network becomes available after offline
- **Implementation**: `ConnectivitySyncCoordinator`
- **Stream**: Listen to connectivity changes across app lifecycle

### 22. **workmanager** (v0.6.0)
- **Purpose**: Cross-platform background task scheduling
- **Tasks Defined**:
  - Periodic Google Tasks sync: Every 4 hours
  - Constraints: Network connected, battery not low
  - Retry: Exponential backoff at 30-minute intervals
- **Configuration**: `WorkManagerService`
- **Entry Points**: Named callback functions for background execution
- **Android**: Uses WorkManager/JobScheduler APIs

---

## Utilities & Helpers

### 23. **url_launcher** (v6.3.2)
- **Purpose**: Open URLs and launch native apps
- **Use Cases**:
  - Telegram bot connection (`tg://` scheme)
  - Settings page links
  - Terms of service, privacy policy
- **Platforms**: Android, iOS, Web, Windows, macOS

### 24. **http** (v1.5.0)
- **Purpose**: HTTP client for making REST API requests
- **Usage**: Authenticated requests to Google APIs via `GoogleApiClient`
- **Features**: Timeout configuration, custom headers, error handling

### 25. **flutter_dotenv** (v5.2.1)
- **Purpose**: Environment variable management
- **File**: `.env` (loaded at startup)
- **Variables**:
  - `GOOGLE_GEMINI_API_KEY`: For AI classification
  - `TELEGRAM_BOT_USERNAME`: For Telegram integration
  - Firebase project config
- **Security**: `.env` not committed to version control

### 26. **flutter_svg** (v2.2.0)
- **Purpose**: SVG image rendering
- **Usage**: Google Sign-In custom SVG button, app icons

---

## Development & Build Tools

### 27. **flutter_lints** (v6.0.0)
- **Purpose**: Dart/Flutter linting rules following best practices
- **Configuration**: `analysis_options.yaml`
- **Usage**: `flutter analyze` for code quality checking
- **Validation**: Zero issues in final codebase

### 28. **build_runner** (v2.4.6)
- **Purpose**: Code generation orchestrator
- **Usage**: `flutter pub run build_runner build`
- **Generates**:
  - Isar schema code via `isar_generator`
  - JSON serialization if used
- **Development**: `flutter pub run build_runner watch` for live generation

### 29. **isar_generator** (v3.0.5)
- **Purpose**: Code generator for Isar database schema
- **Generates**: `note.g.dart` from `note.dart` annotation
- **Schema**: Automatic type mapping, index generation, collection registration
- **Rebuild**: Required on model changes

### 30. **path_provider** (v2.1.5)
- **Purpose**: Access platform-specific directories
- **Usage**: Isar database directory at `getApplicationSupportDirectory()`
- **Platforms**: Android, iOS, Web, Windows, macOS, Linux

---

## Summary Table

| Category | Tools & Technologies | Count |
|----------|----------------------|-------|
| **Frontend** | Flutter, Material Design 3, BLoC, GoRouter | 4 |
| **State & DI** | GetIt, ValueNotifier, Streams | 3 |
| **Storage** | Isar, SharedPreferences | 2 |
| **Cloud** | Firebase Core, Auth, Firestore, FCM | 4 |
| **AI & APIs** | Gemini, Google APIs, Fuzzy Search | 3 |
| **Voice & Audio** | speech_to_text | 1 |
| **Platform** | flutter_overlay_window, permission_handler, connectivity_plus, workmanager | 4 |
| **Utilities** | url_launcher, http, flutter_dotenv, flutter_svg, path_provider | 5 |
| **Development** | flutter_lints, build_runner, isar_generator | 3 |
| **TOTAL** | | **29 Main Technologies** |

---

## Architecture Patterns Used

### 1. **Clean Architecture**
```
Presentation Layer → Feature Layer → Data Layer → External Services
```

### 2. **Repository Pattern**
- Abstract data sources (local Isar, cloud Firestore, external APIs)
- Single point of data access (NoteRepository, UserRepository, etc.)

### 3. **Service Locator Pattern**
- GetIt for dependency injection
- Lazy singleton instantiation
- Centralized service management

### 4. **Observer Pattern**
- Streams, BLoC events
- ValueNotifier listeners
- Event-driven architecture

### 5. **State Machine Pattern**
- Overlay bubble states (Idle → Listening → Processing)
- UI mode transitions (Bubble → Text Panel)

### 6. **Adapter Pattern**
- Firebase/Isar adapter for local-first sync
- Google API client for external services

---

## Performance Optimizations

1. **Lazy Loading**: Services instantiated on first access (GetIt lazy singletons)
2. **Stream Efficiency**: Isar lazy watch streams prevent unnecessary rebuilds
3. **Background Processing**: 8-second polling minimizes CPU usage for AI processing
4. **Transaction Batching**: Isar `writeTxn()` for atomic multi-record updates
5. **Caching**: SharedPreferences for immediate access to user settings
6. **Pagination**: Future support for large note lists (currently all loaded)

---

## Security Measures

1. **OAuth 2.0**: Google Sign-In authentication
2. **Firestore Rules**: User-scoped document access
3. **Firebase Auth**: Token-based session management
4. **Local Encryption**: (Future enhancement) End-to-end encryption for notes
5. **API Key Management**: `.env` file for sensitive credentials
6. **Permission Control**: Runtime permission requests for microphone and overlay

---

## Testing Infrastructure

### Unit Tests (Future)
- Note model validation
- AI classifier logic
- Sync reconciliation algorithms
- Utility function tests

### Integration Tests (Future)
- Overlay lifecycle and gestures
- Full capture → classify → sync pipeline
- Offline handling and recovery
- External service mocking

### Manual Testing Checklist
- [ ] Google Sign-In without ApiException 10
- [ ] Overlay bubble appearance and dragging
- [ ] Voice capture accuracy
- [ ] Text-to-speech on home canvas
- [ ] AI classification accuracy
- [ ] Cloud sync in online/offline scenarios
- [ ] Google Calendar/Tasks bidirectional sync
- [ ] FCM push notifications

---

## Deployment Considerations

### Build Targets
- **Android**: SDK 35 (API 35)
- **iOS**: Minimum iOS 12.0
- **Web**: Chrome, Firefox, Safari
- **Desktop**: Windows, macOS, Linux

### CI/CD Integration (Future)
- GitHub Actions for automated testing
- Firebase App Distribution for beta releases
- Play Store/App Store deployment automation

### Version Management
- Current: 1.0.0+1
- Semantic versioning: MAJOR.MINOR.PATCH+BUILD
- Changelog: Track features, fixes, breaking changes

---

## Related Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md) - Full system architecture
- [ARCHITECTURE_DIAGRAMS.md](ARCHITECTURE_DIAGRAMS.md) - Visual diagrams
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Development setup
- [pubspec.yaml](pubspec.yaml) - All dependencies with versions
- [analysis_options.yaml](analysis_options.yaml) - Linting configuration

---

## Contact & Support

For questions about specific tools or technologies used in WhisperLog:
- Refer to individual package documentation links
- Check `pubspec.yaml` for exact version constraints
- Review code comments in implementation files
