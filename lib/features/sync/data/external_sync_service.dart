import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as gcal;
import 'package:googleapis/tasks/v1.dart' as gtasks;
import 'package:isar/isar.dart';
import 'package:wishperlog/core/storage/isar_service.dart';
import 'package:wishperlog/features/sync/data/google_api_client.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class SyncRunResult {
  SyncRunResult({required this.processed, required this.updated});

  final int processed;
  final int updated;
}

class ExternalSyncService {
  ExternalSyncService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    IsarService? isarService,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _isarService = isarService ?? IsarService.instance,
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             scopes: [
               gcal.CalendarApi.calendarScope,
               gtasks.TasksApi.tasksScope,
               'email',
             ],
           );

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final IsarService _isarService;
  final GoogleSignIn _googleSignIn;

  Future<bool> ensureGoogleConnected() async {
    try {
      final account = await _googleSignIn.signInSilently();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  Future<bool> reconnectGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      return account != null;
    } catch (_) {
      return false;
    }
  }

  Future<SyncRunResult> syncNow() async {
    final db = await _isarService.init();
    final active = await db.notes
        .filter()
        .statusEqualTo(NoteStatus.active)
        .findAll();

    var updated = 0;
    for (final note in active) {
      final result = await syncExternalForNote(note);
      if (result.noteChanged) {
        await db.writeTxn(() async {
          await db.notes.put(result.note);
        });
        await _syncNoteToFirestore(result.note);
        updated += 1;
      }
    }

    return SyncRunResult(processed: active.length, updated: updated);
  }

  Future<int> syncGoogleTaskCompletions() async {
    final account = await _googleSignIn.signInSilently();
    if (account == null) {
      return 0;
    }

    final headers = await account.authHeaders;
    final client = HeaderClient(headers);

    try {
      final tasksApi = gtasks.TasksApi(client);
      final remoteTasks = await tasksApi.tasks.list(
        '@default',
        showCompleted: true,
        showHidden: true,
        maxResults: 200,
      );

      final completedIds = (remoteTasks.items ?? const <gtasks.Task>[])
          .where((task) => task.id != null && task.status == 'completed')
          .map((task) => task.id!)
          .toSet();

      if (completedIds.isEmpty) {
        return 0;
      }

      final db = await _isarService.init();
      final linkedTaskNotes = await db.notes
          .filter()
          .statusEqualTo(NoteStatus.active)
          .gtaskIdIsNotNull()
          .findAll();

      var archivedCount = 0;
      for (final note in linkedTaskNotes) {
        final taskId = note.gtaskId;
        if (taskId == null || !completedIds.contains(taskId)) {
          continue;
        }

        final archived = note.copyWith(
          status: NoteStatus.archived,
          updatedAt: DateTime.now(),
          syncedAt: DateTime.now(),
        );

        await db.writeTxn(() async {
          await db.notes.put(archived);
        });
        await _syncNoteToFirestore(archived);
        archivedCount += 1;
      }

      return archivedCount;
    } catch (_) {
      return 0;
    } finally {
      client.close();
    }
  }

  Future<SyncNoteResult> syncExternalForNote(Note note) async {
    if (note.status != NoteStatus.active) {
      return SyncNoteResult(note: note, noteChanged: false);
    }

    final account = await _googleSignIn.signInSilently();
    if (account == null) {
      return SyncNoteResult(note: note, noteChanged: false);
    }

    final headers = await account.authHeaders;
    final client = HeaderClient(headers);

    try {
      var updated = note;
      var changed = false;

      if (note.category == NoteCategory.reminders &&
          note.extractedDate != null &&
          note.gcalEventId == null) {
        final calendar = gcal.CalendarApi(client);
        final createdEventId = await _createCalendarReminderIfMissing(
          api: calendar,
          note: updated,
        );
        if (createdEventId != null) {
          updated = updated.copyWith(
            gcalEventId: createdEventId,
            updatedAt: DateTime.now(),
          );
          changed = true;
        }
      }

      if (updated.category == NoteCategory.tasks && updated.gtaskId == null) {
        final tasks = gtasks.TasksApi(client);
        final createdTaskId = await _createGoogleTask(tasks, updated);
        if (createdTaskId != null) {
          updated = updated.copyWith(
            gtaskId: createdTaskId,
            updatedAt: DateTime.now(),
          );
          changed = true;
        }
      }

      if (changed) {
        updated = updated.copyWith(syncedAt: DateTime.now());
      }

      return SyncNoteResult(note: updated, noteChanged: changed);
    } catch (_) {
      return SyncNoteResult(note: note, noteChanged: false);
    } finally {
      client.close();
    }
  }

  Future<String?> _createCalendarReminderIfMissing({
    required gcal.CalendarApi api,
    required Note note,
  }) async {
    final target = note.extractedDate!;
    final start = target.subtract(const Duration(days: 2)).toUtc();
    final end = target.add(const Duration(days: 2)).toUtc();

    final events = await api.events.list(
      'primary',
      timeMin: start,
      timeMax: end,
      singleEvents: true,
      maxResults: 50,
    );

    final title = note.title.trim();
    final existingTitles =
        events.items
            ?.map((e) => (e.summary ?? '').trim())
            .where((s) => s.isNotEmpty)
            .toList() ??
        const <String>[];

    final hasDuplicate = _hasFuzzyDuplicate(title, existingTitles);
    if (hasDuplicate) {
      return null;
    }

    final event = gcal.Event(
      summary: title,
      description: note.cleanBody,
      start: gcal.EventDateTime(dateTime: target.toUtc()),
      end: gcal.EventDateTime(
        dateTime: target.toUtc().add(const Duration(minutes: 30)),
      ),
    );

    final created = await api.events.insert(event, 'primary');
    return created.id;
  }

  bool _hasFuzzyDuplicate(String title, List<String> existingTitles) {
    if (title.isEmpty || existingTitles.isEmpty) {
      return false;
    }

    final fuzzy = Fuzzy<String>(
      existingTitles,
      options: FuzzyOptions<String>(threshold: 0.15, shouldNormalize: true),
    );

    final result = fuzzy.search(title, 1);
    if (result.isEmpty) {
      return false;
    }

    // threshold 0.15 ~= 85% similarity requirement.
    return result.first.score <= 0.15;
  }

  Future<String?> _createGoogleTask(gtasks.TasksApi api, Note note) async {
    final task = gtasks.Task(
      title: note.title,
      notes: note.cleanBody,
      due: note.extractedDate?.toUtc().toIso8601String(),
    );
    final created = await api.tasks.insert(task, '@default');
    return created.id;
  }

  Future<void> _syncNoteToFirestore(Note note) async {
    final user = _auth.currentUser;
    if (user == null) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('notes')
        .doc(note.noteId)
        .set(note.toFirestoreJson(), SetOptions(merge: true));
  }
}

class SyncNoteResult {
  SyncNoteResult({required this.note, required this.noteChanged});

  final Note note;
  final bool noteChanged;
}
