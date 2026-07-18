import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'Providers/theme_provider.dart';
import 'Providers/locale_provider.dart';
import 'data/database_helper.dart';
import 'l10n/app_localizations.dart';
import 'features/subscription/presentation/screens/subscription_check_screen.dart';
import 'screens/login_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: DebtManagementApp()));
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

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _dbReady = false;
  String? _currentUid;

  void _initDb(String uid) async {
    if (_currentUid == uid && _dbReady) return;
    setState(() {
      _dbReady = false;
      _currentUid = uid;
    });
    try {
      await DatabaseHelper.instance.init(uid);
    } catch (_) {}
    if (!mounted) return;
    setState(() => _dbReady = true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) {
        if (user != null) {
          _initDb(user.uid);
          if (!_dbReady) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const SubscriptionCheckScreen();
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const LoginScreen(),
    );
  }
}
