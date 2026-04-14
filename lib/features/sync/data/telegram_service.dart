// lib/features/sync/data/telegram_service.dart
//
// v2.0 — Digest Collection Architecture + Dual-Method Linking
//
// Changes from v1:
//   • writeDigestConfig()   — updates the root user schedule fields.
//   • addQueryHistory()     — writes bot command records to
//                             users/{uid}/digest/history_{timestamp}.
//   • linkManualChatId()    — validates and saves a raw chat_id pasted by
//                             the user, enabling the secondary fallback method.
//   • All existing methods preserved and unchanged.

import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class TelegramService {
  TelegramService._();
  static final TelegramService instance = TelegramService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth     _auth      = FirebaseAuth.instance;

  static const String _fallbackBotUsername = 'WishperLogDigestBot';

  String? _lastLinkToken;

  String? get lastLinkToken => _lastLinkToken;
  String? get lastLinkPin   => _lastLinkToken;

  // ── Auth guard ──────────────────────────────────────────────────────────────

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User not authenticated');
    return user.uid;
  }

  // ── Firestore references ────────────────────────────────────────────────────

  /// Root user document: users/{uid}
  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _firestore.collection('users').doc(_uid);

  // ── Bot username helpers ────────────────────────────────────────────────────

  Future<String> _botUsername() async {
    final configured = AppEnv.telegramBotUsername.trim();
    if (configured.isNotEmpty) {
      return configured.replaceFirst(RegExp(r'^@+'), '');
    }
    return _fallbackBotUsername;
  }

  // ── Token generation ────────────────────────────────────────────────────────

  String _buildLinkToken() {
    const alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = math.Random.secure();
    return List.generate(
      10,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }

  // ── URI builders ────────────────────────────────────────────────────────────

  Future<Uri> buildTelegramStartUri(String token) async {
    final deepLinkBase = AppEnv.telegramDeepLinkBase.trim();
    if (deepLinkBase.isNotEmpty) {
      return Uri.parse('$deepLinkBase$token');
    }
    final botUsername = await _botUsername();
    return Uri.https('t.me', '/$botUsername', {'start': token});
  }

  Future<Uri> buildTelegramBotUri() async {
    final botUsername = await _botUsername();
    return Uri.https('t.me', '/$botUsername');
  }

  // ── Primary auto-link flow ──────────────────────────────────────────────────

  /// Creates a one-time link token, writes it to the user root doc, and
  /// returns the token. The bot later POSTs the user's chat_id back to
  /// Firestore when the user sends `/start token`.
  Future<String> createTelegramConnectionToken() async {
    final token = _buildLinkToken();
    _lastLinkToken = token;

    await _userDoc.set({
      'telegram_link_token': token,
      'telegram_link_pin': token,
      'telegram_link_token_created_at': FieldValue.serverTimestamp(),
      'telegram_link_pin_created_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return token;
  }

  /// Alias kept for backward-compatibility with older callers.
  Future<String> generateLinkPin() => createTelegramConnectionToken();

  /// Clears any pending link token (cleanup after successful or abandoned link).
  Future<void> clearTelegramConnectionToken() async {
    _lastLinkToken = null;
    try {
      await _userDoc.update({
        'telegram_link_token': FieldValue.delete(),
        'telegram_link_token_created_at': FieldValue.delete(),
        'telegram_link_pin': FieldValue.delete(),
        'telegram_link_pin_created_at': FieldValue.delete(),
      });
    } catch (_) {}
  }

  Future<void> clearLinkPin() => clearTelegramConnectionToken();

  /// Primary connect: generates a token, builds the deep-link URI, and opens
  /// Telegram so the user can tap START in one motion.
  Future<String> connectTelegramAuto({String? existingToken}) async {
    final token = existingToken ?? await createTelegramConnectionToken();
    try {
      await openTelegramBot(startToken: token);
      return token;
    } catch (_) {
      if (existingToken == null) await clearTelegramConnectionToken();
      rethrow;
    }
  }

  Future<void> openTelegramBot({String? startToken}) async {
    final uri = startToken == null
        ? await buildTelegramBotUri()
        : await buildTelegramStartUri(startToken);

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) throw StateError('Could not open Telegram');
  }

  // ── Secondary manual-link flow ──────────────────────────────────────────────

  /// Validates and saves a chat_id that the user copied from the bot manually.
  ///
  /// Telegram chat_ids for private chats are numeric (positive or negative).
  /// This method validates the format, writes to the user doc, and returns
  /// the normalised chat_id string.
  ///
  /// Throws [ArgumentError] if [rawChatId] is not a valid Telegram chat id.
  Future<String> linkManualChatId(String rawChatId) async {
    final trimmed = rawChatId.trim();

    // Basic validation: must be a non-empty integer string.
    final parsed = int.tryParse(trimmed);
    if (parsed == null || trimmed.isEmpty) {
      throw ArgumentError(
        'Invalid chat ID. It should be a number — copy it directly from the bot.',
      );
    }

    final chatIdStr = trimmed;

    await _userDoc.set({
      'telegram_chat_id': chatIdStr,
      // Clear any pending token since the user linked manually.
      'telegram_link_token': FieldValue.delete(),
      'telegram_link_token_created_at': FieldValue.delete(),
      'telegram_link_pin': FieldValue.delete(),
      'telegram_link_pin_created_at': FieldValue.delete(),
    }, SetOptions(merge: true));

    _lastLinkToken = null;
    return chatIdStr;
  }

  // ── Chat-id readers ─────────────────────────────────────────────────────────

  Future<String?> getLinkedChatId() async {
    final doc    = await _userDoc.get();
    final chatId = (doc.data()?['telegram_chat_id'] ?? '').toString().trim();
    return chatId.isEmpty ? null : chatId;
  }

  Stream<String?> watchLinkedChatId() {
    return _userDoc.snapshots().map((snap) {
      final chatId = (snap.data()?['telegram_chat_id'] ?? '').toString().trim();
      return chatId.isEmpty ? null : chatId;
    });
  }

  // ── Disconnect ──────────────────────────────────────────────────────────────

  Future<void> disconnectTelegram() async {
    _lastLinkToken = null;

    // Wipe all Telegram config from the root user doc, including any
    // residual telegram_* fields written by the old permission-denied fallback.
    await _userDoc.set({
      'telegram_chat_id'               : FieldValue.delete(),
      'telegram_link_token'            : FieldValue.delete(),
      'telegram_link_token_created_at' : FieldValue.delete(),
      'telegram_link_pin'              : FieldValue.delete(),
      'telegram_link_pin_created_at'   : FieldValue.delete(),
      'message_state'                  : FieldValue.delete(),
      // Legacy root-level telegram_* fields (from permission-denied fallback):
      'telegram_digest'                : FieldValue.delete(),
      'telegram_summary'               : FieldValue.delete(),
      'telegram_top'                   : FieldValue.delete(),
      'telegram_tasks'                 : FieldValue.delete(),
      'telegram_reminders'             : FieldValue.delete(),
      'telegram_ideas'                 : FieldValue.delete(),
      'telegram_followup'              : FieldValue.delete(),
      'telegram_journal'               : FieldValue.delete(),
      'telegram_general'               : FieldValue.delete(),
    }, SetOptions(merge: true));

    // Delete the digest subcollection docs (best-effort, non-fatal).
    try {
      final uid = _uid;
      await _firestore
          .collection('users').doc(uid)
          .collection('digest').doc('latest')
          .delete();
      await _firestore
          .collection('users').doc(uid)
          .collection('digest').doc('config')
          .delete();
    } catch (_) {}
  }

  // ── Digest Collection API ───────────────────────────────────────────────────

  /// Writes the digest scheduling configuration to the root user document.
  ///
  /// [utcSlots] — list of "HH:MM" strings in UTC.
  /// [localSlots] — list of "HH:MM" strings in the user's local time.
  Future<void> writeDigestConfig({
    required List<String> utcSlots,
    required List<String> localSlots,
  }) async {
    final uid  = _uid;
    final user = _auth.currentUser;

    // Persist schedule on the root user doc, which is the canonical source
    // for both the app and the Worker.
    final userSnap = await _userDoc.get();
    final chatId = (userSnap.data()?['telegram_chat_id'] ?? '').toString().trim();
    final displayName = user?.displayName ?? (userSnap.data()?['display_name'] ?? '');

    await _userDoc.set({
      'uid'                  : uid,
      'display_name'         : displayName,
      'telegram_chat_id'     : chatId.isEmpty ? null : chatId,
      'digest_time'          : localSlots.isNotEmpty ? localSlots.first : null,
      'digest_times'         : localSlots,
      'digest_times_utc'     : utcSlots,
      'digest_slots'         : localSlots,
      'timezone_offset_minutes': DateTime.now().timeZoneOffset.inMinutes,
      'updated_at'           : FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Records a bot query to `users/{uid}/digest/history_<timestamp>`.
  ///
  /// Called by the Worker via the webhook handler after serving a command so
  /// history is visible to the app for future "digest history" UI features.
  Future<void> addQueryHistory({
    required String command,
    required String responseHeading,
    int noteCount = 0,
  }) async {
    final now = DateTime.now().toUtc();
    final docId = 'history_${now.millisecondsSinceEpoch}';

    await _userDoc.collection('digest').doc(docId).set({
      'command'         : command,
      'response_heading': responseHeading,
      'note_count'      : noteCount,
      'queried_at'      : FieldValue.serverTimestamp(),
    });
  }

  // ── Digest slot persistence ─────────────────────────────────────────────────

  /// Saves digest slots to both the legacy user root doc and the new
  /// root digest fields so both the app and the Worker stay in sync.
  Future<void> saveDigestSlots(List<String> slots) async {
    await _userDoc.set(
      {
        'digest_times_utc': slots,
        'digest_times': slots,
        'digest_slots': slots,
        'updated_at': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  Future<List<String>> getDigestSlots() async {
    final doc = await _userDoc.get();
    final raw = doc.data()?['digest_slots'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return [];
  }

  // ── Bot username resolution ─────────────────────────────────────────────────

  bool get isConfigured => true;

  Future<String?> resolveBotUsername() async {
    final username = await _botUsername();
    return username.trim().isEmpty ? null : username;
  }

  Future<String?> resolveChatIdByStartToken({required String token}) async {
    final tokenValue = token.trim();
    if (tokenValue.isEmpty) return null;

    final query = await _firestore
        .collection('users')
        .where('telegram_link_token', isEqualTo: tokenValue)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      final chatId =
          (query.docs.first.data()['telegram_chat_id'] ?? '').toString().trim();
      if (chatId.isNotEmpty) return chatId;
    }

    // Legacy pin fallback
    final legacyQuery = await _firestore
        .collection('users')
        .where('telegram_link_pin', isEqualTo: tokenValue)
        .limit(1)
        .get();

    if (legacyQuery.docs.isEmpty) return null;
    final chatId =
        (legacyQuery.docs.first.data()['telegram_chat_id'] ?? '').toString().trim();
    return chatId.isEmpty ? null : chatId;
  }

  Future<void> sendConnectionConfirmation({required String chatId}) async {
    if (chatId.trim().isEmpty) return;
  }

  Future<void> registerDefaultCommands() async {}

  // ── Daily digest message builder ────────────────────────────────────────────

  static String staticBuildDailyDigest({
    required List<Note> notes,
    required DateTime localDate,
    int maxItems = 5,
    bool topPriorityOnly = true,
    bool includeMediumFallback = true,
  }) {
    final active = notes
        .where((n) =>
            n.status != NoteStatus.archived && n.status != NoteStatus.deleted)
        .toList();

    active.sort((a, b) {
      final pa = _priorityRank(a.priority.name);
      final pb = _priorityRank(b.priority.name);
      if (pa != pb) return pa.compareTo(pb);
      return b.updatedAt.compareTo(a.updatedAt);
    });

    final picked = active.take(maxItems).toList();
    final buffer = StringBuffer();

    buffer.writeln('<b>WishperLog Daily Digest</b>');
    buffer.writeln('<i>${localDate.toLocal().toIso8601String()}</i>');
    buffer.writeln();

    if (picked.isEmpty) {
      buffer.writeln('No active notes.');
      return buffer.toString().trim();
    }

    for (final note in picked) {
      final title    = _ascii(note.title.isEmpty ? 'Untitled' : note.title);
      final category = note.category.name.toUpperCase();
      final priority = _priorityLabel(note.priority.name);
      final body     = _ascii(note.cleanBody);

      buffer.writeln('• [$category][$priority] $title');
      if (body.isNotEmpty) {
        buffer.writeln(
          '  <i>${body.length > 120 ? '${body.substring(0, 120)}…' : body}</i>',
        );
      }
    }

    return buffer.toString().trim();
  }

  static int _priorityRank(String p) =>
      p == 'high' ? 0 : p == 'medium' ? 1 : 2;

  static String _priorityLabel(String p) {
    switch (p.toLowerCase()) {
      case 'high': return 'HIGH';
      case 'low':  return 'LOW';
      default:     return 'MED';
    }
  }

  static String _ascii(String v) => (v)
      .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}