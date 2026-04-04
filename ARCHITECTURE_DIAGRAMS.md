# WhisperLog System Architecture - Mermaid Diagrams

## 1. Complete System Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        SignInScreen["SignIn Screen<br/>Google OAuth"]
        HomeScreen["Home Screen<br/>Thought Canvas"]
        FolderScreen["Folder Screen<br/>Category View"]
        SettingsScreen["Settings Screen<br/>Overlay Toggle"]
        OverlayBubble["Overlay Bubble<br/>Voice Capture"]
    end

    subgraph "State Management"
        ThemeCubit["Theme Cubit<br/>Light/Dark/System"]
        GoRouter["GoRouter<br/>Navigation"]
        OverlayCoord["OverlayCoordinator<br/>State+Config"]
    end

    subgraph "Feature Layer"
        CaptureService["CaptureService<br/>Note Ingestion"]
        NoteRepo["NoteRepository<br/>CRUD + Streams"]
        UserRepo["UserRepository<br/>Auth + User"]
        AiService["AiProcessingService<br/>Background AI"]
        ExternalSync["ExternalSyncService<br/>Google Services"]
        FirestoreSync["FirestoreNoteSyncService<br/>Cloud Sync"]
        FcmService["FcmSyncService<br/>Push Notifications"]
    end

    subgraph "Domain Models"
        NoteModel["Note Model<br/>Isar Collection"]
        Enums["Enums<br/>Category/Priority/Status"]
        UserModel["User Model"]
    end

    subgraph "Data Persistence"
        IsarDB["Isar Database<br/>Local NoSQL<br/>Thread-Safe"]
        SharedPrefs["SharedPreferences<br/>Settings + Overlay"]
    end

    subgraph "External Services"
        Firebase["Firebase<br/>Auth + Firestore"]
        Gemini["Google Gemini<br/>AI Classification"]
        GoogleCalendar["Google Calendar<br/>Event Sync"]
        GoogleTasks["Google Tasks<br/>Task Sync"]
        FCM["Firebase Cloud<br/>Messaging"]
    end

    subgraph "Platform Layer"
        OverlayWindow["flutter_overlay_window<br/>Android Overlay"]
        SpeechToText["speech_to_text<br/>Voice Recognition"]
        PermHandler["permission_handler<br/>Runtime Perms"]
        Connectivity["connectivity_plus<br/>Network State"]
        WorkManager["workmanager<br/>Background Jobs"]
    end

    subgraph "Core Infrastructure"
        DIContainer["GetIt<br/>Dependency Injection"]
        AppEnv["AppEnv<br/>Config + Env Vars"]
        WorkService["WorkManagerService<br/>Task Scheduling"]
        ConnectivityCoord["ConnectivitySyncCoordinator<br/>Network Triggers"]
    end

    %% Presentation to State
    SignInScreen --> GoRouter
    HomeScreen --> GoRouter
    FolderScreen --> GoRouter
    SettingsScreen --> GoRouter
    OverlayBubble --> GoRouter
    
    %% State to Features
    GoRouter --> ThemeCubit
    GoRouter --> OverlayCoord
    ThemeCubit --> SharedPrefs
    OverlayCoord --> OverlayCoord
    
    %% Screens to Features
    SignInScreen --> UserRepo
    HomeScreen --> CaptureService
    HomeScreen --> NoteRepo
    FolderScreen --> NoteRepo
    SettingsScreen --> OverlayCoord
    OverlayBubble --> CaptureService
    OverlayBubble --> SpeechToText
    
    %% Features to Models
    CaptureService --> NoteModel
    NoteRepo --> NoteModel
    UserRepo --> UserModel
    
    %% Features to Persistence
    CaptureService --> IsarDB
    NoteRepo --> IsarDB
    AiService --> IsarDB
    FirestoreSync --> IsarDB
    UserRepo --> Firebase
    
    %% Features to External
    AiService --> Gemini
    ExternalSync --> GoogleCalendar
    ExternalSync --> GoogleTasks
    FirestoreSync --> Firebase
    FcmService --> FCM
    UserRepo --> Firebase
    
    %% Platform Integration
    OverlayBubble --> OverlayWindow
    OverlayBubble --> SpeechToText
    OverlayBubble --> PermHandler
    CaptureService --> PermHandler
    Connectivity --> ConnectivityCoord
    WorkManager --> WorkService
    
    %% Core Infrastructure
    DIContainer --> CaptureService
    DIContainer --> NoteRepo
    DIContainer --> UserRepo
    DIContainer --> AiService
    DIContainer --> ExternalSync
    DIContainer --> FirestoreSync
    DIContainer --> FcmService
    AppEnv --> Firebase
    WorkService --> AiService
    ConnectivityCoord --> FirestoreSync
    
    %% Styling
    classDef presentation fill:#FF6B6B,stroke:#C92A2A,color:#fff
    classDef state fill:#4ECDC4,stroke:#1B998B,color:#fff
    classDef feature fill:#45B7D1,stroke:#0984E3,color:#fff
    classDef domain fill:#96CEB4,stroke:#52B788,color:#fff
    classDef persistence fill:#FFE66D,stroke:#FFA502,color:#000
    classDef external fill:#DDA15E,stroke:#BC6C25,color:#fff
    classDef platform fill:#D4A5A5,stroke:#9A6C6C,color:#fff
    classDef core fill:#C1A3E8,stroke:#8B5CF6,color:#fff
    
    class SignInScreen,HomeScreen,FolderScreen,SettingsScreen,OverlayBubble presentation
    class ThemeCubit,GoRouter,OverlayCoord state
    class CaptureService,NoteRepo,UserRepo,AiService,ExternalSync,FirestoreSync,FcmService feature
    class NoteModel,Enums,UserModel domain
    class IsarDB,SharedPrefs persistence
    class Firebase,Gemini,GoogleCalendar,GoogleTasks,FCM external
    class OverlayWindow,SpeechToText,PermHandler,Connectivity,WorkManager platform
    class DIContainer,AppEnv,WorkService,ConnectivityCoord core
```

---

## 2. Data Flow: Voice Capture to Cloud Sync

```mermaid
sequenceDiagram
    participant User
    participant UI as OverlayBubble
    participant Speech as SpeechToText
    participant Capture as CaptureService
    participant Isar as IsarDB
    participant AI as AiProcessing
    participant Firestore as Firestore
    participant Sync as ExternalSync

    User->>UI: Long Press Bubble
    UI->>Speech: Initialize + Listen
    Speech-->>UI: Listening State (Blue Pulse)
    User->>UI: Release Press
    UI->>Speech: Stop Listening
    Speech-->>UI: Transcript Text
    
    UI->>Capture: ingestRawCapture(transcript, syncToCloud=false)
    Capture->>Capture: Validate & Trim
    Capture->>Capture: Generate noteId (timestamp+random)
    Capture->>Capture: Create Note(status=pendingAi)
    Capture->>Isar: writeTxn() → put(note)
    Isar-->>Capture: Saved
    
    UI->>UI: Show Toast "Saved"
    Capture->>AI: _promotePendingNote(noteId, transcript)
    
    loop Every 8 seconds
        AI->>Isar: Find notes.status==pendingAi
        AI->>AI: GeminiNoteClassifier.classify()
        AI->>Isar: writeTxn() → update note to active
        Isar-->>AI: Updated
        AI->>Firestore: _syncNoteToFirestore(note)
    end
    
    loop When Network Available
        Sync->>Isar: Find active notes needing sync
        Sync->>Firestore: set(note) with merge=true
        Sync->>Sync: ExternalSync.syncForNote()
        Sync->>GoogleCalendar: Create event if date extracted
        Sync->>GoogleTasks: Create task if category==tasks
    end
    
    Note over Firestore,Sync: Bi-directional sync complete
```

---

## 3. Application Initialization Flow

```mermaid
graph TD
    Start["App Start: main()"]
    
    Start --> Step1["1. WidgetsFlutterBinding<br/>ensureInitialized()"]
    Step1 --> Step2["2. Register FCM<br/>Background Handler"]
    Step2 --> Step3["3. Load AppEnv<br/>from .env file"]
    Step3 --> Step4["4. Firebase.initializeApp()<br/>with options"]
    Step4 --> Step5["5. IsarService.init()<br/>Local Database"]
    Step5 --> Step6["6. WorkManager<br/>registerPeriodicSync()"]
    Step6 --> Step7["7. init() from<br/>injection_container"]
    Step7 --> DI["Register 12+ Singletons<br/>Services + Repositories"]
    DI --> Step8["8. ThemeCubit.hydrate()<br/>Load theme"]
    Step8 --> Step9["9. OverlayCoordinator<br/>hydrateAndRestore()"]
    Step9 --> Step10["10. AiProcessingService<br/>start() every 8s"]
    Step10 --> Step11["11. ConnectivitySyncCoordinator<br/>startMonitoring()"]
    Step11 --> Step12["12. FcmSyncService<br/>initialize()"]
    Step12 --> Step13["13. runApp(MyApp)<br/>with GoRouter"]
    Step13 --> Step14["✓ App Ready<br/>Navigate based on auth state"]
    
    style Start fill:#FF6B6B,stroke:#C92A2A,color:#fff
    style DI fill:#45B7D1,stroke:#0984E3,color:#fff
    style Step14 fill:#52B788,stroke:#2B6A4F,color:#fff
```

---

## 4. Overlay Window Lifecycle (Android)

```mermaid
stateDiagram-v2
    [*] --> Requesting: User toggles<br/>Floating Capture ON
    
    Requesting --> FlutterOverlayWin: Call requestPermission()
    FlutterOverlayWin --> Fallback: If fails after 300ms×15
    Fallback --> PermHandler: Permission.systemAlertWindow<br/>.request()
    
    PermHandler --> GrantedCheck: Poll isPermissionGranted()
    GrantedCheck --> System{OS says<br/>Granted?}
    System -->|No| Denied
    System -->|Yes| SettingPrefs: Save to SharedPrefs
    
    SettingPrefs --> ShowWindow: Call showOverlay()
    ShowWindow --> Bubble: Render OverlayBubbleWidget<br/>in isolate
    
    Bubble --> Idle: Idle state<br/>56dp circle
    
    Idle --> Dragging: Pan gesture
    Dragging --> EdgeSnap: Release on edge
    EdgeSnap --> Idle: Snap to edge<br/>if enabled
    
    Idle --> Listening: Long press start
    Listening --> Speaking: Recording voice
    Speaking --> Processing: Long press end
    Processing --> TextBack: Save to Isar
    TextBack --> Idle: Return to idle
    
    Idle --> TextPanel: Tap/Double-tap
    TextPanel --> TextInput: Show text field
    TextInput --> SaveText: Hit Save
    SaveText --> Idle
    
    Idle --> Disabled: User toggles OFF
    Disabled --> HideWindow: Call hideOverlay()
    HideWindow --> ClearPrefs: Clear visible=false
    ClearPrefs --> [*]
    
    Denied --> [*]
    
    style Bubble fill:#FF6B6B,stroke:#C92A2A,color:#fff
    style Idle fill:#4ECDC4,stroke:#1B998B,color:#fff
    style Listening fill:#45B7D1,stroke:#0984E3,color:#fff
    style TextPanel fill:#FFE66D,stroke:#FFA502,color:#000
```

---

## 5. Note Processing Pipeline

```mermaid
graph LR
    subgraph "Capture Phase"
        Voice["Voice/Text Input"]
        Validate["Validate & Trim"]
        Create["Create Note<br/>status=pendingAi"]
        SaveLocal["Save to Isar"]
    end
    
    subgraph "AI Phase"
        Queue["Queue for AI"]
        Poll["8s Polling Loop"]
        Classify["Gemini<br/>Classify"]
        Extract["Extract:<br/>Title, Category,<br/>Priority, Date"]
        UpdateNote["Update Note<br/>status=active"]
    end
    
    subgraph "Sync Phase"
        SaveCloud["Save to Firestore"]
        ExtSync["External Sync"]
        Calendar["→ Google Calendar"]
        Tasks["→ Google Tasks"]
    end
    
    subgraph "Display Phase"
        FindNote["Find in Isar"]
        WatchStream["Stream to Folder"]
        ShowUI["Display in<br/>Category List"]
    end
    
    Voice --> Validate
    Validate -->|Empty?| Discard["❌ Discard"]
    Validate -->|Valid| Create
    Create --> SaveLocal
    SaveLocal --> Queue
    
    Queue --> Poll
    Poll --> Classify
    Classify --> Extract
    Extract --> UpdateNote
    UpdateNote --> SaveCloud
    
    SaveCloud --> ExtSync
    ExtSync -->|has date| Calendar
    ExtSync -->|category=tasks| Tasks
    
    UpdateNote --> FindNote
    FindNote --> WatchStream
    WatchStream --> ShowUI
    
    style Voice fill:#FF6B6B,stroke:#C92A2A,color:#fff
    style SaveLocal fill:#FFE66D,stroke:#FFA502,color:#000
    style Classify fill:#45B7D1,stroke:#0984E3,color:#fff
    style ShowUI fill:#52B788,stroke:#2B6A4F,color:#fff
    style Discard fill:#999,stroke:#666,color:#fff
```

---

## 6. State & Dependency Injection

```mermaid
graph TB
    subgraph "GetIt Service Locator"
        direction TB
        
        subgraph "Repositories"
            AppPrefs["AppPreferencesRepository"]
            UserRepo["UserRepository"]
            NoteRepo["NoteRepository"]
            ExtSync["ExternalSyncService"]
        end
        
        subgraph "Services"
            CaptureServ["CaptureService"]
            AiServ["AiProcessingService"]
            FcmServ["FcmSyncService"]
            FirestoreSync["FirestoreNoteSyncService"]
            OverlayPrefs["OverlayV1Preferences"]
        end
        
        subgraph "Coordinators"
            OverlayCoord["OverlayCoordinator"]
            ConnectCoord["ConnectivitySyncCoordinator"]
            WorkServ["WorkManagerService"]
        end
        
        subgraph "State"
            ThemeCubit["ThemeCubit"]
        end
    end
    
    subgraph "Registration Order (init())"
        R1["1. Repositories"]
        R2["2. Services"]
        R3["3. Coordinators"]
        R4["4. Presentation State"]
    end
    
    subgraph "Access Pattern"
        Usage["sl&lt;ServiceType&gt;()"]
    end
    
    R1 --> AppPrefs
    R1 --> UserRepo
    R1 --> NoteRepo
    R1 --> ExtSync
    
    R2 --> CaptureServ
    R2 --> AiServ
    R2 --> FcmServ
    R2 --> FirestoreSync
    R2 --> OverlayPrefs
    
    R3 --> OverlayCoord
    R3 --> ConnectCoord
    R3 --> WorkServ
    
    R4 --> ThemeCubit
    
    OverlayCoord --> OverlayPrefs
    CaptureServ --> NoteRepo
    AiServ --> NoteRepo
    
    AppPrefs --> Usage
    UserRepo --> Usage
    ThemeCubit --> Usage
    OverlayCoord --> Usage
    
    style GetIt fill:#C1A3E8,stroke:#8B5CF6,color:#fff
    style Usage fill:#45B7D1,stroke:#0984E3,color:#fff
```

---

## 7. Database Schema & Relationships

```mermaid
erDiagram
    NOTE ||--|| USER : "belongs_to"
    NOTE ||--|| ISAR : "stored_in"
    FIRESTORE ||--|| NOTE : "syncs_to"
    SHARED_PREFS ||--|| OVERLAY_CONFIG : "stores"
    SHARED_PREFS ||--|| APP_SETTINGS : "stores"
    
    NOTE {
        string noteId PK
        string uid FK
        string rawTranscript
        string title
        string cleanBody
        enum category
        enum priority
        datetime createdAt
        datetime updatedAt
        enum status
        string aiModel
        string gcalEventId
        string gtaskId
        enum source
        datetime syncedAt
    }
    
    USER {
        string uid PK
        string email
        string displayName
        string photoUrl
        string fcmToken
        datetime createdAt
    }
    
    ISAR {
        string database "Local NoSQL"
        string collections "Note"
        string transactions "writeTxn()"
        string indexes "noteId (fastHash)"
    }
    
    FIRESTORE {
        string path "users/{uid}/notes/{noteId}"
        string rules "Auth required"
        string merge "SetOptions(merge=true)"
    }
    
    OVERLAY_CONFIG {
        bool visible
        float opacity
        float size
        bool snapEnabled
        double positionX
        double positionY
    }
    
    APP_SETTINGS {
        enum themeMode
        int digestHour
        int digestMinute
    }
```

---

## 8. Network & Sync Architecture

```mermaid
graph TB
    subgraph "Local Device"
        App["Flutter App<br/>Main Isolate"]
        Overlay["Overlay App<br/>Isolated Process"]
        IsarLocal["Isar Database<br/>Local Storage"]
    end
    
    subgraph "Connectivity Layer"
        Monitor["ConnectivityPlus<br/>Network Monitor"]
        Online{Online?}
        Trigger["Trigger Sync"]
    end
    
    subgraph "Sync Services"
        FirestoreSync["FirestoreNoteSyncService<br/>Bi-directional"]
        ExtSync["ExternalSyncService<br/>Google APIs"]
        FcmSync["FcmSyncService<br/>Push Notifications"]
    end
    
    subgraph "Cloud Backend"
        Firestore["Google Firestore<br/>users/{uid}/notes/{noteId}"]
        GoogleCalendar["Google Calendar"]
        GoogleTasks["Google Tasks"]
        FCM["Firebase Cloud<br/>Messaging"]
    end
    
    subgraph "Background Processing"
        AILoop["AiProcessingService<br/>8s Polling"]
        WorkScheduler["WorkManager<br/>Periodic 4h"]
    end
    
    App -->|Creates Note| IsarLocal
    Overlay -->|Captures Voice| IsarLocal
    IsarLocal -->|Local First| App
    
    App -->|Monitor| Monitor
    Monitor --> Online
    
    Online -->|Yes| Trigger
    Trigger --> AILoop
    Trigger --> FirestoreSync
    Trigger --> ExtSync
    
    AILoop -->|Updates| IsarLocal
    FirestoreSync -->|Sync| Firestore
    FirestoreSync -->|Bi-directional| IsarLocal
    
    ExtSync -->|Calendar| GoogleCalendar
    ExtSync -->|Tasks| GoogleTasks
    ExtSync -->|Sync| IsarLocal
    
    FCM -->|Push| FcmSync
    FcmSync -->|Update Local| IsarLocal
    
    WorkScheduler -->|Periodic| Firestore
    
    Online -->|No| OfflineQueue["Queue Locally<br/>for Later Sync"]
    OfflineQueue -->|When Online| Trigger
    
    style App fill:#FF6B6B,stroke:#C92A2A,color:#fff
    style IsarLocal fill:#FFE66D,stroke:#FFA502,color:#000
    style Monitor fill:#4ECDC4,stroke:#1B998B,color:#fff
    style Firestore fill:#DDA15E,stroke:#BC6C25,color:#fff
    style OfflineQueue fill:#C92A2A,stroke:#922B2B,color:#fff
```

---

## 9. Feature Dependency Graph

```mermaid
graph LR
    Auth["🔐<br/>Authentication<br/>Feature"]
    Capture["🎤<br/>Capture<br/>Feature"]
    Notes["📝<br/>Notes<br/>Feature"]
    AI["🤖<br/>AI Processing<br/>Feature"]
    Sync["☁️<br/>Sync<br/>Feature"]
    Overlay["👁️<br/>Overlay<br/>Feature"]
    Settings["⚙️<br/>Settings<br/>Feature"]
    Home["🏠<br/>Home<br/>Feature"]
    
    Auth -->|User Context| Capture
    Auth -->|User Context| Notes
    Auth -->|User Context| Sync
    
    Capture -->|Save Note| Notes
    Capture -->|Isar| AI
    
    Notes -->|Stream Updates| Home
    Notes -->|Archive/Edit| Notes
    
    AI -->|Process Notes| Sync
    AI -->|Update Status| Notes
    
    Sync -->|Cloud Backup| Notes
    Sync -->|External APIs| Sync
    
    Overlay -->|Voice Capture| Capture
    Overlay -->|Mic Permission| Overlay
    
    Settings -->|Configure| Overlay
    Settings -->|Configure| Home
    Settings -->|Logout| Auth
    
    Home -->|New Note| Capture
    Home -->|Dictation| Capture
    
    style Auth fill:#FF6B6B,stroke:#C92A2A,color:#fff
    style Capture fill:#45B7D1,stroke:#0984E3,color:#fff
    style Notes fill:#FFE66D,stroke:#FFA502,color:#000
    style AI fill:#96CEB4,stroke:#52B788,color:#fff
    style Sync fill:#DDA15E,stroke:#BC6C25,color:#fff
    style Overlay fill:#D4A5A5,stroke:#9A6C6C,color:#fff
    style Settings fill:#C1A3E8,stroke:#8B5CF6,color:#fff
    style Home fill:#FF6B6B,stroke:#C92A2A,color:#fff
```

---

## 10. Tools & Technologies Summary

```mermaid
graph TB
    subgraph "Frontend Stack"
        F1["🚀 Flutter"]
        F2["🎨 Material Design 3"]
        F3["📦 Flutter BLoC"]
        F4["🛣️ GoRouter"]
    end
    
    subgraph "State & DI"
        S1["🔌 GetIt"]
        S2["📊 ValueNotifier"]
        S3["🌊 Streams"]
    end
    
    subgraph "Local Storage"
        DB1["📱 Isar (NoSQL)"]
        DB2["⚙️ SharedPreferences"]
    end
    
    subgraph "Cloud & Auth"
        C1["🔐 Firebase Auth"]
        C2["☁️ Cloud Firestore"]
        C3["📨 FCM"]
        C4["🔑 Google OAuth"]
    end
    
    subgraph "AI & APIs"
        AI1["🤖 Google Gemini"]
        AI2["📅 Google Calendar"]
        AI3["✅ Google Tasks"]
        AI4["🔍 Fuzzy Search"]
    end
    
    subgraph "Platform Integration"
        P1["👁️ flutter_overlay_window"]
        P2["🎤 speech_to_text"]
        P3["📋 permission_handler"]
        P4["📡 connectivity_plus"]
        P5["⏰ workmanager"]
    end
    
    subgraph "DevOps & Build"
        DV1["🔧 build_runner"]
        DV2["📝 isar_generator"]
        DV3["✨ flutter_lints"]
        DV4["🌍 flutter_dotenv"]
    end
    
    F1 --> F2
    F1 --> F3
    F3 --> S1
    S1 --> F4
    
    F1 --> DB1
    F1 --> DB2
    
    F4 --> C1
    C1 --> C2
    C1 --> C3
    C2 --> C4
    
    C2 --> AI1
    C2 --> AI2
    C2 --> AI3
    AI1 --> AI4
    
    F1 --> P1
    F1 --> P2
    F1 --> P3
    F1 --> P4
    F1 --> P5
    
    DB1 --> DV2
    F1 --> DV1
    F1 --> DV3
    C1 --> DV4
    
    style F1 fill:#FF6B6B,stroke:#C92A2A,color:#fff
    style DB1 fill:#FFE66D,stroke:#FFA502,color:#000
    style C2 fill:#DDA15E,stroke:#BC6C25,color:#fff
    style AI1 fill:#96CEB4,stroke:#52B788,color:#fff
```

---

## Diagram Notes

- **Color Legend**:
  - 🔴 Red: UI/Presentation
  - 🔵 Blue: Features/Services
  - 🟡 Yellow: Storage
  - 🌴 Green: External APIs
  - 🟣 Purple: Infrastructure

- **Architecture Pattern**: Clean Architecture + BLoC
- **Data Flow**: Local-first → Queue for AI → Cloud backup
- **Sync Strategy**: Network-triggered with exponential backoff
- **Error Handling**: Graceful degradation with detailed logging
