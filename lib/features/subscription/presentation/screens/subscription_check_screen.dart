library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/screens/home_screen.dart';
import '../providers/subscription_provider.dart';
import 'subscription_plan_picker_screen.dart';

class SubscriptionCheckScreen extends ConsumerWidget {
  const SubscriptionCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionProvider);
    final l10n = AppLocalizations.of(context)!;

    if (state.isLoading && state.subscription == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking subscription...'),
            ],
          ),
        ),
      );
    }

    if (state.error != null && state.subscription == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(l10n.syncStatusError),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.read(subscriptionProvider.notifier).load(),
                child: Text(l10n.syncNow),
              ),
            ],
          ),
        ),
      );
    }

    if (state.subscription == null) return const SubscriptionPlanPickerScreen();
    return const HomeScreen();
  }
}
