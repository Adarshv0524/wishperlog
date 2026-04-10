const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onRequest } = require('firebase-functions/v2/https');
const { onDocumentCreated } = require('firebase-functions/v2/firestore');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
const { GoogleGenerativeAI } = require('@google/generative-ai');

admin.initializeApp();

const db = admin.firestore();

// ============================================================================
// AI ENRICHMENT: Enrich pendingAi notes with Gemini API
// ============================================================================

const GEMINI_SYSTEM_PROMPT =
  'You are a personal note classifier. Return JSON with title, category, priority, clean_body, extracted_date. ' +
  'Return ONLY valid JSON with these exact keys: "title", "category", "priority", "clean_body", "extracted_date". ' +
  'Allowed category values: Tasks, Reminders, Ideas, Follow-up, Journal, General. ' +
  'Allowed priority values: high, medium, low. ' +
  'Use null when extracted_date is unknown. No markdown, no extra keys.';

function extractJsonFromResponse(text) {
  if (!text) return null;
  // Try to extract JSON code block
  const codeBlockMatch = text.match(/```(?:json)?\s*\n?([\s\S]*?)\n?```/);
  if (codeBlockMatch && codeBlockMatch[1]) {
    return codeBlockMatch[1].trim();
  }
  // Try to find JSON object in the text
  const jsonMatch = text.match(/\{[\s\S]*\}/);
  if (jsonMatch) {
    return jsonMatch[0];
  }
  return null;
}

function parseExtractedDate(dateValue) {
  if (!dateValue) return null;
  try {
    const parsed = new Date(dateValue);
    if (!isNaN(parsed.getTime())) {
      return parsed.toISOString();
    }
  } catch (_) {
    // Ignore
  }
  return null;
}

function mapCategory(categoryStr) {
  if (!categoryStr) return 'general';
  const normalized = categoryStr.toLowerCase().trim();
  const categoryMap = {
    'tasks': 'tasks',
    'task': 'tasks',
    'reminders': 'reminders',
    'reminder': 'reminders',
    'ideas': 'ideas',
    'idea': 'ideas',
    'follow-up': 'follow-up',
    'followup': 'follow-up',
    'follow_up': 'follow-up',
    'journal': 'journal',
    'journaling': 'journal',
    'general': 'general',
  };
  return categoryMap[normalized] || 'general';
}

function mapPriority(priorityStr) {
  if (!priorityStr) return 'medium';
  const normalized = priorityStr.toLowerCase().trim();
  if (normalized.includes('high')) return 'high';
  if (normalized.includes('low')) return 'low';
  return 'medium';
}

exports.enrichPendingAiNote = onDocumentCreated(
  { document: 'users/{uid}/notes/{noteId}' },
  async (event) => {
    const noteData = event.data.data();
    if (noteData.status !== 'pendingAi') {
      return;
    }

    const uid = event.params.uid;
    const noteId = event.params.noteId;
    const rawTranscript = (noteData.raw_transcript || '').trim();

    if (!rawTranscript) {
      logger.warn(`[enrichPendingAiNote] Empty raw_transcript for note ${noteId}`, { uid });
      return;
    }

    const geminiApiKey = process.env.GEMINI_API_KEY;
    if (!geminiApiKey) {
      logger.warn(`[enrichPendingAiNote] GEMINI_API_KEY not configured; skipping enrichment`);
      return;
    }

    try {
      const genAI = new GoogleGenerativeAI(geminiApiKey);
      const model = genAI.getGenerativeModel({ model: 'gemini-2.5-flash-lite' });

      const response = await model.generateContent([
        { text: GEMINI_SYSTEM_PROMPT },
        { text: `Raw input: ${rawTranscript}` },
      ]);

      const responseText = response.response.text();
      if (!responseText) {
        logger.warn(`[enrichPendingAiNote] Empty response from Gemini for note ${noteId}`);
        return;
      }

      const jsonStr = extractJsonFromResponse(responseText);
      if (!jsonStr) {
        logger.warn(`[enrichPendingAiNote] Could not extract JSON from Gemini response for note ${noteId}`);
        return;
      }

      const enriched = JSON.parse(jsonStr);
      const enrichedTitle = (enriched.title || '').trim() || rawTranscript.substring(0, 100).trim();
      const enrichedCleanBody = (enriched.clean_body || '').trim() || rawTranscript.trim();
      const enrichedCategory = mapCategory(enriched.category);
      const enrichedPriority = mapPriority(enriched.priority);
      const enrichedExtractedDate = parseExtractedDate(enriched.extracted_date);

      const now = new Date().toISOString();
      const updatePayload = {
        title: enrichedTitle,
        clean_body: enrichedCleanBody,
        category: enrichedCategory,
        priority: enrichedPriority,
        extracted_date: enrichedExtractedDate || null,
        ai_model: 'gemini-2.5-flash-lite',
        status: 'active',
        updated_at: now,
        synced_at: now,
      };

      await db
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(noteId)
        .update(updatePayload);

      logger.info(
        `[enrichPendingAiNote] Successfully enriched note ${noteId} for user ${uid}`,
        { enriched: JSON.stringify(updatePayload) },
      );
    } catch (error) {
      logger.error(`[enrichPendingAiNote] Error enriching note ${noteId} for user ${uid}:`, error);
      // Don't update the note; let client retry or manual processing handle it
    }
  },
);

function parseDigestTime(raw) {
  if (!raw || typeof raw !== 'string') {
    return { hour: 9, minute: 0 };
  }

  const value = raw.trim().toUpperCase();
  const match12 = value.match(/^(\d{1,2}):(\d{2})\s*(AM|PM)$/);
  if (match12) {
    let hour = Number(match12[1]);
    const minute = Number(match12[2]);
    const meridiem = match12[3];
    if (hour === 12) {
      hour = 0;
    }
    if (meridiem === 'PM') {
      hour += 12;
    }
    return { hour, minute };
  }

  const match24 = value.match(/^(\d{1,2}):(\d{2})$/);
  if (match24) {
    return {
      hour: Number(match24[1]),
      minute: Number(match24[2]),
    };
  }

  return { hour: 9, minute: 0 };
}

function parseDigestTimes(rawTimes, rawSingle) {
  const parsed = [];
  const seen = new Set();
  const values = Array.isArray(rawTimes) && rawTimes.length > 0
    ? rawTimes
    : [rawSingle];

  for (const value of values) {
    const slot = parseDigestTime(value);
    const key = `${slot.hour}:${slot.minute}`;
    if (seen.has(key)) {
      continue;
    }
    seen.add(key);
    parsed.push(slot);
  }

  return parsed.length > 0 ? parsed : [{ hour: 9, minute: 0 }];
}

function localDateForOffset(nowUtc, offsetMinutes) {
  const shifted = new Date(nowUtc.getTime() + offsetMinutes * 60 * 1000);
  const y = shifted.getUTCFullYear();
  const m = String(shifted.getUTCMonth() + 1).padStart(2, '0');
  const d = String(shifted.getUTCDate()).padStart(2, '0');
  const hour = shifted.getUTCHours();
  const minute = shifted.getUTCMinutes();
  return {
    ymd: `${y}-${m}-${d}`,
    hour,
    minute,
  };
}

function sortPriority(notes) {
  const weight = { high: 0, medium: 1, low: 2 };
  return [...notes].sort((a, b) => {
    const aw = weight[a.priority] ?? 9;
    const bw = weight[b.priority] ?? 9;
    if (aw !== bw) {
      return aw - bw;
    }
    return (a.updated_at || '').localeCompare(b.updated_at || '') * -1;
  });
}

function safeTitle(note) {
function asciiOnly(value) {
  return (value ?? '')
    .toString()
    .normalize('NFKD')
    .replace(/[^\x00-\x7F]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

  return (note.title || '').toString().trim() || 'Untitled note';
  return asciiOnly((note.title || '').toString().trim() || 'Untitled note');
}

function normalizeCategoryKey(value) {
  const normalized = asciiOnly(value).toLowerCase();
  switch (normalized) {
    case 'task':
    case 'tasks':
    case 'todo':
    case 'to-do':
      return 'tasks';
    case 'reminder':
    case 'reminders':
      return 'reminders';
    case 'idea':
    case 'ideas':
      return 'ideas';
    case 'followup':
    case 'follow-up':
    case 'follow_up':
      return 'follow-up';
    case 'journal':
      return 'journal';
    case 'general':
      return 'general';
    default:
      return normalized;
  }
}

function categoryLabel(category) {
  switch (normalizeCategoryKey(category)) {
    case 'tasks':
      return 'Tasks';
    case 'reminders':
      return 'Reminders';
    case 'ideas':
      return 'Ideas';
    case 'follow-up':
      return 'Follow-up';
    case 'journal':
      return 'Journal';
    default:
      return 'General';
  }
}

function priorityLabel(priority) {
  switch ((priority || '').toString().toLowerCase()) {
    case 'high':
      return 'HIGH';
    case 'low':
      return 'LOW';
    default:
      return 'MED';
  }
}

function isActiveNote(note) {
  return (note.status || 'active') === 'active' && note.is_deleted !== true;
}

function getNoteCategory(note) {
  return normalizeCategoryKey(note.category || 'general');
}

function filterNotesByCategory(notes, category) {
  const key = normalizeCategoryKey(category);
  if (key === 'general' || key === 'summary' || key === 'all') {
    return notes;
  }
  return notes.filter((note) => getNoteCategory(note) === key);
}

function formatNoteLine(note, index) {
  return `${index + 1}. [${categoryLabel(note.category)}][${priorityLabel(note.priority)}] ${safeTitle(note)}`;
}

function buildNoteSummaryText(notes, heading, name, now, categoryFilter) {
  const filtered = categoryFilter ? filterNotesByCategory(notes, categoryFilter) : notes;
  const topNotes = sortPriority(filtered).slice(0, 3);
  const counts = filtered.reduce((acc, note) => {
    const key = getNoteCategory(note);
    acc[key] = (acc[key] || 0) + 1;
    return acc;
  }, {});

  const lines = [
    `${heading} for ${asciiOnly(name || 'there')}`,
    `Generated ${now.toISOString().replace('T', ' ').slice(0, 16)} UTC`,
    '',
    `Active notes: ${filtered.length}`,
    `Tasks: ${counts.tasks || 0}`,
    `Reminders: ${counts.reminders || 0}`,
    `Ideas: ${counts.ideas || 0}`,
    `Follow-up: ${counts['follow-up'] || 0}`,
    `Journal: ${counts.journal || 0}`,
    '',
    topNotes.length > 0 ? 'Top 3:' : 'No active notes found.',
  ];

  topNotes.forEach((note, index) => {
    lines.push(formatNoteLine(note, index));
  });

  lines.push('', 'Use /summary, /task, /reminder, /idea, /followup, /journal, or /all.');
  return asciiOnly(lines.join('\n'));
}

function buildHelpText() {
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

function parseTelegramCommand(text) {
  const firstToken = asciiOnly(text).split(/\s+/)[0] || '';
  const command = firstToken.replace(/^\//, '').split('@')[0].toLowerCase();
  return command;
}

async function getUserByChatId(chatId) {
  const snap = await db
    .collection('users')
    .where('telegram_chat_id', '==', String(chatId))
    .limit(1)
    .get();

  if (snap.empty) {
    return null;
  }

  const doc = snap.docs[0];
  const data = doc.data() || {};
  return {
    uid: doc.id,
    displayName: asciiOnly(data.display_name || data.displayName || 'there'),
  };
}

async function getUserNotes(uid) {
  const snap = await db
    .collection('users')
    .doc(uid)
    .collection('notes')
    .get();

  return snap.docs
    .map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }))
    .filter(isActiveNote);
}

async function handleTelegramCommand(chatId, text, now) {
  const command = parseTelegramCommand(text);

  if (!command) {
    return;
  }

  if (command === 'help') {
    await sendTelegramMessage(chatId, buildHelpText());
    return;
  }

  if (command === 'start') {
    await sendTelegramMessage(chatId, buildHelpText());
    return;
  }

  const linkedUser = await getUserByChatId(chatId);
  if (!linkedUser) {
    await sendTelegramMessage(
      chatId,
      'Link your WishperLog account first with /start uid_<your_uid>, then use /summary or /task.',
    );
    return;
  }

  const notes = await getUserNotes(linkedUser.uid);
  const heading = command === 'summary' || command === 'all' ? 'Summary' : `${categoryLabel(command)} summary`;

  switch (command) {
    case 'summary':
    case 'all':
      await sendTelegramMessage(
        chatId,
        buildNoteSummaryText(notes, heading, linkedUser.displayName, now, null),
        sortPriority(notes).slice(0, 3).length > 0
          ? { inline_keyboard: telegramInlineRows(linkedUser.uid, sortPriority(notes).slice(0, 3)) }
          : undefined,
      );
      return;
    case 'task':
    case 'tasks':
    case 'todo':
    case 'to-do':
      await sendTelegramMessage(
        chatId,
        buildNoteSummaryText(notes, heading, linkedUser.displayName, now, 'tasks'),
        sortPriority(filterNotesByCategory(notes, 'tasks')).slice(0, 3).length > 0
          ? { inline_keyboard: telegramInlineRows(linkedUser.uid, sortPriority(filterNotesByCategory(notes, 'tasks')).slice(0, 3)) }
          : undefined,
      );
      return;
    case 'reminder':
    case 'reminders':
      await sendTelegramMessage(
        chatId,
        buildNoteSummaryText(notes, heading, linkedUser.displayName, now, 'reminders'),
        sortPriority(filterNotesByCategory(notes, 'reminders')).slice(0, 3).length > 0
          ? { inline_keyboard: telegramInlineRows(linkedUser.uid, sortPriority(filterNotesByCategory(notes, 'reminders')).slice(0, 3)) }
          : undefined,
      );
      return;
    case 'idea':
    case 'ideas':
      await sendTelegramMessage(
        chatId,
        buildNoteSummaryText(notes, heading, linkedUser.displayName, now, 'ideas'),
        sortPriority(filterNotesByCategory(notes, 'ideas')).slice(0, 3).length > 0
          ? { inline_keyboard: telegramInlineRows(linkedUser.uid, sortPriority(filterNotesByCategory(notes, 'ideas')).slice(0, 3)) }
          : undefined,
      );
      return;
    case 'followup':
    case 'follow-up':
    case 'follow_up':
      await sendTelegramMessage(
        chatId,
        buildNoteSummaryText(notes, heading, linkedUser.displayName, now, 'follow-up'),
        sortPriority(filterNotesByCategory(notes, 'follow-up')).slice(0, 3).length > 0
          ? { inline_keyboard: telegramInlineRows(linkedUser.uid, sortPriority(filterNotesByCategory(notes, 'follow-up')).slice(0, 3)) }
          : undefined,
      );
      return;
    case 'journal':
      await sendTelegramMessage(
        chatId,
        buildNoteSummaryText(notes, heading, linkedUser.displayName, now, 'journal'),
        sortPriority(filterNotesByCategory(notes, 'journal')).slice(0, 3).length > 0
          ? { inline_keyboard: telegramInlineRows(linkedUser.uid, sortPriority(filterNotesByCategory(notes, 'journal')).slice(0, 3)) }
          : undefined,
      );
      return;
    default:
      await sendTelegramMessage(chatId, buildHelpText());
      return;
  }
}

function telegramInlineRows(uid, notes) {
  return notes.slice(0, 8).map((note) => {
    const noteId = note.note_id || note.id;
    const doneData = `done|${uid}|${noteId}`;
    const archiveData = `archive|${uid}|${noteId}`;
    return [
      { text: `Done: ${safeTitle(note).slice(0, 24)}`, callback_data: doneData },
      { text: 'Archive', callback_data: archiveData },
    ];
  });
}

async function sendTelegramMessage(chatId, text, replyMarkup) {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  if (!token) {
    logger.warn('TELEGRAM_BOT_TOKEN is not configured');
    return;
  }

  const endpoint = `https://api.telegram.org/bot${token}/sendMessage`;
  const payload = {
    chat_id: chatId,
    text: asciiOnly(text),
    disable_web_page_preview: true,
    reply_markup: replyMarkup,
  };

  const response = await fetch(endpoint, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });

  if (!response.ok) {
    const body = await response.text();
    logger.error('Telegram sendMessage failed', {
      status: response.status,
      body,
    });
  }
}

async function answerTelegramCallback(callbackId, text) {
  const token = process.env.TELEGRAM_BOT_TOKEN;
  if (!token || !callbackId) {
    return;
  }
  const endpoint = `https://api.telegram.org/bot${token}/answerCallbackQuery`;
  await fetch(endpoint, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      callback_query_id: callbackId,
      text,
      show_alert: false,
    }),
  });
}

async function sendSilentFcm({ token, uid, noteId, status }) {
  if (!token) {
    return;
  }

  const title = 'WishperLog update';
  const body = status === 'done'
    ? 'A note was marked done.'
    : status === 'archived'
      ? 'A note was archived.'
      : 'Your notes were updated.';

  await admin.messaging().send({
    token,
    notification: {
      title,
      body,
    },
    data: {
      type: 'note_status_changed',
      uid,
      note_id: noteId,
      status,
      title,
      body,
    },
    android: {
      priority: 'high',
      notification: {
        title,
        body,
      },
    },
    apns: {
      headers: {
        'apns-priority': '10',
      },
      payload: {
        aps: {
          alert: {
            title,
            body,
          },
          sound: 'default',
        },
      },
    },
  });
}

exports.sendDailyDigest = onSchedule(
  {
    schedule: '* * * * *',
    timeZone: 'UTC',
    region: 'us-central1',
  },
  async () => {
    const nowUtc = new Date();
    const users = await db.collection('users').get();

    for (const userDoc of users.docs) {
      const user = userDoc.data() || {};
      const chatId = user.telegram_chat_id;
      if (!chatId) {
        continue;
      }

      const offsetMinutes = Number(user.timezone_offset_minutes ?? 0);
      const local = localDateForOffset(nowUtc, offsetMinutes);
      const digestTimes = parseDigestTimes(user.digest_times, user.digest_time);

      const matchesCurrentMinute = digestTimes.some(
        (digest) => local.hour === digest.hour && local.minute === digest.minute,
      );
      if (!matchesCurrentMinute) {
        continue;
      }

      const alreadySentForDate = user.last_digest_sent_local_date;
      if (alreadySentForDate === local.ymd) {
        continue;
      }

      const notesSnap = await db
        .collection('users')
        .doc(userDoc.id)
        .collection('notes')
        .get();

      const notes = sortPriority(notesSnap.docs.map((doc) => ({ id: doc.id, ...doc.data() })).filter(isActiveNote));
      if (notes.length === 0) {
        await userDoc.ref.set(
          { last_digest_sent_local_date: local.ymd },
          { merge: true },
        );
        continue;
      }

      const topNotes = notes.slice(0, 3);
      const text = buildNoteSummaryText(notes, 'Daily summary', user.display_name || 'there', nowUtc, null);
      const inlineKeyboard = topNotes.length > 0 ? { inline_keyboard: telegramInlineRows(userDoc.id, topNotes) } : undefined;
      await sendTelegramMessage(chatId, text, inlineKeyboard);

      await userDoc.ref.set(
        { last_digest_sent_local_date: local.ymd },
        { merge: true },
      );
    }

    return null;
  },
);

exports.telegramWebhook = onRequest({ region: 'us-central1' }, async (req, res) => {
  try {
    const body = req.body || {};

    const callback = body.callback_query;
    if (callback) {
      const callbackData = (callback.data || '').toString();
      const [action, uid, noteId] = callbackData.split('|');

      if (!uid || !noteId) {
        await answerTelegramCallback(callback.id, 'Invalid action payload');
        res.status(200).json({ ok: true, ignored: true });
        return;
      }

      await db
        .collection('users')
        .doc(uid)
        .collection('notes')
        .doc(noteId)
        .set(
          {
            status: 'archived',
            updated_at: new Date().toISOString(),
          },
          { merge: true },
        );

      const userDoc = await db.collection('users').doc(uid).get();
      const user = userDoc.data() || {};
      await sendSilentFcm({
        token: user.fcm_token,
        uid,
        noteId,
        status: 'archived',
      });

      await answerTelegramCallback(
        callback.id,
        action === 'done' ? 'Marked done' : 'Archived',
      );

      res.status(200).json({ ok: true });
      return;
    }

    const message = body.message;
    const chatId = message?.chat?.id;
    const text = (message?.text || '').toString();
    const startMatch = text.match(/^\/start\s+uid_(.+)$/i);

    if (chatId && startMatch) {
      const uid = startMatch[1].trim();
      if (uid) {
        await db.collection('users').doc(uid).set(
          {
            telegram_chat_id: String(chatId),
          },
          { merge: true },
        );

        await sendTelegramMessage(
          chatId,
          'WishperLog linked. Use /summary, /task, /reminder, /idea, /followup, /journal, or /all.',
        );
        res.status(200).json({ ok: true, linked: true });
        return;
      }
    }

    if (chatId && text && text.startsWith('/')) {
      await handleTelegramCommand(chatId, text, new Date());
      res.status(200).json({ ok: true, command: true });
      return;
    }

    res.status(200).json({ ok: true });
  } catch (error) {
    logger.error('telegramWebhook error', error);
    res.status(500).json({ ok: false });
  }
});
