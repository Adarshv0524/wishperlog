import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OverlayV1Preferences {
  static const _visibleKey = 'overlay_v1.visible';
  static const _xKey = 'overlay_v1.position_x';
  static const _yKey = 'overlay_v1.position_y';
  static const _opacityKey = 'overlay_v1.opacity';
  static const _sizeKey = 'overlay_v1.size';
  static const _snapEnabledKey = 'overlay_v1.snap_enabled';

  static const Offset defaultPosition = Offset(16, 220);
  static const double defaultOpacity = 0.4;
  static const double defaultSize = 56;
  static const bool defaultSnapEnabled = true;

  Future<bool> isVisible() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_visibleKey) ?? false;
  }

  Future<void> setVisible(bool visible) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_visibleKey, visible);
  }

  Future<Offset> getPosition() async {
    final prefs = await SharedPreferences.getInstance();
    final x = prefs.getDouble(_xKey) ?? defaultPosition.dx;
    final y = prefs.getDouble(_yKey) ?? defaultPosition.dy;
    return Offset(x, y);
  }

  Future<void> setPosition(Offset position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_xKey, position.dx);
    await prefs.setDouble(_yKey, position.dy);
  }

  Future<double> getOpacity() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getDouble(_opacityKey) ?? defaultOpacity).clamp(0.1, 1.0);
  }

  Future<void> setOpacity(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_opacityKey, value.clamp(0.1, 1.0));
  }

  Future<double> getSize() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getDouble(_sizeKey) ?? defaultSize).clamp(40.0, 80.0);
  }

  Future<void> setSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_sizeKey, value.clamp(40.0, 80.0));
  }

  Future<bool> getSnapEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_snapEnabledKey) ?? defaultSnapEnabled;
  }

  Future<void> setSnapEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_snapEnabledKey, value);
  }
}
