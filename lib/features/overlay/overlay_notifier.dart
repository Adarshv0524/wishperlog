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
  bool _nativeSessionActive = false;

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
              Future.microtask(() => _saveOverlayNote(text, source));
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

  /// Called from main.dart _postLaunchTasks - drains notes captured while
  /// Flutter engine was dead (native-only sessions).
  Future<void> drainPendingNativeNotes() async {
    try {
      await _channel.invokeMethod('drainPendingNotes');
    } catch (e) {
      debugPrint('[OverlayNotifier] drainPendingNativeNotes error: $e');
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
  /// CRITICAL PATH: this must call notifyNativeSaved after saving so the
  /// native island shows the category pill even when the app is backgrounded.
  Future<void> _saveOverlayNote(String text, String source) async {
    try {
      final svc = sl.isRegistered<CaptureService>()
          ? sl<CaptureService>()
          : CaptureService();
      final captureSource = source == 'text_overlay'
          ? CaptureSource.textOverlay
          : CaptureSource.voiceOverlay;

      // With instant-save, skip "processing" flash - go direct to saved.
      // AI will update the note in the background.

      final saved = await svc.ingestRawCapture(
        rawTranscript: text,
        source: captureSource,
        syncToCloud: true,
      );

      if (saved == null) {
        try { sl<CaptureUiController>().resetToIdle(); } catch (_) {}
        return;
      }

      debugPrint('[OverlayNotifier] Note saved from overlay: $source');

      // Show saved state immediately with quick title.
      try {
        sl<CaptureUiController>().notifyExternalRecordingSaved(
          title: saved.title,
          category: saved.category,
          model: saved.aiModel,
        );
      } catch (_) {}

      // Native island also gets instant saved notification.
      await notifyNativeSaved(saved.title, saved.category);
    } catch (e) {
      debugPrint('[OverlayNotifier] _saveOverlayNote error: $e');
      try { await _channel.invokeMethod('updateIslandState', {'state': 'idle'}); } catch (_) {}
    }
  }

  /// Pushes the save result to the native OverlayForegroundService so it can
  /// show the category pill on the native island overlay.
  /// Uses the dedicated `notifySaved` channel method added to MainActivity.
  Future<void> notifyNativeSaved(String title, NoteCategory category) async {
    try {
      await _channel.invokeMethod('notifySaved', {
        'title': title,
        'category': category.name, // e.g. "tasks", "ideas", "reminders"
        'collection': 'users/{uid}/notes', // informational label for the island
      });
    } catch (e) {
      debugPrint('[OverlayNotifier] notifyNativeSaved error: $e');
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
    _nativeSessionActive = true;
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
    _nativeSessionActive = false;
    try {
      sl<CaptureUiController>().resetToIdle();
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNativeRecordingFailed error: $e');
    }
  }

  void _onCaptureStateChanged(CaptureUiState state) {
    if (state is CaptureUiIdle) {
      if (_nativeSessionActive) {
        _nativeSessionActive = false;
        _lastNativeState = 'idle';
        return;
      }
      if (_lastNativeState == 'idle') return;
      _lastNativeState = 'idle';
      unawaited(_channel.invokeMethod('updateIslandState', {'state': 'idle'}));
      return;
    }

    if (state is CaptureUiRecording) {
      if (_nativeSessionActive) {
        _lastNativeState = 'recording';
        return;
      }
      _lastNativeState = 'recording';
      final transcript = state.currentTranscript.trim();
      final msg = transcript.isEmpty ? 'Listening...' : transcript;
      // Always forward transcript updates; native side handles dedup.
      unawaited(_channel.invokeMethod('updateIslandState', {
        'state': 'recording',
        'message': msg,
      }));
      return;
    }

    if (state is CaptureUiProcessing) {
      if (_nativeSessionActive) {
        _lastNativeState = 'processing';
        return;
      }
      if (_lastNativeState == 'processing') return;
      _lastNativeState = 'processing';
      unawaited(_channel.invokeMethod('updateIslandState', {
        'state': 'processing',
        'message': state.provider,
      }));
      return;
    }

    if (state is CaptureUiSaved) {
      if (_nativeSessionActive) {
        _nativeSessionActive = false;
        _lastNativeState = 'idle';
        return;
      }
      // Use notifySaved path so native shows category emoji + collection.
      _lastNativeState = 'idle';
      unawaited(notifyNativeSaved(state.title, state.category));
      return;
    }

    if (state is CaptureUiError) {
      _lastNativeState = 'idle';
      unawaited(_channel.invokeMethod('updateIslandState', {'state': 'idle'}));
    }
  }
}