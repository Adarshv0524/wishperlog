import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';

@Deprecated('Use CaptureService.ingestRawCapture instead.')
class NoteSaveService {
  NoteSaveService({dynamic auth, dynamic firestore,
      dynamic isarNoteStore, dynamic noteEventBus})
      : _capture = CaptureService();

  final CaptureService _capture;

  Future<Note> saveNote({
    required String rawTranscript,
    required CaptureSource source,
    bool syncToCloud = true,
  }) async {
    final note = await _capture.ingestRawCapture(
      rawTranscript: rawTranscript,
      source: source,
      syncToCloud: syncToCloud,
    );
    if (note == null) throw Exception('[NoteSaveService] Empty transcript');
    return note;
  }
}