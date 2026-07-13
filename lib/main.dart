import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Providers/theme_provider.dart';
import 'Providers/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'screens/home_screen.dart';

/// Main entry point of the Debt Management application.
///
/// Wraps the app with [ProviderScope] for Riverpod state management,
/// enabling access to theme, locale, and database providers.
void main() {
  runApp(const ProviderScope(child: DebtManagementApp()));
}

/// Root widget of the application.
///
/// Consumes [themeProvider] and [localeProvider] to provide
/// reactive theme and language switching across the entire app.
class DebtManagementApp extends ConsumerWidget {
  const DebtManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Debt Management',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      locale: locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (final supported in supportedLocales) {
          if (locale?.languageCode == supported.languageCode) {
            return supported;
          }
        }
        return supportedLocales.first;
      },
      home: const HomeScreen(),
    );
  }
}
