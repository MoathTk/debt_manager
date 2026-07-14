import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import '../widgets/collection_progress_ring.dart';
import '../widgets/time_range_selector.dart';
import '../widgets/debt_payment_trend_chart.dart';
import '../widgets/monthly_breakdown_chart.dart';
import '../widgets/debt_payment_ratio_chart.dart';
import '../widgets/top_debtors_chart.dart';
import '../widgets/period_totals_section.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});
  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsState();
}

class _AnalyticsState extends ConsumerState<AnalyticsScreen> {
  bool _isWeekly = false;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final statsAsync = ref.watch(dashboardStatsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.analytics)),
      body: statsAsync.when(
        data: (s) => _body(l10n, s),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _body(AppLocalizations l10n, DashboardStats s) {
    final periodic = ref.watch(periodicDataProvider(_isWeekly));
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CollectionProgressRing(rate: s.collectionRate),
          const SizedBox(height: 20),
          const PeriodTotalsSection(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.monthlyTrend,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
              TimeRangeSelector(
                isWeekly: _isWeekly,
                onChanged: (v) => setState(() => _isWeekly = v),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // periodic.when(
          //   data: (d) => DebtPaymentTrendChart(data: d),
          //   loading: () => const SizedBox(
          //     height: 200,
          //     child: Center(child: CircularProgressIndicator()),
          //   ),
          //   error: (e, _) => Text('Error: $e'),
          // ),
          // const SizedBox(height: 16),
          // periodic.when(
          //   data: (d) => MonthlyBreakdownChart(data: d),
          //   loading: () => const SizedBox(height: 180),
          //   error: (_, __) => const SizedBox(),
          // ),
          // const SizedBox(height: 16),
          DebtPaymentRatioChart(
            totalDebts: s.totalDebts,
            totalPayments: s.totalPayments,
          ),
          const SizedBox(height: 16),
          const TopDebtorsChart(),
        ],
      ),
    );
  }
}
