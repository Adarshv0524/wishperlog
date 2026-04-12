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

  const data = (await resp.json()) as { access_token: string };
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

async function runDigestCron(env: Env): Promise<void> {
  const token   = await getFirebaseToken(env);
  const now     = new Date();
  const slotKey = toSlotKey(now);
  const dateKey = toDateKey(now);

  console.log(`[Cron] Running at UTC ${slotKey} on ${dateKey}`);

  const queryUrl =
    `https://firestore.googleapis.com/v1/projects/${env.FIREBASE_PROJECT_ID}/databases/(default)/documents:runQuery`;

  const queryResp = await fetch(queryUrl, {
    method : "POST",
    headers: {
      Authorization : `Bearer ${token}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      structuredQuery: {
        from: [{ collectionId: "users" }],
        select: {
          fields: [
            { fieldPath: "telegram_chat_id" },
            { fieldPath: "digest_times_utc" },
            { fieldPath: "digest_slots" },
            { fieldPath: "digest_time" },
            { fieldPath: "display_name" },
            { fieldPath: "message_state" },
          ],
        },
        where: {
          fieldFilter: {
            field: { fieldPath: "telegram_chat_id" },
            op   : "GREATER_THAN_OR_EQUAL",
            value: { stringValue: "" },
          },
        },
      },
    }),
  });

  if (!queryResp.ok) {
    console.error(`[Cron] collectionGroup query failed: ${queryResp.status}`);
    return;
  }

  const queryResults = (await queryResp.json()) as any[];
  console.log(`[Cron] digest config docs fetched: ${queryResults.length}`);

  let fired = 0;

  for (const result of queryResults) {
    const doc = result?.document;
    if (!doc) continue;

    const docName: string = doc.name ?? "";
    const uid = docName.split("/").pop();
    if (!uid) continue;

    const chatId = extractField(doc, "telegram_chat_id") as string | undefined;
    const name   = (extractField(doc, "display_name") as string | undefined) ?? "there";
    const slots  = [
      ...extractArray(doc, "digest_times_utc"),
      ...extractArray(doc, "digest_slots"),
      ...(extractField(doc, "digest_time") ? [String(extractField(doc, "digest_time"))] : []),
    ].filter((slot) => Boolean(slot.trim()));

    if (!uid || !chatId || !slots.includes(slotKey)) continue;

    let message = "";
    try {
      message = pickTelegramMessage(extractMessageState(doc), "summary");
    } catch (e) {
      console.warn(`[Cron] Failed to read cached digest for ${uid}: ${e}`);
    }

    // Dedup: one digest per slot per day per user.
    const dedupKey = `${dateKey}:${slotKey}:${uid}`;
    const already  = await env.DIGEST_SENT.get(dedupKey);
    if (already) {
      console.log(`[Cron] Already sent to ${uid} at ${slotKey}`);
      continue;
    }

    // Fetch the user's notes from the notes subcollection.
    let notes: NoteDoc[] = [];
    try {
      if (!message) {
        notes = extractDigestNotes(doc);
      }
      if (!message && notes.length === 0) {
        const notesSnap = await firestoreGet(
          `users/${uid}/notes?pageSize=200`,
          token,
          env.FIREBASE_PROJECT_ID,
        );
        notes = parseNoteDocs(((notesSnap as any)?.documents ?? []) as any[], uid);
      }
    } catch (e) {
      console.error(`[Cron] Failed to fetch notes for ${uid}: ${e}`);
      continue;
    }

    if (!message) {
      message = buildDigest(notes, name, "Daily Digest");
    }

    try {
      await sendTelegramMessage(String(chatId), message, env.TELEGRAM_BOT_TOKEN);

      // Mark as sent for 26 hours.
      await env.DIGEST_SENT.put(dedupKey, "1", { expirationTtl: 93_600 });

      // Write a history entry to users/{uid}/digest/history_<ts>
      await writeDigestHistory(uid, "cron_digest", "Daily Digest", notes.length, token, env);

      fired++;
      console.log(`[Cron] Digest sent to ${uid} (${chatId})`);
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
  await handleDigestCommand(chatId, cmd, token, env);

  return new Response("ok");
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
  if (parts.length < 2) return null;
  if (parts[0] !== "users") return null;
  return parts[1] ?? null;
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
    _ctx: ExecutionContext,
  ): Promise<void> {
    await runDigestCron(env);
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