# WhisperLog: Bug Audit & Known Issues

**Last Updated**: 2026-04-04  
**Status**: Architecture complete. Data pipeline verified. Codebase: 0 compilation errors.

---

## Active Investigation

### [Critical] AI Polling Loop Architecture Violation (Timer.periodic Every 8s)

**Severity**: Critical  
**Status**: Open  
**Type**: Architecture Violation  
**Affected Files**: 
- lib/features/ai/data/ai_processing_service.dart
- lib/main.dart

#### Description
- The codebase currently runs AI processing using `Timer.periodic(const Duration(seconds: 8), ...)`.
- This violates the blueprint requirement for event-driven processing and introduces constant background wakeups.

#### Evidence
- `AiProcessingService.start()` creates an 8-second periodic timer.
- App startup invokes `sl<AiProcessingService>().start()`.

#### Expected Behavior
- AI processing must trigger from a `NoteSaved` event stream immediately after successful local Isar save.
- No perpetual polling loop should exist for AI classification.

#### Proposed Fix
1. Introduce a `NoteSaved` event stream in the domain layer.
2. Emit `NoteSaved(noteId)` after successful `writeTxn` local commit.
3. Refactor `AiProcessingService` to subscribe to event stream and process targeted note IDs.
4. Remove `Timer.periodic` logic entirely.

### [High] Missing Telegram Daily Digest WorkManager Worker (9 AM Client-Side)

**Severity**: High  
**Status**: Open  
**Type**: Missing Feature  
**Affected Files**:
- lib/core/background/work_manager_service.dart
- lib/main.dart
- lib/features/settings/presentation/screens/settings_screen.dart

#### Description
- Blueprint requires a client-side WorkManager task to deliver Telegram daily digest at 9:00 AM local time.
- Current `WorkManagerService` schedules Google task completion sync and pending AI flush only.
- Telegram digest configuration UI exists, but no corresponding digest worker exists in Dart runtime.

#### Expected Behavior
- A dedicated daily local-time WorkManager task should:
   1. query active notes from Isar,
   2. format digest summary,
   3. send to Telegram Bot API.

#### Proposed Fix
1. Add `telegram_daily_digest` unique work registration with local-time 09:00 scheduling strategy.
2. Implement worker branch in callback dispatcher for digest generation/sending.
3. Reuse digest time from settings and user timezone offset data.
4. Add retry/backoff plus idempotency guard for same-day sends.

### [Critical] Isar Half-Initialized Instance Crash (LateInitializationError: _collections)

**Severity**: Critical  
**Status**: Open / Reproducible under startup race conditions  
**Frequency**: Intermittent but high-impact  
**Reported by**: Runtime crash logs (April 2026)

#### Symptoms
- App throws unhandled exception while reading notes stream.
- Crash signature:
  - `LateInitializationError: Field '_collections@...' has not been initialized`
  - Stack includes `Isar.collection -> GetNoteCollection.notes -> NoteRepository._visibleNotesSnapshot`
- Logs repeatedly show:
  - `[IsarService] Instance exists but not fully ready, reinitializing`

#### Impact
- Note streams can fail during app boot or service reattachment.
- Home/folder note counts and lists may crash before first render.
- Violates reliability requirement for local-first capture and retrieval.

#### Technical Diagnosis
- The app can obtain an Isar instance handle from `Isar.getInstance()` before internal collections are fully initialized.
- Current readiness probing attempts to call `collection<Note>()`, but a race window still exists where downstream repositories begin querying before the instance is fully usable.
- The failure manifests in read-path calls (`db.notes.where()/findAll`) from stream builders, not only write transactions.

#### Evidence (from reported stack trace)
- `Isar._collections (package:isar/src/isar.dart)`
- `Isar.collection (package:isar/src/isar.dart:190)`
- `GetNoteCollection.notes (shared/models/note.g.dart:13)`
- `NoteRepository._visibleNotesSnapshot (features/notes/data/note_repository.dart:216)`
- `NoteRepository.watchActiveCounts (features/notes/data/note_repository.dart:79)`

#### Expected Behavior
- `IsarService.init()` must return only a fully initialized, query-safe instance.
- Repository streams should never crash due to Isar internal late initialization races.

#### Proposed Fix
1. Harden Isar readiness gate:
   - Add a definitive warm-up/readiness check before returning from `init()`.
   - Treat any collection access `LateInitializationError` as non-ready and retry bounded times.
2. Serialize initialization and consumers:
   - Ensure all repository stream entry points await the same in-flight init barrier.
   - Prevent parallel init/reinit attempts from exposing partially ready handles.
3. Add repository-level defensive fallback:
   - In watch stream snapshots, catch initialization-race exceptions and retry after short backoff instead of crashing the stream.
4. Add instrumentation:
   - Log init attempt id, elapsed time, and readiness probe outcome.
   - Emit a distinct metric for "isar_half_initialized_detected".
5. Regression tests:
   - Cold start with simultaneous stream subscriptions.
   - Rapid app foreground/background transitions.
   - Simulated delayed Isar open and repeated `getInstance()` races.

### [Investigation] "Unable to save note" Error (Intermittent)

**Severity**: Medium  
**Status**: Investigating  
**Frequency**: Rare / Edge case  
**Reported by**: User feedback  

#### Symptoms
- UI shows error message: "Unable to save note"
- Note does not appear in Home Screen or Folder Screen
- Error occurs sporadically, not reproducible consistently

#### Root Cause Analysis

Based on code audit, potential root causes:

1. **Isar Transaction Failure** (Low Probability)
   - `CaptureService.ingestRawCapture()` wraps in Isar `writeTxn()`
   - If database is corrupted, transaction could fail
   - IsarService has auto-recovery (schema mismatch → purge & reinit)

2. **Firebase Initialization Timing** (Medium Probability)
   - CaptureService calls `_auth.currentUser` which may be null if Firebase init incomplete
   - Downstream `_syncNoteToFirestore()` would catch exception but log as error
   - Does NOT block local Isar save (good)

3. **Exception During ingestRawCapture** (Medium Probability)
   - Line: `await db.notes.put(pending);`
   - If Note model has missing required field → Isar throws
   - Exception is caught, logged, and rethrown to HomeScreen

#### Current Code Flow Analysis

**File**: `lib/features/capture/data/capture_service.dart`

```dart
Future<Note?> ingestRawCapture({...}) async {
  try {
    final db = await _isarService.init();  // ← Can this fail silently?
    final note = Note(...);                 // ← All fields required
    await db.writeTxn(() async {
      await db.notes.put(note);              // ← Only place transaction fails
    });
    return note;
  } catch (error, stackTrace) {
    rethrow;  // ← Propagates to HomeScreen which shows error
  }
}
```

**File**: `lib/features/home/presentation/screens/home_screen.dart`

```dart
Future<void> _saveWritingBox() async {
  try {
    await _captureService.ingestRawCapture(...);
  } catch (error, stackTrace) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to save note.')),
    );
  }
}
```

#### Fix Strategy (Phase 5+)

1. **Add Detailed Logging Before Transaction**
   ```dart
   debugPrint('[CaptureService] db=$db,.isClosed=${db.isClosed}');
   debugPrint('[CaptureService] note=$pending');
   ```

2. **Ensure Isar Initialization**
   ```dart
   if (db.isClosed) {
     throw Exception('Isar database is closed');
   }
   ```

3. **Optional: Add Retry Logic**
   ```dart
   for (var attempt = 0; attempt < 3; attempt++) {
     try {
       await db.writeTxn(() => db.notes.put(note));
       return note;
     } catch (e) {
       if (attempt < 2) await Future.delayed(Duration(ms: 100));
     }
   }
   ```

4. **Test Manually**
   - Save note while WiFi toggled off
   - Force app close during save
   - Save 100+ rapid notes
   - Verify error details in logcat

---

## Resolved Issues

### ✅ Black Screen on App Startup (FIXED - Phase 4)
**Severity**: Critical  
**Resolution**: Added startup logging, error handling, splash screen  

**Changes**:
- `lib/main.dart`: Try-catch on all init steps
- Added loading spinner during initialization
- Detailed debug logs at 12+ checkpoints

**Verification**: App now shows splash screen, no black screen observed

---

### ✅ Firebase Integration Lost (FIXED - Phase 4)
**Severity**: High  
**Resolution**: Rewired all sync services with detailed logging  

**Changes**:
- `lib/features/sync/data/firestore_note_sync_service.dart`: Added logging
- `lib/features/capture/data/capture_service.dart`: Added sync logging
- `lib/features/notes/data/note_repository.dart`: Added logging

**Verification**: Firestore sync now logs at all steps, visible in debug console

---

### ✅ FCM Token Timeout (FIXED - Phase 4)
**Severity**: Medium  
**Resolution**: Added 5-second timeout to token retrieval  

**Changes**:
- `lib/features/sync/data/fcm_sync_service.dart`: 5s timeout + error handling

**Verification**: App no longer hangs waiting for FCM token

---

### ✅ Sensitive Files in Git (FIXED - Phase 5)
**Severity**: Critical  
**Resolution**: Removed `.env` and `google-services.json` from tracking  

**Changes**:
- `git rm --cached .env`
- `git rm --cached android/app/google-services.json`
- Updated `.gitignore` with 50+ patterns
- Pushed 3 security commits

**Status**: Tracking fixed. **ACTION REQUIRED**: Regenerate API keys (see SECURITY_FIX_SUMMARY.md)

---

## Known Limitations (By Design)

1. **No Pagination for Large Note Counts**
   - Currently loads all active notes into memory
   - Future: Pagination / lazy loading for 10,000+ notes

2. **No Local Encryption**
   - Notes stored unencrypted in Isar
   - Future: Chacha20-Poly1305 encryption at rest

3. **No Note Sharing**
   - Can't share notes with other users via Firestore
   - Future: Share token-based access control

4. **No Offline Google API Sync**
   - Google Calendar/Tasks sync requires network
   - By design: API calls can't be done offline

---

## Troubleshooting Guide

### Error: "Unable to load notes right now" (Folder Screen)
**Cause**: StreamBuilder error in watch stream  
**Debug Steps**:
1. Check logcat for `[NoteRepository]` stream errors
2. Verify Isar database is initialized properly
3. Check if database file is corrupted

**Fix**:
```bash
# Clear app data (will delete all local notes)
adb shell pm clear com.adarshkumarverma.wishperlog

# Reinstall app
flutter clean && flutter run
```

### Error: "Speech input is unavailable" (Home Screen)
**Cause**: speech_to_text not initialized or permission denied  
**Debug Steps**:
1. Check if microphone permission is granted
2. Verify device supports speech recognition
3. Check physical device vs emulator

**Fix**: Grant microphone permission in Settings → Permissions

### Error: "Overlay permission denied" (Overlay Bubble)
**Cause**: Missing SYSTEM_ALERT_WINDOW permission  
**Debug Steps**:
1. Check Android version (requires 8.0+)
2. Look for stack trace in logcat

**Fix**: Settings → Apps → WhisperLog → Permissions → Display over other apps → Allow

### Error: "Firebase initialization timeout"
**Cause**: Firebase setup incomplete or network issue  
**Debug Steps**:
1. Verify Internet connection
2. Check `google-services.json` is in `android/app/`
3. Confirm Firebase project is properly configured

**Fix**:
1. Ensure `.env` has correct Firebase config
2. Check that Google Play Services is installed on device
3. Force firebase reinitialization:
   ```dart
   // In main.dart, add logging
   debugPrint('[Firebase] Initializing...');
   await Firebase.initializeApp(...);
   debugPrint('[Firebase] Initialized successfully');
   ```

### Error: "google_sign_in: NO_ACTIVITY"
**Cause**: Firebase auth flow interrupted  
**Debug Steps**:
1. Check if Chrome browser is installed
2. Verify Google Play Services version

**Fix**:
1. Install Google Play Services (system app)
2. Clear Chrome cache
3. Try signing in again

### Error: "Photos uploaded but they're not in Firestore"
**Cause**: Firestore sync hasn't completed yet  
**Debug Steps**:
1. Wait 5-10 seconds for background sync
2. Check cloud console for `users/{uid}/notes`

**Fix**: Sync is async and may take time. Refresh app to see updates.

---

## Debugging Commands

### View Logs
```bash
# Real-time Dart log output
flutter logs

# Filter for CaptureService logs
flutter logs | grep CaptureService

# Export to file
flutter logs > logs.txt
```

### Inspect SQLite Database (Isar)
```bash
# SSH into Android emulator
adb shell

# Navigate to app data
cd /data/data/com.adarshkumarverma.wishperlog/app_flutter

# List Isar files
ls -la

# Pull database to desktop for inspection
adb pull /data/data/com.adarshkumarverma.wishperlog/app_flutter/
```

### View Firestore (Cloud Console)
1. Go to Firebase Console → Firestore Database
2. Click on `users` collection
3. Verify user document exists with `notes` subcollection
4. Check that new notes appear within 5-10 seconds

### Clear State
```bash
# Clear app data (deletes all local notes)
adb shell pm clear com.adarshkumarverma.wishperlog

# Uninstall and reinstall
flutter clean && flutter run
```

---

## Performance Monitoring

### Startup Time
**Expected**: < 5 seconds from tap to home screen  
**Measurement**: Check logs for `[Main] === STARTUP COMPLETE ===` timestamp

### Note Save Latency
**Expected**: < 50ms local, 2-5s cloud  
**Measurement**: Check `[CaptureService]` log timestamps

### AI Processing Speed
**Expected**: < 10 seconds from save to AI classification complete  
**Measurement**: Check `[AiProcessingService]` logs

### Search Responsiveness
**Expected**: < 200ms for fuzzy search on 1000 notes  
**Measurement**: Time between keystroke and results displayed

---

## Future Improvements

- [ ] Implement pagination for large note collections
- [ ] Add local encryption (Chacha20-Poly1305)
- [ ] Support note sharing between users
- [ ] Add offline Google Workspace sync queue
- [ ] Implement conflict resolution UI for merge conflicts
- [ ] Add comprehensive UI tests (Flutter testing)
- [ ] Performance profiling and optimization
- [ ] Crashlytics integration for production error tracking

---

## Contact & Escalation

For bugs not listed here:
1. Check Flutter logs: `flutter logs | grep -i error`
2. Search GitHub issues
3. Open a new GitHub issue with:
   - Reproduction steps
   - Device info (model, OS version)
   - Full logcat output
   - Screenshots if applicable
