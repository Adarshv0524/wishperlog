# WhisperLog Setup (Truncated)

This guide only includes the required setup for current app behavior.

## 1) Flutter + Android prereqs
- Install Flutter stable and Android Studio.
- Run:

```bash
flutter doctor
```

Fix any missing Android SDK or platform tools issues.

## 2) Firebase project and app
1. Create Firebase project: wishperlog.
2. Register Android app with your package name.
3. Add SHA-1 for debug keystore.
4. Download google-services.json to android/app/google-services.json.
5. Keep lib/firebase_options.dart in sync with your Firebase project.

## 3) Firestore data model (manual setup required)
Yes, you must do manual setup in Firebase Console for Firestore + rules deployment.

### Required document structure
- users/{uid}
  - uid: string
  - email: string
  - display_name: string
  - google_tokens: map
    - access_token: string|null
    - refresh_token: string|null
    - expiry: string|null
  - telegram_chat_id: string|null
  - digest_time: string (default "09:00")
  - overlay_position: map
    - x: number
    - y: number
  - overlay_visible: boolean
  - fcm_token: string
  - created_at: timestamp

- users/{uid}/notes/{noteId}
  - note_id: string
  - uid: string
  - raw_transcript: string
  - title: string
  - clean_body: string
  - category: string
  - priority: string
  - extracted_date: string|null
  - created_at: string
  - updated_at: string
  - status: string
  - ai_model: string
  - gcal_event_id: string|null
  - gtask_id: string|null
  - source: string
  - synced_at: string|null

## 4) Firestore rules deployment (manual)
Rules file exists at firestore.rules.

Deploy with Firebase CLI:

```bash
firebase login
firebase use <your-project-id>
firebase deploy --only firestore:rules
```

## 5) Gemini API key
Set your Gemini key through the app env mechanism already used in this project.

## 6) Verify Phase 10 critical flows
1. Open Home and long-press in-app mic: mic should glow/grow while speaking.
2. Open overlay bubble and long-press: same hot-state behavior.
3. Save/dictate note and verify it appears under users/{uid}/notes/{noteId}.
4. Tap a folder card (for example Follow-up): header and notes list must match category.
5. Confirm no red error widget appears in Thought Canvas area.
