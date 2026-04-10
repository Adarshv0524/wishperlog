import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/search/data/smart_note_search.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_title_bar.dart';

class SearchNotesModal extends StatefulWidget {
  const SearchNotesModal({super.key});

  @override
  State<SearchNotesModal> createState() => _SearchNotesModalState();
}

class _SearchNotesModalState extends State<SearchNotesModal> {
  final IsarNoteStore _notes = sl<IsarNoteStore>();
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
    final titleColor = context.textPri;
    final secondaryColor = context.textSec;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: SafeArea(
          child: Column(
            children: [
              GlassTitleBar(
                title: 'Search',
                subtitle: 'Find notes quickly',
                onBack: () => Navigator.of(context).pop(),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                child: Row(
                  children: [
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
                  stream: _notes.watchActive(),
                  builder: (context, snapshot) {
                    final all = snapshot.data ?? const <Note>[];
                    final query = _queryController.text.trim();

                    final results = query.isEmpty
                        ? all
                        : SmartNoteSearch.searchSync(
                            all,
                            query,
                          ).map((h) => h.note).toList();

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
                              padding: const EdgeInsets.fromLTRB(
                                12,
                                10,
                                12,
                                10,
                              ),
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
}
