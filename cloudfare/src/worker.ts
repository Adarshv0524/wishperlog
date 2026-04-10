// cloudfare/src/worker.ts  — FULL REPLACEMENT
// Lines: ~180 — full file provided

export interface Env {
  DIGEST_SENT:         KVNamespace;
  TELEGRAM_BOT_TOKEN:  string;
  FIREBASE_PROJECT_ID: string;
  FIREBASE_CLIENT_EMAIL: string;
  FIREBASE_PRIVATE_KEY:  string;
}

// ── Firestore REST helpers ─────────────────────────────────────────────────────

async function getFirestoreToken(env: Env): Promise<string> {
  const header  = btoa(JSON.stringify({ alg: 'RS256', typ: 'JWT' }));
  const now     = Math.floor(Date.now() / 1000);
  const payload = btoa(JSON.stringify({
    iss: env.FIREBASE_CLIENT_EMAIL,
    sub: env.FIREBASE_CLIENT_EMAIL,
    aud: 'https://oauth2.googleapis.com/token',
    iat: now,
    exp: now + 3600,
    scope: 'https://www.googleapis.com/auth/datastore',
  }));
  const unsigned   = `${header}.${payload}`;
  const privateKey = env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n');
  const keyData    = await crypto.subtle.importKey(
    'pkcs8',
    str2ab(atob(privateKey.replace(/-----[^-]+-----/g, '').replace(/\s/g, ''))),
    { name: 'RSASSA-PKCS1-v1_5', hash: 'SHA-256' },
    false, ['sign'],
  );
  const sig = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', keyData, str2ab(unsigned));
  const jwt = `${unsigned}.${btoa(String.fromCharCode(...new Uint8Array(sig)))}`;

  const res  = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
  });
  const data = await res.json<{ access_token: string }>();
  return data.access_token;
}

function str2ab(str: string): ArrayBuffer {
  const buf = new Uint8Array(str.length);
  for (let i = 0; i < str.length; i++) buf[i] = str.charCodeAt(i);
  return buf.buffer;
}

async function firestoreGet(path: string, token: string, projectId: string): Promise<any> {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${path}`;
  const res = await fetch(url, { headers: { Authorization: `Bearer ${token}` } });
  if (!res.ok) return null;
  return res.json();
}

async function firestorePatch(
  path: string, fields: Record<string, any>, token: string, projectId: string,
): Promise<void> {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${path}`;
  const body = { fields: toFirestoreFields(fields) };
  await fetch(url + `?updateMask.fieldPaths=${Object.keys(fields).join(',')}`, {
    method: 'PATCH',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
}

function toFirestoreFields(obj: Record<string, any>): Record<string, any> {
  const out: Record<string, any> = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v === null || v === undefined) out[k] = { nullValue: null };
    else if (typeof v === 'string') out[k] = { stringValue: v };
    else if (typeof v === 'number') out[k] = { integerValue: String(v) };
    else if (typeof v === 'boolean') out[k] = { booleanValue: v };
    else if (Array.isArray(v)) out[k] = { arrayValue: { values: v.map(x => ({ stringValue: String(x) })) } };
    else out[k] = { mapValue: { fields: toFirestoreFields(v) } };
  }
  return out;
}

function extractField(doc: any, ...path: string[]): any {
  let cur = doc?.fields;
  for (const key of path) {
    if (!cur) return undefined;
    cur = cur[key];
    if (cur?.mapValue) cur = cur.mapValue.fields;
    else if (cur?.stringValue !== undefined) return cur.stringValue;
    else if (cur?.arrayValue) return cur.arrayValue.values?.map((v: any) => v.stringValue) ?? [];
    else if (cur?.nullValue !== undefined) return null;
  }
  return cur;
}

// ── Telegram helpers ───────────────────────────────────────────────────────────

async function sendTelegramMessage(
  chatId: string, text: string, token: string,
  replyMarkup?: object,
): Promise<void> {
  const body: Record<string, any> = {
    chat_id: chatId, text, parse_mode: 'HTML',
    disable_web_page_preview: true,
  };
  if (replyMarkup) body.reply_markup = replyMarkup;
  await fetch(`https://api.telegram.org/bot${token}/sendMessage`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });
}

// ── Cron path: dumb dispatcher ────────────────────────────────────────────────

async function runDigestCron(env: Env): Promise<void> {
  const now     = new Date();
  const slotKey = toSlotKey(now);
  const dateKey = toDateKey(now);

  const token = await getFirestoreToken(env);

  // List all user docs
  const listUrl = `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents/users?pageSize=200`;
  const listRes = await fetch(listUrl, { headers: { Authorization: `Bearer ${token}` } });
  if (!listRes.ok) return;
  const listData = await listRes.json<{ documents?: any[] }>();
  const docs = listData.documents ?? [];

  for (const userDoc of docs) {
    try {
      const uid        = userDoc.name?.split('/').pop();
      if (!uid) continue;

      const chatId     = extractField(userDoc, 'telegram_chat_id') as string | null;
      if (!chatId) continue;

      // ── Multi-slot schedule (new) or legacy single slot ──────────────────
      const slotsField = extractField(userDoc, 'digest_slots');
      const slots: string[] = Array.isArray(slotsField) && slotsField.length > 0
        ? slotsField
        : [extractField(userDoc, 'digest_time') as string ?? '09:00'];

      if (!slots.includes(slotKey)) continue;

      // ── KV dedup — one send per (date, slot, uid) per day ───────────────
      const dedupKey = `${dateKey}:${slotKey}:${uid}`;
      const already  = await env.DIGEST_SENT.get(dedupKey);
      if (already) continue;

      // ── Read pre-built message_state — NO re-calculation ─────────────────
      const telegram = extractField(userDoc, 'message_state', 'telegram') as string | null;
      if (!telegram || telegram.trim().length === 0) continue;

      await sendTelegramMessage(chatId, telegram, env.TELEGRAM_BOT_TOKEN);
      await env.DIGEST_SENT.put(dedupKey, '1', { expirationTtl: 93_600 });

      console.log(`[digest] sent to uid=${uid} slot=${slotKey}`);
    } catch (err) {
      console.error('[digest] user loop error:', err);
    }
  }
}

// ── Interactive webhook path (unchanged logic) ─────────────────────────────────

async function handleWebhook(req: Request, env: Env): Promise<Response> {
  const body = await req.json<any>().catch(() => null);
  if (!body) return new Response('bad request', { status: 400 });

  const message  = body.message;
  const chatId   = message?.chat?.id;
  const text     = (message?.text ?? '').trim() as string;

  if (!chatId || !text.startsWith('/')) {
    return new Response('ok');
  }

  const token = await getFirestoreToken(env);

  // Find user by telegram_chat_id
  const queryUrl = `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;
  const queryBody = {
    structuredQuery: {
      from: [{ collectionId: 'users' }],
      where: { fieldFilter: {
        field: { fieldPath: 'telegram_chat_id' },
        op: 'EQUAL',
        value: { stringValue: String(chatId) },
      }},
      limit: 1,
    },
  };
  const qRes  = await fetch(queryUrl, {
    method: 'POST',
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json' },
    body: JSON.stringify(queryBody),
  });
  const qData = await qRes.json<any[]>();
  const userDoc = qData?.[0]?.document;

  if (!userDoc) {
    await sendTelegramMessage(
      String(chatId),
      'Link your WishperLog account first: open the app and connect Telegram.',
      env.TELEGRAM_BOT_TOKEN,
    );
    return new Response('ok');
  }

  const uid         = userDoc.name?.split('/').pop() as string;
  const displayName = extractField(userDoc, 'display_name') as string ?? 'there';

  // For interactive commands we still fetch live notes (real-time UX)
  const notesSnap = await firestoreGet(
    `users/${uid}/notes?pageSize=200`, token, env.FIREBASE_PROJECT_ID,
  );
  const notes = parseNoteDocs(notesSnap?.documents ?? [], uid);

  const parts  = text.split(/\s+/);
  const cmd    = parts[0].slice(1).toLowerCase();
  const args   = parts.slice(1).join(' ');

  switch (cmd) {
    case 'start':
      await sendTelegramMessage(
        String(chatId),
        `Hello ${displayName}! Your WishperLog digest is active. Use /summary, /tasks, /reminders, or /ideas.`,
        env.TELEGRAM_BOT_TOKEN,
      );
      break;
    case 'summary': case 'all':
      await sendTelegramMessage(String(chatId), buildDigest(notes, displayName, 'Summary'), env.TELEGRAM_BOT_TOKEN);
      break;
    case 'tasks': case 'task': case 'todo':
      await sendTelegramMessage(String(chatId), buildDigest(notes.filter(n => n.category === 'tasks'), displayName, 'Tasks'), env.TELEGRAM_BOT_TOKEN);
      break;
    case 'reminders': case 'reminder':
      await sendTelegramMessage(String(chatId), buildDigest(notes.filter(n => n.category === 'reminders'), displayName, 'Reminders'), env.TELEGRAM_BOT_TOKEN);
      break;
    case 'ideas': case 'idea':
      await sendTelegramMessage(String(chatId), buildDigest(notes.filter(n => n.category === 'ideas'), displayName, 'Ideas'), env.TELEGRAM_BOT_TOKEN);
      break;
    default:
      await sendTelegramMessage(
        String(chatId),
        '<b>WishperLog commands</b>\n/summary /tasks /reminders /ideas',
        env.TELEGRAM_BOT_TOKEN,
      );
  }
  return new Response('ok');
}

// ── Note parsing (for interactive commands only) ───────────────────────────────

interface NoteDoc { title: string; category: string; priority: string; body: string; }

function parseNoteDocs(docs: any[], uid: string): NoteDoc[] {
  return docs.map(doc => {
    const f = doc?.fields ?? {};
    const str = (k: string) => f[k]?.stringValue ?? '';
    return { title: str('title'), category: str('category'), priority: str('priority'), body: str('clean_body') };
  });
}

function buildDigest(notes: NoteDoc[], name: string, heading: string): string {
  if (notes.length === 0) return `<b>${heading}</b>\nNo active notes.`;
  const ranked = [...notes].sort((a, b) => priorityRank(a.priority) - priorityRank(b.priority)).slice(0, 5);
  const lines = [`<b>WishperLog ${heading}</b>`, `Hello ${asciiOnly(name)}!`, ''];
  ranked.forEach((n, i) => {
    lines.push(`${i + 1}. [${n.category.toUpperCase()}][${priorityLabel(n.priority)}] ${asciiOnly(n.title)}`);
    if (n.body) lines.push(`   <i>${asciiOnly(n.body).slice(0, 100)}</i>`);
  });
  if (notes.length > ranked.length) lines.push(`\n<i>+${notes.length - ranked.length} more</i>`);
  return lines.join('\n');
}

// ── Main export ───────────────────────────────────────────────────────────────

export default {
  async scheduled(_event: ScheduledEvent, env: Env, _ctx: ExecutionContext): Promise<void> {
    await runDigestCron(env);
  },

  async fetch(req: Request, env: Env): Promise<Response> {
    const url = new URL(req.url);

    // Health / manual trigger endpoint
    if (url.pathname === '/trigger' && req.method === 'GET') {
      await runDigestCron(env);
      return new Response('triggered', { status: 200 });
    }

    // Telegram webhook
    if (url.pathname === '/webhook' && req.method === 'POST') {
      return handleWebhook(req, env);
    }

    return new Response('WishperLog Worker', { status: 200 });
  },
};

// ── Utility ───────────────────────────────────────────────────────────────────

function toSlotKey(d: Date): string {
  return `${pad(d.getUTCHours())}:${pad(d.getUTCMinutes())}`;
}

function toDateKey(d: Date): string {
  return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())}`;
}

function pad(n: number): string { return n.toString().padStart(2, '0'); }

function asciiOnly(v: string): string {
  return (v ?? '').toString().normalize('NFKD').replace(/[^\x00-\x7F]/g, '').replace(/\s+/g, ' ').trim();
}

function priorityRank(p: string): number { return p === 'high' ? 0 : p === 'medium' ? 1 : 2; }

function priorityLabel(p: string): string {
  switch ((p ?? '').toLowerCase()) {
    case 'high': return 'HIGH';
    case 'low':  return 'LOW';
    default:     return 'MED';
  }
}