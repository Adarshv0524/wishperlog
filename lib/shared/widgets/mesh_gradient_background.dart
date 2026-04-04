import 'dart:ui';

import 'package:flutter/material.dart';

class MeshGradientBackground extends StatelessWidget {
  const MeshGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? const [Color(0xFF0A0F1C), Color(0xFF121A2B), Color(0xFF080C16)]
          : const [Color(0xFFF0F4FF), Color(0xFFE8F7FF), Color(0xFFF7F9FF)],
    );

    return DecoratedBox(
      decoration: BoxDecoration(gradient: baseGradient),
      child: Stack(
        children: [
          _orb(
            top: -120,
            left: -90,
            size: 260,
            colors: isDark
                ? const [Color(0xFF4D6FFF), Color(0x004D6FFF)]
                : const [Color(0xFF78A7FF), Color(0x0078A7FF)],
          ),
          _orb(
            top: 160,
            right: -110,
            size: 300,
            colors: isDark
                ? const [Color(0xFF2BD9C6), Color(0x002BD9C6)]
                : const [Color(0xFF61D3C5), Color(0x0061D3C5)],
          ),
          _orb(
            bottom: -120,
            left: 20,
            size: 280,
            colors: isDark
                ? const [Color(0xFFFF6EA8), Color(0x00FF6EA8)]
                : const [Color(0xFFFF9CC5), Color(0x00FF9CC5)],
          ),
          IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: isDark ? 0.03 : 0.18),
                    Colors.transparent,
                    Colors.black.withValues(alpha: isDark ? 0.10 : 0.03),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb({
    double? top,
    double? right,
    double? bottom,
    double? left,
    required double size,
    required List<Color> colors,
  }) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: IgnorePointer(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: colors),
            ),
          ),
        ),
      ),
    );
  }
}
