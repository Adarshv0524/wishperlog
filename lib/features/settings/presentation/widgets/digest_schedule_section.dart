// lib/features/settings/presentation/widgets/digest_schedule_section.dart
//
// Drop-in replacement for the digest-time section in SettingsScreen.
// Supports MINUTE-WISE precision (any HH:MM, not just :00/:15/:30/:45).
// Paste this widget into SettingsScreen and replace the old _addDigestTime
// + _show15MinSlotPicker calls.

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';

/// Fully self-contained digest schedule section widget.
///
/// Usage in SettingsScreen:
/// ```dart
/// DigestScheduleSection(
///   digestTimes: _digestTimes,
///   saving: _savingDigest,
///   onAdd:    _addDigestTime,        // calls _showMinuteWisePicker internally
///   onRemove: _removeDigestTime,
/// )
/// ```
class DigestScheduleSection extends StatelessWidget {
  const DigestScheduleSection({
    super.key,
    required this.digestTimes,
    required this.saving,
    required this.onAdd,
    required this.onRemove,
  });

  final List<TimeOfDay> digestTimes;
  final bool saving;
  final VoidCallback onAdd;
  final void Function(TimeOfDay) onRemove;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Digest Schedule',
                style: TextStyle(
                  color: context.textPri,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (saving) ...[
              SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: context.textSec,
                ),
              ),
              const SizedBox(width: 8),
            ],
            GestureDetector(
              onTap: onAdd,
              child: GlassContainer(
                borderRadius: BorderRadius.circular(20),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.add_rounded, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Add time',
                      style: TextStyle(
                        color: context.textPri,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Choose any time — the worker fires every minute and matches exactly.',
          style: TextStyle(
            color: context.textSec,
            fontSize: 12,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        if (digestTimes.isEmpty)
          Text(
            'No digest times set. Tap "Add time" to schedule your first digest.',
            style: TextStyle(color: context.textSec, fontSize: 13),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final t in digestTimes)
                _DigestTimeChip(
                  time: t,
                  onRemove: () => onRemove(t),
                ),
            ],
          ),
      ],
    );
  }
}

class _DigestTimeChip extends StatelessWidget {
  const _DigestTimeChip({required this.time, required this.onRemove});
  final TimeOfDay time;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final label =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return GlassContainer(
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_rounded, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: context.textPri,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close_rounded, size: 14, color: context.textSec),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Minute-wise time picker
//
// Call this from _SettingsScreenState._addDigestTime() to replace the old
// 15-minute slot picker.
//
// Example:
//   Future<void> _addDigestTime() async {
//     final slot = await showMinuteWiseTimePicker(context, _digestTimes);
//     if (slot == null || !mounted) return;
//     // ... persist as before
//   }
// ─────────────────────────────────────────────────────────────────────────────
Future<TimeOfDay?> showMinuteWiseTimePicker(
  BuildContext context,
  List<TimeOfDay> existing,
) async {
  // Use Flutter's native time picker — it supports minute granularity natively.
  final initialTime = existing.isEmpty
      ? const TimeOfDay(hour: 9, minute: 0)
      : existing.last;

  final picked = await showTimePicker(
    context: context,
    initialTime: initialTime,
    helpText: 'Add digest time',
    cancelText: 'Cancel',
    confirmText: 'Add',
    builder: (ctx, child) => MediaQuery(
      data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
      child: child ?? const SizedBox(),
    ),
  );

  if (picked == null) return null;

  final alreadyExists = existing.any(
    (t) => t.hour == picked.hour && t.minute == picked.minute,
  );
  if (alreadyExists && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This digest time already exists')),
    );
    return null;
  }

  return picked;
}