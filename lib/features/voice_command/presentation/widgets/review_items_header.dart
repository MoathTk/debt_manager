/// REVIEW SUB-WIDGETS — ItemsHeader, ItemCard
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/core/theme/app_colors.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/features/debts/presentation/widgets/amount_input_formatter.dart';
import '../../domain/entities/voice_command.dart';

class ItemsHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final int count;
  const ItemsHeader({
    super.key,
    required this.l10n,
    required this.cs,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    return Row(
      children: [
        Icon(Icons.receipt_long_rounded, size: 14, color: appColors.gold),
        const SizedBox(width: 6),
        Text(
          '${l10n.parsedItems} ($count)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: appColors.gold,
          ),
        ),
      ],
    );
  }
}

class ItemCard extends StatelessWidget {
  final int index;
  final VoiceCommandItem item;
  final ColorScheme cs;
  final AppLocalizations l10n;
  final ValueChanged<int> onRemove;
  const ItemCard({
    super.key,
    required this.index,
    required this.item,
    required this.cs,
    required this.l10n,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = AppColors.of(context);
    return Dismissible(
      key: ValueKey('item_$index'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onRemove(index),
      background: Container(
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: appColors.debt.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: appColors.goldLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: appColors.gold.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Icon(Icons.label_rounded, size: 16, color: appColors.gold),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
            Text(
              formatAmount(item.amount),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: appColors.goldDark,
              ),
            ),
            const SizedBox(width: 6),
            Semantics(
              label: l10n.deleteDebt,
              button: true,
              child: GestureDetector(
                onTap: () => onRemove(index),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: appColors.debt.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
