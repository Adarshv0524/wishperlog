import 'package:flutter/material.dart';

enum OverlayV1Mode { hidden, idle }

@immutable
class OverlayV1State {
  const OverlayV1State({
    required this.mode,
    required this.position,
  });

  final OverlayV1Mode mode;
  final Offset position;

  bool get isVisible => mode == OverlayV1Mode.idle;

  OverlayV1State copyWith({
    OverlayV1Mode? mode,
    Offset? position,
  }) {
    return OverlayV1State(
      mode: mode ?? this.mode,
      position: position ?? this.position,
    );
  }
}
