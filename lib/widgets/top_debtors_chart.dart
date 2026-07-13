import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Providers/database_provider.dart';
import '../l10n/app_localizations.dart';

class TopDebtorsChart extends ConsumerWidget {
  const TopDebtorsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final debtorsAsync = ref.watch(topDebtorsProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: debtorsAsync.when(
        data: (debtors) {
          if (debtors.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.noTopDebtors,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
              ),
            );
          }
          final maxVal = (debtors.first['outstanding'] as num).toDouble();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.topDebtors,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 12),
              for (final d in debtors)
                _Row(
                  name: d['name'] as String,
                  amount: (d['outstanding'] as num).toDouble(),
                  ratio: maxVal > 0
                      ? (d['outstanding'] as num).toDouble() / maxVal
                      : 0,
                ),
            ],
          );
        },
        loading: () => const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Text('Error: $e'),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String name;
  final double amount;
  final double ratio;
  const _Row({required this.name, required this.amount, required this.ratio});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatted = amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ),
              Text(
                formatted,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFE53935),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: cs.outlineVariant.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFE53935)),
            ),
          ),
        ],
      ),
    );
  }
}
