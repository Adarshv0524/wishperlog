part of 'capture_ui_controller.dart';

/// Enum representing capture recording states in the overlay.
enum CaptureRecordingState {
  idle,
  recording,
  processing,
  saved,
}

/// State class for CaptureUiController Cubit.
abstract class CaptureUiState {
  const CaptureUiState();
}

/// Initial state when notch is idle, no recording in progress.
class CaptureUiIdle extends CaptureUiState {
  const CaptureUiIdle();
}

/// State when recording is in progress.
class CaptureUiRecording extends CaptureUiState {
  const CaptureUiRecording({
    required this.durationMs,
    required this.waveformSamples,
    required this.currentTranscript,
  });

  final int durationMs;
  final List<double> waveformSamples;
  final String currentTranscript;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptureUiRecording &&
          runtimeType == other.runtimeType &&
          durationMs == other.durationMs &&
          waveformSamples == other.waveformSamples &&
          currentTranscript == other.currentTranscript;

  @override
  int get hashCode =>
      durationMs.hashCode ^ waveformSamples.hashCode ^ currentTranscript.hashCode;
}

/// State when audio is being processed (transcribing / classifying).
class CaptureUiProcessing extends CaptureUiState {
  const CaptureUiProcessing({required this.provider});

  final String provider; // e.g., "Gemini", "OpenAI"

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptureUiProcessing &&
          runtimeType == other.runtimeType &&
          provider == other.provider;

  @override
  int get hashCode => provider.hashCode;
}

/// State when a note has been saved and is showing success UI.
class CaptureUiSaved extends CaptureUiState {
  const CaptureUiSaved({
    required this.title,
    required this.category,
  });

  final String title;
  final NoteCategory category;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptureUiSaved &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          category == other.category;

  @override
  int get hashCode => title.hashCode ^ category.hashCode;
}

/// State when an error occurred during recording or processing.
class CaptureUiError extends CaptureUiState {
  const CaptureUiError({required this.message});

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptureUiError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
