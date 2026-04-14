// lib/features/overlay/overlay_customisation_sheet.dart
//
// Real-time overlay customiser — every control immediately previews the bubble
// and island appearance in a live mock widget above the controls.
// No "Apply" button needed; changes are debounced and pushed to native after
// 300 ms of idle time using OverlayNotifier.saveOverlaySettings().

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/overlay/overlay_settings_model.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

/// Shows the overlay customisation bottom sheet.
void showOverlayCustomisationSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _OverlayCustomisationSheet(),
  );
}

class _OverlayCustomisationSheet extends StatefulWidget {
  const _OverlayCustomisationSheet();

  @override
  State<_OverlayCustomisationSheet> createState() =>
      _OverlayCustomisationSheetState();
}

class _OverlayCustomisationSheetState
    extends State<_OverlayCustomisationSheet> {
  late OverlaySettings _draft;
  Timer? _applyDebounce;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft = sl<OverlayNotifier>().overlaySettings;
  }

  @override
  void dispose() {
    _applyDebounce?.cancel();
    super.dispose();
  }

  void _update(OverlaySettings next) {
    setState(() => _draft = next);
    _applyDebounce?.cancel();
    _applyDebounce = Timer(const Duration(milliseconds: 300), _apply);
  }

  Future<void> _apply() async {
    if (!mounted) return;
    setState(() => _saving = true);
    try {
      await sl<OverlayNotifier>().saveOverlaySettings(_draft);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      minChildSize: 0.40,
      builder: (ctx, scrollCtrl) => GlassPane(
        level: 1,
        radius: 28,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // ── Drag handle ──────────────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: context.textSec.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            // ── Title ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Row(
                children: [
                  Text(
                    'Overlay Style',
                    style: TextStyle(
                      color: context.textPri,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const Spacer(),
                  if (_saving)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Live preview ─────────────────────────────────────────────────
            _LivePreview(settings: _draft),
            const SizedBox(height: 14),
            // ── Controls ─────────────────────────────────────────────────────
            Expanded(
              child: ListView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                children: [
                  _SectionLabel('Opacity'),
                  Slider(
                    value: _draft.alpha,
                    min: 0.30,
                    max: 1.0,
                    divisions: 14,
                    label: '${(_draft.alpha * 100).round()}%',
                    activeColor: AppColors.tasks,
                    onChanged: (v) => _update(_draft.copyWith(alpha: v)),
                  ),
                  _SectionLabel('Fill Style'),
                  _SegmentRow<OverlayColorFill>(
                    values: OverlayColorFill.values,
                    selected: _draft.colorFill,
                    label: (v) => v.name,
                    onChanged: (v) => _update(_draft.copyWith(colorFill: v)),
                  ),
                  if (_draft.colorFill == OverlayColorFill.solid) ...[
                    _SectionLabel('Solid colour'),
                    _ColorRow(
                      color: _draft.solidColor,
                      onChanged: (c) => _update(_draft.copyWith(solidColor: c)),
                    ),
                  ],
                  if (_draft.colorFill == OverlayColorFill.linearGradient ||
                      _draft.colorFill == OverlayColorFill.radialGradient) ...[
                    _SectionLabel('Gradient start'),
                    _ColorRow(
                      color: _draft.gradientStart,
                      onChanged: (c) =>
                          _update(_draft.copyWith(gradientStart: c)),
                    ),
                    _SectionLabel('Gradient end'),
                    _ColorRow(
                      color: _draft.gradientEnd,
                      onChanged: (c) =>
                          _update(_draft.copyWith(gradientEnd: c)),
                    ),
                  ],
                  _SectionLabel('Border'),
                  _SegmentRow<OverlayBorderStyle>(
                    values: OverlayBorderStyle.values,
                    selected: _draft.borderStyle,
                    label: (v) => v.name,
                    onChanged: (v) => _update(_draft.copyWith(borderStyle: v)),
                  ),
                  _SectionLabel('Animation'),
                  _SegmentRow<OverlayAnimation>(
                    values: OverlayAnimation.values,
                    selected: _draft.animation,
                    label: (v) => v.name,
                    onChanged: (v) => _update(_draft.copyWith(animation: v)),
                  ),
                  if (_draft.animation == OverlayAnimation.sizeGrow) ...[
                    _SectionLabel('Grow scale  '
                        '${_draft.growScale.toStringAsFixed(2)}×'),
                    Slider(
                      value: _draft.growScale,
                      min: 1.0,
                      max: 1.25,
                      divisions: 10,
                      activeColor: AppColors.tasks,
                      onChanged: (v) =>
                          _update(_draft.copyWith(growScale: v)),
                    ),
                  ],
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Restore overlay on reboot',
                      style: TextStyle(
                        color: context.textPri,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    value: _draft.persistOnReboot,
                    activeThumbColor: AppColors.tasks,
                    onChanged: (v) =>
                        _update(_draft.copyWith(persistOnReboot: v)),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => _update(const OverlaySettings()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.reminders,
                      side: BorderSide(
                        color: AppColors.reminders.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Text('Reset to defaults'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Live preview widget ───────────────────────────────────────────────────────
class _LivePreview extends StatelessWidget {
  const _LivePreview({required this.settings});

  final OverlaySettings settings;

  @override
  Widget build(BuildContext context) {
    return GlassPane(
      level: 2,
      radius: 20,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              _MockBubble(settings: settings),
              const SizedBox(height: 6),
              Text(
                'Bubble',
                style: TextStyle(
                  color: context.textSec,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Column(
            children: [
              _MockIsland(settings: settings),
              const SizedBox(height: 6),
              Text(
                'Island',
                style: TextStyle(
                  color: context.textSec,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MockBubble extends StatelessWidget {
  const _MockBubble({required this.settings});
  final OverlaySettings settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _resolveGradient(settings),
        color: _resolveGradient(settings) == null
            ? settings.solidColor.withValues(alpha: settings.alpha)
            : null,
        border: _resolveBorder(settings),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.mic_rounded, color: Colors.white, size: 22),
    );
  }
}

class _MockIsland extends StatelessWidget {
  const _MockIsland({required this.settings});
  final OverlaySettings settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _resolveGradient(settings),
        color: _resolveGradient(settings) == null
            ? settings.solidColor.withValues(alpha: settings.alpha)
            : null,
        border: _resolveBorder(settings),
      ),
      child: const Center(
        child: Text(
          'Saved · Tasks',
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

LinearGradient? _resolveGradient(OverlaySettings s) {
  switch (s.colorFill) {
    case OverlayColorFill.linearGradient:
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          s.gradientStart.withValues(alpha: s.alpha),
          s.gradientEnd.withValues(alpha: s.alpha),
        ],
      );
    case OverlayColorFill.radialGradient:
      return LinearGradient(
        begin: Alignment.center,
        end: Alignment.bottomRight,
        colors: [
          s.gradientStart.withValues(alpha: s.alpha),
          s.gradientEnd.withValues(alpha: s.alpha),
        ],
      );
    case OverlayColorFill.glass:
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: s.alpha * 0.22),
          Colors.white.withValues(alpha: s.alpha * 0.06),
        ],
      );
    case OverlayColorFill.solid:
      return null;
  }
}

Border? _resolveBorder(OverlaySettings s) {
  switch (s.borderStyle) {
    case OverlayBorderStyle.none:
      return null;
    case OverlayBorderStyle.hairline:
      return Border.all(
        color: s.borderColor.withValues(alpha: 0.5),
        width: 0.8,
      );
    case OverlayBorderStyle.glow:
      return Border.all(
        color: s.borderColor.withValues(alpha: 0.88),
        width: 1.4,
      );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4),
        child: Text(
          text,
          style: TextStyle(
            color: context.textSec,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.7,
          ),
        ),
      );
}

class _SegmentRow<T> extends StatelessWidget {
  const _SegmentRow({
    required this.values,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: values.map((v) {
        final active = v == selected;
        return GestureDetector(
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: active
                  ? AppColors.tasks.withValues(alpha: 0.18)
                  : context.surface1.withValues(alpha: 0.56),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: active
                    ? AppColors.tasks.withValues(alpha: 0.72)
                    : context.textSec.withValues(alpha: 0.10),
              ),
            ),
            child: Text(
              label(v),
              style: TextStyle(
                color: active ? AppColors.tasks : context.textSec,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ColorRow extends StatelessWidget {
  const _ColorRow({required this.color, required this.onChanged});
  final Color color;
  final ValueChanged<Color> onChanged;

  static const _palette = [
    Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFF06B6D4),
    Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFEF4444),
    Color(0xFFEC4899), Color(0xFF1C1C2E), Color(0xFFFFFFFF),
  ];

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _palette.map((c) {
          final selected = c.toARGB32() == color.toARGB32();
          return GestureDetector(
            onTap: () => onChanged(c),
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: c,
                border: Border.all(
                  color: selected ? AppColors.tasks : Colors.transparent,
                  width: 2.5,
                ),
              ),
            ),
          );
        }).toList(),
      );
}