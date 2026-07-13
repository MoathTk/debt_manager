import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import 'period_chips.dart';
import 'period_navigator.dart';
import 'period_mini_card.dart';
import 'period_date_helper.dart';

class PeriodTotalsSection extends ConsumerStatefulWidget {
  const PeriodTotalsSection({super.key});

  @override
  ConsumerState<PeriodTotalsSection> createState() => _PeriodTotalsState();
}

class _PeriodTotalsState extends ConsumerState<PeriodTotalsSection> {
  PeriodType _type = PeriodType.month;
  DateTime _ref = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final range = PeriodHelper.dateRange(_type, _ref);
    final key =
        '${range.start.toIso8601String()}|${range.end.toIso8601String()}';
    final totalsAsync = ref.watch(totalsByDateRangeProvider(key));
    final current = PeriodHelper.isCurrent(_type, _ref);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.periodTotals,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        PeriodChips(
          selected: _type,
          onChanged: (t) => setState(() {
            _type = t;
            _ref = DateTime.now();
          }),
        ),
        const SizedBox(height: 10),
        PeriodNavigator(
          label: PeriodHelper.label(_type, _ref, l10n),
          subtitle: current ? l10n.currentPeriod : null,
          onBack: () =>
              setState(() => _ref = PeriodHelper.shift(_type, _ref, -1)),
          onForward: () =>
              setState(() => _ref = PeriodHelper.shift(_type, _ref, 1)),
          onToday: current ? null : () => setState(() => _ref = DateTime.now()),
        ),
        const SizedBox(height: 12),
        totalsAsync.when(
          data: (t) => Row(
            children: [
              Expanded(
                child: PeriodMiniCard(
                  label: l10n.periodDebts,
                  value: t['debts']!,
                  color: const Color(0xFFE53935),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PeriodMiniCard(
                  label: l10n.periodPayments,
                  value: t['payments']!,
                  color: const Color(0xFF43A047),
                ),
              ),
            ],
          ),
          loading: () => const SizedBox(
            height: 70,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Text('Error: $e'),
        ),
      ],
    );
  }
}
