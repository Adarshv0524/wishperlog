import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesRepository {
  static const _themeModeKey = 'prefs.theme_mode';
  static const _overlayVisibleKey = 'prefs.overlay_visible';
  static const _overlayOpacityKey = 'prefs.overlay_opacity';
  static const _overlaySnapEnabledKey = 'prefs.overlay_snap_enabled';
  static const _overlayBubbleSizeKey = 'prefs.overlay_bubble_size';
  static const _overlayBannerHeightFactorKey = 'prefs.overlay_banner_height';
  static const _volumeShortcutKey = 'prefs.volume_shortcut';
  static const _digestHourKey = 'prefs.digest_hour';
  static const _digestMinuteKey = 'prefs.digest_minute';

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_themeModeKey);
    return switch (raw) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (mode) {
      ThemeMode.dark => 'dark',
      ThemeMode.light => 'light',
      ThemeMode.system => 'system',
    };
    await prefs.setString(_themeModeKey, value);
  }

  Future<bool> isOverlayVisible() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_overlayVisibleKey) ?? true;
  }

  Future<void> setOverlayVisible(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_overlayVisibleKey, value);
  }

  Future<double> getOverlayOpacity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_overlayOpacityKey) ?? 0.84;
  }

  Future<void> setOverlayOpacity(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_overlayOpacityKey, value.clamp(0.2, 1.0));
  }

  Future<bool> isOverlaySnapEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_overlaySnapEnabledKey) ?? true;
  }

  Future<void> setOverlaySnapEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_overlaySnapEnabledKey, value);
  }

  Future<double> getOverlayBubbleSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_overlayBubbleSizeKey) ?? 76;
  }

  Future<void> setOverlayBubbleSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_overlayBubbleSizeKey, value.clamp(64.0, 120.0));
  }

  Future<double> getOverlayBannerHeightFactor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_overlayBannerHeightFactorKey) ?? 0.36;
  }

  Future<void> setOverlayBannerHeightFactor(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(
      _overlayBannerHeightFactorKey,
      value.clamp(0.28, 0.50),
    );
  }

  Future<bool> isVolumeShortcutEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_volumeShortcutKey) ?? true;
  }

  Future<void> setVolumeShortcutEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_volumeShortcutKey, value);
  }

  Future<TimeOfDay> getDigestTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_digestHourKey) ?? 9;
    final minute = prefs.getInt(_digestMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setDigestTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_digestHourKey, time.hour);
    await prefs.setInt(_digestMinuteKey, time.minute);
  }
}
