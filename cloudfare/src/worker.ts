/**
 * WishperLog — Cloudflare Worker: Telegram Digest Dispatcher
 *
 * Runs every 15 minutes via Cron Trigger.
 * For each firing:
 *   1. Determines the current UTC "HH:MM" slot (rounded to 15 min).
 *   2. Queries Firestore for users whose `digest_times_utc` array contains
 *      that slot AND have a telegram_chat_id set.
 *   3. For each matching user, fetches their top-priority notes.
 *   4. Sends a formatted Telegram message.
 *   5. Stores a dedup key in KV so the same slot is never sent twice per day.
 */

export interface Env {
  TELEGRAM_BOT_TOKEN:   string;
  FIREBASE_PROJECT_ID:  string;
  FIREBASE_CLIENT_EMAIL: string;
  FIREBASE_PRIVATE_KEY: string;
  DIGEST_SENT:          KVNamespace;
}

// ── Entry point ──────────────────────────────────────────────────────────────

export default {
  async scheduled(
    event: ScheduledEvent,
    env: Env,
    ctx: ExecutionContext,
  ): Promise<void> {
    ctx.waitUntil(runDigest(event, env));
  },

  // HTTP handler — useful for testing via `wrangler dev`
  async fetch(req: Request, env: Env): Promise<Response> {
    const url = new URL(req.url);
    if (url.pathname === '/trigger') {
      await runDigest({ scheduledTime: Date.now() } as ScheduledEvent, env);
      return new Response('Triggered OK');
    }
    return new Response('WishperLog Digest Worker 🟣', { status: 200 });
  },
};

// ── Core dispatcher ──────────────────────────────────────────────────────────

async function runDigest(event: ScheduledEvent, env: Env): Promise<void> {
  const now      = new Date(event.scheduledTime ?? Date.now());
  const slotKey  = toSlotKey(now);          // e.g. "09:15"
  const dateKey  = toDateKey(now);           // e.g. "2025-01-24"
  const dedupKey = `${dateKey}:${slotKey}`; // KV dedup key

  console.log(`[WishperLog] Firing for slot ${slotKey} on ${dateKey}`);

  // Get a Firebase access token via Service Account JWT
  const token = await getFirebaseToken(env);

  // Query users who want a digest at this slot
  const users = await getUsersForSlot(slotKey, token, env.FIREBASE_PROJECT_ID);
  console.log(`[WishperLog] Found ${users.length} user(s) for slot ${slotKey}`);

  for (const user of users) {
    const userDedupKey = `${dedupKey}:${user.uid}`;

    // Skip if already sent this slot to this user today
    const alreadySent = await env.DIGEST_SENT.get(userDedupKey);
    if (alreadySent) {
      console.log(`[WishperLog] Skipping ${user.uid} — already sent`);
      continue;
    }

    try {
      const notes  = await getUserNotes(user.uid, token, env.FIREBASE_PROJECT_ID);
      const digest = buildDigestMessage(notes, user.displayName ?? 'there', slotKey);
      await sendTelegramMessage(user.telegramChatId, digest, env.TELEGRAM_BOT_TOKEN);

      // Mark as sent — expires after 26 hours to survive DST edge cases
      await env.DIGEST_SENT.put(userDedupKey, '1', { expirationTtl: 93_600 });
      console.log(`[WishperLog] Sent digest to ${user.uid}`);
    } catch (err) {
      console.error(`[WishperLog] Error sending to ${user.uid}:`, err);
    }
  }
}

// ── Firebase helpers ─────────────────────────────────────────────────────────

interface FirestoreUser {
  uid:             string;
  displayName?:    string;
  telegramChatId:  string;
}

interface FirestoreNote {
  title:          string;
  category:       string;
  priority:       string;
  clean_body:     string;
  extracted_date: string | null;
}

async function getFirebaseToken(env: Env): Promise<string> {
  const now          = Math.floor(Date.now() / 1000);
  const header       = { alg: 'RS256', typ: 'JWT' };
  const payload      = {
    iss:   env.FIREBASE_CLIENT_EMAIL,
    sub:   env.FIREBASE_CLIENT_EMAIL,
    aud:   'https://oauth2.googleapis.com/token',
    iat:   now,
    exp:   now + 3600,
    scope: 'https://www.googleapis.com/auth/datastore',
  };

  const privateKey = env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n');
  const jwt        = await signJwt(header, payload, privateKey);

  const resp = await fetch('https://oauth2.googleapis.com/token', {
    method:  'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body:    `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });

  if (!resp.ok) throw new Error(`Token error: ${await resp.text()}`);
  const data = await resp.json<{ access_token: string }>();
  return data.access_token;
}

async function getUsersForSlot(
  slot: string, token: string, project: string,
): Promise<FirestoreUser[]> {
  // Firestore REST: query users collection where digest_times_utc array contains the slot
  const url = `https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/documents:runQuery`;

  const body = {
    structuredQuery: {
      from:  [{ collectionId: 'users' }],
      where: {
        compositeFilter: {
          op: 'AND',
          filters: [
            {
              fieldFilter: {
                field: { fieldPath: 'digest_times_utc' },
                op:    'ARRAY_CONTAINS',
                value: { stringValue: slot },
              },
            },
            {
              fieldFilter: {
                field: { fieldPath: 'telegram_chat_id' },
                op:    'NOT_EQUAL',
                value: { stringValue: '' },
              },
            },
          ],
        },
      },
      limit: 500,
    },
  };

  const resp = await fetch(url, {
    method:  'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body:    JSON.stringify(body),
  });

  if (!resp.ok) throw new Error(`Firestore query error: ${await resp.text()}`);
  const rows = await resp.json<any[]>();

  return rows
    .filter((r: any) => r.document)
    .map((r: any) => {
      const fields = r.document.fields ?? {};
      const uid    = r.document.name.split('/').pop() as string;
      return {
        uid,
        displayName:   fields.display_name?.stringValue ?? '',
        telegramChatId: fields.telegram_chat_id?.stringValue ?? '',
      };
    })
    .filter(u => u.telegramChatId.length > 0);
}

async function getUserNotes(
  uid: string, token: string, project: string,
): Promise<FirestoreNote[]> {
  const url = `https://firestore.googleapis.com/v1/projects/${project}/databases/(default)/documents:runQuery`;

  const body = {
    structuredQuery: {
      from:  [{ collectionId: 'notes', allDescendants: false }],
      where: {
        compositeFilter: {
          op: 'AND',
          filters: [
            {
              fieldFilter: {
                field: { fieldPath: 'uid' },
                op:    'EQUAL',
                value: { stringValue: uid },
              },
            },
            {
              fieldFilter: {
                field: { fieldPath: 'status' },
                op:    'EQUAL',
                value: { stringValue: 'active' },
              },
            },
          ],
        },
      },
      orderBy: [{ field: { fieldPath: 'priority' }, direction: 'ASCENDING' }],
      limit:   20,
    },
    parent: `projects/${project}/databases/(default)/documents/users/${uid}`,
  };

  const resp = await fetch(url, {
    method:  'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body:    JSON.stringify(body),
  });

  if (!resp.ok) {
    console.error(`[WishperLog] Notes fetch error for ${uid}: ${await resp.text()}`);
    return [];
  }

  const rows = await resp.json<any[]>();
  return rows
    .filter((r: any) => r.document)
    .map((r: any) => {
      const f = r.document.fields ?? {};
      return {
        title:          f.title?.stringValue          ?? 'Untitled',
        category:       f.category?.stringValue       ?? 'general',
        priority:       f.priority?.stringValue       ?? 'medium',
        clean_body:     f.clean_body?.stringValue     ?? '',
        extracted_date: f.extracted_date?.stringValue ?? null,
      };
    });
}

// ── Message builder ──────────────────────────────────────────────────────────

const CATEGORY_EMOJI: Record<string, string> = {
  tasks:      '✅',
  reminders:  '🔔',
  ideas:      '💡',
  'follow-up': '🔁',
  journal:    '📓',
  general:    '📌',
};

const PRIORITY_LABEL: Record<string, string> = {
  high:   '🔴 High',
  medium: '🟡 Medium',
  low:    '🟢 Low',
};

function buildDigestMessage(
  notes: FirestoreNote[],
  name: string,
  slot: string,
): string {
  const [h, m]   = slot.split(':').map(Number);
  const timeLabel = new Date(Date.UTC(2000, 0, 1, h, m))
    .toLocaleTimeString('en-US', { hour: '2-digit', minute: '2-digit', timeZone: 'UTC' });

  if (notes.length === 0) {
    return `🟣 *WishperLog — ${timeLabel} Digest*\n\nHey ${name}! You're all caught up — no active notes right now. Keep capturing! 🎙️`;
  }

  const high   = notes.filter(n => n.priority === 'high');
  const medium = notes.filter(n => n.priority === 'medium');
  const low    = notes.filter(n => n.priority === 'low');

  let msg = `🟣 *WishperLog — ${timeLabel} Digest*\n`;
  msg    += `Hey ${escMd(name)}! Here's your snapshot:\n\n`;

  const renderGroup = (label: string, items: FirestoreNote[]) => {
    if (items.length === 0) return '';
    let out = `*${label}*\n`;
    for (const n of items.slice(0, 5)) {
      const cat  = CATEGORY_EMOJI[n.category] ?? '📌';
      const date = n.extracted_date ? ` _(due ${n.extracted_date})_` : '';
      out += `${cat} ${escMd(n.title)}${date}\n`;
    }
    return out + '\n';
  };

  msg += renderGroup('🔴 High Priority', high);
  msg += renderGroup('🟡 Medium Priority', medium);
  msg += renderGroup('🟢 Low Priority', low);

  msg += `_${notes.length} active note${notes.length !== 1 ? 's' : ''} total_\n`;
  msg += '\n💡 Open WishperLog to act on these.';
  return msg;
}

function escMd(s: string): string {
  return s.replace(/[_*[\]()~`>#+=|{}.!-]/g, '\\$&');
}

// ── Telegram helper ──────────────────────────────────────────────────────────

async function sendTelegramMessage(
  chatId: string, text: string, botToken: string,
): Promise<void> {
  const url  = `https://api.telegram.org/bot${botToken}/sendMessage`;
  const resp = await fetch(url, {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify({
      chat_id:    chatId,
      text,
      parse_mode: 'MarkdownV2',
      disable_web_page_preview: true,
    }),
  });
  if (!resp.ok) throw new Error(`Telegram error: ${await resp.text()}`);
}

// ── JWT helpers (Web Crypto API — available in Workers) ──────────────────────

async function signJwt(
  header: object, payload: object, pemKey: string,
): Promise<string> {
  const enc     = new TextEncoder();
  const b64url  = (buf: ArrayBuffer) =>
    btoa(String.fromCharCode(...new Uint8Array(buf)))
      .replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');

  const headerB64  = btoa(JSON.stringify(header))
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
  const payloadB64 = btoa(JSON.stringify(payload))
    .replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
  const unsigned   = `${headerB64}.${payloadB64}`;

  // Import PEM private key
  const pemBody  = pemKey
    .replace('-----BEGIN PRIVATE KEY-----', '')
    .replace('-----END PRIVATE KEY-----', '')
    .replace(/\s/g, '');
  const der      = Uint8Array.from(atob(pemBody), c => c.charCodeAt(0));
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8', der,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false, ['sign'],
  );

  const sig = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    enc.encode(unsigned),
  );

  return `${unsigned}.${b64url(sig)}`;
}

// ── Utility helpers ──────────────────────────────────────────────────────────

function toSlotKey(d: Date): string {
  const h = d.getUTCHours();
  const m = Math.floor(d.getUTCMinutes() / 15) * 15;
  return `${pad(h)}:${pad(m)}`;
}

function toDateKey(d: Date): string {
  return d.toISOString().slice(0, 10);
}

function pad(n: number): string {
  return n.toString().padStart(2, '0');
}