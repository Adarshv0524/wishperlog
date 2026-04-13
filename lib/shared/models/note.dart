import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:isar/isar.dart';

import 'enums.dart';
import 'note_helpers.dart';

part 'note.g.dart';

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

@collection
class Note {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  String noteId;
  String uid;
  String rawTranscript;
  /// English translation of the original content when the input was non-English.
  /// Null if the note content is already in English.
  String? translatedContent;
  /// English translation of the title when the input was non-English.
  String? translatedTitle;
  String title;
  String cleanBody;

  @Enumerated(EnumType.name)
  NoteCategory category;

  @Enumerated(EnumType.name)
  NotePriority priority;

  DateTime? extractedDate;
  DateTime createdAt;
  DateTime updatedAt;

  @Index()
  @Enumerated(EnumType.name)
  NoteStatus status;

  String aiModel;
  String? gcalEventId;
  String? gtaskId;

  @Enumerated(EnumType.name)
  CaptureSource source;

  DateTime? syncedAt;

  Note({
    required this.noteId,
    required this.uid,
    required this.rawTranscript,
    this.translatedContent,
    this.translatedTitle,
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
    String? translatedContent,
    String? translatedTitle,
    bool clearTranslatedContent = false,
    bool clearTranslatedTitle = false,
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
      translatedContent: clearTranslatedContent
        ? null
        : (translatedContent ?? this.translatedContent),
      translatedTitle: clearTranslatedTitle
        ? null
        : (translatedTitle ?? this.translatedTitle),
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
    // ISSUE-10: Use typed Timestamp fields so Firestore can sort/query server-side.
    return {
      'note_id': noteId,
      'uid': uid,
      'raw_transcript': rawTranscript,
      'translated_content': translatedContent,
      'translated_title': translatedTitle,
      'title': title,
      'clean_body': cleanBody,
      'category': category.name,
      'priority': priority.name,
      'ai_model': aiModel,
      'status': status.name,
      'source': source.name,
        'extracted_date': extractedDate != null
          ? firestore.Timestamp.fromDate(extractedDate!)
          : null,
        'created_at': firestore.Timestamp.fromDate(createdAt),
        'updated_at': firestore.Timestamp.fromDate(updatedAt),
        'synced_at': syncedAt != null
          ? firestore.Timestamp.fromDate(syncedAt!)
          : null,
      'gtask_id': gtaskId,
      'gcal_event_id': gcalEventId,
      'is_deleted': status == NoteStatus.deleted,
    };
  }

  Map<String, Object?> toSqliteMap() {
    return {
      'note_id': noteId,
      'uid': uid,
      'raw_transcript': rawTranscript,
      'translated_content': translatedContent,
      'translated_title': translatedTitle,
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
      translatedContent: row['translated_content']?.toString(),
      translatedTitle: row['translated_title']?.toString(),
      title: _readString(row, 'title'),
      cleanBody: _readString(row, 'clean_body'),
      category: parseCategory(_readString(row, 'category')),
      priority: parsePriority(_readString(row, 'priority')),
      extractedDate: _readDate(row['extracted_date']),
      createdAt: _readDate(row['created_at']) ?? DateTime.now(),
      updatedAt: _readDate(row['updated_at']) ?? DateTime.now(),
      status: parseStatus(_readString(row, 'status')),
      aiModel: _readString(row, 'ai_model'),
      gcalEventId: row['gcal_event_id']?.toString(),
      gtaskId: row['gtask_id']?.toString(),
      source: parseSource(_readString(row, 'source')),
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
      translatedContent: json['translated_content'] as String?,
      translatedTitle: json['translated_title'] as String?,
      title: (json['title'] as String?)?.trim().isNotEmpty == true
          ? (json['title'] as String).trim()
          : 'Quick note',
      cleanBody:
          (json['clean_body'] as String?)?.trim() ??
          (json['raw_transcript'] as String?)?.trim() ??
          '',
      category: parseCategory(
        (json['category'] as String?) ?? NoteCategory.general.name,
      ),
      priority: parsePriority(
        (json['priority'] as String?) ?? NotePriority.medium.name,
      ),
      extractedDate: _readFirestoreDate(json['extracted_date']),
      createdAt: _readFirestoreDate(json['created_at']) ?? DateTime.now(),
      updatedAt: _readFirestoreDate(json['updated_at']) ?? DateTime.now(),
      status: parseStatus(
        (json['status'] as String?) ?? NoteStatus.active.name,
      ),
      aiModel: (json['ai_model'] as String?) ?? '',
      gcalEventId: json['gcal_event_id'] as String?,
      gtaskId: json['gtask_id'] as String?,
      source: parseSource(
        (json['source'] as String?) ?? CaptureSource.homeWritingBox.name,
      ),
      syncedAt: _readFirestoreDate(json['synced_at']),
    );
  }

  static String _readString(Map<String, Object?> row, String key) {
    return row[key]?.toString() ?? '';
  }

  static DateTime? _readDate(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  /// Reads a date field that may be a Firestore [Timestamp] (new) or an ISO
  /// [String] (legacy documents written before ISSUE-10 was fixed).
  static DateTime? _readFirestoreDate(Object? value) {
    if (value == null) return null;
    if (value is firestore.Timestamp) return value.toDate();
    return DateTime.tryParse(value.toString());
  }
}
