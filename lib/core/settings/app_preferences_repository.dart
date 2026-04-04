import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesRepository {
  static const _themeModeKey = 'prefs.theme_mode';
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
