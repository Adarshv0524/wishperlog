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
    if (url.pathname === '/telegram-webhook' && req.method === 'POST') {
      await handleTelegramWebhook(req, env, url);
      return new Response('OK', { status: 200 });
    }
    if (url.pathname === '/configure-telegram-webhook') {
      const webhookUrl = `${url.origin}/telegram-webhook`;
      const result = await configureTelegramWebhook(env, webhookUrl);
      return new Response(result, { status: 200, headers: { 'Content-Type': 'text/plain; charset=utf-8' } });
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

      const message = buildDigestMessage(notes, user.displayName ?? 'there', now, 'WishperLog daily summary');
      try {
        await sendTelegramMessage(user.telegramChatId, message, env.TELEGRAM_BOT_TOKEN);
      } catch (messageError) {
        if (isTelegramChatNotFound(messageError)) {
          console.error(`[WishperLog] Invalid Telegram chat for ${user.uid} — clearing saved chat ID`);
          await clearTelegramChatId(user.uid, token, env.FIREBASE_PROJECT_ID);
        }
        throw messageError;
      }

      // Dedup key lives 26 h to survive DST edge cases.
      await env.DIGEST_SENT.put(dedupKey, '1', { expirationTtl: 93_600 });
      console.log(`[WishperLog] Digest sent to ${user.uid}`);
    } catch (err) {
      console.error(`[WishperLog] Failed for ${user.uid}:`, err);
      // Continue to next user — don't abort the whole run.
    }
  }

  await sendDueTelegramReminders(now, dateKey, slotKey, token, env);
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
  digestTimesUtc: string[];
  digestTimes: string[];
  digestTime: string;
  timezoneOffsetMinutes: number;
}

interface NoteDoc {
  title:    string;
  category: string;
  priority: string;
  body:     string;
}

interface ReminderDoc {
  noteId: string;
  uid: string;
  title: string;
  body: string;
  category: string;
  priority: string;
  extractedAt: Date;
}

async function getUsersForSlot(
  slot: string,
  token: string,
  projectId: string,
): Promise<DigestUser[]> {
  const users = await getTelegramUsers(token, projectId);
  console.log(`[WishperLog] Slot ${slot} candidate users=${users.length}`);
  return users.filter((user) => matchesDigestSlot(user, slot));
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
    .filter(d => {
      const status = d.fields?.status?.stringValue ?? 'active';
      return status === 'active' && d.fields?.is_deleted?.booleanValue !== true;
    })
    .slice(0, 10)
    .map(d => ({
      title:    d.fields.title?.stringValue    ?? 'Untitled',
      category: d.fields.category?.stringValue ?? 'general',
      priority: d.fields.priority?.stringValue ?? 'medium',
      body:     d.fields.clean_body?.stringValue ?? d.fields.raw_transcript?.stringValue ?? '',
    }));
}

async function getTelegramUsers(
  token: string,
  projectId: string,
): Promise<DigestUser[]> {
  const users: DigestUser[] = [];
  let pageToken: string | undefined;

  do {
    const url = new URL(`https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users`);
    url.searchParams.set('pageSize', '1000');
    if (pageToken) {
      url.searchParams.set('pageToken', pageToken);
    }

    const res = await fetch(url, {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });

    if (!res.ok) {
      console.error('[WishperLog] getTelegramUsers failed:', res.status, await res.text());
      return [];
    }

    const body = await res.json() as {
      documents?: Array<{ name: string; fields: Record<string, any> }>;
      nextPageToken?: string;
    };

    for (const doc of body.documents ?? []) {
      const f = doc.fields;
      const telegramChatId = f.telegram_chat_id?.stringValue ?? '';
      if (!telegramChatId) continue;

      const digestTimesUtc = readStringListField(f.digest_times_utc);
      const digestTimes = readStringListField(f.digest_times);
      const digestTime = f.digest_time?.stringValue?.toString().trim() ?? '';

      users.push({
        uid: doc.name.split('/').pop() ?? '',
        displayName: f.display_name?.stringValue ?? null,
        telegramChatId,
        digestTimesUtc,
        digestTimes,
        digestTime,
        timezoneOffsetMinutes: Number(f.timezone_offset_minutes?.integerValue ?? f.timezone_offset_minutes?.doubleValue ?? 0) || 0,
      });
    }

    pageToken = body.nextPageToken;
  } while (pageToken);

  return users;
}

async function getTelegramUserByChatId(
  chatId: string,
  token: string,
  projectId: string,
): Promise<DigestUser | null> {
  const users = await getTelegramUsers(token, projectId);
  return users.find((user) => user.telegramChatId === String(chatId)) ?? null;
}

function matchesDigestSlot(user: DigestUser, slot: string): boolean {
  if (user.digestTimesUtc.includes(slot)) {
    return true;
  }

  const offsetMinutes = Number.isFinite(user.timezoneOffsetMinutes) ? user.timezoneOffsetMinutes : 0;
  if (user.digestTimes.some((value) => localSlotToUtc(value, offsetMinutes) === slot)) {
    return true;
  }

  if (user.digestTime && localSlotToUtc(user.digestTime, offsetMinutes) === slot) {
    return true;
  }

  return false;
}

function readStringListField(field: Record<string, any> | undefined): string[] {
  const values = field?.arrayValue?.values ?? [];
  return values
    .map((value: any) => value.stringValue?.toString().trim())
    .filter((value: string | undefined): value is string => !!value);
}

function localSlotToUtc(slot: string, offsetMinutes: number): string {
  const match = String(slot).match(/^(\d{2}):(\d{2})$/);
  if (!match) return '';
  const localMinutes = Number(match[1]) * 60 + Number(match[2]);
  const total = (localMinutes - offsetMinutes) % (24 * 60);
  const normalized = total < 0 ? total + (24 * 60) : total;
  return `${pad(Math.floor(normalized / 60))}:${pad(normalized % 60)}`;
}

async function getDueReminderNotesForUser(
  uid: string,
  now: Date,
  token: string,
  projectId: string,
): Promise<ReminderDoc[]> {
  const start = new Date(now);
  start.setUTCSeconds(0, 0);
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${uid}/notes?pageSize=100`;

  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });

  if (!res.ok) {
    console.error('[WishperLog] getDueReminderNotesForUser failed:', res.status, await res.text());
    return [];
  }

  const body = await res.json() as { documents?: Array<{ name: string; fields: Record<string, any> }> };
  return (body.documents ?? [])
    .map(doc => {
      const f = doc.fields;
      const status = f.status?.stringValue ?? 'active';
      const category = f.category?.stringValue ?? 'reminders';
      const parts = doc.name.split('/');
      const noteId = parts[parts.length - 1] ?? '';
      return {
        noteId,
        uid,
        title: f.title?.stringValue ?? 'Untitled',
        body: f.clean_body?.stringValue ?? f.raw_transcript?.stringValue ?? '',
        category,
        priority: f.priority?.stringValue ?? 'medium',
        status,
        extractedAt: firestoreTimestampToDate(f.extracted_date) ?? new Date('invalid'),
      };
    })
    .filter(r =>
      r.noteId &&
      r.uid &&
      r.status === 'active' &&
      r.category === 'reminders' &&
      r.extractedAt.getTime() >= start.getTime() &&
      r.extractedAt.getTime() < start.getTime() + 60_000 &&
      !Number.isNaN(r.extractedAt.getTime())
    );
}

async function sendDueTelegramReminders(
  now: Date,
  dateKey: string,
  slotKey: string,
  token: string,
  env: Env,
): Promise<void> {
  const users = await getTelegramUsers(token, env.FIREBASE_PROJECT_ID);
  if (users.length === 0) return;

  const reminderGroups = await Promise.all(users.map(async (user) => ({
    user,
    reminders: await getDueReminderNotesForUser(user.uid, now, token, env.FIREBASE_PROJECT_ID),
  })));

  for (const { user, reminders } of reminderGroups) {
    const freshReminders: ReminderDoc[] = [];

    for (const reminder of reminders) {
      const dedupKey = `${dateKey}:reminder:${user.uid}:${reminder.noteId}`;
      const already = await env.DIGEST_SENT.get(dedupKey);
      if (!already) {
        freshReminders.push(reminder);
      }
    }

    if (freshReminders.length === 0) {
      continue;
    }

    try {
      const orderedReminders = freshReminders
        .slice()
        .sort((a, b) => {
          const priorityWeight = { high: 0, medium: 1, low: 2 };
          const aw = priorityWeight[a.priority] ?? 9;
          const bw = priorityWeight[b.priority] ?? 9;
          if (aw !== bw) return aw - bw;
          return a.extractedAt.getTime() - b.extractedAt.getTime();
        });

      const topReminders = orderedReminders.slice(0, 3);
      const message = buildReminderSummaryMessage(
        user.displayName ?? 'there',
        topReminders,
        orderedReminders.length,
        now,
      );

      try {
        await sendTelegramMessage(user.telegramChatId, message, env.TELEGRAM_BOT_TOKEN);
      } catch (messageError) {
        if (isTelegramChatNotFound(messageError)) {
          console.error(`[WishperLog] Invalid Telegram chat for ${user.uid} — clearing saved chat ID`);
          await clearTelegramChatId(user.uid, token, env.FIREBASE_PROJECT_ID);
        }
        throw messageError;
      }

      for (const reminder of freshReminders) {
        const dedupKey = `${dateKey}:reminder:${user.uid}:${reminder.noteId}`;
        await env.DIGEST_SENT.put(dedupKey, '1', { expirationTtl: 93_600 });
      }

      console.log(`[WishperLog] Reminder summary sent to ${user.uid} at ${slotKey} (${freshReminders.length} note(s))`);
    } catch (err) {
      console.error(`[WishperLog] Reminder failed for ${user.uid}:`, err);
    }
  }
}

// ── Telegram ──────────────────────────────────────────────────────────────────

async function sendTelegramMessage(
  chatId: string,
  text:   string,
  token:  string,
  replyMarkup?: any,
): Promise<void> {
  const url = `https://api.telegram.org/bot${token}/sendMessage`;
  const res = await fetch(url, {
    method:  'POST',
    headers: { 'Content-Type': 'application/json' },
    body:    JSON.stringify({
      chat_id:    chatId,
      text: asciiOnly(text),
      // Prevent link previews cluttering the chat.
      disable_web_page_preview: true,
      ...(replyMarkup ? { reply_markup: replyMarkup } : {}),
    }),
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Telegram sendMessage ${res.status}: ${body}`);
  }
}

async function clearTelegramChatId(uid: string, token: string, projectId: string): Promise<void> {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${uid}?updateMask.fieldPaths=telegram_chat_id`;
  await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      fields: {
        telegram_chat_id: { stringValue: '' },
      },
    }),
  });
}

function isTelegramChatNotFound(error: unknown): boolean {
  const message = error instanceof Error ? error.message : String(error ?? '');
  return message.includes('Bad Request: chat not found');
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

function buildDigestMessage(notes: NoteDoc[], name: string, now: Date, heading = 'WishperLog summary'): string {
  const ordered = notes.slice(0, 3);
  const counts = notes.reduce((acc, note) => {
    const cat = normalizeCategory(note.category);
    acc[cat] = (acc[cat] ?? 0) + 1;
    return acc;
  }, {} as Record<string, number>);

  const lines = [
    `${heading} for ${asciiOnly(name)}`,
    `Generated ${utcStamp(now)}`,
    '',
    `Active notes: ${notes.length}`,
    `Tasks: ${counts.tasks ?? 0}`,
    `Reminders: ${counts.reminders ?? 0}`,
    `Ideas: ${counts.ideas ?? 0}`,
    `Follow-up: ${counts['follow-up'] ?? 0}`,
    `Journal: ${counts.journal ?? 0}`,
    '',
  ];

  if (ordered.length === 0) {
    lines.push('No active notes found.');
  } else {
    lines.push('Top 3:');
    ordered.forEach((note, index) => {
      lines.push(formatAsciiNoteLine(note, index));
    });
  }

  return lines.join('\n');
}

function buildHelpText(): string {
  return [
    'WishperLog commands',
    '',
    '/summary - show the top 3 active notes',
    '/task - top 3 tasks',
    '/reminder - top 3 reminders',
    '/idea - top 3 ideas',
    '/followup - top 3 follow-up notes',
    '/journal - top 3 journal notes',
    '/all - top 3 active notes across all categories',
  ].join('\n');
}

function parseTelegramCommand(text: string): string {
  const firstToken = asciiOnly(text).split(/\s+/)[0] || '';
  return firstToken.replace(/^\//, '').split('@')[0].toLowerCase();
}

function telegramInlineRows(uid: string, notes: NoteDoc[]) {
  return notes.slice(0, 3).map((note) => {
    const noteId = note.note_id || note.id;
    return [
      { text: `Done: ${asciiOnly(note.title).slice(0, 24)}`, callback_data: `done|${uid}|${noteId}` },
      { text: 'Archive', callback_data: `archive|${uid}|${noteId}` },
    ];
  });
}

async function configureTelegramWebhook(env: Env, webhookUrl: string): Promise<string> {
  const res = await fetch(`https://api.telegram.org/bot${env.TELEGRAM_BOT_TOKEN}/setWebhook`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      url: webhookUrl,
      allowed_updates: ['message', 'callback_query'],
    }),
  });

  const body = await res.text();
  return res.ok ? `Webhook configured: ${body}` : `Webhook configuration failed: ${body}`;
}

async function updateTelegramUserChatId(
  uid: string,
  chatId: string,
  token: string,
  projectId: string,
): Promise<void> {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${uid}?updateMask.fieldPaths=telegram_chat_id`;
  const res = await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      fields: {
        telegram_chat_id: { stringValue: String(chatId) },
      },
    }),
  });

  if (!res.ok) {
    const body = await res.text();
    throw new Error(`Firestore telegram_chat_id update failed ${res.status}: ${body}`);
  }
}

async function updateNoteStatus(
  uid: string,
  noteId: string,
  status: string,
  token: string,
  projectId: string,
): Promise<void> {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/users/${uid}/notes/${noteId}?updateMask.fieldPaths=status&updateMask.fieldPaths=updated_at`;
  await fetch(url, {
    method: 'PATCH',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      fields: {
        status: { stringValue: status },
        updated_at: { timestampValue: new Date().toISOString() },
      },
    }),
  });
}

async function answerTelegramCallback(callbackId: string, token: string, text: string): Promise<void> {
  if (!callbackId) return;
  await fetch(`https://api.telegram.org/bot${token}/answerCallbackQuery`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      callback_query_id: callbackId,
      text: asciiOnly(text),
      show_alert: false,
    }),
  });
}

async function handleTelegramWebhook(req: Request, env: Env, url: URL): Promise<void> {
  const token = await getFirebaseToken(env);
  const update = await req.json() as any;

  if (update.callback_query) {
    const callback = update.callback_query;
    const [action, uid, noteId] = String(callback.data || '').split('|');
    if (uid && noteId) {
      const status = action === 'done' ? 'done' : 'archived';
      await updateNoteStatus(uid, noteId, status, token, env.FIREBASE_PROJECT_ID);
      await answerTelegramCallback(callback.id, env.TELEGRAM_BOT_TOKEN, action === 'done' ? 'Marked done' : 'Archived');
    } else {
      await answerTelegramCallback(callback.id, env.TELEGRAM_BOT_TOKEN, 'Invalid action');
    }
    return;
  }

  const message = update.message;
  const chatId = message?.chat?.id;
  const text = String(message?.text || '');

  if (!chatId || !text) {
    return;
  }

  const startMatch = text.match(/^\/start\s+uid_(.+)$/i);
  if (startMatch) {
    const uid = startMatch[1].trim();
    if (uid) {
      await updateTelegramUserChatId(uid, String(chatId), token, env.FIREBASE_PROJECT_ID);
      await sendTelegramMessage(String(chatId), 'WishperLog linked. Use /summary, /task, /reminder, /idea, /followup, /journal, or /all.', env.TELEGRAM_BOT_TOKEN);
    }
    return;
  }

  if (!text.startsWith('/')) {
    return;
  }

  const command = parseTelegramCommand(text);
  if (!command || command === 'help') {
    await sendTelegramMessage(String(chatId), buildHelpText(), env.TELEGRAM_BOT_TOKEN);
    return;
  }

  const linkedUser = await getTelegramUserByChatId(String(chatId), token, env.FIREBASE_PROJECT_ID);
  if (!linkedUser) {
    await sendTelegramMessage(String(chatId), 'Link your WishperLog account first with /start uid_<your_uid>, then use /summary or /task.', env.TELEGRAM_BOT_TOKEN);
    return;
  }

  const notes = await getUserNotes(linkedUser.uid, token, env.FIREBASE_PROJECT_ID);
  let filteredNotes = notes;
  let heading = 'WishperLog summary';

  switch (command) {
    case 'summary':
    case 'all':
      heading = 'WishperLog summary';
      break;
    case 'task':
    case 'tasks':
    case 'todo':
    case 'to-do':
      filteredNotes = filterNotesByCategory(notes, 'tasks');
      heading = 'WishperLog tasks';
      break;
    case 'reminder':
    case 'reminders':
      filteredNotes = filterNotesByCategory(notes, 'reminders');
      heading = 'WishperLog reminders';
      break;
    case 'idea':
    case 'ideas':
      filteredNotes = filterNotesByCategory(notes, 'ideas');
      heading = 'WishperLog ideas';
      break;
    case 'followup':
    case 'follow-up':
    case 'follow_up':
      filteredNotes = filterNotesByCategory(notes, 'follow-up');
      heading = 'WishperLog follow-up';
      break;
    case 'journal':
      filteredNotes = filterNotesByCategory(notes, 'journal');
      heading = 'WishperLog journal';
      break;
    default:
      await sendTelegramMessage(String(chatId), buildHelpText(), env.TELEGRAM_BOT_TOKEN);
      return;
  }

  const topNotes = sortPriority(filteredNotes).slice(0, 3);
  const replyMarkup = topNotes.length > 0 ? { inline_keyboard: telegramInlineRows(linkedUser.uid, topNotes) } : undefined;
  const textOut = buildDigestMessage(filteredNotes, linkedUser.displayName ?? 'there', new Date(), heading);
  await sendTelegramMessage(String(chatId), textOut, env.TELEGRAM_BOT_TOKEN, replyMarkup);
}

function buildReminderSummaryMessage(name: string, reminders: ReminderDoc[], totalCount: number, now: Date): string {
  const lines = [
    `WishperLog reminders for ${asciiOnly(name)}`,
    `Generated ${utcStamp(now)}`,
    '',
    `Due now: ${totalCount}`,
    '',
  ];

  if (reminders.length === 0) {
    lines.push('No due reminders found.');
    return lines.join('\n');
  }

  lines.push('Top 3:');
  reminders.forEach((reminder, index) => {
    const dueAt = reminder.extractedAt;
    const dueText = `${dueAt.toISOString().slice(0, 10)} ${pad(dueAt.getUTCHours())}:${pad(dueAt.getUTCMinutes())} UTC`;
    const title = asciiOnly(reminder.title);
    lines.push(`${index + 1}. [REMINDER][${priorityLabel(reminder.priority)}] ${title}`);
    if (reminder.body) {
      lines.push(`   ${asciiOnly(reminder.body).slice(0, 120)}`);
    }
    lines.push(`   Due ${dueText}`);
  });

  if (totalCount > reminders.length) {
    lines.push('');
    lines.push(`+ ${totalCount - reminders.length} more.`);
  }

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

function asciiOnly(value: string): string {
  return (value ?? '')
    .toString()
    .normalize('NFKD')
    .replace(/[^\x00-\x7F]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

function normalizeCategory(category: string): string {
  const key = asciiOnly(category || 'general').toLowerCase();
  if (key === 'task' || key === 'tasks' || key === 'todo' || key === 'to-do') return 'tasks';
  if (key === 'reminder' || key === 'reminders') return 'reminders';
  if (key === 'idea' || key === 'ideas') return 'ideas';
  if (key === 'followup' || key === 'follow-up' || key === 'follow_up') return 'follow-up';
  if (key === 'journal') return 'journal';
  return 'general';
}

function priorityLabel(priority: string): string {
  switch ((priority || '').toLowerCase()) {
    case 'high': return 'HIGH';
    case 'low': return 'LOW';
    default: return 'MED';
  }
}

function formatAsciiNoteLine(note: NoteDoc, index: number): string {
  return `${index + 1}. [${normalizeCategory(note.category).toUpperCase()}][${priorityLabel(note.priority)}] ${asciiOnly(note.title)}`;
}

function utcStamp(now: Date): string {
  return now.toISOString().replace('T', ' ').slice(0, 16) + ' UTC';
}

function firestoreTimestampToDate(value: any): Date | null {
  const timestamp = value?.timestampValue;
  if (typeof timestamp !== 'string' || timestamp.trim().length === 0) {
    return null;
  }
  return new Date(timestamp);
}
