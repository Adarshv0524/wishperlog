import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

OverlayEntry? _activeTopNotchEntry;
Timer? _activeTopNotchTimer;

Future<void> showTopNotchSavedMessage({
  required BuildContext context,
  required String title,
  required NoteCategory category,
}) {
  final overlayState = Overlay.maybeOf(context);
  if (overlayState == null) {
    return Future<void>.value();
  }

  _activeTopNotchTimer?.cancel();
  _activeTopNotchEntry?.remove();
  _activeTopNotchEntry = null;

  final chipColor = categoryColor(category);
  final textColor = context.textPri;

  final entry = OverlayEntry(
    builder: (_) {
      return IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: AppDurations.saveConfirm,
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * -28),
                    child: child,
                  ),
                );
              },
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 32,
                ),
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: context.glass1,
                  border: Border.all(color: context.border, width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Saved',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '·',
                      style: TextStyle(color: context.textSec, fontSize: 12),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: chipColor.withValues(alpha: 0.18),
                      ),
                      child: Text(
                        categoryLabel(category),
                        style: TextStyle(
                          color: chipColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: context.textSec,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

  overlayState.insert(entry);
  _activeTopNotchEntry = entry;
  _activeTopNotchTimer = Timer(AppDurations.notchAutoReturn, () {
    _activeTopNotchEntry?.remove();
    _activeTopNotchEntry = null;
    _activeTopNotchTimer = null;
  });

  return Future<void>.value();
}
