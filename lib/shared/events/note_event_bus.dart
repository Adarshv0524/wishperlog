import 'dart:async';

class NoteEventBus {
  NoteEventBus._();

  static final NoteEventBus instance = NoteEventBus._();

  final StreamController<String> _noteSavedController =
      StreamController<String>.broadcast();
  final StreamController<String> _noteUpdatedController =
      StreamController<String>.broadcast();

  Stream<String> get onNoteSaved => _noteSavedController.stream;
  Stream<String> get onNoteUpdated => _noteUpdatedController.stream;

  void emitNoteSaved(String noteId) {
    if (noteId.trim().isEmpty) {
      return;
    }
    _noteSavedController.add(noteId);
  }

  void emitNoteUpdated(String noteId) {
    if (noteId.trim().isEmpty) {
      return;
    }
    _noteUpdatedController.add(noteId);
  }
}
