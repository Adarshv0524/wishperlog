import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final NoteRepository _notes = sl<NoteRepository>();
  final TextEditingController _queryController = TextEditingController();
  NoteCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _queryController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPane(
        level: 4,
        radius: 0,
        tintOverride: context.isDark
            ? const Color(0x99000000)
            : const Color(0xCCFFFFFF),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 20,
                        color: context.textPri,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: context.surface1,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: context.textSec.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: context.textPri,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _queryController,
                                autofocus: true,
                                style: TextStyle(
                                  color: context.textPri,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search your brain...',
                                  hintStyle: TextStyle(
                                    color: context.textSec,
                                    fontSize: 14,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: kAllNoteCategories.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final category = kAllNoteCategories[index];
                    final selected = _selectedCategory == category;
                    final color = categoryColor(category);

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = selected ? null : category;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withValues(alpha: 0.15)
                              : context.surface1,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? color.withValues(alpha: 0.5)
                                : context.textSec.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              categoryEmoji(category),
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              categoryLabel(category),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: selected
                                    ? FontWeight.w800
                                    : FontWeight.w600,
                                color: selected ? color : context.textSec,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: StreamBuilder<List<Note>>(
                  stream: _notes.watchAllActiveLocal(),
                  builder: (context, snapshot) {
                    final all = snapshot.data ?? const <Note>[];
                    final query = _queryController.text.trim().toLowerCase();
                    final ranked = _rankResults(query, all).where((note) {
                      if (_selectedCategory == null) return true;
                      return note.category == _selectedCategory;
                    }).toList();

                    if (ranked.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 48,
                              color: context.textSec.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No matching thoughts found',
                              style: TextStyle(
                                color: context.textSec,
                                fontSize: 14,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemBuilder: (context, index) {
                        final note = ranked[index];
                        return GlassPane(
                          level: 2,
                          radius: 18,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              context.pop();
                              context.push('/folder', extra: note.category);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(categoryEmoji(note.category)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: _HighlightedText(
                                          text: note.title,
                                          query: query,
                                          style: TextStyle(
                                            color: context.textPri,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: -0.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  _HighlightedText(
                                    text: note.cleanBody,
                                    query: query,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: context.textSec,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemCount: ranked.length,
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

  List<Note> _rankResults(String query, List<Note> notes) {
    if (query.isEmpty) {
      return notes;
    }

    final ranked = [...notes]
      ..sort((a, b) {
        final scoreA = _score(query, a);
        final scoreB = _score(query, b);
        if (scoreA == scoreB) {
          return b.updatedAt.compareTo(a.updatedAt);
        }
        return scoreB.compareTo(scoreA);
      });

    return ranked.where((note) => _score(query, note) > 0).toList();
  }

  int _score(String query, Note note) {
    final title = note.title.toLowerCase();
    final body = note.cleanBody.toLowerCase();
    final raw = note.rawTranscript.toLowerCase();
    final category = categoryLabel(note.category).toLowerCase();

    var score = 0;
    if (title.contains(query)) score += 60;
    if (title.startsWith(query)) score += 30;
    if (body.contains(query) || raw.contains(query)) score += 35;
    if (category.contains(query)) score += 25;
    return score;
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({
    required this.text,
    required this.query,
    required this.style,
    this.maxLines = 1,
  });

  final String text;
  final String query;
  final TextStyle style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final lower = text.toLowerCase();
    final start = lower.indexOf(query);
    if (start < 0) {
      return Text(
        text,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: style,
      );
    }

    final end = start + query.length;
    return RichText(
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, start)),
          TextSpan(
            text: text.substring(start, end),
            style: style.copyWith(fontWeight: FontWeight.w800),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
    );
  }
}
