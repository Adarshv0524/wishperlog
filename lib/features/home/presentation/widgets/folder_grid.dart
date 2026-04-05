import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class FolderGrid extends StatelessWidget {
  const FolderGrid({required this.counts, super.key});

  final Map<NoteCategory, int> counts;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: kAllNoteCategories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
      ),
      itemBuilder: (context, index) {
        final category = kAllNoteCategories[index];
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
          child: _FolderCard(category: category, count: counts[category] ?? 0),
        );
      },
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({required this.category, required this.count});

  final NoteCategory category;
  final int count;

  @override
  Widget build(BuildContext context) {
    final catColor = categoryColor(category);
    final emoji = categoryEmoji(category);
    final overdue = category == NoteCategory.reminders && count > 0;
    
    return GlassPane(
      level: 2,
      radius: 20,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.push('/folder', extra: category),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border(left: BorderSide(color: catColor, width: 4.5)),
            color: categoryFolderBg(category, context.isDark).withValues(alpha: 0.12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                  _CountBadge(count: count, color: catColor),
                ],
              ),
              const Spacer(),
              Text(
                categoryLabel(category),
                style: TextStyle(
                  color: context.textPri,
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                overdue ? 'Needs attention' : '${count == 0 ? 'No' : count} notes',
                style: TextStyle(
                  color: overdue ? AppColors.reminders : context.textSec,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.color});

  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TweenAnimationBuilder<int>(
        tween: IntTween(begin: 0, end: count),
        duration: AppDurations.countRoll,
        builder: (context, value, _) {
          return Text(
            '$value',
            style: TextStyle(
              color: context.textPri,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          );
        },
      ),
    );
  }
}

