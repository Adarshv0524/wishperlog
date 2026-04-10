import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wishperlog/core/settings/app_preferences_repository.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(ThemeMode.system);

  final AppPreferencesRepository _prefs;

  Future<void> hydrate() async {
    emit(await _prefs.getThemeMode());
  }

  /// Cycles: system → light → dark → system.
  Future<void> cycleTheme() async {
    final next = switch (state) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light  => ThemeMode.dark,
      ThemeMode.dark   => ThemeMode.system,
    };
    await setThemeMode(next);
  }

  /// Legacy binary toggle kept for callers that used it. Now cycles through
  /// all three states instead of flipping between only light and dark.
  Future<void> toggleLightDark() => cycleTheme();

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setThemeMode(mode);
    emit(mode);
  }

  /// Human-readable label for the current theme, suitable for a toggle chip.
  String get modeLabel => switch (state) {
    ThemeMode.system => 'Auto',
    ThemeMode.light  => 'Light',
    ThemeMode.dark   => 'Dark',
  };
}