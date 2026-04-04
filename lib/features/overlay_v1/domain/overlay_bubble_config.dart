import 'package:flutter/foundation.dart';

@immutable
class OverlayBubbleConfig {
  const OverlayBubbleConfig({
    required this.opacity,
    required this.size,
    required this.snapEnabled,
  });

  static const OverlayBubbleConfig defaults = OverlayBubbleConfig(
    opacity: 0.4,
    size: 56,
    snapEnabled: true,
  );

  final double opacity;
  final double size;
  final bool snapEnabled;

  OverlayBubbleConfig copyWith({
    double? opacity,
    double? size,
    bool? snapEnabled,
  }) {
    return OverlayBubbleConfig(
      opacity: opacity ?? this.opacity,
      size: size ?? this.size,
      snapEnabled: snapEnabled ?? this.snapEnabled,
    );
  }
}