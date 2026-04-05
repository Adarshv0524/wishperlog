import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/shared/models/enums.dart';

part 'capture_ui_state.dart';

/// Manages recording / capture UI state for the single global Dynamic Island.
/// Transitions: idle → recording → processing → saved → idle.
class CaptureUiController extends Cubit<CaptureUiState> {
  CaptureUiController({
    required CaptureService captureService,
    required SpeechToText speechToText,
  }) : _captureService = captureService,
       _speechToText = speechToText,
       super(const CaptureUiIdle()) {
    // Pre-warm the speech engine so the first long-press has no latency.
    _prewarmSpeech();
  }

  final CaptureService _captureService;
  final SpeechToText _speechToText;

  Timer? _autoReturnTimer;
  Timer? _recordingTimer;
  int _recordingDurationMs = 0;
  final List<double> _waveformSamples = [];
  String _lastTranscript = '';

  // ── Timing-safety flags ────────────────────────────────────────────────────
  /// True while [startRecording] is awaiting speech engine initialisation.
  bool _isInitializing = false;
  /// True if [stopRecording] was called before init finished (user released
  /// the button before the engine was ready).  Checked after init.
  bool _stopRequested = false;

  Future<void> _prewarmSpeech() async {
    try {
      if (!_speechToText.isAvailable) {
        await _speechToText.initialize(
          onStatus: _onSpeechStatus,
          onError: (e) => debugPrint('[CaptureUiController] STT prewarm error: ${e.errorMsg}'),
        );
      }
    } catch (e) {
      debugPrint('[CaptureUiController] prewarm failed (non-fatal): $e');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // In-app recording (triggered by the floating bubble long-press)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Starts recording.  Called on long-press START.
  Future<void> startRecording() async {
    if (state is CaptureUiRecording || state is CaptureUiProcessing) return;
    if (_isInitializing) return; // already spinning up — ignore duplicate call

    _stopRequested = false;
    _isInitializing = true;

    try {
      // ── Step 1: ensure speech engine is ready ──────────────────────────────
      if (!_speechToText.isAvailable) {
        final ready = await _speechToText.initialize(
          onStatus: _onSpeechStatus,
          onError: (error) {
            debugPrint('[CaptureUiController] STT error: ${error.errorMsg}');
            if (state is CaptureUiRecording) stopRecording();
          },
        );
        if (!ready) {
          _isInitializing = false;
          emit(const CaptureUiError(
            message: 'Microphone not available. Please grant permission in Settings.',
          ));
          await Future<void>.delayed(const Duration(seconds: 2));
          emit(const CaptureUiIdle());
          return;
        }
      }

      _isInitializing = false;

      // User released the button while we were initialising → don't record.
      if (_stopRequested) {
        _stopRequested = false;
        return;
      }

      // ── Step 2: show recording state immediately ───────────────────────────
      _recordingDurationMs = 0;
      _waveformSamples.clear();
      _lastTranscript = '';
      emit(const CaptureUiRecording(
        durationMs: 0,
        waveformSamples: [],
        currentTranscript: '',
      ));

      // ── Step 3: waveform animation timer ──────────────────────────────────
      _recordingTimer?.cancel();
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
        if (state is CaptureUiRecording) {
          _recordingDurationMs += 100;
          _updateWaveform();
        }
      });

      // ── Step 4: start listening ────────────────────────────────────────────
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: const SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          onDevice: false, // network STT works on far more devices
        ),
      );
    } catch (e) {
      _isInitializing = false;
      debugPrint('[CaptureUiController] startRecording error: $e');
      _recordingTimer?.cancel();
      emit(const CaptureUiError(
        message: 'Microphone not available. Please grant permission in Settings.',
      ));
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(const CaptureUiIdle());
    }
  }

  /// Stops recording.  Called on long-press END.
  Future<void> stopRecording() async {
    // If still initialising, just flag it — startRecording() will see it.
    if (_isInitializing) {
      _stopRequested = true;
      return;
    }
    if (state is! CaptureUiRecording) return;

    _recordingTimer?.cancel();

    try {
      await _speechToText.stop();
      emit(const CaptureUiProcessing(provider: 'AI'));

      final captured = _lastTranscript.trim();
      final savedNote = captured.isEmpty
          ? null
          : await _captureService.ingestRawCapture(
              rawTranscript: captured,
              source: CaptureSource.voiceOverlay,
              syncToCloud: true, // sync in background
            );

      emit(CaptureUiSaved(
        title: savedNote?.title ?? 'Voice capture',
        category: savedNote?.category ?? NoteCategory.general,
      ));

      _autoReturnTimer?.cancel();
      _autoReturnTimer = Timer(AppDurations.notchAutoReturn, () {
        if (state is CaptureUiSaved) emit(const CaptureUiIdle());
      });
    } catch (error) {
      emit(CaptureUiError(message: 'Failed to save: $error'));
      await Future<void>.delayed(const Duration(seconds: 2));
      emit(const CaptureUiIdle());
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // External notifications (native overlay / quick-note editor / home screen)
  // These update the island without opening the microphone from Flutter.
  // ═══════════════════════════════════════════════════════════════════════════

  /// Native overlay started recording — light up the island.
  void notifyExternalRecordingStarted() {
    if (state is CaptureUiRecording || state is CaptureUiProcessing) return;
    _recordingDurationMs = 0;
    _waveformSamples.clear();
    _lastTranscript = '';
    emit(const CaptureUiRecording(
      durationMs: 0,
      waveformSamples: [],
      currentTranscript: '',
    ));
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (state is CaptureUiRecording) {
        _recordingDurationMs += 100;
        _updateWaveform();
      }
    });
  }

  /// Native overlay received a partial transcript — scroll text in island.
  void updateExternalTranscript(String text) {
    if (state is! CaptureUiRecording) return;
    final current = state as CaptureUiRecording;
    emit(CaptureUiRecording(
      durationMs: current.durationMs,
      waveformSamples: current.waveformSamples,
      currentTranscript: text,
    ));
  }

  /// Native overlay done recognising — show processing indicator.
  void notifyExternalRecordingStopped() {
    _recordingTimer?.cancel();
    if (state is CaptureUiRecording) {
      emit(const CaptureUiProcessing(provider: 'AI'));
    }
  }

  /// A note was saved (from any source) — show the saved confirmation pill.
  void notifyExternalRecordingSaved({
    required String title,
    required NoteCategory category,
  }) {
    _recordingTimer?.cancel();
    emit(CaptureUiSaved(title: title, category: category));
    _autoReturnTimer?.cancel();
    _autoReturnTimer = Timer(AppDurations.notchAutoReturn, () {
      if (state is CaptureUiSaved) emit(const CaptureUiIdle());
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Internal helpers
  // ═══════════════════════════════════════════════════════════════════════════

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastTranscript = result.recognizedWords;
    if (state is CaptureUiRecording) {
      final current = state as CaptureUiRecording;
      emit(CaptureUiRecording(
        durationMs: current.durationMs,
        waveformSamples: current.waveformSamples,
        currentTranscript: _lastTranscript,
      ));
    }
  }

  void _onSpeechStatus(String status) {
    debugPrint('[CaptureUiController] STT status: $status');
    if ((status == 'done' || status == 'notListening') &&
        state is CaptureUiRecording) {
      stopRecording();
    }
  }

  void _updateWaveform() {
    if (state is! CaptureUiRecording) return;
    final newSamples = List<double>.generate(5, (i) {
      // Simple pseudo-random bars driven by time + index
      final t = (_recordingDurationMs % 1000) / 1000.0;
      final phase = (t + i * 0.2) % 1.0;
      return (0.25 + 0.75 * phase).clamp(0.0, 1.0);
    });
    emit(CaptureUiRecording(
      durationMs: _recordingDurationMs,
      waveformSamples: newSamples,
      currentTranscript: _lastTranscript,
    ));
  }

  void resetToIdle() {
    _recordingTimer?.cancel();
    _autoReturnTimer?.cancel();
    _recordingDurationMs = 0;
    _waveformSamples.clear();
    _lastTranscript = '';
    _stopRequested = false;
    _isInitializing = false;
    emit(const CaptureUiIdle());
  }

  @override
  Future<void> close() {
    _recordingTimer?.cancel();
    _autoReturnTimer?.cancel();
    return super.close();
  }
}