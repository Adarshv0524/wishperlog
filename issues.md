# WhisperLog: Bug Audit & Known Issues

**Last Updated**: 2026-04-04  
**Status**: Architecture complete. Data pipeline verified. Codebase: 0 compilation errors.

---

## Active Investigation

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
