import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/features/notes/presentation/widgets/glass_note_card.dart';
import 'package:wishperlog/features/overlay/quick_note_editor.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';
import 'package:wishperlog/shared/widgets/glass_title_bar.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({required this.category, super.key});

  final NoteCategory category;

  @override
  State<FolderScreen> createState() => _FolderScreenState();
}

class _FolderScreenState extends State<FolderScreen> {
  final NoteRepository _notes = sl<NoteRepository>();

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      context.pop();
      return;
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final secondaryText = context.textSec;

    return StreamBuilder<List<Note>>(
      stream: _notes.watchActiveByCategoryLocal(widget.category),
      builder: (context, snapshot) {
        final notes = snapshot.data ?? const <Note>[];
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: GlassTitleBar(
            title: categoryLabel(widget.category),
            subtitle: '${notes.length} active notes',
            onBack: _goBack,
            leading: Icon(
              categoryIcon(widget.category),
              size: 18,
              color: categoryColor(widget.category),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: categoryColor(widget.category).withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${notes.length}',
                style: TextStyle(
                  color: categoryColor(widget.category),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          body: GlassPageBackground(
            category: widget.category,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                final targetTint = categoryColor(
                  widget.category,
                ).withValues(alpha: context.isDark ? 0.07 : 0.045);
                return FolderGlassTint(
                  tint: targetTint.withValues(alpha: targetTint.a * value),
                  child: child!,
                );
              },
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                    child: GlassPane(
                      level: 1,
                      radius: 24,
                      tintOverride: categoryColor(widget.category).withValues(alpha: 0.08),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: categoryColor(widget.category).withValues(alpha: 0.14),
                            ),
                            child: Icon(
                              categoryIcon(widget.category),
                              color: categoryColor(widget.category),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  categoryLabel(widget.category),
                                  style: TextStyle(
                                    color: context.textPri,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Swipe to delete or reassign • tap to edit',
                                  style: TextStyle(
                                    color: secondaryText,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: categoryColor(widget.category).withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${notes.length}',
                              style: TextStyle(
                                color: categoryColor(widget.category),
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: (() {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            'Unable to load notes right now.',
                            style: TextStyle(
                              color: secondaryText,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                              fontSize: 13.5,
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData &&
                          snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      }

                      if (notes.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: GlassPane(
                              level: 2,
                              radius: 22,
                              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.inbox_outlined,
                                    size: 32,
                                    color: categoryColor(widget.category),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Nothing here yet',
                                    style: TextStyle(
                                      color: context.textPri,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Add a note and it will appear in this folder automatically.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: secondaryText,
                                      fontSize: 12.5,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                        itemCount: notes.length,
                        itemBuilder: (context, index) {
                          final note = notes[index];

                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: AppDurations.folderStagger * (index + 1),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, (1 - value) * 10),
                                  child: child,
                                ),
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.only(
                                bottom: index == notes.length - 1 ? 0 : 10,
                              ),
                              child: Dismissible(
                                key: ValueKey(note.noteId),
                                confirmDismiss: (direction) async {
                                  if (direction == DismissDirection.startToEnd) {
                                    unawaited(_notes.delete(note.noteId));
                                    unawaited(HapticFeedback.lightImpact());
                                    return true;
                                  }

                                  await _openReassignSheet(note);
                                  return false;
                                },
                                background: _swipeBackground(
                                  alignment: Alignment.centerLeft,
                                  color: Colors.red.withValues(alpha: 0.12),
                                  icon: Icons.delete_outline,
                                  label: 'Delete',
                                ),
                                secondaryBackground: _swipeBackground(
                                  alignment: Alignment.centerRight,
                                  color: categoryColor(
                                    widget.category,
                                  ).withValues(alpha: 0.12),
                                  icon: Icons.category_outlined,
                                  label: 'Reassign',
                                ),
                                child: GlassNoteCard(
                                  note: note,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    })(),
                  ),
                ],
              ),
            ), // closes TweenAnimationBuilder
          ), // closes GlassPageBackground
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const QuickNoteEditor(),
              );
            },
            icon: const Icon(Icons.add),
            label: Text('New ${categoryLabel(widget.category).toLowerCase()}'),
            backgroundColor: categoryColor(widget.category),
            foregroundColor: Colors.white,
          ),
        ); // closes Scaffold
      }, // closes StreamBuilder builder
    ); // closes StreamBuilder
  }

  Widget _swipeBackground({
    required Alignment alignment,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    final isLeft = alignment == Alignment.centerLeft;
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      padding: EdgeInsets.symmetric(horizontal: isLeft ? 16 : 18),
      alignment: alignment,
      child: Row(
        mainAxisAlignment: isLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (!isLeft) ...[
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
          ],
          Icon(icon, size: 18),
          if (isLeft) ...[
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }

  Future<void> _openReassignSheet(Note note) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: GlassPane(
            level: 1,
            radius: 20,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final category in kAllNoteCategories)
                  GestureDetector(
                    onTap: () async {
                      await _notes.updateEditedNote(
                        noteId: note.noteId,
                        title: note.title,
                        cleanBody: note.cleanBody,
                        category: category,
                        priority: note.priority,
                        extractedDate: note.extractedDate,
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: GlassPane(
                      level: 3,
                      radius: 12,
                      tintOverride: categoryColor(
                        category,
                      ).withValues(alpha: context.isDark ? 0.07 : 0.045),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      child: Text(
                        categoryLabel(category),
                        style: TextStyle(
                          color: categoryColor(category),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

}