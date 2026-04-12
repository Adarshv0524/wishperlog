import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/features/ai/data/ai_classifier_router.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

// ══════════════════════════════════════════════════════════════════════════════
// sign_in_screen.dart v4.0 — Immediate Gamified Overlay (Race-Condition Fix)
//
// CRITICAL FIX — Login Processing Race Condition:
//   Previous behaviour: overlay appeared AFTER signInWithGoogle() returned.
//   New behaviour: overlay appears IMMEDIATELY when the user taps the button.
//   signInWithGoogle(), AI hydration, and Isar init all run concurrently inside
//   _doPostSignInWork(), which is passed as workFuture to _EnvironmentSetupOverlay.
//   The overlay animation plays while real work is in progress.
//
//   If work fails (e.g. Google sign-in cancelled), the overlay closes itself and
//   _signIn() surfaces the error through _showGlassError() as before.
// ══════════════════════════════════════════════════════════════════════════════

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _signingIn = false;

  void _showGlassError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          content: GlassContainer(
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Text(
              message,
              style: TextStyle(
                color: context.textPri,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ),
      );
  }

  /// Entry-point when the user taps the Google sign-in button.
  ///
  /// KEY CHANGE v4: We show the gamified overlay card IMMEDIATELY (before
  /// any async work starts) by kicking off [_doPostSignInWork] as a Future
  /// and passing it to the overlay so both the animation and the real work
  /// run concurrently.  Any exception from the work is re-surfaced here
  /// after the dialog closes.
  Future<void> _signIn() async {
    if (_signingIn) return;
    setState(() => _signingIn = true);
    try {
      await _runSetupAnimationWithWork();
      if (!mounted) return;
      context.go('/permissions');
    } on SignInFriendlyException catch (e) {
      _showGlassError(e.message);
    } catch (_) {
      _showGlassError('Sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  /// Shows the gamified overlay card immediately, passing real work as a
  /// concurrent future.  After the dialog closes (success or failure), any
  /// exception from the work future is re-thrown so [_signIn] can surface it.
  Future<void> _runSetupAnimationWithWork() async {
    // ── Start the real work NOW, before the dialog is even mounted. ──────────
    final workFuture = _doPostSignInWork();

    // ── Show overlay immediately. It drives itself via workFuture. ───────────
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.60),
      builder: (_) => _EnvironmentSetupOverlay(
        workFuture: workFuture,
        onDone: () {},
      ),
    );

    // ── Re-surface any error that occurred during background work. ────────────
    // If workFuture completed with an error, awaiting it here will rethrow,
    // which propagates to _signIn() → catch → _showGlassError().
    await workFuture;
  }

  /// All background work runs here, concurrently with the animation overlay.
  ///
  /// Includes: Google sign-in, AI hydration, Isar init.
  Future<void> _doPostSignInWork() async {
    // Step 1 – Authenticate with Google. May throw SignInFriendlyException.
    await sl<UserRepository>().signInWithGoogle();

    // Steps 2 & 3 – Non-blocking hydration; failures are silenced so they
    // don't block navigation if optional services are unavailable.
    try {
      await sl<AiClassifierRouter>().hydrate();
    } catch (_) {}
    try {
      await IsarNoteStore.instance.init();
    } catch (_) {}

    // Brief pause so the final "Everything is ready!" step is readable.
    await Future<void>.delayed(const Duration(milliseconds: 200));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final List<BoxShadow> logoShadows = [
      BoxShadow(
        color: const Color(0xFF6366F1).withValues(alpha: 0.40),
        blurRadius: 14,
        spreadRadius: -2,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: const Color(0xFF6366F1).withValues(alpha: 0.22),
        blurRadius: 32,
        spreadRadius: -6,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: const Color(0xFF6366F1).withValues(alpha: 0.10),
        blurRadius: 64,
        spreadRadius: -16,
        offset: const Offset(0, 24),
      ),
    ];

    final logoRimBright = isDark
        ? Colors.white.withValues(alpha: 0.36)
        : Colors.white.withValues(alpha: 0.55);
    final logoRimDark = isDark
        ? Colors.black.withValues(alpha: 0.24)
        : Colors.black.withValues(alpha: 0.12);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassPane(
                level: 1,
                radius: 28,
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Logo mark ─────────────────────────────────────────────
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [logoRimBright, logoRimDark],
                        ),
                        boxShadow: logoShadows,
                      ),
                      padding: const EdgeInsets.all(1.2),
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF7C72FF),
                              Color(0xFF6045FA),
                              Color(0xFF4C35E8),
                            ],
                            stops: [0.0, 0.5, 1.0],
                          ),
                        ),
                        foregroundDecoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: Alignment.topLeft,
                            radius: 1.6,
                            colors: [
                              Color(0x22FFFFFF),
                              Colors.transparent,
                              Color(0x12000000),
                            ],
                            stops: [0.0, 0.45, 1.0],
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'WishperLog',
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Capture thoughts instantly.\nLet AI organise your day quietly in the background.',
                      style: TextStyle(
                        color: context.textSec,
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 30),

                    // ── Google Sign-In Button ────────────────────────────────
                    _TactileGoogleSignInButton(
                      onTap: _signIn,
                      loading: _signingIn,
                    ),

                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms & Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: context.textSec.withValues(alpha: 0.60),
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
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

// ─────────────────────────────────────────────────────────────────────────────
// _TactileGoogleSignInButton — unchanged visual treatment from v3
// ─────────────────────────────────────────────────────────────────────────────
class _TactileGoogleSignInButton extends StatefulWidget {
  const _TactileGoogleSignInButton({required this.onTap, required this.loading});
  final VoidCallback onTap;
  final bool loading;

  @override
  State<_TactileGoogleSignInButton> createState() =>
      _TactileGoogleSignInButtonState();
}

class _TactileGoogleSignInButtonState
    extends State<_TactileGoogleSignInButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final rimBright = isDark ? AppColors.darkRimBright : AppColors.lightRimBright;
    final rimMid    = isDark ? AppColors.darkRimMid    : AppColors.lightRimMid;
    final rimDark   = isDark ? AppColors.darkRimDark   : AppColors.lightRimDark;

    final List<BoxShadow> raisedShadows = isDark
        ? [
            BoxShadow(
              color: AppColors.darkShadowClose,
              blurRadius: 10,
              spreadRadius: -2,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: AppColors.darkShadowMid,
              blurRadius: 26,
              spreadRadius: -6,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.darkShadowFar,
              blurRadius: 56,
              spreadRadius: -14,
              offset: const Offset(0, 22),
            ),
          ]
        : [
            BoxShadow(
              color: AppColors.lightShadowClose,
              blurRadius: 8,
              spreadRadius: -2,
              offset: const Offset(0, 3),
            ),
            BoxShadow(
              color: AppColors.lightShadowMid,
              blurRadius: 22,
              spreadRadius: -6,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.lightShadowFar,
              blurRadius: 50,
              spreadRadius: -14,
              offset: const Offset(0, 18),
            ),
          ];

    return GestureDetector(
      onTapDown: (_) { if (!widget.loading) setState(() => _pressed = true); },
      onTapUp: (_) {
        setState(() => _pressed = false);
        if (!widget.loading) widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          height: 54,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [rimBright, rimMid, rimDark],
              stops: const [0.0, 0.45, 1.0],
            ),
            boxShadow: _pressed ? [] : raisedShadows,
          ),
          padding: const EdgeInsets.all(1.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(998),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 110),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(998),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                            Colors.white.withValues(alpha: _pressed ? 0.09 : 0.13),
                            Colors.white.withValues(alpha: _pressed ? 0.04 : 0.06),
                          ]
                        : [
                            Colors.white.withValues(alpha: _pressed ? 0.72 : 0.88),
                            Colors.white.withValues(alpha: _pressed ? 0.52 : 0.66),
                          ],
                  ),
                ),
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
                    stops: const [0.0, 0.55, 1.0],
                  ),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: widget.loading
                        ? SizedBox(
                            key: const ValueKey('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation(
                                context.textPri.withValues(alpha: 0.80),
                              ),
                            ),
                          )
                        : Row(
                            key: const ValueKey('idle'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/google_logo.svg',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Continue with Google',
                                style: TextStyle(
                                  color: context.textPri,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  letterSpacing: 0.1,
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

// ─────────────────────────────────────────────────────────────────────────────
// _EnvironmentSetupOverlay
//
// CRITICAL FIX v4: workFuture now INCLUDES signInWithGoogle() — so the overlay
// appears immediately on tap, and the animation runs while authentication and
// hydration happen concurrently.  If workFuture throws, the overlay closes
// itself so _signIn() can surface the error.
// ─────────────────────────────────────────────────────────────────────────────
class _EnvironmentSetupOverlay extends StatefulWidget {
  const _EnvironmentSetupOverlay({
    required this.workFuture,
    required this.onDone,
  });

  final Future<void> workFuture;
  final VoidCallback onDone;

  @override
  State<_EnvironmentSetupOverlay> createState() =>
      _EnvironmentSetupOverlayState();
}

class _EnvironmentSetupOverlayState extends State<_EnvironmentSetupOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeIn;
  late final AnimationController _orbController;
  late final Animation<double> _orb1;
  late final Animation<double> _orb2;

  int _stepIndex = 0;
  double _progressValue = 0.12;

  static const _steps = [
    _Step(badge: 'auth',      text: 'Authenticating with Google…'),
    _Step(badge: 'classify',  text: 'Loading your AI classifier…'),
    _Step(badge: 'store',     text: 'Preparing your local vault…'),
    _Step(badge: 'ready',     text: 'Everything is ready!'),
  ];

  static const _minDuration   = Duration(milliseconds: 2200);
  static const _stepDuration  = Duration(milliseconds: 520);

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    );
    _fadeIn = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOutCubic);
    _fadeCtrl.forward();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _orb1 = Tween<double>(begin: 0, end: math.pi * 2).animate(_orbController);
    _orb2 = Tween<double>(begin: math.pi, end: math.pi * 3).animate(_orbController);

    _runSteps();
  }

  Future<void> _runSteps() async {
    final workAndMin = Future.wait([
      widget.workFuture,
      Future<void>.delayed(_minDuration),
    ]);

    // Animate through steps 0 → n-2 while work + min-duration run.
    for (var i = 0; i < _steps.length - 1; i++) {
      await Future<void>.delayed(_stepDuration);
      if (mounted) {
        setState(() {
          _stepIndex = i + 1;
          _progressValue = (i + 1) / (_steps.length - 1) * 0.88;
        });
      }
    }

    // Wait for work to finish. If it fails, close the dialog so _signIn()
    // can catch the exception from the re-awaited workFuture.
    try {
      await workAndMin;
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // Success path: show final step, brief pause, dismiss.
    if (mounted) {
      setState(() {
        _stepIndex = _steps.length - 1;
        _progressValue = 1.0;
      });
      await Future<void>.delayed(const Duration(milliseconds: 480));
      widget.onDone();
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _orbController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeIn,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 80),
        child: GlassPane(
          level: 1,
          radius: 28,
          padding: const EdgeInsets.fromLTRB(26, 32, 26, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Step badge chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.06),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.14 : 0.18),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  _steps[_stepIndex].badge.toUpperCase(),
                  style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : Theme.of(context).colorScheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Animated orb
              SizedBox(
                width: 128,
                height: 128,
                child: AnimatedBuilder(
                  animation: _orbController,
                  builder: (context, child) => CustomPaint(
                    painter: _OrbPainter(
                      angle1: _orb1.value,
                      angle2: _orb2.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFF8B5CF6),
                size: 22,
              ),
              const SizedBox(height: 16),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: Text(
                  _steps[_stepIndex].text,
                  key: ValueKey(_stepIndex),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Stay with us. The setup is doing real work in the background.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.62),
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _progressValue),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  builder: (context, value, child) => LinearProgressIndicator(
                    value: value,
                    minHeight: 5,
                    backgroundColor: Colors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6366F1),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StageChip(label: 'authenticating'),
                  const SizedBox(width: 8),
                  _StageChip(label: 'syncing AI'),
                  const SizedBox(width: 8),
                  _StageChip(label: 'readying vault'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${(_progressValue * 100).toInt()}%',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
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

class _Step {
  const _Step({required this.badge, required this.text});
  final String badge;
  final String text;
}

// ─────────────────────────────────────────────────────────────────────────────
// _OrbPainter — two revolving gradient orbs
// ─────────────────────────────────────────────────────────────────────────────
class _OrbPainter extends CustomPainter {
  _OrbPainter({required this.angle1, required this.angle2});
  final double angle1;
  final double angle2;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  * 0.3;

    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.9,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF6366F1), const Color(0xFF6366F1).withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.9))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    final o1 = Offset(cx + r * math.cos(angle1), cy + r * math.sin(angle1));
    canvas.drawCircle(
      o1,
      r * 0.45,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF8B5CF6), const Color(0xFF6366F1).withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: o1, radius: r * 0.45))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16),
    );

    final o2 = Offset(
        cx + r * 0.6 * math.cos(angle2), cy + r * 0.6 * math.sin(angle2));
    canvas.drawCircle(
      o2,
      r * 0.3,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFEC4899), const Color(0xFFEC4899).withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: o2, radius: r * 0.3))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  @override
  bool shouldRepaint(_OrbPainter old) =>
      old.angle1 != angle1 || old.angle2 != angle2;
}

// ─────────────────────────────────────────────────────────────────────────────
// _StageChip — glass mini-badge
// ─────────────────────────────────────────────────────────────────────────────
class _StageChip extends StatelessWidget {
  const _StageChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.white.withValues(alpha: 0.08),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.78),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}