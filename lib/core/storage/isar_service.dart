import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wishperlog/shared/models/note.dart';

class IsarService {
  IsarService._();

  static final IsarService instance = IsarService._();

  Future<Isar> init() async {
    final existing = Isar.getInstance();
    if (existing != null) {
      return existing;
    }

    final dir = await getApplicationSupportDirectory();
    return Isar.open([NoteSchema], directory: dir.path, inspector: false);
  }
}
