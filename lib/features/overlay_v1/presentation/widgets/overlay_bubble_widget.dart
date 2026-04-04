import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:wishperlog/features/capture/data/capture_service.dart';
import 'package:wishperlog/shared/models/enums.dart';

enum _OverlayUiMode { bubble, textPanel }
enum _BubbleVisualState { idle, listening, processing }

class OverlayBubbleWidget extends StatefulWidget {
  const OverlayBubbleWidget({super.key});

  @override
  State<OverlayBubbleWidget> createState() => _OverlayBubbleWidgetState();
}

class _OverlayBubbleWidgetState extends State<OverlayBubbleWidget>
    with TickerProviderStateMixin {
  static const double _snapEdgePadding = 8;
  static const double _dragThreshold = 5;
  static const int _panelHeight = 240;

  late final AnimationController _snapController;
  late final AnimationController _pulseController;
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final CaptureService _captureService = CaptureService(enableExternalSync: false);
  final SpeechToText _speech = SpeechToText();

  StreamSubscription<dynamic>? _overlayMessageSub;
  Timer? _toastTimer;
  Animation<double>? _snapX;
  _OverlayUiMode _mode = _OverlayUiMode.bubble;
  _BubbleVisualState _bubbleState = _BubbleVisualState.idle;
  double _dragDistance = 0;
  double _bubbleSize = 56;
  double _bubbleOpacity = 0.4;
  bool _snapEnabled = true;
  bool _savingText = false;
  bool _speechReady = false;
  String _recognizedWords = '';
  String? _overlayToast;
  bool _isDragging = false;
  OverlayPosition? _dragStartPosition;
  OverlayPosition? _lastBubblePosition;
  Offset _accumulatedDelta = Offset.zero;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 880),
    );
    _overlayMessageSub = FlutterOverlayWindow.overlayListener.listen(_onOverlayEvent);
    FlutterOverlayWindow.shareData({'event': 'overlay_open'});
  }

  @override
  void dispose() {
    _overlayMessageSub?.cancel();
    _toastTimer?.cancel();
    unawaited(_speech.stop());
    _textController.dispose();
    _textFocusNode.dispose();
    FlutterOverlayWindow.shareData({'event': 'overlay_close'});
    _pulseController.dispose();
    _snapController.dispose();
    super.dispose();
  }

  Future<void> _onOverlayEvent(dynamic event) async {
    if (event is! Map) {
      return;
    }
    if (event['event'] != 'overlay_config') {
      return;
    }

    final nextOpacity = (event['opacity'] as num?)?.toDouble();
    final nextSize = (event['size'] as num?)?.toDouble();
    final nextSnapEnabled = event['snapEnabled'] as bool?;

    if (!mounted) {
      return;
    }

    setState(() {
      if (nextOpacity != null) {
        _bubbleOpacity = nextOpacity.clamp(0.1, 1.0);
      }
      if (nextSize != null) {
        _bubbleSize = nextSize.clamp(40.0, 80.0);
      }
      if (nextSnapEnabled != null) {
        _snapEnabled = nextSnapEnabled;
      }
    });

    if (_mode == _OverlayUiMode.bubble) {
      await _resizeToBubble();
    }
  }

  Future<void> _onPanStart(DragStartDetails details) async {
    if (_mode != _OverlayUiMode.bubble || _bubbleState != _BubbleVisualState.idle) {
      return;
    }
    _snapController.stop();
    _dragDistance = 0;
    _accumulatedDelta = Offset.zero;
    _isDragging = false;

    try {
      _dragStartPosition = await FlutterOverlayWindow.getOverlayPosition();
      _lastBubblePosition = _dragStartPosition;
    } catch (_) {
      _dragStartPosition = null;
    }
  }

  Future<void> _onPanUpdate(DragUpdateDetails details) async {
    if (_mode != _OverlayUiMode.bubble || _bubbleState != _BubbleVisualState.idle) {
      return;
    }
    _accumulatedDelta += details.delta;
    _dragDistance = _accumulatedDelta.distance;
    if (!_isDragging && _dragDistance > _dragThreshold) {
      _isDragging = true;
      await FlutterOverlayWindow.shareData({'event': 'overlay_drag_start'});
    }

    final start = _dragStartPosition;
    if (start == null) {
      return;
    }

    final nextX = start.x + _accumulatedDelta.dx;
    final nextY = start.y + _accumulatedDelta.dy;

    try {
      await FlutterOverlayWindow.moveOverlay(OverlayPosition(nextX, nextY));
      _lastBubblePosition = OverlayPosition(nextX, nextY);
    } catch (_) {
      // Overlay moves can fail when service is re-attaching.
    }
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    if (_mode != _OverlayUiMode.bubble || _bubbleState != _BubbleVisualState.idle) {
      return;
    }
    final current = await _safeGetCurrentPosition();
    if (current == null) {
      return;
    }

    if (!_snapEnabled) {
      _dragStartPosition = current;
      _lastBubblePosition = current;
      _accumulatedDelta = Offset.zero;
      _dragDistance = 0;
      _isDragging = false;
      await FlutterOverlayWindow.shareData({
        'event': 'overlay_snap_end',
        'x': current.x,
        'y': current.y,
      });
      return;
    }

    final screenWidth = _screenWidth;
    final centerX = current.x + ((_bubbleSize + 16) / 2);
    final targetX = centerX < (screenWidth / 2)
        ? _snapEdgePadding
        : (screenWidth - (_bubbleSize + 16) - _snapEdgePadding);

    _snapX = Tween<double>(begin: current.x, end: targetX).animate(
      CurvedAnimation(parent: _snapController, curve: Curves.easeOutCubic),
    );

    void tick() {
      final value = _snapX?.value;
      if (value == null) {
        return;
      }
      FlutterOverlayWindow.moveOverlay(OverlayPosition(value, current.y));
    }

    _snapController
      ..removeListener(tick)
      ..addListener(tick)
      ..reset();

    await _snapController.forward();
    _snapController.removeListener(tick);

    await FlutterOverlayWindow.shareData({
      'event': 'overlay_snap_end',
      'x': targetX,
      'y': current.y,
    });

    _dragStartPosition = OverlayPosition(targetX, current.y);
    _lastBubblePosition = _dragStartPosition;
    _accumulatedDelta = Offset.zero;
    _dragDistance = 0;
    _isDragging = false;
  }

  Future<void> _onLongPressStart(LongPressStartDetails details) async {
    if (_mode != _OverlayUiMode.bubble || _bubbleState != _BubbleVisualState.idle) {
      return;
    }

    await _ensureBubbleModeActive();
    await _ensureMicrophonePermission();
    if (_mode != _OverlayUiMode.bubble) {
      return;
    }

    await _startVoiceCapture();
  }

  Future<void> _onLongPressEnd(LongPressEndDetails details) async {
    if (_bubbleState != _BubbleVisualState.listening) {
      return;
    }
    await _finishVoiceCapture();
  }

  Future<void> _ensureBubbleModeActive() async {
    await HapticFeedback.lightImpact();
    if (_mode == _OverlayUiMode.textPanel) {
      await _closeTextPanel();
    }
  }

  Future<void> _ensureMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (status.isGranted) {
      return;
    }
    status = await Permission.microphone.request();
    if (!status.isGranted) {
      _showOverlayToast('Microphone permission denied');
    }
  }

  Future<bool> _ensureSpeechReady() async {
    if (_speechReady) {
      return true;
    }

    _speechReady = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' && _bubbleState == _BubbleVisualState.listening) {
          unawaited(_finishVoiceCapture());
        }
      },
      onError: (_) {
        if (_bubbleState == _BubbleVisualState.listening) {
          unawaited(_finishVoiceCapture());
        }
      },
      debugLogging: false,
    );
    return _speechReady;
  }

  Future<void> _startVoiceCapture() async {
    final micGranted = await Permission.microphone.isGranted;
    if (!micGranted) {
      return;
    }

    final ready = await _ensureSpeechReady();
    if (!ready) {
      _showOverlayToast('Voice engine unavailable');
      return;
    }

    setState(() {
      _recognizedWords = '';
      _bubbleState = _BubbleVisualState.listening;
    });
    _pulseController.repeat(reverse: true);

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
    } catch (_) {
      _pulseController.stop();
      _pulseController.value = 0;
      if (!mounted) {
        return;
      }
      setState(() {
        _bubbleState = _BubbleVisualState.idle;
      });
      _showOverlayToast('Unable to start voice capture');
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _recognizedWords = result.recognizedWords;
  }

  Future<void> _finishVoiceCapture() async {
    if (_bubbleState != _BubbleVisualState.listening) {
      return;
    }

    if (mounted) {
      setState(() {
        _bubbleState = _BubbleVisualState.processing;
      });
    }
    _pulseController.stop();
    _pulseController.value = 0;

    try {
      await _speech.stop();
    } catch (_) {
      // Ignore plugin race conditions from stop() on some devices.
    }

    final spoken = _recognizedWords.trim();
    if (spoken.isNotEmpty) {
      await _captureService.ingestRawCapture(
        rawTranscript: spoken,
        source: CaptureSource.voiceOverlay,
        syncToCloud: false,
      );
      _showOverlayToast('Saved');
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _bubbleState = _BubbleVisualState.idle;
      _recognizedWords = '';
    });
  }

  Future<void> _openTextPanel() async {
    if (
        _mode == _OverlayUiMode.textPanel ||
        _savingText ||
        _bubbleState != _BubbleVisualState.idle) {
      return;
    }

    _lastBubblePosition = await _safeGetCurrentPosition() ?? _lastBubblePosition;
    _dragDistance = 0;
    _isDragging = false;

    try {
      await FlutterOverlayWindow.showOverlay(
        width: WindowSize.matchParent,
        height: _panelHeight,
        alignment: OverlayAlignment.bottomCenter,
        flag: OverlayFlag.focusPointer,
        enableDrag: false,
        overlayTitle: 'Wishperlog Floating Capture',
        overlayContent: 'Quick text capture',
      );
    } catch (_) {
      return;
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _mode = _OverlayUiMode.textPanel;
    });
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (mounted) {
      FocusScope.of(context).requestFocus(_textFocusNode);
    }
  }

  Future<void> _closeTextPanel() async {
    FocusScope.of(context).unfocus();
    final bubbleWindowSize = (_bubbleSize + 16).round();
    try {
      await FlutterOverlayWindow.showOverlay(
        width: bubbleWindowSize,
        height: bubbleWindowSize,
        alignment: OverlayAlignment.center,
        flag: OverlayFlag.defaultFlag,
        enableDrag: false,
        positionGravity: PositionGravity.none,
        startPosition: _lastBubblePosition,
        overlayTitle: 'Wishperlog Floating Capture',
        overlayContent: 'Floating capture enabled',
      );
    } catch (_) {
      // Keep widget state usable even if native resize fails.
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _mode = _OverlayUiMode.bubble;
      _textController.clear();
    });
    await _resizeToBubble();
  }

  Future<void> _saveTextCapture() async {
    if (_savingText) {
      return;
    }
    final text = _textController.text.trim();
    if (text.isEmpty) {
      await _closeTextPanel();
      return;
    }

    setState(() {
      _savingText = true;
    });

    await _captureService.ingestRawCapture(
      rawTranscript: text,
      source: CaptureSource.textOverlay,
      syncToCloud: false,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _savingText = false;
    });
    _showOverlayToast('Saved');
    await _closeTextPanel();
  }

  void _showOverlayToast(String message) {
    _toastTimer?.cancel();
    if (!mounted) {
      return;
    }
    setState(() {
      _overlayToast = message;
    });
    _toastTimer = Timer(const Duration(milliseconds: 900), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _overlayToast = null;
      });
    });
  }

  Future<void> _resizeToBubble() async {
    try {
      final bubbleWindowSize = (_bubbleSize + 16).round();
      await FlutterOverlayWindow.resizeOverlay(
        bubbleWindowSize,
        bubbleWindowSize,
        false,
      );
      await FlutterOverlayWindow.updateFlag(OverlayFlag.defaultFlag);
    } catch (_) {
      // Best-effort resize.
    }
  }

  Future<OverlayPosition?> _safeGetCurrentPosition() async {
    try {
      return await FlutterOverlayWindow.getOverlayPosition();
    } catch (_) {
      return null;
    }
  }

  double get _screenWidth {
    final view = PlatformDispatcher.instance.views.first;
    return view.physicalSize.width / view.devicePixelRatio;
  }

  @override
  Widget build(BuildContext context) {
    final isListening = _bubbleState == _BubbleVisualState.listening;
    final isProcessing = _bubbleState == _BubbleVisualState.processing;

    final pulse = isListening ? (0.75 + (_pulseController.value * 0.25)) : 1.0;
    final scale = isListening
        ? 1.1
        : isProcessing
            ? 1.04
            : 1.0;

    final bubbleFillColor = isListening
        ? const Color(0xFF3B82F6).withValues(alpha: 0.28 * pulse)
        : isProcessing
            ? const Color(0xFFF59E0B).withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.05 * _bubbleOpacity);

    final bubbleBorderColor = isListening
        ? const Color(0xFF93C5FD).withValues(alpha: 0.95)
        : isProcessing
            ? const Color(0xFFFDE68A)
            : Colors.white.withValues(alpha: 0.22 * _bubbleOpacity);

    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _mode == _OverlayUiMode.bubble
              ? GestureDetector(
                  key: const ValueKey<String>('bubble_mode'),
                  behavior: HitTestBehavior.opaque,
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  onLongPressStart: _onLongPressStart,
                  onLongPressEnd: _onLongPressEnd,
                  onTapUp: (_) {
                    if (_dragDistance > _dragThreshold || _isDragging) {
                      return;
                    }
                    _openTextPanel();
                  },
                  onDoubleTap: _openTextPanel,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOutCubic,
                    scale: scale,
                    child: ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeOutCubic,
                          width: _bubbleSize,
                          height: _bubbleSize,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: bubbleFillColor,
                            border: Border.all(
                              color: bubbleBorderColor,
                              width: isListening ? 1.6 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isListening
                                        ? const Color(0xFF3B82F6)
                                        : Colors.black)
                                    .withValues(alpha: isListening ? 0.36 : 0.12),
                                blurRadius: isListening ? 20 : 12,
                                spreadRadius: isListening ? 2 : 0,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              isProcessing
                                  ? Icons.hourglass_bottom_rounded
                                  : Icons.mic_none_rounded,
                              size: _bubbleSize * 0.39,
                              color: Colors.white.withValues(alpha: 0.92),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Align(
                  key: const ValueKey<String>('panel_mode'),
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 10,
                      right: 10,
                      bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white.withValues(alpha: 0.07),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.22),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Quick Text Capture',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.94),
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Cancel',
                                    onPressed: _closeTextPanel,
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                                ],
                              ),
                              TextField(
                                controller: _textController,
                                focusNode: _textFocusNode,
                                autofocus: true,
                                minLines: 3,
                                maxLines: 5,
                                textInputAction: TextInputAction.newline,
                                decoration: InputDecoration(
                                  hintText: 'Write a thought...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.6),
                                  ),
                                  border: InputBorder.none,
                                ),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.94),
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _savingText ? null : _saveTextCapture,
                                  child: Text(_savingText ? 'Saving...' : 'Save'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
        ),
        if (_overlayToast != null)
          Positioned(
            top: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: Colors.black.withValues(alpha: 0.7),
                ),
                child: Text(
                  _overlayToast!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
