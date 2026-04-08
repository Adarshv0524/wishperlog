import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/search/data/smart_note_search.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final IsarNoteStore _notes = sl<IsarNoteStore>();
  final TextEditingController _queryController = TextEditingController();
  Timer? _debounce;
  String _debouncedQuery = '';

  @override
  void initState() {
    super.initState();
    _queryController.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 180), () {
      if (mounted) {
        setState(() => _debouncedQuery = _queryController.text.trim());
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
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
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
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
                                textInputAction: TextInputAction.search,
                                style: TextStyle(
                                  color: context.textPri,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Search… try "tasks: standup"',
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
              Expanded(
                child: StreamBuilder<List<Note>>(
                  stream: _notes.watchActive(),
                  builder: (context, snapshot) {
                    final all = snapshot.data ?? const <Note>[];
                    final query = _debouncedQuery;
                    final hits = SmartNoteSearch.searchSync(all, query);

                    if (query.isEmpty) {
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
                              'Search notes, tasks, and ideas',
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

                    if (hits.isEmpty) {
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
                              'No results for "$query"',
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
                        final hit = hits[index];
                        final note = hit.note;
                        return GlassPane(
                          level: 2,
                          radius: 18,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              context.pop();
                              context.push('/notes/${note.noteId}');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: categoryColor(note.category).withValues(alpha: 0.14),
                                        ),
                                        child: Icon(
                                          categoryIcon(note.category),
                                          size: 16,
                                          color: categoryColor(note.category),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          note.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                                  Text(
                                    hit.snippet.isNotEmpty
                                        ? hit.snippet
                                        : note.cleanBody,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: context.textSec,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: context.surface1,
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          border: Border.all(
                                            color: context.textSec.withValues(
                                              alpha: 0.18,
                                            ),
                                          ),
                                        ),
                                        child: Text(
                                          categoryLabel(note.category),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: context.textSec,
                                          ),
                                        ),
                                      ),
                                      if (hit.matchedField.isNotEmpty &&
                                          hit.matchedField != 'title') ...[
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'matched in ${hit.matchedField}',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: context.textSec.withValues(
                                                alpha: 0.5,
                                              ),
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemCount: hits.length,
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

}
