/// AUTHENTICATION FEATURE — PRESENTATION LAYER: AUTH GATE
///
/// Routes the user based on auth state:
/// - No user → LoginScreen
/// - User present → initialize auth → route to SubscriptionCheckScreen
///
/// Extracted from the former AuthGate in main.dart.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/data/database_helper.dart';
import 'package:local_debt_management/Providers/sync_provider.dart';
import 'package:local_debt_management/features/subscription/presentation/screens/subscription_check_screen.dart';
import '../providers/auth_provider.dart';
import '../../data/providers/auth_providers.dart';
import 'login_screen.dart';
import 'pin_screen.dart';

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
    ref.read(syncProvider.notifier).onAuthChanged(uid);
    ref.read(authProvider.notifier).initForUser(uid);
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authUserProvider);
    final authState = ref.watch(authProvider);

    return authUser.when(
      data: (user) {
        if (user != null) {
          _initDb(user.uid);

          if (!_dbReady) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (authState.isPinSetupStep || authState.isPinEntryStep) {
            return PinScreen(
              mode: authState.isPinSetupStep ? PinMode.setup : PinMode.entry,
            );
          }

          if (authState.isComplete) {
            return const SubscriptionCheckScreen();
          }

          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (_currentUid != null) {
          ref.read(syncProvider.notifier).onAuthChanged(null);
        }
        return const LoginScreen();
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => const LoginScreen(),
    );
  }
}
