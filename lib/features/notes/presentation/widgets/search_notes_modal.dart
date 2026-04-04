import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';

class SearchNotesModal extends StatefulWidget {
  const SearchNotesModal({super.key});

  @override
  State<SearchNotesModal> createState() => _SearchNotesModalState();
}

class _SearchNotesModalState extends State<SearchNotesModal> {
  final NoteRepository _notes = sl<NoteRepository>();
  final TextEditingController _queryController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNode.requestFocus();
      }
    });
    _queryController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final secondaryColor = isDark
        ? Colors.white.withValues(alpha: 0.72)
        : const Color(0xFF475569);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_rounded, color: titleColor),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: GlassContainer(
                        borderRadius: BorderRadius.circular(14),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: TextField(
                          controller: _queryController,
                          focusNode: _focusNode,
                          style: TextStyle(
                            color: titleColor,
                            fontWeight: FontWeight.w600,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search title, body, or category...',
                            hintStyle: TextStyle(color: secondaryColor),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<List<Note>>(
                  stream: _notes.watchAllActive(),
                  builder: (context, snapshot) {
                    final all = snapshot.data ?? const <Note>[];
                    final query = _queryController.text.trim();

                    final results = query.isEmpty
                        ? all
                        : _rankedSearch(query, all);

                    if (results.isEmpty) {
                      return Center(
                        child: Text(
                          'No matching notes',
                          style: TextStyle(color: secondaryColor),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(12, 4, 12, 20),
                      itemCount: results.length,
                      separatorBuilder: (_, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final note = results[index];
                        return GlassContainer(
                          borderRadius: BorderRadius.circular(14),
                          padding: EdgeInsets.zero,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(14),
                            onTap: () {
                              Navigator.of(context).pop();
                              context.go('/folder', extra: note.category);
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: titleColor,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    note.cleanBody,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: secondaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    categoryLabel(note.category),
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: secondaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Note> _rankedSearch(String query, List<Note> notes) {
    final normalizedQuery = _normalize(query);
    if (normalizedQuery.isEmpty) {
      return notes;
    }

    final queryTokens = normalizedQuery
        .split(' ')
        .where((t) => t.trim().isNotEmpty)
        .toList();
    final expandedTokens = <String>{...queryTokens};
    for (final token in queryTokens) {
      expandedTokens.addAll(_semanticExpansions(token));
    }

    final ranked = <_RankedNote>[];

    for (final note in notes) {
      final title = _normalize(note.title);
      final body = _normalize(note.cleanBody);
      final raw = _normalize(note.rawTranscript);
      final category = _normalize(categoryLabel(note.category));
      final combined = '$title $body $raw $category';

      var score = 0;

      if (title.contains(normalizedQuery)) score += 130;
      if (body.contains(normalizedQuery) || raw.contains(normalizedQuery)) {
        score += 90;
      }
      if (category.contains(normalizedQuery)) score += 95;
      if (title.startsWith(normalizedQuery)) score += 45;

      for (final token in expandedTokens) {
        if (token.isEmpty) continue;
        if (title.contains(token)) score += 20;
        if (body.contains(token)) score += 10;
        if (raw.contains(token)) score += 8;
        if (category.contains(token)) score += 15;
      }

      final allBaseTokensPresent = queryTokens.every(
        (token) => combined.contains(token),
      );
      if (allBaseTokensPresent) {
        score += 38;
      }

      if (score <= 0) {
        continue;
      }

      final ageHours = DateTime.now().difference(note.updatedAt).inHours;
      final recencyBoost = (24 - ageHours).clamp(0, 24) ~/ 4;
      score += recencyBoost;

      ranked.add(_RankedNote(note: note, score: score));
    }

    ranked.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      if (byScore != 0) return byScore;
      return b.note.updatedAt.compareTo(a.note.updatedAt);
    });

    return ranked.map((r) => r.note).toList();
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Set<String> _semanticExpansions(String token) {
    const synonyms = <String, Set<String>>{
      'call': {'phone', 'ring'},
      'meeting': {'meet', 'schedule'},
      'reminder': {'remind', 'remember', 'tomorrow'},
      'task': {'todo', 'work', 'complete'},
      'idea': {'brainstorm', 'concept'},
      'follow': {'followup', 'ping'},
      'journal': {'diary', 'reflection'},
      'buy': {'purchase', 'shopping'},
    };

    final expanded = <String>{};
    if (synonyms.containsKey(token)) {
      expanded.addAll(synonyms[token]!);
    }

    for (final entry in synonyms.entries) {
      if (entry.value.contains(token)) {
        expanded.add(entry.key);
      }
    }

    return expanded;
  }
}

class _RankedNote {
  const _RankedNote({required this.note, required this.score});

  final Note note;
  final int score;
}
