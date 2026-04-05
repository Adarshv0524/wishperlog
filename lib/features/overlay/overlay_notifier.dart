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

  /// Load persisted state. Call once at startup (after runApp is safe but
  /// we actually call it in initState of OverlayRootWrapper so the tree is up).
  Future<void> hydrate() async {
    if (_hydrated) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_kEnabled) ?? true; // Defaults to true per Phase B
      final x = prefs.getDouble(_kPosX) ?? 20.0;
      final y = prefs.getDouble(_kPosY) ?? 200.0;
      _position = Offset(x, y);

      _channel.setMethodCallHandler((call) async {
        if (call.method == 'openEditor') {
          // Open Truecaller-style transparent banner
          router.push('/system_banner');
        } else if (call.method == 'notifyRecordingStarted') {
          // Native overlay started recording → light up the island.
          _onNativeRecordingStarted();
        } else if (call.method == 'notifyRecordingStopped') {
          // Native overlay finished recognising → show brief processing.
          _onNativeRecordingStopped();
        } else if (call.method == 'notifyRecordingTranscript') {
          // Native overlay sent a partial transcript → scroll in island.
          final text = call.arguments?['text'] as String? ?? '';
          _onNativeTranscript(text);
        } else if (call.method == 'captureNote') {
          // Called by NoteInputReceiver when native overlay sends a note
          final text = call.arguments?['text'] as String? ?? '';
          final source = call.arguments?['source'] as String? ?? 'voice_overlay';
          if (text.isNotEmpty) {
            await _saveOverlayNote(text, source);
          }
        } else if (call.method == 'promptMicrophonePermission') {
          final granted = await requestMicrophonePermission();
          if (granted && _isEnabled) {
            await _restartNativeOverlay();
          }
        }
      });
      
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

  /// Toggle or explicitly set the overlay on/off.
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
     // Maybe check again
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

  /// Called while the user drags the bubble. Updates position immediately
  /// (60 fps) and debounces the SharedPreferences write.
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
    _openEditorCallbacks.clear();
    super.dispose();
  }

  bool _isBackgroundRecording = false;

  void _startBackgroundRecording() {
    if (_isBackgroundRecording) return;
    _isBackgroundRecording = true;
    
    try {
      final captureController = sl<CaptureUiController>();
      captureController.startRecording();
    } catch (e) {
      debugPrint('[OverlayNotifier] start recording error: $e');
    }
  }

  void _stopBackgroundRecording() {
    if (!_isBackgroundRecording) return;
    _isBackgroundRecording = false;
    
    try {
      final captureController = sl<CaptureUiController>();
      captureController.stopRecording();
      // island is already globally rendered — no separate route needed
    } catch (e) {
      debugPrint('[OverlayNotifier] stop recording error: $e');
    }
  }

  Future<void> _saveOverlayNote(String text, String source) async {
    try {
      final svc = sl.isRegistered<CaptureService>()
          ? sl<CaptureService>()
          : CaptureService();
      final captureSource = source == 'text_overlay'
          ? CaptureSource.textOverlay
          : CaptureSource.voiceOverlay;
      final saved = await svc.ingestRawCapture(
        rawTranscript: text,
        source: captureSource,
        syncToCloud: true,
      );
      if (saved == null) {
        debugPrint('[OverlayNotifier] Overlay note ignored (empty transcript).');
        return;
      }
      debugPrint('[OverlayNotifier] Note saved from overlay: $source');
      // Tell the island to show the saved confirmation.
      try {
        final captureController = sl<CaptureUiController>();
        captureController.notifyExternalRecordingSaved(
          title: saved.title ?? 'Voice capture',
          category: saved.category ?? NoteCategory.general,
        );
      } catch (e) {
        debugPrint('[OverlayNotifier] island saved-notify error: $e');
      }
    } catch (e) {
      debugPrint('[OverlayNotifier] _saveOverlayNote error: $e');
    }
  }

  // ── Native recording notifications ─────────────────────────────────────────

  void _onNativeRecordingStarted() {
    try {
      final captureController = sl<CaptureUiController>();
      captureController.notifyExternalRecordingStarted();
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNativeRecordingStarted error: $e');
    }
  }

  void _onNativeTranscript(String text) {
    try {
      final captureController = sl<CaptureUiController>();
      captureController.updateExternalTranscript(text);
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNativeTranscript error: $e');
    }
  }

  void _onNativeRecordingStopped() {
    try {
      final captureController = sl<CaptureUiController>();
      captureController.notifyExternalRecordingStopped();
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNativeRecordingStopped error: $e');
    }
  }
}