import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

// ══════════════════════════════════════════════════════════════════════════════
// top_notch_message.dart v3.0 — Tactile Soft-Glass Dynamic Island Pill
//
// The Dynamic Island pill is the most visually prominent transient element.
// Soft-Glass mechanics applied:
//
//   • Rim Light: The pill gets a bright top-left → dim bottom-right gradient
//     border (1.0 px wide). It simulates the pill being a physical extruded
//     "SmokGlass capsule" floating above the screen, with room light reflecting
//     off its top-left bevel. On dark backgrounds this is the primary depth cue.
//
//   • Compound Shadows: 3-layer drop shadows. The category colour bleeds into
//     the mid layer for a subtle "content-aware" ambient glow effect.
//
//   • BackdropFilter: the pill itself blurs what's behind it, maintaining the
//     frosted glass look even when the background changes (mesh, images, etc.)
//
//   • Spring-driven entry: vertical slide-up (from -36 px) + fade + scale for
//     a soft bouncy entrance that feels physically "popped up" from the notch.
//
// All original overlay/timer business logic preserved exactly.
// ══════════════════════════════════════════════════════════════════════════════

OverlayEntry? _activeTopNotchEntry;
Timer? _activeTopNotchTimer;

Future<void> showTopNotchSavedMessage({
  required BuildContext context,
  required String title,
  required NoteCategory category,
}) {
  final overlayState = Overlay.maybeOf(context);
  if (overlayState == null) return Future<void>.value();

  _activeTopNotchTimer?.cancel();
  _activeTopNotchEntry?.remove();
  _activeTopNotchEntry = null;

  final chipColor = categoryColor(category);

  final entry = OverlayEntry(
    builder: (ctx) => _TopNotchPill(
      title: title,
      category: category,
      chipColor: chipColor,
    ),
  );

  overlayState.insert(entry);
  _activeTopNotchEntry = entry;

  // Auto-remove after notch return duration (unchanged)
  _activeTopNotchTimer = Timer(AppDurations.notchAutoReturn, () {
    _activeTopNotchEntry?.remove();
    _activeTopNotchEntry = null;
    _activeTopNotchTimer = null;
  });

  return Future<void>.value();
}

// ─────────────────────────────────────────────────────────────────────────────
// _TopNotchPill — the actual floating capsule widget
// ─────────────────────────────────────────────────────────────────────────────
class _TopNotchPill extends StatefulWidget {
  const _TopNotchPill({
    required this.title,
    required this.category,
    required this.chipColor,
  });

  final String title;
  final NoteCategory category;
  final Color chipColor;

  @override
  State<_TopNotchPill> createState() => _TopNotchPillState();
}

class _TopNotchPillState extends State<_TopNotchPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppDurations.saveConfirm,
    );

    final curve = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _opacity    = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _translateY = Tween<double>(begin: -36.0, end: 0.0).animate(curve);
    _scale      = Tween<double>(begin: 0.82, end: 1.0).animate(curve);

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ── Rim light colors ─────────────────────────────────────────────────────
    final rimBright = isDark ? AppColors.darkRimBright : AppColors.lightRimBright;
    final rimMid    = isDark ? AppColors.darkRimMid    : AppColors.lightRimMid;
    final rimDark   = isDark ? AppColors.darkRimDark   : AppColors.lightRimDark;

    // ── Compound shadows — mid layer tinted with category colour ─────────────
    final List<BoxShadow> shadows = [
      BoxShadow(
        color: isDark ? AppColors.darkShadowClose : AppColors.lightShadowClose,
        blurRadius: 8,
        spreadRadius: -2,
        offset: const Offset(0, 3),
      ),
      // Category-aware ambient glow (content-aware depth)
      BoxShadow(
        color: widget.chipColor.withValues(alpha: isDark ? 0.18 : 0.12),
        blurRadius: 22,
        spreadRadius: -5,
        offset: const Offset(0, 7),
      ),
      BoxShadow(
        color: isDark ? AppColors.darkShadowFar : AppColors.lightShadowFar,
        blurRadius: 48,
        spreadRadius: -14,
        offset: const Offset(0, 18),
      ),
    ];

    // ── Glass fill ───────────────────────────────────────────────────────────
    final glassFillTop = isDark
        ? Colors.white.withValues(alpha: 0.13)
        : Colors.white.withValues(alpha: 0.82);
    final glassFillBottom = isDark
        ? const Color(0xFF111827).withValues(alpha: 0.90)
        : Colors.white.withValues(alpha: 0.60);

    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) => Opacity(
              opacity: _opacity.value,
              child: Transform.translate(
                offset: Offset(0, _translateY.value),
                child: Transform.scale(
                  scale: _scale.value,
                  child: child,
                ),
              ),
            ),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 48,
              ),
              margin: const EdgeInsets.only(top: 8),

              // ── LAW 2: Rim Light outer shell (gradient border) ──────────────
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [rimBright, rimMid, rimDark],
                  stops: const [0.0, 0.45, 1.0],
                ),
                // ── LAW 3: Compound Shadows ─────────────────────────────────
                boxShadow: shadows,
              ),
              padding: const EdgeInsets.all(1.0), // rim light ring width

              child: ClipRRect(
                borderRadius: BorderRadius.circular(998),
                // ── LAW 1: Backdrop Translucency ─────────────────────────────
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(998),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [glassFillTop, glassFillBottom],
                      ),
                    ),
                    // ── LAW 4: Tactile Extrusion foreground ─────────────────
                    foregroundDecoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(998),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          isDark
                              ? AppColors.darkExtrusionShadow
                              : AppColors.lightExtrusionShadow,
                        ],
                        stops: const [0.0, 0.50, 1.0],
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── "Saved" label ────────────────────────────────────
                        Text(
                          'Saved',
                          style: TextStyle(
                            color: context.textPri,
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '·',
                          style: TextStyle(
                            color: context.textSec,
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // ── Category chip (mini glass pill) ──────────────────
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            // Category-tinted glass fill
                            color: widget.chipColor.withValues(alpha: 0.18),
                            border: Border.all(
                              color: widget.chipColor.withValues(alpha: 0.30),
                              width: 0.7,
                            ),
                          ),
                          child: Text(
                            categoryLabel(widget.category),
                            style: TextStyle(
                              color: widget.chipColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        // ── Note title (truncated) ────────────────────────────
                        Flexible(
                          child: Text(
                            widget.title,
                            style: TextStyle(
                              color: context.textSec,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}