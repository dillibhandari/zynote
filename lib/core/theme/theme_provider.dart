import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:my_secure_note_app/core/preferances/shared_preferences.dart';

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._settings) : super(_settings.themeMode);

  final AppSettings _settings;

  void setThemeMode(ThemeMode mode) {
    if (mode == state) return;
    state = mode;
    _settings.themeMode = mode;
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(AppSettings()),
);
