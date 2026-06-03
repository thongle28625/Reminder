import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme(
      MaterialColor seedColor,
      ) {
    return ThemeData(
      useMaterial3: true,

      colorSchemeSeed: seedColor,

      brightness: Brightness.light,

      appBarTheme: const AppBarTheme(
        centerTitle: true,
      ),

      cardTheme: const CardThemeData(
        elevation: 3,
        margin: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 5,
        ),
      ),
    );
  }

  static ThemeData darkTheme(
      MaterialColor seedColor,
      ) {
    return ThemeData(
      useMaterial3: true,

      colorSchemeSeed: seedColor,

      brightness: Brightness.dark,

      appBarTheme: const AppBarTheme(
        centerTitle: true,
      ),
    );
  }
}