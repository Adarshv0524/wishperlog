import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/core/theme/app_durations.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

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

    // Web graceful fallback: voice recording not supported
    if (kIsWeb) {
      emit(const CaptureUiError(
        message: 'Voice recording is not available on web. Use text input instead.',
      ));
      await Future<void>.delayed(const Duration(seconds: 3));
      emit(const CaptureUiIdle());
      return;
    }

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
      _recordingTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
        if (state is CaptureUiRecording) {
          _recordingDurationMs += 150;
          _updateWaveform();
        }
      });

      // ── Step 4: start listening ────────────────────────────────────────────
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
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
    if (_isInitializing) { _stopRequested = true; return; }
    if (state is! CaptureUiRecording) return;

    _recordingTimer?.cancel();

    final captured = _lastTranscript.trim();

    try {
      await _speechToText.stop();
    } catch (_) {}

    if (captured.isEmpty) {
      emit(const CaptureUiIdle());
      return;
    }

    // Show provider immediately using last known provider
    emit(CaptureUiProcessing(
      provider: _captureService.activeProviderName,
    ));

    // Save in background - ingestRawCapture now returns instantly
    try {
      final savedNote = await _captureService.ingestRawCapture(
        rawTranscript: captured,
        source: CaptureSource.voiceOverlay,
        syncToCloud: true,
      );

      // Show saved with quick title; island updates again when AI finishes
      emit(CaptureUiSaved(
        title: savedNote?.title ?? captured,
        category: savedNote?.category ?? NoteCategory.general,
        originPrefix: saveOriginPrefix(savedNote?.aiModel ?? ''),
        noteId: savedNote?.noteId,
      ));
    } catch (error) {
      emit(CaptureUiError(message: 'Failed to save: $error'));
      await Future<void>.delayed(const Duration(seconds: 2));
    }

    _autoReturnTimer?.cancel();
    _autoReturnTimer = Timer(AppDurations.notchAutoReturn, () {
      if (state is CaptureUiSaved || state is CaptureUiError) {
        emit(const CaptureUiIdle());
      }
    });
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
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      if (state is CaptureUiRecording) {
        _recordingDurationMs += 150;
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
      final activeProvider = _captureService.activeProviderName;
      emit(CaptureUiProcessing(provider: activeProvider));
      // Safety net: if _saveOverlayNote never calls notifyExternalRecordingSaved
      // (e.g. empty transcript), auto-return to idle after 12 seconds.
      _autoReturnTimer?.cancel();
      _autoReturnTimer = Timer(const Duration(seconds: 4), () {
        if (state is CaptureUiProcessing) {
          emit(const CaptureUiIdle());
        }
      });
    }
  }

  /// Text overlay submitted — show processing indicator (no prior recording state).
  void notifyExternalTextProcessingStarted() {
    _recordingTimer?.cancel();
    emit(const CaptureUiProcessing(provider: 'AI'));
    _autoReturnTimer?.cancel();
    _autoReturnTimer = Timer(const Duration(seconds: 15), () {
      if (state is CaptureUiProcessing) emit(const CaptureUiIdle());
    });
  }

  /// Called by OverlayNotifier when a note captured from the native overlay
  /// is being saved + classified. Puts the Dynamic Island into processing state.
  void notifyExternalRecordingProcessing({String provider = 'Gemini'}) {
    _recordingTimer?.cancel();
    _autoReturnTimer?.cancel();
    emit(CaptureUiProcessing(provider: provider));
    // Safety auto-return: if we never get a saved/error signal, reset after 45s.
    _autoReturnTimer = Timer(const Duration(seconds: 45), () {
      if (state is CaptureUiProcessing) {
        emit(const CaptureUiIdle());
      }
    });
  }

  /// A note was saved (from any source) — show the saved confirmation pill.
  void notifyExternalRecordingSaved({
    required String title,
    required NoteCategory category,
    String? model,
    String? noteId,
  }) {
    _recordingTimer?.cancel();
    _autoReturnTimer?.cancel();
    emit(CaptureUiSaved(
      title: title,
      category: category,
      originPrefix: saveOriginPrefix(model ?? ''),
      noteId: noteId,
    ));
    _autoReturnTimer = Timer(AppDurations.notchAutoReturn, () {
      if (state is CaptureUiSaved) emit(const CaptureUiIdle());
    });
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Internal helpers
  // ═══════════════════════════════════════════════════════════════════════════

  void _onSpeechResult(SpeechRecognitionResult result) {
    final next = result.recognizedWords.trim();
    if (next.isNotEmpty) {
      _lastTranscript = next;
    }
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
    // 'done' = engine auto-closed due to silence or system cut-off.
    if (status == 'done' && state is CaptureUiRecording) {
      if (_stopRequested) {
        // User already released the button — flush whatever we have.
        debugPrint('[CaptureUiController] STT done after stop request — flushing transcript');
        _flushAndStop();
        return;
      }
      if (!_isInitializing) {
        // User is still holding — re-arm the listener.
        unawaited(_resumeListening());
      }
    }
  }

  /// Saves the last captured transcript if non-empty and transitions to
  /// processing state. Called when the button is released AND STT closes.
  void _flushAndStop() {
    _recordingTimer?.cancel();
    final transcript = _lastTranscript.trim();
    if (transcript.isEmpty) {
      resetToIdle();
      return;
    }
    emit(CaptureUiProcessing(provider: _captureService.activeProviderName));
    _autoReturnTimer?.cancel();
    _autoReturnTimer = Timer(const Duration(seconds: 45), () {
      if (state is CaptureUiProcessing) emit(const CaptureUiIdle());
    });
    // The save itself is triggered by the caller (_stopDictation) which
    // already holds the transcript in _lastTranscript. If this is reached
    // via _onSpeechStatus, emit the saved-transcript event so the upstream
    // save flow is triggered.
    _onSpeechResult(
      SpeechRecognitionResult(
        [SpeechRecognitionWords(transcript, null, 1.0)],
        true,
      ),
    );
  }

  /// Re-arms STT when it auto-closes during an active recording session.
  Future<void> _resumeListening() async {
    // Do NOT re-arm if: user released button, we're still initialising,
    // or the state has already moved beyond recording.
    if (state is! CaptureUiRecording || _stopRequested || _isInitializing) {
      if (_stopRequested && state is CaptureUiRecording) {
        _flushAndStop();
      }
      return;
    }
    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
          onDevice: false,
        ),
      );
    } catch (e) {
      debugPrint('[CaptureUiController] _resumeListening error: $e');
    }
  }

  void _updateWaveform() {
    if (state is! CaptureUiRecording) return;
    final t = _recordingDurationMs / 1000.0;
    // 5 bars with sin-wave animation at slightly different phases/frequencies.
    final newSamples = List<double>.generate(5, (i) {
      return (0.35 + 0.65 * ((math.sin(t * 2.5 + i * 0.7) + 1) / 2)).clamp(
        0.0,
        1.0,
      );
    });

    // Only emit if samples changed meaningfully.
    final current = state as CaptureUiRecording;
    if (_wavesEqual(current.waveformSamples, newSamples) &&
        current.durationMs == _recordingDurationMs) {
      return;
    }

    emit(CaptureUiRecording(
      durationMs: _recordingDurationMs,
      waveformSamples: newSamples,
      currentTranscript: _lastTranscript,
    ));
  }

  bool _wavesEqual(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if ((a[i] - b[i]).abs() > 0.05) return false;
    }
    return true;
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