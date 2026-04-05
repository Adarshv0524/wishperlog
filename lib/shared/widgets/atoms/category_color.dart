import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/models/enums.dart';

/// Gets the category chromatic color for a NoteCategory.
/// These colors are immutable brand tokens (same in dark and light modes).
Color getCategoryColor(NoteCategory category) {
  return categoryColor(category);
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
