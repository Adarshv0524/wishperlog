import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';

class FolderGlassTint extends InheritedWidget {
  const FolderGlassTint({required this.tint, required super.child, super.key});

  final Color? tint;

  static Color? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FolderGlassTint>()?.tint;
  }

  @override
  bool updateShouldNotify(covariant FolderGlassTint oldWidget) {
    return oldWidget.tint != tint;
  }
}

class GlassPane extends StatelessWidget {
  const GlassPane({
    required this.child,
    super.key,
    this.level = 1,
    this.radius = 12,
    this.tintOverride,
    this.padding,
    this.margin,
    this.sigmaOverride,
  });

  final Widget child;
  final int level;
  final double radius;
  final Color? tintOverride;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? sigmaOverride;

  double get _blur {
    if (sigmaOverride != null) {
      return sigmaOverride!;
    }
    switch (level) {
      case 1:
        return 30; // 20 -> 30
      case 2:
        return 36; // 24 -> 36
      case 3:
        return 24; // 16 -> 24
      case 4:
        return 12; // 8 -> 12
      default:
        return 30;
    }
  }

  Color _fillFor(BuildContext context) {
    final base = switch (level) {
      1 => context.glass1,
      2 => context.glass2,
      3 => context.glass3,
      4 => context.glass3,
      _ => context.glass1,
    };
    final folderTint = FolderGlassTint.maybeOf(context);

    var output = base;
    if (folderTint != null) {
      output = Color.alphaBlend(folderTint, output);
    }
    if (tintOverride != null) {
      output = Color.alphaBlend(tintOverride!, output);
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    final baseFill = _fillFor(context);
    final isDark = context.isDark;
    final topLayer = Color.alphaBlend(
      Colors.white.withValues(alpha: isDark ? 0.08 : 0.32),
      baseFill,
    );
    final bottomLayer = Color.alphaBlend(
      Colors.black.withValues(alpha: isDark ? 0.14 : 0.03),
      baseFill,
    );

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [topLayer, bottomLayer],
              ),
              border: Border.all(
                color: context.border.withValues(alpha: isDark ? 0.95 : 0.75),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.28)
                      : Colors.white.withValues(alpha: 0.48),
                  blurRadius: isDark ? 22 : 18,
                  spreadRadius: -8,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
