import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wishperlog/app/router.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/storage/isar_note_store.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/shared/events/note_event_bus.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/features/overlay/overlay_settings_model.dart';
import 'package:wishperlog/shared/models/note_helpers.dart';

/// Lightweight state holder for the in-app floating overlay.
/// Has ZERO knowledge of BuildContext or the widget tree.
/// Persists enabled/position to SharedPreferences.
class OverlayNotifier extends ChangeNotifier {
  OverlayNotifier();

  // ── Prefs keys ────────────────────────────────────────────────────────────
  static const _kEnabled   = 'overlay_v2.enabled';
  static const _kPosX      = 'overlay_v2.pos_x';
  static const _kPosY      = 'overlay_v2.pos_y';
  static const _kSettings  = 'overlay_v2.settings_json';

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isEnabled = false;
  Offset _position = const Offset(20, 200);
  bool _hydrated = false;
  OverlaySettings _overlaySettings = const OverlaySettings();

  Timer? _persistDebounce;
  StreamSubscription<CaptureUiState>? _captureStateSub;
  StreamSubscription<String>? _noteUpdatedSub;
  String _lastNativeState = 'idle';
  bool _nativeSessionActive = false;
  String? _lastSavedNoteId;

  final MethodChannel _channel = const MethodChannel('wishperlog/overlay');
  final List<VoidCallback> _openEditorCallbacks = [];

  bool get isEnabled => _isEnabled;
  OverlaySettings get overlaySettings => _overlaySettings;

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
      _overlaySettings = OverlaySettings.fromJsonString(
        prefs.getString(_kSettings),
      );

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

      try {
        _noteUpdatedSub = NoteEventBus.instance.onNoteUpdated.listen(_onNoteUpdated);
      } catch (e) {
        debugPrint('[OverlayNotifier] note update subscription error: $e');
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


  /// Whether we are currently waiting for the user to return from Settings
  /// after we opened the overlay-permission screen.
  bool _pendingPermissionCheck = false;

  Future<void> setEnabled(bool value) async {
    if (_isEnabled == value) return;

    if (value) {
      final hasOverlayPermission =
          await _channel.invokeMethod<bool>('checkPermission') ?? false;

      if (!hasOverlayPermission) {
        // Open the system settings page. Do NOT re-check immediately —
        // the check will happen in resumePermissionCheck() called from
        // the platform side (via AppLifecycleState.resumed) or on the
        // next hydrate() call.
        _pendingPermissionCheck = true;
        await _channel.invokeMethod('requestPermission');
        // Do NOT proceed — the user hasn't granted permission yet.
        return;
      }

      final hasMicPermission = await requestMicrophonePermission();
      if (!hasMicPermission) return;
    }

    _isEnabled = value;
    notifyListeners();
    await _persistEnabled();
    _syncNativeOverlayState();
  }

  /// Called by the app shell (e.g. from AppLifecycleListener.onResume) after
  /// the user returns from the Android overlay-permission settings screen.
  /// Re-checks permission and completes the enable flow if granted.
  Future<void> resumePermissionCheck() async {
    if (!_pendingPermissionCheck) return;
    _pendingPermissionCheck = false;

    final hasOverlayPermission =
        await _channel.invokeMethod<bool>('checkPermission') ?? false;
    if (!hasOverlayPermission) return; // Still not granted — stay disabled.

    final hasMicPermission = await requestMicrophonePermission();
    if (!hasMicPermission) return;

    _isEnabled = true;
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
          await _channel.invokeMethod('flushPendingNotes');
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

  Future<void> saveOverlaySettings(OverlaySettings settings) async {
    _overlaySettings = settings;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kSettings, settings.toJsonString());
      // Push relevant numeric settings to native overlay channel.
      await _channel.invokeMethod<void>('updateOverlaySettings', {
        'alpha':      settings.alpha,
        'blurSigma':  settings.blurSigma,
        'growOnHold': settings.animation == OverlayAnimation.sizeGrow,
        'growScale':  settings.growScale,
      });
    } catch (e) {
      debugPrint('[OverlayNotifier] saveOverlaySettings error: $e');
    }
  }

  @override
  void dispose() {
    _persistDebounce?.cancel();
    _captureStateSub?.cancel();
    _noteUpdatedSub?.cancel();
    _openEditorCallbacks.clear();
    super.dispose();
  }

  /// Core save method — called when native overlay broadcasts a captured note.
  ///
  /// Flow:
  ///   1. Show "processing" immediately on the Flutter Dynamic Island.
  ///   2. ingestRawCapture → instant Isar save (returns quickTitle / general).
  ///   3. Show saved pill on both Flutter island and native island.
  ///   4. AI classification runs asynchronously via AiProcessingService.
  Future<void> _saveOverlayNote(String text, String source) async {
      try {
          final svc = sl.isRegistered<CaptureService>()
              ? sl<CaptureService>()
              : CaptureService();
          final captureSource = source == 'text_overlay'
              ? CaptureSource.textOverlay
              : CaptureSource.voiceOverlay;

          // Show "processing" in Flutter island immediately (no-op if app is off-screen).
          try {
              sl<CaptureUiController>().notifyExternalRecordingProcessing(
                  provider: svc.activeProviderName,
              );
          } catch (_) {}

          final saved = await svc.ingestRawCapture(
              rawTranscript: text,
              source:        captureSource,
              syncToCloud:   true,
          );

          if (saved == null) {
              _lastSavedNoteId = null;
              try { sl<CaptureUiController>().resetToIdle(); } catch (_) {}
              // Cancel any stuck "Classifying..." on the native island.
              try {
                  await _channel.invokeMethod('updateIslandState', {'state': 'idle'});
              } catch (_) {}
              return;
          }

          debugPrint('[OverlayNotifier] Note saved from overlay: $source '
              'title="${saved.title}"');
            _lastSavedNoteId = saved.noteId;

          // Update Flutter Dynamic Island to saved state.
          try {
              sl<CaptureUiController>().notifyExternalRecordingSaved(
                  title:    saved.title,
                  category: saved.category,
                  model:    saved.aiModel,
                  noteId:   saved.noteId,
              );
          } catch (_) {}

          // Update native island pill (works even when app is backgrounded,
          // because OverlayForegroundService is a persistent foreground service).
            await notifyNativeSaved(
              saved.title,
              saved.category,
              prefix: saveOriginPrefix(saved.aiModel),
            );
      } catch (e) {
          debugPrint('[OverlayNotifier] _saveOverlayNote error: $e');
          try { sl<CaptureUiController>().resetToIdle(); } catch (_) {}
          try {
              await _channel.invokeMethod('updateIslandState', {'state': 'idle'});
          } catch (_) {}
      }
  }

  /// Pushes the save result to the native OverlayForegroundService so it can
  /// show the category pill on the native island overlay.
  /// Uses the dedicated `notifySaved` channel method added to MainActivity.
  Future<void> notifyNativeSaved(
    String title,
    NoteCategory category, {
    String prefix = 'AI',
  }) async {
    try {
      await _channel.invokeMethod('notifySaved', {
        'title': title,
        'category': category.name, // e.g. "tasks", "ideas", "reminders"
        'prefix': prefix,
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

  Future<void> _onNoteUpdated(String noteId) async {
    if (noteId.trim().isEmpty || noteId != _lastSavedNoteId) {
      return;
    }

    try {
      final note = await IsarNoteStore.instance.getById(noteId);
      if (note == null) return;

      _lastSavedNoteId = note.noteId;

      try {
        sl<CaptureUiController>().notifyExternalRecordingSaved(
          title: note.title,
          category: note.category,
          model: note.aiModel,
          noteId: note.noteId,
        );
      } catch (_) {}

      await notifyNativeSaved(
        note.title,
        note.category,
        prefix: saveOriginPrefix(note.aiModel),
      );
    } catch (e) {
      debugPrint('[OverlayNotifier] _onNoteUpdated error: $e');
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
      _lastSavedNoteId = state.noteId;
      unawaited(notifyNativeSaved(
        state.title,
        state.category,
        prefix: state.originPrefix,
      ));
      return;
    }

    if (state is CaptureUiError) {
      _lastNativeState = 'idle';
      unawaited(_channel.invokeMethod('updateIslandState', {'state': 'idle'}));
    }
  }
}