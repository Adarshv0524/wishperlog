const { onSchedule } = require('firebase-functions/v2/scheduler');
const { onRequest } = require('firebase-functions/v2/https');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();

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
  return (note.title || '').toString().trim() || 'Untitled note';
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
    text,
    parse_mode: 'Markdown',
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

  await admin.messaging().send({
    token,
    data: {
      type: 'note_status_changed',
      uid,
      note_id: noteId,
      status,
    },
    android: {
      priority: 'high',
    },
    apns: {
      headers: {
        'apns-priority': '5',
      },
      payload: {
        aps: {
          'content-available': 1,
        },
      },
    },
  });
}

exports.sendDailyDigest = onSchedule(
  {
    schedule: '*/15 * * * *',
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
      const digest = parseDigestTime(user.digest_time);
      const local = localDateForOffset(nowUtc, offsetMinutes);

      const minuteDelta = Math.abs(local.minute - digest.minute);
      if (local.hour !== digest.hour || minuteDelta > 10) {
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
        .where('status', '==', 'active')
        .get();

      const notes = sortPriority(notesSnap.docs.map((doc) => doc.data()));
      if (notes.length === 0) {
        await userDoc.ref.set(
          { last_digest_sent_local_date: local.ymd },
          { merge: true },
        );
        continue;
      }

      const topNotes = notes.slice(0, 8);
      const lines = topNotes.map((note, index) => {
        const icon = note.priority === 'high' ? '🔴' : note.priority === 'medium' ? '🟡' : '⚪';
        return `${index + 1}. ${icon} ${safeTitle(note)}`;
      });

      const text = [
        '*WhisperLog Daily Digest*',
        '',
        ...lines,
      ].join('\n');

      const inlineKeyboard = telegramInlineRows(userDoc.id, topNotes);
      await sendTelegramMessage(chatId, text, { inline_keyboard: inlineKeyboard });

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
      }
    }

    res.status(200).json({ ok: true });
  } catch (error) {
    logger.error('telegramWebhook error', error);
    res.status(500).json({ ok: false });
  }
});
