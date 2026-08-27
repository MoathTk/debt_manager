import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/sharedProviders/theme_provider.dart';
import 'core/sharedProviders/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'core/services/clock_integrity_service.dart';
import 'core/services/online_status_service.dart';
import 'features/authentication/presentation/screens/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp().timeout(const Duration(seconds: 10));
    OnlineStatusService.instance.init();
  } catch (e) {
    // ignore: avoid_print
    print('[Main] Firebase init failed: $e');
  }
  runApp(const ProviderScope(child: DebtManagementApp()));
  ClockIntegrityService.init();
}

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
      home: const AuthGate(),
    );
  }
}
