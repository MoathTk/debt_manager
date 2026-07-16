import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import '../Providers/mutations.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_transactions_list.dart';
import '../features/subscription/presentation/widgets/subscription_banner.dart';
import 'all_transactions_screen.dart';
import 'analytics_screen.dart';

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
        data: (s) => _body(context, l10n, s),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _body(BuildContext ctx, AppLocalizations l10n, DashboardStats s) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      //padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SubscriptionBanner(),
          const SizedBox(height: 8),
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
                numValue: s.totalDebts,
                color: const Color(0xFFE53935),
                compact: true,
              ),
              StatCard(
                icon: Icons.payments,
                label: l10n.totalPayments,
                numValue: s.totalPayments,
                color: const Color(0xFF43A047),
                compact: true,
              ),
              StatCard(
                icon: Icons.people,
                label: l10n.customers,
                numValue: s.customerCount.toDouble(),
                color: const Color(0xFF1E88E5),
              ),
              StatCard(
                icon: Icons.notifications_active,
                label: l10n.pendingReminders,
                numValue: s.pendingReminders.toDouble(),
                color: const Color(0xFFF9A825),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _analyticsCard(ctx, l10n, s),
          const SizedBox(height: 24),
          Container(
            margin: EdgeInsets.only(left: 3, right: 3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.recentTransactions,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 22),
                  onPressed: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                      builder: (_) => const AllTransactionsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const RecentTransactionsList(),
        ],
      ),
    );
  }

  Widget _analyticsCard(
    BuildContext ctx,
    AppLocalizations l10n,
    DashboardStats s,
  ) {
    final cs = Theme.of(ctx).colorScheme;
    final rate = (s.collectionRate * 100).clamp(0, 100).toInt();
    return GestureDetector(
      onTap: () => Navigator.push(
        ctx,
        MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
      ),
      child: Container(
        margin: EdgeInsets.only(left: 3,right: 3),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              cs.primaryContainer,
              cs.primaryContainer.withValues(alpha: 0.5),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.analytics_rounded, color: cs.primary, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.analytics,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    '${l10n.collectionRate}: $rate%',
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: cs.primary),
          ],
        ),
      ),
    );
  }
}
