# WhisperLog External Setup Guide

This document tracks all external setup requirements and dependencies that need to be configured for WhisperLog to function properly across all features.

## ✅ Completion Checklist

---

## 1. Firebase Setup

### 1.1 Firebase Project Configuration
- [ ] Create Firebase project at [console.firebase.google.com](https://console.firebase.google.com)
- [ ] Enable Authentication (Google Sign-In)
  - Go to Authentication → Sign-in method → Enable Google
  - Configure OAuth consent screen with required scopes
- [ ] Enable Firestore Database
  - Create database in production mode
  - Set location: `us-central1` (or your region)
- [ ] Enable Firebase Cloud Messaging (FCM)
- [ ] Enable Cloud Functions

### 1.2 Firestore Security Rules
Currently using test rules. **Before production:**
```
Visit: Firebase Console → Firestore → Rules
Replace with production rules from firestore.rules file
```

**Current status:** 
- [ ] Firestore rules reviewed and updated (check `firestore.rules`)
- [ ] Test rules replaced with production rules

### 1.3 Firebase Configuration Files
- [ ] `firebase.json` configured with correct project ID
- [ ] `android/app/google-services.json` downloaded from Firebase
- [ ] `ios/Runner/GoogleService-Info.plist` downloaded from Firebase
- [ ] `ios/Runner/GoogleService-Info.plist` added to Xcode project

### 1.4 Firebase Android Configuration (No API Key Needed)
**Android uses SHA-1 fingerprint for Firebase authentication, not an API key.**

- [ ] Get app SHA-1 fingerprint:
  ```bash
  cd android && ./gradlew signingReport
  # Look for SHA-1 under debugKeystore
  # Example: AB:CD:EF:01:23:45:67:89:AB:CD:EF:01:23:45:67:89:AB:CD:EF:01
  ```
- [ ] Add SHA-1 to Firebase Console:
  - Firebase Console → Project Settings → Your apps → Android app
  - Add fingerprint under "SHA-1 certificate fingerprint"
- [ ] `google-services.json` downloaded and placed at `android/app/google-services.json`
- [ ] No `.env` configuration needed for Firebase on Android

---

## 2. Google Cloud APIs

### 2.1 Google Calendar API
**Purpose:** Create calendar events for reminder-categorized notes

- [ ] Enable Google Calendar API in [Google Cloud Console](https://console.cloud.google.com)
- [ ] OAuth 2.0 credentials configured (already via Google Sign-In)
- [ ] Calendar ID detected from signed-in user

**What it does:**
- Creates calendar events 2 days before the extracted date
- Links event ID to note for tracking

**Troubleshooting:** If calendar events aren't created:
1. User must have signed in with Google
2. Check logs: `[ExternalSyncService] _createCalendarReminderIfMissing`
3. Verify Google account permissions

### 2.2 Google Tasks API
**Purpose:** Create tasks for task-categorized notes

- [ ] Enable Google Tasks API in [Google Cloud Console](https://console.cloud.google.com)
- [ ] OAuth 2.0 credentials configured (already via Google Sign-In)

**What it does:**
- Creates tasks in Google Tasks
- Syncs completion status back to notes
- Runs every 4 hours to check for completed tasks

**Troubleshooting:** If tasks aren't created:
1. Check OAuth scopes in `external_sync_service.dart` include `gtasks.TasksApi.tasksScope`
2. Verify user is signed into Google
3. Look for `[ExternalSyncService] _createGoogleTask` logs

---

## 3. Gemini API (AI Enrichment)

### 3.1 API Setup
**Purpose:** Process raw transcripts to extract title, category, priority, date, and clean text

- [ ] Create Gemini API project in [Google AI Studio](https://aistudio.google.com)
- [ ] Generate API key
- [ ] Set environment variable:
  ```bash
  export GEMINI_API_KEY=your-gemini-api-key
  ```

### 3.2 Cloud Functions Configuration
**Deploy the enrichment function:**

```bash
cd functions
firebase functions:config:set gemini.api_key="YOUR_KEY_FROM_STEP_3.1"
firebase deploy --only functions
```

**What it does:**
- Cloud Function `enrichPendingAiNote` triggers on new `pendingAi` notes
- Calls Gemini 2.5 Flash Lite to classify and enrich
- Updates Firestore with: title, category, priority, clean_body, extracted_date
- Marks note as `active` when complete

**Monitoring:**
```bash
firebase functions:log
# Look for [enrichPendingAiNote] entries
```

**Cost:** ~$0.00006 per note (10K notes/month = $0.60)

### 3.3 Categories Supported
Gemini maps any user input to canonical categories:
- `tasks` - Action items
- `reminders` - Time-sensitive reminders
- `ideas` - Creative concepts
- `follow-up` - Follow-ups with people/tasks
- `journal` - Personal journaling
- `general` - Miscellaneous

---

## 4. Speech-to-Text (Voice)

### 4.1 Android Setup
- [ ] `speech_to_text` Flutter package installed
- [ ] Microphone permission granted at runtime
- [ ] Language support: English (en-US recommended)

**Troubleshooting:**
- If overlay recording doesn't capture audio: Check Android settings → Apps → WhisperLog → Permissions → Microphone
- If transcription is empty: Verify microphone is working with voice recorder app

### 4.2 iOS Setup
- [ ] `speech_to_text` Flutter package installed
- [ ] Microphone permission in `ios/Runner/Info.plist`
- [ ] Speech recognition permission in `ios/Runner/Info.plist`

---

## 5. Local Notifications (Optional)

### 5.1 Android Setup
- [ ] `flutter_local_notifications` supports Android 5.0+
- [ ] Permission to post notifications (Android 13+)

**What it does:**
- Shows local alerts for sync status
- Can be extended for recording reminders

---

## 6. Firebase Cloud Functions Deployment

### 6.1 Prerequisites
- [ ] Firebase CLI installed: `npm install -g firebase-tools`
- [ ] Node.js 20+ installed
- [ ] Authenticated: `firebase login`

### 6.2 Deploy Steps
```bash
cd /home/veerbhadra/StudioProjects/wishperlog

# Set Gemini API key
firebase functions:config:set gemini.api_key="YOUR_KEY"

# Deploy functions
firebase deploy --only functions

# Verify deployment
firebase functions:log
```

### 6.3 Available Cloud Functions

#### `enrichPendingAiNote` (Firestore Trigger)
- **Trigger:** Document create at `users/{uid}/notes/{noteId}`
- **Condition:** Automatically processes notes with `status == "pendingAi"`
- **Action:** 
  1. Calls Gemini API
  2. Extracts title, category, priority, clean_body, extracted_date
  3. Updates Firestore document
  4. Changes status to `active`

#### `sendTelegramDigest` (Scheduled, if configured)
- **Trigger:** Runs near configured digest time daily
- **Requires:** `TELEGRAM_BOT_TOKEN` environment variable
- **Action:** Sends daily task digest to Telegram

#### `syncGoogleTaskCompletions` (Scheduled, if configured)
- **Trigger:** Runs every 4 hours
- **Action:** Checks completed Google Tasks and archives linked notes

---

## 7. SQLite Local Database

### 7.1 Database Location
- **Android:** `/data/data/com/yourapp/databases/wishperlog_notes.db`
- **iOS:** `Documents/wishperlog_notes.db`
- **Web:** IndexedDB (browser-dependent)

### 7.2 Database Schema
```sql
CREATE TABLE notes (
  note_id TEXT PRIMARY KEY,
  uid TEXT NOT NULL,
  raw_transcript TEXT NOT NULL,
  title TEXT NOT NULL,
  clean_body TEXT NOT NULL,
  category TEXT NOT NULL,
  priority TEXT NOT NULL,
  extracted_date TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  status TEXT NOT NULL,
  ai_model TEXT NOT NULL,
  gcal_event_id TEXT,
  gtask_id TEXT,
  source TEXT NOT NULL,
  synced_at TEXT
);
```

### 7.3 Sync Status
- [ ] Verify SQLite initializes on app startup
- [ ] Check logs: `[SqliteNoteStore] Ready at /path/to/db`

---

## 8. Data Sync Flow (Critical)

### 8.1 Note Creation Flow
```
Recording → Overlay captures audio → Speech-to-text → Raw transcript
  ↓
CaptureService.ingestRawCapture()
  ├─ Save to SQLite with status: "pendingAi"
  ├─ Sync snapshot to Firebase
  └─ Emit NoteEventBus event
```

### 8.2 AI Enrichment Flow
```
Cloud Function triggers (Firebase Trigger)
  ↓
enrichPendingAiNote calls Gemini API
  ├─ Input: raw_transcript
  └─ Output: title, category, priority, clean_body, extracted_date
  
Firestore updated with enriched data (status → "active")
  ↓
AiProcessingService (local) also processes
  ├─ Updates SQLite with enriched data
  └─ Syncs back to Firebase
```

### 8.3 External Sync Flow (Google Calendar/Tasks)
```
ExternalSyncService processes active notes
  ├─ Category == "reminders" + extracted_date
  │   └─ Create Google Calendar event
  ├─ Category == "tasks"
  │   └─ Create Google Task
  └─ Save IDs back to note (gcal_event_id, gtask_id)
```

### 8.4 Firebase → SQLite Pull (On Demand)
```
FirestoreNoteSyncService.syncNoteById(noteId)
  ├─ Fetch note from Firestore
  ├─ Parse into Note object
  └─ Upsert to SQLite
```

**Triggered by:**
- FCM message from Cloud Function
- Manual sync button (if implemented)
- WorkManager periodic tasks

### 8.5 SQLite → Firebase Push (On Update)
```
CaptureService.ingestRawCapture()
  └─ _syncNoteToFirestore(note)
    └─ Set document with merge: true

AiProcessingService.processNoteById()
  └─ _syncToFirestore(enrichedNote)
    └─ Set document with merge: true
```

**Current status:**
- [ ] Firebase pulls new notes from Firestore ✓
- [ ] SQLite pushes all updates to Firebase ✓
- [ ] Bidirectional sync tested end-to-end

---

## 9. Transcript Organization & Categorization

### 9.1 Folder Structure (Logical)
```
WhisperLog (App)
├─ All Notes (default view - SQLite)
├─ Transcripts (by date)
│  ├─ 2026-04-05/
│  │  ├─ note_1234567890_1.txt (raw)
│  │  └─ note_1234567890_1_enriched.json (AI processed)
│  └─ 2026-04-04/
├─ Tasks (category filter)
├─ Reminders (category filter)
├─ Ideas (category filter)
├─ Follow-ups (category filter)
├─ Journal (category filter)
└─ General (category filter)
```

### 9.2 Categorization Flow
```
Raw Transcript
  ↓
CaptureService._initialCategory() [heuristic match, medium priority]
  ↓
Uploaded to Firebase as: status="pendingAi", category=heuristic
  ↓
Cloud Function enrichPendingAiNote [Gemini categorizes accurately]
  ↓
Category updated in Firestore + SQLite
  ↓
UI filters by category
```

### 9.3 Transcript File Format (SQLite)
Each note is stored as a record:
```json
{
  "note_id": "1234567890_12345",
  "uid": "user_id",
  "raw_transcript": "buy milk tomorrow before 5pm",
  "title": "Buy milk",
  "clean_body": "Buy milk before 5 PM tomorrow",
  "category": "reminders",
  "priority": "medium",
  "extracted_date": "2026-04-06T17:00:00Z",
  "created_at": "2026-04-05T10:30:00Z",
  "updated_at": "2026-04-05T10:31:00Z",
  "status": "active",
  "ai_model": "gemini-2.5-flash-lite",
  "gcal_event_id": null,
  "gtask_id": null,
  "source": "overlay",
  "synced_at": "2026-04-05T10:31:05Z"
}
```

### 9.4 Organization by Status
- `pendingAi` - Awaiting AI enrichment (temporary)
- `active` - Processed, ready for user view
- `archived` - Marked complete or dismissed
- `deleted` - Soft delete (if implemented)

---

## 10. Troubleshooting Checklist

### 10.1 "Note stuck in pendingAi"
- [ ] Check Cloud Function logs: `firebase functions:log`
- [ ] Verify Gemini API key is set: `firebase functions:config:get`
- [ ] Check Firestore document has `raw_transcript` field
- [ ] Verify user is authenticated (uid != "local_anonymous")

### 10.2 "Recording not being captured"
- [ ] Verify overlay is enabled (Settings → Overlay)
- [ ] Check Android/iOS microphone permission is granted
- [ ] Confirm `speech_to_text` package is working
- [ ] Check logs: `[_DraggableCaptureBubble]` entries

### 10.3 "Firebase not syncing"
- [ ] Verify user is logged in (check Firebase Auth in console)
- [ ] Check internet connection (WiFi or mobile data)
- [ ] Look at logs: `[CaptureService] Syncing note to Firestore:`
- [ ] Verify Firestore security rules allow user writes

### 10.4 "Google Calendar/Tasks not linking"
- [ ] User must be signed into Google (separate from Firebase)
- [ ] Check Google scopes in `external_sync_service.dart`
- [ ] Verify note has `category == "reminders"` or `"tasks"`
- [ ] Confirm `extracted_date` is set for calendar events
- [ ] Check logs: `[ExternalSyncService]` entries

### 10.5 "SQLite database errors"
- [ ] Uninstall and reinstall app (clears local DB)
- [ ] Check available storage on device
- [ ] Verify SQLite indices are created: `[SqliteNoteStore] Ready at`

---

## 11. Environment Variables Reference

### 11.1 Firebase Configuration
**Android:** Firebase configuration is handled by `google-services.json` (no `.env` needed)

**If using web/debug:**
```
# These are NOT needed for Android native apps
# Firebase Console auto-configures via google-services.json
```

**Required:** SHA-1 fingerprint registered in Firebase Console (see 1.4)

### 11.2 Cloud Functions Environment
Set via Firebase CLI:
```bash
firebase functions:config:set gemini.api_key="your-gemini-key"
firebase functions:config:set telegram.bot_token="your-bot-token" # Optional
firebase functions:config:set telegram.chat_id="your-chat-id"     # Optional
```

### 11.3 Local Development
```bash
# Enable Firebase emulator (optional)
firebase emulators:start

# Deploy functions with environment vars
firebase deploy --only functions
```

---

## 12. Quick Start (New Setup)

### 12.1 Step-by-Step
1. **Firebase Project**: Create at console.firebase.google.com
2. **Download config files**: 
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`
3. **Enable APIs**:
   - Authentication (Google Sign-In)
   - Firestore Database
   - Cloud Functions
   - Cloud Messaging
4. **Google Cloud APIs**:
   - Enable Google Calendar API
   - Enable Google Tasks API
5. **Get SHA-1 Fingerprint**:
   ```bash
   cd android && ./gradlew signingReport
   # Copy SHA-1 from debugKeystore
   ```
6. **Add SHA-1 to Firebase Console** (Project Settings → Your apps → Android)
7. **Gemini API**: Create key at aistudio.google.com
8. **Deploy Cloud Functions**:
   ```bash
   cd functions
   firebase functions:config:set gemini.api_key="YOUR_KEY"
   firebase deploy --only functions
   ```
9. **Update `.env`**: Add Gemini and other API keys (not Firebase)
10. **Build & Run**:
   ```bash
   flutter pub get
   flutter run
   ```

---

## 13. Monitoring & Debugging

### 13.1 Logs to Watch
```bash
# Real-time Cloud Function logs
firebase functions:log

# Firestore activity
# Dashboard → Firestore → Logs

# SQLite operations
# Run app with Flutter DevTools and search for [SqliteNoteStore]

# AI Processing
# Search for [AiProcessingService] and [enrichPendingAiNote]

# Sync operations
# Search for [FirestoreNoteSyncService] and [ExternalSyncService]
```

### 13.2 Test Checklist (Per Session)
- [ ] Create a note via overlay
- [ ] Verify note appears in Firestore
- [ ] Verify Cloud Function processes it
- [ ] Check note is enriched with category & title
- [ ] Confirm note is in "active" status
- [ ] Navigate to category view and see it listed
- [ ] If reminder/task: Check Google Calendar/Tasks for linked items

---

## 14. Common Issues & Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Note stuck in `pendingAi` | Cloud Function timeout or Gemini API error | Check `firebase functions:log` for errors; verify API key |
| Firebase write fails | User not authenticated or rules too strict | Verify user login; check Firestore security rules |
| No recording captured | Microphone permission denied | Grant permission in Settings > Apps > WhisperLog > Permissions |
| Calendar/Tasks not created | Category mismatch or Google Sign-In missing | Ensure category matches ("reminders" or "tasks"); verify Google Sign-In |
| SQLite initialization fails | Corrupted database or low storage | Uninstall app, clear data, reinstall |
| FCM push not received | Firebase Messaging token not updated | Restart app; check device has internet |

---

## 15. Production Checklist

Before deploying to production:
- [ ] Firestore security rules updated (not test mode)
- [ ] All environment variables set securely
- [ ] Cloud Functions deployed and tested
- [ ] Google API credentials restricted by API type
- [ ] Firebase error tracking enabled (Crashlytics)
- [ ] Database backups configured
- [ ] Rate limiting on Cloud Functions set
- [ ] No debug logs in production builds

---

## Notes & Updates

**Last Updated:** 2026-04-05

**Ongoing Tasks:**
- [ ] Test full sync cycle: overlay → Firestore → SQLite → categorization
- [ ] Verify bidirectional sync consistency
- [ ] Monitor Cloud Function costs and optimize if needed
- [ ] Set up production error tracking

---
