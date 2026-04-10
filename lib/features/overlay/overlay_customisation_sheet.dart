// lib/features/overlay/overlay_customisation_sheet.dart
//
// "God-Level" overlay customisation bottom-sheet.
// Shows live preview + every setting from OverlaySettings.

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/overlay/overlay_settings_model.dart';

/// Call via:
///   showOverlayCustomisationSheet(context, initial, onSave);
Future<void> showOverlayCustomisationSheet(
  BuildContext context,
  OverlaySettings initial,
  Future<void> Function(OverlaySettings) onSave,
) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _OverlayCustomisationSheet(
      initial: initial,
      onSave: onSave,
    ),
  );
}

class _OverlayCustomisationSheet extends StatefulWidget {
  const _OverlayCustomisationSheet({
    required this.initial,
    required this.onSave,
  });

  final OverlaySettings initial;
  final Future<void> Function(OverlaySettings) onSave;

  @override
  State<_OverlayCustomisationSheet> createState() =>
      _OverlayCustomisationSheetState();
}

class _OverlayCustomisationSheetState
    extends State<_OverlayCustomisationSheet> {
  late OverlaySettings _s;
  bool _saving = false;
  bool _growPreview = false;

  @override
  void initState() {
    super.initState();
    _s = widget.initial;
  }

  // ── Live preview ──────────────────────────────────────────────────────────

  Widget _buildPreview() {
    final hasGlow = _s.borderStyle == OverlayBorderStyle.glow;
    final gradient = _s.colorFill == OverlayColorFill.linearGradient
        ? LinearGradient(
            colors: [_s.gradientStart, _s.gradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : _s.colorFill == OverlayColorFill.radialGradient
            ? RadialGradient(
                colors: [_s.gradientStart, _s.gradientEnd],
              )
            : null;

    final baseDecoration = BoxDecoration(
      color: _s.colorFill == OverlayColorFill.solid ? _s.solidColor.withValues(alpha: _s.alpha) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(24),
      border: _s.borderStyle != OverlayBorderStyle.none
          ? Border.all(
              color: _s.borderColor.withValues(
                alpha: _s.borderStyle == OverlayBorderStyle.hairline ? 0.5 : 1.0,
              ),
              width: _s.borderStyle == OverlayBorderStyle.hairline ? 0.6 : 1.4,
            )
          : null,
      boxShadow: hasGlow
          ? [
              BoxShadow(
                color: _s.borderColor.withValues(alpha: 0.55),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ]
          : null,
    );

    Widget pill = AnimatedScale(
      scale: _growPreview && _s.animation == OverlayAnimation.sizeGrow
          ? _s.growScale
          : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _growPreview = true),
        onTapUp: (_) => setState(() => _growPreview = false),
        onTapCancel: () => setState(() => _growPreview = false),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: _s.colorFill == OverlayColorFill.glass ? _s.blurSigma : 0,
              sigmaY: _s.colorFill == OverlayColorFill.glass ? _s.blurSigma : 0,
            ),
            child: Container(
              width: 160,
              height: 52,
              decoration: _s.colorFill == OverlayColorFill.glass
                  ? baseDecoration.copyWith(
                      color: Colors.white.withValues(alpha: _s.alpha * 0.12),
                      border: baseDecoration.border,
                      boxShadow: baseDecoration.boxShadow,
                    )
                  : baseDecoration,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mic_rounded, color: Colors.white.withValues(alpha: 0.9), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Hold to Record',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return Center(child: pill);
  }

  // ── Section label ─────────────────────────────────────────────────────────

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 8),
    child: Text(
      text,
      style: TextStyle(
        color: context.textSec,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    ),
  );

  // ── Segmented button helper ───────────────────────────────────────────────

  Widget _segmented<T>({
    required List<T> values,
    required T current,
    required String Function(T) label,
    required void Function(T) onSelect,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((v) {
        final selected = v == current;
        return GestureDetector(
          onTap: () => setState(() => onSelect(v)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.tasks
                  : context.surface1.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: selected
                    ? AppColors.tasks
                    : context.textSec.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              label(v),
              style: TextStyle(
                color: selected ? Colors.white : context.textSec,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Color row ─────────────────────────────────────────────────────────────

  static const _palette = [
    Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899),
    Color(0xFF22D3EE), Color(0xFF10B981), Color(0xFFF59E0B),
    Color(0xFFEF4444), Color(0xFF1C1C2E), Color(0xFFFFFFFF),
  ];

  Widget _colorRow(Color current, void Function(Color) onSelect) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _palette.map((c) {
        final sel = current.toARGB32() == c.toARGB32();
        return GestureDetector(
          onTap: () => setState(() => onSelect(c)),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            width: 30, height: 30,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                color: sel ? Colors.white : Colors.transparent,
                width: 2.5,
              ),
              boxShadow: sel
                  ? [BoxShadow(color: c.withValues(alpha: 0.6), blurRadius: 10)]
                  : null,
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.96,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
            child: Container(
              decoration: BoxDecoration(
                color: context.isDark
                    ? const Color(0xF2111827)
                    : const Color(0xF2F9FAFB),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Handle bar
                  const SizedBox(height: 10),
                  Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: context.textSec.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Title row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Overlay Customiser',
                            style: TextStyle(
                              color: context.textPri,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: _saving
                              ? null
                              : () async {
                                  setState(() => _saving = true);
                                  try {
                                    await widget.onSave(_s);
                                    if (ctx.mounted) Navigator.of(ctx).pop();
                                  } finally {
                                    if (mounted) setState(() => _saving = false);
                                  }
                                },
                          child: _saving
                              ? const SizedBox(
                                  width: 16, height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(
                                  'Save',
                                  style: TextStyle(
                                    color: AppColors.tasks,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Scrollable content
                  Expanded(
                    child: ListView(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                      children: [
                        // ── Preview ───────────────────────────────────────
                        _label('LIVE PREVIEW — TAP TO TEST ANIMATION'),
                        Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: context.surface1.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: context.textSec.withValues(alpha: 0.1)),
                          ),
                          child: _buildPreview(),
                        ),

                        // ── Transparency ─────────────────────────────────
                        _label('TRANSPARENCY'),
                        Row(
                          children: [
                            Text('${(_s.alpha * 100).round()}%',
                                style: TextStyle(color: context.textSec, fontSize: 12)),
                            Expanded(
                              child: Slider(
                                value: _s.alpha,
                                min: 0.2, max: 1.0, divisions: 32,
                                activeColor: AppColors.tasks,
                                onChanged: (v) => setState(() => _s = _s.copyWith(alpha: v)),
                              ),
                            ),
                          ],
                        ),

                        // ── Glassmorphism Blur ────────────────────────────
                        _label('GLASSMORPHISM BLUR'),
                        Row(
                          children: [
                            Text('σ${_s.blurSigma.round()}',
                                style: TextStyle(color: context.textSec, fontSize: 12)),
                            Expanded(
                              child: Slider(
                                value: _s.blurSigma,
                                min: 0, max: 40, divisions: 40,
                                activeColor: AppColors.tasks,
                                onChanged: (v) => setState(() => _s = _s.copyWith(blurSigma: v)),
                              ),
                            ),
                          ],
                        ),

                        // ── Fill Style ───────────────────────────────────
                        _label('FILL STYLE'),
                        _segmented<OverlayColorFill>(
                          values: OverlayColorFill.values,
                          current: _s.colorFill,
                          label: (v) => switch (v) {
                            OverlayColorFill.glass => 'Glass',
                            OverlayColorFill.solid => 'Solid',
                            OverlayColorFill.linearGradient => 'Linear',
                            OverlayColorFill.radialGradient => 'Radial',
                          },
                          onSelect: (v) => _s = _s.copyWith(colorFill: v),
                        ),

                        // ── Solid color ───────────────────────────────────
                        if (_s.colorFill == OverlayColorFill.solid) ...[
                          _label('FILL COLOUR'),
                          _colorRow(_s.solidColor, (c) => _s = _s.copyWith(solidColor: c)),
                        ],

                        // ── Gradient colours ──────────────────────────────
                        if (_s.colorFill == OverlayColorFill.linearGradient ||
                            _s.colorFill == OverlayColorFill.radialGradient) ...[
                          _label('GRADIENT START'),
                          _colorRow(_s.gradientStart, (c) => _s = _s.copyWith(gradientStart: c)),
                          _label('GRADIENT END'),
                          _colorRow(_s.gradientEnd, (c) => _s = _s.copyWith(gradientEnd: c)),
                        ],

                        // ── Border Style ──────────────────────────────────
                        _label('BORDER STYLE'),
                        _segmented<OverlayBorderStyle>(
                          values: OverlayBorderStyle.values,
                          current: _s.borderStyle,
                          label: (v) => switch (v) {
                            OverlayBorderStyle.none => 'None',
                            OverlayBorderStyle.hairline => 'Hairline',
                            OverlayBorderStyle.glow => 'Glow',
                          },
                          onSelect: (v) => _s = _s.copyWith(borderStyle: v),
                        ),
                        if (_s.borderStyle != OverlayBorderStyle.none) ...[
                          _label('BORDER / GLOW COLOUR'),
                          _colorRow(_s.borderColor, (c) => _s = _s.copyWith(borderColor: c)),
                        ],

                        // ── Animation ─────────────────────────────────────
                        _label('TOUCH ANIMATION'),
                        _segmented<OverlayAnimation>(
                          values: OverlayAnimation.values,
                          current: _s.animation,
                          label: (v) => switch (v) {
                            OverlayAnimation.none => 'None',
                            OverlayAnimation.sizeGrow => 'Size Grow',
                            OverlayAnimation.pulseGlow => 'Pulse Glow',
                            OverlayAnimation.bounceIn => 'Bounce In',
                          },
                          onSelect: (v) => _s = _s.copyWith(animation: v),
                        ),
                        if (_s.animation == OverlayAnimation.sizeGrow) ...[
                          _label('GROW SCALE'),
                          Row(
                            children: [
                              Text('${(_s.growScale * 100).round()}%',
                                  style: TextStyle(color: context.textSec, fontSize: 12)),
                              Expanded(
                                child: Slider(
                                  value: _s.growScale,
                                  min: 1.0, max: 1.30, divisions: 15,
                                  activeColor: AppColors.tasks,
                                  onChanged: (v) => setState(() => _s = _s.copyWith(growScale: v)),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // ── Persistence ───────────────────────────────────
                        _label('PERSISTENCE'),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            'Show after device reboot',
                            style: TextStyle(color: context.textPri, fontSize: 14),
                          ),
                          value: _s.persistOnReboot,
                          activeThumbColor: AppColors.tasks,
                          onChanged: (v) => setState(() => _s = _s.copyWith(persistOnReboot: v)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}