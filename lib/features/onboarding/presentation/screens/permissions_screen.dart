import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';
import 'package:wishperlog/shared/widgets/glass_page_background.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _continueToApp() async {
    await HapticFeedback.mediumImpact();
    if (!mounted) {
      return;
    }
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor = isDark
        ? Colors.white.withValues(alpha: 0.82)
        : const Color(0xFF374151);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GlassPageBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassContainer(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                borderRadius: BorderRadius.circular(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Finish setup',
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You can start using WhisperLog now. Additional capture tools '
                      'will be added in a later update.',
                      style: TextStyle(
                        color: subtitleColor,
                        fontSize: 14,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final glow = 0.24 + (_pulseController.value * 0.26);
                          final scale = 0.98 + (_pulseController.value * 0.04);
                          return Transform.scale(
                            scale: scale,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (isDark
                                                ? const Color(0xFF96F7FF)
                                                : const Color(0xFF1A6CFF))
                                            .withValues(alpha: glow),
                                    blurRadius: 22,
                                    spreadRadius: 0.5,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: child,
                            ),
                          );
                        },
                        child: GlassContainer(
                          borderRadius: BorderRadius.circular(999),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 14,
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: _continueToApp,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  color: titleColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Continue to Home',
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Center(
                      child: TextButton(
                        onPressed: () => context.go('/home'),
                        child: Text(
                          'Back',
                          style: TextStyle(
                            color: subtitleColor,
                            fontWeight: FontWeight.w600,
                          ),
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
