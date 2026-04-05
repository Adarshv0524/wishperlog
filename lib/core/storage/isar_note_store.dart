import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

class IsarNoteStore {
  IsarNoteStore._();

  static final IsarNoteStore instance = IsarNoteStore._();

  Isar? _isar;
  Completer<Isar>? _initCompleter;

  Future<Isar> init() async {
    if (_isar != null && _isar!.isOpen) return _isar!;

    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<Isar>();
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [NoteSchema],
        directory: docsDir.path,
        name: 'wishperlog_isar',
      );
      debugPrint('[IsarNoteStore] Ready at ${docsDir.path}');
      _initCompleter!.complete(_isar!);
      return _isar!;
    } catch (e, st) {
      _initCompleter!.completeError(e, st);
      _initCompleter = null;
      rethrow;
    }
  }

  Future<void> put(Note note) async {
    final isar = await init();
    await isar.writeTxn(() async {
      await isar.notes.putByNoteId(note);
    });
  }

  Future<void> putAll(List<Note> notes) async {
    if (notes.isEmpty) {
      return;
    }

    final isar = await init();
    await isar.writeTxn(() async {
      await isar.notes.putAllByNoteId(notes);
    });
  }

  Future<Note?> getByNoteId(String noteId) async {
    final isar = await init();
    return isar.notes.filter().noteIdEqualTo(noteId).findFirst();
  }

  Future<List<Note>> getAllNotes() async {
    final isar = await init();
    return isar.notes.where().findAll();
  }

  Stream<List<Note>> watchAll() async* {
    final isar = await init();
    final query = isar.notes.where().build();
    yield* query.watch(fireImmediately: true).asyncMap((_) => query.findAll());
  }

  Future<List<Note>> getAllActive() async {
    final isar = await init();
    return isar.notes
        .filter()
        .not()
        .statusEqualTo(NoteStatus.archived)
        .and()
        .not()
        .statusEqualTo(NoteStatus.deleted)
        .findAll();
  }

  Future<List<Note>> getPendingAiNotes() async {
    final isar = await init();
    return isar.notes
        .filter()
        .statusEqualTo(NoteStatus.pendingAi)
        .sortByCreatedAt()
        .findAll();
  }

  Future<int> countPendingAi() async {
    final pending = await getPendingAiNotes();
    return pending.length;
  }

  Stream<List<Note>> watchActive() async* {
    final isar = await init();
    final query = isar.notes.where().build();

    yield* query.watch(fireImmediately: true).asyncMap((_) async {
      final all = await query.findAll();
      return all
          .where(
            (note) =>
                note.status != NoteStatus.archived &&
                note.status != NoteStatus.deleted,
          )
          .toList();
    });
  }
}
