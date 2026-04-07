import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  
  /// Fallback mode: if Isar fails on web, use Firestore directly
  bool _useFirestoreOnly = false;
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;

  Future<Isar> init() async {
    if (_isar != null && _isar!.isOpen) return _isar!;

    if (_initCompleter != null) return _initCompleter!.future;

    _initCompleter = Completer<Isar>();
    try {
      // Initialize Firebase references for fallback
      _auth ??= FirebaseAuth.instance;
      _firestore ??= FirebaseFirestore.instance;

      if (kIsWeb) {
        // On web: try Isar, fall back to Firestore-only if it fails
        try {
          _isar = await Isar.open(
            [NoteSchema],
            directory: '.',
            name: 'wishperlog_isar',
          );
          _useFirestoreOnly = false;
          debugPrint('[IsarNoteStore] ✓ Ready on web (Isar + IndexedDB)');
        } catch (e) {
          // Isar failed on web - use Firestore as primary storage
          debugPrint(
            '[IsarNoteStore] ⚠ Isar init failed on web: $e\n'
            'Falling back to Firestore-only mode for web storage.',
          );
          _useFirestoreOnly = true;
          _isar = null;
          // Return a dummy Isar to satisfy type system; actual operations use Firestore
        }
      } else {
        // Android/iOS/Desktop: always use Isar with path_provider
        final docsDir = await getApplicationDocumentsDirectory();
        _isar = await Isar.open(
          [NoteSchema],
          directory: docsDir.path,
          name: 'wishperlog_isar',
        );
        _useFirestoreOnly = false;
        debugPrint('[IsarNoteStore] ✓ Ready at ${docsDir.path}');
      }
      
      _initCompleter!.complete(_isar!);
      return _isar!;
    } catch (e, st) {
      debugPrint('[IsarNoteStore] ERROR: $e');
      debugPrintStack(stackTrace: st);
      _initCompleter!.completeError(e, st);
      _initCompleter = null;
      rethrow;
    }
  }

  /// Get current user UID, or null if not authenticated
  String? _getCurrentUserId() {
    _auth ??= FirebaseAuth.instance;
    return _auth?.currentUser?.uid;
  }

  /// Put a single note - uses Firestore if in fallback mode
  Future<void> put(Note note) async {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] put() - skipped, user not authenticated');
        return;
      }
      _firestore ??= FirebaseFirestore.instance;
      await _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(note.noteId)
          .set(note.toFirestoreJson(), SetOptions(merge: true));
      return;
    }

    // Normal Isar path
    final isar = await init();
    if (isar.isOpen) {
      await isar.writeTxn(() async {
        await isar.notes.putByNoteId(note);
      });
    }
  }

  /// Put multiple notes - uses Firestore if in fallback mode
  Future<void> putAll(List<Note> notes) async {
    if (notes.isEmpty) return;

    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] putAll() - skipped, user not authenticated');
        return;
      }
      _firestore ??= FirebaseFirestore.instance;
      
      // Batch write to Firestore
      final batch = _firestore!.batch();
      for (final note in notes) {
        final docRef = _firestore!
            .collection('users')
            .doc(uid)
            .collection('notes')
            .doc(note.noteId);
        batch.set(docRef, note.toFirestoreJson(), SetOptions(merge: true));
      }
      await batch.commit();
      return;
    }

    // Normal Isar path
    final isar = await init();
    if (isar.isOpen) {
      await isar.writeTxn(() async {
        await isar.notes.putAllByNoteId(notes);
      });
    }
  }

  /// Get a single note by ID - uses Firestore if in fallback mode
  Future<Note?> getByNoteId(String noteId) async {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] getByNoteId() - null, user not authenticated');
        return null;
      }
      _firestore ??= FirebaseFirestore.instance;
      
      final doc = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .doc(noteId)
          .get();
      
      if (!doc.exists) return null;
      try {
        return Note.fromFirestoreJson(doc.data()!, uid: uid, noteId: noteId);
      } catch (e) {
        debugPrint('[IsarNoteStore] Error parsing note from Firestore: $e');
        return null;
      }
    }

    // Normal Isar path
    final isar = await init();
    if (isar.isOpen) {
      return isar.notes.filter().noteIdEqualTo(noteId).findFirst();
    }
    return null;
  }

  /// Get all notes - uses Firestore if in fallback mode
  Future<List<Note>> getAllNotes() async {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] getAllNotes() - empty, user not authenticated');
        return [];
      }
      _firestore ??= FirebaseFirestore.instance;
      
      final query = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();
      
      return query.docs
          .map((doc) {
            try {
              return Note.fromFirestoreJson(doc.data(), uid: uid, noteId: doc.id);
            } catch (e) {
              debugPrint('[IsarNoteStore] Error parsing note: $e');
              return null;
            }
          })
          .whereType<Note>()
          .toList();
    }

    // Normal Isar path
    final isar = await init();
    if (isar.isOpen) {
      return isar.notes.where().findAll();
    }
    return [];
  }

  /// Watch all notes stream - uses Firestore if in fallback mode
  Stream<List<Note>> watchAll() async* {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] watchAll() - empty stream, user not authenticated');
        yield [];
        return;
      }
      _firestore ??= FirebaseFirestore.instance;
      
      yield* _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .snapshots()
          .asyncMap((query) async {
        return query.docs
            .map((doc) {
              try {
                return Note.fromFirestoreJson(doc.data(), uid: uid, noteId: doc.id);
              } catch (e) {
                debugPrint('[IsarNoteStore] Error parsing note: $e');
                return null;
              }
            })
            .whereType<Note>()
            .toList();
      });
      return;
    }

    // Normal Isar path
    await init();
    if (_isar != null && _isar!.isOpen) {
      final query = _isar!.notes.where().build();
      yield* query.watch(fireImmediately: true).asyncMap((_) => query.findAll());
    }
  }

  /// Get all active notes (not archived/deleted) - uses Firestore if in fallback mode
  Future<List<Note>> getAllActive() async {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] getAllActive() - empty, user not authenticated');
        return [];
      }
      _firestore ??= FirebaseFirestore.instance;
      
      // Fetch all notes and filter in-memory
      final query = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();
      
      final notes = query.docs
          .map((doc) {
            try {
              return Note.fromFirestoreJson(doc.data(), uid: uid, noteId: doc.id);
            } catch (e) {
              debugPrint('[IsarNoteStore] Error parsing note: $e');
              return null;
            }
          })
          .whereType<Note>()
          .toList();
      
      // Filter to exclude archived and deleted
      return notes
          .where((note) =>
              note.status != NoteStatus.archived &&
              note.status != NoteStatus.deleted)
          .toList();
    }

    // Normal Isar path
    await init();
    if (_isar != null && _isar!.isOpen) {
      return _isar!.notes
          .filter()
          .not()
          .statusEqualTo(NoteStatus.archived)
          .and()
          .not()
          .statusEqualTo(NoteStatus.deleted)
          .findAll();
    }
    return [];
  }

  /// Get all pending AI notes - uses Firestore if in fallback mode
  Future<List<Note>> getPendingAiNotes() async {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] getPendingAiNotes() - empty, user not authenticated');
        return [];
      }
      _firestore ??= FirebaseFirestore.instance;
      
      // Fetch all notes and filter in-memory
      final query = await _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .get();
      
      final notes = query.docs
          .map((doc) {
            try {
              return Note.fromFirestoreJson(doc.data(), uid: uid, noteId: doc.id);
            } catch (e) {
              debugPrint('[IsarNoteStore] Error parsing note: $e');
              return null;
            }
          })
          .whereType<Note>()
          .toList();
      
      // Filter to pending AI and sort by creation date
      return notes
          .where((note) => note.status == NoteStatus.pendingAi)
          .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    // Normal Isar path
    await init();
    if (_isar != null && _isar!.isOpen) {
      return _isar!.notes
          .filter()
          .statusEqualTo(NoteStatus.pendingAi)
          .sortByCreatedAt()
          .findAll();
    }
    return [];
  }

  /// Count pending AI notes
  Future<int> countPendingAi() async {
    final pending = await getPendingAiNotes();
    return pending.length;
  }

  /// Watch active notes stream - uses Firestore if in fallback mode
  Stream<List<Note>> watchActive() async* {
    if (_useFirestoreOnly) {
      final uid = _getCurrentUserId();
      if (uid == null) {
        debugPrint('[IsarNoteStore] watchActive() - empty stream, user not authenticated');
        yield [];
        return;
      }
      _firestore ??= FirebaseFirestore.instance;
      
      yield* _firestore!
          .collection('users')
          .doc(uid)
          .collection('notes')
          .snapshots()
          .asyncMap((query) async {
        return query.docs
            .map((doc) {
              try {
                return Note.fromFirestoreJson(doc.data(), uid: uid, noteId: doc.id);
              } catch (e) {
                debugPrint('[IsarNoteStore] Error parsing note: $e');
                return null;
              }
            })
            .whereType<Note>()
            .where((note) =>
                note.status != NoteStatus.archived &&
                note.status != NoteStatus.deleted)
            .toList();
      });
      return;
    }

    // Normal Isar path
    await init();
    if (_isar != null && _isar!.isOpen) {
      final query = _isar!.notes.where().build();

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
}
