import 'enums.dart';
import 'note_helpers.dart';

int fastHash(String string) {
  var hash = 0xcbf29ce484222000;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}

class Note {
  final String noteId;
  final String uid;
  final String rawTranscript;
  final String title;
  final String cleanBody;
  final NoteCategory category;
  final NotePriority priority;
  final DateTime? extractedDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NoteStatus status;
  final String aiModel;
  final String? gcalEventId;
  final String? gtaskId;
  final CaptureSource source;
  final DateTime? syncedAt;

  Note({
    required this.noteId,
    required this.uid,
    required this.rawTranscript,
    required this.title,
    required this.cleanBody,
    required this.category,
    required this.priority,
    this.extractedDate,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.aiModel,
    this.gcalEventId,
    this.gtaskId,
    required this.source,
    this.syncedAt,
  });

  Note copyWith({
    String? noteId,
    String? uid,
    String? rawTranscript,
    String? title,
    String? cleanBody,
    NoteCategory? category,
    NotePriority? priority,
    DateTime? extractedDate,
    bool clearExtractedDate = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    NoteStatus? status,
    String? aiModel,
    String? gcalEventId,
    bool clearGcalEventId = false,
    String? gtaskId,
    bool clearGtaskId = false,
    CaptureSource? source,
    DateTime? syncedAt,
    bool clearSyncedAt = false,
  }) {
    return Note(
      noteId: noteId ?? this.noteId,
      uid: uid ?? this.uid,
      rawTranscript: rawTranscript ?? this.rawTranscript,
      title: title ?? this.title,
      cleanBody: cleanBody ?? this.cleanBody,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      extractedDate: clearExtractedDate
          ? null
          : (extractedDate ?? this.extractedDate),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      aiModel: aiModel ?? this.aiModel,
      gcalEventId: clearGcalEventId ? null : (gcalEventId ?? this.gcalEventId),
      gtaskId: clearGtaskId ? null : (gtaskId ?? this.gtaskId),
      source: source ?? this.source,
      syncedAt: clearSyncedAt ? null : (syncedAt ?? this.syncedAt),
    );
  }

  Map<String, dynamic> toFirestoreJson() {
    return {
      'note_id': noteId,
      'uid': uid,
      'raw_transcript': rawTranscript,
      'title': title,
      'clean_body': cleanBody,
      'category': category.name,
      'priority': priority.name,
      'extracted_date': extractedDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status.name,
      'ai_model': aiModel,
      'gcal_event_id': gcalEventId,
      'gtask_id': gtaskId,
      'source': source.name,
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  Map<String, Object?> toSqliteMap() {
    return {
      'note_id': noteId,
      'uid': uid,
      'raw_transcript': rawTranscript,
      'title': title,
      'clean_body': cleanBody,
      'category': category.name,
      'priority': priority.name,
      'extracted_date': extractedDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'status': status.name,
      'ai_model': aiModel,
      'gcal_event_id': gcalEventId,
      'gtask_id': gtaskId,
      'source': source.name,
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory Note.fromSqliteMap(Map<String, Object?> row) {
    return Note(
      noteId: _readString(row, 'note_id'),
      uid: _readString(row, 'uid'),
      rawTranscript: _readString(row, 'raw_transcript'),
      title: _readString(row, 'title'),
      cleanBody: _readString(row, 'clean_body'),
      category: parseCategory(_readString(row, 'category')),
      priority: parsePriority(_readString(row, 'priority')),
      extractedDate: _readDate(row['extracted_date']),
      createdAt: _readDate(row['created_at']) ?? DateTime.now(),
      updatedAt: _readDate(row['updated_at']) ?? DateTime.now(),
      status: _parseStatus(_readString(row, 'status')),
      aiModel: _readString(row, 'ai_model'),
      gcalEventId: row['gcal_event_id']?.toString(),
      gtaskId: row['gtask_id']?.toString(),
      source: _parseSource(_readString(row, 'source')),
      syncedAt: _readDate(row['synced_at']),
    );
  }

  factory Note.fromFirestoreJson(
    Map<String, dynamic> json, {
    required String uid,
    required String noteId,
  }) {
    return Note(
      noteId: noteId,
      uid: uid,
      rawTranscript: (json['raw_transcript'] as String?)?.trim() ?? '',
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Quick note',
      cleanBody: (json['clean_body'] as String?)?.trim() ??
          (json['raw_transcript'] as String?)?.trim() ??
          '',
      category: parseCategory((json['category'] as String?) ?? 'general'),
      priority: parsePriority((json['priority'] as String?) ?? 'medium'),
      extractedDate: DateTime.tryParse((json['extracted_date'] as String?) ?? ''),
      createdAt: DateTime.tryParse((json['created_at'] as String?) ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse((json['updated_at'] as String?) ?? '') ??
          DateTime.now(),
      status: _parseStatus((json['status'] as String?) ?? 'active'),
      aiModel: (json['ai_model'] as String?) ?? '',
      gcalEventId: json['gcal_event_id'] as String?,
      gtaskId: json['gtask_id'] as String?,
      source: _parseSource((json['source'] as String?) ?? 'homeWritingBox'),
      syncedAt: DateTime.tryParse((json['synced_at'] as String?) ?? ''),
    );
  }

  static NoteStatus _parseStatus(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'archived':
        return NoteStatus.archived;
      case 'pendingai':
      case 'pending_ai':
        return NoteStatus.pendingAi;
      case 'active':
      default:
        return NoteStatus.active;
    }
  }

  static CaptureSource _parseSource(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'voiceoverlay':
      case 'voice_overlay':
        return CaptureSource.voiceOverlay;
      case 'textoverlay':
      case 'text_overlay':
        return CaptureSource.textOverlay;
      case 'homewritingbox':
      case 'home_writing_box':
      default:
        return CaptureSource.homeWritingBox;
    }
  }

  static String _readString(Map<String, Object?> row, String key) {
    return row[key]?.toString() ?? '';
  }

  static DateTime? _readDate(Object? value) {
    if (value == null) {
      return null;
    }
    return DateTime.tryParse(value.toString());
  }
}
