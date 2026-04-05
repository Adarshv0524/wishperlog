import 'package:flutter/material.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/widgets/mesh_gradient_background.dart';

class GlassPageBackground extends StatelessWidget {
  const GlassPageBackground({required this.child, super.key, this.category});

  final Widget child;
  final NoteCategory? category;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MeshGradientBackground(category: category),
        child,
      ],
    );
  }
}
