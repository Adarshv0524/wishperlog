import 'package:flutter/material.dart';
import 'package:wishperlog/shared/models/enums.dart';

const List<NoteCategory> kAllNoteCategories = [
  NoteCategory.tasks,
  NoteCategory.reminders,
  NoteCategory.ideas,
  NoteCategory.followUp,
  NoteCategory.journal,
  NoteCategory.general,
];

String categoryLabel(NoteCategory category) {
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

String categoryEmoji(NoteCategory category) {
  switch (category) {
    case NoteCategory.tasks:
      return '✅';
    case NoteCategory.reminders:
      return '🔔';
    case NoteCategory.ideas:
      return '💡';
    case NoteCategory.followUp:
      return '📥';
    case NoteCategory.journal:
      return '📖';
    case NoteCategory.general:
      return '📂';
  }
}

IconData categoryIcon(NoteCategory category) {
  switch (category) {
    case NoteCategory.tasks:
      return Icons.check_circle_outline;
    case NoteCategory.reminders:
      return Icons.notifications_none_rounded;
    case NoteCategory.ideas:
      return Icons.lightbulb_outline_rounded;
    case NoteCategory.followUp:
      return Icons.reply_rounded;
    case NoteCategory.journal:
      return Icons.menu_book_rounded;
    case NoteCategory.general:
      return Icons.grid_view_rounded;
  }
}

String normalizeEnumToken(String raw) {
  return raw
      .trim()
      .replaceAllMapped(
        RegExp(r'([a-z])([A-Z])'),
        (match) => '${match.group(1)} ${match.group(2)}',
      )
      .toLowerCase()
      .replaceAll(RegExp(r'[_-]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

NoteCategory parseCategory(String raw) {
  final value = normalizeEnumToken(raw);
  switch (value) {
    case 'tasks':
      return NoteCategory.tasks;
    case 'reminders':
      return NoteCategory.reminders;
    case 'ideas':
      return NoteCategory.ideas;
    case 'followup':
    case 'follow up':
      return NoteCategory.followUp;
    case 'journal':
      return NoteCategory.journal;
    case 'general':
    default:
      return NoteCategory.general;
  }
}

NotePriority parsePriority(String raw) {
  switch (normalizeEnumToken(raw)) {
    case 'high':
      return NotePriority.high;
    case 'low':
      return NotePriority.low;
    case 'medium':
    default:
      return NotePriority.medium;
  }
}

NoteStatus parseStatus(String raw) {
  switch (normalizeEnumToken(raw)) {
    case 'archived':
      return NoteStatus.archived;
    case 'deleted':
      return NoteStatus.deleted;
    case 'pending ai':
      return NoteStatus.pendingAi;
    case 'active':
    default:
      return NoteStatus.active;
  }
}

CaptureSource parseSource(String raw) {
  switch (normalizeEnumToken(raw)) {
    case 'voice overlay':
      return CaptureSource.voiceOverlay;
    case 'text overlay':
      return CaptureSource.textOverlay;
    case 'shortcut tile':
      return CaptureSource.shortcutTile;
    case 'notification':
      return CaptureSource.notification;
    case 'home writing box':
    default:
      return CaptureSource.homeWritingBox;
  }
}

int priorityWeight(NotePriority priority) {
  switch (priority) {
    case NotePriority.high:
      return 0;
    case NotePriority.medium:
      return 1;
    case NotePriority.low:
      return 2;
  }
}

Color priorityColor(NotePriority priority) {
  switch (priority) {
    case NotePriority.high:
      return const Color(0xFFD64545);
    case NotePriority.medium:
      return const Color(0xFFDEB437);
    case NotePriority.low:
      return const Color(0xFF9CA3AF);
  }
}
