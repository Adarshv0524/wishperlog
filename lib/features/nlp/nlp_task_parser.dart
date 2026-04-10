// lib/features/nlp/nlp_task_parser.dart
//
// Lightweight, zero-dependency NLP parser for task/reminder extraction.
// Runs synchronously on the main isolate — no network needed.
// Supplements AI classification for instant feedback.

import 'package:wishperlog/shared/models/enums.dart';

class NlpParseResult {
  const NlpParseResult({
    required this.category,
    required this.priority,
    this.extractedDate,
    this.cleanTitle,
  });

  final NoteCategory category;
  final NotePriority priority;
  final DateTime? extractedDate;
  final String? cleanTitle;
}

abstract final class NlpTaskParser {
  NlpTaskParser._();

  // ── Category detection ────────────────────────────────────────────────────

  static const _taskKeywords = [
    'todo', 'to-do', 'task', 'complete', 'finish', 'submit', 'send',
    'write', 'prepare', 'fix', 'deploy', 'buy', 'call', 'email',
    'review', 'update', 'check', 'do', 'make',
  ];

  static const _reminderKeywords = [
    'remind', 'reminder', 'don\'t forget', 'remember', 'alarm',
    'alert', 'notify', 'schedule',
  ];

  static const _ideaKeywords = [
    'idea', 'thought', 'concept', 'brainstorm', 'maybe', 'what if',
    'could', 'explore', 'consider',
  ];

  static const _followUpKeywords = [
    'follow up', 'follow-up', 'check in', 'ping', 'circle back',
    'get back', 'revisit', 'track',
  ];

  static const _journalKeywords = [
    'today i', 'felt', 'feeling', 'mood', 'diary', 'journal',
    'reflection', 'note to self',
  ];

  // ── Priority detection ────────────────────────────────────────────────────

  static const _highPriority = [
    'urgent', 'asap', 'critical', 'immediately', 'now',
    'high priority', 'emergency', 'crucial', 'deadline',
  ];

  static const _lowPriority = [
    'someday', 'maybe later', 'eventually', 'if time', 'low priority',
    'not urgent', 'optional', 'nice to have',
  ];

  // ── Date patterns ─────────────────────────────────────────────────────────

  static final _relativeDate = RegExp(
    r'\b(today|tomorrow|next\s+(?:week|month|monday|tuesday|wednesday|thursday|friday|saturday|sunday))\b',
    caseSensitive: false,
  );

  static final _absoluteDate = RegExp(
    r'\b(\d{1,2})[\/\-](\d{1,2})(?:[\/\-](\d{2,4}))?\b',
  );

  static final _monthDate = RegExp(
    r'\b(jan(?:uary)?|feb(?:ruary)?|mar(?:ch)?|apr(?:il)?|may|jun(?:e)?|jul(?:y)?|aug(?:ust)?|sep(?:tember)?|oct(?:ober)?|nov(?:ember)?|dec(?:ember)?)\s+(\d{1,2})(?:st|nd|rd|th)?\b',
    caseSensitive: false,
  );

  // ── Public API ────────────────────────────────────────────────────────────

  static NlpParseResult parse(String text) {
    final lower = text.toLowerCase();

    return NlpParseResult(
      category:      _detectCategory(lower),
      priority:      _detectPriority(lower),
      extractedDate: _extractDate(lower, DateTime.now()),
      cleanTitle:    _cleanTitle(text),
    );
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  static NoteCategory _detectCategory(String lower) {
    if (_containsAny(lower, _taskKeywords))     return NoteCategory.tasks;
    if (_containsAny(lower, _reminderKeywords)) return NoteCategory.reminders;
    if (_containsAny(lower, _ideaKeywords))     return NoteCategory.ideas;
    if (_containsAny(lower, _followUpKeywords)) return NoteCategory.followUp;
    if (_containsAny(lower, _journalKeywords))  return NoteCategory.journal;
    return NoteCategory.general;
  }

  static NotePriority _detectPriority(String lower) {
    if (_containsAny(lower, _highPriority)) return NotePriority.high;
    if (_containsAny(lower, _lowPriority))  return NotePriority.low;
    return NotePriority.medium;
  }

  static DateTime? _extractDate(String lower, DateTime now) {
    // Relative dates
    final relMatch = _relativeDate.firstMatch(lower);
    if (relMatch != null) {
      final phrase = relMatch.group(1)!.toLowerCase();
      if (phrase == 'today') return DateTime(now.year, now.month, now.day);
      if (phrase == 'tomorrow') return now.add(const Duration(days: 1));
      if (phrase.startsWith('next')) {
        final dayName = phrase.split(RegExp(r'\s+')).last;
        return _nextWeekday(now, dayName);
      }
    }

    // Month + day  e.g. "June 15"
    final monthMatch = _monthDate.firstMatch(lower);
    if (monthMatch != null) {
      final month = _parseMonth(monthMatch.group(1)!);
      final day   = int.tryParse(monthMatch.group(2) ?? '');
      if (month != null && day != null) {
        var year = now.year;
        final candidate = DateTime(year, month, day);
        if (candidate.isBefore(DateTime(now.year, now.month, now.day))) {
          year++;
        }
        return DateTime(year, month, day);
      }
    }

    // dd/mm or dd-mm
    final absMatch = _absoluteDate.firstMatch(lower);
    if (absMatch != null) {
      final d = int.tryParse(absMatch.group(1) ?? '');
      final m = int.tryParse(absMatch.group(2) ?? '');
      final y = int.tryParse(absMatch.group(3) ?? '');
      if (d != null && m != null && d <= 31 && m <= 12) {
        return DateTime(y ?? now.year, m, d);
      }
    }

    return null;
  }

  static String _cleanTitle(String text) {
    // Remove common filler prefixes
    const prefixes = [
      'todo:', 'task:', 'remind me to', 'reminder:', 'note to self:',
      'idea:', 'don\'t forget to', 'don\'t forget',
    ];
    var clean = text.trim();
    for (final p in prefixes) {
      if (clean.toLowerCase().startsWith(p)) {
        clean = clean.substring(p.length).trim();
        break;
      }
    }
    // Capitalise first letter
    if (clean.isEmpty) return clean;
    return clean[0].toUpperCase() + clean.substring(1);
  }

  static bool _containsAny(String text, List<String> keywords) {
    for (final k in keywords) {
      if (text.contains(k)) return true;
    }
    return false;
  }

  static DateTime _nextWeekday(DateTime now, String dayName) {
    const days = {
      'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4,
      'friday': 5, 'saturday': 6, 'sunday': 7, 'week': 7,
    };
    final target = days[dayName] ?? (now.weekday + 7);
    var diff = target - now.weekday;
    if (diff <= 0) diff += 7;
    return now.add(Duration(days: diff));
  }

  static int? _parseMonth(String name) {
    const m = {
      'jan': 1, 'january': 1, 'feb': 2, 'february': 2, 'mar': 3, 'march': 3,
      'apr': 4, 'april': 4, 'may': 5, 'jun': 6, 'june': 6, 'jul': 7,
      'july': 7, 'aug': 8, 'august': 8, 'sep': 9, 'september': 9,
      'oct': 10, 'october': 10, 'nov': 11, 'november': 11, 'dec': 12,
      'december': 12,
    };
    return m[name.toLowerCase()];
  }
}