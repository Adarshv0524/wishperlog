import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  bool get isEnabled => _isEnabled;
  Offset get position => _position;
  bool get isHydrated => _hydrated;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Load persisted state. Call once at startup (after runApp is safe but
  /// we actually call it in initState of OverlayRootWrapper so the tree is up).
  Future<void> hydrate() async {
    if (_hydrated) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      _isEnabled = prefs.getBool(_kEnabled) ?? false;
      final x = prefs.getDouble(_kPosX) ?? 20.0;
      final y = prefs.getDouble(_kPosY) ?? 200.0;
      _position = Offset(x, y);
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
    _isEnabled = value;
    notifyListeners();
    await _persistEnabled();
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
    super.dispose();
  }
}
