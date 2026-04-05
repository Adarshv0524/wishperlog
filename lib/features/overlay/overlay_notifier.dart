import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wishperlog/app/router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/shared/models/enums.dart';

/// Lightweight state holder for the in-app floating overlay.
/// Has ZERO knowledge of BuildContext or the widget tree.
/// Persists enabled/position to SharedPreferences.
class OverlayNotifier extends ChangeNotifier {
  OverlayNotifier();

  // ── Prefs keys ────────────────────────────────────────────────────────────
  static const _kEnabled = 'overlay_v2.enabled';
  static const _kPosX = 'overlay_v2.pos_x';
  static const _kPosY = 'overlay_v2.pos_y';

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isEnabled = false;
  Offset _position = const Offset(20, 200);
  bool _hydrated = false;

  Timer? _persistDebounce;
  StreamSubscription<CaptureUiState>? _captureStateSub;
  String _lastNativeState = 'idle';
  String? _lastNativeMessage;

  final MethodChannel _channel = const MethodChannel('wishperlog/overlay');
  final List<VoidCallback> _openEditorCallbacks = [];

  bool get isEnabled => _isEnabled;

  void addOpenEditorListener(VoidCallback listener) {
    _openEditorCallbacks.add(listener);
  }

  void removeOpenEditorListener(VoidCallback listener) {
    _openEditorCallbacks.remove(listener);
  }

  Offset get position => _position;
  bool get isHydrated => _hydrated;

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> hydrate() async {
    if (_hydrated) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_kEnabled) ?? true;
      final x = prefs.getDouble(_kPosX) ?? 20.0;
      final y = prefs.getDouble(_kPosY) ?? 200.0;
      _position = Offset(x, y);

      _channel.setMethodCallHandler((call) async {
        switch (call.method) {
          case 'openEditor':
            router.push('/system_banner');
            break;
          case 'notifyRecordingStarted':
            _onNativeRecordingStarted();
            break;
          case 'notifyRecordingStopped':
            _onNativeRecordingStopped();
            break;
          case 'notifyRecordingTranscript':
            final text = call.arguments?['text'] as String? ?? '';
            _onNativeTranscript(text);
            break;
          case 'captureNote':
            // Called by NoteInputReceiver when native overlay sends a note.
            // This works when Flutter engine is alive (app in foreground or
            // kept alive). When engine is dead, the note is dropped at the
            // Kotlin level (see NoteInputReceiver).
            final text = call.arguments?['text'] as String? ?? '';
            final source = call.arguments?['source'] as String? ?? 'voice_overlay';
            if (text.isNotEmpty) {
              await _saveOverlayNote(text, source);
            }
            break;
          case 'promptMicrophonePermission':
            final granted = await requestMicrophonePermission();
            if (granted && _isEnabled) {
              await _restartNativeOverlay();
            }
            break;
          case 'notifyRecordingFailed':
            _onNativeRecordingFailed();
            break;
        }
      });

      try {
        final captureCtrl = sl<CaptureUiController>();
        _captureStateSub = captureCtrl.stream.listen(_onCaptureStateChanged);
      } catch (e) {
        debugPrint('[OverlayNotifier] capture state subscription error: $e');
      }

      if (_isEnabled) {
        _syncNativeOverlayState();
      }
    } catch (e) {
      debugPrint('[OverlayNotifier] hydrate error: $e');
    } finally {
      _hydrated = true;
      notifyListeners();
    }
  }

  Future<void> setEnabled(bool value) async {
    if (_isEnabled == value) return;

    if (value) {
      final hasOverlayPermission =
          await _channel.invokeMethod<bool>('checkPermission') ?? false;
      if (!hasOverlayPermission) {
        await _channel.invokeMethod('requestPermission');
        final grantedAfterRequest =
            await _channel.invokeMethod<bool>('checkPermission') ?? false;
        if (!grantedAfterRequest) {
          return;
        }
      }

      final hasMicPermission = await requestMicrophonePermission();
      if (!hasMicPermission) {
        return;
      }
    }

    _isEnabled = value;
    notifyListeners();
    await _persistEnabled();
    _syncNativeOverlayState();
  }

  Future<void> requestPermission() async {
    await _channel.invokeMethod('requestPermission');
    final hasPermission = await _channel.invokeMethod<bool>('checkPermission') ?? false;
    if (hasPermission) {
      await setEnabled(true);
    }
  }

  Future<bool> checkPermission() async {
    return await _channel.invokeMethod<bool>('checkPermission') ?? false;
  }

  Future<bool> requestMicrophonePermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestMicrophonePermission') ??
          false;
    } catch (e) {
      debugPrint('[OverlayNotifier] mic permission request error: $e');
      return false;
    }
  }

  void updatePosition(Offset newPosition) {
    _position = newPosition;
    notifyListeners();
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 400), _persistPosition);
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _syncNativeOverlayState() async {
    try {
      if (_isEnabled) {
        await _channel.invokeMethod('show');
      } else {
        await _channel.invokeMethod('hide');
      }
    } catch (e) {
      debugPrint('[OverlayNotifier] native sync error: $e');
    }
  }

  Future<void> _restartNativeOverlay() async {
    try {
      await _channel.invokeMethod('hide');
      await _channel.invokeMethod('show');
    } catch (e) {
      debugPrint('[OverlayNotifier] native restart error: $e');
    }
  }

  Future<void> _persistEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kEnabled, _isEnabled);
    } catch (e) {
      debugPrint('[OverlayNotifier] persist enabled error: $e');
    }
  }

  Future<void> _persistPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_kPosX, _position.dx);
      await prefs.setDouble(_kPosY, _position.dy);
    } catch (e) {
      debugPrint('[OverlayNotifier] persist position error: $e');
    }
  }

  @override
  void dispose() {
    _persistDebounce?.cancel();
    _captureStateSub?.cancel();
    _openEditorCallbacks.clear();
    super.dispose();
  }

  /// Core save method — called when native overlay broadcasts a captured note.
  /// CRITICAL PATH: this must call _notifyNativeSaved after saving so the
  /// native island shows the category pill even when the app is backgrounded.
  Future<void> _saveOverlayNote(String text, String source) async {
    try {
      final svc = sl.isRegistered<CaptureService>()
          ? sl<CaptureService>()
          : CaptureService();
      final captureSource = source == 'text_overlay'
          ? CaptureSource.textOverlay
          : CaptureSource.voiceOverlay;

      // Update Flutter island to processing state (works when app is foreground)
      try {
        sl<CaptureUiController>().notifyExternalRecordingStopped();
      } catch (_) {}

      final saved = await svc.ingestRawCapture(
        rawTranscript: text,
        source: captureSource,
        syncToCloud: true,
      );

      if (saved == null) {
        debugPrint('[OverlayNotifier] Overlay note ignored (empty transcript).');
        try { sl<CaptureUiController>().resetToIdle(); } catch (_) {}
        return;
      }

      debugPrint('[OverlayNotifier] Note saved from overlay: $source');

      // 1. Update Flutter island (works when app is in foreground)
      try {
        sl<CaptureUiController>().notifyExternalRecordingSaved(
          title: saved.title,
          category: saved.category,
        );
      } catch (e) {
        debugPrint('[OverlayNotifier] island saved-notify error: $e');
      }

      // 2. Push the saved result DIRECTLY to the native overlay service.
      //    This is the critical call that makes the island show the category
      //    label even when the Flutter engine is backgrounded.
      await _notifyNativeSaved(saved.title, saved.category);
    } catch (e) {
      debugPrint('[OverlayNotifier] _saveOverlayNote error: $e');
      // Show error on native island too
      try {
        await _channel.invokeMethod('updateIslandState', {'state': 'idle'});
      } catch (_) {}
    }
  }

  /// Pushes the save result to the native OverlayForegroundService so it can
  /// show the category pill on the native island overlay.
  /// Uses the dedicated `notifySaved` channel method added to MainActivity.
  Future<void> _notifyNativeSaved(String title, NoteCategory category) async {
    try {
      await _channel.invokeMethod('notifySaved', {
        'title': title,
        'category': category.name, // e.g. "tasks", "ideas", "reminders"
      });
    } catch (e) {
      debugPrint('[OverlayNotifier] _notifyNativeSaved error: $e');
      // Fallback: use the generic updateIslandState
      try {
        await _channel.invokeMethod('updateIslandState', {
          'state': 'saved',
          'message': title,
        });
      } catch (_) {}
    }
  }

  // ── Native recording notifications ─────────────────────────────────────────

  void _onNativeRecordingStarted() {
    try {
      sl<CaptureUiController>().notifyExternalRecordingStarted();
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNativeRecordingStarted error: $e');
    }
  }

  void _onNativeTranscript(String text) {
    try {
      sl<CaptureUiController>().updateExternalTranscript(text);
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNativeTranscript error: $e');
    }
  }

  void _onNativeRecordingStopped() {
    try {
      sl<CaptureUiController>().notifyExternalRecordingStopped();
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNativeRecordingStopped error: $e');
    }
  }

  void _onNativeRecordingFailed() {
    try {
      sl<CaptureUiController>().resetToIdle();
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNativeRecordingFailed error: $e');
    }
  }

  void _onCaptureStateChanged(CaptureUiState state) {
    String stateStr;
    String? message;

    if (state is CaptureUiRecording) {
      stateStr = 'recording';
      if (_lastNativeState == 'recording') return;
      final transcript = state.currentTranscript;
      if (transcript.isEmpty) {
        message = 'Listening...';
      } else {
        final end = transcript.length.clamp(0, 50).toInt();
        message = transcript.substring(0, end);
      }
    } else if (state is CaptureUiProcessing) {
      stateStr = 'processing';
      message = 'Classifying...';
    } else if (state is CaptureUiSaved) {
      stateStr = 'saved';
      // Include category name so native island can show the label
      message = '${state.category.name}::${state.title}';
    } else {
      stateStr = 'idle';
      message = null;
    }

    // While recording, forward transcript changes (not only first entry state)
    if (_lastNativeState == stateStr) {
      if (stateStr != 'recording' || _lastNativeMessage == message) {
        return;
      }
    }
    _lastNativeState = stateStr;
    _lastNativeMessage = message;

    // For the saved state, use notifySaved for richer category info
    if (state is CaptureUiSaved) {
      unawaited(_notifyNativeSaved(state.title, state.category));
      return;
    }

    final payload = <String, Object?>{'state': stateStr};
    if (message != null) {
      payload['message'] = message;
    }

    unawaited(
      _channel.invokeMethod('updateIslandState', payload),
    );
  }
}