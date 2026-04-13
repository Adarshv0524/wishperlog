// cloudfare/src/worker.ts
//
// WishperLog Digest Worker — v3.1
//
// ── Architecture change (v3.1) ──────────────────────────────────────────────
// The cron now reads scheduling data from the user root document so digest
// delivery does not depend on the optional digest/config mirror write.
//
// Firestore query path for cron:
//   collection: users  →  filter docs with telegram_chat_id present
//
// Firestore path for cron dedup KV:
//   key format: "YYYY-MM-DD:HH:MM:<uid>"   TTL: 26 h (93 600 s)
//
// Webhook: reads user root doc via token lookup (unchanged) then writes a
// history entry to users/{uid}/digest/history_<ts>.
// ENV secrets (wrangler secret put <name>):
//   TELEGRAM_BOT_TOKEN
//   FIREBASE_PROJECT_ID
//   FIREBASE_CLIENT_EMAIL
//   FIREBASE_PRIVATE_KEY          (PEM with literal \n)
//   TRIGGER_SECRET
// ─────────────────────────────────────────────────────────────────────────────

interface Env {
  DIGEST_SENT: KVNamespace;
  TELEGRAM_BOT_TOKEN: string;
  FIREBASE_PROJECT_ID: string;
  FIREBASE_CLIENT_EMAIL: string;
  FIREBASE_PRIVATE_KEY: string;
  TRIGGER_SECRET: string;
}

type KVNamespace = {
  get(key: string): Promise<string | null> | string | null;
  put(key: string, value: string, options?: { expirationTtl?: number }): Promise<void> | void;
};

type ScheduledEvent = unknown;

type ExecutionContext = unknown;

// ── JWT / Auth ────────────────────────────────────────────────────────────────

async function getFirebaseToken(env: Env): Promise<string> {
  const privateKey = env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, "\n");
  const now        = Math.floor(Date.now() / 1000);

  const header  = { alg: "RS256", typ: "JWT" };
  const payload = {
    iss  : env.FIREBASE_CLIENT_EMAIL,
    sub  : env.FIREBASE_CLIENT_EMAIL,
    aud  : "https://oauth2.googleapis.com/token",
    iat  : now,
    exp  : now + 3600,
    scope: "https://www.googleapis.com/auth/datastore",
  };

  const encode = (obj: object) =>
    btoa(JSON.stringify(obj))
      .replace(/=/g, "")
      .replace(/\+/g, "-")
      .replace(/\//g, "_");

  const unsigned = `${encode(header)}.${encode(payload)}`;

  const keyData = await crypto.subtle.importKey(
    "pkcs8",
    pemToBuffer(privateKey),
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );

  const sig = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    keyData,
    new TextEncoder().encode(unsigned),
  );

  const sigB64 = btoa(String.fromCharCode(...new Uint8Array(sig)))
    .replace(/=/g, "")
    .replace(/\+/g, "-")
    .replace(/\//g, "_");

  const jwt = `${unsigned}.${sigB64}`;

  const resp = await fetch("https://oauth2.googleapis.com/token", {
    method : "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body   : `grant_type=urn%3Aietf%3Aparams%3Aoauth%3Agrant-type%3Ajwt-bearer&assertion=${jwt}`,
  });

  const data = (await resp.json()) as { access_token?: string; error?: string };
  if (!data.access_token) {
    throw new Error(`Firebase token exchange failed: ${data.error ?? "unknown"}`);
  }
  return data.access_token;
}

function pemToBuffer(pem: string): ArrayBuffer {
  const b64 = pem
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const bin = atob(b64);
  const buf = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) buf[i] = bin.charCodeAt(i);
  return buf.buffer;
}

// ── Firestore REST helpers ────────────────────────────────────────────────────

async function firestoreGet(
  path: string,
  token: string,
  projectId: string,
): Promise<unknown> {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${path}`;
  const resp = await fetch(url, {
    headers: { Authorization: `Bearer ${token}` },
  });
  if (!resp.ok) throw new Error(`Firestore GET failed: ${resp.status} ${path}`);
  return resp.json();
}

async function firestorePost(
  path: string,
  body: object,
  token: string,
  projectId: string,
): Promise<unknown> {
  const url = `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${path}`;
  const resp = await fetch(url, {
    method : "POST",
    headers: {
      Authorization  : `Bearer ${token}`,
      "Content-Type" : "application/json",
    },
    body: JSON.stringify(body),
  });
  if (!resp.ok) {
    const text = await resp.text();
    throw new Error(`Firestore POST failed: ${resp.status} ${text}`);
  }
  return resp.json();
}

async function firestorePatch(
  docPath: string,
  fields: Record<string, unknown>,
  token: string,
  projectId: string,
): Promise<void> {
  const url =
    `https://firestore.googleapis.com/v1/projects/${projectId}/databases/(default)/documents/${docPath}` +
    `?${Object.keys(fields)
      .map((k) => `updateMask.fieldPaths=${encodeURIComponent(k)}`)
      .join("&")}`;

  const resp = await fetch(url, {
    method : "PATCH",
    headers: {
      Authorization : `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({ fields }),
  });
  if (!resp.ok) {
    const text = await resp.text();
    throw new Error(`Firestore PATCH failed: ${resp.status} ${text}`);
  }
}

// ── Firestore field extractors ────────────────────────────────────────────────

function extractField(doc: any, field: string): unknown {
  const f = doc?.fields?.[field];
  if (!f) return undefined;
  return (
    f.stringValue  ??
    f.integerValue ??
    f.booleanValue ??
    f.doubleValue  ??
    undefined
  );
}

function extractArray(doc: any, field: string): string[] {
  const f = doc?.fields?.[field];
  if (!f?.arrayValue?.values) return [];
  return (f.arrayValue.values as any[]).map(
    (v: any) => v.stringValue ?? "",
  ).filter(Boolean);
}

// ── Telegram ──────────────────────────────────────────────────────────────────

async function sendTelegramMessage(
  chatId: string,
  text: string,
  botToken: string,
): Promise<void> {
  const resp = await fetch(
    `https://api.telegram.org/bot${botToken}/sendMessage`,
    {
      method : "POST",
      headers: { "Content-Type": "application/json" },
      body   : JSON.stringify({
        chat_id   : chatId,
        text,
        parse_mode: "HTML",
      }),
    },
  );
  if (!resp.ok) {
    const err = await resp.text();
    throw new Error(`Telegram sendMessage failed: ${err}`);
  }
}

// ── Cron digest ───────────────────────────────────────────────────────────────

// ── v3 schema helpers ─────────────────────────────────────────────────────

async function readDigestLatest(
  uid: string,
  token: string,
  env: Env,
): Promise<any | null> {
  try {
    return await firestoreGet(
      `users/${uid}/digest/latest`,
      token,
      env.FIREBASE_PROJECT_ID,
    );
  } catch {
    return null; // Subcollection may not exist yet (v2 user)
  }
}

// Try digest/config first (v3), fallback to user root doc (v2)
function resolveChatId(userDoc: any, digestConfig: any): string | null {
  const f   = userDoc?.fields ?? {};
  const df  = digestConfig?.fields ?? {};
  const raw = df['telegram_chat_id']?.stringValue
           ?? f['telegram_chat_id']?.stringValue
           ?? f['chat_id']?.stringValue
           ?? null;
  return raw ? String(raw).trim() : null;
}

// Read digest times from user doc (canonical field)
function resolveDigestTimes(userDoc: any): string[] {
  const f = userDoc?.fields ?? {};
  const digestTimesField = f['digest_times']?.arrayValue?.values ?? [];
  return digestTimesField
    .map((v: any) => v?.stringValue ?? v?.integerValue ?? '')
    .filter(Boolean)
    .map((v: string | number) => String(v).trim())
    .filter((v: string) => v.length > 0);
}

async function runDigestCron(env: Env): Promise<void> {
  const nowUtc    = new Date();
  const slotKey   = toSlotKey(nowUtc);
  const dateKey   = toDateKey(nowUtc);
  const token     = await getFirebaseToken(env);

  console.log(`[Cron] Slot ${slotKey} (${dateKey}) — scanning users`);

  const users = await listAllUsers(token, env.FIREBASE_PROJECT_ID);
  console.log(`[Cron] ${users.length} user(s) found`);

  let fired = 0;

  for (const doc of users) {
    const uid  = extractUidFromDocName(doc?.name ?? '');
    if (!uid) continue;

    const f    = doc?.fields ?? {};
    const name = (f['display_name']?.stringValue ?? '').trim();

    // Resolve digest times and chat_id ─────────────────────────────────────
    const digestTimes = resolveDigestTimes(doc);
    if (digestTimes.length === 0) continue;

    // Compute user-local slot using timezone_offset_minutes
    const tzOffsetMin = Number(f['timezone_offset_minutes']?.integerValue ?? 0);
    const localMs  = nowUtc.getTime() + tzOffsetMin * 60_000;
    const localDt  = new Date(localMs);
    const localSlot = toSlotKey(localDt);
    const localDate = toDateKey(localDt);

    if (!digestTimes.includes(localSlot)) continue;

    // Dedup: already sent today? ───────────────────────────────────────────
    const dedupKey = `${localDate}:${localSlot}:${uid}`;
    const already  = await env.DIGEST_SENT.get(dedupKey);
    if (already) {
      console.log(`[Cron] Already sent for ${uid} at ${localSlot} — skip`);
      continue;
    }

    // Resolve chat_id: check digest/config (v3) then root doc (v2) ─────────
    let chatId: string | null = null;
    let digestConfigDoc: any = null;
    try {
      digestConfigDoc = await firestoreGet(
        `users/${uid}/digest/config`,
        token,
        env.FIREBASE_PROJECT_ID,
      );
      chatId = resolveChatId(doc, digestConfigDoc);
    } catch {
      chatId = resolveChatId(doc, null);
    }
    if (!chatId) continue;

    // Build message ─────────────────────────────────────────────────────────
    // v3: try pre-rendered message from digest/latest first.
    let message: string | null = null;
    const digestLatestDoc = await readDigestLatest(uid, token, env);
    if (digestLatestDoc) {
      const lf = digestLatestDoc?.fields ?? {};
      const preRendered = lf['telegram']?.stringValue
                       ?? lf['telegram_digest']?.stringValue
                       ?? '';
      if (preRendered.trim().length > 0) {
        message = preRendered;
        console.log(`[Cron] Using pre-rendered digest/latest for ${uid}`);
      }
    }

    // Fallback: fetch live notes and build on the fly.
    if (!message) {
      console.log(`[Cron] Building live digest for ${uid}`);
      const notesSnap = await firestoreGet(
        `users/${uid}/notes?pageSize=200`,
        token,
        env.FIREBASE_PROJECT_ID,
      );
      const notes = parseNoteDocs(
        ((notesSnap as any)?.documents ?? []) as any[],
        uid,
      );
      message = buildDigest(notes, name, 'Daily Digest');
    }

    // Send ─────────────────────────────────────────────────────────────────
    try {
      await sendTelegramMessage(String(chatId), message, env.TELEGRAM_BOT_TOKEN);
      await env.DIGEST_SENT.put(dedupKey, '1', { expirationTtl: 93_600 });
      await writeDigestHistory(uid, 'cron_digest', 'Daily Digest', 0, token, env);
      fired++;
      console.log(`[Cron] Digest sent to ${uid} (${chatId}) slot=${localSlot}`);
    } catch (e) {
      console.error(`[Cron] Failed to send to ${uid}: ${e}`);
    }
  }

  console.log(`[Cron] Done — fired ${fired} digest(s)`);
}

// ── Write digest history entry ────────────────────────────────────────────────

async function writeDigestHistory(
  uid: string,
  command: string,
  heading: string,
  noteCount: number,
  token: string,
  env: Env,
): Promise<void> {
  try {
    const ts    = Date.now();
    const docId = `history_${ts}`;
    const path  = `users/${uid}/digest/${docId}`;

    const fields = {
      command         : { stringValue: command },
      response_heading: { stringValue: heading },
      note_count      : { integerValue: String(noteCount) },
      queried_at      : { timestampValue: new Date().toISOString() },
    };

    await firestorePatch(path, fields, token, env.FIREBASE_PROJECT_ID);
  } catch (e) {
    // Non-fatal: history logging should never block the main send path.
    console.warn(`[History] Failed to write history for ${uid}: ${e}`);
  }
}

// ── Telegram webhook handler ──────────────────────────────────────────────────

// ── Live-digest builder (used by webhook to avoid stale cached state) ─────────
async function buildLiveTelegramMessage(
  uid: string,
  token: string,
  env: Env,
): Promise<string> {
  const notes = await fetchUserNotes(uid, token, env);
  const userDoc = await fetchUserDoc(uid, token, env);
  const f = userDoc?.fields ?? {};
  const displayName = (f['display_name']?.stringValue ?? '').trim();
  const noteDocs = parseNoteDocs(notes, uid);
  return buildDigest(noteDocs, displayName, '📋 Your Notes Summary');
}

async function fetchUserNotes(uid: string, token: string, env: Env): Promise<any[]> {
  const notesSnap = await firestoreGet(
    `users/${uid}/notes?pageSize=200`,
    token,
    env.FIREBASE_PROJECT_ID,
  );

  return ((notesSnap as any)?.documents ?? []) as any[];
}

async function fetchUserDoc(uid: string, token: string, env: Env): Promise<any | null> {
  try {
    return await firestoreGet(
      `users/${uid}`,
      token,
      env.FIREBASE_PROJECT_ID,
    );
  } catch {
    return null;
  }
}

async function handleWebhook(req: Request, env: Env): Promise<Response> {
  let body: any;
  try {
    body = await req.json();
  } catch {
    return new Response("bad request", { status: 400 });
  }

  const message = body?.message;
  const chatId  = message?.chat?.id;
  const text    = (message?.text ?? "").trim();

  if (!chatId || !text.startsWith("/")) {
    return new Response("ok");
  }

  const token = await getFirebaseToken(env);

  // ── Handle /start <link_token> — link the user's account ──────────────────
  if (text.startsWith("/start")) {
    const parts      = text.split(/\s+/);
    const linkToken  = parts[1]?.trim() ?? "";

    if (linkToken) {
      await handleStartWithToken(chatId, linkToken, token, env);
    } else {
      // /start with no token → send help + Chat ID
      await sendTelegramMessage(
        String(chatId),
        [
          '<b>WishperLog</b> <i>Telegram link</i>',
          '',
          'Your Chat ID',
          `<code>${chatId}</code>`,
          '',
          '<i>Manual linking</i>',
          '1. Open WishperLog → Settings → Telegram',
          '2. Tap <b>Manual Chat ID</b>',
          '3. Paste the number above',
        ].join('\n'),
        env.TELEGRAM_BOT_TOKEN,
      );
    }
    return new Response("ok");
  }

  // ── Handle digest commands ─────────────────────────────────────────────────
  const cmd = text.replace(/^\//, "").split("@")[0].toLowerCase();
  if (cmd === "summary" || cmd === "top") {
    // Always fetch live notes from Firestore for freshest data.
    try {
      const uid = await resolveTelegramUserId(String(chatId), token, env);
      const liveMessage = await buildLiveTelegramMessage(uid, token, env);
      await sendTelegramMessage(String(chatId), liveMessage, env.TELEGRAM_BOT_TOKEN);
    } catch (e) {
      console.error(`[Webhook] Failed to build live digest for ${chatId}:`, e);
      await sendTelegramMessage(
        String(chatId),
        '⚠️ Could not fetch your notes right now. Try again shortly.',
        env.TELEGRAM_BOT_TOKEN,
      );
    }
    return new Response("ok");
  }

  await handleDigestCommand(chatId, cmd, token, env);

  return new Response("ok");
}

async function resolveTelegramUserId(
  chatId: string,
  token: string,
  env: Env,
): Promise<string> {
  const queryUrl =
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;

  const configDoc =
    await findLinkedDigestConfigDoc(queryUrl, token, chatId, env);

  const uid = extractUidFromDocName(configDoc?.name ?? "");
  if (uid) return uid;

  throw new Error(`Telegram chat ${chatId} is not linked to a user`);
}

async function handleStartWithToken(
  chatId: number,
  linkToken: string,
  token: string,
  env: Env,
): Promise<void> {
  const queryUrl =
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;

  const userDoc = await findLinkedUserDocByValue(queryUrl, token, linkToken, [
    "telegram_link_token",
    "telegram_link_pin",
    "pending_telegram.token",
  ]);

  if (!userDoc) {
    await sendTelegramMessage(
      String(chatId),
      [
        '<b>Telegram link not found or already used.</b>',
        '',
        '<i>Quick recovery</i>',
        '• Open WishperLog → Settings → Telegram',
        '• Tap <b>Connect in Telegram</b> again',
        '• Use the new link or copied code immediately',
        '',
        '<i>Manual fallback</i>',
        'Send <b>/start</b> without a code to get your Chat ID, then paste it back into the app.',
      ].join('\n'),
      env.TELEGRAM_BOT_TOKEN,
    );
    return;
  }

  const uid         = userDoc.name?.split("/").pop() as string;
  const displayName = (extractField(userDoc, "display_name") as string) ?? "there";

  // Write chat_id to both the user root doc and the digest/config doc.
  const chatIdStr = String(chatId);

  // User root doc update
  await firestorePatch(
    `users/${uid}`,
    {
      telegram_chat_id: { stringValue: chatIdStr },
      telegram_link_token: { nullValue: "NULL_VALUE" },
    },
    token,
    env.FIREBASE_PROJECT_ID,
  );

  // Digest config doc update — this is the canonical source the cron reads.
  await firestorePatch(
    `users/${uid}/digest/config`,
    {
      telegram_chat_id: { stringValue: chatIdStr },
      link_method     : { stringValue: "auto_deeplink" },
      linked_at       : { timestampValue: new Date().toISOString() },
    },
    token,
    env.FIREBASE_PROJECT_ID,
  );

  await sendTelegramMessage(
    chatIdStr,
    [
      '✅ <b>WishperLog connected</b>',
      '',
      `Hello <b>${escapeHtml(asciiOnly(displayName))}</b>!`,
      'Your digests are now linked and ready.',
      '',
      '<b>Quick commands</b>',
      '<code>/summary</code> <code>/top</code> <code>/tasks</code>',
      '<code>/reminders</code> <code>/ideas</code> <code>/followup</code>',
      '<code>/journal</code> <code>/general</code>',
    ].join('\n'),
    env.TELEGRAM_BOT_TOKEN,
  );
}

async function findLinkedUserDocByValue(
  queryUrl: string,
  token: string,
  linkToken: string,
  fieldPaths: string[],
): Promise<any | null> {
  for (const fieldPath of fieldPaths) {
    const queryResp = await fetch(queryUrl, {
      method : "POST",
      headers: {
        Authorization : `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        structuredQuery: {
          from : [{ collectionId: "users" }],
          where: {
            fieldFilter: {
              field: { fieldPath },
              op   : "EQUAL",
              value: { stringValue: linkToken },
            },
          },
          limit: { value: 1 },
        },
      }),
    });

    if (!queryResp.ok) continue;
    const results = (await queryResp.json()) as any[];
    const doc = results?.[0]?.document;
    if (doc) return doc;
  }

  return null;
}

async function handleDigestCommand(
  chatId: number,
  cmd: string,
  token: string,
  env: Env,
): Promise<void> {
  const queryUrl =
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;

  const configDoc =
    await findLinkedDigestConfigDoc(queryUrl, token, String(chatId), env);

  if (!configDoc) {
    await sendTelegramMessage(
      String(chatId),
      [
        '<b>Telegram is not linked yet.</b>',
        '',
        'Open WishperLog → Telegram and connect again.',
      ].join('\n'),
      env.TELEGRAM_BOT_TOKEN,
    );
    return;
  }

  const uid = extractUidFromDocName(configDoc.name ?? "");
  if (!uid) {
    await sendTelegramMessage(
      String(chatId),
      [
        '<b>Telegram is linked, but the user record could not be resolved.</b>',
        '',
        'Open WishperLog → Settings → Telegram and reconnect.',
      ].join('\n'),
      env.TELEGRAM_BOT_TOKEN,
    );
    return;
  }
  const name      = (extractField(configDoc, "display_name") as string) ?? "there";

  if (!isSupportedTelegramCommand(cmd)) {
    await sendTelegramMessage(
      String(chatId),
      [
        '<b>WishperLog commands</b>',
        '<i>Use any of these:</i>',
        '',
        '<code>/summary</code>  <code>/top</code>  <code>/tasks</code>',
        '<code>/reminders</code>  <code>/ideas</code>  <code>/followup</code>',
        '<code>/journal</code>  <code>/general</code>',
      ].join('\n'),
      env.TELEGRAM_BOT_TOKEN,
    );
    return;
  }

  let message = "";
  try {
    message = await loadCachedTelegramMessage(uid, configDoc, cmd, token, env);
  } catch (e) {
    console.warn(`[Cmd] Failed to read cached message for ${uid}: ${e}`);
  }

  const heading = pickHeading(cmd);

  if (!message) {
    const infoDoc = await loadDigestInfoDoc(uid, token, env);
    const notes =
      extractDigestNotes(infoDoc).length > 0
        ? extractDigestNotes(infoDoc)
        : parseNoteDocs(
            ((await firestoreGet(
              `users/${uid}/notes?pageSize=200`,
              token,
              env.FIREBASE_PROJECT_ID,
            )) as any)?.documents ?? [],
            uid,
          );
    const sentNotes = pickNotesForCommand(notes, cmd);
    message = buildDigest(sentNotes, name, heading);
    await sendTelegramMessage(String(chatId), message, env.TELEGRAM_BOT_TOKEN);
    await writeDigestHistory(uid, cmd, heading, sentNotes.length, token, env);
    return;
  }

  await sendTelegramMessage(
    String(chatId),
    message,
    env.TELEGRAM_BOT_TOKEN,
  );

  // Log to history
  await writeDigestHistory(uid, cmd, heading, 0, token, env);
}

function extractMessageState(doc: any): Record<string, string> {
  const fields = doc?.fields?.message_state?.mapValue?.fields ?? {};
  const output: Record<string, string> = {};
  for (const [key, value] of Object.entries(fields)) {
    const fieldValue = value as any;
    const raw = fieldValue?.stringValue;
    if (typeof raw === "string" && raw.trim()) {
      output[key] = raw;
    }
  }
  return output;
}

async function loadCachedTelegramMessage(
  uid: string,
  configDoc: any,
  cmd: string,
  token: string,
  env: Env,
): Promise<string> {
  const infoDoc = await loadDigestInfoDoc(uid, token, env);
  const configState = {
    ...extractMessageState(configDoc),
    ...extractMessageState(infoDoc),
  };
  const fromConfig = pickTelegramMessage(configState, cmd);
  if (fromConfig) return fromConfig;

  try {
    const userSnap = await firestoreGet(
      `users/${uid}`,
      token,
      env.FIREBASE_PROJECT_ID,
    );
    return pickTelegramMessage(extractMessageState(userSnap as any), cmd);
  } catch {
    return "";
  }
}

async function loadDigestInfoDoc(uid: string, token: string, env: Env): Promise<any | null> {
  try {
    return await firestoreGet(
      `users/${uid}/digest/config/info/current`,
      token,
      env.FIREBASE_PROJECT_ID,
    );
  } catch {
    return null;
  }
}

function extractDigestNotes(doc: any): NoteDoc[] {
  const values = doc?.fields?.notes?.arrayValue?.values ?? [];
  return values
    .map((entry: any) => {
      const fields = entry?.mapValue?.fields ?? {};
      const str = (key: string) => fields[key]?.stringValue ?? '';
      return {
        title: str('title') || str('note_title'),
        category: str('category'),
        priority: str('priority'),
        body: str('body') || str('clean_body'),
      } as NoteDoc;
    })
    .filter((note: NoteDoc) => Boolean(note.title || note.body || note.category));
}

function pickTelegramMessage(state: Record<string, string>, cmd: string): string {
  const summary = state.telegram_summary ?? state.telegram_digest ?? state.telegram ?? "";
  switch (cmd) {
    case "summary":
    case "all":
      return summary;
    case "top":
      return state.telegram_top ?? summary;
    case "tasks":
    case "task":
    case "todo":
      return state.telegram_tasks ?? summary;
    case "reminders":
    case "reminder":
      return state.telegram_reminders ?? summary;
    case "ideas":
    case "idea":
      return state.telegram_ideas ?? summary;
    case "followup":
    case "follow-up":
    case "follow_up":
      return state.telegram_followup ?? summary;
    case "journal":
      return state.telegram_journal ?? summary;
    case "general":
      return state.telegram_general ?? summary;
    default:
      return "";
  }
}

function pickHeading(cmd: string): string {
  switch (cmd) {
    case "top":
      return "Top";
    case "tasks":
    case "task":
    case "todo":
      return "Tasks";
    case "reminders":
    case "reminder":
      return "Reminders";
    case "ideas":
    case "idea":
      return "Ideas";
    case "followup":
    case "follow-up":
    case "follow_up":
      return "Follow-up";
    case "journal":
      return "Journal";
    case "general":
      return "General";
    default:
      return "Summary";
  }
}

function pickNotesForCommand(notes: NoteDoc[], cmd: string): NoteDoc[] {
  switch (cmd) {
    case "top":
      return [...notes]
        .sort((a, b) => priorityRank(a.priority) - priorityRank(b.priority))
        .slice(0, 3);
    case "tasks":
    case "task":
    case "todo":
      return notes.filter((n) => n.category === "tasks");
    case "reminders":
    case "reminder":
      return notes.filter((n) => n.category === "reminders");
    case "ideas":
    case "idea":
      return notes.filter((n) => n.category === "ideas");
    case "followup":
    case "follow-up":
    case "follow_up":
      return notes.filter((n) => n.category === "followUp");
    case "journal":
      return notes.filter((n) => n.category === "journal");
    case "general":
      return notes.filter((n) => n.category === "general");
    default:
      return notes;
  }
}

function isSupportedTelegramCommand(cmd: string): boolean {
  return [
    "summary",
    "all",
    "top",
    "tasks",
    "task",
    "todo",
    "reminders",
    "reminder",
    "ideas",
    "idea",
    "followup",
    "follow-up",
    "follow_up",
    "journal",
    "general",
  ].includes(cmd);
}

async function findLinkedDigestConfigDoc(
  queryUrl: string,
  token: string,
  chatId: string,
  env: Env,
): Promise<any | null> {
  const candidates = [
    {
      from: [{ collectionId: "users" }],
      where: {
        fieldFilter: {
          field: { fieldPath: "telegram_chat_id" },
          op: "EQUAL",
          value: { stringValue: chatId },
        },
      },
      limit: { value: 1 },
    },
    {
      from: [{ collectionId: "digest", allDescendants: true }],
      where: {
        fieldFilter: {
          field: { fieldPath: "telegram_chat_id" },
          op: "EQUAL",
          value: { stringValue: chatId },
        },
      },
      limit: { value: 1 },
    },
  ];

  for (const structuredQuery of candidates) {
    const queryResp = await fetch(queryUrl, {
      method : "POST",
      headers: {
        Authorization : `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ structuredQuery }),
    });

    if (!queryResp.ok) continue;

    const results = (await queryResp.json()) as any[];
    for (const result of results) {
      const doc = result?.document;
      if (!doc) continue;
      return doc;
    }
  }

  return null;
}

function extractUidFromDocName(name: string): string | null {
  const parts = name.split("/").filter(Boolean);
  const usersIndex = parts.lastIndexOf("users");
  if (usersIndex < 0 || usersIndex + 1 >= parts.length) return null;
  return parts[usersIndex + 1] ?? null;
}

// ── Note parsing ──────────────────────────────────────────────────────────────

interface NoteDoc {
  title   : string;
  category: string;
  priority: string;
  body    : string;
}

function parseNoteDocs(docs: any[], _uid: string): NoteDoc[] {
  return docs.map((doc) => {
    const f   = doc?.fields ?? {};
    const str = (k: string) => f[k]?.stringValue ?? "";
    return {
      title   : str("title"),
      category: str("category"),
      priority: str("priority"),
      body    : str("clean_body"),
    };
  });
}

function buildDigest(notes: NoteDoc[], name: string, heading: string): string {
  const ranked = [...notes]
    .sort((a, b) => priorityRank(a.priority) - priorityRank(b.priority))
    .slice(0, 5);

  const title = `<b>${escapeHtml(heading)}</b>`;
  const greeting = asciiOnly(name)
    ? `Hello <b>${escapeHtml(asciiOnly(name))}</b>`
    : 'Hello';

  if (ranked.length === 0) {
    return [
      '📋 <b>WishperLog</b>',
      title,
      `<i>${greeting}</i>`,
      '',
      '<i>No active notes right now. You are all caught up.</i>',
    ].join('\n');
  }

  const stats = [
    `${notes.length} note${notes.length === 1 ? "" : "s"}`,
    `${notes.filter((n) => n.priority === "high").length} high`,
    `${notes.filter((n) => n.category === "tasks").length} tasks`,
  ].join(" · ");

  const lines = [
    '📋 <b>WishperLog</b>',
    title,
    `<i>${greeting}</i>`,
    `<i>${escapeHtml(stats)}</i>`,
    '',
    '<b>Top items</b>',
  ];

  ranked.forEach((n) => {
    const category = categoryLabelFromKey(n.category);
    const priority = priorityLabel(n.priority);
    const titleText = escapeHtml(asciiOnly(n.title) || "Untitled note");
    lines.push(`• <b>${category}</b> <code>${priority}</code> ${titleText}`);

    const body = asciiOnly(n.body).slice(0, 140);
    if (body) {
      lines.push(`  <i>${escapeHtml(body)}</i>`);
    }
  });

  if (notes.length > ranked.length) {
    lines.push("", `<i>+${notes.length - ranked.length} more</i>`);
  }

  return lines.join("\n");
}

// ── Main export ───────────────────────────────────────────────────────────────

export default {
  async scheduled(
    _event: ScheduledEvent,
    env: Env,
    ctx: ExecutionContext,
  ): Promise<void> {
    (ctx as any).waitUntil?.(
      runDigestCron(env).catch((e) =>
        console.error('[Cron] runDigestCron failed:', e),
      ),
    );
  },

  async fetch(req: Request, env: Env): Promise<Response> {
    const url = new URL(req.url);

    if (url.pathname === "/trigger" && req.method === "GET") {
      if (req.headers.get("X-Trigger-Secret") !== env.TRIGGER_SECRET) {
        return new Response("Forbidden", { status: 403 });
      }
      await runDigestCron(env);
      return new Response("triggered", { status: 200 });
    }

    if (url.pathname === "/webhook" && req.method === "POST") {
      return handleWebhook(req, env);
    }

    return new Response("WishperLog Worker v3", { status: 200 });
  },
};

// ── Utility ───────────────────────────────────────────────────────────────────

function toSlotKey(d: Date): string {
  return `${pad(d.getUTCHours())}:${pad(d.getUTCMinutes())}`;
}

function toDateKey(d: Date): string {
  return `${d.getUTCFullYear()}-${pad(d.getUTCMonth() + 1)}-${pad(d.getUTCDate())}`;
}

function pad(n: number): string {
  return n.toString().padStart(2, "0");
}

function asciiOnly(v: string): string {
  return (v ?? "")
    .toString()
    .normalize("NFKD")
    .replace(/[^\x00-\x7F]/g, "")
    .replace(/\s+/g, " ")
    .trim();
}

function priorityRank(p: string): number {
  return p === "high" ? 0 : p === "medium" ? 1 : 2;
}

function priorityLabel(p: string): string {
  switch ((p ?? "").toLowerCase()) {
    case "high": return "HIGH";
    case "low":  return "LOW";
    default:     return "MED";
  }
}

function categoryLabelFromKey(key: string): string {
  switch ((key ?? "").toLowerCase()) {
    case "tasks": return "Tasks";
    case "reminders": return "Reminders";
    case "ideas": return "Ideas";
    case "followup":
    case "follow_up":
    case "follow-up": return "Follow-up";
    case "journal": return "Journal";
    default: return "General";
  }
}

function escapeHtml(input: string): string {
  return (input ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#39;");
}