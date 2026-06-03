import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;

  MaterialColor _seedColor = Colors.blue;

  bool get isDark => _isDark;

  MaterialColor get seedColor => _seedColor;

  ThemeProvider() {
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs =
    await SharedPreferences.getInstance();

    _isDark =
        prefs.getBool('dark_mode') ?? false;

    final colorIndex =
        prefs.getInt('theme_color') ?? 0;

    _seedColor =
    Colors.primaries[colorIndex];

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDark = !_isDark;

    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'dark_mode',
      _isDark,
    );

    notifyListeners();
  }

  Future<void> changeColor(
      MaterialColor color,
      ) async {
    _seedColor = color;

    final prefs =
    await SharedPreferences.getInstance();

    final index =
    Colors.primaries.indexOf(color);

    await prefs.setInt(
      'theme_color',
      index,
    );

    notifyListeners();
  }
}