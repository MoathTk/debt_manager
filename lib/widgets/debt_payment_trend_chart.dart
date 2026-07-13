import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';

class DebtPaymentTrendChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const DebtPaymentTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    if (data.isEmpty) return _empty(l10n, cs);

    final debtSpots = <FlSpot>[];
    final paySpots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      debtSpots.add(FlSpot(i.toDouble(), (data[i]['debts'] as num).toDouble()));
      paySpots.add(
        FlSpot(i.toDouble(), (data[i]['payments'] as num).toDouble()),
      );
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.monthlyTrend,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          _Legend(l10n: l10n),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= data.length) return const SizedBox();
                        return Text(
                          data[i]['label'].toString(),
                          style: TextStyle(
                            fontSize: 10,
                            color: cs.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: debtSpots,
                    isCurved: true,
                    color: const Color(0xFFE53935),
                    barWidth: 2.5,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFE53935).withValues(alpha: 0.08),
                    ),
                  ),
                  LineChartBarData(
                    spots: paySpots,
                    isCurved: true,
                    color: const Color(0xFF43A047),
                    barWidth: 2.5,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF43A047).withValues(alpha: 0.08),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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

class _Legend extends StatelessWidget {
  final dynamic l10n;
  const _Legend({required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _dot(const Color(0xFFE53935), l10n.debts),
        const SizedBox(width: 16),
        _dot(const Color(0xFF43A047), l10n.payments),
      ],
    );
  }

  Widget _dot(Color c, String t) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(t, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}
