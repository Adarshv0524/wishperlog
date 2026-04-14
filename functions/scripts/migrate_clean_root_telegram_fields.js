// functions/scripts/migrate_clean_root_telegram_fields.js
//
// One-shot script: strips all legacy telegram_* fields and message_state
// from the root user documents across all users. Run ONCE after deploying
// Patches 1–5. Reads existing digest/latest to confirm data is safe before
// deleting root fields.
//
// Usage:  node functions/scripts/migrate_clean_root_telegram_fields.js

const admin = require('firebase-admin');
const serviceAccount = require('../serviceAccountKey.json'); // adjust path

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

const ROOT_TELEGRAM_FIELDS = [
  'telegram_digest', 'telegram_summary', 'telegram_top', 'telegram_tasks',
  'telegram_reminders', 'telegram_ideas', 'telegram_followup',
  'telegram_journal', 'telegram_general', 'message_state',
];

async function migrate() {
  const usersSnap = await db.collection('users').get();
  console.log(`Found ${usersSnap.size} users`);

  let cleaned = 0;
  let skipped = 0;

  for (const userDoc of usersSnap.docs) {
    const uid  = userDoc.id;
    const data = userDoc.data();

    // Safety: only clean if digest/latest exists (data is safe)
    const latestSnap = await db
      .collection('users').doc(uid)
      .collection('digest').doc('latest').get();

    if (!latestSnap.exists) {
      console.log(`  SKIP  ${uid} — digest/latest not found, skipping cleanup`);
      skipped++;
      continue;
    }

    const fieldsToDelete = {};
    let hasStaleFields = false;
    for (const field of ROOT_TELEGRAM_FIELDS) {
      if (data[field] !== undefined) {
        fieldsToDelete[field] = admin.firestore.FieldValue.delete();
        hasStaleFields = true;
      }
    }

    if (!hasStaleFields) {
      skipped++;
      continue;
    }

    await db.collection('users').doc(uid).update(fieldsToDelete);
    console.log(`  CLEAN ${uid} — removed ${Object.keys(fieldsToDelete).length} stale fields`);
    cleaned++;
  }

  console.log(`\nDone: ${cleaned} cleaned, ${skipped} skipped`);
  process.exit(0);
}

migrate().catch(e => { console.error(e); process.exit(1); });