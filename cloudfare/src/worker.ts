/**
 * WishperLog — Cloudflare Worker: Telegram Digest Dispatcher
 *
 * Changes from original:
 *  ① MINUTE-WISE cron: fires every minute ("* * * * *").
 *     The Worker matches the current HH:MM against each user's
 *     `digest_times_utc` array — no precision is lost.
 *  ② Dedup key is per-user per-day per-minute so the same slot
 *     can never be sent twice even across DST changes.
 *  ③ Fixed Telegram sendMessage call — was missing required params.
 *  ④ Firebase JWT auth now correctly signs with RS256.
 *  ⑤ Structured error logging with per-user isolation.
 *  ⑥ Graceful empty-notes handling (no message sent for 0 notes).
 */

export interface Env {
  TELEGRAM_BOT_TOKEN:    string;   // from @BotFather
  FIREBASE_PROJECT_ID:   string;   // e.g. "wishperlog-prod"
  FIREBASE_CLIENT_EMAIL: string;   // service account email
  FIREBASE_PRIVATE_KEY:  string;   // PEM, newlines as \n
  DIGEST_SENT:           KVNamespace;
}

// ── Entry point ──────────────────────────────────────────────────────────────

export default {
  // Cron fires every minute (wrangler.toml: "* * * * *")
  async scheduled(event: ScheduledEvent, env: Env, ctx: ExecutionContext): Promise<void> {
    ctx.waitUntil(runDigest(event, env));
  },

  // HTTP handler — for manual testing via `wrangler dev` → GET /trigger
  async fetch(req: Request, env: Env): Promise<Response> {
    const url = new URL(req.url);
    if (url.pathname === '/trigger') {
      await runDigest({ scheduledTime: Date.now() } as ScheduledEvent, env);
      return new Response('Triggered OK', { status: 200 });
    }
    return new Response('WishperLog Digest Worker 🟣  v2.0', { status: 200 });
  },
};

// ── Core dispatcher ──────────────────────────────────────────────────────────

async function runDigest(event: ScheduledEvent, env: Env): Promise<void> {
  const now     = new Date(event.scheduledTime ?? Date.now());
  const slotKey = toSlotKey(now);     // "HH:MM" in UTC — minute granularity
  const dateKey = toDateKey(now);     // "YYYY-MM-DD"

  console.log(`[WishperLog] Cron fired — slot=${slotKey}  date=${dateKey}`);

  let token: string;
  try {
    token = await getFirebaseToken(env);
  } catch (err) {
    console.error('[WishperLog] Firebase auth failed:', err);
    return;
  }

  const users = await getUsersForSlot(slotKey, token, env.FIREBASE_PROJECT_ID);
  console.log(`[WishperLog] ${users.length} user(s) matched slot ${slotKey}`);

  for (const user of users) {
    const dedupKey = `${dateKey}:${slotKey}:${user.uid}`;

    try {
      const already = await env.DIGEST_SENT.get(dedupKey);
      if (already) {
        console.log(`[WishperLog] Skip ${user.uid} — already sent at ${slotKey}`);
        continue;
      }

      const notes = await getUserNotes(user.uid, token, env.FIREBASE_PROJECT_ID);
      if (notes.length === 0) {
        console.log(`[WishperLog] No notes for ${user.uid} — skipping message`);
        // Still mark sent so we don't check again this minute.
        await env.DIGEST_SENT.put(dedupKey, '1', { expirationTtl: 93_600 });
        continue;
      }

      const message = buildDigestMessage(notes, user.displayName ?? 'there', now);
      await sendTelegramMessage(user.telegramChatId, message, env.TELEGRAM_BOT_TOKEN);

      // Dedup key lives 26 h to survive DST edge cases.
      await env.DIGEST_SENT.put(dedupKey, '1', { expirationTtl: 93_600 });
      console.log(`[WishperLog] Digest sent to ${user.uid}`);
    } catch (err) {
      console.error(`[WishperLog] Failed for ${user.uid}:`, err);
      // Continue to next user — don't abort the whole run.
    }
  }
}

// ── Firebase auth ─────────────────────────────────────────────────────────────

async function getFirebaseToken(env: Env): Promise<string> {
  const now       = Math.floor(Date.now() / 1000);
  const expiresAt = now + 3600;
  const scope     = 'https://www.googleapis.com/auth/datastore';

  const header  = { alg: 'RS256', typ: 'JWT' };
  const payload = {
    iss:   env.FIREBASE_CLIENT_EMAIL,
    sub:   env.FIREBASE_CLIENT_EMAIL,
    aud:   'https://oauth2.googleapis.com/token',
    iat:   now,
    exp:   expiresAt,
    scope,
  };

  const encode  = (obj: object) =>
    btoa(JSON.stringify(obj)).replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');

  const signingInput = `${encode(header)}.${encode(payload)}`;

  // Import PEM private key for RS256 signing.
  const pemKey  = env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n');
  const keyData = pemToDer(pemKey);
  const cryptoKey = await crypto.subtle.importKey(
    'pkcs8', keyData,
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false, ['sign'],
  );

  const signBuffer = await crypto.subtle.sign(
    'RSASSA-PKCS1-v1_5',
    cryptoKey,
    new TextEncoder().encode(signingInput),
  );

  const signature = btoa(String.fromCharCode(...new Uint8Array(signBuffer)))
    .replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_');

  const jwt = `${signingInput}.${signature}`;

  // Exchange JWT for OAuth2 access token.
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
      assertion:   jwt,
    }),
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`OAuth token exchange failed ${res.status}: ${body}`);
  }

  const json = await res.json() as { access_token: string };
  return json.access_token;
}

/** Strip PEM headers and decode base64 to ArrayBuffer. */
function pemToDer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, '')
    .replace(/-----END PRIVATE KEY-----/, '')
    .replace(/\s/g, '');
  const bin = atob(b64);
  const buf = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) buf[i] = bin.charCodeAt(i);
  return buf.buffer;
}

// ── Firestore queries ─────────────────────────────────────────────────────────

interface DigestUser {
  uid:            string;
  displayName:    string | null;
  telegramChatId: string;
}

interface NoteDoc {
  title:    string;
  category: string;
  priority: string;
  body:     string;
}

async function getUsersForSlot(
  slot: string,
  token: string,
  projectId: string,
): Promise<DigestUser[]> {
  // Firestore REST: query users where digest_times_utc array contains `slot`
  // and telegram_chat_id is non-empty.
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents:runQuery`;

  const body = {
    structuredQuery: {
      from:  [{ collectionId: 'users' }],
      where: {
        compositeFilter: {
          op: 'AND',
          filters: [
            {
              fieldFilter: {
                field:  { fieldPath: 'digest_times_utc' },
                op:     'ARRAY_CONTAINS',
                value:  { stringValue: slot },
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
    },
  };

  const res = await fetch(url, {
    method:  'POST',
    headers: {
      Authorization:  `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });

  if (!res.ok) {
    console.error('[WishperLog] Firestore users query failed:', res.status, await res.text());
    return [];
  }

  const docs = await res.json() as Array<{ document?: { name: string; fields: Record<string, any> } }>;
  return docs
    .filter(d => d.document)
    .map(d => {
      const f   = d.document!.fields;
      const uid = d.document!.name.split('/').pop() ?? '';
      return {
        uid,
        displayName:    f.display_name?.stringValue ?? null,
        telegramChatId: f.telegram_chat_id?.stringValue ?? '',
      };
    })
    .filter(u => u.telegramChatId);
}

async function getUserNotes(
  uid: string,
  token: string,
  projectId: string,
): Promise<NoteDoc[]> {
  const base = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents`;
  const url  = `${base}/users/${uid}/notes?pageSize=20&orderBy=created_at desc`;

  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });

  if (!res.ok) {
    console.error('[WishperLog] getUserNotes failed:', res.status);
    return [];
  }

  const body = await res.json() as { documents?: Array<{ fields: Record<string, any> }> };
  const docs = body.documents ?? [];

  return docs
    .filter(d => d.fields?.status?.stringValue !== 'completed' && d.fields?.is_deleted?.booleanValue !== true)
    .slice(0, 10)
    .map(d => ({
      title:    d.fields.title?.stringValue    ?? 'Untitled',
      category: d.fields.category?.stringValue ?? 'general',
      priority: d.fields.priority?.stringValue ?? 'medium',
      body:     d.fields.clean_body?.stringValue ?? d.fields.raw_transcript?.stringValue ?? '',
    }));
}

// ── Telegram ──────────────────────────────────────────────────────────────────

async function sendTelegramMessage(
  chatId: string,
  text:   string,
  token:  string,
): Promise<void> {
  const url = `https://api.telegram.org/bot${token}/sendMessage`;
  const res = await fetch(url, {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify({
      chat_id:    chatId,
      text,
      parse_mode: 'HTML',
      // Prevent link previews cluttering the chat.
      disable_web_page_preview: true,
    }),
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Telegram sendMessage ${res.status}: ${body}`);
  }
}

// ── Digest message builder ────────────────────────────────────────────────────

const CATEGORY_EMOJI: Record<string, string> = {
  tasks:     '✅',
  reminders: '⏰',
  ideas:     '💡',
  'follow-up': '🔁',
  journal:   '📔',
  general:   '📝',
};

function buildDigestMessage(notes: NoteDoc[], name: string, now: Date): string {
  const timeStr = now.toLocaleTimeString('en-US', {
    hour:   '2-digit',
    minute: '2-digit',
    hour12: true,
    timeZone: 'UTC',
  });

  const lines: string[] = [
    `👋 <b>Hey ${escapeHtml(name)}!</b> Here's your WishperLog digest — ${timeStr} UTC\n`,
  ];

  // Group by category for better readability.
  const byCategory = new Map<string, NoteDoc[]>();
  for (const note of notes) {
    const cat = note.category || 'general';
    if (!byCategory.has(cat)) byCategory.set(cat, []);
    byCategory.get(cat)!.push(note);
  }

  for (const [cat, catNotes] of byCategory) {
    const emoji = CATEGORY_EMOJI[cat] ?? '📝';
    lines.push(`\n${emoji} <b>${capitalise(cat)}</b>`);
    for (const note of catNotes) {
      const priorityBadge = note.priority === 'high' ? ' 🔴' : note.priority === 'medium' ? ' 🟡' : '';
      lines.push(`  • ${escapeHtml(note.title)}${priorityBadge}`);
    }
  }

  lines.push(`\n<i>${notes.length} note${notes.length !== 1 ? 's' : ''} — open WishperLog to manage them.</i>`);
  return lines.join('\n');
}

// ── Utility ───────────────────────────────────────────────────────────────────

/** Returns "HH:MM" in UTC — minute granularity. */
function toSlotKey(d: Date): string {
  return `${pad(d.getUTCHours())}:${pad(d.getUTCMinutes())}`;
}

function toDateKey(d: Date): string {
  return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())}`;
}

function pad(n: number): string { return n.toString().padStart(2, '0'); }

function escapeHtml(s: string): string {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
}

function capitalise(s: string): string {
  return s.charAt(0).toUpperCase() + s.slice(1);
}