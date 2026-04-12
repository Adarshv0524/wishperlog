import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';

// ══════════════════════════════════════════════════════════════════════════════
// GlassPane v3.0 — Tactile Soft-Glass Core Component
//
// Implements all 4 Anatomical Laws of the Soft-Glass Formula:
//
//   LAW 1 — Backdrop Translucency
//     BackdropFilter(ImageFilter.blur) wraps the content. Sigma scales by level.
//
//   LAW 2 — Rim Light (THE most critical detail — 1.0 px specular highlight)
//     The outermost Container uses a LinearGradient as its fill.
//     The gradient runs top-left (bright white) → mid (transparent) → bottom-right
//     (very subtly dark). A 1.0 px Padding child creates the "bevel catch" effect,
//     exactly like physical light catching the edge of a frosted acrylic sheet.
//
//   LAW 3 — Compound Spatial Elevation (3-layer drop shadows)
//     Three BoxShadow entries at distinct blur/offset/opacity values create the
//     highly diffused "floating softly" appearance. Dark mode uses coloured
//     ambient glows; light mode uses cool desaturated grey.
//
//   LAW 4 — Tactile Extrusion (Inner Shadow simulation)
//     A foregroundDecoration with a very low opacity top-left→bottom-right
//     gradient wraps the content. This gives the "puffed ceramic" volume.
//     Opacity is 10% dark / 5% light — barely perceptible, purely tactile.
//
// ARCHITECTURE NOTE:
//   GlassPane is the single foundational primitive. GlassContainer, GlassBubble,
//   GlassTitleBar, FolderScreen, NoteCard all compose it.
//   All 4 laws apply uniformly at this single layer.
// ══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// FolderGlassTint — propagates a folder category tint down the tree
// (unchanged from v2; kept here for co-location)
// ─────────────────────────────────────────────────────────────────────────────
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

// ─────────────────────────────────────────────────────────────────────────────
// GlassPane
// ─────────────────────────────────────────────────────────────────────────────
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

  /// Elevation level 1-4. Controls blur strength and shadow intensity.
  /// Level 1 = most opaque, highest blur (for primary panels/cards).
  /// Level 4 = most transparent, least blur (for overlapping micro-surfaces).
  final int level;

  final double radius;
  final Color? tintOverride;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? sigmaOverride;

  // ── Law 1: Backdrop blur sigma by level ──────────────────────────────────
  double get _blur {
    if (sigmaOverride != null) return sigmaOverride!;
    return switch (level) {
      1 => 32.0,  // Primary panels — heavy frosted
      2 => 38.0,  // Elevated surfaces — extra frosted
      3 => 24.0,  // Secondary overlapping panels
      4 => 14.0,  // Micro surfaces (chips, badges)
      _ => 32.0,
    };
  }

  // ── Glass fill color (mode-aware) ─────────────────────────────────────────
  Color _fillFor(BuildContext context) {
    final base = switch (level) {
      1 => context.glass1,
      2 => context.glass2,
      3 => context.glass3,
      4 => context.glass3,
      _ => context.glass1,
    };
    var output = base;
    final folderTint = FolderGlassTint.maybeOf(context);
    if (folderTint != null) output = Color.alphaBlend(folderTint, output);
    if (tintOverride != null) output = Color.alphaBlend(tintOverride!, output);
    return output;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final baseFill = _fillFor(context);
    final r = radius;

    // ── Glass gradient fills (top-left lighter, bottom-right darker) ─────────
    // Mimics light hitting the top surface of a polished/smoked glass sheet.
    final topLayer = Color.alphaBlend(
      Colors.white.withValues(alpha: isDark ? 0.09 : 0.38),
      baseFill,
    );
    final bottomLayer = Color.alphaBlend(
      Colors.black.withValues(alpha: isDark ? 0.16 : 0.04),
      baseFill,
    );

    // ── Law 2: Rim Light gradient colors ─────────────────────────────────────
    // Dark "Smoked Glass": bright metallic rim is THE depth cue
    // Light "Polished Resin": crisp white rim; shadows do more depth work
    final rimBright = isDark ? AppColors.darkRimBright  : AppColors.lightRimBright;
    final rimMid    = isDark ? AppColors.darkRimMid     : AppColors.lightRimMid;
    final rimDark   = isDark ? AppColors.darkRimDark    : AppColors.lightRimDark;

    // ── Law 3: Compound Spatial Elevation — 3 shadow layers ─────────────────
    // Dark mode: coloured ambient glow (LED backlight simulation)
    // Light mode: cool desaturated grey (shadow depth on bright bg)
    final List<BoxShadow> shadows = isDark
        ? [
            // Close shadow — tight, ~24% opacity
            BoxShadow(
              color: AppColors.darkShadowClose,
              blurRadius: 8,
              spreadRadius: -3,
              offset: const Offset(0, 3),
            ),
            // Mid shadow — medium spread, ~18% opacity
            BoxShadow(
              color: AppColors.darkShadowMid,
              blurRadius: 24,
              spreadRadius: -7,
              offset: const Offset(0, 9),
            ),
            // Far ambient glow — very diffused, ~12% opacity
            BoxShadow(
              color: AppColors.darkShadowFar,
              blurRadius: 60,
              spreadRadius: -14,
              offset: const Offset(0, 22),
            ),
          ]
        : [
            // Close shadow — tight, cool blue-grey tint
            BoxShadow(
              color: AppColors.lightShadowClose,
              blurRadius: 7,
              spreadRadius: -2,
              offset: const Offset(0, 3),
            ),
            // Mid shadow — medium diffusion
            BoxShadow(
              color: AppColors.lightShadowMid,
              blurRadius: 20,
              spreadRadius: -6,
              offset: const Offset(0, 8),
            ),
            // Far ambient — barely visible, just softens the float
            BoxShadow(
              color: AppColors.lightShadowFar,
              blurRadius: 50,
              spreadRadius: -14,
              offset: const Offset(0, 18),
            ),
          ];

    // ── Law 4: Tactile Extrusion colors ──────────────────────────────────────
    // Bottom-right receives a very subtle darkening to simulate the light source
    // not wrapping around the far side of the "puffed" object.
    final extrusionColor = isDark
        ? AppColors.darkExtrusionShadow
        : AppColors.lightExtrusionShadow;

    return Container(
      margin: margin,

      // ── OUTER SHELL (Laws 2 + 3) ──────────────────────────────────────────
      // The gradient fill here IS the rim light. The 1.0 px Padding below
      // means only this 1 px "ring" is ever visible — the frosted glass fills
      // the interior. Linear gradient from top-left (bright) to bottom-right
      // (dark) perfectly replicates the physical bevel catch.
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [rimBright, rimMid, rimDark],
          stops: const [0.0, 0.45, 1.0],
        ),
        boxShadow: shadows,
      ),

      // 1.0 px uniform border = rim light ring thickness
      padding: const EdgeInsets.all(1.0),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(r - 1.0),

        // ── Law 1: Backdrop Translucency ─────────────────────────────────────
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),

          // ── INNER GLASS SURFACE (Laws 1 + 4) ────────────────────────────────
          child: Container(
            padding: padding,

            // Glass fill gradient
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r - 1.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [topLayer, bottomLayer],
              ),
            ),

            // ── Law 4: Tactile Extrusion overlay ─────────────────────────────
            // foregroundDecoration paints ABOVE the child in the widget tree,
            // but at only 5-10% opacity it's imperceptible on content while
            // adding the essential "clay-like 3D volume" to the surface itself.
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r - 1.0),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  extrusionColor,
                ],
                stops: const [0.0, 0.52, 1.0],
              ),
            ),

            child: child,
          ),
        ),
      ),
    );
  }
}