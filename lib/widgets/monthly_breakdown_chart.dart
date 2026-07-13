import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../l10n/app_localizations.dart';

class MonthlyBreakdownChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  const MonthlyBreakdownChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    if (data.isEmpty) return _empty(l10n, cs);

    final barGroups = <BarChartGroupData>[];
    for (var i = 0; i < data.length; i++) {
      final d = (data[i]['debts'] as num).toDouble();
      final p = (data[i]['payments'] as num).toDouble();
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: d,
              color: const Color(0xFFE53935),
              width: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
            BarChartRodData(
              toY: p,
              color: const Color(0xFF43A047),
              width: 12,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
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
            l10n.debts,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
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
                barGroups: barGroups,
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
