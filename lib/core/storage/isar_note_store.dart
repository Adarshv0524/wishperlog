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
  bool _initializing = false;

  Future<Isar> init() async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }

    if (_initializing) {
      while (_initializing) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      if (_isar != null && _isar!.isOpen) {
        return _isar!;
      }
    }

    _initializing = true;
    try {
      final docsDir = await getApplicationDocumentsDirectory();
      _isar = await Isar.open(
        [NoteSchema],
        directory: docsDir.path,
        name: 'wishperlog_isar',
      );
      debugPrint('[IsarNoteStore] Ready at ${docsDir.path}');
      return _isar!;
    } finally {
      _initializing = false;
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
    final all = await isar.notes.where().findAll();
    return all
        .where(
          (note) =>
              note.status != NoteStatus.archived &&
              note.status != NoteStatus.deleted,
        )
        .toList();
  }

  Future<List<Note>> getPendingAiNotes() async {
    final isar = await init();
    final all = await isar.notes.where().findAll();
    return all.where((note) => note.status == NoteStatus.pendingAi).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
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
