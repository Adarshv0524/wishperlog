import 'package:flutter/material.dart';
import 'package:wishperlog/shared/widgets/mesh_gradient_background.dart';

class GlassPageBackground extends StatelessWidget {
  const GlassPageBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [const MeshGradientBackground(), child],
    );
  }
}
