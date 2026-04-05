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
    required this.onMicPressStart,
    required this.onMicPressEnd,
    required this.isSaving,
    required this.isRecording,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSave;
  final VoidCallback onMicPressStart;
  final VoidCallback onMicPressEnd;
  final bool isSaving;
  final bool isRecording;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark
      ? const Color(0x44D4E5FF)
      : const Color(0x26204268);
    final topLayer = isDark
      ? const Color(0x2AE8F2FF)
      : const Color(0xE3FFFFFF);
    final bottomLayer = isDark
      ? const Color(0x164E6FA0)
      : const Color(0xBFEAF2FF);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 36, sigmaY: 36),
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
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: borderColor, width: 0.95),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.34)
                    : const Color(0x663D6A97),
                blurRadius: 30,
                spreadRadius: -10,
                offset: const Offset(0, 10),
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
                      Colors.white.withValues(alpha: isDark ? 0.04 : 0.24),
                      Colors.white.withValues(alpha: isDark ? 0.34 : 0.54),
                      Colors.white.withValues(alpha: isDark ? 0.04 : 0.24),
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
                  textInputAction: TextInputAction.newline,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  style: TextStyle(
                    color: context.textPri,
                    fontSize: 15,
                    height: 1.5,
                  ),
                  decoration: InputDecoration(
                    filled: false,
                    hintText: isRecording
                        ? 'Listening...'
                        : "What's on your mind...",
                    hintStyle: TextStyle(
                      color: context.textSec.withValues(alpha: 0.7),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
                  ),
                ),
              ),
              // ── Action bar ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: borderColor,
                      width: 0.6,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Tag
                    _BarBtn(
                      icon: Icons.label_outline_rounded,
                      color: context.textSec,
                      onTap: () {},
                    ),
                    const SizedBox(width: 4),
                    // Reminder
                    _BarBtn(
                      icon: Icons.alarm_add_rounded,
                      color: context.textSec,
                      onTap: () {},
                    ),
                    const Spacer(),
                    // Mic (long-press to dictate)
                    GestureDetector(
                      onLongPressStart: (_) => onMicPressStart(),
                      onLongPressEnd: (_) => onMicPressEnd(),
                      child: AnimatedContainer(
                        duration: AppDurations.microSnap,
                        width: isRecording ? 44 : 40,
                        height: isRecording ? 44 : 40,
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
                          size: 20,
                          color: isRecording ? Colors.white : context.textSec,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Send
                    AnimatedSwitcher(
                      duration: AppDurations.microSnap,
                      child: controller.text.trim().isEmpty
                          ? const SizedBox(width: 40, height: 40)
                          : GestureDetector(
                              key: const ValueKey('send'),
                              onTap: isSaving ? null : onSave,
                              child: AnimatedContainer(
                                duration: AppDurations.microSnap,
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.tasks,
                                ),
                                child: isSaving
                                    ? const Padding(
                                        padding: EdgeInsets.all(10),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                              ),
                            ),
                    ),
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
  const _BarBtn({required this.icon, required this.color, required this.onTap});

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}
