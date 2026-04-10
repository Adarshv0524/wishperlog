import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class GlassNoteCard extends StatefulWidget {
  const GlassNoteCard({required this.note, super.key});

  final Note note;

  @override
  State<GlassNoteCard> createState() => _GlassNoteCardState();
}

class _GlassNoteCardState extends State<GlassNoteCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: AppDurations.aiShimmer,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final safeTitle = note.title.trim().isEmpty ? 'Quick note' : note.title;
    final safeBody = note.cleanBody.trim().isEmpty
        ? note.rawTranscript.trim()
        : note.cleanBody;
    final tint = categoryColor(note.category).withValues(alpha: 0.04);

    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, _) {
        final pending = note.status == NoteStatus.pendingAi;
        final borderColor = pending
            ? Color.lerp(
                    AppColors.journal,
                    AppColors.journal.withValues(alpha: 0.2),
                    _shimmerController.value,
                  ) ??
                  AppColors.journal
            : context.border;

        return AnimatedScale(
          duration: AppDurations.microSnap,
          scale: _pressed ? 0.97 : 1.0,
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: () {
              context.push('/notes/${note.noteId}/view', extra: note);
            },
            onLongPress: () {
              HapticFeedback.mediumImpact();
              context.push('/notes/${note.noteId}');
            },
            child: GlassPane(
              level: 2,
              radius: 16,
              tintOverride: tint,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor, width: 0.5),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 4.5,
                        decoration: BoxDecoration(
                          color: categoryColor(note.category),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    categoryIcon(note.category),
                                    size: 18,
                                    color: categoryColor(note.category),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      safeTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: context.textPri,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                safeBody,
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.35,
                                  color: context.textSec,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: categoryColor(note.category).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          categoryLabel(note.category),
                                          style: TextStyle(
                                            color: categoryColor(note.category),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatTime(note.extractedDate ?? note.createdAt),
                                        style: TextStyle(
                                          color: context.textSec,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (pending)
                                    Text(
                                      'AI pending',
                                      style: TextStyle(
                                        color: AppColors.journal,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime date) {
    if (DateTime.now().difference(date).inDays > 0) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } else {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }
}
