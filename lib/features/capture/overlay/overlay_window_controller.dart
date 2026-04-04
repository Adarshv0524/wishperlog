import 'dart:ui';

import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OverlayMode { bubble, banner }

class OverlayCustomization {
  const OverlayCustomization({
    required this.opacity,
    required this.snapEnabled,
    required this.bubbleSize,
    required this.bannerHeightFactor,
  });

  final double opacity;
  final bool snapEnabled;
  final double bubbleSize;
  final double bannerHeightFactor;
}

class OverlayWindowController {
  static const _modeKey = 'overlay.mode';
  static const _posXKey = 'overlay.pos.x';
  static const _posYKey = 'overlay.pos.y';

  static const _overlayOpacityKey = 'prefs.overlay_opacity';
  static const _overlaySnapEnabledKey = 'prefs.overlay_snap_enabled';
  static const _overlayBubbleSizeKey = 'prefs.overlay_bubble_size';
  static const _overlayBannerHeightFactorKey = 'prefs.overlay_banner_height';

  static const _customizationEventType = 'overlay_customization';
  static const _surfaceProbeEventType = 'overlay_surface_probe';

  static Future<bool> ensurePermission() async {
    final granted = await FlutterOverlayWindow.isPermissionGranted();
    if (granted) {
      return true;
    }
    final requested = await FlutterOverlayWindow.requestPermission();
    return requested ?? false;
  }

  static Future<void> showBubble() async {
    await _setMode(OverlayMode.bubble);
    final customization = await readCustomization();
    final start = await _readPosition();

    await FlutterOverlayWindow.showOverlay(
      width: customization.bubbleSize.round(),
      height: customization.bubbleSize.round(),
      alignment: OverlayAlignment.centerLeft,
      flag: OverlayFlag.defaultFlag,
      enableDrag: true,
      positionGravity: customization.snapEnabled
          ? PositionGravity.auto
          : PositionGravity.none,
      startPosition: start,
      overlayTitle: 'WhisperLog Bubble',
      overlayContent: 'Ready',
    );
  }

  static Future<void> showBanner() async {
    await _setMode(OverlayMode.banner);
    final customization = await readCustomization();

    final view = PlatformDispatcher.instance.views.first;
    final logicalHeight = view.physicalSize.height / view.devicePixelRatio;
    final overlayHeight =
        (logicalHeight * customization.bannerHeightFactor).toInt();

    await FlutterOverlayWindow.showOverlay(
      width: WindowSize.matchParent,
      height: overlayHeight,
      alignment: OverlayAlignment.bottomCenter,
      flag: OverlayFlag.focusPointer,
      enableDrag: false,
      overlayTitle: 'WhisperLog Banner',
      overlayContent: 'Type note',
    );
  }

  static Future<void> showTextInput() => showBanner();

  static Future<void> requestSurfaceProbe() async {
    if (!await FlutterOverlayWindow.isActive()) {
      return;
    }
    await FlutterOverlayWindow.shareData({'type': _surfaceProbeEventType});
  }

  static Future<void> applyCustomization({bool rebuildBubble = false}) async {
    final customization = await readCustomization();

    await FlutterOverlayWindow.shareData({
      'type': _customizationEventType,
      'overlay_opacity': customization.opacity,
      'overlay_snap_enabled': customization.snapEnabled,
      'overlay_bubble_size': customization.bubbleSize,
      'overlay_banner_height': customization.bannerHeightFactor,
    });

    if (!await FlutterOverlayWindow.isActive()) {
      return;
    }

    final mode = await currentMode();
    if (rebuildBubble && mode == OverlayMode.bubble) {
      await showBubble();
    }
  }

  static Future<OverlayCustomization> readCustomization() async {
    final prefs = await SharedPreferences.getInstance();
    final opacity = (prefs.getDouble(_overlayOpacityKey) ?? 0.84).clamp(
      0.2,
      1.0,
    );
    final snapEnabled = prefs.getBool(_overlaySnapEnabledKey) ?? true;
    final bubbleSize = (prefs.getDouble(_overlayBubbleSizeKey) ?? 76.0).clamp(
      64.0,
      120.0,
    );
    final bannerHeightFactor =
        (prefs.getDouble(_overlayBannerHeightFactorKey) ?? 0.36).clamp(
          0.28,
          0.50,
        );

    return OverlayCustomization(
      opacity: opacity,
      snapEnabled: snapEnabled,
      bubbleSize: bubbleSize,
      bannerHeightFactor: bannerHeightFactor,
    );
  }

  static Future<void> rememberCurrentPosition() async {
    if (!await FlutterOverlayWindow.isActive()) {
      return;
    }
    final mode = await currentMode();
    if (mode != OverlayMode.bubble) {
      return;
    }

    final pos = await FlutterOverlayWindow.getOverlayPosition();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_posXKey, pos.x);
    await prefs.setDouble(_posYKey, pos.y);
  }

  static Future<OverlayMode> currentMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_modeKey);
    if (raw == OverlayMode.banner.name || raw == 'textInput') {
      return OverlayMode.banner;
    }
    return OverlayMode.bubble;
  }

  static Future<void> _setMode(OverlayMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
  }

  static Future<OverlayPosition?> _readPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final x = prefs.getDouble(_posXKey);
    final y = prefs.getDouble(_posYKey);
    if (x == null || y == null) {
      return null;
    }
    return OverlayPosition(x, y);
  }
}
