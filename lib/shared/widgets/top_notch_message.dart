import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

OverlayEntry? _activeTopNotchEntry;
Timer? _activeTopNotchTimer;

Future<void> showTopNotchSavedMessage({
  required BuildContext context,
  required String title,
  required String categoryLabel,
  String? subtitle,
  Duration duration = const Duration(milliseconds: 2600),
}) {
  final overlayState = Overlay.maybeOf(context);
  if (overlayState == null) {
    return Future<void>.value();
  }

  _activeTopNotchTimer?.cancel();
  _activeTopNotchEntry?.remove();
  _activeTopNotchEntry = null;

  final media = MediaQuery.of(context);
  final size = media.size;

  final minHeight = size.height * 0.05;
  final maxHeight = size.height * 0.2;
  final textColor = Colors.white;
  final secondaryTextColor = Colors.white.withValues(alpha: 0.78);
  final tertiaryTextColor = Colors.white.withValues(alpha: 0.62);
  final icon = _categoryIcon(categoryLabel);

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) {
      return IgnorePointer(
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              tween: Tween<double>(begin: 0, end: 1),
              builder: (context, t, child) {
                return Opacity(
                  opacity: t,
                  child: Transform.translate(
                    offset: Offset(0, (1 - t) * -14),
                    child: Transform.scale(
                      scale: 0.94 + (0.06 * t),
                      child: child,
                    ),
                  ),
                );
              },
              child: Container(
                width: size.width * 0.60,
                constraints: BoxConstraints(
                  minHeight: minHeight,
                  maxHeight: maxHeight,
                ),
                margin: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF0A0B11).withValues(alpha: 0.96),
                            const Color(0xFF171A24).withValues(alpha: 0.94),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.12),
                          width: 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.32),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  const Color(0xFF3A8DFF).withValues(alpha: 0.96),
                                  const Color(0xFF34D399).withValues(alpha: 0.92),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF34D399,
                                  ).withValues(alpha: 0.30),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Icon(icon, size: 17, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: textColor,
                                          fontSize: 13.6,
                                          fontWeight: FontWeight.w700,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: Color(0xFF34D399),
                                      size: 14,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  'Saved as $categoryLabel',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: secondaryTextColor,
                                    fontSize: 12.1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                if (subtitle != null &&
                                    subtitle.trim().isNotEmpty) ...[
                                  const SizedBox(height: 1),
                                  Text(
                                    subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: tertiaryTextColor,
                                      fontSize: 11.2,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.white.withValues(alpha: 0.08),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.12),
                                width: 0.8,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 11,
                                  color: Colors.white.withValues(alpha: 0.84),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Queued',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.84),
                                    fontSize: 10.3,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
  _activeTopNotchTimer = Timer(duration, () {
    _activeTopNotchEntry?.remove();
    _activeTopNotchEntry = null;
    _activeTopNotchTimer = null;
  });

  return Future<void>.value();
}

IconData _categoryIcon(String categoryLabel) {
  final normalized = categoryLabel.toLowerCase();
  if (normalized.contains('task')) return Icons.checklist_rounded;
  if (normalized.contains('reminder')) return Icons.alarm_rounded;
  if (normalized.contains('idea')) return Icons.lightbulb_rounded;
  if (normalized.contains('follow')) return Icons.reply_rounded;
  if (normalized.contains('journal')) return Icons.menu_book_rounded;
  return Icons.note_rounded;
}
