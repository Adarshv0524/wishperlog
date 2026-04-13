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
      return '⏰';
    case NoteCategory.ideas:
      return '💡';
    case NoteCategory.followUp:
      return '🔁';
    case NoteCategory.journal:
      return '📔';
    case NoteCategory.general:
      return '📝';
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

String _normalizeInferenceText(String raw) {
  return normalizeEnumToken(raw)
      .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

bool _hasPhrase(String text, List<String> phrases) {
  for (final phrase in phrases) {
    if (RegExp(r'\b' + RegExp.escape(phrase) + r'\b').hasMatch(text)) {
      return true;
    }
  }
  return false;
}

// ── Hindi (romanised/transliterated) keyword banks ────────────────────────
const _hiFollowUp = [
  'follow karo', 'follow up karo', 'puchna hai', 'reply karo',
  'update lo', 'baat karo',
];
const _hiDateSignals = [
  'kal', 'aaj', 'subah', 'shaam', 'raat ko', 'is hafte', 'agli baar',
  'yaad rakhna', 'mujhe yaad dilana', 'reminder', 'deadline',
];
const _hiTaskSignals = [
  'karna hai', 'karo', 'lena hai', 'bhejo', 'call karo', 'book karo',
  'likhna hai', 'khareedna', 'dena hai', 'fix karo', 'batao',
];
const _hiIdeaSignals = [
  'kya agar', 'ek idea', 'sochna chahiye', 'explore karo', 'shayad',
];

// ── Telugu (romanised) keyword banks ─────────────────────────────────────
const _teFollowUp = [
  'follow up cheyyali', 'chudali', 'update telusukovali',
];
const _teDateSignals = [
  'repu', 'ee roju', 'ee vaaram', 'remind cheyyandi', 'gurtu pettukovali',
];
const _teTaskSignals = [
  'cheyyali', 'pampali', 'call cheyyali', 'book cheyyali', 'fix cheyyali',
];

NoteCategory inferCategoryFromText(String raw) {
  final text = _normalizeInferenceText(raw);
  if (text.isEmpty) return NoteCategory.general;

  // Follow-up detection (English + Hindi + Telugu)
  if (_hasPhrase(text, const [
    'follow up', 'followup', 'check in', 'check with', 'ping',
    'any update on', 'touch base', 'get back to',
    ..._hiFollowUp, ..._teFollowUp,
  ])) {
    return NoteCategory.followUp;
  }

  final hasDateSignal = _hasPhrase(text, const [
    'today', 'tomorrow', 'tonight',
    ..._hiDateSignals, ..._teDateSignals,
    'next monday',
    'next tuesday',
    'next wednesday',
    'next thursday',
    'next friday',
    'next saturday',
    'next sunday',
    'this monday',
    'this tuesday',
    'this wednesday',
    'this thursday',
    'this friday',
    'this saturday',
    'this sunday',
    'this week',
    'next week',
    'remind me',
    'reminder',
  ]) ||
      RegExp(r'\b\d{1,2}(:\d{2})?\s?(am|pm)?\b').hasMatch(text) ||
      RegExp(r'\b\d{4}-\d{2}-\d{2}\b').hasMatch(text);
  if (hasDateSignal) {
    return NoteCategory.reminders;
  }

  final actionVerbAtStart = RegExp(
    r'^(call|buy|book|send|email|text|reply|fix|finish|review|update|draft|write|prepare|submit|pay|schedule|move|order|install|create|check|clean|plan|meet|join|ring)\b',
  ).hasMatch(text);
  final actionSignal = actionVerbAtStart || _hasPhrase(text, const [
    'to do', 'todo', 'need to', 'must', 'should', 'have to', 'remember to',
    ..._hiTaskSignals, ..._teTaskSignals,
  ]);
  if (actionSignal) {
    return NoteCategory.tasks;
  }

  if (_hasPhrase(text, const [
    'idea', 'brainstorm', 'what if', 'could be', 'maybe', 'explore', 'consider',
    ..._hiIdeaSignals,
  ])) {
    return NoteCategory.ideas;
  }

  if (_hasPhrase(text, const [
    'i feel',
    'today i',
    'grateful',
    'frustrated',
    'happy',
    'sad',
    'reflect',
    'reflection',
    'note to self',
    'learned',
  ])) {
    return NoteCategory.journal;
  }

  return NoteCategory.general;
}

NoteCategory parseCategory(String raw) {
  final value = normalizeEnumToken(raw);
  switch (value) {
    case 'task':
    case 'tasks':
      return NoteCategory.tasks;
    case 'reminder':
    case 'reminders':
      return NoteCategory.reminders;
    case 'idea':
    case 'ideas':
      return NoteCategory.ideas;
    case 'followup':
    case 'follow up':
    case 'follow-up':
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

String saveOriginPrefix(String aiModel, {bool wasFallback = false}) {
  final model = normalizeEnumToken(aiModel);
  if (wasFallback ||
      model.startsWith('local') ||
      model.contains('fallback') ||
      model.startsWith('sys')) {
    return 'sys';
  }
  return 'AI';
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
    // ISSUE-10: these were previously falling through to homeWritingBox.
    case 'google tasks':
    case 'googletasks':
      return CaptureSource.googleTasks;
    case 'google calendar':
    case 'googlecalendar':
      return CaptureSource.googleCalendar;
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
