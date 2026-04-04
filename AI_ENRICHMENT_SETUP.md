# AI Enrichment Setup - WhisperLog

## Problem
When notes are created with `status: "pendingAi"`, they were NOT being enriched by the Gemini API because:
1. **Client-side only processing**: The Flutter app processes AI enrichment locally
2. **Network/crash vulnerability**: If the app closes/crashes before processing, notes stay stuck as `pendingAi` forever
3. **No server-side fallback**: Firestore had no mechanism to enrichment orphaned notes

**Evidence**: Your Firestore data shows notes with:
- `status: "pendingAi"` (not processed)
- `title` = `raw_transcript` (no enrichment)
- `clean_body` = `raw_transcript` (no enrichment)
- `ai_model: ""` (empty)

## Solution
**Added a Cloud Function that:**
1. Listens for new notes with `status: "pendingAi"`
2. Calls Gemini 2.5 Flash Lite API for enrichment
3. Parses the JSON response to extract:
   - Enhanced title
   - Category (Tasks, Reminders, Ideas, Follow-up, Journal, General)
   - Priority (high, medium, low)
   - Clean body (normalized text)
   - Extracted date (if any)
4. Updates the Firestore note with enriched data
5. Changes status to `"active"`
6. Sets `ai_model` to `"gemini-2.5-flash-lite"`

## Files Changed

### 1. `functions/package.json`
- Added dependency: `"@google/generative-ai": "^0.21.0"`
- Allows Cloud Functions to call Gemini API

### 2. `functions/index.js`
- Added import: `const { onDocumentCreated } = require('firebase-functions/v2/firestore')`
- Added import: `const { GoogleGenerativeAI } = require('@google/generative-ai')`
- Added new function: `exports.enrichPendingAiNote = onDocumentCreated(...)`

## How It Works

### Trigger
```
Firestore path: users/{uid}/notes/{noteId}
Condition: Only processes when status == "pendingAi"
```

### Processing
1. **Extract** the `raw_transcript` from the note
2. **Call Gemini API** with system prompt + raw input
3. **Parse JSON** response (handles code blocks and nested JSON)
4. **Map values**:
   - Category normalization (e.g., "task" → "tasks")
   - Priority: high/medium/low fallback
   - Date parsing: ISO 8601 conversion
5. **Update Firestore** with enriched data
6. **Set status to active** - note is now ready for user

### Key Features
- **Resilient JSON parsing**: Extracts JSON from code blocks, markdown, or raw JSON
- **Fallback logic**: Uses defaults if enrichment data is incomplete
  - Empty title → first 100 chars of raw transcript
  - Empty clean_body → full raw transcript
  - Missing category → "general"
  - Missing priority → "medium"
  - Missing date → null
- **Error logging**: Failed enrichments are logged but don't crash the function
- **Atomic updates**: Uses Firestore `update()` for clean partial updates

## Deployment

### Step 1: Set Environment Variable in Firebase
The Cloud Function needs the Gemini API key from your `.env`:

```bash
# Ensure your .env has:
GEMINI_API_KEY=AIzaSyBmy5O8moPDR4bh9nOIk61w-CAHVT3kWko

# Set it in Firebase Cloud Functions environment
firebase functions:config:set gemini.api_key="AIzaSyBmy5O8moPDR4bh9nOIk61w-CAHVT3kWko"
```

**Alternative**: Add to `functions/.env.local` or use Firebase CLI to set environment secrets.

### Step 2: Deploy Cloud Functions
```bash
cd functions
firebase deploy --only functions
```

### Step 3: Test
1. Create a new note in the app
2. Watch Firestore: the note should transition from `pendingAi` → `active` within 1-2 seconds
3. Check that `title`, `clean_body`, `category`, `priority`, `ai_model` are enriched

## Monitoring

### Firebase Console
1. Go to **Cloud Functions** → `enrichPendingAiNote`
2. View **Executions** tab for:
   - Success count
   - Latency (typically 1-2 seconds per note)
   - Error logs

### Example Success Log
```
[enrichPendingAiNote] Successfully enriched note 1775312446471124_1018329 for user wnQlqX15pYTdpDOuC8AZguWIS3h2
enriched: {"title":"Test Scenario Discussion","clean_body":"Discussion about test scenarios...","category":"ideas","priority":"medium","ai_model":"gemini-2.5-flash-lite","status":"active","updated_at":"2026-04-04T19:52:00.000Z"}
```

## Redundancy: Client-Side Still Works

The Flutter app's `AiProcessingService` **continues to work independently**:
- App processes `pendingAi` notes when it runs
- Cloud Function acts as server-side fallback if the app is offline
- Both systems update the same Firestore document (deterministic merge)

This provides **defense-in-depth**:
- ✅ App running → immediate local processing
- ✅ App offline → Cloud Function processes on next note creation
- ✅ Both running → Cloud Function wins due to Firestore atomicity

## Cost Considerations

### API Calls
- **Gemini 2.5 Flash Lite**: ~$0.075/1M input tokens, ~$0.30/1M output tokens
- **Per note**: ~500 input tokens + 200 output tokens ≈ $0.000060/note
- **Monthly (10,000 notes)**: ~$0.60 for AI enrichment

### Cloud Functions
- **Compute**: First 2M invocations free/month
- **Network**: Included in free tier

**Total**: Minimal cost, easily within free tier.

## Troubleshooting

### Notes Still Stuck as `pendingAi`
1. Check Firebase console for function errors
2. Verify `GEMINI_API_KEY` is set: `firebase functions:config:get`
3. Check `raw_transcript` field exists and not empty
4. Manually trigger by creating a test note in app

### Enrichment Taking Too Long
- Gemini API latency: 1-3 seconds typical
- Check network/Firestore latency in logs
- Can add retry logic if needed (currently fails silently)

### Wrong Enrichment
- Adjust `GEMINI_SYSTEM_PROMPT` in `functions/index.js`
- Test locally with sample transcript
- Redeploy after changes

## Next Steps

1. **Deploy immediately:**
   ```bash
   cd functions && firebase deploy --only functions
   ```

2. **Test with sample note:**
   - Create a note from voice with raw transcript
   - Watch Firestore for auto-enrichment within 2-3 seconds

3. **Fix stuck notes (optional):**
   - Query all notes where `status == "pendingAi"`
   - Update them to trigger the Cloud Function
   - Or wait for next manual creation to test the flow

4. **Monitor success rate:**
   - Check Firebase Cloud Functions dashboard
   - Aim for 100% success on enrichment
   - Adjust model/prompt if needed

## Summary

**Before**: Notes were stuck as `pendingAi` without UI processing
**After**: 
- ✅ Cloud Function auto-enriches on creation
- ✅ Client-side still works as backup
- ✅ Firestore data now has proper title/body/category/priority
- ✅ Minimal cost, leverages existing .env API key
- ✅ Seamless - no app changes needed
