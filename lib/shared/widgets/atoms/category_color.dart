import 'package:flutter/material.dart';
import 'package:wishperlog/shared/models/enums.dart';

/// Gets the category chromatic color for a NoteCategory.
/// These colors are immutable brand tokens (same in dark and light modes).
Color getCategoryColor(NoteCategory category) {
  switch (category) {
    case NoteCategory.tasks:
      return const Color(0xFF60A5FA); // Cyan
    case NoteCategory.reminders:
      return const Color(0xFFF472B6); // Pink
    case NoteCategory.ideas:
      return const Color(0xFFFBBF24); // Amber
    case NoteCategory.followUp:
      return const Color(0xFF34D399); // Emerald
    case NoteCategory.journal:
      return const Color(0xFFA78BFA); // Purple
    case NoteCategory.general:
      return const Color(0xFF94A3B8); // Slate
  }
}

/// Gets the display label for a category.
String getCategoryLabel(NoteCategory category) {
  switch (category) {
    case NoteCategory.tasks:
      return 'Tasks';
    case NoteCategory.reminders:
      return 'Reminders';
    case NoteCategory.ideas:
      return 'Ideas';
    case NoteCategory.followUp:
      return 'Follow-up';
    case NoteCategory.journal:
      return 'Journal';
    case NoteCategory.general:
      return 'General';
  }
}

/// Extension on NoteCategory for convenient access to label.
extension NoteCategoryX on NoteCategory {
  String get label => getCategoryLabel(this);

  Color get color => getCategoryColor(this);
}
