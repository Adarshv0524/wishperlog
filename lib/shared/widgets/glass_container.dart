import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    required this.child,
    super.key,
    this.padding,
    this.margin,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.sigmaX = 15,
    this.sigmaY = 15,
    this.shadowOpacity = 0.18,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadius borderRadius;
  final double sigmaX;
  final double sigmaY;
  final double shadowOpacity;

  @override
  Widget build(BuildContext context) {
    final resolvedRadius = borderRadius.topLeft.x;
    return GlassPane(
      margin: margin,
      padding: padding,
      radius: resolvedRadius,
      level: 1,
      child: child,
    );
  }
}

class GlassBubble extends StatelessWidget {
  const GlassBubble({
    required this.child,
    super.key,
    this.size = 76,
    this.opacity = 0.84,
    this.isActive = false,
    this.isError = false,
    this.sigmaX = 14,
    this.sigmaY = 14,
  });

  final Widget child;
  final double size;
  final double opacity;
  final bool isActive;
  final bool isError;
  final double sigmaX;
  final double sigmaY;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalizedOpacity = opacity.clamp(0.2, 1.0);

    final idleGradient = isDark
        ? [AppColors.darkGlass1, AppColors.darkGlass2]
        : [AppColors.lightGlass1, AppColors.lightGlass2];

    return Opacity(
      opacity: normalizedOpacity,
      child: GlassPane(
        level: 4,
        radius: size,
        sigmaOverride: (sigmaX + sigmaY) / 2,
        child: AnimatedContainer(
          duration: AppDurations.microSnap,
          curve: Curves.easeOutCubic,
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [AppColors.tasks, AppColors.journal]
                  : idleGradient,
            ),
            border: Border.all(
              color: isActive
                  ? (isDark ? AppColors.darkTextPri : AppColors.lightTextPri).withValues(alpha: 0.18)
                  : isError
                  ? AppColors.errorStatus.withValues(alpha: 0.42)
                  : Colors.white.withValues(alpha: isDark ? 0.72 : 0.86),
              width: isActive ? 2.0 : 1.3,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
