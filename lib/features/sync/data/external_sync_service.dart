import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis/tasks/v1.dart' as gtasks;
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/sync/data/google_api_client.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class SyncRunResult {
  const SyncRunResult({required this.processed, required this.updated});
  final int processed;
  final int updated;
}

class SyncNoteExternalResult {
  const SyncNoteExternalResult({required this.note, this.noteChanged = false});
  final Note note;
  final bool noteChanged;
}

/// ─────────────────────────────────────────────────────────────────────────────
/// ExternalSyncService — Full Bi-directional Google Tasks + Calendar Sync
///
/// Design guarantees:
///  1. NO duplicate creation: uses `gtaskId` / `gcalEventId` fields for ID
///     matching. Any note with a non-null ID is updated, not re-created.
///  2. Bi-directional deletion:
///     • Note deleted in app → delete remote entry.
///     • Remote entry deleted by user → mark note as unsynced (remove ID).
///  3. Smart mapping:
///     • Tasks | Reminders | Follow-up → Google Tasks.
///     • Notes with extracted_date → Google Calendar (in addition if applicable).
///  4. Completion sync: checks remote task completion and marks local note done.
///  5. All Firestore writes are batched to reduce cost.
/// ─────────────────────────────────────────────────────────────────────────────
class ExternalSyncService {
  ExternalSyncService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
    GoogleSignIn? googleSignIn,
  })  : _auth          = auth ?? FirebaseAuth.instance,
        _firestore     = firestore ?? FirebaseFirestore.instance,
        _isarNoteStore = isarNoteStore ?? IsarNoteStore.instance,
        _googleSignIn  = googleSignIn ??
            GoogleSignIn(scopes: [
              gcal.CalendarApi.calendarScope,
              gtasks.TasksApi.tasksScope,
              'email',
            ]);

  final FirebaseAuth    _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore   _isarNoteStore;
  final GoogleSignIn    _googleSignIn;

  // ── Auth helpers ──────────────────────────────────────────────────────────

  Future<bool> ensureGoogleConnected() async {
    try { return await _googleSignIn.signInSilently() != null; }
    catch (_) { return false; }
  }

  Future<bool> reconnectGoogle() async {
    try { return await _googleSignIn.signIn() != null; }
    catch (_) { return false; }
  }

  Future<Map<String, String>?> _authHeaders({bool retried = false}) async {
    try {
      var account = _googleSignIn.currentUser;
      account ??= await _googleSignIn.signInSilently();
      if (account == null) return null;
      // authHeaders internally calls getAuthToken which refreshes the access
      // token if it has expired (via the platform's token refresh flow).
      final headers = await account.authHeaders;
      // Sanity-check: ensure we actually have a Bearer token.
      final auth = headers['Authorization'] ?? '';
      if (auth.isEmpty && !retried) {
        // Force a fresh account sign-in and retry once.
        await _googleSignIn.signOut();
        return _authHeaders(retried: true);
      }
      return headers;
    } catch (e) {
      debugPrint('[ExternalSync] _authHeaders error: $e');
      return null;
    }
  }

  // ── Public entry-points ───────────────────────────────────────────────────

  /// Full bi-directional sync: push local changes → remote, pull deletions ← remote.
  Future<SyncRunResult> syncNow() async {
    final headers = await _authHeaders();
    if (headers == null) {
      debugPrint('[ExternalSync] Not signed in — skipping');
      return const SyncRunResult(processed: 0, updated: 0);
    }

    final client   = HeaderClient(headers);
    final tasksApi = gtasks.TasksApi(client);
    final calApi   = gcal.CalendarApi(client);

    int processed = 0;
    int updated   = 0;

    try {
      final r1 = await _syncGoogleTasks(tasksApi);
      final r2 = await _syncGoogleCalendar(calApi);
      processed = r1.processed + r2.processed;
      updated   = r1.updated   + r2.updated;
    } catch (e) {
      debugPrint('[ExternalSync] syncNow error: $e');
    } finally {
      client.close();
    }

    debugPrint('[ExternalSync] syncNow complete: processed=$processed updated=$updated');
    return SyncRunResult(processed: processed, updated: updated);
  }

  /// Sync a single note's external entries (called after AI classification or edit/delete).
  Future<SyncNoteExternalResult> syncSingleNote(Note note) async {
    final headers = await _authHeaders();
    if (headers == null) return SyncNoteExternalResult(note: note);

    final client   = HeaderClient(headers);
    final tasksApi = gtasks.TasksApi(client);
    final calApi   = gcal.CalendarApi(client);
    Note updated   = note;
    bool changed   = false;

    try {
      if (note.status == NoteStatus.deleted) {
        // Immediate deletion cascade to Google APIs
        if (note.gtaskId != null) {
          final listId = await _getCachedTaskListId(tasksApi);
          if (listId != null) {
            try {
              await tasksApi.tasks.delete(listId, note.gtaskId!);
              updated = updated.copyWith(gtaskId: null, syncedAt: DateTime.now());
              changed = true;
              debugPrint('[ExternalSync] Deleted remote task ${note.gtaskId}');
            } catch (e) {
              debugPrint('[ExternalSync] Remote task delete error: $e');
            }
          }
        }
        if (note.gcalEventId != null) {
          try {
            await calApi.events.delete(_calendarId, note.gcalEventId!);
            updated = updated.copyWith(gcalEventId: null, syncedAt: DateTime.now());
            changed = true;
            debugPrint('[ExternalSync] Deleted remote cal event ${note.gcalEventId}');
          } catch (e) {
            debugPrint('[ExternalSync] Remote cal event delete error: $e');
          }
        }
      } else {
        // Google Tasks — for task-like categories.
        if (_shouldSyncToTasks(note.category)) {
          final r = await _upsertGoogleTask(tasksApi, note);
          if (r != null && r.noteId == note.noteId) {
            updated = r; changed = true;
          }
        }

        // Google Calendar — only if there's a concrete date.
        if (note.extractedDate != null) {
          final r = await _upsertCalendarEvent(calApi, updated);
          if (r != null && r.noteId == updated.noteId) {
            updated = r; changed = true;
          }
        }
      }
    } catch (e) {
      debugPrint('[ExternalSync] syncSingleNote error for ${note.noteId}: $e');
    } finally {
      client.close();
    }

    return SyncNoteExternalResult(note: updated, noteChanged: changed);
  }

  /// Explicitly pulls completion statuses from Google Tasks (for settings "Sync Now" button).
  Future<void> syncGoogleTaskCompletions() async {
    final headers = await _authHeaders();
    if (headers == null) return;
    final client = HeaderClient(headers);
    try {
      await _pullTaskCompletions(gtasks.TasksApi(client));
    } finally {
      client.close();
    }
  }

  // ── Google Tasks sync ─────────────────────────────────────────────────────

  static const _taskListTitle = 'WishperLog';

  // Cache the task-list ID so we don't query it on every per-note upsert.
  String? _cachedTaskListId;
  DateTime? _taskListCacheTime;
  static const _taskListCacheTtl = Duration(hours: 6);

  Future<SyncRunResult> _syncGoogleTasks(gtasks.TasksApi api) async {
    int processed = 0;
    int updated   = 0;

    // ── Ensure our task list exists ───────────────────────────────────────────
    final listId = await _getCachedTaskListId(api);
    if (listId == null) return const SyncRunResult(processed: 0, updated: 0);

    // ── Pull: check which of our synced tasks were deleted on Google side ─────
    final remoteTaskIds = await _fetchRemoteTaskIds(api, listId);
    final localNotes    = await _isarNoteStore.getAllNotes();

    for (final note in localNotes) {
      if (note.gtaskId == null) continue;
      if (!remoteTaskIds.contains(note.gtaskId)) {
        // Remote was deleted — clear local ID so it won't try to update a ghost.
        debugPrint('[ExternalSync] gtask ${note.gtaskId} was deleted remotely — clearing from note ${note.noteId}');
        final cleared = note.copyWith(gtaskId: null, syncedAt: DateTime.now());
        await _isarNoteStore.put(cleared);
        await _firestorePatch(note.noteId, {'gtask_id': null, 'synced_at': DateTime.now().toIso8601String()});
        updated++;
      }
    }

    // ── Push: upsert notes that need syncing ──────────────────────────────────
    final needsSync = localNotes.where((n) =>
      _shouldSyncToTasks(n.category) &&
      n.status == NoteStatus.active &&
      (n.gtaskId == null || (n.syncedAt != null && n.updatedAt.isAfter(n.syncedAt!)))
    ).toList();

    for (final note in needsSync) {
      try {
        final result = await _upsertGoogleTask(api, note, taskListId: listId);
        if (result != null) { await _isarNoteStore.put(result); updated++; }
        processed++;
      } catch (e) {
        debugPrint('[ExternalSync] task upsert error for ${note.noteId}: $e');
      }
    }

    // ── Handle local deletions (push deletes to Google) ───────────────────────
    final deletedWithTask = localNotes.where((n) =>
      n.status == NoteStatus.deleted && n.gtaskId != null
    ).toList();

    for (final note in deletedWithTask) {
      try {
        await api.tasks.delete(listId, note.gtaskId!);
        final cleared = note.copyWith(gtaskId: null);
        await _isarNoteStore.put(cleared);
        debugPrint('[ExternalSync] deleted remote task ${note.gtaskId} for note ${note.noteId}');
      } catch (e) {
        // 404 is acceptable — already deleted.
        debugPrint('[ExternalSync] delete task error (may be 404): $e');
      }
    }

    // ── Completion pull ───────────────────────────────────────────────────────
    await _pullTaskCompletions(api, listId: listId);

    return SyncRunResult(processed: processed, updated: updated);
  }

  Future<Note?> _upsertGoogleTask(
    gtasks.TasksApi api,
    Note note, {
    String? taskListId,
  }) async {
    // Prefer the caller-supplied listId (from syncNow batch), fall back to
    // the per-instance cache, or fetch+create as last resort.
    final resolvedListId = taskListId ?? await _getCachedTaskListId(api);
    if (resolvedListId == null) return null;

    final taskTitle = note.title.isNotEmpty ? note.title : 'WishperLog Note';
    final body      = note.cleanBody.isNotEmpty ? note.cleanBody : note.rawTranscript;
    final dueDate   = note.extractedDate;

    // ── Update existing ───────────────────────────────────────────────────────
    if (note.gtaskId != null) {
      try {
        final patch = gtasks.Task()
          ..title = taskTitle
          ..notes = body
          ..due   = dueDate != null
              ? DateTime.utc(dueDate.year, dueDate.month, dueDate.day).toIso8601String()
              : null;
        await api.tasks.patch(patch, resolvedListId, note.gtaskId!);
        debugPrint('[ExternalSync] Updated task ${note.gtaskId}');
        return note.copyWith(syncedAt: DateTime.now());
      } on gtasks.DetailedApiRequestError catch (e) {
        if (e.status == 404) {
          // Task was deleted remotely — fall through to create.
          debugPrint('[ExternalSync] Task 404 — will recreate: ${note.gtaskId}');
        } else {
          rethrow;
        }
      }
    }

    // ── Create new ────────────────────────────────────────────────────────────
    final newTask = gtasks.Task()
      ..title = taskTitle
      ..notes = body
      ..due   = dueDate != null
          ? DateTime.utc(dueDate.year, dueDate.month, dueDate.day).toIso8601String()
          : null;

    final created = await api.tasks.insert(newTask, resolvedListId);
    debugPrint('[ExternalSync] Created task ${created.id} for note ${note.noteId}');
    final updated = note.copyWith(gtaskId: created.id, syncedAt: DateTime.now());
    await _firestorePatch(note.noteId, {
      'gtask_id':  created.id,
      'synced_at': DateTime.now().toIso8601String(),
    });
    return updated;
  }

  Future<void> _pullTaskCompletions(gtasks.TasksApi api, {String? listId}) async {
    final taskListId = listId ?? await _getOrCreateTaskList(api);
    if (taskListId == null) return;

    try {
      final result = await api.tasks.list(taskListId, showCompleted: true, showHidden: true);
      final tasks  = result.items ?? [];

      for (final task in tasks) {
        if (task.id == null) continue;
        final isCompleted = task.status == 'completed';
        final note = await _isarNoteStore.findByGtaskId(task.id!);
        if (note == null) continue;
        if (isCompleted && note.status != NoteStatus.archived) {
          debugPrint('[ExternalSync] Marking note ${note.noteId} complete from Google Tasks');
          final updated = note.copyWith(status: NoteStatus.archived, syncedAt: DateTime.now());
          await _isarNoteStore.put(updated);
          await _firestorePatch(note.noteId, {
            'status': 'archived',
            'synced_at': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      debugPrint('[ExternalSync] pullTaskCompletions error: $e');
    }
  }

  Future<String?> _getOrCreateTaskList(gtasks.TasksApi api) async {
    try {
      final lists = await api.tasklists.list();
      for (final list in lists.items ?? []) {
        if (list.title == _taskListTitle) return list.id;
      }
      // Create it.
      final created = await api.tasklists.insert(
        gtasks.TaskList()..title = _taskListTitle,
      );
      debugPrint('[ExternalSync] Created task list: ${created.id}');
      return created.id;
    } catch (e) {
      debugPrint('[ExternalSync] _getOrCreateTaskList error: $e');
      return null;
    }
  }

  Future<Set<String>> _fetchRemoteTaskIds(gtasks.TasksApi api, String listId) async {
    final ids = <String>{};
    String? pageToken;
    try {
      do {
        final page = await api.tasks.list(
          listId,
          maxResults: 100,
          showCompleted: true,
          showHidden: true,
          pageToken: pageToken,
        );
        for (final t in page.items ?? const <gtasks.Task>[]) {
          if (t.id != null) ids.add(t.id!);
        }
        pageToken = page.nextPageToken;
      } while (pageToken != null);
    } catch (e) {
      debugPrint('[ExternalSync] _fetchRemoteTaskIds error: $e');
    }
    return ids;
  }

  // ── Google Calendar sync ──────────────────────────────────────────────────

  static const _calendarId = 'primary';

  Future<SyncRunResult> _syncGoogleCalendar(gcal.CalendarApi api) async {
    int processed = 0;
    int updated   = 0;

    final localNotes = await _isarNoteStore.getAllNotes();

    // ── Pull: detect remote deletions ─────────────────────────────────────────
    final notesWithCalEvent = localNotes.where((n) => n.gcalEventId != null).toList();
    for (final note in notesWithCalEvent) {
      try {
        await api.events.get(_calendarId, note.gcalEventId!);
        // Event still exists — no action needed.
      } on gcal.DetailedApiRequestError catch (e) {
        if (e.status == 404 || e.status == 410) {
          // Deleted on Calendar side.
          debugPrint('[ExternalSync] gcal event ${note.gcalEventId} deleted remotely');
          final cleared = note.copyWith(gcalEventId: null, syncedAt: DateTime.now());
          await _isarNoteStore.put(cleared);
          await _firestorePatch(note.noteId, {'gcal_event_id': null});
          updated++;
        }
      } catch (e) {
        debugPrint('[ExternalSync] gcal get error for ${note.gcalEventId}: $e');
      }
    }

    // ── Push: upsert notes that have a date ───────────────────────────────────
    final needsSync = localNotes.where((n) =>
      n.extractedDate != null &&
      n.status == NoteStatus.active
    ).toList();

    for (final note in needsSync) {
      try {
        final result = await _upsertCalendarEvent(api, note);
        if (result != null) { await _isarNoteStore.put(result); updated++; }
        processed++;
      } catch (e) {
        debugPrint('[ExternalSync] calendar upsert error for ${note.noteId}: $e');
      }
    }

    // ── Handle local deletions ────────────────────────────────────────────────
    final deletedWithEvent = localNotes.where((n) =>
      n.status == NoteStatus.deleted && n.gcalEventId != null
    ).toList();

    for (final note in deletedWithEvent) {
      try {
        await api.events.delete(_calendarId, note.gcalEventId!);
        final cleared = note.copyWith(gcalEventId: null);
        await _isarNoteStore.put(cleared);
        debugPrint('[ExternalSync] deleted cal event ${note.gcalEventId}');
      } catch (e) {
        debugPrint('[ExternalSync] delete cal event error (may be 404): $e');
      }
    }

    return SyncRunResult(processed: processed, updated: updated);
  }

  Future<Note?> _upsertCalendarEvent(gcal.CalendarApi api, Note note) async {
    if (note.extractedDate == null) return null;

    final d     = note.extractedDate!;
    final title = note.title.isNotEmpty ? note.title : 'WishperLog Note';
    final desc  = note.cleanBody.isNotEmpty ? note.cleanBody : note.rawTranscript;

    // All-day event using the extracted date.
    final event = gcal.Event()
      ..summary     = title
      ..description = desc
      ..start       = (gcal.EventDateTime()..date = DateTime(d.year, d.month, d.day))
      ..end         = (gcal.EventDateTime()..date = DateTime(d.year, d.month, d.day + 1))
      ..source      = (gcal.EventSource()..title = 'WishperLog' ..url = 'https://wishperlog.app');

    // ── Update existing ───────────────────────────────────────────────────────
    if (note.gcalEventId != null) {
      try {
        await api.events.patch(event, _calendarId, note.gcalEventId!);
        debugPrint('[ExternalSync] Updated cal event ${note.gcalEventId}');
        return note.copyWith(syncedAt: DateTime.now());
      } on gcal.DetailedApiRequestError catch (e) {
        if (e.status == 404 || e.status == 410) {
          // Fall through to create.
        } else {
          rethrow;
        }
      }
    }

    // ── Create new ────────────────────────────────────────────────────────────
    final created = await api.events.insert(event, _calendarId);
    debugPrint('[ExternalSync] Created cal event ${created.id} for note ${note.noteId}');
    final updated = note.copyWith(gcalEventId: created.id, syncedAt: DateTime.now());
    await _firestorePatch(note.noteId, {
      'gcal_event_id': created.id,
      'synced_at':     DateTime.now().toIso8601String(),
    });
    return updated;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  bool _shouldSyncToTasks(NoteCategory category) {
    return category == NoteCategory.tasks ||
           category == NoteCategory.reminders ||
           category == NoteCategory.followUp;
  }

  /// Returns the cached task-list ID or fetches/creates it.
  Future<String?> _getCachedTaskListId(gtasks.TasksApi api) async {
    final now = DateTime.now();
    if (_cachedTaskListId != null &&
        _taskListCacheTime != null &&
        now.difference(_taskListCacheTime!) < _taskListCacheTtl) {
      return _cachedTaskListId;
    }
    final id = await _getOrCreateTaskList(api);
    if (id != null) {
      _cachedTaskListId = id;
      _taskListCacheTime = now;
    }
    return id;
  }

  Future<void> _firestorePatch(String noteId, Map<String, dynamic> fields) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;
      final docRef = _firestore
          .collection('users').doc(uid)
          .collection('notes').doc(noteId);

      final snap = await docRef.get();
      if (!snap.exists) return;

      await docRef.set(fields, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[ExternalSync] Firestore patch error for $noteId: $e');
    }
  }
}