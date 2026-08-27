import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/core/theme/app_colors.dart';
import 'package:local_debt_management/features/reminders/domain/entities/debt_reminder.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/core/sharedProviders/database_provider.dart';
import 'debt_detail_dialog.dart';
import 'package:local_debt_management/core/widgets/empty_state.dart';

String _fmt(double n) {
  final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
  return s.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

/// Bottom sheet listing every unpaid debt (remaining > 0) of a customer —
/// the debts that make up the balance shown on the [BalanceCard].
void showUnpaidDebtsSheet(
  BuildContext context,
  WidgetRef ref,
  String customerId,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _UnpaidDebtsBody(customerId: customerId),
  );
}

class _UnpaidDebtsBody extends ConsumerWidget {
  final String customerId;
  const _UnpaidDebtsBody({required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final debtsAsync = ref.watch(debtsWithRemainingProvider(customerId));
    final remindersAsync = ref.watch(remindersByCustomerProvider(customerId));

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                children: [
                  Text(
                    l10n.debts,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.remaining,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: debtsAsync.when(
                data: (debts) {
                  if (debts.isEmpty) {
                    return EmptyState(
                      icon: Icons.check_circle_rounded,
                      title: l10n.noOutstandingDebts,
                      message: l10n.noOutstandingDebtsMessage,
                    );
                  }
                  final rMap = <String, List<DebtReminder>>{};
                  remindersAsync.whenData((rs) {
                    for (final r in rs) {
                      final key = r.debtId ?? r.id;
                      (rMap[key] ??= []).add(r);
                    }
                  });
                  return ListView.separated(
                    controller: scrollCtrl,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: debts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (_, i) {
                      final d = debts[i];
                      final debtId = d['id'] as String;
                      final amount = (d['amount'] as num).toDouble();
                      final remaining = (d['remaining'] as num).toDouble();
                      return _UnpaidDebtTile(
                        amount: amount,
                        remaining: remaining,
                        note: d['note'] as String?,
                        date: d['date'] as String?,
                        reminders: rMap[debtId] ?? const [],
                        onTap: () => showDebtDetailDialog(
                          context,
                          debtId: debtId,
                          amount: amount,
                          remaining: remaining,
                          note: d['note'] as String?,
                          date: d['date'] as String?,
                          paid: amount - remaining,
                        ),
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

class _UnpaidDebtTile extends StatelessWidget {
  final double amount;
  final double remaining;
  final String? note;
  final String? date;
  final List<DebtReminder> reminders;
  final VoidCallback onTap;

  const _UnpaidDebtTile({
    required this.amount,
    required this.remaining,
    this.note,
    this.date,
    required this.reminders,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appColors = AppColors.of(context);

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: appColors.debtBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: appColors.debt,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _fmt(remaining),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: appColors.debt,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (amount != remaining)
                          Text(
                            _fmt(amount),
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.5),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                      ],
                    ),
                    if (note?.isNotEmpty == true) ...[
                      const SizedBox(height: 4),
                      Text(
                        note!,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (date != null && date!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            date!,
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (reminders.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final r in reminders)
                            _ReminderChip(
                              reminder: r,
                              color: appColors.reminder,
                              bg: appColors.reminderBg,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
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

class _ReminderChip extends StatelessWidget {
  final DebtReminder reminder;
  final Color color;
  final Color bg;
  const _ReminderChip({
    required this.reminder,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    final text = reminder.message?.isNotEmpty == true
        ? '${reminder.reminderDate.substring(0, 10)} · ${reminder.message}'
        : reminder.reminderDate.substring(0, 10);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            reminder.completed
                ? Icons.notifications_off_rounded
                : Icons.notifications_active_rounded,
            size: 13,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
