import 'package:flutter/material.dart';

class AppTheme {
  static const bg      = Color(0xFF0A0A14);
  static const surface = Color(0xFF12121F);
  static const card    = Color(0xFF181828);
  static const accent  = Color(0xFFE94560);
  static const accentD = Color(0xFFB8273E);
  static const gold    = Color(0xFFF5A623);
  static const green   = Color(0xFF3EE8A0);
  static const blue    = Color(0xFF4A9EFF);
  static const textPrimary   = Color(0xFFF0F0FA);
  static const textSecondary = Color(0xFF9090B0);
  static const border  = Color(0x12FFFFFF);

  static const Map<String, Color> catColors = {
    'gym':      accent,
    'study':    blue,
    'language': gold,
    'health':   Color(0xFFFF6B9D),
    'work':     Color(0xFF9B59B6),
    'other':    green,
  };

  static Color catColor(String key) => catColors[key] ?? green;

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: accent,
      secondary: gold,
      surface: surface,
      // 'background' was deprecated in Flutter 3.18; use 'surface' variants instead.
    ),
    fontFamily: 'sans-serif',
    appBarTheme: const AppBarTheme(
      backgroundColor: bg,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
  );
}