import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishperlog/core/di/injection_container.dart';
import 'package:wishperlog/core/theme/app_colors.dart';
import 'package:wishperlog/features/capture/presentation/state/capture_ui_controller.dart';
import 'package:wishperlog/features/overlay/overlay_notifier.dart';
import 'package:wishperlog/features/overlay/quick_note_editor.dart';
import 'package:wishperlog/shared/widgets/molecules/dynamic_notch_pill.dart';

/// The root wrapper placed inside MaterialApp.builder.
/// Renders all routes as normal, and conditionally overlays the
/// draggable capture bubble using a Stack (never OverlayEntry).
class OverlayRootWrapper extends StatefulWidget {
  const OverlayRootWrapper({required this.child, super.key});

  final Widget child;

  @override
  State<OverlayRootWrapper> createState() => _OverlayRootWrapperState();
}

class _OverlayRootWrapperState extends State<OverlayRootWrapper> {
  late final OverlayNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = sl<OverlayNotifier>();
    _notifier.addOpenEditorListener(_onNativeEditorCall);
    // Hydrate after the first frame so prefs are read after widget tree is up.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notifier.hydrate();
    });
  }

  @override
  void dispose() {
    _notifier.removeOpenEditorListener(_onNativeEditorCall);
    super.dispose();
  }

  void _onNativeEditorCall() {
    _openEditorSheet(context);
  }

  void _openEditorSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickNoteEditor(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _notifier,
      builder: (context, _) {
        return Stack(
          children: [
            widget.child,
            if (_notifier.isHydrated && _notifier.isEnabled)
              _DraggableCaptureBubble(notifier: _notifier),
            // ── Global dynamic island (top center) ──
            const Positioned(
              top: 8,
              left: 0,
              right: 0,
              child: Center(child: UnifiedDynamicIsland()),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Internal: the actual draggable bubble
// ─────────────────────────────────────────────────────────────────────────────

class _DraggableCaptureBubble extends StatefulWidget {
  const _DraggableCaptureBubble({required this.notifier});

  final OverlayNotifier notifier;

  @override
  State<_DraggableCaptureBubble> createState() =>
      _DraggableCaptureBubbleState();
}

class _DraggableCaptureBubbleState extends State<_DraggableCaptureBubble>
    with SingleTickerProviderStateMixin {
  late final CaptureUiController _captureController;
  
  void _openEditor() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const QuickNoteEditor(),
    );
  }

  // For snapping bubble to screen edge
  late Offset _pos;
  bool _isDragging = false;

  // Pulse animation for recording state
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pos = widget.notifier.position;
    _captureController = sl<CaptureUiController>();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
  }

  @override
  void didUpdateWidget(covariant _DraggableCaptureBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync position if it changed externally (e.g. first hydration).
    if (oldWidget.notifier.position != widget.notifier.position && !_isDragging) {
      setState(() => _pos = widget.notifier.position);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Drag ──────────────────────────────────────────────────────────────────

  void _onPanStart(DragStartDetails details) {
    _isDragging = true;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _pos = _pos + details.delta;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _isDragging = false;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    const bubbleSize = 56.0;
    const margin = 12.0;

    // Snap to nearest horizontal edge
    final snapX = _pos.dx < screenWidth / 2
        ? margin
        : screenWidth - bubbleSize - margin;

    // Clamp vertically within safe area
    final clampedY = _pos.dy.clamp(
      MediaQuery.paddingOf(context).top + 8,
      screenHeight - bubbleSize - MediaQuery.paddingOf(context).bottom - 8,
    );

    setState(() => _pos = Offset(snapX, clampedY));
    widget.notifier.updatePosition(_pos);
  }

  // ── Voice capture ─────────────────────────────────────────────────────────

  Future<void> _startRecording() async {
    HapticFeedback.mediumImpact();
    await _captureController.startRecording();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _stopAndSave() async {
    _pulseController.stop();
    _pulseController.reset();
    await _captureController.stopRecording();
    HapticFeedback.lightImpact();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    const size = 56.0;

    return Positioned(
      left: _pos.dx,
      top: _pos.dy,
      child: BlocBuilder<CaptureUiController, CaptureUiState>(
        bloc: _captureController,
        builder: (context, state) {
          // ── Drag uses a Listener (raw pointer events, outside the gesture
          // arena) so it never competes with the long-press recognizer. ──────
          return Listener(
            onPointerDown: (e) {
              _onPanStart(DragStartDetails(
                globalPosition: e.position,
                localPosition: e.localPosition,
              ));
            },
            onPointerMove: (e) {
              _onPanUpdate(DragUpdateDetails(
                globalPosition: e.position,
                localPosition: e.localPosition,
                delta: e.delta,
              ));
            },
            onPointerUp: (e) {
              _onPanEnd(DragEndDetails());
            },
            onPointerCancel: (_) {
              _onPanEnd(DragEndDetails());
            },
            // ── Long-press (record) + double-tap (editor) go in a plain
            // GestureDetector with NO pan callbacks so there is no race. ─────
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onDoubleTap: _openEditor,
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _stopAndSave(),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  final isRecording = state is CaptureUiRecording;
                  if (!isRecording && _pulseController.isAnimating) {
                    _pulseController.stop();
                    _pulseController.reset();
                  }
                  final scale = isRecording
                      ? 1.0 + (_pulseController.value * 0.12)
                      : 1.0;
                  return Transform.scale(scale: scale, child: child);
                },
                child: SizedBox(
                  width: size,
                  height: size,
                  child: const _BubbleContent(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bubble visual
// ─────────────────────────────────────────────────────────────────────────────

class _BubbleContent extends StatelessWidget {
  const _BubbleContent();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E1B3A) : const Color(0xFFEEEAFB);
    const icon = Icon(
      Icons.mic_none_rounded,
      color: AppColors.tasks,
      size: 24,
    );

    return Material(
      color: Colors.transparent,
      elevation: 8,
      shadowColor: Colors.black26,
      shape: const CircleBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: bgColor,
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.80),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: bgColor.withValues(alpha: 0.45),
              blurRadius: 16,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(child: icon),
      ),
    );
  }
}