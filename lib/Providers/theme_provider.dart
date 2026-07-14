import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme provider managing light/dark mode toggle.
///
/// Uses [StateNotifierProvider] to hold the current [ThemeMode].
/// Provides [ThemeNotifier] to toggle between light and dark themes.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Manages the application's theme mode.
///
/// Defaults to [ThemeMode.light] for optimal readability.
/// Merchants can toggle between light and dark modes.
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  /// Toggles between light and dark theme modes.
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  /// Sets the theme mode explicitly.
  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

/// Light theme configuration optimized for readability.
///
/// Uses teal as the seed color with generous text scaling (~1.15)
/// for accessibility across all age groups.
ThemeData get lightTheme {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: Brightness.light,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    textTheme: const TextTheme().copyWith(
      headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      bodyLarge: const TextStyle(fontSize: 18),
      bodyMedium: const TextStyle(fontSize: 16),
      bodySmall: const TextStyle(fontSize: 14),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.inversePrimary,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: const CircleBorder(),
    ),
  );
}

/// Dark theme configuration optimized for readability.
///
/// Uses the same teal seed color with dark surfaces.
/// Maintains the same text scaling for consistency.
ThemeData get darkTheme {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 46, 59, 134),
    brightness: Brightness.dark,
  );

  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    textTheme: const TextTheme().copyWith(
      headlineLarge: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      headlineMedium: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      titleLarge: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
      bodyLarge: const TextStyle(fontSize: 18),
      bodyMedium: const TextStyle(fontSize: 16),
      bodySmall: const TextStyle(fontSize: 14),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: colorScheme.inversePrimary,
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      shape: const CircleBorder(),
    ),
  );
}
