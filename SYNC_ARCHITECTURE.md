# WhisperLog Data Sync Architecture

Complete guide to bidirectional Firebase ↔ SQLite synchronization and transcript processing.

## Overview

WhisperLog uses a **dual-storage model**:
- **SQLite (Local)**: Primary cache for instant UI updates
- **Firebase (Cloud)**: Source of truth for multi-device sync and backup

```
Recording → SQLite (immediate) → Firebase (async) ↔ External APIs
   ↓          ↓
Overlay    Local cache        Cloud enrichment
           + AI processing    + Multi-device sync
```

---

## Data Flow Architecture

### Phase 1: Capture & Local Storage

```mermaid
Recording
   ↓
CaptureService.ingestRawCapture()
   ├─ Input: rawTranscript (from speech-to-text)
   ├─ Create Note object:
   │  ├─ note_id: timestamp_randomInt
   │  ├─ uid: user.uid or "local_anonymous"
   │  ├─ status: "pendingAi"
   │  ├─ category: heuristic guess
   │  ├─ priority: "medium" (default)
   │  ├─ source: "overlay" (or "homeWritingBox", etc.)
   │  └─ raw_transcript: user's input
   ├─ SQLite UPSERT
   │  └─ Emits SqliteNoteStore.changes stream
   ├─ NoteEventBus.emitNoteSaved(noteId)
   │  └─ Triggers AiProcessingService listener
   └─ Firebase SET (merge: true) ← if authenticated
      └─ Document: users/{uid}/notes/{noteId}
         └─ status: "pendingAi"
```

**Key Points:**
- SQLite write happens first (instant UI update)
- Firebase sync is async (doesn't block UI)
- Status is "pendingAi" until AI enrichment completes
- Event bus triggers AI processing immediately

---

### Phase 2: AI Enrichment (Dual Path)

#### Path A: Cloud Function (Server-Side)

```
Firebase Document created (status: "pendingAi")
   ↓
Firestore trigger: onDocumentCreated
   ├─ Check: is status === "pendingAi"?
   ├─ Call Gemini API with raw_transcript
   ├─ Parse response: {title, category, priority, clean_body, extracted_date}
   └─ Update Firestore document:
      ├─ title, clean_body, category, priority, extracted_date
      ├─ ai_model: "gemini-2.5-flash-lite"
      └─ status: "active"
      
Result: Firestore note is enriched server-side
```

**When it triggers:** Only once per document (new creation)

#### Path B: Client-Side Processing (Backup)

```
NoteEventBus.onNoteSaved triggered
   ↓
AiProcessingService.processNoteById(noteId)
   ├─ Get note from SQLite
   ├─ Check: status === "pendingAi"?
   ├─ Call AiClassifierRouter (Gemini or Groq)
   ├─ Update SQLite with enriched data
   ├─ Call ExternalSyncService.syncExternalForNote()
   │  └─ Create Google Calendar/Tasks if needed
   ├─ _syncToFirestore(enrichedNote)
   │  └─ Set Firestore document (merge: true)
   └─ Firebase updated with:
      ├─ title, clean_body, category, priority, extracted_date
      ├─ gcal_event_id, gtask_id (if created)
      ├─ ai_model: "groq-mixtral-8x7b" (or Gemini if fallback)
      └─ status: "active"
```

**When it triggers:** 
- Immediately after capture (via NoteEventBus)
- On app startup (sweeps pending notes)
- When connectivity returns (WorkManager)

**Timeout handling:**
```
If AiProcessingService timesout or errors:
├─ Note stays as "pendingAi" in SQLite
├─ Cloud Function can still process it (if deployed)
└─ Retry on next app start or connectivity event
```

---

### Phase 3: External API Sync (Google Calendar/Tasks)

```
Active note with category === "reminders" or "tasks"
   ↓
ExternalSyncService.syncExternalForNote(note)
   ├─ Check: Google Sign-In connected?
   ├─ If category === "reminders" + extracted_date:
   │  └─ Create Google Calendar event (2 days before)
   │     └─ Store event_id in note.gcal_event_id
   ├─ If category === "tasks":
   │  └─ Create Google Task
   │     └─ Store task_id in note.gtask_id
   └─ Update SQLite + Firebase with IDs
   
WorkManager periodic task (every 4 hours):
   ├─ Check Google Tasks for completed items
   ├─ Match task_id to notes with gtask_id
   └─ Archive matched notes (status: "archived")
```

---

### Phase 4: Bidirectional Sync

#### 4A: SQLite → Firebase (Push)

**Trigger points:**

1. **CaptureService.ingestRawCapture()** ← User creates note
   ```dart
   await _syncNoteToFirestore(pending); // Push initial note
   ```

2. **AiProcessingService.processNoteById()** ← AI enrichment complete
   ```dart
   await _syncToFirestore(enrichedNote); // Push enriched data
   ```

3. **ExternalSyncService.syncExternalForNote()** ← Google APIs updated
   ```dart
   await _syncNoteToFirestore(updatedNote); // Push IDs
   ```

**Implementation:**
```dart
// All use the same pattern:
await _firestore
    .collection('users')
    .doc(uid)
    .collection('notes')
    .doc(noteId)
    .set(note.toFirestoreJson(), SetOptions(merge: true));
```

**Merge behavior:** 
- Only specified fields updated
- Existing fields preserved
- No data loss on partial updates

#### 4B: Firebase → SQLite (Pull)

**Trigger points:**

1. **FCM Message** ← Cloud Function sends push notification
   ```
   FCM payload:
   {
     "type": "note_updated",
     "note_id": "1234567890_12345"
   }
   
   Handler:
   ├─ FirestoreNoteSyncService.syncNoteById(noteId)
   ├─ Fetch from Firestore
   └─ Upsert to SQLite
   ```

2. **Status Change Notification** ← Cloud Function marks note enriched
   ```
   FCM payload:
   {
     "type": "note_status_changed",
     "note_id": "1234567890_12345",
     "status": "active"
   }
   
   Handler:
   ├─ FirestoreNoteSyncService.applyStatusFromPush(noteId, state)
   ├─ Get existing note from SQLite
   └─ Update status + timestamps
   ```

3. **WorkManager Periodic Task** ← Scheduled sync
   ```
   registerPeriodicGoogleTasksSync(): every 4 hours
   registerTelegramDailyDigest(): daily
   
   Flow:
   ├─ Get all active notes from SQLite
   ├─ For each: ExternalSyncService.syncExternalForNote()
   └─ Push any changes back to Firebase
   ```

4. **Manual Sync** ← User taps refresh button (if implemented)
   ```dart
   await externalSyncService.syncNow();
   ```

---

## State Machine: Note Lifecycle

```
                          ┌─────────────────────────┐
                          │  SYNC IN PROGRESS       │
                          │  (pendingAi)            │
                          └──────────┬──────────────┘
                                     │
                    ┌────────────────┼────────────────────┐
                    ▼                ▼                    ▼
            ┌──────────────┐  ┌──────────────┐   ┌───────────────┐
            │ Cloud Fn     │  │ Client Fn    │   │ Sync Fails    │
            │ Enriches     │  │ Enriches     │   │ (Retry)       │
            └──────┬───────┘  └──────┬───────┘   └───────────────┘
                   │                 │                    
                   │                 │
                   └────────────┬────┘
                                ▼
                    ┌────────────────────────┐
                    │ ACTIVE                 │
                    │ (status: "active")     │
                    │ Ready for user view    │
                    └────────────┬───────────┘
                                 │
                ┌────────────────┼────────────────┐
                ▼                ▼                ▼
        ┌─────────────┐  ┌────────────┐  ┌──────────────┐
        │ User marks  │  │ Task auto  │  │ User archives│
        │ as complete │  │ completes  │  │    note      │
        └──────┬──────┘  └──────┬─────┘  └──────┬───────┘
               │                 │               │
               └────────────┬────┴───────────────┘
                            ▼
                 ┌──────────────────────┐
                 │ ARCHIVED             │
                 │ (status: "archived") │
                 │ Hidden from view     │
                 └──────────────────────┘
```

---

## Consistency & Conflict Resolution

### Conflict Scenarios

#### Scenario 1: Stale Local Edit
```
Device A: Note marked as "archived" locally
Device B: Cloud Function updates same note to "active"

Resolution:
├─ FCM push from Cloud Fn triggers pull
├─ Firebase version fetched to SQLite
├─ Device A's local change checked: is syncedAt older?
└─ YES → Firebase version wins (latest is authoritative)
```

#### Scenario 2: Offline Changes
```
User edits note while offline
├─ Changes saved to SQLite
├─ Firebase sync queued
└─ When online:
   ├─ Check timestamps (updatedAt)
   └─ If local updatedAt > Firebase updatedAt:
      └─ Push to Firebase (local wins)
      └─ Otherwise: Pull from Firebase (cloud wins)
```

**Current strategy:** 
- Last write wins (based on `updatedAt` timestamp)
- Server (Firebase) is source of truth when timestamps tie
- Manual conflict resolution if needed (user sees warning)

---

## Data Consistency Guarantees

### Strong Consistency (Guaranteed)
- ✅ Each note has unique `note_id` (no duplicates)
- ✅ `uid` always matches authenticated user
- ✅ `created_at` never changes
- ✅ `updated_at` monotonically increases (or tied to server time)

### Eventual Consistency (Within seconds)
- ≈ SQLite updated immediately, Firebase after network request
- ≈ Firebase Firestore listeners notify client after update
- ≈ Cross-device sync via FCM (Firebase Cloud Messaging)

### What might be inconsistent temporarily
- ❓ Note visible on one device but not another (until FCM reaches)
- ❓ Status showing "active" locally but "pendingAi" on server (until pull sync)
- ❓ Google Calendar event created but `gcal_event_id` not yet synced

### Mitigation strategies
1. **Immediate local UI update:** SQLite writes first
2. **Gentle server sync:** All writes use `merge: true` (no overwrites)
3. **Retries:** Failed syncs retry on connectivity restoration
4. **Event-driven:** NoteEventBus triggers processing without waiting

---

## Detailed Sync Flow Diagram

```
USER INPUT
   │
   ├─ Recording (overlay)
   ├─ Text input (home)
   └─ Quick edit
        │
        ▼
   CaptureService.ingestRawCapture()
        │
        ├─ Create Note (status: "pendingAi")
        ├─ UPSERT to SQLite ◄─ IMMEDIATE UI UPDATE
        │
        └─ emit NoteEventBus.onNoteSaved(noteId)
             │
             ├─ (parallel) _syncNoteToFirestore(note)
             │   └─ Firebase SET (merge)
             │
             └─ AiProcessingService listener triggered
                 │
                 ├─ Get from SQLite
                 ├─ Call AI (Gemini/Groq)
                 │
                 ├─ UPSERT enriched Note to SQLite
                 │
                 ├─ ExternalSyncService.syncExternalForNote()
                 │  ├─ Create Google Calendar event (if appropriate)
                 │  ├─ Create Google Task (if appropriate)
                 │  └─ UPSERT with IDs back to SQLite
                 │
                 └─ _syncToFirestore(updatedNote)
                     └─ Firebase SET (merge) with enriched data
                         │
                         └─ Cloud Function already processed?
                             ├─ YES: Our merge updates any missed fields
                             └─ NO: Acts as fallback enrichment
                         
                         Cloud Function (if not yet run)
                         ├─ Triggered by Firestore document creation
                         ├─ Checks status === "pendingAi"
                         └─ Calls Gemini → updates Firestore
                             │
                             └─ Send FCM: "note_updated"
                                 │
                                 └─ Client receives FCM
                                     ├─ Pull updated note from Firestore
                                     └─ UPSERT to SQLite
```

---

## Implementation Details

### SQLite Schema
```sql
CREATE TABLE notes (
  note_id TEXT PRIMARY KEY,           -- Unique ID: timestamp_random
  uid TEXT NOT NULL,                  -- User ID or "local_anonymous"
  raw_transcript TEXT NOT NULL,       -- Original user input
  title TEXT NOT NULL,                -- AI-extracted or fallback
  clean_body TEXT NOT NULL,           -- AI-enhanced version
  category TEXT NOT NULL,             -- tasks|reminders|ideas|follow-up|journal|general
  priority TEXT NOT NULL,             -- high|medium|low
  extracted_date TEXT,                -- ISO8601 or NULL
  created_at TEXT NOT NULL,           -- ISO8601, immutable
  updated_at TEXT NOT NULL,           -- ISO8601, updated whenever note changes
  status TEXT NOT NULL,               -- pendingAi|active|archived
  ai_model TEXT NOT NULL,             -- "gemini-2.5-flash-lite" or "groq-mixtral-8x7b" or ""
  gcal_event_id TEXT,                 -- Google Calendar event ID or NULL
  gtask_id TEXT,                      -- Google Tasks task ID or NULL
  source TEXT NOT NULL,               -- overlay|homeWritingBox (capture source)
  synced_at TEXT                      -- ISO8601, last sync to Firebase
);

-- Indices for performance
CREATE INDEX idx_notes_status ON notes(status);
CREATE INDEX idx_notes_category ON notes(category);
CREATE INDEX idx_notes_updated_at ON notes(updated_at);
CREATE INDEX idx_notes_priority ON notes(priority);
```

### Firestore Schema
```javascript
users/{uid}/notes/{noteId} : {
  note_id: string,
  uid: string,
  raw_transcript: string,
  title: string,
  clean_body: string,
  category: string,
  priority: string,
  extracted_date: timestamp | null,
  created_at: timestamp,
  updated_at: timestamp,
  status: string,       // Also a collection index for queries
  ai_model: string,
  gcal_event_id: string | null,
  gtask_id: string | null,
  source: string,
  synced_at: timestamp | null,
}
```

### Firestore Security Rules
```javascript
match /users/{uid}/notes/{noteId} {
  allow read: if request.auth.uid == uid;
  allow create: if request.auth.uid == uid && 
                   request.resource.data.status == 'pendingAi';
  allow update: if request.auth.uid == uid;
  allow delete: if request.auth.uid == uid;
}
```

---

## Transcript Categorization Details

### How Categorization Works

```
Raw Input
   ↓
1. Client heuristic (CaptureService._initialCategory)
   ├─ Keywords: "todo", "task", "finish", "deadline"      → tasks
   ├─ Keywords: "remind", "tomorrow", "at 3pm"            → reminders
   ├─ Keywords: "idea", "brainstorm", "concept"           → ideas
   ├─ Keywords: "follow up", "ping", "check back"         → follow-up
   ├─ Keywords: "journal", "mood", "felt", "dear diary"   → journal
   └─ Fallback                                             → general
   
   [Saved with guess, status: pendingAi]
   ▼
2. Cloud Function (enrichPendingAiNote)
   ├─ Calls Gemini API
   ├─ Inputs: SYSTEM_PROMPT + raw_transcript
   └─ Gemini returns improved category
   
   ├─ Map response: "Task" → "tasks", "reminder" → "reminders"
   ├─ Fallback on parse error: keep heuristic
   └─ Update Firestore with Gemini's category
   
   ▼
3. Client-side backup (AiProcessingService)
   ├─ Also processes with Gemini/Groq
   └─ Updates SQLite + Firebase if Cloud Fn missing
   
   ▼
4. Result: Both Firebase and SQLite have finalized category
   ├─ UI filters by category
   └─ User can manually override if needed
```

### Category Hierarchy
```
All Notes (union)
├─ Tasks (status: active, category: tasks)
│  └─ Usually synced to Google Tasks
├─ Reminders (status: active, category: reminders)
│  └─ Usually synced to Google Calendar
├─ Ideas (status: active, category: ideas)
├─ Follow-ups (status: active, category: follow-up)
├─ Journal (status: active, category: journal)
└─ General (status: active, category: general)
+ Archived (status: archived)
```

### File Organization (Logical)
Notes are NOT stored as files, but as records in SQLite and Firestore.
To export transcripts for analysis:

```bash
# Export by date/category
SELECT * FROM notes 
WHERE category = 'tasks' 
  AND DATE(created_at) = '2026-04-05'
ORDER BY created_at DESC;
```

To convert to files:
```json
// 2026-04-05/note_1234567890_12345.json
{
  "note_id": "1234567890_12345",
  "raw_transcript": "buy milk",
  "title": "Buy milk",
  "clean_body": "Purchase milk from grocery store",
  "category": "tasks",
  "status": "active",
  "created_at": "2026-04-05T10:30:00Z"
}
```

---

## Monitoring & Debugging

### Key Logs to Monitor

```
[CaptureService] Saving note: {noteId}
[CaptureService] Syncing note to Firestore: {noteId}
[AiProcessingService] Processing note: {noteId}
[AiProcessingService] Firebase sync result: true|false
[FirestoreNoteSyncService] Syncing note {noteId} from Firestore
[SqliteNoteStore] Ready at /path/to/db
[FcmSyncService] Got token
[FcmSyncService] Push received: {type} {noteId}
```

### Testing Bidirectional Sync

```
1. Create note via overlay
   ├─ Check: SQLite has note (status: pendingAi)
   ├─ Check: Firestore has note
   └─ Check: Logs show sync attempts

2. Wait for AI enrichment
   ├─ Check: Note status → "active"
   ├─ Check: Title/clean_body populated
   ├─ Check: Cloud Function logs show success
   └─ Check: Both SQLite and Firestore updated consistently

3. Sign in on another device
   ├─ Force sync (if button available)
   ├─ Check: Note appears on Device B
   ├─ Edit note on Device B
   ├─ Check: Edit appears on Device A (via FCM)
   └─ Verify: timestamp consistency
```

---

## Performance Optimizations

### SQLite
- ✅ Indices on `status`, `category`, `updated_at`, `priority`
- ✅ Batch inserts via SQLite transactions
- ✅ Connection pooling (sqflite manages this)

### Firebase
- ✅ Document-level writes (not full collection)
- ✅ `merge: true` prevents overwrites
- ✅ Firestore listeners only on active notes
- ✅ FCM for push notifications (no polling)

### Caching
- ✅ Local SQLite as primary cache
- ✅ In-memory note set in `AiProcessingService._inFlightNoteIds`
- ✅ Prevents duplicate processing

### Rate Limiting
- ⚠️ WorkManager tasks run at most every 4 hours
- ⚠️ Exponential backoff for failed Cloud Function calls
- ⚠️ Gemini API costs ~$0.00006 per call

---

## Future Improvements

### Short Term
- [ ] Manual sync button for on-demand pulls
- [ ] Sync status indicator (last synced time)
- [ ] Conflict resolution UI (manual override if timestamps tie)
- [ ] Export transcripts as .json or .pdf

### Medium Term
- [ ] Offline draft support (store unsent notes locally)
- [ ] Bandwidth optimization (compression for transcripts)
- [ ] Batch AI processing (group pending notes)
- [ ] Custom category creation

### Long Term
- [ ] Multi-workspace support
- [ ] Collaborative notes (shared with team)
- [ ] Advanced analytics (notes per category, trends)
- [ ] Voice query search
- [ ] Integration with Slack/Discord

---

**Last Updated:** 2026-04-05
**Version:** 1.0
