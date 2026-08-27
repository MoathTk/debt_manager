/// REVIEW SUB-WIDGETS — TotalSection, DueRow
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_debt_management/core/theme/app_colors.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/features/debts/presentation/widgets/amount_input_formatter.dart';

class TotalSection extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final double total;
  const TotalSection({
    super.key,
    required this.l10n,
    required this.cs,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: appColors.debt.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: appColors.debt.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.total,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: appColors.debt,
            ),
          ),
          Text(
            formatAmount(total),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: appColors.debt,
            ),
          ),
        ],
      ),
    );
  }
}

class DueRow extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final DateTime date;
  const DueRow({
    super.key,
    required this.l10n,
    required this.cs,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    final locale = Localizations.localeOf(context);
    final formattedDate = DateFormat.yMMMd(locale.languageCode).format(date);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: appColors.customer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: appColors.customer.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: appColors.customer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: appColors.customer,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.due.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: appColors.customer,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
