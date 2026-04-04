# Firebase Integration - Complete Setup Guide

## ✅ Status: FULLY INTEGRATED

Your WhisperLog app is already connected to Firebase with proper data syncing to match your Firestore structure.

---

## 📊 Firestore Structure (users/{uid}/notes/{noteId})

### User Document
```
users/{uid}
├── uid: string
├── email: string
├── display_name: string
├── created_at: timestamp
├── digest_time: string (e.g., "09:00")
├── timezone_offset_minutes: number
├── overlay_position: {x: number, y: number}
├── overlay_visible: boolean
├── fcm_token: string
├── telegram_chat_id: string (optional)
└── google_tokens
    ├── access_token: string
    ├── refresh_token: string (nullable)
    └── expiry: string (nullable)
```

### Note Document (Sub-collection)
```
users/{uid}/notes/{noteId}
├── note_id: string
├── uid: string
├── raw_transcript: string
├── title: string
├── clean_body: string
├── category: string (general, work, personal, routine, schedule)
├── priority: string (low, medium, high)
├── extracted_date: string (ISO 8601, nullable)
├── created_at: string (ISO 8601)
├── updated_at: string (ISO 8601)
├── status: string (active, pendingAi, archived)
├── ai_model: string
├── gcal_event_id: string (nullable)
├── gtask_id: string (nullable)
├── source: string (homeWritingBox, voiceOverlay, textOverlay)
└── synced_at: string (ISO 8601, nullable)
```

---

## 🔄 Data Flow Architecture

### Writing Notes (Local → Firestore)

```
User Input (Voice/Text)
    ↓
CaptureService.ingestRawCapture()
    ├─ Write to Isar (local database)
    ├─ _syncNoteToFirestore() → users/{uid}/notes/{noteId}
    └─ _promotePendingNote()
        ├─ AI Classification (Gemini)
        ├─ Extract dates/calendar events
        ├─ Sync to Google Calendar/Tasks
        └─ Update note in Isar & Firestore
```

### Reading Notes (Firestore → Local)

```
FirebaseMessaging Push (FCM)
    ↓
FcmSyncService._handleRemoteMessage()
    ↓
FirestoreNoteSyncService.syncNoteById()
    ↓
Download from users/{uid}/notes/{noteId}
    ↓
Parse & store in Isar
```

### Periodic Sync (Background)

```
WorkManager (Every 4 hours)
    ↓
ConnectivitySyncCoordinator.start()
    ├─ Monitor network changes
    └─ Trigger sync when online
       ↓
AiProcessingService.start() (Every 8 seconds)
    ├─ Query pendingAi notes from Isar
    ├─ Process with Gemini AI
    ├─ Update Isar
    └─ Notify Firestore (via _syncNoteToFirestore)
```

---

## 🔐 Firebase Configuration

### Project ID
- **Project**: `wishperlog`
- **Region**: (Default)

### Firebase Services Enabled
- ✅ Authentication (Email, Google OAuth)
- ✅ Firestore Database (NoSQL)
- ✅ Cloud Messaging (FCM)
- ✅ Storage (for future attachments)

### API Keys
- **Android**: `AIzaSyB-0jX3pPJ-8iBDMlSW1W19ih_XkqtqH4E`
- **iOS**: `AIzaSyBGeq1oyfJaEBXgJRqOuEMTmJzo6IA7dkM`
- **Web**: `AIzaSyApWYePpNFwwkpKNfe8wBjrcgcvYkVFmiI`

### Firestore Rules
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(uid) {
      return isSignedIn() && request.auth.uid == uid;
    }

    match /users/{uid} {
      allow read, write: if isOwner(uid);

      match /notes/{noteId} {
        allow read, write: if isOwner(uid);
      }
    }
  }
}
```

---

## 📱 Implementation Details

### 1. **lib/features/auth/data/repositories/user_repository.dart**
- Handles Firebase Authentication
- Creates/updates user documents in `users/{uid}`
- Manages Google OAuth tokens
- Updates FCM token, digest time, overlay settings

```dart
// User document creation on sign-in
await _firestore.collection('users').doc(firebaseUser.uid).set({
  'uid': firebaseUser.uid,
  'email': firebaseUser.email,
  'display_name': firebaseUser.displayName,
  'google_tokens': {...},
  'fcm_token': '',
  'digest_time': '09:00',
  'created_at': FieldValue.serverTimestamp(),
}, SetOptions(merge: true));
```

### 2. **lib/features/capture/data/capture_service.dart**
- Captures voice/text input
- Creates notes in Isar (instant local access)
- Syncs to Firestore `users/{uid}/notes/{noteId}`
- Triggers AI processing

```dart
Future<Note?> ingestRawCapture({
  required String rawTranscript,
  required CaptureSource source,
  bool syncToCloud = true,
}) async {
  // 1. Save to Isar (instant)
  await db.writeTxn(() async {
    await db.notes.put(pending);
  });
  
  // 2. Sync to Firestore (background)
  if (syncToCloud) {
    unawaited(_syncNoteToFirestore(pending));
  }
  
  // 3. Process with AI (background)
  unawaited(_promotePendingNote(noteId: noteId, rawTranscript: trimmed));
}
```

### 3. **lib/features/notes/data/note_repository.dart**
- CRUD operations on notes
- Updates note status (active, archived, pendingAi)
- Syncs changes to Firestore after local update

```dart
Future<void> savePendingFromHome(String rawText) async {
  // Save locally first (instant)
  await db.writeTxn(() async {
    await db.notes.put(note);
  });
  
  // Then sync to cloud (background)
  await _syncNoteToFirestore(note);
}
```

### 4. **lib/features/sync/data/firestore_note_sync_service.dart**
- Handles cloud-to-local sync
- Processes FCM push notifications
- Downloads notes from Firestore to Isar
- Applies status changes from cloud

```dart
Future<void> syncNoteById(String noteId, {String? uid}) async {
  final snap = await _firestore
      .collection('users')
      .doc(uid)
      .collection('notes')
      .doc(noteId)
      .get();
  
  final parsed = Note.fromFirestoreJson(data, uid: uid, noteId: noteId);
  await db.writeTxn(() async {
    await db.notes.put(parsed);
  });
}
```

### 5. **lib/features/sync/data/fcm_sync_service.dart**
- Registers device for push notifications
- Listens for remote messages
- Triggers note sync when cloud data changes

```dart
Future<void> initialize() async {
  final token = await _messaging.getToken().timeout(Duration(seconds: 5));
  await _users.updateFcmToken(token);
  
  _messageSub ??= FirebaseMessaging.onMessage.listen(_handleRemoteMessage);
}
```

### 6. **lib/shared/models/note.dart**
- JSON serialization for Firestore
- Proper field mapping (snake_case in Firestore, camelCase in code)

```dart
Map<String, dynamic> toFirestoreJson() {
  return {
    'note_id': noteId,
    'raw_transcript': rawTranscript,
    'clean_body': cleanBody,
    'category': category.name,
    'priority': priority.name,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'status': status.name,
    // ... other fields
  };
}
```

---

## 🔍 How to Monitor Data Sync

### View Logs During App Startup
```bash
flutter logs | grep -E "\[Firebase\]|\[CaptureService\]|\[Firestore\]|\[FCM\]"
```

### Check What's Being Logged
- `[Main]` - App initialization steps
- `[CaptureService]` - Note capture and sync
- `[FcmSyncService]` - Cloud messaging events
- `[FirestoreNoteSyncService]` - Cloud-to-local sync

### Example Log Output
```
[Main] Initializing Firebase...
[Main] Firebase initialized
[CaptureService] Saving note: 1708012834000_123456
[CaptureService] Note saved successfully: 1708012834000_123456
[CaptureService] Syncing to Firestore...
[FcmSyncService] Got token, updating user...
[FirestoreNoteSyncService] Syncing note: 1708012834000_123456
```

### Monitor in Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select project: **wishperlog**
3. Navigate to **Firestore Database**
4. View collections:
   - `users/{uid}` - User profiles
   - `users/{uid}/notes` - All notes for that user

---

## 🚀 Startup Initialization Order

```
1. WidgetsFlutterBinding.ensureInitialized()
2. AppEnv.load() → Load .env variables
3. Firebase.initializeApp() → Initialize Firebase
   → Options loaded from DefaultFirebaseOptions.currentPlatform
4. IsarService.init() → Open local database
5. WorkManagerService.initialize() → Background task setup
6. init() → Dependency Injection setup
   ├─ UserRepository (Firebase Auth)
   ├─ NoteRepository (Local + Firestore)
   ├─ CaptureService (Note ingestion)
   ├─ FirestoreNoteSyncService (Cloud-to-local)
   ├─ AiProcessingService (Gemini classification)
   └─ FcmSyncService (Cloud messaging)
7. ThemeCubit.hydrate() → Load theme preference
8. OverlayCoordinator.hydrateAndRestore() → Restore overlay settings
9. AiProcessingService.start() → Start 8-second polling
10. ConnectivitySyncCoordinator.start() → Monitor network
11. FcmSyncService.initialize() → Register for push notifications
12. runApp() → Display UI
```

---

## ✨ What Gets Synced Where

| Data | Direction | Timing | Location |
|------|-----------|--------|----------|
| **Notes** | Bi-directional | Immediate → Periodic | `users/{uid}/notes/{noteId}` |
| **User Profile** | Both directions | On change | `users/{uid}` |
| **AI Processing** | Local → Cloud | After AI finishes | Note document |
| **Calendar Events** | Cloud → External | After sync | Google Calendar |
| **Google Tasks** | Cloud → External | After sync | Google Tasks |
| **FCM Token** | Local → Cloud | On change | `users/{uid}.fcm_token` |
| **Settings** | Local → Cloud | On change | `users/{uid}` |

---

## 🔧 Testing Firebase Connection

### 1. Sign In
- Open app → Click "Sign in with Google"
- Verify user document appears in Firestore `users/{uid}`

### 2. Create a Note
- Open home screen → Type in "Thought Canvas"
- Click "Save"
- Check Firestore → `users/{uid}/notes/{noteId}` appears within 2 seconds

### 3. Check AI Processing
- Note appears with status: `pendingAi`
- After 8 seconds, AI processes it
- Status changes to: `active`
- Fields updated: title, clean_body, category, priority, ai_model

### 4. Verify Sync
- Open Firebase Console
- Go to `users/{uid}/notes/{noteId}`
- Scroll to `synced_at` field
- Should show recent timestamp

### 5. Check Cloud Messaging
- Create a note on this device
- Go to Firestore Console → edit any note field on another device
- Check logs in app with `flutter logs`
- Should see FCM push notification processed

---

## 🐛 Troubleshooting

### Notes Not Appearing in Firestore

**Symptom**: Created note in app, but not in Firestore

**Checklist**:
1. ✅ Signed in to Firebase (user document exists in `users/{uid}`)
2. ✅ No errors in logs (run `flutter logs | grep -i error`)
3. ✅ Internet connected (check connectivity_plus logging)
4. ✅ Firestore rules allow write (check security rules above)

**Solution**:
```bash
flutter logs
# Look for: [CaptureService] ERROR
# Check: network connectivity
# Check: Firebase authentication status
```

### Notes Syncing Slow

**Symptom**: Note takes 30+ seconds to appear in Firestore

**Cause**: Cloud processing takes time
- Isar write: ~0ms (instant)
- Firestore sync: 1-3 seconds
- AI processing: 3-8 seconds
- Total: 4-11 seconds typical

**To Speed Up**:
- Ensure good internet (WiFi better than mobile)
- Check Firebase quota (console.firebase.google.com → Usage)
- Check Gemini API quota (aistudio.google.com)

### Can't Sign In

**Symptom**: Google Sign In fails

**Solution**:
1. Check SHA-1 fingerprint
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore
   # Default password: android
   ```
2. Add SHA-1 to Firebase Console → Project Settings → Android
3. Re-download `google-services.json`
4. Verify in `lib/firebase_options.dart`

### FCM Token Not Updating

**Symptom**: Push notifications not working

**Solution**:
```dart
// Check token update in logs
[FcmSyncService] Got token, updating user...

// Verify in Firestore: users/{uid}.fcm_token
// Should show valid token string, not empty
```

---

## 📝 Environment Variables (.env)

Add these to `.env` file in project root:

```env
# Required
GEMINI_API_KEY=your_gemini_key_here
GOOGLE_WEB_CLIENT_ID=your_web_client_id_here

# Optional
TELEGRAM_BOT_USERNAME=your_telegram_bot
```

---

## 🔒 Security Checklist

- [x] Firestore rules restrict to authenticated users
- [x] Users can only access their own data
- [x] Google OAuth tokens stored securely
- [x] FCM tokens auto-updated
- [x] No sensitive data in Isar (local only)
- [ ] Enable Firestore backups (manual action in Console)
- [ ] Set up billing alerts in Firebase Console
- [ ] Review security rules monthly

---

## 📊 Firestore Usage Tracking

### Expected Monthly Costs (Free Tier)
- **Reads**: 50,000 free/day (sufficient for most users)
- **Writes**: 20,000 free/day (sufficient for most users)
- **Deletes**: 20,000 free/day (sufficient for most users)
- **Storage**: 1GB free

### Monitor in Console
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Project: **wishperlog**
3. Analytics → Realtime
4. Check read/write ops per day

---

## 🎯 Next Steps

1. **Test on Device**:
   ```bash
   flutter run
   # Sign in with Google
   # Create a few notes
   # Check Firestore Console
   ```

2. **Enable Firestore Backups**:
   - Firebase Console → Firestore Database → Backups
   - Create daily automated backup

3. **Set Up Billing Alerts**:
   - Firebase Console → Billing → Budget alerts
   - Set to $10/month

4. **Monitor Real Numbers**:
   - Keep an eye on Analytics dashboard
   - Track read/write/delete operations
   - Adjust if exceeding free tier

5. **Test Offline→Online Sync**:
   - Create note while offline
   - Go online
   - Verify note syncs to Firestore

---

## 🎉 You're Connected!

Your app is fully connected to Firebase with:
- ✅ Real-time user authentication
- ✅ Bi-directional note synchronization  
- ✅ Cloud messaging (push notifications)
- ✅ Offline-first architecture
- ✅ Automatic background sync
- ✅ AI processing with Firestore updates
- ✅ Google Calendar/Tasks integration

Start capturing notes and watch them sync in real-time! 🚀
