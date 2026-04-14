import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';

class ThoughtCanvas extends StatelessWidget {
  const ThoughtCanvas({
    required this.controller,
    required this.focusNode,
    required this.onSave,
    required this.onSubmit,
    required this.onTagTap,
    required this.onReminderTap,
    required this.onReminderLongPress,
    required this.onMicPressStart,
    required this.onMicPressEnd,
    required this.isSaving,
    required this.isRecording,
    this.tagActive = false,
    this.reminderActive = false,
    this.tagLabel,
    this.reminderLabel,
    this.languageCode = 'en-US',
    this.onLanguageSelect,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSave;
  final VoidCallback onSubmit;
  final VoidCallback onTagTap;
  final VoidCallback onReminderTap;
  final VoidCallback onReminderLongPress;
  final VoidCallback onMicPressStart;
  final VoidCallback onMicPressEnd;
  final bool isSaving;
  final bool isRecording;
  final bool tagActive;
  final bool reminderActive;
  final String? tagLabel;
  final String? reminderLabel;
  final String languageCode;
  final VoidCallback? onLanguageSelect;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF102538) : const Color(0xFFF4F7FB);
    final surfaceTop = isDark ? const Color(0xFF17364C) : const Color(0xFFFFFFFF);
    final surfaceBottom = isDark ? const Color(0xFF0A1825) : const Color(0xFFDDE7F0);
    final highlight = isDark ? const Color(0x26FFFFFF) : const Color(0xCCFFFFFF);
    final shadowDark = isDark ? const Color(0xC4121B27) : const Color(0x2B7890A8);
    final shadowSoft = isDark ? const Color(0x73131D29) : const Color(0x22A8BDD2);
    final rim = isDark ? const Color(0x3C8BB5DA) : const Color(0x92D7E5F1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 6),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(36),
          boxShadow: [
            BoxShadow(
              color: isDark ? shadowDark : const Color(0x44FFFFFF),
              blurRadius: 26,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: isDark ? const Color(0x55000000) : shadowSoft,
              blurRadius: 30,
              spreadRadius: -2,
              offset: const Offset(12, 14),
            ),
            BoxShadow(
              color: isDark ? const Color(0x4415222F) : const Color(0xB7FFFFFF),
              blurRadius: 20,
              spreadRadius: -4,
              offset: const Offset(-8, -8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    surfaceTop,
                    surface,
                    surfaceBottom,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
                borderRadius: BorderRadius.circular(36),
                border: Border.all(color: rim, width: 0.8),
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(36),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      highlight.withValues(alpha: isDark ? 0.10 : 0.35),
                      Colors.transparent,
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
            children: [
              Container(
                height: 1.2,
                margin: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.transparent,
                      highlight.withValues(alpha: isDark ? 0.28 : 0.78),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              // ── Text field ──────────────────────────────────────────────
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  onSubmitted: (_) {
                    if (controller.text.trim().isNotEmpty && !isSaving) {
                      onSubmit();
                    }
                  },
                  style: TextStyle(
                    color: context.textPri,
                    fontSize: 15.5,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    filled: false,
                    hintText: isRecording
                        ? 'Listening...'
                        : 'Type a note, task, or reminder',
                    hintStyle: TextStyle(
                      color: context.textSec.withValues(alpha: 0.64),
                      fontSize: 15.2,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                  ),
                ),
              ),
              // ── Action bar ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDark ? const Color(0x2A8FB2D2) : const Color(0x6AB9CBE0),
                      width: 0.8,
                    ),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      isDark ? const Color(0x0F16232E) : const Color(0x74FFFFFF),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Tag
                        _BarBtn(
                          icon: Icons.hexagon_outlined,
                          color: tagActive ? AppColors.tasks : context.textSec,
                          active: tagActive,
                          onTap: onTagTap,
                        ),
                        const SizedBox(width: 4),
                        // Reminder
                        _BarBtn(
                          icon: Icons.alarm_add_rounded,
                          color: reminderActive ? AppColors.tasks : context.textSec,
                          active: reminderActive,
                          onTap: onReminderTap,
                          onLongPress: onReminderLongPress,
                        ),
                        const Spacer(),
                        // Language selector (tap to cycle: en-US / hi-IN / te-IN)
                        if (onLanguageSelect != null)
                          _BarBtn(
                            icon: Icons.language_rounded,
                            color: languageCode != 'en-US'
                                ? AppColors.tasks
                                : context.textSec,
                            active: languageCode != 'en-US',
                            onTap: () => onLanguageSelect?.call(),
                          ),
                        const SizedBox(width: 4),
                        // Mic (long-press to dictate)
                        GestureDetector(
                          onLongPressStart: (_) => onMicPressStart(),
                          onLongPressEnd: (_) => onMicPressEnd(),
                          child: AnimatedContainer(
                            duration: AppDurations.microSnap,
                            width: isRecording ? 46 : 42,
                            height: isRecording ? 46 : 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isRecording
                                    ? [
                                        AppColors.tasks.withValues(alpha: 0.98),
                                        AppColors.tasks.withValues(alpha: 0.78),
                                      ]
                                    : [
                                        isDark ? const Color(0xFF20384D) : const Color(0xFFF9FCFF),
                                        isDark ? const Color(0xFF112132) : const Color(0xFFD9E6F1),
                                      ],
                              ),
                              border: Border.all(
                                color: isRecording
                                    ? AppColors.tasks.withValues(alpha: 0.9)
                                    : (isDark ? const Color(0x448FB1D5) : const Color(0x8CC2D5E7)),
                                width: isRecording ? 1.2 : 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.30)
                                      : const Color(0x3391A8BB),
                                  blurRadius: 10,
                                  offset: const Offset(3, 4),
                                ),
                                BoxShadow(
                                  color: isDark
                                      ? const Color(0x24FFFFFF)
                                      : Colors.white.withValues(alpha: 0.84),
                                  blurRadius: 10,
                                  offset: const Offset(-3, -3),
                                ),
                              ],
                            ),
                            child: Icon(
                              isRecording
                                  ? Icons.graphic_eq_rounded
                                  : Icons.mic_none_rounded,
                              size: 19,
                              color: isRecording ? Colors.white : context.textSec,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Send
                        AnimatedSwitcher(
                          duration: AppDurations.microSnap,
                          child: controller.text.trim().isEmpty
                              ? const SizedBox(width: 42, height: 42)
                              : GestureDetector(
                                  key: const ValueKey('send'),
                                  onTap: isSaving ? null : onSave,
                                  child: AnimatedContainer(
                                    duration: AppDurations.microSnap,
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF58D0C7),
                                          AppColors.tasks,
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: isDark
                                              ? Colors.black.withValues(alpha: 0.35)
                                              : const Color(0x4A89AFC7),
                                          blurRadius: 12,
                                          offset: const Offset(4, 6),
                                        ),
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.68),
                                          blurRadius: 8,
                                          offset: const Offset(-3, -3),
                                        ),
                                      ],
                                    ),
                                    child: isSaving
                                        ? const Padding(
                                            padding: EdgeInsets.all(11),
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.send_rounded,
                                            color: Colors.white,
                                            size: 17,
                                          ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    if (tagLabel != null || reminderLabel != null) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (tagLabel != null)
                            _MetaChip(label: tagLabel!, accent: AppColors.tasks),
                          if (reminderLabel != null)
                            _MetaChip(label: reminderLabel!, accent: AppColors.followUp),
                        ],
                      ),
                    ],
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
    );
  }
}

class _BarBtn extends StatelessWidget {
  const _BarBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    this.active = false,
    this.onLongPress,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: AppDurations.microSnap,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: active
                ? [
                    AppColors.tasks.withValues(alpha: 0.20),
                    AppColors.tasks.withValues(alpha: 0.08),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.72),
                    Colors.white.withValues(alpha: 0.24),
                  ],
          ),
          border: Border.all(
            color: active
                ? AppColors.tasks.withValues(alpha: 0.24)
                : Colors.white.withValues(alpha: 0.34),
            width: 0.8,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: active ? 0.10 : 0.08),
              blurRadius: 8,
              offset: const Offset(2, 3),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: active ? 0.16 : 0.70),
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: Icon(icon, size: 19, color: color),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.accent});

  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: 0.14),
            accent.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.18), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 7,
            offset: const Offset(2, 3),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.68),
            blurRadius: 7,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: accent,
          fontSize: 10.8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
