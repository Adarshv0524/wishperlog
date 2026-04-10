# Cloudfare Reminder Fix Guide

This guide fixes the Telegram reminder sending path in the Cloudflare Worker.

## What is broken

Right now, Telegram reminders are not sent by the app itself. The reminder send path lives in the Cloudflare Worker at `cloudfare/src/worker.ts`, and that worker needs to be updated and redeployed.

## What this fix does

- Keeps the existing digest sending flow intact.
- Adds a dedicated reminder dispatch pass.
- Sends reminder notes whose `category` is `reminders` and whose `extracted_date` matches the current UTC minute.
- Uses the saved `telegram_chat_id` for each user.

## Click-by-click fix

### 1. Open the worker file

- In VS Code, open the workspace `wishperlog`.
- In the Explorer, open `cloudfare`.
- Open `src`.
- Open `worker.ts`.

### 2. Find the cron entry point

- Scroll near the top until you find `runDigest(...)`.
- This is the function that runs every minute.

### 3. Add reminder dispatch after the digest loop

- After the loop that sends the daily digest, add a second call for reminders.
- The worker should:
  - load Telegram-linked users,
  - load due reminder notes,
  - match them by `uid`,
  - send a reminder message to the user’s Telegram chat,
  - store a dedup key so the same reminder is not sent twice in the same minute.

### 4. Check the Firestore note fields

- Reminder notes must have:
  - `status = active`
  - `category = reminders`
  - `extracted_date` set
  - `telegram_chat_id` saved on the user document
- In Firestore, make sure reminder notes are being written with those fields.

### 5. Save the file

- Use `Ctrl+S` or `Cmd+S`.

### 6. Validate the worker code locally

- If you have a worker build setup, run the TypeScript build or the Wrangler validation command.
- If you use VS Code terminal, run the worker checks from the `cloudfare` folder.

### 7. Deploy the worker

- Open a terminal in the `cloudfare` directory.
- Run the Wrangler deploy command for your worker.
- Wait for deployment to finish successfully.

### 8. Verify in Cloudflare dashboard

- Open the Cloudflare dashboard.
- Select your worker.
- Open the logs or observability view.
- Confirm the worker is running every minute.
- Confirm a reminder note triggers a Telegram send.

### 9. Verify in Telegram

- Open Telegram.
- Find the connected bot.
- Confirm the reminder arrives when the note is due.

## If reminders still do not send

Check these in order:

1. The user has a non-empty `telegram_chat_id`.
2. The reminder note has `category = reminders`.
3. The reminder note has a valid `extracted_date`.
4. The worker deployment is the latest version.
5. The worker logs show the reminder send pass executing.

## Best quick test

- Create one note with category `reminders`.
- Set its extracted date to the current UTC minute.
- Save it for a user with a Telegram chat ID.
- Trigger the worker manually if your setup supports a `/trigger` test endpoint.

## Expected result

- The digest flow continues to work.
- A due reminder note sends one Telegram message.
- The same reminder does not repeat within the same minute.

## Files involved

- `cloudfare/src/worker.ts`
- Firestore `users` collection
- Firestore `notes` collection
