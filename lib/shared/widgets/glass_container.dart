import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

// ══════════════════════════════════════════════════════════════════════════════
// glass_container.dart v3.0 — Tactile Soft-Glass Containers
//
// GlassContainer — thin adapter that delegates to GlassPane.
//   All 4 Soft-Glass laws are inherited automatically from GlassPane v3.
//
// GlassBubble — the floating overlay bubble, redesigned to be a "Smoked Glass
//   Orb". It receives compound coloured ambient shadows (like LED backlighting),
//   an active-state glow pulse, and a rim-light edge ring for physical depth.
//
// No MethodChannels, Streams, or business logic were altered.
// ══════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────────────────────────────────────
// GlassContainer — generic glass card/panel
// ─────────────────────────────────────────────────────────────────────────────
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
    // Delegates entirely to GlassPane v3 — all 4 laws apply.
    return GlassPane(
      margin: margin,
      padding: padding,
      radius: resolvedRadius,
      level: 1,
      sigmaOverride: (sigmaX + sigmaY) / 2,
      child: child,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GlassBubble — the floating overlay FAB / recording bubble
//
// Soft-Glass mechanics applied:
//   • Rim Light: a 1.2 px gradient border ring (top-left bright → bottom-right
//     slightly dark) simulating anodized metal catching ambient room light.
//   • Compound Shadows: 3 layered drop shadows. In active state, the inner two
//     layers become coloured (category-tinted) "LED glow" per Dark Mode spec.
//   • Tactile Extrusion: the AnimatedContainer carries a subtle inner gradient
//     giving the orb physical volume (lighter at top-left, darker at bottom-right).
//   • BackdropFilter: blur applied via the ClipOval at 14 sigma.
// ─────────────────────────────────────────────────────────────────────────────
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
    final sigma = (sigmaX + sigmaY) / 2;

    // ── Color recipe ─────────────────────────────────────────────────────────
    final idleGradient = isDark
        ? [AppColors.darkGlass1, AppColors.darkGlass2]
        : [AppColors.lightGlass1, AppColors.lightGlass2];

    // Active gradient uses app brand colors for recording state
    const activeGradient = [AppColors.tasks, AppColors.journal];

    // ── Rim Light colors (for the circular gradient border) ──────────────────
    final rimBright = isDark ? AppColors.darkRimBright : AppColors.lightRimBright;
    final rimDark   = isDark ? AppColors.darkRimDark   : AppColors.lightRimDark;

    // ── Compound Shadow (3 layers, with active glow variation) ───────────────
    final activeGlowColor = AppColors.tasks.withValues(alpha: isDark ? 0.45 : 0.30);
    final errorGlowColor  = AppColors.errorStatus.withValues(alpha: isDark ? 0.40 : 0.28);

    final List<BoxShadow> shadows = [
      // Layer 1 — close, sharp
      BoxShadow(
        color: isActive
            ? activeGlowColor.withValues(alpha: 0.40)
            : isError
                ? errorGlowColor.withValues(alpha: 0.38)
                : (isDark ? AppColors.darkShadowClose : AppColors.lightShadowClose),
        blurRadius: isActive ? 12 : 8,
        spreadRadius: isActive ? 0 : -3,
        offset: const Offset(0, 3),
      ),
      // Layer 2 — mid, coloured glow in active/error states
      BoxShadow(
        color: isActive
            ? activeGlowColor.withValues(alpha: 0.25)
            : isError
                ? errorGlowColor.withValues(alpha: 0.22)
                : (isDark ? AppColors.darkShadowMid : AppColors.lightShadowMid),
        blurRadius: isActive ? 28 : 20,
        spreadRadius: isActive ? 2 : -6,
        offset: const Offset(0, 8),
      ),
      // Layer 3 — far diffusion
      BoxShadow(
        color: isActive
            ? activeGlowColor.withValues(alpha: 0.12)
            : (isDark ? AppColors.darkShadowFar : AppColors.lightShadowFar),
        blurRadius: 50,
        spreadRadius: -12,
        offset: const Offset(0, 18),
      ),
    ];

    return Opacity(
      opacity: normalizedOpacity,

      // ── Outer ring = Rim Light ────────────────────────────────────────────
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          // The 1.2 px gradient ring IS the rim light for the bubble
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [rimBright, rimDark],
          ),
          boxShadow: shadows,
        ),
        // 1.2 px uniform padding = rim light ring width
        padding: const EdgeInsets.all(1.2),

        child: ClipOval(
          // Law 1: Backdrop blur
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),

            // Inner glass orb (Laws 1 + 4)
            child: AnimatedContainer(
              duration: AppDurations.microSnap,
              curve: Curves.easeOutCubic,
              width: size - 2.4,
              height: size - 2.4,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                // Glass fill gradient (lighter at top = light source from above)
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isActive ? activeGradient : idleGradient,
                ),
              ),
              // Law 4: Tactile Extrusion — subtle inner shadow via foregroundDecoration
              foregroundDecoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.4,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.06 : 0.14),
                    Colors.transparent,
                    Colors.black.withValues(alpha: isDark ? 0.10 : 0.05),
                  ],
                  stops: const [0.0, 0.50, 1.0],
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}