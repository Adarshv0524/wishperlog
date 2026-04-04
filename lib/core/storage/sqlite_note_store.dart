import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class SqliteNoteStore {
  SqliteNoteStore._();

  static final SqliteNoteStore instance = SqliteNoteStore._();

  static const _databaseName = 'wishperlog_notes.db';
  static const _tableName = 'notes';

  Database? _db;
  bool _initializing = false;
  final StreamController<void> _changes = StreamController<void>.broadcast();

  Future<Database> init() async {
    if (_db?.isOpen == true) {
      return _db!;
    }

    if (_initializing) {
      while (_initializing) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      if (_db?.isOpen == true) {
        return _db!;
      }
    }

    _initializing = true;
    try {
      final databasesPath = await getDatabasesPath();
      final dbPath = path.join(databasesPath, _databaseName);
      _db = await openDatabase(
        dbPath,
        version: 1,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE $_tableName (
              note_id TEXT PRIMARY KEY,
              uid TEXT NOT NULL,
              raw_transcript TEXT NOT NULL,
              title TEXT NOT NULL,
              clean_body TEXT NOT NULL,
              category TEXT NOT NULL,
              priority TEXT NOT NULL,
              extracted_date TEXT,
              created_at TEXT NOT NULL,
              updated_at TEXT NOT NULL,
              status TEXT NOT NULL,
              ai_model TEXT NOT NULL,
              gcal_event_id TEXT,
              gtask_id TEXT,
              source TEXT NOT NULL,
              synced_at TEXT
            )
          ''');
          await db.execute('CREATE INDEX idx_notes_status ON $_tableName(status)');
          await db.execute('CREATE INDEX idx_notes_category ON $_tableName(category)');
          await db.execute('CREATE INDEX idx_notes_updated_at ON $_tableName(updated_at)');
          await db.execute('CREATE INDEX idx_notes_priority ON $_tableName(priority)');
        },
      );
      debugPrint('[SqliteNoteStore] Ready at $dbPath');
      return _db!;
    } finally {
      _initializing = false;
    }
  }

  Stream<void> get changes => _changes.stream;

  Future<void> upsert(Note note) async {
    final db = await init();
    await db.insert(
      _tableName,
      note.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    _emitChange();
  }

  Future<Note?> getByNoteId(String noteId) async {
    final db = await init();
    final rows = await db.query(
      _tableName,
      where: 'note_id = ?',
      whereArgs: [noteId],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Note.fromSqliteMap(rows.first);
  }

  Future<List<Note>> getAllNotes() async {
    final db = await init();
    final rows = await db.query(_tableName);
    final notes = rows.map((row) => Note.fromSqliteMap(row)).toList();
    _sortNotes(notes);
    return notes;
  }

  Future<List<Note>> getActiveNotes() async {
    final notes = await getAllNotes();
    return notes.where((note) => note.status != NoteStatus.archived).toList();
  }

  Future<List<Note>> getActiveNotesByCategory(NoteCategory category) async {
    final notes = await getActiveNotes();
    return notes.where((note) => note.category == category).toList();
  }

  Future<List<Note>> getPendingAiNotes() async {
    final db = await init();
    final rows = await db.query(
      _tableName,
      where: 'status = ?',
      whereArgs: [NoteStatus.pendingAi.name],
    );
    final notes = rows.map((row) => Note.fromSqliteMap(row)).toList();
    notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return notes;
  }

  Future<int> countPendingAi() async {
    final db = await init();
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM $_tableName WHERE status = ?',
        [NoteStatus.pendingAi.name],
      ),
    );
    return count ?? 0;
  }

  Future<void> clear() async {
    final db = await init();
    await db.delete(_tableName);
    _emitChange();
  }

  void _emitChange() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

  void _sortNotes(List<Note> notes) {
    notes.sort((a, b) {
      final priorityComparison = priorityWeight(a.priority).compareTo(
        priorityWeight(b.priority),
      );
      if (priorityComparison != 0) {
        return priorityComparison;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
  }
}