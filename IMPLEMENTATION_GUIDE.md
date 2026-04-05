# WhisperLog: Complete Setup & Implementation Guide

**Last Updated:** 2026-04-05  
**Status:** ✅ Ready for external setup

---

## What's Been Set Up

### 1. ✅ **Overlay & Floating Button**
- **Status:** Working, untouched
- **How it works:**
  - Tap floating bubble → activates speech-to-text
  - Audio captured and transcribed in real-time
  - Transcript sent to `CaptureService.ingestRawCapture()`
  - Note immediately saved to SQLite (status: `pendingAi`)
  
**Don't touch:** 
- `lib/features/overlay/overlay_bubble.dart`
- `lib/features/overlay/overlay_notifier.dart`
- Recording & transcription logic works as-is

**Just get:**
- `rawTranscript` from speech-to-text
- `source: CaptureSource.overlay`
- Emit it to CaptureService (already done ✓)

---

### 2. ✅ **Firebase ↔ SQLite Bidirectional Sync**

#### What it does:
```
User Records Note (Overlay)
    ↓
SQLite saved (instant UI update) ← Local cache
    ↓
Firebase pushed (async) ← Cloud backup
    ↓
Cloud Function enriches with Gemini
    ↓
Firebase updated with: title, category, priority, clean_body, extracted_date
    ↓
FCM push received
    ↓
SQLite updated (consistent with cloud) ← Stays in sync
    ↓
UI shows enriched note across all devices
```

**Implementation files:**
- `lib/features/capture/data/capture_service.dart` → **SQLite write first**
- `lib/features/ai/data/ai_processing_service.dart` → **Enrichment + Firebase push**
- `lib/features/sync/data/firestore_note_sync_service.dart` → **Firebase pull → SQLite**
- `lib/features/sync/data/fcm_sync_service.dart` → **Listen to push notifications**
- `functions/index.js` → **Cloud Function enrichment (server-side)**

**Sync guarantees:**
- ✅ No data loss (merge: true strategy)
- ✅ Eventual consistency (seconds delay)
- ✅ Timestamps tracked (created_at, updated_at, synced_at)
- ✅ Conflict resolution (last-write-wins)

---

### 3. ✅ **Transcript Categorization & Organization**

#### How transcripts are categorized:
```
Raw Input: "buy milk tomorrow at 5pm"
    ↓
CaptureService heuristic guess: "reminders" (checks for date/time keywords)
    ↓
Saved to SQLite with status: "pendingAi"
    ↓
Cloud Function (enrichPendingAiNote) hits Gemini API
    ├─ Input: raw_transcript
    └─ Output: {title: "Buy milk", category: "reminders", priority: "medium", ...}
    ↓
Firestore + SQLite updated with accurate category
    ↓
UI filters by category (visible in "Reminders" view)
```

#### Categories (from categorization system):
- **tasks** → Actions you need to do (create Google Task)
- **reminders** → Time-sensitive items (create Google Calendar event)
- **ideas** → Creative concepts
- **follow-up** → Follow-ups with people
- **journal** → Personal reflection
- **general** → Miscellaneous

#### Files storing this:
- `lib/shared/models/note.dart` → **Note model with category field**
- `lib/shared/models/enums.dart` → **Category enum definition**
- `lib/features/capture/data/capture_service.dart` → **Initial heuristic**
- `functions/index.js` (enrichPendingAiNote) → **Server enrichment**
- `lib/features/ai/data/gemini_note_classifier.dart` → **Client enrichment**

#### Organization in views:
- All notes stored in SQLite with `category` field
- UI queries by: `SELECT * FROM notes WHERE status='active' AND category='tasks'`
- Automatic folder-like grouping via category filter

---

### 4. ✅ **External Setup Documentation**

**File:** `USER_TODO.md`

**Covers:**
1. **Firebase Setup** (create project, enable services)
2. **Google APIs** (Calendar, Tasks, Speech-to-Text)
3. **Gemini API** (AI enrichment)
4. **Cloud Functions** (deployment steps)
5. **Environment Variables** (.env configuration)
6. **Data Sync Flow** (detailed walkthrough)
7. **Categorization System** (how transcripts get organized)
8. **Troubleshooting** (common issues & solutions)
9. **Monitoring** (logs to watch)
10. **Production Checklist** (before going live)

**Quick start in USER_TODO.md § 12:**
```
1. Create Firebase project
2. Download config files (google-services.json, GoogleService-Info.plist)
3. Enable APIs (Calendar, Tasks, Cloud Messaging, Cloud Functions)
4. Create Gemini API key
5. Deploy Cloud Functions with `firebase deploy --only functions`
6. Update .env with keys
7. Build & run
```

---

## Complete Data Flow (End-to-End)

### Step 1: User Creates Note (Overlay)
```dart
// Overlay floating button → starts recording
SpeechToText.listen()
    ↓
// User speaks: "buy milk tomorrow"
[transcript received]
    ↓
// Sent to capture service
CaptureService.ingestRawCapture(
  rawTranscript: "buy milk tomorrow",
  source: CaptureSource.overlay
)
```

### Step 2: Local Persistence
```dart
// Create Note object (status: pendingAi)
Note pending = Note(
  noteId: '1234567890_12345',
  uid: user.uid,
  rawTranscript: 'buy milk tomorrow',
  title: 'buy milk tomorrow', // fallback
  cleanBody: 'buy milk tomorrow', // fallback
  category: NoteCategory.reminders, // heuristic guess
  priority: NotePriority.medium,
  status: NoteStatus.pendingAi,
  // ... other fields
);

// Upsert to SQLite immediately
await SqliteNoteStore.instance.upsert(pending);
// → User sees note in UI instantly ✓

// Emit event
NoteEventBus.instance.emitNoteSaved(pending.noteId);
// → Triggers AI processing
```

### Step 3: Firebase Sync (Async)
```dart
// Parallel to above:
await _syncNoteToFirestore(pending);
// → SET to Firestore with merge: true
// → Cloud Function trigger setup: onDocumentCreated
```

### Step 4: Server-Side AI Enrichment (Cloud Function)
```javascript
// functions/index.js
exports.enrichPendingAiNote = onDocumentCreated(
  'users/{uid}/notes/{noteId}',
  async (event) => {
    if (event.data.data().status !== 'pendingAi') return;
    
    const rawTranscript = event.data.data().raw_transcript;
    // Call Gemini 2.5 Flash Lite
    const response = await model.generateContent([
      { text: SYSTEM_PROMPT },
      { text: `Raw input: ${rawTranscript}` }
    ]);
    
    const enriched = parseJSON(response.text());
    // enriched = {
    //   title: "Buy milk",
    //   category: "reminders",
    //   priority: "medium",
    //   clean_body: "Purchase milk from store before 5 PM tomorrow",
    //   extracted_date: "2026-04-06T17:00:00Z"
    // }
    
    // Update Firestore
    await db.collection('users').doc(uid).collection('notes').doc(noteId)
      .update({
        title: enriched.title,
        category: enriched.category,
        priority: enriched.priority,
        clean_body: enriched.clean_body,
        extracted_date: enriched.extracted_date,
        ai_model: 'gemini-2.5-flash-lite',
        status: 'active'
      });
  }
);
```

### Step 5: Client-Side Backup (Redundancy)
```dart
// AiProcessingService also processes locally
// (in case Cloud Function fails or is offline)

NoteEventBus.onNoteSaved.listen((noteId) {
  AiProcessingService.processNoteById(noteId);
  // → Calls AiClassifierRouter (Gemini/Groq)
  // → Updates SQLite with enriched data
  // → Calls ExternalSyncService (Google APIs)
  // → Syncs back to Firebase
});
```

### Step 6: Push Notification (Cross-Device Sync)
```
Firebase Cloud Function updates document
    ↓
Cloud Function sends FCM: {type: 'note_updated', note_id: '...'}
    ↓
FcmSyncService receives FCM message
    ↓
FirestoreNoteSyncService.syncNoteById(noteId)
    ├─ Fetch latest from Firestore
    └─ Upsert to SQLite
    
Result: Both devices now have identical, enriched note
```

### Step 7: External Sync (Google Calendar/Tasks)
```dart
// ExternalSyncService runs automatically

if (note.category == NoteCategory.reminders && 
    note.extractedDate != null) {
  // Create Google Calendar event
  final eventId = await _createCalendarEvent(note);
  note.gcalEventId = eventId;
}

if (note.category == NoteCategory.tasks) {
  // Create Google Task
  final taskId = await _createGoogleTask(note);
  note.gtaskId = taskId;
}

// Save IDs back to note
await SqliteNoteStore.instance.upsert(note);
await _syncNoteToFirestore(note);
```

### Step 8: Complete State
```
SQLite:
├─ note_id: 1234567890_12345
├─ status: active ✓
├─ category: reminders ✓
├─ title: Buy milk ✓
├─ clean_body: Purchase milk before 5 PM tomorrow ✓
├─ extracted_date: 2026-04-06T17:00:00Z ✓
├─ ai_model: gemini-2.5-flash-lite ✓
├─ gcal_event_id: null (added if reminder)
├─ synced_at: 2026-04-05T10:31:05Z ✓

Firestore:
├─ SAME as SQLite

Google Calendar:
├─ Event created (if category == reminders)
├─ Title: Buy milk
├─ Date: 2026-04-04 (2 days before extracted date)
├─ Reminder: 2 days early

Result: Note visible in:
  ✓ WhisperLog app (all devices, synced)
  ✓ Google Calendar (if reminder)
  ✓ Categorized properly (in Reminders view)
```

---

## Key Implementation Points

### Don't Touch (Already Working)
- ✅ Overlay recording mechanism (`lib/features/overlay/`)
- ✅ Speech-to-text integration (`speech_to_text` package)
- ✅ Floating button UI
- These just work, leave them alone

### Already Implemented (Just Need Setup)
- ✅ SQLite local database (`lib/core/storage/sqlite_note_store.dart`)
- ✅ Firebase Firestore sync (`lib/features/sync/data/`)
- ✅ AI enrichment client-side (`lib/features/ai/data/`)
- ✅ AI enrichment server-side (`functions/index.js`)
- ✅ External API sync (`lib/features/sync/data/external_sync_service.dart`)
- ✅ FCM push notifications (`lib/features/sync/data/fcm_sync_service.dart`)
- ✅ Categorization system (`lib/shared/models/enums.dart`)

### Just Needs Configuration (Via USER_TODO.md)
- 🔧 Firebase project creation & configuration
- 🔧 Google APIs enablement (Calendar, Tasks)
- 🔧 Gemini API key setup
- 🔧 Cloud Functions deployment
- 🔧 Environment variables (.env file)

---

## Testing the Complete Flow

### Test 1: Basic Capture & Sync
```
1. ✓ Tap floating overlay button
2. ✓ Say: "buy milk"
3. ✓ Check: Note appears in SQLite
4. ✓ Check: Note appears in Firestore
5. ✓ Check: Cloud Function processes it
6. ✓ Check: Note status becomes "active"
7. ✓ Verify: Category is accurate
```

### Test 2: Cross-Device Sync
```
1. ✓ Create note on Device A
2. ✓ Sign in on Device B
3. ✓ Check: Note synced to Device B (via FCM)
4. ✓ Edit note on Device B
5. ✓ Check: Edit appears on Device A
```

### Test 3: External Integration
```
1. ✓ Create reminder note: "call john tomorrow at 2pm"
2. ✓ Check: Note categorized as "reminders"
3. ✓ Check: Google Calendar event created
4. ✓ Check: Event set 2 days before
5. ✓ Mark done in Google Calendar
6. ✓ Check: Note archived in WhisperLog
```

---

## File Structure Summary

```
wishperlog/
├─ lib/
│  ├─ main.dart                          [App entry, init sequence]
│  ├─ features/
│  │  ├─ overlay/                        [Recording UI - DON'T TOUCH]
│  │  │  ├─ overlay_bubble.dart
│  │  │  ├─ overlay_notifier.dart
│  │  │  └─ quick_note_editor.dart
│  │  ├─ capture/
│  │  │  └─ data/
│  │  │     ├─ capture_service.dart      [Saves to SQLite + Firebase]
│  │  │     └─ note_save_service.dart
│  │  ├─ ai/
│  │  │  └─ data/
│  │  │     ├─ ai_processing_service.dart [Client enrichment]
│  │  │     ├─ gemini_note_classifier.dart
│  │  │     ├─ groq_note_classifier.dart
│  │  │     └─ ai_classifier_router.dart
│  │  └─ sync/
│  │     └─ data/
│  │        ├─ firestore_note_sync_service.dart [Firebase pull]
│  │        ├─ fcm_sync_service.dart            [Push notifications]
│  │        └─ external_sync_service.dart       [Google APIs]
│  ├─ core/
│  │  ├─ storage/
│  │  │  └─ sqlite_note_store.dart              [SQLite write]
│  │  ├─ background/
│  │  │  ├─ work_manager_service.dart           [Periodic tasks]
│  │  │  └─ connectivity_sync_coordinator.dart
│  │  ├─ di/
│  │  │  └─ injection_container.dart            [DI setup]
│  │  └─ config/
│  │     └─ app_env.dart                        [.env loading]
│  └─ shared/
│     └─ models/
│        ├─ note.dart                           [Data model]
│        └─ enums.dart                          [Status, category, etc.]
├─ functions/
│  ├─ index.js                           [Cloud Function enrichment]
│  └─ package.json
├─ .env                                  [Environment variables]
├─ firebase.json                         [Firebase config]
├─ pubspec.yaml                          [Flutter dependencies]
├─ USER_TODO.md                          [External setup checklist ← START HERE]
└─ SYNC_ARCHITECTURE.md                  [Detailed sync guide]
```

---

## Next Steps (For You)

### Immediate (Setup Phase)
1. **Read:** `USER_TODO.md` (sections 1-7)
2. **Do:** Follow Firebase setup checklist (use SHA-1 fingerprint, not API key)
   ```bash
   cd android && ./gradlew signingReport # Get SHA-1
   # Add SHA-1 to Firebase Console → Your apps → Android
   ```
3. **Do:** Download `google-services.json` to `android/app/`
4. **Do:** Configure Google APIs (Calendar, Tasks)
5. **Do:** Create Gemini API key (this goes in `.env`)
6. **Do:** Deploy Cloud Functions (with Gemini key)

### Then (Testing Phase)
1. **Build:** `flutter pub get && flutter run`
2. **Test:** Create a note via overlay
3. **Check:** Logs show sync completing
4. **Verify:** Note in Firestore with `status: active`
5. **Confirm:** Category is accurate

### Finally (Optimization)
1. **Monitor:** `firebase functions:log`
2. **Review:** `USER_TODO.md` sections 13-15 (monitoring & production)
3. **Configure:** Backup strategy & error tracking
4. **Document:** Any custom setup steps you added

---

## Troubleshooting Quick Links

| Problem | Solution |
|---------|----------|
| Cloud Function not running | Check `firebase functions:log` |
| Note stuck in `pendingAi` | Verify Gemini API key is set |
| Firebase not syncing | Check user is authenticated |
| Overlay not recording | Check microphone permission |
| Google Calendar not syncing | Verify note category matches and Google Sign-In is done |

**See:** `USER_TODO.md` § 10 for full troubleshooting guide

---

## Documentation Files

| File | Purpose |
|------|---------|
| `USER_TODO.md` | External setup checklist (Firebase, APIs, deployment) |
| `SYNC_ARCHITECTURE.md` | Detailed technical guide (data flows, state machine, schemas) |
| This file | Quick reference & end-to-end walkthrough |
| `ARCHITECTURE.md` | Overall system architecture (audit) |
| `issues.md` | Known issues & resolutions |

---

**Status:** ✅ All systems documented and ready for setup  
**Next:** Follow `USER_TODO.md` step-by-step to configure external services

Good luck! 🚀
