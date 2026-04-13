// lib/features/notes/presentation/screens/note_view_screen.dart
//
// Immersive "View" screen (read-only).
// Edit is a secondary FAB action — no clutter on the read surface.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/notes/data/note_repository.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class NoteViewScreen extends StatefulWidget {
  const NoteViewScreen({required this.note, super.key});

  final Note note;

  @override
  State<NoteViewScreen> createState() => _NoteViewScreenState();
}

class _NoteViewScreenState extends State<NoteViewScreen> {
  final NoteRepository _notes = sl<NoteRepository>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  late Note _note;
  bool _showTranslation = false;
  bool _isEditing = false;
  bool _saving = false;
  NoteCategory _category = NoteCategory.general;
  NotePriority _priority = NotePriority.medium;
  DateTime? _extractedDate;

  bool get _hasTranslation => (_note.translatedContent ?? '').trim().isNotEmpty;

  String get _displayBody =>
      (_showTranslation && _hasTranslation)
          ? _note.translatedContent!.trim()
          : (_note.cleanBody.isNotEmpty ? _note.cleanBody : _note.rawTranscript);

  String get _displayTitle =>
      (_showTranslation && _hasTranslation && (_note.translatedTitle ?? '').trim().isNotEmpty)
          ? _note.translatedTitle!.trim()
          : (_note.title.isNotEmpty ? _note.title : 'Untitled Note');

  @override
  void initState() {
    super.initState();
    _note = widget.note;
    _seedEditors();
  }

  @override
  void didUpdateWidget(covariant NoteViewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.noteId != widget.note.noteId) {
      _note = widget.note;
      _seedEditors();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _seedEditors() {
    _titleController.text = _note.title == 'Quick note' ? '' : _note.title;
    _bodyController.text = _note.cleanBody.isNotEmpty ? _note.cleanBody : _note.rawTranscript;
    _category = _note.category;
    _priority = _note.priority;
    _extractedDate = _note.extractedDate;
  }

  void _toggleEditor() {
    setState(() {
      _isEditing = !_isEditing;
      if (_isEditing) {
        _seedEditors();
      }
    });
  }

  Future<void> _saveEdits() async {
    if (_saving) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    try {
      await _notes.updateEditedNote(
        noteId: _note.noteId,
        title: _titleController.text,
        cleanBody: _bodyController.text,
        category: _category,
        priority: _priority,
        extractedDate: _extractedDate,
      );

      final updated = _note.copyWith(
        title: _titleController.text.trim().isEmpty ? _note.title : _titleController.text.trim(),
        cleanBody: _bodyController.text.trim().isEmpty ? _note.cleanBody : _bodyController.text.trim(),
        category: _category,
        priority: _priority,
        extractedDate: _extractedDate,
        clearExtractedDate: _extractedDate == null,
        updatedAt: DateTime.now(),
      );

      if (!mounted) return;
      setState(() {
        _note = updated;
        _isEditing = false;
      });
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note updated')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
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

  Color _priorityColor(NotePriority p) => switch (p) {
    NotePriority.high   => const Color(0xFFEF4444),
    NotePriority.medium => const Color(0xFFF59E0B),
    NotePriority.low    => const Color(0xFF10B981),
  };

  @override
  Widget build(BuildContext context) {
    final note = _note;
    final accent = categoryColor(note.category);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      floatingActionButton: _EditFab(onPressed: _toggleEditor),
      body: GlassPageBackground(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(-0.72, -0.86),
                    radius: 1.15,
                    colors: [
                      accent.withValues(alpha: context.isDark ? 0.20 : 0.14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    pinned: false,
                    leading: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              context.surface1.withValues(alpha: context.isDark ? 0.92 : 0.84),
                              context.surface2.withValues(alpha: context.isDark ? 0.80 : 0.92),
                            ],
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: context.isDark ? 0.08 : 0.42),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: context.isDark ? 0.28 : 0.10),
                              blurRadius: 14,
                              offset: const Offset(4, 5),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: context.isDark ? 0.08 : 0.72),
                              blurRadius: 10,
                              offset: const Offset(-3, -3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: context.textPri,
                        ),
                      ),
                    ),
                    actions: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          final body = '$_displayTitle\n\n$_displayBody';
                          Clipboard.setData(ClipboardData(text: body));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Copied to clipboard')),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                context.surface1.withValues(alpha: context.isDark ? 0.92 : 0.84),
                                context.surface2.withValues(alpha: context.isDark ? 0.80 : 0.92),
                              ],
                            ),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: context.isDark ? 0.08 : 0.42),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: context.isDark ? 0.28 : 0.10),
                                blurRadius: 14,
                                offset: const Offset(4, 5),
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: context.isDark ? 0.08 : 0.72),
                                blurRadius: 10,
                                offset: const Offset(-3, -3),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: context.textPri,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GlassPane(
                            level: 3,
                            radius: 28,
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                _SurfacePill(
                                  icon: categoryIcon(note.category),
                                  label: categoryLabel(note.category),
                                  tint: accent,
                                ),
                                _SurfacePill(
                                  icon: Icons.priority_high_rounded,
                                  label: note.priority.name.toUpperCase(),
                                  tint: _priorityColor(note.priority),
                                ),
                                if (note.aiModel.isNotEmpty)
                                  _SurfacePill(
                                    icon: Icons.auto_awesome_rounded,
                                    label: note.aiModel.toUpperCase(),
                                    tint: AppColors.followUp,
                                  ),
                                if (note.extractedDate != null)
                                  _SurfacePill(
                                    icon: Icons.event_rounded,
                                    label: _formatDate(note.extractedDate!),
                                    tint: AppColors.tasks,
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          GlassPane(
                            level: 2,
                            radius: 30,
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _displayTitle,
                                  style: TextStyle(
                                    color: context.textPri,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.8,
                                    height: 1.2,
                                  ),
                                ),
                                if (_hasTranslation) ...[
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () => setState(() => _showTranslation = !_showTranslation),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 220),
                                      curve: Curves.easeOut,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        color: AppColors.ideas.withValues(alpha: _showTranslation ? 0.22 : 0.10),
                                        border: Border.all(
                                          color: AppColors.ideas.withValues(alpha: 0.30),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.translate_rounded,
                                            size: 14,
                                            color: AppColors.ideas,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            _showTranslation ? 'Show original' : 'Show in English',
                                            style: TextStyle(
                                              color: AppColors.ideas,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Text(
                                  'Captured ${_formatDate(note.createdAt)}',
                                  style: TextStyle(
                                    color: context.textSec,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 260),
                                  child: SelectableText(
                                    _displayBody,
                                    key: ValueKey<bool>(_showTranslation),
                                    style: TextStyle(
                                      color: context.textPri,
                                      fontSize: 16,
                                      height: 1.75,
                                      fontWeight: FontWeight.w400,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                ),
                                if (_isEditing) ...[
                                  const SizedBox(height: 20),
                                  _InlineEditPanel(
                                    formKey: _formKey,
                                    titleController: _titleController,
                                    bodyController: _bodyController,
                                    category: _category,
                                    priority: _priority,
                                    extractedDate: _extractedDate,
                                    saving: _saving,
                                    onCategoryChanged: (value) => setState(() => _category = value),
                                    onPriorityChanged: (value) => setState(() => _priority = value),
                                    onPickDate: _pickExtractedDate,
                                    onClearDate: _clearExtractedDate,
                                    onCancel: _toggleEditor,
                                    onSave: _saveEdits,
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (note.rawTranscript.isNotEmpty &&
                              note.rawTranscript != note.cleanBody) ...[
                            const SizedBox(height: 16),
                            _RawTranscriptSection(rawTranscript: note.rawTranscript),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _SurfacePill extends StatelessWidget {
  const _SurfacePill({
    required this.icon,
    required this.label,
    required this.tint,
  });

  final IconData icon;
  final String label;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            tint.withValues(alpha: context.isDark ? 0.22 : 0.12),
            tint.withValues(alpha: context.isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: tint.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.16 : 0.08),
            blurRadius: 10,
            offset: const Offset(3, 4),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: context.isDark ? 0.08 : 0.66),
            blurRadius: 8,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: tint),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              style: TextStyle(
                color: tint,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditFab extends StatelessWidget {
  const _EditFab({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FloatingActionButton.extended(
      heroTag: 'edit_fab_note_view',
      onPressed: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      backgroundColor: Colors.transparent,
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      label: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.tasks.withValues(alpha: isDark ? 0.95 : 0.88),
              const Color(0xFF58D0C7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.16),
              blurRadius: 18,
              offset: const Offset(5, 8),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.62),
              blurRadius: 12,
              offset: const Offset(-4, -4),
            ),
          ],
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.edit_rounded, size: 18),
              SizedBox(width: 8),
              Text(
                'Edit',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InlineEditPanel extends StatelessWidget {
  const _InlineEditPanel({
    required this.formKey,
    required this.titleController,
    required this.bodyController,
    required this.category,
    required this.priority,
    required this.extractedDate,
    required this.saving,
    required this.onCategoryChanged,
    required this.onPriorityChanged,
    required this.onPickDate,
    required this.onClearDate,
    required this.onCancel,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController bodyController;
  final NoteCategory category;
  final NotePriority priority;
  final DateTime? extractedDate;
  final bool saving;
  final ValueChanged<NoteCategory> onCategoryChanged;
  final ValueChanged<NotePriority> onPriorityChanged;
  final VoidCallback onPickDate;
  final VoidCallback onClearDate;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  InputDecoration _inputDecoration(BuildContext context, {required String label, required String hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: context.surface1.withValues(alpha: context.isDark ? 0.82 : 0.72),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: context.border.withValues(alpha: 0.7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: context.border.withValues(alpha: 0.55)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.ideas.withValues(alpha: 0.75), width: 1.4),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 2,
      radius: 24,
      padding: const EdgeInsets.all(16),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inline edit',
              style: TextStyle(
                color: context.textPri,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: titleController,
              textInputAction: TextInputAction.next,
              decoration: _inputDecoration(context, label: 'Title', hint: 'Note title'),
              validator: (value) {
                if ((value ?? '').trim().isEmpty && bodyController.text.trim().isEmpty) {
                  return 'Add a title or body';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: bodyController,
              minLines: 4,
              maxLines: 8,
              decoration: _inputDecoration(context, label: 'Body', hint: 'Note details'),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<NoteCategory>(
                    initialValue: category,
                    decoration: _inputDecoration(context, label: 'Category', hint: 'Choose category'),
                    items: NoteCategory.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(categoryLabel(value)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onCategoryChanged(value);
                    },
                  ),
                ),
                SizedBox(
                  width: 170,
                  child: DropdownButtonFormField<NotePriority>(
                    initialValue: priority,
                    decoration: _inputDecoration(context, label: 'Priority', hint: 'Choose priority'),
                    items: NotePriority.values
                        .map(
                          (value) => DropdownMenuItem(
                            value: value,
                            child: Text(value.name.toUpperCase()),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) onPriorityChanged(value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onPickDate,
                    icon: const Icon(Icons.event_rounded, size: 18),
                    label: Text(extractedDate == null ? 'Pick date' : _formatDate(extractedDate!)),
                  ),
                ),
                if (extractedDate != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: onClearDate,
                    child: const Text('Clear'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: saving ? null : onCancel,
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: saving ? null : onSave,
                  icon: saving
                      ? const SizedBox(
                          height: 14,
                          width: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_rounded, size: 18),
                  label: Text(saving ? 'Saving' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RawTranscriptSection extends StatefulWidget {
  const _RawTranscriptSection({required this.rawTranscript});
  final String rawTranscript;

  @override
  State<_RawTranscriptSection> createState() => _RawTranscriptSectionState();
}

class _RawTranscriptSectionState extends State<_RawTranscriptSection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) => GlassPane(
        level: 2,
        radius: 24,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.textSec.withValues(alpha: 0.10),
                    ),
                    child: Icon(Icons.mic_none_rounded, size: 14, color: context.textSec),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Raw Transcript',
                    style: TextStyle(
                      color: context.textPri,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: context.textSec,
                  ),
                ],
              ),
            ),
            if (_expanded) ...[
              const SizedBox(height: 12),
              SelectableText(
                widget.rawTranscript,
                style: TextStyle(
                  color: context.textSec,
                  fontSize: 14,
                  height: 1.65,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      );
}