import 'package:flutter/material.dart';

/// App theme definitions (no custom fonts, Material 3).
class AppTheme {
  static const Color _greenSeed = Color(0xFF2E7D32);
  static const Color _darkSurface = Color(0xFF0E1420);
  static const Color _darkCard = Color(0xFF111926);

  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _greenSeed,
  );

  static final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
    seedColor: _greenSeed,
    brightness: Brightness.dark,
  ).copyWith(
    surface: _darkSurface,
    surfaceContainerHighest: _darkCard,
  );

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: _lightColorScheme,
    cardColor: Colors.white,
    textTheme: TextTheme(
      displayMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: _lightColorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: _lightColorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: _lightColorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        color: _lightColorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      labelSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _lightColorScheme.onSurfaceVariant,
      ),
      labelMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: _lightColorScheme.onSurface,
      ),
      labelLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _lightColorScheme.onSurface,
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: _darkColorScheme,
    cardColor: _darkCard,
    textTheme: TextTheme(
      displayMedium: TextStyle(
        fontSize: 30,
        fontWeight: FontWeight.w600,
        color: _darkColorScheme.onSurface,
      ),
      displaySmall: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        color: _darkColorScheme.onSurface,
      ),
      headlineSmall: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: _darkColorScheme.onSurface,
      ),
      bodyMedium: TextStyle(
        color: _darkColorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
      labelSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _darkColorScheme.onSurfaceVariant,
      ),
      labelMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
        color: _darkColorScheme.onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _darkColorScheme.onSurface,
      ),
    ),
  );
}
