import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/models/enums.dart';

class MeshGradientBackground extends StatefulWidget {
  const MeshGradientBackground({super.key, this.category});

  final NoteCategory? category;

  @override
  State<MeshGradientBackground> createState() => _MeshGradientBackgroundState();
}

class _MeshGradientBackgroundState extends State<MeshGradientBackground>
    with SingleTickerProviderStateMixin {
  static const _periods = <double>[38, 43, 47, 41, 52];
  static const _phaseX = <double>[0.25, 1.1, 2.2, 3.8, 4.7];
  static const _phaseY = <double>[1.6, 2.4, 0.7, 4.2, 5.3];

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nodes = [...context.meshNodes];
    final leakTarget = widget.category == null
        ? null
        : Color.lerp(
            nodes.first,
            categoryFolderBg(widget.category!, context.isDark),
            0.60,
          );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 60.0;
        return RepaintBoundary(
          child: AnimatedContainer(
            duration: AppDurations.modeTransition,
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [leakTarget ?? nodes[0], nodes[1], nodes[2]],
              ),
            ),
            child: CustomPaint(
              painter: _MeshBlobPainter(
                timeSeconds: t,
                opacity: context.isDark ? 0.55 : 0.40,
                colors: [leakTarget ?? nodes[0], ...nodes.skip(1).take(4)],
                periods: _periods,
                phaseX: _phaseX,
                phaseY: _phaseY,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        );
      },
    );
  }
}

class _MeshBlobPainter extends CustomPainter {
  const _MeshBlobPainter({
    required this.timeSeconds,
    required this.opacity,
    required this.colors,
    required this.periods,
    required this.phaseX,
    required this.phaseY,
  });

  final double timeSeconds;
  final double opacity;
  final List<Color> colors;
  final List<double> periods;
  final List<double> phaseX;
  final List<double> phaseY;

  static const _bases = <Offset>[
    Offset(0.12, 0.18),
    Offset(0.86, 0.28),
    Offset(0.20, 0.84),
    Offset(0.76, 0.78),
    Offset(0.48, 0.30),
  ];

  static const _radii = <double>[190, 220, 230, 210, 180];

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < 5; i++) {
      final wx = _wave(timeSeconds, periods[i], phaseX[i], 18);
      final wy = _wave(timeSeconds, periods[i], phaseY[i], 22);
      final center = Offset(
        (_bases[i].dx * size.width) + wx,
        (_bases[i].dy * size.height) + wy,
      );

      final shader = RadialGradient(
        colors: [
          colors[i].withValues(alpha: opacity),
          colors[i].withValues(alpha: 0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: _radii[i]));

      canvas.drawCircle(
        center,
        _radii[i],
        Paint()
          ..shader = shader
          ..isAntiAlias = true,
      );
    }
  }

  double _wave(double t, double period, double phase, double amp) {
    return math.sin(((2 * math.pi) * t / period) + phase) * amp;
  }

  @override
  bool shouldRepaint(covariant _MeshBlobPainter oldDelegate) {
    return oldDelegate.timeSeconds != timeSeconds ||
        oldDelegate.opacity != opacity ||
        oldDelegate.colors != colors;
  }
}
