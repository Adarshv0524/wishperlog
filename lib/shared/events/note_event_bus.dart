import 'dart:async';

class NoteEventBus {
  NoteEventBus._();

  static final NoteEventBus instance = NoteEventBus._();

  final StreamController<String> _noteSavedController =
      StreamController<String>.broadcast();

  Stream<String> get onNoteSaved => _noteSavedController.stream;

  void emitNoteSaved(String noteId) {
    if (noteId.trim().isEmpty) {
      return;
    }
    _noteSavedController.add(noteId);
  }
}
