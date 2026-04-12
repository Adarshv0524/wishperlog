// lib/features/notes/presentation/screens/note_view_screen.dart
//
// Immersive "View" screen (read-only).
// Edit is a secondary FAB action — no clutter on the read surface.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class NoteViewScreen extends StatelessWidget {
  const NoteViewScreen({super.key, required this.note});

  final Note note;

  Color _priorityColor(NotePriority p) => switch (p) {
    NotePriority.high   => const Color(0xFFEF4444),
    NotePriority.medium => const Color(0xFFF59E0B),
    NotePriority.low    => const Color(0xFF10B981),
  };

  @override
  Widget build(BuildContext context) {
    final accent = categoryColor(note.category);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      floatingActionButton: _EditFab(noteId: note.noteId),
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
                          final body = '${note.title}\n\n${note.cleanBody.isNotEmpty ? note.cleanBody : note.rawTranscript}';
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
                                  note.title.isEmpty ? 'Untitled Note' : note.title,
                                  style: TextStyle(
                                    color: context.textPri,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.8,
                                    height: 1.2,
                                  ),
                                ),
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
                                SelectableText(
                                  note.cleanBody.isNotEmpty
                                      ? note.cleanBody
                                      : note.rawTranscript,
                                  style: TextStyle(
                                    color: context.textPri,
                                    fontSize: 16,
                                    height: 1.75,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.1,
                                  ),
                                ),
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
          Text(
            label,
            style: TextStyle(
              color: tint,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditFab extends StatelessWidget {
  const _EditFab({required this.noteId});
  final String noteId;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FloatingActionButton.extended(
      heroTag: 'edit_fab_$noteId',
      onPressed: () {
        HapticFeedback.mediumImpact();
        context.push('/notes/$noteId');
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