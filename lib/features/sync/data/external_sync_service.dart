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

/// Full bi-directional Google Tasks + Google Calendar sync with
/// strict duplicate prevention using the `gtaskId` and `gcalEventId`
/// fields stored on each [Note].
class ExternalSyncService {
  ExternalSyncService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarNoteStore? isarNoteStore,
    GoogleSignIn? googleSignIn,
  })  : _auth           = auth      ?? FirebaseAuth.instance,
        _firestore      = firestore ?? FirebaseFirestore.instance,
        _isarNoteStore  = isarNoteStore ?? IsarNoteStore.instance,
        _googleSignIn   = googleSignIn  ??
            GoogleSignIn(scopes: [
              gcal.CalendarApi.calendarScope,
              gtasks.TasksApi.tasksScope,
              'email',
            ]);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarNoteStore _isarNoteStore;
  final GoogleSignIn _googleSignIn;

  // ── Auth helpers ──────────────────────────────────────────────────────────

  Future<bool> ensureGoogleConnected() async {
    try {
      return await _googleSignIn.signInSilently() != null;
    } catch (_) { return false; }
  }

  Future<bool> reconnectGoogle() async {
    try {
      return await _googleSignIn.signIn() != null;
    } catch (_) { return false; }
  }

  Future<Map<String, String>?> _authHeaders() async {
    final account = await _googleSignIn.signInSilently();
    if (account == null) return null;
    return account.authHeaders;
  }

  // ── Primary entry-point ───────────────────────────────────────────────────

  /// Full bi-directional sync: push local → remote + pull remote → local.
  Future<SyncRunResult> syncNow() async {
    final headers = await _authHeaders();
    if (headers == null) {
      debugPrint('[ExternalSync] Not signed in — skipping');
      return const SyncRunResult(processed: 0, updated: 0);
    }

    final client    = HeaderClient(headers);
    final tasksApi  = gtasks.TasksApi(client);
    final calApi    = gcal.CalendarApi(client);

    int processed = 0;
    int updated   = 0;

    try {
      final r1 = await _syncGoogleTasks(tasksApi);
      final r2 = await _syncGoogleCalendar(calApi);
      processed = r1.processed + r2.processed;
      updated   = r1.updated   + r2.updated;
    } finally {
      client.close();
    }

    return SyncRunResult(processed: processed, updated: updated);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GOOGLE TASKS
  // ─────────────────────────────────────────────────────────────────────────

  Future<SyncRunResult> _syncGoogleTasks(gtasks.TasksApi api) async {
    int processed = 0, updated = 0;

    // 1. Pull all remote tasks
    final remoteTasks = await _fetchAllGoogleTasks(api);
    final remoteById  = { for (final t in remoteTasks) if (t.id != null) t.id!: t };

    // 2. Pull all local notes
    final localNotes = await _isarNoteStore.getAllActive();
    final taskNotes  = localNotes.where((n) => n.category == NoteCategory.tasks).toList();

    // Build lookup: gtaskId → local note
    final localByGTaskId = <String, Note>{};
    for (final n in taskNotes) {
      if (n.gtaskId != null) localByGTaskId[n.gtaskId!] = n;
    }

    // 3. PUSH: local task notes → Google Tasks
    for (final note in taskNotes) {
      processed++;
      try {
        if (note.gtaskId == null) {
          // Create new remote task
          final created = await _createGoogleTask(api, note);
          if (created?.id != null) {
            final saved = note.copyWith(gtaskId: created!.id);
            await _isarNoteStore.put(saved);
            await _firestoreUpdate(saved);
            updated++;
            localByGTaskId[created.id!] = saved;
          }
        } else if (remoteById.containsKey(note.gtaskId)) {
          // Update existing remote task if local note is newer
          final remote = remoteById[note.gtaskId!]!;
          // Parse remote.updated (String from API) to DateTime for comparison
          DateTime? remoteUpdated;
          try {
            if (remote.updated != null) {
              remoteUpdated = DateTime.parse(remote.updated!);
            }
          } catch (_) {}
          
          if (_isLocalNewer(note, remoteUpdated)) {
            await _updateGoogleTask(api, note, remote);
            updated++;
          }
        }
        // (if gtaskId exists but remote has been deleted, clear the id)
        else if (note.gtaskId != null) {
          final cleared = note.copyWith(clearGtaskId: true);
          await _isarNoteStore.put(cleared);
          await _firestoreUpdate(cleared);
        }
      } catch (e) {
        debugPrint('[ExternalSync] Task push error for ${note.noteId}: $e');
      }
    }

    // 4. PULL: remote tasks → local (only those not already linked)
    final uid = _auth.currentUser?.uid ?? 'local_anonymous';
    for (final task in remoteTasks) {
      if (task.id == null || task.title == null) continue;
      processed++;
      if (localByGTaskId.containsKey(task.id!)) {
        // Already linked — sync completion status
        final local = localByGTaskId[task.id!]!;
        if (task.status == 'completed' && local.status != NoteStatus.archived) {
          final archived = local.copyWith(
            status: NoteStatus.archived,
            updatedAt: DateTime.now(),
          );
          await _isarNoteStore.put(archived);
          await _firestoreUpdate(archived);
          updated++;
        }
        continue;
      }
      // New remote task — create local note
      try {
        final note = _googleTaskToNote(task, uid);
        await _isarNoteStore.put(note);
        await _firestoreUpdate(note);
        updated++;
      } catch (e) {
        debugPrint('[ExternalSync] Task pull error for ${task.id}: $e');
      }
    }

    return SyncRunResult(processed: processed, updated: updated);
  }

  Future<List<gtasks.Task>> _fetchAllGoogleTasks(gtasks.TasksApi api) async {
    final all = <gtasks.Task>[];
    String? pageToken;
    do {
      final page = await api.tasks.list(
        '@default',
        showCompleted: true,
        showHidden:    false,
        maxResults:    100,
        pageToken:     pageToken,
      );
      all.addAll(page.items ?? []);
      pageToken = page.nextPageToken;
    } while (pageToken != null);
    return all;
  }

  Future<gtasks.Task?> _createGoogleTask(gtasks.TasksApi api, Note note) async {
    final task = gtasks.Task()
      ..title = note.title
      ..notes = note.cleanBody
      ..status = 'needsAction';

    if (note.extractedDate != null) {
      task.due = note.extractedDate!.toUtc().toIso8601String();
    }
    return api.tasks.insert(task, '@default');
  }

  Future<void> _updateGoogleTask(
      gtasks.TasksApi api, Note note, gtasks.Task remote) async {
    remote
      ..title  = note.title
      ..notes  = note.cleanBody
      ..status = note.status == NoteStatus.archived ? 'completed' : 'needsAction';
    if (note.extractedDate != null) {
      remote.due = note.extractedDate!.toUtc().toIso8601String();
    }
    await api.tasks.update(remote, '@default', remote.id!);
  }

  Note _googleTaskToNote(gtasks.Task task, String uid) {
    final now = DateTime.now();
    DateTime? due;
    if (task.due != null) {
      try { due = DateTime.parse(task.due!); } catch (_) {}
    }
    return Note(
      noteId:        'gtask_${task.id}',
      uid:           uid,
      rawTranscript: task.title ?? '',
      title:         task.title ?? 'Untitled Task',
      cleanBody:     task.notes ?? task.title ?? '',
      category:      NoteCategory.tasks,
      priority:      NotePriority.medium,
      extractedDate: due,
      createdAt:     now,
      updatedAt:     now,
      status:        task.status == 'completed'
                         ? NoteStatus.archived
                         : NoteStatus.active,
      aiModel:       'google_tasks_import',
      gtaskId:       task.id,
      gcalEventId:   null,
      source:        CaptureSource.googleTasks,
      syncedAt:      now,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GOOGLE CALENDAR
  // ─────────────────────────────────────────────────────────────────────────

  Future<SyncRunResult> _syncGoogleCalendar(gcal.CalendarApi api) async {
    int processed = 0, updated = 0;

    final now        = DateTime.now().toUtc();
    final windowEnd  = now.add(const Duration(days: 60));

    // 1. Pull remote events (next 60 days)
    final remoteEvents = await _fetchCalendarEvents(api, now, windowEnd);
    final remoteById   = { for (final e in remoteEvents) if (e.id != null) e.id!: e };

    // 2. Local notes with dates and no gcalEventId → PUSH
    final localNotes = await _isarNoteStore.getAllActive();
    final datedNotes = localNotes.where((n) =>
        n.extractedDate != null &&
        n.extractedDate!.isAfter(now) &&
        (n.category == NoteCategory.reminders ||
         n.category == NoteCategory.tasks      ||
         n.category == NoteCategory.followUp)).toList();

    final localByGCalId = <String, Note>{};
    for (final n in localNotes) {
      if (n.gcalEventId != null) localByGCalId[n.gcalEventId!] = n;
    }

    for (final note in datedNotes) {
      processed++;
      try {
        if (note.gcalEventId == null) {
          final created = await _createCalendarEvent(api, note);
          if (created?.id != null) {
            final saved = note.copyWith(gcalEventId: created!.id);
            await _isarNoteStore.put(saved);
            await _firestoreUpdate(saved);
            updated++;
            localByGCalId[created.id!] = saved;
          }
        } else if (remoteById.containsKey(note.gcalEventId)) {
          final remote = remoteById[note.gcalEventId!]!;
          // remote.updated is already a DateTime?, pass it directly (no toDateTime())
          if (_isLocalNewer(note, remote.updated)) {
            await _updateCalendarEvent(api, note, remote);
            updated++;
          }
        } else {
          // Remote event was deleted — clear local link
          final cleared = note.copyWith(clearGcalEventId: true);
          await _isarNoteStore.put(cleared);
          await _firestoreUpdate(cleared);
        }
      } catch (e) {
        debugPrint('[ExternalSync] Calendar push error for ${note.noteId}: $e');
      }
    }

    // 3. Pull remote events → local (only new ones)
    final uid = _auth.currentUser?.uid ?? 'local_anonymous';
    for (final event in remoteEvents) {
      if (event.id == null || event.summary == null) continue;
      processed++;
      if (localByGCalId.containsKey(event.id!)) continue;

      try {
        final note = _calendarEventToNote(event, uid);
        await _isarNoteStore.put(note);
        await _firestoreUpdate(note);
        updated++;
      } catch (e) {
        debugPrint('[ExternalSync] Calendar pull error for ${event.id}: $e');
      }
    }

    return SyncRunResult(processed: processed, updated: updated);
  }

  Future<List<gcal.Event>> _fetchCalendarEvents(
      gcal.CalendarApi api, DateTime from, DateTime to) async {
    final all = <gcal.Event>[];
    String? pageToken;
    do {
      final page = await api.events.list(
        'primary',
        timeMin:   from,
        timeMax:   to,
        singleEvents: true,
        orderBy:      'startTime',
        maxResults:   250,
        pageToken:    pageToken,
      );
      all.addAll(page.items ?? []);
      pageToken = page.nextPageToken;
    } while (pageToken != null);
    return all;
  }

  Future<gcal.Event?> _createCalendarEvent(gcal.CalendarApi api, Note note) async {
    final date     = note.extractedDate!.toUtc();
    final endDate  = date.add(const Duration(hours: 1));
    final event    = gcal.Event()
      ..summary     = note.title
      ..description = note.cleanBody
      ..start       = gcal.EventDateTime(dateTime: date,    timeZone: 'UTC')
      ..end         = gcal.EventDateTime(dateTime: endDate, timeZone: 'UTC');
    return api.events.insert(event, 'primary');
  }

  Future<void> _updateCalendarEvent(
      gcal.CalendarApi api, Note note, gcal.Event remote) async {
    final date    = note.extractedDate!.toUtc();
    final endDate = date.add(const Duration(hours: 1));
    remote
      ..summary     = note.title
      ..description = note.cleanBody
      ..start       = gcal.EventDateTime(dateTime: date,    timeZone: 'UTC')
      ..end         = gcal.EventDateTime(dateTime: endDate, timeZone: 'UTC');
    await api.events.update(remote, 'primary', remote.id!);
  }

  Note _calendarEventToNote(gcal.Event event, String uid) {
    final now   = DateTime.now();
    DateTime? start;
    try {
      // Try dateTime first (events with specific times)
      start = event.start?.dateTime?.toLocal();
      // Fallback to date field (all-day events or date-only)
      if (start == null && event.start?.date != null) {
        try {
          // Handle both String and DateTime types for date field
          final dateValue = event.start!.date;
          if (dateValue is DateTime) {
            start = dateValue;
          } else {
            start = DateTime.parse(dateValue.toString());
          }
        } catch (_) {}
      }
    } catch (_) {}

    return Note(
      noteId:        'gcal_${event.id}',
      uid:           uid,
      rawTranscript: event.summary ?? '',
      title:         event.summary ?? 'Untitled Event',
      cleanBody:     event.description ?? event.summary ?? '',
      category:      NoteCategory.reminders,
      priority:      NotePriority.medium,
      extractedDate: start,
      createdAt:     now,
      updatedAt:     now,
      status:        NoteStatus.active,
      aiModel:       'gcal_import',
      gtaskId:       null,
      gcalEventId:   event.id,
      source:        CaptureSource.googleCalendar,
      syncedAt:      now,
    );
  }

  // – Sync a single note to external services (Google Tasks/Calendar) ────────

  /// Syncs a single note with external services (Google Tasks/Calendar).
  /// Returns the note (potentially with updated gtaskId/gcalEventId) and a 
  /// flag indicating if any changes were made.
  Future<SyncNoteExternalResult> syncExternalForNote(Note note) async {
    final headers = await _authHeaders();
    if (headers == null) {
      // Not signed in — just return the note unchanged
      return SyncNoteExternalResult(note: note, noteChanged: false);
    }

    var updatedNote = note;
    var changed = false;

    try {
      final client = HeaderClient(headers);
      try {
        // Attempt to sync to Google Tasks if it's a task/reminder
        if ((note.category == NoteCategory.tasks || 
             note.category == NoteCategory.reminders) &&
            note.gtaskId == null) {
          final tasksApi = gtasks.TasksApi(client);
          final created = await _createGoogleTask(tasksApi, note);
          if (created?.id != null) {
            updatedNote = note.copyWith(gtaskId: created!.id);
            changed = true;
          }
        }

        // Attempt to sync to Google Calendar if dated and applicable
        if ((note.extractedDate != null &&
             (note.category == NoteCategory.reminders ||
              note.category == NoteCategory.tasks ||
              note.category == NoteCategory.followUp)) &&
            updatedNote.gcalEventId == null) {
          final calApi = gcal.CalendarApi(client);
          final created = await _createCalendarEvent(calApi, updatedNote);
          if (created?.id != null) {
            updatedNote = updatedNote.copyWith(gcalEventId: created!.id);
            changed = true;
          }
        }

        // Update Firestore if any external IDs were set
        if (changed) {
          await _firestoreUpdate(updatedNote);
        }
      } finally {
        client.close();
      }
    } catch (e) {
      debugPrint('[ExternalSync] syncExternalForNote error: $e');
      // On error, just return the note unchanged
    }

    return SyncNoteExternalResult(note: updatedNote, noteChanged: changed);
  }

  // ── Completions poll (called from WorkManager / settings) ─────────────────

  Future<int> syncGoogleTaskCompletions() async {
    final headers = await _authHeaders();
    if (headers == null) return 0;
    final client   = HeaderClient(headers);
    final tasksApi = gtasks.TasksApi(client);
    try {
      final result = await _syncGoogleTasks(tasksApi);
      return result.updated;
    } finally {
      client.close();
    }
  }

  // ── Utilities ─────────────────────────────────────────────────────────────

  bool _isLocalNewer(Note note, DateTime? remoteUpdated) {
    if (remoteUpdated == null) return true;
    return note.updatedAt.isAfter(remoteUpdated);
  }

  Future<void> _firestoreUpdate(Note note) async {
    final user = _auth.currentUser;
    if (user == null) return;
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('notes')
          .doc(note.noteId)
          .set(note.toFirestoreJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('[ExternalSync] Firestore update failed: $e');
    }
  }
}