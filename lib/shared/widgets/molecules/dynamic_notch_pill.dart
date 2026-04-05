import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/core/theme/app_colors_x.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';
import 'package:wishperlog/shared/widgets/glass_pane.dart';

class UnifiedDynamicIsland extends StatefulWidget {
  const UnifiedDynamicIsland({super.key});

  @override
  State<UnifiedDynamicIsland> createState() => _UnifiedDynamicIslandState();
}

@Deprecated('Use UnifiedDynamicIsland instead.')
class DynamicNotchPill extends UnifiedDynamicIsland {
  const DynamicNotchPill({super.key});
}

class _UnifiedDynamicIslandState extends State<UnifiedDynamicIsland> {
  bool _showContent = true;
  Timer? _fadeTimer;

  @override
  void dispose() {
    _fadeTimer?.cancel();
    super.dispose();
  }

  void _scheduleContentFade() {
    _fadeTimer?.cancel();
    setState(() {
      _showContent = false;
    });
    _fadeTimer = Timer(AppDurations.notchContentFade, () {
      if (!mounted) {
        return;
      }
      setState(() {
        _showContent = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<CaptureUiController, CaptureUiState>(
      buildWhen: (previous, current) {
        final changed =
            previous.runtimeType != current.runtimeType ||
            (current is CaptureUiSaved &&
                previous is CaptureUiSaved &&
                (previous.category != current.category ||
                    previous.title != current.title));
        if (changed) {
          _scheduleContentFade();
        }
        return true;
      },
      builder: (context, state) {
        final size = _sizeForState(state);
        final glowColor = state is CaptureUiRecording
            ? AppColors.tasks.withValues(alpha: 0.30)
            : state is CaptureUiSaved
            ? categoryColor(state.category).withValues(alpha: 0.30)
            : Colors.transparent;

        return AnimatedContainer(
          duration: AppDurations.microSnap,
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            boxShadow: glowColor == Colors.transparent
                ? const []
                : [
                    BoxShadow(
                      color: glowColor,
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: GlassPane(
              level: 1,
              sigmaOverride: 28,
              radius: 999,
              tintOverride: isDark
                  ? const Color(0xFF14142A)
                  : const Color(0xF5F0F8FC),
              child: AnimatedContainer(
                duration: AppDurations.saveConfirm,
                curve: Curves.easeOutCubic,
                width: size.width,
                height: size.height,
                child: AnimatedOpacity(
                  duration: AppDurations.notchContentFade,
                  opacity: _showContent ? 1 : 0,
                  child: Center(child: _buildStateContent(state, isDark)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Size _sizeForState(CaptureUiState state) {
    if (state is CaptureUiIdle) {
      return const Size(132, 36);
    }
    return const Size(240, 40);
  }

  Widget _buildStateContent(CaptureUiState state, bool isDark) {
    if (state is CaptureUiRecording) {
      return _RecordingContent(state: state, isDark: isDark);
    }
    if (state is CaptureUiProcessing) {
      return _ProcessingContent(state: state, isDark: isDark);
    }
    if (state is CaptureUiSaved) {
      return _SavedContent(state: state, isDark: isDark);
    }
    if (state is CaptureUiError) {
      return _ErrorContent(isDark: isDark);
    }
    return _IdleContent(isDark: isDark);
  }
}

class _IdleContent extends StatelessWidget {
  const _IdleContent({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.lightTextPri;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.tasks,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'whisperlog',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordingContent extends StatelessWidget {
  const _RecordingContent({required this.state, required this.isDark});

  final CaptureUiRecording state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.lightTextPri;
    final bars = state.waveformSamples.isEmpty
        ? const <double>[0.25, 0.48, 0.7, 0.45, 0.3]
        : state.waveformSamples.take(5).toList();
    final transcript = state.currentTranscript.trim();
    final transcriptText = transcript.isEmpty ? 'Listening...' : transcript;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.tasks,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          ...bars.map((value) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: AnimatedContainer(
                duration: AppDurations.microSnap,
                width: 2,
                height: (4 + (value * 10)).clamp(4, 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: AppColors.tasks,
                ),
              ),
            );
          }),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                transcriptText,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: 10.5,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessingContent extends StatelessWidget {
  const _ProcessingContent({required this.state, required this.isDark});

  final CaptureUiProcessing state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.lightTextPri;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.tasks,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Classifying with ${state.provider}...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          _CategoryChip(label: state.provider, category: NoteCategory.journal),
        ],
      ),
    );
  }
}

class _SavedContent extends StatelessWidget {
  const _SavedContent({required this.state, required this.isDark});

  final CaptureUiSaved state;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.lightTextPri;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.tasks,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              state.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 6),
          _CategoryChip(
            label: categoryLabel(state.category),
            category: state.category,
          ),
        ],
      ),
    );
  }
}

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? Colors.white : AppColors.lightTextPri;
    return Text('Error', style: TextStyle(fontSize: 10, color: textColor));
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.label, required this.category});

  final String label;
  final NoteCategory category;

  @override
  Widget build(BuildContext context) {
    final color = categoryColor(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: color.withValues(alpha: 0.20),
        border: Border.all(color: color.withValues(alpha: 0.45), width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
