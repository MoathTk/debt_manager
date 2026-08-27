import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/core/sharedProviders/database_provider.dart';
import 'package:local_debt_management/core/theme/app_colors.dart';
import 'package:local_debt_management/features/debts/domain/entities/transaction.dart'
    as model;
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'debt_detail_dialog.dart';
import 'debt_payment_history_dialog.dart';

class AllTransactionsTile extends ConsumerWidget {
  final model.Transaction transaction;
  final double? remaining;
  final VoidCallback? onTap;
  const AllTransactionsTile({
    super.key,
    required this.transaction,
    this.remaining,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final appColors = AppColors.of(context);
    final t = transaction;
    final isDebt = t.isDebt;
    final color = isDebt ? appColors.debt : appColors.payment;
    final bg = isDebt ? appColors.debtBg : appColors.paymentBg;
    final amt = t.amount % 1 == 0
        ? t.amount.toStringAsFixed(0)
        : t.amount.toStringAsFixed(2);
    final display = amt.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    final name =
        ref.watch(customerByIdProvider(t.customerId)).value?.name ?? '\u2014';

    final tile = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isDebt
                  ? Icons.arrow_upward_rounded
                  : Icons.arrow_downward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  isDebt ? l10n.debt : l10n.payment,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                if (t.note?.isNotEmpty == true)
                  Text(
                    t.note!,
                    style: TextStyle(fontSize: 11, color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                display,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                t.date.substring(0, 10),
                style: TextStyle(
                  fontSize: 11,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (!isDebt) {
      if (t.debtId == null) return tile;
      return GestureDetector(
        onTap: () async {
          final repo = ref.read(transactionRepositoryProvider);
          final debt = await repo.getById(t.debtId!);
          if (debt == null || !context.mounted) return;
          final paid = await repo.getPaymentsForDebt(t.debtId!);
          if (!context.mounted) return;
          showDebtPaymentHistoryDialog(
            context,
            debtId: t.debtId!,
            amount: debt.amount,
            remaining: debt.amount - paid,
            note: debt.note,
            date: debt.date,
            highlightPaymentId: t.id,
          );
        },
        child: tile,
      );
    }

    return GestureDetector(
      onTap:
          onTap ??
          () => showDebtDetailDialog(
            context,
            debtId: t.id,
            amount: t.amount,
            remaining: remaining ?? t.amount,
            paid: t.amount - (remaining ?? t.amount),
            note: t.note,
            date: t.date,
          ),
      child: tile,
    );
  }
}
