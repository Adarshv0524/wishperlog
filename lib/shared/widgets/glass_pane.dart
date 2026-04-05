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
              color: _fillFor(context),
              border: Border.all(color: context.border, width: 0.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
