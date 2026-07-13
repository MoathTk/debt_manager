import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_transactions_list.dart';

/// Dashboard screen showing business overview statistics.
///
/// Displays a 2x2 grid of stat cards and recent transactions.
/// Pull-to-refresh supported for quick data refresh.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);
    final l10n = AppLocalizations.of(context)!;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dashboardStatsProvider);
        ref.invalidate(transactionsProvider);
      },
      child: statsAsync.when(
        data: (stats) => _DashboardContent(stats: stats, l10n: l10n),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

/// Content builder for the dashboard when stats are loaded.
class _DashboardContent extends StatelessWidget {
  final DashboardStats stats;
  final AppLocalizations l10n;

  const _DashboardContent({required this.stats, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.0,
            children: [
              StatCard(
                icon: Icons.money_off,
                label: l10n.totalDebts,
                numValue: stats.totalDebts,
                color: const Color(0xFFE53935),
              ),
              StatCard(
                icon: Icons.payments,
                label: l10n.totalPayments,
                numValue: stats.totalPayments,
                color: const Color(0xFF43A047),
              ),
              StatCard(
                icon: Icons.people,
                label: l10n.customers,
                numValue: stats.customerCount.toDouble(),
                color: const Color(0xFF1E88E5),
              ),
              StatCard(
                icon: Icons.notifications_active,
                label: l10n.pendingReminders,
                numValue: stats.pendingReminders.toDouble(),
                color: const Color(0xFFF9A825),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.recentTransactions,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const RecentTransactionsList(),
        ],
      ),
    );
  }
}
