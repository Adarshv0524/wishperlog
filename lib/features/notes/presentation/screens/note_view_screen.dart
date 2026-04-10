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
      body: Stack(
        children: [
          // Ambient gradient backdrop
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withValues(alpha: context.isDark ? 0.18 : 0.10),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                ),
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                // ── App bar ──────────────────────────────────────────────
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  pinned: false,
                  leading: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.surface1.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: context.textPri,
                      ),
                    ),
                  ),
                  actions: [
                    // Quick share
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
                          color: context.surface1.withValues(alpha: 0.7),
                          shape: BoxShape.circle,
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Category + Priority row ───────────────────────
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: accent.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(categoryIcon(note.category), size: 13, color: accent),
                                  const SizedBox(width: 5),
                                  Text(
                                    categoryLabel(note.category),
                                    style: TextStyle(
                                      color: accent,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: _priorityColor(note.priority).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: _priorityColor(note.priority).withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                note.priority.name.toUpperCase(),
                                style: TextStyle(
                                  color: _priorityColor(note.priority),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ── Title ────────────────────────────────────────
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

                        // ── Metadata strip ───────────────────────────────
                        GlassPane(
                          level: 3,
                          radius: 14,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _MetaItem(
                                icon: Icons.schedule_rounded,
                                label: _formatDate(note.createdAt),
                              ),
                              if (note.aiModel.isNotEmpty) ...[
                                _MetaItem(
                                  icon: Icons.auto_awesome_rounded,
                                  label: note.aiModel.toUpperCase(),
                                ),
                              ],
                              if (note.extractedDate != null)
                                _MetaItem(
                                  icon: Icons.event_rounded,
                                  label: _formatDate(note.extractedDate!),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // ── Body ──────────────────────────────────────────
                        SelectableText(
                          note.cleanBody.isNotEmpty
                              ? note.cleanBody
                              : note.rawTranscript,
                          style: TextStyle(
                            color: context.textPri,
                            fontSize: 16,
                            height: 1.7,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.1,
                          ),
                        ),

                        // ── Raw transcript (collapsible) ─────────────────
                        if (note.rawTranscript.isNotEmpty &&
                            note.rawTranscript != note.cleanBody) ...[
                          const SizedBox(height: 24),
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
    );
  }

  String _formatDate(DateTime dt) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 13, color: context.textSec),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          color: context.textSec,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

class _EditFab extends StatelessWidget {
  const _EditFab({required this.noteId});
  final String noteId;

  @override
  Widget build(BuildContext context) => FloatingActionButton.extended(
    heroTag: 'edit_fab_$noteId',
    onPressed: () {
      HapticFeedback.mediumImpact();
      context.push('/notes/$noteId');
    },
    backgroundColor: AppColors.tasks,
    foregroundColor: Theme.of(context).colorScheme.onPrimary,
    elevation: 8,
    icon: const Icon(Icons.edit_rounded, size: 18),
    label: const Text(
      'Edit',
      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
    ),
  );
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
    radius: 14,
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Row(
            children: [
              Icon(Icons.mic_none_rounded, size: 14, color: context.textSec),
              const SizedBox(width: 6),
              Text(
                'Raw Transcript',
                style: TextStyle(
                  color: context.textSec,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 18,
                color: context.textSec,
              ),
            ],
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 10),
          SelectableText(
            widget.rawTranscript,
            style: TextStyle(
              color: context.textSec,
              fontSize: 14,
              height: 1.6,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    ),
  );
}