import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';
import 'package:wishperlog/shared/widgets/glass_title_bar.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({required this.noteId, super.key});

  final String noteId;

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  final NoteRepository _notes = sl<NoteRepository>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  Note? _note;
  NoteCategory _category = NoteCategory.general;
  NotePriority _priority = NotePriority.medium;
  DateTime? _extractedDate;
  bool _saving = false;
  String? _seededNoteId;

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _seed(Note note) {
    if (_seededNoteId == note.noteId) return;
    _seededNoteId = note.noteId;
    _note = note;
    _titleController.text = note.title == 'Quick note' ? '' : note.title;
    _bodyController.text = note.cleanBody.isNotEmpty ? note.cleanBody : note.rawTranscript;
    _category = note.category;
    _priority = note.priority;
    _extractedDate = note.extractedDate;
  }

  Future<void> _save() async {
    final note = _note;
    if (note == null || _saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      await _notes.updateEditedNote(
        noteId: note.noteId,
        title: _titleController.text,
        cleanBody: _bodyController.text,
        category: _category,
        priority: _priority,
        extractedDate: _extractedDate,
      );
      if (mounted) {
        HapticFeedback.mediumImpact();
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickExtractedDate() async {
    final initialDate = _extractedDate ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
      setState(() => _extractedDate = picked);
    }
  }

  void _clearExtractedDate() {
    setState(() => _extractedDate = null);
  }

  String _formatDate(DateTime dt) {
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
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: context.surface1.withValues(alpha: context.isDark ? 0.82 : 0.72),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: context.textSec.withValues(alpha: 0.08)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: context.textSec.withValues(alpha: 0.08)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        borderSide: BorderSide(color: AppColors.tasks, width: 1.2),
      ),
      labelStyle: TextStyle(
        color: context.textSec,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  TextStyle _dropdownTextStyle(BuildContext context) {
    return TextStyle(
      color: context.textPri,
      fontWeight: FontWeight.w600,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saving ? null : _save,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        icon: _saving
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              )
            : const Icon(Icons.save_rounded),
        label: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                categoryColor(_category).withValues(alpha: isDark ? 0.95 : 0.90),
                const Color(0xFF58D0C7),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.14),
                blurRadius: 18,
                offset: const Offset(5, 8),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.66),
                blurRadius: 12,
                offset: const Offset(-4, -4),
              ),
            ],
          ),
          child: Text(
            _saving ? 'Saving…' : 'Save changes',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
      ),
      appBar: GlassTitleBar(
        title: 'Edit note',
        subtitle: 'Update title, body, category, and priority',
        onBack: () {
          if (Navigator.of(context).canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        },
      ),
      body: GlassPageBackground(
        child: StreamBuilder<Note?>(
          stream: _notes.watchNoteById(widget.noteId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final note = snapshot.data;
            if (note == null) {
              return const Center(
                child: Text('Note not found or no longer available.'),
              );
            }

            _seed(note);

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GlassPane(
                      level: 2,
                      radius: 28,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      categoryColor(_category).withValues(alpha: 0.24),
                                      categoryColor(_category).withValues(alpha: 0.10),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: categoryColor(_category).withValues(alpha: 0.24),
                                  ),
                                ),
                                child: Icon(
                                  categoryIcon(_category),
                                  color: categoryColor(_category),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Editing note',
                                      style: TextStyle(
                                        color: context.textPri,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.2,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Save changes to update the note everywhere.',
                                      style: TextStyle(
                                        color: context.textSec,
                                        fontSize: 12,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _MetaChip(label: categoryLabel(_category)),
                              _MetaChip(label: _priority.name.toUpperCase()),
                              _MetaChip(label: note.source.name),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GlassPane(
                      level: 1,
                      radius: 26,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleController,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              context,
                              label: 'Title',
                              hint: _titleController.text.isEmpty ? 'Quick note' : _titleController.text,
                            ),
                            style: TextStyle(
                              color: context.textPri,
                              fontWeight: FontWeight.w700,
                            ),
                            validator: (value) {
                              if (value != null && value.trim().length > 120) {
                                return 'Title is too long';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _bodyController,
                            minLines: 10,
                            maxLines: 18,
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            decoration: _inputDecoration(
                              context,
                              label: 'Body',
                              hint: 'Write the cleaned note text here',
                            ),
                            style: TextStyle(
                              color: context.textPri,
                              height: 1.5,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Body cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<NoteCategory>(
                                  initialValue: _category,
                                  decoration: _inputDecoration(
                                    context,
                                    label: 'Category',
                                    hint: 'Choose category',
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  dropdownColor: context.surface2.withValues(alpha: isDark ? 0.98 : 0.995),
                                  iconEnabledColor: context.textSec,
                                  style: _dropdownTextStyle(context),
                                  menuMaxHeight: 320,
                                  items: kAllNoteCategories
                                      .map(
                                        (category) => DropdownMenuItem<NoteCategory>(
                                          value: category,
                                          child: Text(
                                            categoryLabel(category),
                                            style: _dropdownTextStyle(context),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _category = value);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonFormField<NotePriority>(
                                  initialValue: _priority,
                                  decoration: _inputDecoration(
                                    context,
                                    label: 'Priority',
                                    hint: 'Choose priority',
                                  ),
                                  borderRadius: BorderRadius.circular(22),
                                  dropdownColor: context.surface2.withValues(alpha: isDark ? 0.98 : 0.995),
                                  iconEnabledColor: context.textSec,
                                  style: _dropdownTextStyle(context),
                                  menuMaxHeight: 260,
                                  items: NotePriority.values
                                      .map(
                                        (priority) => DropdownMenuItem<NotePriority>(
                                          value: priority,
                                          child: Text(
                                            priority.name.toUpperCase(),
                                            style: _dropdownTextStyle(context),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    if (value == null) return;
                                    setState(() => _priority = value);
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          GlassPane(
                            level: 1,
                            radius: 22,
                            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Extracted date',
                                  style: TextStyle(
                                    color: context.textPri,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _extractedDate == null ? 'No extracted date set' : _formatDate(_extractedDate!),
                                  style: TextStyle(
                                    color: context.textSec,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: _pickExtractedDate,
                                      icon: const Icon(Icons.event_outlined),
                                      label: const Text('Pick date'),
                                    ),
                                    TextButton(
                                      onPressed: _extractedDate == null ? null : _clearExtractedDate,
                                      child: const Text('Clear'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (note.rawTranscript.isNotEmpty && note.rawTranscript != note.cleanBody) ...[
                            const SizedBox(height: 12),
                            GlassPane(
                              level: 2,
                              radius: 22,
                              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Original capture',
                                    style: TextStyle(
                                      color: context.textPri,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SelectableText(
                                    note.rawTranscript,
                                    style: TextStyle(
                                      color: context.textSec,
                                      height: 1.55,
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Captured ${_formatDate(note.createdAt)} • ${note.source.name}',
                                    style: TextStyle(
                                      color: context.textSec,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.16),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
