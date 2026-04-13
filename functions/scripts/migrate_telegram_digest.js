const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

function detectProjectId() {
  const envProjectId =
    process.env.FIREBASE_PROJECT_ID ||
    process.env.GCLOUD_PROJECT ||
    process.env.GOOGLE_CLOUD_PROJECT ||
    process.env.GCP_PROJECT;

  if (envProjectId) {
    return envProjectId.trim();
  }

  try {
    const firebaseJsonPath = path.resolve(__dirname, '..', '..', 'firebase.json');
    const raw = fs.readFileSync(firebaseJsonPath, 'utf8');
    const parsed = JSON.parse(raw);

    const inferred =
      parsed?.flutter?.platforms?.dart?.['lib/firebase_options.dart']?.projectId ||
      parsed?.flutter?.platforms?.android?.default?.projectId ||
      parsed?.functions?.projectId ||
      '';

    return String(inferred).trim();
  } catch (_) {
    return '';
  }
}

function initAdmin() {
  if (admin.apps.length > 0) {
    return;
  }

  const projectId = detectProjectId();
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY;

  if (projectId && clientEmail && privateKey) {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId,
        clientEmail,
        privateKey: privateKey.replace(/\\n/g, '\n'),
      }),
      projectId,
    });
    return;
  }

  admin.initializeApp(projectId ? { projectId } : undefined);
}

function asTrimmedString(value) {
  if (value === null || value === undefined) return '';
  return String(value).trim();
}

function asStringArray(value) {
  if (!Array.isArray(value)) return [];
  return value.map((item) => asTrimmedString(item)).filter(Boolean);
}

function pickMessageStatePayload(state) {
  const payload = {};
  const keys = [
    'telegram',
    'telegram_digest',
    'telegram_summary',
    'telegram_top',
    'telegram_tasks',
    'telegram_reminders',
    'telegram_ideas',
    'telegram_followup',
    'telegram_journal',
    'telegram_general',
  ];

  for (const key of keys) {
    const value = asTrimmedString(state?.[key]);
    if (value) {
      payload[key] = value;
    }
  }

  return payload;
}

async function migrateUserDoc(db, docSnap, { dryRun }) {
  const data = docSnap.data() || {};
  const uid = docSnap.id;
  const rootRef = docSnap.ref;
  const configRef = rootRef.collection('digest').doc('config');
  const latestRef = rootRef.collection('digest').doc('latest');

  const rootDeletes = {};
  for (const key of Object.keys(data)) {
    if (key.startsWith('telegram_')) {
      rootDeletes[key] = admin.firestore.FieldValue.delete();
    }
  }
  if (Object.prototype.hasOwnProperty.call(data, 'message_state')) {
    rootDeletes.message_state = admin.firestore.FieldValue.delete();
  }

  const configPayload = {
    uid,
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  };

  const chatId = asTrimmedString(data.telegram_chat_id || data.chat_id);
  if (chatId) {
    configPayload.telegram_chat_id = chatId;
  }

  const displayName = asTrimmedString(data.display_name);
  if (displayName) {
    configPayload.display_name = displayName;
  }

  const digestTimes = asStringArray(data.digest_times);
  if (digestTimes.length > 0) {
    configPayload.digest_times = digestTimes;
  } else {
    const singleDigestTime = asTrimmedString(data.digest_time);
    if (singleDigestTime) {
      configPayload.digest_times = [singleDigestTime];
    }
  }

  const digestTimesUtc = asStringArray(data.digest_times_utc);
  if (digestTimesUtc.length > 0) {
    configPayload.digest_times_utc = digestTimesUtc;
  }

  if (data.timezone_offset_minutes !== undefined && data.timezone_offset_minutes !== null) {
    configPayload.timezone_offset_minutes = Number(data.timezone_offset_minutes) || 0;
  }

  const messageStatePayload = pickMessageStatePayload(data.message_state);
  const latestPayload = Object.keys(messageStatePayload).length > 0
    ? {
        ...messageStatePayload,
        computed_at: admin.firestore.FieldValue.serverTimestamp(),
      }
    : null;

  const actions = [];
  if (Object.keys(configPayload).length > 2) {
    actions.push(`config fields: ${Object.keys(configPayload).join(', ')}`);
  }
  if (latestPayload) {
    actions.push(`latest fields: ${Object.keys(latestPayload).join(', ')}`);
  }
  if (Object.keys(rootDeletes).length > 0) {
    actions.push(`delete root fields: ${Object.keys(rootDeletes).join(', ')}`);
  }

  if (actions.length === 0) {
    return { uid, changed: false };
  }

  if (dryRun) {
    console.log(`[dry-run] ${uid} -> ${actions.join(' | ')}`);
    return { uid, changed: true };
  }

  const batch = db.batch();
  batch.set(configRef, configPayload, { merge: true });
  if (latestPayload) {
    batch.set(latestRef, latestPayload, { merge: true });
  }
  if (Object.keys(rootDeletes).length > 0) {
    batch.set(rootRef, rootDeletes, { merge: true });
  }

  await batch.commit();
  console.log(`[migrated] ${uid} -> ${actions.join(' | ')}`);
  return { uid, changed: true };
}

async function main() {
  initAdmin();
  const db = admin.firestore();
  const dryRun = process.env.DRY_RUN !== '0' && process.env.APPLY !== '1';

  console.log(dryRun
    ? 'Running in dry-run mode. Set APPLY=1 to write changes.'
    : 'Running in apply mode. Changes will be written to Firestore.');

  const snapshot = await db.collection('users').get();
  let scanned = 0;
  let changed = 0;

  for (const docSnap of snapshot.docs) {
    scanned += 1;
    const result = await migrateUserDoc(db, docSnap, { dryRun });
    if (result.changed) {
      changed += 1;
    }
  }

  console.log(`Done. scanned=${scanned} changed=${changed} mode=${dryRun ? 'dry-run' : 'apply'}`);
}

main().catch((error) => {
  console.error('Migration failed:', error);
  process.exitCode = 1;
});