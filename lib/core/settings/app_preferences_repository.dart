import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferencesRepository {
  static const _themeModeKey = 'prefs.theme_mode';
  static const _digestHourKey = 'prefs.digest_hour';
  static const _digestMinuteKey = 'prefs.digest_minute';
  static const _digestTimesKey = 'prefs.digest_times';

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
    final times = await getDigestTimes();
    return times.first;
  }

  Future<void> setDigestTime(TimeOfDay time) async {
    await setDigestTimes([time]);
  }

  Future<List<TimeOfDay>> getDigestTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_digestTimesKey) ?? const [];

    final parsed = raw
        .map(_parseHm)
        .whereType<TimeOfDay>()
        .toList();

    if (parsed.isNotEmpty) {
      return _normalizeTimes(parsed);
    }

    final hour = prefs.getInt(_digestHourKey) ?? 9;
    final minute = prefs.getInt(_digestMinuteKey) ?? 0;
    return [TimeOfDay(hour: hour, minute: minute)];
  }

  Future<void> setDigestTimes(List<TimeOfDay> times) async {
    final prefs = await SharedPreferences.getInstance();
    final normalized = _normalizeTimes(times);
    final persisted = normalized.map(_toHm).toList();

    await prefs.setStringList(_digestTimesKey, persisted);

    final first = normalized.first;
    await prefs.setInt(_digestHourKey, first.hour);
    await prefs.setInt(_digestMinuteKey, first.minute);
  }

  List<TimeOfDay> _normalizeTimes(List<TimeOfDay> times) {
    final byMinute = <int, TimeOfDay>{};
    for (final t in times) {
      byMinute[t.hour * 60 + t.minute] = t;
    }
    final sortedMinutes = byMinute.keys.toList()..sort();
    if (sortedMinutes.isEmpty) {
      return const [TimeOfDay(hour: 9, minute: 0)];
    }
    return sortedMinutes
        .map((m) => TimeOfDay(hour: m ~/ 60, minute: m % 60))
        .toList();
  }

  TimeOfDay? _parseHm(String value) {
    final parts = value.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null || h < 0 || h > 23 || m < 0 || m > 59) {
      return null;
    }
    return TimeOfDay(hour: h, minute: m);
  }

  String _toHm(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }
}
