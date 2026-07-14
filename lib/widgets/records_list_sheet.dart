import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../data/models/transaction.dart' as model;
import '../Providers/database_provider.dart';
import 'edit_debt_sheet.dart';
import 'edit_payment_sheet.dart';

void showRecordsListSheet(BuildContext context, WidgetRef ref, String customerId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _RecordsListBody(customerId: customerId),
  );
}

class _RecordsListBody extends ConsumerWidget {
  final String customerId;
  const _RecordsListBody({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final txnsAsync = ref.watch(transactionsByCustomerProvider(customerId));
    final debtsAsync = ref.watch(debtsWithRemainingProvider(customerId));

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return Column(
          children: [
            _Handle(theme: theme),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Text(
                loc.editRecords,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(
              child: txnsAsync.when(
                data: (txns) {
                  if (txns.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            loc.noTransactionsForCustomer,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  final rMap = <String, double>{};
                  debtsAsync.whenData((ds) {
                    for (final d in ds) {
                      rMap[d['id'] as String] = (d['remaining'] as num).toDouble();
                    }
                  });
                  return ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: txns.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final txn = txns[i];
                      return _RecordTile(
                        transaction: txn,
                        remaining: txn.isDebt ? rMap[txn.id] : null,
                        onTap: () {
                          Navigator.pop(context);
                          if (txn.isDebt) {
                            showEditDebtSheet(context, ref, txn);
                          } else {
                            showEditPaymentSheet(context, ref, txn);
                          }
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  final ThemeData theme;
  const _Handle({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  final model.Transaction transaction;
  final double? remaining;
  final VoidCallback onTap;
  const _RecordTile({
    required this.transaction,
    this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final isDebt = transaction.isDebt;
    final color = isDebt ? theme.colorScheme.error : const Color(0xFF2E7D32);
    final bg = isDebt
        ? theme.colorScheme.errorContainer
        : const Color(0xFFE8F5E9);
    final formatted = transaction.amount % 1 == 0
        ? transaction.amount.toStringAsFixed(0)
        : transaction.amount.toStringAsFixed(2);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDebt ? loc.debt : loc.payment,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    if (remaining != null && isDebt)
                      Text(
                        '${loc.remaining}: $formatted',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (transaction.note?.isNotEmpty == true)
                      Text(
                        transaction.note!,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatted,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  Text(
                    transaction.date.substring(0, 10),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.4,
                ),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
