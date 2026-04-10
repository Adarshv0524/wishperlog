import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/sync/data/telegram_service.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/user.dart';
import 'package:wishperlog/shared/models/enums.dart'; // Added for NoteStatus

/// Computes per-channel digest payloads from the current note set and
/// persists them into `users/{uid}/message_state` in Firestore.
///
/// **Source of Truth contract:**
///   - Called after every note create / update / AI-classification.
///   - The Cloudflare Worker reads `message_state.telegram` and sends it
///     without any further calculation.
///   - Adding WhatsApp / Email requires only implementing the
///     `_buildWhatsapp` / `_buildEmail` methods below.
class MessageStateService {
  MessageStateService({
    FirebaseAuth?    auth,
    FirebaseFirestore? firestore,
    IsarNoteStore?   isarNoteStore,
  })  : _auth          = auth          ?? FirebaseAuth.instance,
        _firestore     = firestore     ?? FirebaseFirestore.instance,
        _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance;

  final FirebaseAuth     _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore    _isarNoteStore;

  // ── Public entry-point ─────────────────────────────────────────────────────

  /// Recompute all channel payloads for the current user and persist them.
  /// Safe to call from any isolate that has Firebase initialised.
  /// [uid] is optional — falls back to `FirebaseAuth.instance.currentUser`.
  Future<void> recompute({String? uid}) async {
    final resolvedUid = uid ?? _auth.currentUser?.uid;
    if (resolvedUid == null || resolvedUid.trim().isEmpty) {
      debugPrint('[MessageStateService] skipped — no authenticated user');
      return;
    }

    try {
      final notes = await _fetchActiveNotes(resolvedUid);
      final telegram = _buildTelegram(notes);

      // ── Extend here for additional channels ───────────────────────────────
      // final whatsapp = _buildWhatsapp(notes);
      // final email    = _buildEmail(notes);

      final state = MessageState(
        telegram:   telegram,
        computedAt: DateTime.now().toUtc(),
      );

      await _persist(resolvedUid, state);
      debugPrint(
        '[MessageStateService] recomputed for $resolvedUid '
        '(telegram ${telegram?.length ?? 0} chars)',
      );
    } catch (e, st) {
      debugPrint('[MessageStateService] recompute error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  // ── Firestore fetch ────────────────────────────────────────────────────────

  Future<List<Note>> _fetchActiveNotes(String uid) async {
    // Prefer local Isar (fast, offline) — fall back to Firestore.
    try {
      final local = await _isarNoteStore.getAllNotes();
      final active = local
          .where((n) =>
              n.uid == uid &&
              n.status == NoteStatus.active)
          .toList();
      if (active.isNotEmpty) return active;
    } catch (_) {}

    // Firestore fallback
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('notes')
        .where('status', isEqualTo: 'active')
        .get();

    return snap.docs
        .map((d) {
          try {
            return Note.fromFirestoreJson(d.data(), uid: uid, noteId: d.id);
          } catch (_) {
            return null;
          }
        })
        .whereType<Note>()
        .toList();
  }

  // ── Channel builders ───────────────────────────────────────────────────────

  /// Builds the Telegram HTML string using the same logic as TelegramService.
  /// Returns null when there are no active notes (Worker will skip send).
  String? _buildTelegram(List<Note> notes) {
    if (notes.isEmpty) return null;

    final now = DateTime.now().toUtc();
    // Reuse the existing rich formatter from TelegramService (pure function).
    return TelegramService.staticBuildDailyDigest(
      notes:   notes,
      localDate: now,
      maxItems: 5,
      topPriorityOnly: true,
      includeMediumFallback: true,
    );
  }

  // Stub: add WhatsApp plain-text builder here.
  // String? _buildWhatsapp(List<Note> notes) { ... }

  // Stub: add Email HTML builder here.
  // String? _buildEmail(List<Note> notes) { ... }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _persist(String uid, MessageState state) async {
    await _firestore
        .collection('users')
        .doc(uid)
        .set({'message_state': state.toJson()}, SetOptions(merge: true));
  }
}