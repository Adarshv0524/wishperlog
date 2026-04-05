import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/shared/models/enums.dart';

part 'capture_ui_state.dart';

/// BLoC/Cubit that manages the recording and capture UI state for the notch pill.
/// Handles transitions: idle → recording → processing → saved → idle.
class CaptureUiController extends Cubit<CaptureUiState> {
  CaptureUiController({
    required CaptureService captureService,
    required SpeechToText speechToText,
  }) : _captureService = captureService,
       _speechToText = speechToText,
       super(const CaptureUiIdle());

  final CaptureService _captureService;
  final SpeechToText _speechToText;

  Timer? _autoReturnTimer;
  Timer? _recordingTimer;
  int _recordingDurationMs = 0;
  final List<double> _waveformSamples = [];
  String _lastTranscript = '';

  /// Starts recording. Called on long-press start.
  Future<void> startRecording() async {
    if (state is CaptureUiRecording || state is CaptureUiProcessing) {
      return; // Already recording or processing
    }

    try {
      // Initialize speech-to-text if needed
      if (!_speechToText.isAvailable) {
        await _speechToText.initialize();
      }

      // Start listening
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          onDevice: true,
        ),
      );

      // Reset recording state
      _recordingDurationMs = 0;
      _waveformSamples.clear();
      _lastTranscript = '';

      // Emit recording state
      emit(
        const CaptureUiRecording(
          durationMs: 0,
          waveformSamples: [],
          currentTranscript: '',
        ),
      );

      // Start recording timer to update waveform visualization
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (state is CaptureUiRecording) {
          _recordingDurationMs += 100;
          _updateWaveformVisualization();
        }
      });
    } catch (error) {
      emit(CaptureUiError(message: 'Failed to start recording: $error'));
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(const CaptureUiIdle());
    }
  }

  /// Stops recording. Called on long-press end. Triggers processing.
  Future<void> stopRecording() async {
    if (state is! CaptureUiRecording) {
      return;
    }

    _recordingTimer?.cancel();

    try {
      await _speechToText.stop();

      // Transition to processing state
      emit(const CaptureUiProcessing(provider: 'Gemini'));

      // Simulate processing delay (in production, wait for actual AI response)
      await Future<void>.delayed(AppDurations.microSnap * 6);

      final captured = _lastTranscript.trim();
      final savedNote = captured.isEmpty
          ? null
          : await _captureService.ingestRawCapture(
              rawTranscript: captured,
              source: CaptureSource.voiceOverlay,
              syncToCloud: false,
            );

      // Transition to saved state.
      emit(
        CaptureUiSaved(
          title: savedNote?.title ?? 'Voice capture',
          category: savedNote?.category ?? NoteCategory.general,
        ),
      );

      // Auto-return to idle after 2600ms
      _autoReturnTimer?.cancel();
      _autoReturnTimer = Timer(AppDurations.notchAutoReturn, () {
        if (state is CaptureUiSaved) {
          emit(const CaptureUiIdle());
        }
      });
    } catch (error) {
      emit(CaptureUiError(message: 'Failed to stop recording: $error'));
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(const CaptureUiIdle());
    }
  }

  /// Called whenever speech recognition result is updated.
  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastTranscript = result.recognizedWords;
    if (state is CaptureUiRecording) {
      final current = state as CaptureUiRecording;
      emit(
        CaptureUiRecording(
          durationMs: current.durationMs,
          waveformSamples: current.waveformSamples,
          currentTranscript: _lastTranscript,
        ),
      );
    }
  }

  /// Updates waveform visualization with mock data.
  void _updateWaveformVisualization() {
    if (state is! CaptureUiRecording) {
      return;
    }

    // Generate mock waveform samples (5 bars as per design)
    final newSamples = List<double>.generate(
      5,
      (_) => (0.3 + (0.7 * ((_recordingDurationMs % 1000) / 1000))).clamp(
        0.0,
        1.0,
      ),
    );

    emit(
      CaptureUiRecording(
        durationMs: _recordingDurationMs,
        waveformSamples: newSamples,
        currentTranscript: _lastTranscript,
      ),
    );
  }

  /// Manually resets to idle state (for cancel operations).
  void resetToIdle() {
    _recordingTimer?.cancel();
    _autoReturnTimer?.cancel();
    _recordingDurationMs = 0;
    _waveformSamples.clear();
    _lastTranscript = '';
    emit(const CaptureUiIdle());
  }

  @override
  Future<void> close() {
    _recordingTimer?.cancel();
    _autoReturnTimer?.cancel();
    return super.close();
  }
}
