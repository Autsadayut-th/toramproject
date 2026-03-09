import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController extends ChangeNotifier {
  AppThemeController._();

  static final AppThemeController instance = AppThemeController._();

  static const String _themeModeKey = 'app_theme_mode';
  static const String _darkValue = 'dark';
  static const String _lightValue = 'light';

  ThemeMode _themeMode = ThemeMode.dark;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLoaded => _loaded;

  Future<void> load() async {
    if (_loaded) {
      return;
    }
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String stored = preferences.getString(_themeModeKey) ?? _darkValue;
    _themeMode = stored == _lightValue ? ThemeMode.light : ThemeMode.dark;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode != ThemeMode.light && mode != ThemeMode.dark) {
      mode = ThemeMode.dark;
    }
    if (_themeMode == mode) {
      return;
    }

    _themeMode = mode;
    notifyListeners();

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _themeModeKey,
      mode == ThemeMode.light ? _lightValue : _darkValue,
    );
  }

  Future<void> toggle() async {
    await setThemeMode(isLightMode ? ThemeMode.dark : ThemeMode.light);
  }

  void saveThemeModeUnawaited(ThemeMode mode) {
    unawaited(setThemeMode(mode));
  }
}
