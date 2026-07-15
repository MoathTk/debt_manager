import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import '../Providers/mutations.dart';
import '../data/models/debt_reminder.dart';
import '../data/models/transaction.dart' as model;
import 'reminder_action_btn.dart';

String _fmt(double n) {
  final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
  return s.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

class ReminderCard extends ConsumerWidget {
  final DebtReminder reminder;
  final Color accent;
  final VoidCallback onTap;
  const ReminderCard({
    super.key,
    required this.reminder,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final nameAsync = ref.watch(customerByIdProvider(reminder.customerId));
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: dark
              ? cs.surfaceContainerHighest.withValues(alpha: 0.6)
              : cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: dark ? 0.15 : 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              PositionedDirectional(
                end: 0,
                top: 0,
                bottom: 0,
                width: 4,
                child: Container(color: accent),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          nameAsync.when(
                            data: (c) => Text(
                              c?.name ?? '—',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: cs.onSurface,
                                letterSpacing: -0.2,
                              ),
                            ),
                            loading: () =>
                                const SizedBox(height: 18, width: 60),
                            error: (_, __) => const Text('—'),
                          ),
                          if (reminder.message != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              reminder.message!,
                              style: TextStyle(
                                fontSize: 13,
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                          const SizedBox(height: 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: accent.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  _dateText(l10n),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: accent,
                                  ),
                                ),
                              ),

                              if (reminder.debtId != null) ...[
                                const SizedBox(width: 6, height: 4),
                                _AmountChip(debtId: reminder.debtId!),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!reminder.completed)
                      ReminderActionBtn(
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF43A047),
                        onTap: () => _confirmToggle(context, l10n),
                      ),
                    if (!reminder.completed)
                      const SizedBox(width: 8),
                    ReminderActionBtn(
                      icon: Icons.delete_outline_rounded,
                      color: cs.error,
                      onTap: () => _confirmDelete(context, l10n),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dateText(AppLocalizations l10n) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final rd = DateTime.parse(reminder.reminderDate);
    final diff = today.difference(DateTime(rd.year, rd.month, rd.day)).inDays;
    final d = '${rd.day}/${rd.month}/${rd.year}';
    if (diff == 0) return '$d  ·  ${l10n.dueToday}';
    if (diff > 0) return '$d  ·  $diff ${l10n.daysOverdue}';
    return '$d  ·  ${-diff} ${l10n.daysUntilDue}';
  }

  void _confirmToggle(BuildContext ctx, AppLocalizations l10n) {
    final msg = reminder.completed
        ? l10n.confirmMarkPending
        : l10n.confirmMarkCompleted;
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(l10n.markCompleted),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final container = ProviderScope.containerOf(ctx);
              reminder.completed
                  ? markReminderPending(container, reminder.id)
                  : markReminderCompleted(container, reminder.id,l10n.autoSettledViaReminder);
            },
            child: Text(l10n.yes),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, AppLocalizations l10n) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(l10n.deleteReminder),
        content: Text(l10n.confirmDeleteReminder),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              deleteReminder(ProviderScope.containerOf(ctx), reminder.id);
            },
            child: Text(
              l10n.yes,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountChip extends ConsumerWidget {
  final String debtId;
  const _AmountChip({required this.debtId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return FutureBuilder<model.Transaction?>(
      future: ref.read(transactionRepositoryProvider).getById(debtId),
      builder: (ctx, snap) {
        if (!snap.hasData || snap.data == null) return const SizedBox();
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: cs.primaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _fmt(snap.data!.amount),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        );
      },
    );
  }
}
