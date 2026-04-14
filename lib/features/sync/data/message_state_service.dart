import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class MessageStateService {
  MessageStateService._({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance;

  static final MessageStateService instance = MessageStateService._();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore _isarNoteStore;
  Timer? _recomputeTimer;
  String? _queuedUid;
  bool _recomputeRunning = false;

  Future<void> rebuildDigest(List<Note> activeNotes, {String? uid}) async {
    final resolvedUid = uid ?? _auth.currentUser?.uid;
    if (resolvedUid == null || resolvedUid.trim().isEmpty) {
      debugPrint('[MessageStateService] skipped — no authenticated user');
      return;
    }

    try {
      final userDoc = await _firestore.collection('users').doc(resolvedUid).get();
      final displayName = (userDoc.data()?['display_name'] as String?)?.trim();
      final messages = _buildTelegramMessages(
        activeNotes,
        displayName: displayName,
      );

      await _persist(
        resolvedUid,
        messages,
        activeNotes,
        displayName: displayName,
      );
      debugPrint(
        '[MessageStateService] rebuilt for $resolvedUid '
        '(telegram ${messages['telegram']?.length ?? 0} chars)',
      );
    } catch (e, st) {
      debugPrint('[MessageStateService] rebuild error: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> recompute({String? uid}) async {
    final resolvedUid = uid ?? _auth.currentUser?.uid;
    if (resolvedUid == null || resolvedUid.trim().isEmpty) {
      debugPrint('[MessageStateService] skipped — no authenticated user');
      return;
    }

    _queuedUid = resolvedUid;
    _recomputeTimer?.cancel();
    _recomputeTimer = Timer(const Duration(milliseconds: 250), () {
      _recomputeTimer = null;
      unawaited(_runQueuedRecompute());
    });
  }

  Future<void> _runQueuedRecompute() async {
    if (_recomputeRunning) return;
    final resolvedUid = _queuedUid;
    if (resolvedUid == null || resolvedUid.trim().isEmpty) return;

    _queuedUid = null;
    _recomputeRunning = true;
    try {
      final notes = await _fetchActiveNotes(resolvedUid);
      await rebuildDigest(notes, uid: resolvedUid);
    } catch (e, st) {
      debugPrint('[MessageStateService] recompute error: $e');
      debugPrintStack(stackTrace: st);
    } finally {
      _recomputeRunning = false;
      if (_queuedUid != null && _recomputeTimer == null) {
        _recomputeTimer = Timer(const Duration(milliseconds: 16), () {
          _recomputeTimer = null;
          unawaited(_runQueuedRecompute());
        });
      }
    }
  }

  Future<List<Note>> _fetchActiveNotes(String uid) async {
    try {
      final local = await _isarNoteStore.getAllActive();
      final active = local.where((n) => n.uid == uid).toList();
      if (active.isNotEmpty) return active;
    } catch (_) {}

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
        .where((n) => n.status == NoteStatus.active)
        .toList();
  }

  Map<String, String> _buildTelegramMessages(
    List<Note> notes, {
    String? displayName,
  }) {
    final active = notes
        .where((n) => n.status == NoteStatus.active)
        .toList();

    if (active.isEmpty) {
      return {
        'telegram': '📋 <b>WishperLog Daily Digest</b>\nNo active notes.',
        'telegram_digest': '📋 <b>WishperLog Daily Digest</b>\nNo active notes.',
        'telegram_summary': '📋 <b>WishperLog Summary</b>\nNo active notes.',
        'telegram_top': '🏆 <b>WishperLog Top</b>\nNo active notes.',
        'telegram_tasks': '📝 <b>WishperLog Tasks</b>\nNo active notes.',
        'telegram_reminders': '⏰ <b>WishperLog Reminders</b>\nNo active notes.',
        'telegram_ideas': '💡 <b>WishperLog Ideas</b>\nNo active notes.',
        'telegram_followup': '🔁 <b>WishperLog Follow-up</b>\nNo active notes.',
        'telegram_journal': '📓 <b>WishperLog Journal</b>\nNo active notes.',
        'telegram_general': '📦 <b>WishperLog General</b>\nNo active notes.',
      };
    }

    active.sort((a, b) {
      final pa = _priorityRank(a.priority.name);
      final pb = _priorityRank(b.priority.name);
      if (pa != pb) return pa.compareTo(pb);
      return b.updatedAt.compareTo(a.updatedAt);
    });

    final tasks = active.where((n) => n.category == NoteCategory.tasks).toList();
    final reminders = active.where((n) => n.category == NoteCategory.reminders).toList();
    final ideas = active.where((n) => n.category == NoteCategory.ideas).toList();
    final followUps = active.where((n) => n.category == NoteCategory.followUp).toList();
    final journals = active.where((n) => n.category == NoteCategory.journal).toList();
    final generals = active.where((n) => n.category == NoteCategory.general).toList();

    return {
      'telegram': _buildDigestMessage(
        title: 'Daily Digest',
        icon: '📋',
        subtitle: 'Your complete daily snapshot',
        greeting: displayName,
        notes: active,
        maxItems: 5,
        includeStats: true,
      ),
      'telegram_digest': _buildDigestMessage(
        title: 'Daily Digest',
        icon: '📋',
        subtitle: 'Your complete daily snapshot',
        greeting: displayName,
        notes: active,
        maxItems: 5,
        includeStats: true,
      ),
      'telegram_summary': _buildDigestMessage(
        title: 'Summary',
        icon: '🧭',
        subtitle: 'A quick view of everything active',
        greeting: displayName,
        notes: active,
        maxItems: 5,
        includeStats: true,
      ),
      'telegram_top': _buildDigestMessage(
        title: 'Top Priorities',
        icon: '🏆',
        subtitle: 'Your sharpest focus items right now',
        greeting: displayName,
        notes: active.take(3).toList(),
        maxItems: 3,
        includeStats: false,
      ),
      'telegram_tasks': _buildDigestMessage(
        title: 'Tasks',
        icon: '📝',
        subtitle: 'Actionable items that need attention',
        greeting: displayName,
        notes: tasks,
        maxItems: 5,
        includeStats: false,
      ),
      'telegram_reminders': _buildDigestMessage(
        title: 'Reminders',
        icon: '⏰',
        subtitle: 'Things you should not forget',
        greeting: displayName,
        notes: reminders,
        maxItems: 5,
        includeStats: false,
      ),
      'telegram_ideas': _buildDigestMessage(
        title: 'Ideas',
        icon: '💡',
        subtitle: 'Thoughts worth capturing and keeping',
        greeting: displayName,
        notes: ideas,
        maxItems: 5,
        includeStats: false,
      ),
      'telegram_followup': _buildDigestMessage(
        title: 'Follow-up',
        icon: '🔁',
        subtitle: 'Things you need to circle back on',
        greeting: displayName,
        notes: followUps,
        maxItems: 5,
        includeStats: false,
      ),
      'telegram_journal': _buildDigestMessage(
        title: 'Journal',
        icon: '📓',
        subtitle: 'Notes that belong in your personal log',
        greeting: displayName,
        notes: journals,
        maxItems: 5,
        includeStats: false,
      ),
      'telegram_general': _buildDigestMessage(
        title: 'General',
        icon: '📦',
        subtitle: 'Everything that does not fit elsewhere',
        greeting: displayName,
        notes: generals,
        maxItems: 5,
        includeStats: false,
      ),
    };
  }

  Future<void> _persist(
    String uid,
    Map<String, String> messages,
    List<Note> activeNotes, {
    String? displayName,
  }) async {
    final active = activeNotes
        .where((n) => n.status == NoteStatus.active)
        .toList()
      ..sort((a, b) {
        final pa = _priorityRank(a.priority.name);
        final pb = _priorityRank(b.priority.name);
        if (pa != pb) return pa.compareTo(pb);
        return b.updatedAt.compareTo(a.updatedAt);
      });

    final categoryCounts = <String, int>{
      'tasks': active.where((n) => n.category == NoteCategory.tasks).length,
      'reminders': active.where((n) => n.category == NoteCategory.reminders).length,
      'ideas': active.where((n) => n.category == NoteCategory.ideas).length,
      'followUp': active.where((n) => n.category == NoteCategory.followUp).length,
      'journal': active.where((n) => n.category == NoteCategory.journal).length,
      'general': active.where((n) => n.category == NoteCategory.general).length,
    };

    final priorityCounts = <String, int>{
      'high': active.where((n) => n.priority == NotePriority.high).length,
      'medium': active.where((n) => n.priority == NotePriority.medium).length,
      'low': active.where((n) => n.priority == NotePriority.low).length,
    };

    // ── Root doc: config-only aggregates, NO channel content ─────────────────
    // Intentionally omits display_name; that field is written once at sign-in
    // by UserRepository and must not be overwritten here to avoid race conditions.
    await _firestore
        .collection('users')
        .doc(uid)
        .set({
      'schema_version'   : 3,
      'updated_at'       : FieldValue.serverTimestamp(),
      'active_note_count': active.length,
      'category_counts'  : categoryCounts,
      'priority_counts'  : priorityCounts,
    }, SetOptions(merge: true));

    // ── digest/latest: single source of truth for all channel messages ────────
    // merge:false guarantees stale keys from prior schema versions are wiped
    // clean on every recompute cycle.
    final latestPayload = <String, dynamic>{
      'computed_at'       : FieldValue.serverTimestamp(),
      'active_note_count' : active.length,
      'telegram'          : messages['telegram']           ?? messages['telegram_digest'] ?? '',
      'telegram_digest'   : messages['telegram_digest']    ?? '',
      'telegram_summary'  : messages['telegram_summary']   ?? '',
      'telegram_top'      : messages['telegram_top']       ?? '',
      'telegram_tasks'    : messages['telegram_tasks']     ?? '',
      'telegram_reminders': messages['telegram_reminders'] ?? '',
      'telegram_ideas'    : messages['telegram_ideas']     ?? '',
      'telegram_followup' : messages['telegram_followup']  ?? '',
      'telegram_journal'  : messages['telegram_journal']   ?? '',
      'telegram_general'  : messages['telegram_general']   ?? '',
    };

    await _firestore
        .collection('users')
        .doc(uid)
        .collection('digest')
        .doc('latest')
        .set(latestPayload, SetOptions(merge: false));
    // If this throws permission-denied, add to firestore.rules:
    //   match /users/{userId}/digest/{doc} {
    //     allow read, write: if request.auth != null && request.auth.uid == userId;
    //   }
  }
}

String _buildDigestMessage({
  required String title,
  required String icon,
  required String subtitle,
  required String? greeting,
  required List<Note> notes,
  required int maxItems,
  required bool includeStats,
}) {
  final sorted = [...notes]
    ..sort((a, b) {
      final pa = _priorityRank(a.priority.name);
      final pb = _priorityRank(b.priority.name);
      if (pa != pb) return pa.compareTo(pb);
      return b.updatedAt.compareTo(a.updatedAt);
    });

  final active = sorted.take(maxItems).toList();
  final tasks = notes.where((n) => n.category == NoteCategory.tasks).length;
  final reminders = notes.where((n) => n.category == NoteCategory.reminders).length;
  final ideas = notes.where((n) => n.category == NoteCategory.ideas).length;

  final buffer = StringBuffer();
  buffer.writeln('$icon <b>WishperLog</b>');
  buffer.writeln('<b>${_escapeHtml(title)}</b>');
  buffer.writeln('<i>${_escapeHtml(subtitle)}</i>');
  if ((greeting ?? '').trim().isNotEmpty) {
    buffer.writeln();
    buffer.writeln('Hello <b>${_escapeHtml(_ascii(greeting ?? 'there'))}</b>');
  }

  if (includeStats) {
    buffer.writeln();
    buffer.writeln('<i>${notes.length} notes · $tasks tasks · $reminders reminders · $ideas ideas</i>');
  }

  if (active.isEmpty) {
    buffer.writeln();
    buffer.writeln('<i>No active notes right now. You are all caught up.</i>');
    return buffer.toString().trim();
  }

  buffer.writeln();
  buffer.writeln('<b>Top items</b>');
  for (final note in active) {
    final titleText = _escapeHtml(_ascii(note.title.isEmpty ? 'Untitled' : note.title));
    final category = _categoryLabel(note.category.name);
    final priority = _priorityLabel(note.priority.name);
    buffer.writeln('\n$category | $priority');
    buffer.writeln('<b>$titleText</b>');

    final body = _ascii(note.cleanBody);
    if (body.isNotEmpty) {
      buffer.writeln('<i>${_escapeHtml(body.length > 500 ? '${body.substring(0, 500)}…' : body)}</i>');
    }
  }

  buffer.writeln('\n━━━━━━━━━━━━━━━');
  if (notes.length > active.length) {
    buffer.writeln('<i>+${notes.length - active.length} more. Tap /summary to see all.</i>');
  }
  buffer.writeln('<i>Quick links:</i> /tasks • /ideas • /followup');

  return buffer.toString().trim();
}

int _priorityRank(String? p) {
  return switch (p?.toLowerCase()) {
    'high' => 0,
    'medium' => 1,
    'low' => 2,
    _ => 3,
  };
}

String _priorityLabel(String? p) {
  return switch (p?.toLowerCase()) {
    'high' => 'HIGH',
    'low' => 'LOW',
    _ => 'MED',
  };
}

String _categoryLabel(String? value) {
  return switch ((value ?? '').toLowerCase()) {
    'tasks' => 'Tasks',
    'reminders' => 'Reminders',
    'ideas' => 'Ideas',
    'followup' => 'Follow-up',
    'follow_up' => 'Follow-up',
    'follow-up' => 'Follow-up',
    'journal' => 'Journal',
    _ => 'General',
  };
}

String _ascii(String? v) {
  return (v ?? '')
      .replaceAll(RegExp(r'[^\x00-\x7F]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String _escapeHtml(String input) {
  return input
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');
}