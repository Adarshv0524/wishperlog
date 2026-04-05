import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

class FolderGrid extends StatelessWidget {
  const FolderGrid({required this.counts, super.key});

  final Map<NoteCategory, int> counts;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        const mainAxisSpacing = 10.0;
        const crossAxisSpacing = 10.0;

        final itemCount = kAllNoteCategories.length;
        final rowCount = (itemCount / crossAxisCount).ceil();
        final tileWidth =
            (constraints.maxWidth - (crossAxisSpacing * (crossAxisCount - 1))) /
            crossAxisCount;
        final tileHeight =
            (constraints.maxHeight - (mainAxisSpacing * (rowCount - 1))) /
            rowCount;
        final childAspectRatio = tileWidth / tileHeight;

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: childAspectRatio,
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
              child: _FolderCard(
                category: category,
                count: counts[category] ?? 0,
              ),
            );
          },
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
    final isDark = context.isDark;
    
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => context.push('/folder', extra: category),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  (isDark
                    ? categoryColor(category).withValues(alpha: 0.07)
                    : categoryColor(category).withValues(alpha: 0.06)),
                  (isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.white.withValues(alpha: 0.28)),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: categoryColor(category).withValues(
                  alpha: isDark ? 0.24 : 0.13,
                ),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.24)
                      : Colors.white.withValues(alpha: 0.30),
                  blurRadius: 16,
                  spreadRadius: -4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isCompact = constraints.maxHeight < 86;

                if (isCompact) {
                  return Row(
                    children: [
                      Text(
                        emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          categoryLabel(category),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.textPri,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      if (count > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.20),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: context.textPri,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
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
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      overdue
                          ? 'Needs attention'
                          : '${count == 0 ? 'No' : count} notes',
                      style: TextStyle(
                        color: overdue ? AppColors.reminders : context.textSec,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
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

