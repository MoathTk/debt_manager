/// Subscription feature — Blocked screen (read-only mode)
///
/// Full-screen view when subscription is expired beyond grace period.
/// User can VIEW data but cannot create/edit/delete.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/screens/dashboard_screen.dart';
import 'package:local_debt_management/screens/customers_screen.dart';
import 'package:local_debt_management/screens/reminders_screen.dart';
import '../providers/subscription_provider.dart';
import '../widgets/read_only_banner.dart';
import '../widgets/subscription_status_card.dart';

class SubscriptionBlockedScreen extends ConsumerWidget {
  const SubscriptionBlockedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(subscriptionProvider);
    final sub = state.subscription;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.appTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.read(subscriptionProvider.notifier).load(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home_rounded)),
              Tab(icon: Icon(Icons.people_rounded)),
              Tab(icon: Icon(Icons.notifications_none_rounded)),
            ],
          ),
        ),
        body: Column(
          children: [
            const ReadOnlyBanner(),
            if (sub != null) SubscriptionStatusCard(subscription: sub),
            Expanded(
              child: TabBarView(
                children: [
                  DashboardScreen(),
                  CustomersScreen(),
                  RemindersScreen(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
