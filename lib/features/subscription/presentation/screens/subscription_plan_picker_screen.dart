library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../providers/subscription_provider.dart';
import '../widgets/plan_card.dart';

class SubscriptionPlanPickerScreen extends ConsumerWidget {
  const SubscriptionPlanPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final notifier = ref.read(subscriptionProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.workspace_premium_rounded,
                size: 64,
                color: cs.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.choosePlan,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.choosePlanSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              PlanCard(
                title: l10n.planTrial,
                subtitle: l10n.planTrialDesc,
                badge: l10n.free,
                badgeColor: Colors.green,
                icon: Icons.star_rounded,
                highlighted: true,
                onTap: () => notifier.activateTrial(),
              ),
              const SizedBox(height: 12),
              PlanCard(
                title: l10n.planWeekly,
                subtitle: l10n.planWeeklyDesc,
                badge: l10n.contactAdmin,
                badgeColor: cs.primary,
                icon: Icons.calendar_view_week_rounded,
                highlighted: false,
                onTap: () => _contactAdmin(context),
              ),
              const SizedBox(height: 12),
              PlanCard(
                title: l10n.planMonthly,
                subtitle: l10n.planMonthlyDesc,
                badge: l10n.contactAdmin,
                badgeColor: cs.primary,
                icon: Icons.calendar_month_rounded,
                highlighted: false,
                onTap: () => _contactAdmin(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _contactAdmin(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.support_agent_rounded, size: 40),
        title: const Text('Contact Admin'),
        content: const Text(
          'To subscribe to a paid plan, contact your admin. '
          'They will activate your subscription manually.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
