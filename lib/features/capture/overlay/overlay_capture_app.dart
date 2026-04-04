import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/features/capture/overlay/overlay_window_controller.dart';
import 'package:wishperlog/shared/models/enums.dart';
import 'package:wishperlog/shared/widgets/glass_container.dart';

class OverlayCaptureApp extends StatelessWidget {
  const OverlayCaptureApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayCaptureView(),
    );
  }
}

class OverlayCaptureView extends StatefulWidget {
  const OverlayCaptureView({super.key});

  @override
  State<OverlayCaptureView> createState() => _OverlayCaptureViewState();
}

enum OverlaySpeechState {
  uninitialized,
  initializing,
  ready,
  listening,
  processing,
}

class _OverlayCaptureViewState extends State<OverlayCaptureView> {
  final SpeechToText _speech = SpeechToText();
  final CaptureService _captureService = CaptureService(
    enableExternalSync: false,
  );
  final TextEditingController _textController = TextEditingController();
  final FocusNode _bannerFocusNode = FocusNode();

  OverlayMode _mode = OverlayMode.bubble;
  OverlaySpeechState _speechState = OverlaySpeechState.uninitialized;
  bool _surfaceReady = false;
  bool _isDisposed = false;
  bool _isPressingMic = false;
  bool _micPermissionDenied = false;
  bool _snapEnabled = true;
  double _overlayOpacity = 0.84;
  double _bubbleSize = 76;
  String _voiceWords = '';
  StreamSubscription<dynamic>? _overlayEventSub;
  Timer? _positionSyncTimer;

  bool get _isListening => _speechState == OverlaySpeechState.listening;
  bool get _isBusy => _speechState == OverlaySpeechState.processing;
  bool get _micHot => _isListening || _isBusy || _isPressingMic;
  bool get _canStartListening =>
      _surfaceReady &&
      _mode == OverlayMode.bubble &&
      _speechState == OverlaySpeechState.ready;

  @override
  void initState() {
    super.initState();
    _loadMode();
    _loadCustomization();
    _overlayEventSub = FlutterOverlayWindow.overlayListener.listen(_onOverlayEvent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifySurfaceReady();
      _ensureSpeechInitialized();
    });
    _positionSyncTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      if (_mode == OverlayMode.bubble && !_isListening) {
        await OverlayWindowController.rememberCurrentPosition();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _overlayEventSub?.cancel();
    _positionSyncTimer?.cancel();
    _textController.dispose();
    _bannerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadMode() async {
    final mode = await OverlayWindowController.currentMode();
    if (!mounted) {
      return;
    }
    setState(() {
      _mode = mode;
    });
    if (mode == OverlayMode.banner) {
      _requestBannerFocus();
    }
  }

  Future<void> _loadCustomization() async {
    final customization = await OverlayWindowController.readCustomization();
    if (!mounted) {
      return;
    }
    setState(() {
      _overlayOpacity = customization.opacity;
      _snapEnabled = customization.snapEnabled;
      _bubbleSize = customization.bubbleSize;
    });
  }

  Future<void> _ensureSpeechInitialized() async {
    if (_isDisposed ||
        _speechState == OverlaySpeechState.initializing ||
        _speechState == OverlaySpeechState.ready ||
        _speechState == OverlaySpeechState.listening ||
        _speechState == OverlaySpeechState.processing) {
      return;
    }

    if (mounted) {
      setState(() {
        _speechState = OverlaySpeechState.initializing;
        _micPermissionDenied = false;
      });
    }

    final ok = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && _speechState == OverlaySpeechState.listening) {
          _stopListeningAndSave();
        }
      },
      onError: (_) {
        if (_speechState == OverlaySpeechState.listening) {
          _stopListeningAndSave();
          return;
        }
        if (mounted && !_isDisposed) {
          setState(() {
            _speechState = OverlaySpeechState.uninitialized;
            _micPermissionDenied = true;
            _isPressingMic = false;
          });
        }
      },
      debugLogging: false,
    );

    if (!mounted || _isDisposed) {
      return;
    }

    setState(() {
      _speechState = ok
          ? OverlaySpeechState.ready
          : OverlaySpeechState.uninitialized;
      _micPermissionDenied = !ok;
      _isPressingMic = false;
    });
  }

  Future<void> _startListening() async {
    if (!_canStartListening) {
      if (_speechState == OverlaySpeechState.uninitialized) {
        await _ensureSpeechInitialized();
      }
      if (mounted) {
        setState(() {
          _isPressingMic = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isPressingMic = true;
        _micPermissionDenied = false;
      });
    }

    await HapticFeedback.mediumImpact();

    try {
      await _speech.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
          autoPunctuation: false,
          onDevice: true,
        ),
      );
      if (!mounted || _isDisposed) {
        return;
      }
      setState(() {
        _speechState = OverlaySpeechState.listening;
        _voiceWords = '';
        _micPermissionDenied = false;
        _isPressingMic = true;
      });
    } catch (_) {
      if (!mounted || _isDisposed) {
        return;
      }
      setState(() {
        _speechState = OverlaySpeechState.ready;
        _isPressingMic = false;
        _micPermissionDenied = true;
      });
    }
  }

  Future<void> _stopListeningAndSave() async {
    if (_speechState != OverlaySpeechState.listening) {
      return;
    }

    if (mounted) {
      setState(() {
        _speechState = OverlaySpeechState.processing;
        _isPressingMic = false;
      });
    }

    try {
      await _speech.stop();
    } catch (_) {
      // Speech plugin can throw NotInitializedError on some devices/races.
    }
    final captured = _voiceWords.trim();
    if (captured.isNotEmpty) {
      try {
        await _captureService.ingestRawCapture(
          rawTranscript: captured,
          source: CaptureSource.voiceOverlay,
        );
      } catch (_) {
        // Avoid crashing overlay isolate; capture can be retried by user.
      }
    }

    if (!mounted || _isDisposed) {
      return;
    }
    setState(() {
      _speechState = OverlaySpeechState.ready;
      _isPressingMic = false;
      _voiceWords = '';
      _mode = OverlayMode.bubble;
    });
    await OverlayWindowController.showBubble();
  }

  Future<void> _handleLongPressStart(LongPressStartDetails _) async {
    await _startListening();
  }

  Future<void> _handleLongPressEnd(LongPressEndDetails _) async {
    await _stopListeningAndSave();
  }

  Future<void> _handleDoubleTap() async {
    if (_isListening || _isBusy) {
      return;
    }
    await _openTextInputOverlay();
  }

  Future<void> _handleTap() async {
    if (_isListening || _isBusy) {
      return;
    }
    await _openTextInputOverlay();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _voiceWords = result.recognizedWords;
  }

  Future<void> _saveTypedText() async {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      try {
        await _captureService.ingestRawCapture(
          rawTranscript: text,
          source: CaptureSource.textOverlay,
        );
      } catch (_) {
        // Avoid crashing overlay isolate; capture can be retried by user.
      }
    }
    _textController.clear();
    if (mounted) {
      setState(() {
        _mode = OverlayMode.bubble;
      });
    }
    await OverlayWindowController.showBubble();
  }

  Future<void> _openTextInputOverlay() async {
    await OverlayWindowController.rememberCurrentPosition();
    await OverlayWindowController.showBanner();
    if (!mounted) {
      return;
    }
    setState(() {
      _mode = OverlayMode.banner;
    });
    _requestBannerFocus();
  }

  Future<void> _closeBannerToBubble() async {
    _textController.clear();
    if (!mounted) {
      await OverlayWindowController.showBubble();
      return;
    }
    setState(() {
      _mode = OverlayMode.bubble;
    });
    await OverlayWindowController.showBubble();
  }

  void _requestBannerFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _mode != OverlayMode.banner) {
        return;
      }
      FocusScope.of(context).requestFocus(_bannerFocusNode);
    });
  }

  Future<void> _onOverlayEvent(dynamic raw) async {
    if (raw is! Map) {
      return;
    }

    final type = raw['type'];
    if (type == 'overlay_surface_probe') {
      _notifySurfaceReady();
      return;
    }

    if (type != 'hardware_volume_down') {
      if (type == 'overlay_customization') {
        final opacity = (raw['overlay_opacity'] as num?)?.toDouble();
        final snapEnabled = raw['overlay_snap_enabled'] as bool?;
        final bubbleSize = (raw['overlay_bubble_size'] as num?)?.toDouble();
        if (!mounted) {
          return;
        }
        setState(() {
          if (opacity != null) {
            _overlayOpacity = opacity.clamp(0.2, 1.0);
          }
          if (snapEnabled != null) {
            _snapEnabled = snapEnabled;
          }
          if (bubbleSize != null) {
            _bubbleSize = bubbleSize.clamp(64.0, 120.0);
          }
        });
      }
      return;
    }

    if (!_surfaceReady) {
      return;
    }

    final phase = raw['phase'];
    if (phase == 'start' && _speechState == OverlaySpeechState.ready) {
      await _startListening();
    } else if (phase == 'end' &&
        _speechState == OverlaySpeechState.listening) {
      await _stopListeningAndSave();
    }
  }

  Future<void> _notifySurfaceReady() async {
    if (_surfaceReady || _isDisposed) {
      return;
    }
    _surfaceReady = true;
    await FlutterOverlayWindow.shareData({'type': 'overlay_surface_ready'});
  }

  @override
  Widget build(BuildContext context) {
    if (_mode == OverlayMode.banner) {
      return _buildBanner();
    }
    return _buildBubble();
  }

  Widget _buildBubble() {
    final baseSize = _micHot ? _bubbleSize * 1.15 : _bubbleSize;

    return Material(
      color: Colors.transparent,
      child: Center(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _handleTap,
          onDoubleTap: _handleDoubleTap,
          onLongPressStart: _handleLongPressStart,
          onLongPressEnd: _handleLongPressEnd,
          child: Opacity(
            opacity: _overlayOpacity,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              width: baseSize,
              height: baseSize,
              decoration: BoxDecoration(
                gradient: _micHot
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF4C6FFF), Color(0xFF7B4BFF)],
                      )
                    : const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0x801A1F2C), Color(0x66101521)],
                      ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _micHot
                      ? const Color(0xFFD6DDFF)
                      : _micPermissionDenied
                          ? const Color(0xFFFFCFCF)
                          : Colors.white.withValues(alpha: 0.88),
                  width: _micHot ? 2.0 : 1.25,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _micHot
                        ? const Color(0xAA5F77FF)
                        : Colors.black.withValues(alpha: 0.28),
                    blurRadius: _micHot ? 24 : 16,
                    spreadRadius: _micHot ? 3 : 0,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 180),
                scale: _micHot ? 1.08 : 1,
                child: Icon(
                  _isListening
                      ? Icons.graphic_eq_rounded
                      : _micPermissionDenied
                          ? Icons.mic_off_rounded
                          : Icons.mic_none_rounded,
                  color: Colors.white,
                  size: _isListening ? 36 : 30,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner() {
    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.sizeOf(context).height * 0.36,
          child: Opacity(
            opacity: _overlayOpacity,
            child: GlassContainer(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              borderRadius: BorderRadius.circular(22),
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Truecaller Banner',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints.tightFor(
                          width: 36,
                          height: 36,
                        ),
                        onPressed: _closeBannerToBubble,
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GlassContainer(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      child: TextField(
                        controller: _textController,
                        focusNode: _bannerFocusNode,
                        autofocus: true,
                        minLines: 4,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        decoration: const InputDecoration(
                          hintText: 'Type quietly...',
                          isDense: true,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _snapEnabled
                              ? 'Snapping enabled'
                              : 'Snapping disabled',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.82),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _saveTypedText,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF141414),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
