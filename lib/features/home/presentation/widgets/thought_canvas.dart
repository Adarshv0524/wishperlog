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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
      ? const Color(0x44D4E5FF)
      : const Color(0x26204268);
    final topLayer = isDark
      ? const Color(0x24E8F2FF)
      : const Color(0xEEF9FCFF);
    final bottomLayer = isDark
      ? const Color(0x144E6FA0)
      : const Color(0xB8EAF2FF);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                topLayer,
                bottomLayer,
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.30)
                    : const Color(0x563D6A97),
                blurRadius: 28,
                spreadRadius: -10,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.03 : 0.18),
                      Colors.white.withValues(alpha: isDark ? 0.28 : 0.46),
                      Colors.white.withValues(alpha: isDark ? 0.03 : 0.18),
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
                    contentPadding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
                  ),
                ),
              ),
              // ── Action bar ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: borderColor,
                      width: 0.6,
                    ),
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
                              color: isRecording
                                  ? AppColors.tasks.withValues(alpha: 0.85)
                                  : (isDark
                                        ? const Color(0x30FFFFFF)
                                        : const Color(0x22DDEAFF)),
                              border: Border.all(
                                color: isRecording ? AppColors.tasks : borderColor,
                                width: isRecording ? 1.5 : 0.8,
                              ),
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
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.tasks,
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
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(7),
        child: AnimatedContainer(
          duration: AppDurations.microSnap,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: active ? AppColors.tasks.withValues(alpha: 0.10) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 19, color: color),
        ),
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
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.16)),
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
