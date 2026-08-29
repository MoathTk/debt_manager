import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_type.dart';

/// Theme provider managing light/dark mode toggle.
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.light);

  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }
}

/// Light theme — Deep Navy + Gold palette.
///
/// Uses explicit [ColorScheme] instead of [ColorScheme.fromSeed] so that
/// every Material widget (AppBar, Scaffold, FAB, bottom nav, buttons, etc.)
/// picks up the navy+gold palette immediately.
ThemeData get lightTheme {
  const cs = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF0F1D3D),
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFD6DEEF),
    onPrimaryContainer: Color(0xFF0A1224),
    secondary: Color(0xFFC49A3C),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF5E6C0),
    onSecondaryContainer: Color(0xFF3D2E08),
    tertiary: Color(0xFF2E7D32),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFE8F5E9),
    onTertiaryContainer: Color(0xFF1B5E20),
    error: Color(0xFFC62828),
    onError: Colors.white,
    errorContainer: Color(0xFFFDE8E8),
    onErrorContainer: Color(0xFF8B1A1A),
    surface: Color(0xFFFDFCFA),
    onSurface: Color(0xFF1A1C1E),
    onSurfaceVariant: Color(0xFF44474E),
    outline: Color(0xFF74777F),
    outlineVariant: Color(0xFFC4C6CF),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFF2F3033),
    onInverseSurface: Color(0xFFF1F0F4),
    surfaceContainerHighest: Color(0xFFE1E2E9),
    surfaceContainerHigh: Color(0xFFECEDF4),
    surfaceContainer: Color(0xFFF5F5FA),
    surfaceContainerLow: Color(0xFFF9F9FE),
    surfaceContainerLowest: Colors.white,
  );

  return ThemeData(
    colorScheme: cs,
    scaffoldBackgroundColor: cs.surface,
    useMaterial3: true,
    extensions: const [AppColors.light],
    textTheme: _buildTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: AppType.displayFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFF0F1D3D),
      ),
      iconTheme: IconThemeData(color: Color(0xFF0F1D3D)),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      color: cs.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFC49A3C),
      foregroundColor: Colors.white,
      shape: CircleBorder(),
      elevation: 3,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF0F1D3D),
      unselectedItemColor: Color(0xFF74777F),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFE0E0E0),
      thickness: 0.5,
      space: 0.5,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC4C6CF)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC4C6CF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFC49A3C), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F1D3D),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}

/// Dark theme — Deep Navy + Gold palette (dark variant).
ThemeData get darkTheme {
  const cs = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFB0C4E8),
    onPrimary: Color(0xFF0F1D3D),
    primaryContainer: Color(0xFF1A2F52),
    onPrimaryContainer: Color(0xFFD6DEEF),
    secondary: Color(0xFFE0B94D),
    onSecondary: Color(0xFF1A1400),
    secondaryContainer: Color(0xFF3D3018),
    onSecondaryContainer: Color(0xFFF5E6C0),
    tertiary: Color(0xFF66BB6A),
    onTertiary: Color(0xFF0D3311),
    tertiaryContainer: Color(0xFF152718),
    onTertiaryContainer: Color(0xFFA5D6A7),
    error: Color(0xFFEF5350),
    onError: Color(0xFF2D0A0A),
    errorContainer: Color(0xFF3A1518),
    onErrorContainer: Color(0xFFFFB4AB),
    surface: Color(0xFF0A1628),
    onSurface: Color(0xFFE1E2E9),
    onSurfaceVariant: Color(0xFFC4C6CF),
    outline: Color(0xFF8E9099),
    outlineVariant: Color(0xFF44474E),
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: Color(0xFFE1E2E9),
    onInverseSurface: Color(0xFF1A1C1E),
    surfaceContainerHighest: Color(0xFF2A3A52),
    surfaceContainerHigh: Color(0xFF1E2E44),
    surfaceContainer: Color(0xFF162640),
    surfaceContainerLow: Color(0xFF112038),
    surfaceContainerLowest: Color(0xFF0A1628),
  );

  return ThemeData(
    colorScheme: cs,
    scaffoldBackgroundColor: cs.surface,
    useMaterial3: true,
    extensions: const [AppColors.dark],
    textTheme: _buildTextTheme(),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: TextStyle(
        fontFamily: AppType.displayFamily,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Color(0xFFB0C4E8),
      ),
      iconTheme: IconThemeData(color: Color(0xFFB0C4E8)),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      color: cs.surfaceContainerLow,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFFE0B94D),
      foregroundColor: Color(0xFF0F1D3D),
      shape: CircleBorder(),
      elevation: 3,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0A1628),
      selectedItemColor: Color(0xFFE0B94D),
      unselectedItemColor: Color(0xFF8E9099),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A3A52),
      thickness: 0.5,
      space: 0.5,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: cs.surfaceContainerLow,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF44474E)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF44474E)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0B94D), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE0B94D),
        foregroundColor: const Color(0xFF0F1D3D),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}

/// Shared type scale — [AppType] pairing (Cairo display / Tajawal body)
/// applied across light and dark themes so both scripts render consistently.
TextTheme _buildTextTheme() {
  return const TextTheme(
    displaySmall: AppType.displaySmall,
    headlineLarge: AppType.headlineLarge,
    headlineMedium: AppType.headlineMedium,
    headlineSmall: AppType.headlineSmall,
    titleLarge: AppType.titleLarge,
    titleMedium: AppType.titleMedium,
    titleSmall: AppType.titleSmall,
    bodyLarge: AppType.bodyLarge,
    bodyMedium: AppType.bodyMedium,
    bodySmall: AppType.bodySmall,
    labelLarge: AppType.labelLarge,
    labelMedium: AppType.labelMedium,
    labelSmall: AppType.labelSmall,
  );
}
