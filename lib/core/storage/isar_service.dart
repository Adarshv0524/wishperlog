import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wishperlog/shared/models/note.dart';

class IsarService {
  IsarService._();

  static final IsarService instance = IsarService._();
  Future<Isar>? _opening;

  Future<Isar> init() async {
    final existing = Isar.getInstance();
    if (existing != null && existing.isOpen) {
      try {
        existing.collection<Note>();
        return existing;
      } catch (_) {
        debugPrint('[IsarService] Instance exists but not fully ready, reinitializing');
      }
    }

    final inFlight = _opening;
    if (inFlight != null) {
      return inFlight;
    }

    final openFuture = _openWithRecovery();
    _opening = openFuture;
    try {
      final db = await openFuture;
      for (var attempt = 0; attempt < 5; attempt++) {
        try {
          db.collection<Note>();
          debugPrint('[IsarService] Isar fully initialized and ready');
          return db;
        } catch (_) {
          if (attempt < 4) {
            await Future<void>.delayed(const Duration(milliseconds: 50));
          } else {
            return db;
          }
        }
      }
      return db;
    } finally {
      if (identical(_opening, openFuture)) {
        _opening = null;
      }
    }
  }

  Future<Isar> _openWithRecovery() async {
    final dir = await getApplicationSupportDirectory();
    try {
      return await _openInstance(dir.path);
    } on IsarError catch (error) {
      final message = error.toString().toLowerCase();
      if (!message.contains('collection id is invalid')) {
        rethrow;
      }

      await _purgeIncompatibleIsarFiles(dir);
      return _openInstance(dir.path);
    }
  }

  Future<Isar> _openInstance(String directoryPath) async {
    try {
      return await Isar.open(
        [NoteSchema],
        directory: directoryPath,
        inspector: false,
      );
    } on IsarError catch (error) {
      final message = error.toString().toLowerCase();
      if (!message.contains('already been opened')) {
        rethrow;
      }

      for (var attempt = 0; attempt < 20; attempt++) {
        final existing = Isar.getInstance();
        if (existing != null) {
          return existing;
        }
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      rethrow;
    }
  }

  Future<void> _purgeIncompatibleIsarFiles(Directory dir) async {
    if (!await dir.exists()) {
      return;
    }

    await for (final entity in dir.list()) {
      if (entity is! File) {
        continue;
      }

      final name = entity.uri.pathSegments.last.toLowerCase();
      final isIsarArtifact =
          name.contains('.isar') &&
          (name.startsWith('default') || name.startsWith('wishperlog'));
      if (!isIsarArtifact) {
        continue;
      }

      await entity.delete();
      if (kDebugMode) {
        debugPrint('Deleted incompatible Isar artifact: ${entity.path}');
      }
    }
  }
}
