// lib/features/overlay/overlay_settings_model.dart
//
// Serialisable settings model for the native + Flutter overlay.
// Persisted to SharedPreferences as JSON.

import 'dart:convert';
import 'dart:ui';

enum OverlayColorFill { solid, linearGradient, radialGradient, glass }

enum OverlayBorderStyle { none, hairline, glow }

enum OverlayAnimation { none, sizeGrow, pulseGlow, bounceIn }

class OverlaySettings {
  const OverlaySettings({
    this.alpha = 0.82,
    this.blurSigma = 22.0,
    this.colorFill = OverlayColorFill.glass,
    this.solidColor = const Color(0xFF1C1C2E),
    this.gradientStart = const Color(0xFF6366F1),
    this.gradientEnd = const Color(0xFF8B5CF6),
    this.borderStyle = OverlayBorderStyle.glow,
    this.borderColor = const Color(0xFF6366F1),
    this.animation = OverlayAnimation.sizeGrow,
    this.growScale = 1.10,
    this.positionFraction = const Offset(0.88, 0.30),
    this.persistOnReboot = true,
  });

  final double alpha;           // 0.3–1.0
  final double blurSigma;       // 0–40
  final OverlayColorFill colorFill;
  final Color solidColor;
  final Color gradientStart;
  final Color gradientEnd;
  final OverlayBorderStyle borderStyle;
  final Color borderColor;
  final OverlayAnimation animation;
  final double growScale;       // 1.0–1.25
  final Offset positionFraction; // dx/dy as fraction of screen size
  final bool persistOnReboot;

  OverlaySettings copyWith({
    double? alpha,
    double? blurSigma,
    OverlayColorFill? colorFill,
    Color? solidColor,
    Color? gradientStart,
    Color? gradientEnd,
    OverlayBorderStyle? borderStyle,
    Color? borderColor,
    OverlayAnimation? animation,
    double? growScale,
    Offset? positionFraction,
    bool? persistOnReboot,
  }) => OverlaySettings(
    alpha: alpha ?? this.alpha,
    blurSigma: blurSigma ?? this.blurSigma,
    colorFill: colorFill ?? this.colorFill,
    solidColor: solidColor ?? this.solidColor,
    gradientStart: gradientStart ?? this.gradientStart,
    gradientEnd: gradientEnd ?? this.gradientEnd,
    borderStyle: borderStyle ?? this.borderStyle,
    borderColor: borderColor ?? this.borderColor,
    animation: animation ?? this.animation,
    growScale: growScale ?? this.growScale,
    positionFraction: positionFraction ?? this.positionFraction,
    persistOnReboot: persistOnReboot ?? this.persistOnReboot,
  );

  Map<String, dynamic> toJson() => {
    'alpha': alpha,
    'blurSigma': blurSigma,
    'colorFill': colorFill.name,
    'solidColor': solidColor.toARGB32(),
    'gradientStart': gradientStart.toARGB32(),
    'gradientEnd': gradientEnd.toARGB32(),
    'borderStyle': borderStyle.name,
    'borderColor': borderColor.toARGB32(),
    'animation': animation.name,
    'growScale': growScale,
    'posX': positionFraction.dx,
    'posY': positionFraction.dy,
    'persistOnReboot': persistOnReboot,
  };

  factory OverlaySettings.fromJson(Map<String, dynamic> j) => OverlaySettings(
    alpha: (j['alpha'] as num?)?.toDouble() ?? 0.82,
    blurSigma: (j['blurSigma'] as num?)?.toDouble() ?? 22.0,
    colorFill: _parseEnum(OverlayColorFill.values, j['colorFill']) ?? OverlayColorFill.glass,
    solidColor: _parseColor(j['solidColor']) ?? const Color(0xFF1C1C2E),
    gradientStart: _parseColor(j['gradientStart']) ?? const Color(0xFF6366F1),
    gradientEnd: _parseColor(j['gradientEnd']) ?? const Color(0xFF8B5CF6),
    borderStyle: _parseEnum(OverlayBorderStyle.values, j['borderStyle']) ?? OverlayBorderStyle.glow,
    borderColor: _parseColor(j['borderColor']) ?? const Color(0xFF6366F1),
    animation: _parseEnum(OverlayAnimation.values, j['animation']) ?? OverlayAnimation.sizeGrow,
    growScale: (j['growScale'] as num?)?.toDouble() ?? 1.10,
    positionFraction: Offset(
      (j['posX'] as num?)?.toDouble() ?? 0.88,
      (j['posY'] as num?)?.toDouble() ?? 0.30,
    ),
    persistOnReboot: j['persistOnReboot'] as bool? ?? true,
  );

  factory OverlaySettings.fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return const OverlaySettings();
    try {
      return OverlaySettings.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return const OverlaySettings();
    }
  }

  String toJsonString() => jsonEncode(toJson());

  static T? _parseEnum<T extends Enum>(List<T> values, dynamic name) {
    if (name is! String) return null;
    try {
      return values.firstWhere((e) => e.name == name);
    } catch (_) {
      return null;
    }
  }

  static Color? _parseColor(dynamic raw) {
    if (raw is! int) return null;
    return Color(raw);
  }
}