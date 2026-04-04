import 'dart:ui';

import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? Colors.white : Colors.black;

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  base.withValues(alpha: isDark ? 0.12 : 0.08),
                  base.withValues(alpha: isDark ? 0.07 : 0.04),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: isDark ? 0.20 : 0.45),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: shadowOpacity),
                  blurRadius: 22,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
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
    final base = isDark ? Colors.white : Colors.black;
    final normalizedOpacity = opacity.clamp(0.2, 1.0);

    final idleGradient = [
      base.withValues(alpha: isDark ? 0.18 : 0.10),
      base.withValues(alpha: isDark ? 0.10 : 0.06),
    ];

    return Opacity(
      opacity: normalizedOpacity,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isActive
                    ? const [Color(0xFF4C6FFF), Color(0xFF7B4BFF)]
                    : idleGradient,
              ),
              border: Border.all(
                color: isActive
                    ? const Color(0xFFD6DDFF)
                    : isError
                    ? const Color(0xFFFFCFCF)
                    : Colors.white.withValues(alpha: isDark ? 0.72 : 0.86),
                width: isActive ? 2.0 : 1.3,
              ),
              boxShadow: [
                BoxShadow(
                  color: isActive
                      ? const Color(0xAA5F77FF)
                      : Colors.black.withValues(alpha: 0.22),
                  blurRadius: isActive ? 24 : 16,
                  spreadRadius: isActive ? 3 : 0,
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
