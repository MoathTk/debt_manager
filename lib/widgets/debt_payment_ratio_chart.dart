import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';

class DebtPaymentRatioChart extends StatelessWidget {
  final double totalDebts;
  final double totalPayments;
  const DebtPaymentRatioChart({
    super.key,
    required this.totalDebts,
    required this.totalPayments,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final total = totalDebts + totalPayments;

    if (total == 0) return _empty(l10n, cs);

    final debtPct = totalDebts / total;
    final payPct = totalPayments / total;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 28,
                sections: [
                  PieChartSectionData(
                    value: debtPct,
                    color: const Color(0xFFE53935),
                    radius: 14,
                    title: '',
                  ),
                  PieChartSectionData(
                    value: payPct,
                    color: const Color(0xFF43A047),
                    radius: 14,
                    title: '',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _legend(l10n.debts, debtPct, const Color(0xFFE53935)),
                const SizedBox(height: 8),
                _legend(l10n.payments, payPct, const Color(0xFF43A047)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(String label, double pct, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label ${(pct * 100).toInt()}%',
          style: const TextStyle(fontSize: 13),
        ),
      ],
    );
  }

  Widget _empty(dynamic l10n, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Center(
        child: Text(
          l10n.noChartData,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}
