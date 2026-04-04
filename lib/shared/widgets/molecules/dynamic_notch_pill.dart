import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/shared/widgets/atoms/category_color.dart';

/// A morphing notch pill that transitions between recording states.
/// Implements the design from the UX audit: idle (compact) → recording (expanded with waveform)
/// → processing (shimmer) → saved (success badge) → idle (auto-return 2600ms).
class DynamicNotchPill extends StatelessWidget {
  const DynamicNotchPill({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<CaptureUiController, CaptureUiState>(
      builder: (context, state) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          height: _heightForState(state),
          width: _widthForState(state),
          decoration: BoxDecoration(
            color: _backgroundColorForState(state, colorScheme, isDark),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: _borderColorForState(state, colorScheme, isDark),
              width: 1,
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _buildContent(context, state, colorScheme, isDark),
          ),
        );
      },
    );
  }

  /// Determines height based on state.
  static double _heightForState(CaptureUiState state) {
    final baseSize = 24.0;
    if (state is CaptureUiRecording) return 40.0;
    if (state is CaptureUiProcessing) return 30.0;
    if (state is CaptureUiSaved) return 34.0;
    return baseSize; // idle
  }

  /// Determines width based on state.
  static double _widthForState(CaptureUiState state) {
    final baseSize = 88.0;
    if (state is CaptureUiRecording) return 190.0;
    if (state is CaptureUiProcessing) return 156.0;
    if (state is CaptureUiSaved) return 172.0;
    return baseSize; // idle
  }

  /// Background color based on state and theme.
  static Color _backgroundColorForState(
    CaptureUiState state,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    // Use glass layer color from theme
    if (isDark) {
      return const Color(0xFF14142A).withValues(alpha: 0.95);
    } else {
      return Colors.white.withValues(alpha: 0.9);
    }
  }

  /// Border color based on state.
  static Color _borderColorForState(
    CaptureUiState state,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    if (isDark) {
      if (state is CaptureUiRecording) {
        return const Color(0xFF4DAAFF).withValues(alpha: 0.4);
      } else if (state is CaptureUiProcessing) {
        return const Color(0xFF9B6FFF).withValues(alpha: 0.4);
      } else if (state is CaptureUiSaved) {
        return const Color(0xFF32C878).withValues(alpha: 0.4);
      }
      return const Color(0xFFFFFFFF).withValues(alpha: 0.1);
    } else {
      if (state is CaptureUiRecording) {
        return const Color(0xFF3B82F6).withValues(alpha: 0.3);
      } else if (state is CaptureUiProcessing) {
        return const Color(0xFF8B5CF6).withValues(alpha: 0.3);
      } else if (state is CaptureUiSaved) {
        return const Color(0xFF10B981).withValues(alpha: 0.3);
      }
      return const Color(0xFF000000).withValues(alpha: 0.1);
    }
  }

  /// Builds the content inside the notch pill based on state.
  Widget _buildContent(
    BuildContext context,
    CaptureUiState state,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    if (state is CaptureUiRecording) {
      return _buildRecordingContent(state, isDark);
    } else if (state is CaptureUiProcessing) {
      return _buildProcessingContent(state, isDark);
    } else if (state is CaptureUiSaved) {
      return _buildSavedContent(state, isDark);
    } else if (state is CaptureUiError) {
      return _buildErrorContent(isDark);
    } else {
      return _buildIdleContent(isDark);
    }
  }

  /// Idle state: small purple dot + "whisperlog" label.
  Widget _buildIdleContent(bool isDark) {
    final textColor = isDark
        ? const Color(0xFFE8E4FD)
        : const Color(0xFF1A1530);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF353360)
                  : const Color(0xFF9B97B8),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'whisperlog',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Recording state: waveform bars + "Recording" label.
  Widget _buildRecordingContent(CaptureUiRecording state, bool isDark) {
    final textColor = isDark
        ? const Color(0xFFE8E4FD)
        : const Color(0xFF1A1530);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Waveform bars (5 animated bars)
          ..._buildWaveformBars(state.waveformSamples, isDark),
          const SizedBox(width: 6),
          Text(
            'Recording',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Processing state: shimmer effect + "Classifying" + "Gemini" sublabel.
  Widget _buildProcessingContent(CaptureUiProcessing state, bool isDark) {
    final textColor = isDark
        ? const Color(0xFFE8E4FD)
        : const Color(0xFF1A1530);
    final subtextColor = isDark
        ? const Color(0xFF7A74A8)
        : const Color(0xFF6B6590);

    return Stack(
      children: [
        // Shimmer overlay
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  isDark
                      ? const Color(0xFF9B6FFF).withValues(alpha: 0.22)
                      : const Color(0xFF8B5CF6).withValues(alpha: 0.18),
                  Colors.transparent,
                ],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Classifying',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              Text(
                state.provider,
                style: TextStyle(
                  fontSize: 8.5,
                  color: subtextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Saved state: category badge + title + success indicator.
  Widget _buildSavedContent(CaptureUiSaved state, bool isDark) {
    final textColor = isDark
        ? const Color(0xFFE8E4FD)
        : const Color(0xFF1A1530);
    final categoryColor = getCategoryColor(state.category);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success dot
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: const Color(0xFF32C878),
              borderRadius: BorderRadius.circular(3.5),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.title,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.2),
                    border: Border.all(
                      color: categoryColor.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    state.category.label,
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      color: categoryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Error state: red dot + error message.
  Widget _buildErrorContent(bool isDark) {
    final textColor = isDark
        ? const Color(0xFFE8E4FD)
        : const Color(0xFF1A1530);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              'Error',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: textColor,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds animated waveform bar visuals.
  static List<Widget> _buildWaveformBars(
    List<double> samples,
    bool isDark,
  ) {
    final barColor = isDark ? const Color(0xFF4DAAFF) : const Color(0xFF3B82F6);
    final bars = samples.isEmpty
        ? [0.3, 0.5, 0.4, 0.6, 0.5] // default pattern
        : samples;

    return List.generate(
      bars.length,
      (index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1.5),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 2.5,
          height: (bars[index] * 14 + 4).clamp(4, 16).toDouble(),
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(1.25),
          ),
        ),
      ),
    );
  }
}
