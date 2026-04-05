import 'package:flutter/material.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

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
    return Stack(
      children: [
        GlassPane(
          level: 1,
          radius: 28,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 120),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 3,
              maxLines: 8,
              style: TextStyle(color: context.textPri, height: 1.4),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.transparent,
                hintText: "What's on your mind...",
                hintStyle: TextStyle(color: context.textSec, fontSize: 16),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.only(bottom: 40),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          right: 12,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.text.trim().isNotEmpty)
                IconButton(
                  onPressed: isSaving ? null : onSave,
                  icon: isSaving 
                     ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                     : const Icon(Icons.send_rounded, color: AppColors.tasks),
                ),
              GestureDetector(
                onLongPressStart: (_) => onMicPressStart(),
                onLongPressEnd: (_) => onMicPressEnd(),
                child: AnimatedContainer(
                  duration: AppDurations.microSnap,
                  width: isRecording ? 48 : 44,
                  height: isRecording ? 48 : 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.journal.withValues(
                      alpha: isRecording ? 0.92 : 0.72,
                    ),
                  ),
                  child: Icon(
                    isRecording
                        ? Icons.graphic_eq_rounded
                        : Icons.mic_none_rounded,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
