// lib/features/overlay/presentation/system_banner_overlay.dart
//
// Premium "God-Level" System Banner Overlay.
// Uses BackdropFilter + OverlaySettings for live customisation.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/overlay/overlay_settings_model.dart';
import 'package:wishperlog/features/overlay/quick_note_editor.dart';

class SystemBannerOverlay extends StatelessWidget {
  const SystemBannerOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        // Tap outside the card dismisses.
        onTap: () => context.pop(),
        child: Container(
          color: Colors.transparent,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                // Swipe up to dismiss
                GestureDetector(
                  // Prevent outer GestureDetector from firing on card tap.
                  onTap: () {},
                  child: Dismissible(
                    key: const Key('system_banner'),
                    direction: DismissDirection.up,
                    onDismissed: (_) => context.pop(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _PremiumBannerCard(
                        onClose: () => context.pop(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumBannerCard extends StatefulWidget {
  const _PremiumBannerCard({required this.onClose});

  final VoidCallback onClose;

  @override
  State<_PremiumBannerCard> createState() => _PremiumBannerCardState();
}

class _PremiumBannerCardState extends State<_PremiumBannerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late Animation<double> _scaleAnim;

  OverlaySettings get _settings {
    try {
      return sl<OverlayNotifier>().overlaySettings;
    } catch (_) {
      return const OverlaySettings();
    }
  }

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _fadeAnim  = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _scaleAnim = Tween<double>(begin: 0.94, end: 1.0)
        .animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutBack));

    _entryCtrl.forward();
    HapticFeedback.lightImpact();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── Decoration builder using OverlaySettings ──────────────────────────────

  Decoration _buildDecoration(OverlaySettings s) {
    final gradient = switch (s.colorFill) {
      OverlayColorFill.linearGradient => LinearGradient(
          colors: [s.gradientStart, s.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      OverlayColorFill.radialGradient => RadialGradient(
          colors: [s.gradientStart, s.gradientEnd],
        ),
      _ => null,
    };

    final solidFill = s.colorFill == OverlayColorFill.solid
        ? s.solidColor.withValues(alpha: s.alpha)
        : null;

    final glassFill = s.colorFill == OverlayColorFill.glass
        ? Colors.white.withValues(
            alpha: context.isDark ? s.alpha * 0.10 : s.alpha * 0.16,
          )
        : null;

    return BoxDecoration(
      color: solidFill ?? glassFill,
      gradient: gradient,
      borderRadius: BorderRadius.circular(24),
      border: switch (s.borderStyle) {
        OverlayBorderStyle.none     => null,
        OverlayBorderStyle.hairline => Border.all(
            color: s.borderColor.withValues(alpha: 0.5),
            width: 0.7,
          ),
        OverlayBorderStyle.glow => Border.all(
            color: s.borderColor.withValues(alpha: 0.9),
            width: 1.5,
          ),
      },
      boxShadow: [
        // Base elevation
        BoxShadow(
          color: Colors.black.withValues(alpha: context.isDark ? 0.40 : 0.14),
          blurRadius: 32,
          offset: const Offset(0, 12),
        ),
        // Glow layer
        if (s.borderStyle == OverlayBorderStyle.glow)
          BoxShadow(
            color: s.borderColor.withValues(alpha: 0.40),
            blurRadius: 24,
            spreadRadius: 1,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = _settings;

    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: s.colorFill == OverlayColorFill.glass ? s.blurSigma : 0,
                sigmaY: s.colorFill == OverlayColorFill.glass ? s.blurSigma : 0,
              ),
              child: Container(
                decoration: _buildDecoration(s),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Handle ───────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 10, bottom: 2),
                      child: Container(
                        width: 36, height: 4,
                        decoration: BoxDecoration(
                          color: context.textSec.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    // ── Header ───────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 6, 12, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Quick Capture',
                            style: TextStyle(
                              color: context.textPri,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: widget.onClose,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: context.surface1.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: context.textSec,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // ── Editor ───────────────────────────────────────────
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width - 32,
                        maxHeight: MediaQuery.sizeOf(context).height * 0.55,
                      ),
                      child: const QuickNoteEditor(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}