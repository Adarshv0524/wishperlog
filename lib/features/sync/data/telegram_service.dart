import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:wishperlog/core/config/app_env.dart';
import 'package:wishperlog/features/search/data/smart_note_search.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class TelegramCommandEvent {
  final int updateId;
  final String chatId;
  final int messageId;
  final String command;
  final String commandArgs;
  final String rawText;

  const TelegramCommandEvent({
    required this.updateId,
    required this.chatId,
    required this.messageId,
    required this.command,
    required this.commandArgs,
    required this.rawText,
  });
}

class TelegramUpdateBatch {
  final List<TelegramCommandEvent> events;
  final int nextOffset;

  const TelegramUpdateBatch({required this.events, required this.nextOffset});
}

class TelegramService {
  static const _baseUrl = 'https://api.telegram.org';

  final String _botToken;
  String? _resolvedBotUsername;

  TelegramService({String? botToken})
    : _botToken = botToken ?? AppEnv.telegramBotToken;

  bool get isConfigured => _botToken.isNotEmpty;

  static const List<Map<String, String>> defaultCommands = [
    {'command': 'start', 'description': 'Link and quick welcome'},
    {'command': 'help', 'description': 'Show available commands'},
    {'command': 'status', 'description': 'Show bot connection status'},
    {'command': 'digest', 'description': 'Send priority brief now'},
    {'command': 'top', 'description': 'Show top 3 priorities now'},
    {'command': 'today', 'description': 'Show today summary card'},
    {'command': 'slots', 'description': 'Show configured digest times'},
    {'command': 'stats', 'description': 'Show category + priority stats'},
    {'command': 'find', 'description': 'Search notes by keyword'},
    {'command': 'agenda', 'description': 'Upcoming dated notes'},
    {'command': 'menu', 'description': 'Show quick action panel'},
    {'command': 'focus', 'description': 'Get one focus reminder'},
    {'command': 'nudge', 'description': 'Get a quick motivational nudge'},
    {'command': 'ping', 'description': 'Health check'},
  ];

  Future<String?> resolveBotUsername() async {
    final configured = AppEnv.telegramBotUsername.trim();
    if (configured.isNotEmpty) return configured;
    if (_resolvedBotUsername != null && _resolvedBotUsername!.isNotEmpty) {
      return _resolvedBotUsername;
    }
    if (!isConfigured) return null;

    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/bot$_botToken/getMe'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        debugPrint('[TelegramService] getMe failed: ${response.body}');
        return null;
      }
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final result = data['result'] as Map<String, dynamic>?;
      final username = (result?['username'] ?? '').toString().trim();
      if (username.isEmpty) return null;
      _resolvedBotUsername = username;
      return username;
    } catch (e) {
      debugPrint('[TelegramService] resolveBotUsername error: $e');
      return null;
    }
  }

  Future<bool> registerDefaultCommands() async {
    if (!isConfigured) return false;
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/bot$_botToken/setMyCommands'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'commands': defaultCommands}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        debugPrint('[TelegramService] setMyCommands failed: ${response.body}');
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('[TelegramService] registerDefaultCommands error: $e');
      return false;
    }
  }

  Future<TelegramUpdateBatch> fetchCommandUpdates({
    int offset = 0,
    int timeoutSeconds = 3,
  }) async {
    if (!isConfigured) {
      return TelegramUpdateBatch(events: const [], nextOffset: offset);
    }

    try {
      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/bot$_botToken/getUpdates?offset=$offset&timeout=$timeoutSeconds&allowed_updates=["message"]',
            ),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        debugPrint('[TelegramService] fetchCommandUpdates failed: ${response.body}');
        return TelegramUpdateBatch(events: const [], nextOffset: offset);
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final raw = (body['result'] as List?) ?? const [];
      final events = <TelegramCommandEvent>[];
      var nextOffset = offset;

      for (final item in raw) {
        final entry = item as Map<String, dynamic>;
        final updateId = entry['update_id'] as int? ?? 0;
        if (updateId >= nextOffset) nextOffset = updateId + 1;

        final msg = entry['message'] as Map<String, dynamic>?;
        final text = (msg?['text'] ?? '').toString().trim();
        if (!text.startsWith('/')) continue;

        final chatId = msg?['chat']?['id']?.toString().trim();
        if (chatId == null || chatId.isEmpty) continue;
        final messageId = (msg?['message_id'] as int?) ?? 0;

        final firstToken = text.split(RegExp(r'\s+')).first;
        final args = text.length > firstToken.length
            ? text.substring(firstToken.length).trim()
            : '';
        var command = firstToken;
        if (command.startsWith('/')) {
          command = command.substring(1);
        }
        if (command.contains('@')) {
          command = command.split('@').first;
        }
        command = command.toLowerCase().trim();
        if (command.isEmpty) continue;

        events.add(
          TelegramCommandEvent(
            updateId: updateId,
            chatId: chatId,
            messageId: messageId,
            command: command,
            commandArgs: args,
            rawText: text,
          ),
        );
      }

      return TelegramUpdateBatch(events: events, nextOffset: nextOffset);
    } catch (e) {
      debugPrint('[TelegramService] fetchCommandUpdates error: $e');
      return TelegramUpdateBatch(events: const [], nextOffset: offset);
    }
  }

  String buildHelpMessage() {
    return [
      '<b>WishperLog Bot Commands</b>',
      '',
      '/start - welcome and quick setup',
      '/help - this command list',
      '/status - linked chat and digest status',
      '/digest - send priority brief now',
      '/top - send top 3 priority notes',
      '/today - today summary card',
      '/slots - your digest time slots',
      '/stats - category and priority stats',
      '/find <query> - smart semantic-ish note search',
      '/agenda - upcoming extracted date timeline',
      '/menu - rich action command panel',
      '/focus - one actionable focus item',
      '/nudge - quick motivation prompt',
      '/ping - bot health check',
    ].join('\n');
  }

  /// Fallback linker for setups without bot backend/webhook.
  /// Polls getUpdates and looks for `/start <token>` then returns chat_id.
  Future<String?> resolveChatIdByStartToken({
    required String token,
    Duration timeout = const Duration(seconds: 90),
  }) async {
    if (!isConfigured || token.trim().isEmpty) return null;

    final deadline = DateTime.now().add(timeout);
    var offset = 0;

    while (DateTime.now().isBefore(deadline)) {
      try {
        final response = await http
            .get(
              Uri.parse(
                '$_baseUrl/bot$_botToken/getUpdates?offset=$offset&timeout=8&allowed_updates=["message"]',
              ),
            )
            .timeout(const Duration(seconds: 12));

        if (!_isTelegramOk(response)) {
          debugPrint('[TelegramService] getUpdates failed (ok=false): ${response.body}');
          await Future<void>.delayed(const Duration(seconds: 2));
          continue;
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final updates = (body['result'] as List?) ?? const [];

        for (final update in updates) {
          final entry = update as Map<String, dynamic>;
          final updateId = entry['update_id'] as int? ?? 0;
          if (updateId >= offset) offset = updateId + 1;

          final msg = entry['message'] as Map<String, dynamic>?;
          final text = (msg?['text'] ?? '').toString().trim();
          if (text.isEmpty) continue;

          if (_isMatchingStartToken(text, token)) {
            final chatId = msg?['chat']?['id']?.toString().trim();
            if (chatId != null && chatId.isNotEmpty) {
              return chatId;
            }
          }
        }
      } catch (e) {
        debugPrint('[TelegramService] resolveChatIdByStartToken error: $e');
      }

      // Back-off: 2 s between polls to avoid hammering the API.
      await Future<void>.delayed(const Duration(seconds: 2));
    }

    return null;
  }

  bool _isMatchingStartToken(String text, String token) {
    final normalized = text.trim();
    if (!normalized.startsWith('/start')) return false;
    final parts = normalized.split(RegExp(r'\s+'));
    if (parts.length < 2) return false;
    return parts[1].trim() == token.trim();
  }

  /// Pure formatter — no network, no bot token. Used by MessageStateService.
  static String staticBuildDailyDigest({
    required List<Note> notes,
    required DateTime localDate,
    int maxItems = 3,
    bool topPriorityOnly = true,
    bool includeMediumFallback = true,
  }) {
    return TelegramService().buildDailyDigestMessage(
      notes: notes,
      localDate: localDate,
      maxItems: maxItems,
      topPriorityOnly: topPriorityOnly,
      includeMediumFallback: includeMediumFallback,
    );
  }

  Future<bool> sendDailyDigest({
    required String chatId,
    required List<Note> notes,
    required DateTime localDate,
    int maxItems = 3,
    bool topPriorityOnly = true,
    bool includeMediumFallback = true,
  }) async {
    final text = staticBuildDailyDigest(
      notes: notes,
      localDate: localDate,
      maxItems: maxItems,
      topPriorityOnly: topPriorityOnly,
      includeMediumFallback: includeMediumFallback,
    );
    return sendMessage(
      chatId: chatId,
      text: text,
      replyMarkup: buildDigestActionKeyboard(),
      disableWebPagePreview: true,
    );
  }

  Future<bool> sendPriorityBrief({
    required String chatId,
    required List<Note> notes,
    required DateTime localDate,
  }) {
    return sendDailyDigest(
      chatId: chatId,
      notes: notes,
      localDate: localDate,
      maxItems: 3,
      topPriorityOnly: true,
      includeMediumFallback: true,
    );
  }

  Future<bool> sendTodaySummaryCard({
    required String chatId,
    required List<Note> notes,
    required DateTime localDate,
  }) {
    return sendMessage(
      chatId: chatId,
      text: buildTodaySummaryCardMessage(notes: notes, localDate: localDate),
      silent: true,
    );
  }

  Future<bool> sendScheduleSlots({
    required String chatId,
    required List<String> slots,
  }) {
    final rows = slots.isEmpty ? ['(none)'] : slots.map((s) => '- $s').toList();
    return sendMessage(
      chatId: chatId,
      text: [
        '<b>Digest Time Slots</b>',
        '<pre>${rows.join('\n')}</pre>',
      ].join('\n'),
      replyMarkup: buildDigestActionKeyboard(),
      silent: true,
    );
  }

  Future<bool> sendFindResults({
    required String chatId,
    required String query,
    required List<Note> notes,
    int maxItems = 6,
  }) {
    final clean = query.trim();
    if (clean.isEmpty) {
      return sendMessage(
        chatId: chatId,
        text: [
          '<b>Find Notes</b>',
          'Usage: <code>/find keyword</code>',
          'Examples: <code>/find invoice</code> | <code>/find tasks:deploy</code>',
        ].join('\n'),
        replyMarkup: buildPrimaryActionKeyboard(),
        silent: true,
      );
    }

    final hits = SmartNoteSearch.searchSync(notes, clean, limit: max(1, maxItems));
    if (hits.isEmpty) {
      return sendMessage(
        chatId: chatId,
        text: [
          '<b>Find</b> <code>${_escapeHtml(clean)}</code>',
          '',
          'No matching notes found.',
        ].join('\n'),
        replyMarkup: buildDigestActionKeyboard(),
        silent: true,
      );
    }

    final lines = <String>[
      '<b>Find</b> <code>${_escapeHtml(clean)}</code>',
      '<i>${hits.length} match(es)</i>',
    ];
    for (var i = 0; i < hits.length; i++) {
      final hit = hits[i];
      final title = _escapeHtml(_truncate(
        hit.note.title.trim().isEmpty ? 'Untitled note' : hit.note.title.trim(),
        58,
      ));
      final snippet = _escapeHtml(_truncate(
        hit.snippet.trim().isEmpty
            ? _firstMeaningfulLine(hit.note.cleanBody, hit.note.rawTranscript)
            : hit.snippet.trim(),
        78,
      ));
      final score = hit.score.toStringAsFixed(2);
      lines.add(
        '${i + 1}) ${categoryEmoji(hit.note.category)} ${_priorityChip(hit.note.priority)} <b>$title</b> <i>[$score]</i>',
      );
      if (snippet.isNotEmpty) {
        lines.add('   <i>$snippet</i>');
      }
    }

    return sendMessage(
      chatId: chatId,
      text: lines.join('\n'),
      replyMarkup: buildDigestActionKeyboard(),
      silent: true,
      typingBeforeSend: true,
    );
  }

  Future<bool> sendAgenda({
    required String chatId,
    required List<Note> notes,
    required DateTime localNow,
    int horizonDays = 7,
    int maxItems = 8,
  }) {
    final start = DateTime(localNow.year, localNow.month, localNow.day);
    final end = start.add(Duration(days: max(1, horizonDays)));

    final upcoming = notes.where((n) {
      final dt = n.extractedDate?.toLocal();
      if (dt == null) return false;
      return !dt.isBefore(start) && dt.isBefore(end);
    }).toList()
      ..sort((a, b) => (a.extractedDate ?? DateTime(3000)).compareTo(b.extractedDate ?? DateTime(3000)));

    if (upcoming.isEmpty) {
      return sendMessage(
        chatId: chatId,
        text: [
          '<b>Agenda (${horizonDays}d)</b>',
          'No dated notes in the next $horizonDays day(s).',
        ].join('\n'),
        replyMarkup: buildPrimaryActionKeyboard(),
        silent: true,
      );
    }

    final lines = <String>[
      '<b>Agenda (${horizonDays}d)</b>',
      '<i>Now: ${_clock(localNow)}</i>',
    ];

    for (var i = 0; i < min(upcoming.length, max(1, maxItems)); i++) {
      final note = upcoming[i];
      final dt = note.extractedDate!.toLocal();
      final unix = dt.millisecondsSinceEpoch ~/ 1000;
      final title = _escapeHtml(_truncate(
        note.title.trim().isEmpty ? 'Untitled note' : note.title.trim(),
        60,
      ));
      lines.add(
        '${i + 1}) <tg-time unix="$unix" format="wDT">${_escapeHtml(_humanDate(dt))}</tg-time> '
        '${categoryEmoji(note.category)} ${_priorityChip(note.priority)} <b>$title</b>',
      );
    }

    final hidden = upcoming.length - min(upcoming.length, max(1, maxItems));
    if (hidden > 0) {
      lines.add('<i>+$hidden more upcoming</i>');
    }

    return sendMessage(
      chatId: chatId,
      text: lines.join('\n'),
      replyMarkup: buildDigestActionKeyboard(),
      silent: true,
      typingBeforeSend: true,
    );
  }

  Future<bool> sendCommandMenuCard({required String chatId}) {
    return sendMessage(
      chatId: chatId,
      text: [
        '<b>WishperLog Command Deck</b>',
        'Tap any action, then hit send to execute instantly.',
      ].join('\n'),
      replyMarkup: buildAdvancedCommandKeyboard(),
      disableWebPagePreview: true,
      silent: true,
    );
  }

  Future<bool> sendStatsCard({
    required String chatId,
    required List<Note> notes,
    required DateTime localDate,
  }) {
    return sendMessage(
      chatId: chatId,
      text: buildStatsMessage(notes: notes, localDate: localDate),
      replyMarkup: buildDigestActionKeyboard(),
      silent: true,
    );
  }

  Future<bool> sendNudgePack({
    required String chatId,
    required List<Note> notes,
  }) {
    final high = notes.where((n) => n.priority == NotePriority.high).toList();
    final msg = high.isNotEmpty
        ? 'You already have ${high.length} high-priority item(s).\nStart with the top one now for 10 focused minutes.'
        : 'No urgent blockers right now.\nPick one medium task and complete it before your next break.';
    return sendQuickNudge(chatId: chatId, headline: 'Momentum boost', detail: msg);
  }

  Future<bool> sendConnectionConfirmation({required String chatId}) {
    return sendMessage(
      chatId: chatId,
      text: [
        '<b>WishperLog Connected</b>',
        '',
        'You are all set.',
        'Daily priority briefs will be delivered on your schedule.',
        '',
        'Type /help to see available commands.',
      ].join('\n'),
      replyMarkup: buildPrimaryActionKeyboard(),
      silent: true,
    );
  }

  Future<bool> sendQuickNudge({
    required String chatId,
    required String headline,
    String? detail,
    bool typingBeforeSend = false,
  }) {
    final lines = <String>[
      '<b>Quick Nudge</b>',
      _escapeHtml(_truncate(headline.trim(), 110)),
    ];
    if (detail != null && detail.trim().isNotEmpty) {
      lines.add(_escapeHtml(_truncate(detail.trim(), 150)));
    }
    return sendMessage(
      chatId: chatId,
      text: lines.join('\n'),
      typingBeforeSend: typingBeforeSend,
    );
  }

  Future<bool> sendFocusReminder({
    required String chatId,
    required Note note,
  }) {
    final title = _escapeHtml(_truncate(note.title.trim().isEmpty ? 'Untitled note' : note.title.trim(), 90));
    final body = _escapeHtml(_truncate(_firstMeaningfulLine(note.cleanBody, note.rawTranscript), 130));
    return sendMessage(
      chatId: chatId,
      text: [
        '<b>Focus Reminder</b>',
        '${categoryEmoji(note.category)} ${_priorityChip(note.priority)} <b>$title</b>',
        if (body.isNotEmpty) body,
      ].join('\n'),
    );
  }

  Future<bool> sendDigestTestPing({
    required String chatId,
    required DateTime localNow,
  }) {
    return sendMessage(
      chatId: chatId,
      text: [
        '<b>Digest Test Ping</b>',
        'Scheduler is alive at ${_clock(localNow)}.',
        'Next briefs will follow your configured time slots.',
      ].join('\n'),
      replyMarkup: buildPrimaryActionKeyboard(),
      silent: true,
    );
  }

  Map<String, dynamic> buildPrimaryActionKeyboard() {
    return {
      'inline_keyboard': [
        [
          {
            'text': 'Refresh Brief',
            'switch_inline_query_current_chat': '/digest',
          },
          {
            'text': 'Top 3',
            'switch_inline_query_current_chat': '/top',
          },
        ],
        [
          {
            'text': 'Today',
            'switch_inline_query_current_chat': '/today',
          },
          {
            'text': 'Stats',
            'switch_inline_query_current_chat': '/stats',
          },
        ],
        [
          {
            'text': 'Help',
            'switch_inline_query_current_chat': '/help',
          },
        ],
      ],
    };
  }

  Map<String, dynamic> buildAdvancedCommandKeyboard() {
    final keyboard = {
      'inline_keyboard': [
        [
          {'text': 'Digest', 'switch_inline_query_current_chat': '/digest'},
          {'text': 'Agenda', 'switch_inline_query_current_chat': '/agenda'},
        ],
        [
          {'text': 'Search', 'switch_inline_query_current_chat': '/find '},
          {'text': 'Focus', 'switch_inline_query_current_chat': '/focus'},
        ],
        [
          {'text': '/find …', 'switch_inline_query_current_chat': '/find '},
          {'text': '/agenda', 'switch_inline_query_current_chat': '/agenda'},
        ],
      ],
    };

    final username = _resolvedBotUsername ?? AppEnv.telegramBotUsername.trim();
    if (username.isNotEmpty) {
      (keyboard['inline_keyboard'] as List).add([
        {'text': 'Open Bot', 'url': 'https://t.me/$username'},
      ]);
    }
    return keyboard;
  }

  Map<String, dynamic> buildDigestActionKeyboard() {
    final keyboard = buildPrimaryActionKeyboard();
    final username = _resolvedBotUsername ?? AppEnv.telegramBotUsername.trim();
    if (username.isNotEmpty) {
      final rows = (keyboard['inline_keyboard'] as List).cast<List>();
      rows.add([
        {
          'text': 'Open Bot',
          'url': 'https://t.me/$username',
        },
      ]);
      keyboard['inline_keyboard'] = rows;
    }
    return keyboard;
  }

  String buildDailyDigestMessage({
    required List<Note> notes,
    required DateTime localDate,
    int maxItems = 3,
    bool topPriorityOnly = true,
    bool includeMediumFallback = true,
  }) {
    final dayLabel = _humanDate(localDate);
    final highlights = selectDigestHighlights(
      notes: notes,
      maxItems: maxItems,
      topPriorityOnly: topPriorityOnly,
      includeMediumFallback: includeMediumFallback,
    );

    if (highlights.isEmpty) {
      return [
        '<b>WishperLog Brief</b>',
        '<pre>${_asciiCard([
          'DATE  $dayLabel',
          'TIME  ${_clock(localDate)}',
          '',
          'No urgent items now.',
          'You are clear.',
        ])}</pre>',
      ].join('\n');
    }

    final highCount = notes.where((n) => n.priority == NotePriority.high).length;
    final mediumCount = notes.where((n) => n.priority == NotePriority.medium).length;
    final usingFallback = highCount == 0 && includeMediumFallback;

    final lines = <String>[
      '<b>WishperLog Brief</b>',
      '<pre>${_asciiCard([
        'DATE   $dayLabel',
        'TIME   ${_clock(localDate)}',
        if (highCount > 0) 'HIGH   $highCount open',
        if (highCount == 0 && usingFallback) 'HIGH   0 | MED queue: $mediumCount',
      ])}</pre>',
      '<b>Top 3</b>',
    ];

    for (var i = 0; i < highlights.length; i++) {
      lines.add(_formatDigestLine(index: i + 1, note: highlights[i]));
    }

    final hidden = (usingFallback ? mediumCount : highCount) - highlights.length;
    if (hidden > 0) {
      lines.add('<i>+$hidden more pending</i>');
    }

    return lines.join('\n');
  }

  String buildTodaySummaryCardMessage({
    required List<Note> notes,
    required DateTime localDate,
  }) {
    final high = notes.where((n) => n.priority == NotePriority.high).length;
    final med = notes.where((n) => n.priority == NotePriority.medium).length;
    final low = notes.where((n) => n.priority == NotePriority.low).length;
    final tasks = notes.where((n) => n.category == NoteCategory.tasks).length;
    final reminders = notes.where((n) => n.category == NoteCategory.reminders).length;
    final dayLabel = _humanDate(localDate);

    return [
      '<b>Today Summary</b>',
      '<pre>${_asciiCard([
        'DATE      $dayLabel',
        'TOTAL     ${notes.length}',
        'PRIORITY  H:$high M:$med L:$low',
        'CATEGORY  Tasks:$tasks Reminders:$reminders',
      ])}</pre>',
    ].join('\n');
  }

  String buildStatsMessage({
    required List<Note> notes,
    required DateTime localDate,
  }) {
    final byCategory = <NoteCategory, int>{};
    final byPriority = <NotePriority, int>{};
    for (final n in notes) {
      byCategory[n.category] = (byCategory[n.category] ?? 0) + 1;
      byPriority[n.priority] = (byPriority[n.priority] ?? 0) + 1;
    }

    final catLines = byCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final detail = <String>[
      'PRIORITY  H:${byPriority[NotePriority.high] ?? 0} M:${byPriority[NotePriority.medium] ?? 0} L:${byPriority[NotePriority.low] ?? 0}',
      '--- CATEGORY ---',
      ...catLines.take(6).map((e) => '${categoryLabel(e.key).padRight(9)} ${e.value.toString().padLeft(2)}'),
    ];

    return [
      '<b>Analytics Snapshot</b>',
      '<pre>${_asciiCard(detail)}</pre>',
    ].join('\n');
  }

  List<Note> selectDigestHighlights({
    required List<Note> notes,
    int maxItems = 6,
    bool topPriorityOnly = true,
    bool includeMediumFallback = true,
  }) {
    final sorted = [...notes]..sort((a, b) {
      final p = _priorityRank(a.priority).compareTo(_priorityRank(b.priority));
      if (p != 0) return p;
      return b.createdAt.compareTo(a.createdAt);
    });

    if (!topPriorityOnly) {
      return sorted.take(max(1, maxItems)).toList();
    }

    final high = sorted.where((n) => n.priority == NotePriority.high).toList();
    if (high.isNotEmpty) {
      return high.take(max(1, maxItems)).toList();
    }

    if (includeMediumFallback) {
      final medium = sorted.where((n) => n.priority == NotePriority.medium).toList();
      return medium.take(max(1, maxItems)).toList();
    }

    return const [];
  }

  String _formatDigestLine({required int index, required Note note}) {
    final emoji = categoryEmoji(note.category);
    final priority = _priorityChip(note.priority);
    final title = _escapeHtml(_truncate(note.title.trim().isEmpty ? 'Untitled note' : note.title.trim(), 52));
    final subtitle = _firstMeaningfulLine(note.cleanBody, note.rawTranscript);
    final safeSubtitle = subtitle.isEmpty ? '' : ' - ${_escapeHtml(_truncate(subtitle, 44))}';
    return '$index) $emoji $priority <b>$title</b>$safeSubtitle';
  }

  String _firstMeaningfulLine(String cleanBody, String rawTranscript) {
    final raw = cleanBody.trim().isNotEmpty ? cleanBody.trim() : rawTranscript.trim();
    if (raw.isEmpty) return '';
    final firstLine = raw.split(RegExp(r'[\n\r]')).first.trim();
    return firstLine;
  }

  String _truncate(String value, int limit) {
    if (value.length <= limit) return value;
    return '${value.substring(0, max(0, limit - 1)).trimRight()}…';
  }

  String _escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  int _priorityRank(NotePriority priority) {
    switch (priority) {
      case NotePriority.high:
        return 0;
      case NotePriority.medium:
        return 1;
      case NotePriority.low:
        return 2;
    }
  }

  String _priorityChip(NotePriority priority) {
    switch (priority) {
      case NotePriority.high:
        return '[HIGH]';
      case NotePriority.medium:
        return '[MED]';
      case NotePriority.low:
        return '[LOW]';
    }
  }

  String _humanDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _clock(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _asciiCard(List<String> rows) {
    final sanitized = rows.map((r) => _stripNonAscii(r)).toList();
    var width = 24;
    for (final r in sanitized) {
      if (r.length > width) width = r.length;
    }
    width = width.clamp(24, 64);

    final top = '+${'-' * (width + 2)}+';
    final body = sanitized.map((r) {
      final t = _truncate(r, width);
      return '| ${t.padRight(width)} |';
    }).join('\n');
    return '$top\n$body\n$top';
  }

  String _stripNonAscii(String value) {
    final out = StringBuffer();
    for (final code in value.runes) {
      if (code >= 32 && code <= 126) {
        out.writeCharCode(code);
      }
    }
    return out.toString();
  }

  /// Send a plain text message to a chat.
  Future<bool> sendMessage({
    required String chatId,
    required String text,
    bool silent = false,
    Map<String, dynamic>? replyMarkup,
    bool disableWebPagePreview = false,
    int? replyToMessageId,
    bool typingBeforeSend = false,
  }) async {
    if (!isConfigured || chatId.isEmpty || text.trim().isEmpty) return false;
    try {
      if (typingBeforeSend) {
        await sendChatAction(chatId: chatId, action: 'typing');
      }

      final chunks = _splitTelegramText(text, maxChars: 3900);
      var okAll = true;
      for (var i = 0; i < chunks.length; i++) {
        final part = chunks[i];
        final primary = await _postMessage(
          chatId: chatId,
          text: part,
          parseMode: 'HTML',
          silent: silent,
          replyMarkup: i == chunks.length - 1 ? replyMarkup : null,
          disableWebPagePreview: disableWebPagePreview,
          replyToMessageId: i == 0 ? replyToMessageId : null,
        );
        // Telegram always returns HTTP 200; real errors are in the JSON body.
        if (_isTelegramOk(primary)) {
          continue;
        }

        // Fallback path: strip HTML and retry as plain text.
        debugPrint('[TelegramService] HTML send failed (${primary.body}), retrying plain');
        final plain = _stripHtmlTags(part);
        final fallback = await _postMessage(
          chatId: chatId,
          text: plain,
          parseMode: null,
          silent: silent,
          replyMarkup: i == chunks.length - 1 ? replyMarkup : null,
          disableWebPagePreview: disableWebPagePreview,
          replyToMessageId: i == 0 ? replyToMessageId : null,
        );
        if (!_isTelegramOk(fallback)) {
          okAll = false;
          debugPrint('[TelegramService] sendMessage failed (plain fallback): ${fallback.body}');
          break;
        }
      }
      return okAll;
    } catch (e) {
      debugPrint('[TelegramService] sendMessage error: $e');
      return false;
    }
  }

  Future<bool> sendChatAction({
    required String chatId,
    String action = 'typing',
  }) async {
    if (!isConfigured || chatId.isEmpty) return false;
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/bot$_botToken/sendChatAction'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'chat_id': chatId, 'action': action}),
          )
          .timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<http.Response> _postMessage({
    required String chatId,
    required String text,
    required String? parseMode,
    required bool silent,
    required Map<String, dynamic>? replyMarkup,
    required bool disableWebPagePreview,
    required int? replyToMessageId,
  }) {
    final payload = <String, dynamic>{
      'chat_id': chatId,
      'text': text,
      'disable_notification': silent,
      'disable_web_page_preview': disableWebPagePreview,
    };
    if (parseMode != null && parseMode.isNotEmpty) {
      payload['parse_mode'] = parseMode;
    }
    if (replyMarkup != null) {
      payload['reply_markup'] = replyMarkup;
    }
    if (replyToMessageId != null && replyToMessageId > 0) {
      payload['reply_parameters'] = {
        'message_id': replyToMessageId,
        'allow_sending_without_reply': true,
      };
    }

    return http
        .post(
          Uri.parse('$_baseUrl/bot$_botToken/sendMessage'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        )
        .timeout(const Duration(seconds: 10));
  }

  /// Returns true only when Telegram's response indicates success.
  /// Telegram returns HTTP 200 for both successes AND API-level errors;
  /// the actual result lives in the JSON `ok` field.
  bool _isTelegramOk(http.Response response) {
    if (response.statusCode != 200) return false;
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['ok'] as bool? ?? false;
    } catch (_) {
      return false;
    }
  }

  String _stripHtmlTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  List<String> _splitTelegramText(String input, {int maxChars = 3900}) {
    final text = input.trim();
    if (text.length <= maxChars) return [text];

    final chunks = <String>[];
    var start = 0;
    while (start < text.length) {
      var end = min(start + maxChars, text.length);
      if (end < text.length) {
        final breakAt = text.lastIndexOf('\n', end);
        if (breakAt > start + 120) {
          end = breakAt;
        }
      }
      final chunk = text.substring(start, end).trim();
      if (chunk.isNotEmpty) chunks.add(chunk);
      start = end;
    }
    return chunks.isEmpty ? [text.substring(0, maxChars)] : chunks;
  }
}
