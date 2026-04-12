import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

// ══════════════════════════════════════════════════════════════════════════════
// glass_title_bar.dart v3.0 — Tactile Soft-Glass Title Bar
//
// Soft-Glass mechanics applied:
//   • GlassTitleBar: wraps GlassPane(level:1) — inherits all 4 laws.
//   • Back button (_TactileBackButton): now a fully "Polished Resin" tactile
//     element. It has:
//       - Its own compound shadow (elevated above the title bar surface)
//       - A brighter rim-light gradient border (it's the most interactive element)
//       - An AnimatedScale on press (0.92) to simulate physical depression
//       - The inner gradient goes light-top-left → dark-bottom-right (3D volume)
//
// All onBack callbacks and Streams preserved unchanged.
// ══════════════════════════════════════════════════════════════════════════════
class GlassTitleBar extends StatelessWidget implements PreferredSizeWidget {
  const GlassTitleBar({
    required this.title,
    required this.onBack,
    super.key,
    this.subtitle,
    this.trailing,
    this.leading,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final Widget? trailing;
  final Widget? leading;

  @override
  Size get preferredSize => const Size.fromHeight(82);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 8),
        child: GlassPane(
          level: 1,
          radius: 22,
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
          // Soft blue tint for the title bar surface (slightly cooler than the page BG)
          tintOverride: context.isDark
              ? const Color(0x6610243F)
              : const Color(0xBFEFF7FF),
          child: Row(
            children: [
              _TactileBackButton(onTap: onBack),
              const SizedBox(width: 8),
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    if (subtitle != null && subtitle!.trim().isNotEmpty)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: context.textSec,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TactileBackButton
//
// A micro "Polished Resin" button. Floats above the title bar via its own
// compound shadow, with a bright top-left rim and AnimatedScale on press.
// ─────────────────────────────────────────────────────────────────────────────
class _TactileBackButton extends StatefulWidget {
  const _TactileBackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  State<_TactileBackButton> createState() => _TactileBackButtonState();
}

class _TactileBackButtonState extends State<_TactileBackButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    // Rim light colors for the button border
    final rimBright = isDark ? AppColors.darkRimBright : AppColors.lightRimBright;
    final rimDark   = isDark ? AppColors.darkRimDark   : AppColors.lightRimDark;

    // Compound shadows (button floats above the title bar panel)
    final shadows = isDark
        ? [
            BoxShadow(
              color: AppColors.darkShadowClose,
              blurRadius: 6,
              spreadRadius: -1,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: AppColors.darkShadowMid,
              blurRadius: 14,
              spreadRadius: -4,
              offset: const Offset(0, 5),
            ),
          ]
        : [
            BoxShadow(
              color: AppColors.lightShadowClose,
              blurRadius: 5,
              spreadRadius: -1,
              offset: const Offset(0, 2),
            ),
            BoxShadow(
              color: AppColors.lightShadowMid,
              blurRadius: 12,
              spreadRadius: -4,
              offset: const Offset(0, 4),
            ),
          ];

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
          width: 40,
          height: 40,
          // Outer ring = Rim Light for the button
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [rimBright, rimDark],
            ),
            boxShadow: _pressed ? [] : shadows,
          ),
          padding: const EdgeInsets.all(1.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              // Inner glass surface with top-to-bottom gradient (light source from above)
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [
                        Colors.white.withValues(alpha: _pressed ? 0.10 : 0.16),
                        Colors.white.withValues(alpha: _pressed ? 0.04 : 0.07),
                      ]
                    : [
                        Colors.white.withValues(alpha: _pressed ? 0.60 : 0.78),
                        Colors.white.withValues(alpha: _pressed ? 0.36 : 0.52),
                      ],
              ),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: context.textPri,
              size: 17,
            ),
          ),
        ),
      ),
    );
  }
}