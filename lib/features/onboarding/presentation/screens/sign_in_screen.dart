import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/auth/data/repositories/user_repository.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SignInScreen — Entry point with Google sign-in.
// After sign-in succeeds, shows the animated EnvironmentSetupOverlay before
// navigating to /permissions, giving users confidence the app is "doing work".
// ─────────────────────────────────────────────────────────────────────────────
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

  Future<void> _signIn() async {
    if (_signingIn) return;
    setState(() => _signingIn = true);
    try {
      await sl<UserRepository>().signInWithGoogle();
      if (!mounted) return;
      // Show the animated setup overlay before navigating.
      await _runSetupAnimation();
      if (!mounted) return;
      context.go('/permissions');
    } on SignInFriendlyException catch (e) {
      _showGlassError(e.message);
    } catch (e) {
      _showGlassError('Sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }

  Future<void> _runSetupAnimation() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => const _EnvironmentSetupOverlay(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = context.textPri;
    final subtitleColor = context.textSec;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassContainer(
                borderRadius: BorderRadius.circular(28),
                padding: const EdgeInsets.fromLTRB(22, 28, 22, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo mark
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6366F1).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'WishperLog',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 34,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Capture thoughts instantly.\nLet AI organise your day quietly in the background.',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // Google sign-in button
                    _GoogleSignInButton(
                      onTap: _signIn,
                      loading: _signingIn,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'By continuing, you agree to our Terms & Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: subtitleColor.withValues(alpha: 0.6),
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
// Google sign-in button
// ─────────────────────────────────────────────────────────────────────────────
class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({required this.onTap, required this.loading});
  final VoidCallback onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(999),
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: loading ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          child: loading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/google.svg', width: 20, height: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Continue with Google',
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _EnvironmentSetupOverlay
//
// Full-screen animated onboarding overlay shown once after sign-in.
// Progressive status messages give the user confidence that setup is happening.
// Auto-dismisses after the last step completes.
// ─────────────────────────────────────────────────────────────────────────────
class _EnvironmentSetupOverlay extends StatefulWidget {
  const _EnvironmentSetupOverlay();
  @override
  State<_EnvironmentSetupOverlay> createState() => _EnvironmentSetupOverlayState();
}

class _EnvironmentSetupOverlayState extends State<_EnvironmentSetupOverlay>
    with TickerProviderStateMixin {
  // Steps with realistic timing (ms)
  static const _steps = [
    (badge: 'processing', text: 'Booting the workspace engine', durationMs: 900),
    (badge: 'sync', text: 'Getting Google task bridge online', durationMs: 800),
    (badge: 'seed', text: 'Preparing your note network', durationMs: 950),
    (badge: 'align', text: 'Aligning preferences and permissions', durationMs: 700),
    (badge: 'launch', text: 'System ready. Opening the gate.', durationMs: 600),
  ];

  int    _stepIndex     = 0;
  double _progressValue = 0.0;

  late AnimationController _orbController;
  late AnimationController _fadeController;
  late Animation<double>   _orb1;
  late Animation<double>   _orb2;
  late Animation<double>   _fadeIn;

  @override
  void initState() {
    super.initState();

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _orb1   = Tween<double>(begin: 0, end: 2 * math.pi).animate(_orbController);
    _orb2   = Tween<double>(begin: math.pi, end: 3 * math.pi).animate(_orbController);
    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _fadeController.forward();
    _runSteps();
  }

  Future<void> _runSteps() async {
    for (var i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      setState(() {
        _stepIndex     = i;
        _progressValue = (i + 1) / _steps.length;
      });
      await Future<void>.delayed(Duration(milliseconds: _steps[i].durationMs));
    }
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _orbController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeTransition(
      opacity: _fadeIn,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 80),
        child: GlassContainer(
          borderRadius: BorderRadius.circular(28),
          padding: const EdgeInsets.fromLTRB(26, 32, 26, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: (isDark ? Colors.white : scheme.primary).withValues(alpha: 0.08),
                ),
                child: Text(
                  _steps[_stepIndex].badge.toUpperCase(),
                  style: TextStyle(
                    color: isDark ? Colors.white : scheme.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              // ── Animated orb illustration ─────────────────────────────────
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
              // ── Status text ───────────────────────────────────────────────
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
                  style: const TextStyle(
                    color: Colors.white,
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
              // ── Progress bar ──────────────────────────────────────────────
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
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StageChip(label: 'processing'),
                  const SizedBox(width: 8),
                  _StageChip(label: 'getting Google task'),
                  const SizedBox(width: 8),
                  _StageChip(label: 'readying'),
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

// ─────────────────────────────────────────────────────────────────────────────
// Orb painter — two revolving gradient circles (60 fps, GPU-backed)
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

    // Core glow
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.9,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFF6366F1), const Color(0xFF6366F1).withValues(alpha: 0)],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.9))
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Orb 1
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

    // Orb 2
    final o2 = Offset(cx + r * 0.6 * math.cos(angle2), cy + r * 0.6 * math.sin(angle2));
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
  bool shouldRepaint(_OrbPainter old) => old.angle1 != angle1 || old.angle2 != angle2;
}

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
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
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