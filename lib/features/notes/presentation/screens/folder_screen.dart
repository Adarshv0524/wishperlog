import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/features/notes/presentation/widgets/glass_note_card.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/top_notch_message.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText = isDark
        ? Colors.white.withValues(alpha: 0.78)
        : const Color(0xFF374151);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back',
          onPressed: _goBack,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(categoryLabel(widget.category)),
      ),
      body: GlassPageBackground(
        child: StreamBuilder<List<Note>>(
          stream: _notes.watchActiveByCategory(widget.category),
          builder: (context, snapshot) {
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

            final notes = snapshot.data ?? const <Note>[];

            if (notes.isEmpty) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 56),
                    child: Center(
                      child: Text(
                        'No notes here yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: secondaryText,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];

                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == notes.length - 1 ? 0 : 10,
                  ),
                  child: Dismissible(
                    key: ValueKey(note.noteId),
                    confirmDismiss: (direction) async {
                      if (direction == DismissDirection.startToEnd) {
                        await _notes.archive(note.noteId);
                        await HapticFeedback.lightImpact();
                        return true;
                      }

                      await _notes.cyclePriority(note.noteId);
                      await HapticFeedback.lightImpact();
                      return false;
                    },
                    background: _swipeBackground(
                      alignment: Alignment.centerLeft,
                      color: const Color(0xFFE8F5E9),
                      icon: Icons.archive_outlined,
                      label: 'Archive',
                    ),
                    secondaryBackground: _swipeBackground(
                      alignment: Alignment.centerRight,
                      color: const Color(0xFFFFF8E1),
                      icon: Icons.swap_horiz_rounded,
                      label: 'Priority',
                    ),
                    child: GlassNoteCard(
                      note: note,
                      onTap: () async {
                        await HapticFeedback.lightImpact();
                        await _openEditSheet(note);
                      },
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
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

  Future<void> _openEditSheet(Note note) async {
    final titleController = TextEditingController(text: note.title);
    final bodyController = TextEditingController(text: note.cleanBody);

    var selectedCategory = note.category;
    var selectedPriority = note.priority;
    DateTime? selectedDate = note.extractedDate;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.22),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                14,
                12,
                14,
                14 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(22),
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Edit note',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: bodyController,
                        minLines: 3,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          labelText: 'Body',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<NoteCategory>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          isDense: true,
                        ),
                        items: kAllNoteCategories
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(categoryLabel(c)),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setSheetState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<NotePriority>(
                        initialValue: selectedPriority,
                        decoration: const InputDecoration(
                          labelText: 'Priority',
                          isDense: true,
                        ),
                        items: NotePriority.values
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(p.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setSheetState(() {
                            selectedPriority = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedDate == null
                                  ? 'No extracted date'
                                  : (selectedDate!
                                        .toIso8601String()
                                        .split('T')
                                        .first),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF374151),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final now = DateTime.now();
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate ?? now,
                                firstDate: DateTime(now.year - 5),
                                lastDate: DateTime(now.year + 10),
                              );
                              if (picked == null) return;
                              setSheetState(() {
                                selectedDate = picked;
                              });
                            },
                            child: const Text('Pick date'),
                          ),
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                selectedDate = null;
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () async {
                            await _notes.updateEditedNote(
                              noteId: note.noteId,
                              title: titleController.text,
                              cleanBody: bodyController.text,
                              category: selectedCategory,
                              priority: selectedPriority,
                              extractedDate: selectedDate,
                            );
                            await HapticFeedback.lightImpact();
                            if (context.mounted) {
                              final displayTitle =
                                  titleController.text.trim().isNotEmpty
                                  ? titleController.text.trim()
                                  : bodyController.text.trim();
                              unawaited(
                                showTopNotchSavedMessage(
                                  context: context,
                                  title: displayTitle.isNotEmpty
                                      ? displayTitle
                                      : 'Note updated',
                                  categoryLabel: categoryLabel(selectedCategory),
                                  subtitle:
                                      'Priority: ${selectedPriority.name}',
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Save'),
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
    );
  }
}
