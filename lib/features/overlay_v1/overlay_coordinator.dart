import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wishperlog/features/overlay_v1/data/overlay_v1_logger.dart';
import 'package:wishperlog/features/overlay_v1/data/overlay_v1_preferences.dart';
import 'package:wishperlog/features/overlay_v1/domain/overlay_bubble_config.dart';
import 'package:wishperlog/features/overlay_v1/domain/overlay_v1_state.dart';

class OverlayCoordinator {
  OverlayCoordinator(this._prefs);

  final OverlayV1Preferences _prefs;

  final ValueNotifier<OverlayV1State> state = ValueNotifier<OverlayV1State>(
    const OverlayV1State(
      mode: OverlayV1Mode.hidden,
      position: OverlayV1Preferences.defaultPosition,
    ),
  );
  final ValueNotifier<OverlayBubbleConfig> bubbleConfig =
      ValueNotifier<OverlayBubbleConfig>(OverlayBubbleConfig.defaults);

  StreamSubscription<dynamic>? _overlaySubscription;

  Future<void> hydrate() async {
    final visible = await _prefs.isVisible();
    final position = await _prefs.getPosition();
    final opacity = await _prefs.getOpacity();
    final size = await _prefs.getSize();
    final snapEnabled = await _prefs.getSnapEnabled();
    state.value = OverlayV1State(
      mode: visible ? OverlayV1Mode.idle : OverlayV1Mode.hidden,
      position: position,
    );
    bubbleConfig.value = OverlayBubbleConfig(
      opacity: opacity,
      size: size,
      snapEnabled: snapEnabled,
    );
  }

  Future<void> hydrateAndRestore() async {
    try {
      debugPrint('[OverlayCoordinator] Starting hydration...');
      await hydrate();
      debugPrint('[OverlayCoordinator] Hydration complete');
      // Don't try to restore overlay visibility on startup - let user enable it explicitly
      // This prevents hanging during app initialization
      debugPrint('[OverlayCoordinator] Skipping overlay visual restoration (user will enable manually)');
    } catch (error, stackTrace) {
      debugPrint('[OverlayCoordinator] Hydration error: $error');
      debugPrintStack(stackTrace: stackTrace);
      await _setDisabledState();
    }
  }

  Future<bool> isPermissionGranted() async {
    if (!Platform.isAndroid) {
      return false;
    }
    try {
      return await FlutterOverlayWindow.isPermissionGranted();
    } catch (error) {
      OverlayV1Logger.event('overlay_permission_check_failure', {'error': '$error'});
      return false;
    }
  }

  Future<bool> requestPermission() async {
    if (!Platform.isAndroid) {
      return false;
    }

    Future<bool> pollGranted() async {
      for (var attempt = 0; attempt < 15; attempt++) {
        await Future<void>.delayed(const Duration(milliseconds: 300));
        if (await isPermissionGranted()) {
          return true;
        }
      }
      return await isPermissionGranted();
    }

    try {
      await FlutterOverlayWindow.requestPermission();
      final grantedFromPlugin = await pollGranted();
      if (grantedFromPlugin) {
        return true;
      }
    } catch (error) {
      OverlayV1Logger.event('overlay_permission_request_failure', {'error': '$error'});
    }

    try {
      await Permission.systemAlertWindow.request();
      return await pollGranted();
    } catch (error) {
      OverlayV1Logger.event('overlay_permission_request_fallback_failure', {'error': '$error'});
      return false;
    }
  }

  Future<bool> showIdleBubble() async {
    if (!Platform.isAndroid) {
      return false;
    }

    try {
      final granted = await isPermissionGranted();
      if (!granted) {
        debugPrint('[OverlayCoordinator] Permission not granted, cannot show overlay');
        await _setDisabledState();
        return false;
      }

      final position = await _prefs.getPosition();
      final config = bubbleConfig.value;
      final bubbleWindowSize = (config.size + 16).round();

      debugPrint('[OverlayCoordinator] Attempting to show overlay at position $position...');

      try {
        await FlutterOverlayWindow.showOverlay(
          width: bubbleWindowSize,
          height: bubbleWindowSize,
          alignment: OverlayAlignment.center,
          flag: OverlayFlag.defaultFlag,
          enableDrag: false,
          overlayTitle: 'Wishperlog Floating Capture',
          overlayContent: 'Floating capture enabled',
          positionGravity: PositionGravity.none,
          startPosition: OverlayPosition(position.dx, position.dy),
        );
      } catch (showError) {
        // If showOverlay fails, ensure state is clean
        debugPrint('[OverlayCoordinator] showOverlay threw exception: $showError');
        await _setDisabledState();
        rethrow;
      }

      // Update state only after successful show
      await _prefs.setVisible(true);
      state.value = state.value.copyWith(
        mode: OverlayV1Mode.idle,
        position: position,
      );

      OverlayV1Logger.event('overlay_open');
      _startOverlayListener();
      await _broadcastBubbleConfig();

      debugPrint('[OverlayCoordinator] Overlay shown successfully');
      return true;
    } catch (error, stackTrace) {
      debugPrint('[OverlayCoordinator] Overlay show failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      OverlayV1Logger.event('overlay_show_failure', {'error': '$error'});

      // Force disabled state on failure
      await _setDisabledState();
      return false;
    }
  }

  Future<void> hideOverlay() async {
    if (!Platform.isAndroid) {
      await _setDisabledState();
      return;
    }

    try {
      await FlutterOverlayWindow.closeOverlay();
      OverlayV1Logger.event('overlay_close');
    } catch (error) {
      OverlayV1Logger.event('overlay_close_failure', {'error': '$error'});
    } finally {
      await _overlaySubscription?.cancel();
      _overlaySubscription = null;
      await _setDisabledState();
    }
  }

  Future<void> updatePersistedPosition(Offset position) async {
    await _prefs.setPosition(position);
    state.value = state.value.copyWith(position: position);
  }

  Future<OverlayBubbleConfig> getBubbleConfig() async {
    await hydrate();
    return bubbleConfig.value;
  }

  Future<void> updateBubbleConfig({
    double? opacity,
    double? size,
    bool? snapEnabled,
  }) async {
    final next = bubbleConfig.value.copyWith(
      opacity: opacity,
      size: size,
      snapEnabled: snapEnabled,
    );

    if (opacity != null) {
      await _prefs.setOpacity(next.opacity);
    }
    if (size != null) {
      await _prefs.setSize(next.size);
    }
    if (snapEnabled != null) {
      await _prefs.setSnapEnabled(next.snapEnabled);
    }

    bubbleConfig.value = next;
    await _broadcastBubbleConfig();
  }

  Future<void> dispose() async {
    await _overlaySubscription?.cancel();
    _overlaySubscription = null;
    state.dispose();
    bubbleConfig.dispose();
  }

  void _startOverlayListener() {
    _overlaySubscription ??= FlutterOverlayWindow.overlayListener.listen((event) async {
      if (event is! Map) {
        return;
      }
      final type = event['event'];
      if (type == 'overlay_drag_start') {
        OverlayV1Logger.event('overlay_drag_start');
      }
      if (type == 'overlay_snap_end') {
        final x = (event['x'] as num?)?.toDouble();
        final y = (event['y'] as num?)?.toDouble();
        if (x != null && y != null) {
          await updatePersistedPosition(Offset(x, y));
        }
        OverlayV1Logger.event('overlay_snap_end', {
          'x': x,
          'y': y,
        });
      }
      if (type == 'overlay_open') {
        OverlayV1Logger.event('overlay_open');
      }
      if (type == 'overlay_close') {
        OverlayV1Logger.event('overlay_close');
      }
    });
  }

  Future<void> _broadcastBubbleConfig() async {
    try {
      await FlutterOverlayWindow.shareData({
        'event': 'overlay_config',
        'opacity': bubbleConfig.value.opacity,
        'size': bubbleConfig.value.size,
        'snapEnabled': bubbleConfig.value.snapEnabled,
      });
    } catch (error) {
      OverlayV1Logger.event('overlay_config_broadcast_failure', {'error': '$error'});
    }
  }

  Future<void> _setDisabledState() async {
    await _prefs.setVisible(false);
    state.value = state.value.copyWith(mode: OverlayV1Mode.hidden);
  }
}
