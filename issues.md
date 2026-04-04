# WhisperLog: Bug Audit & Known Issues

**Last Updated**: 2026-04-04  
**Status**: Architecture complete. Data pipeline verified. Codebase: 0 compilation errors.

---

## Active Investigation

No open issues currently under active investigation.

---

## Resolved Issues

### ✅ Missing Telegram Daily Digest WorkManager Worker (FIXED - Phase 6)
**Severity**: High
**Resolution**: Added client-side daily digest worker with local-time gate, retry, and idempotency.

**Changes**:
- `lib/core/background/work_manager_service.dart`: Added `telegram_daily_digest` periodic task, digest generation from local active notes, Telegram API send, retry, and same-day guard.
- `lib/main.dart`: Registered Telegram digest worker at startup.
- `lib/features/settings/presentation/screens/settings_screen.dart`: Re-registered digest worker when digest time changes.
- `lib/core/config/app_env.dart`: Added `telegramBotToken` getter.

**Verification**: Worker is registered on startup and executes digest branch in callback dispatcher.

---

### ✅ "Unable to save note" Error (Intermittent) (FIXED - Phase 6)
**Severity**: Medium
**Resolution**: Made local save authoritative and cloud sync best-effort.

**Changes**:
- `lib/features/capture/data/note_save_service.dart`: Added explicit SQLite open check before upsert and kept retry loop.
- `lib/features/capture/data/note_save_service.dart`: Stopped rethrowing cloud sync exceptions so local saves do not fail when network/Firebase is flaky.

**Verification**: Local note persistence path no longer surfaces cloud-sync failures as save failures.

---

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
   - Notes stored unencrypted in SQLite
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
2. Verify SQLite database is initialized properly
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

### Inspect SQLite Database
```bash
# SSH into Android emulator
adb shell

# Navigate to app databases
cd /data/data/com.adarshkumarverma.wishperlog/databases

# List SQLite files
ls -la

# Pull database to desktop for inspection
adb pull /data/data/com.adarshkumarverma.wishperlog/databases/wishperlog_notes.db
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
**Expected**: < 200ms for semantic-pragmatic ranked search on 1000 notes  
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
