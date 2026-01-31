import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Holds and persists the user's preferred ThemeMode
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  static const String _prefsKey = 'settings.theme_mode_v1';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final intIndex = prefs.getInt(_prefsKey);
      if (intIndex == null) return;
      final mode = _fromIndex(intIndex);
      state = mode;
    } catch (_) {
      // ignore
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefsKey, _toIndex(mode));
    } catch (_) {
      // ignore
    }
  }

  int _toIndex(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 0;
      case ThemeMode.light:
        return 1;
      case ThemeMode.dark:
        return 2;
    }
  }

  ThemeMode _fromIndex(int index) {
    switch (index) {
      case 0:
        return ThemeMode.system;
      case 1:
        return ThemeMode.light;
      case 2:
      default:
        return ThemeMode.dark;
    }
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
