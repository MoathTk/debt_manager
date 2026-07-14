import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../data/models/transaction.dart' as model;
import '../Providers/database_provider.dart';
import '../data/models/debt_reminder.dart';
import 'info_row.dart';

String fmt(double n) {
  final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
  return s.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

class ReminderDetailInfo extends StatelessWidget {
  final DebtReminder reminder;
  final model.Transaction? debtTxn;
  final double debtPaid;
  const ReminderDetailInfo({
    super.key,
    required this.reminder,
    this.debtTxn,
    this.debtPaid = 0,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final r = reminder;
    final nameAsync = ProviderScope.containerOf(
      context,
    ).read(customerByIdProvider(r.customerId));
    final rd = DateTime.parse(r.reminderDate);
    final dateStr = '${rd.day}/${rd.month}/${rd.year}';
    final remaining = debtTxn != null ? debtTxn!.amount - debtPaid : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InfoRow(
          label: l10n.customerName,
          child: nameAsync.when(
            data: (c) => Text(
              c?.name ?? '—',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            loading: () => const CircularProgressIndicator(strokeWidth: 2),
            error: (_, __) => const Text('—'),
          ),
        ),
        if (debtTxn != null) ...[
          InfoRow(
            label: l10n.amount,
            child: Text(
              fmt(debtTxn!.amount),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
          if (debtPaid > 0)
            InfoRow(
              label: l10n.paid,
              child: Text(
                fmt(debtPaid),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),
          if (remaining > 0)
            InfoRow(
              label: l10n.remaining,
              child: Text(
                fmt(remaining),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: cs.error,
                ),
              ),
            ),
        ],
        InfoRow(
          label: l10n.reminderDate,
          child: Text(
            dateStr,
            style: TextStyle(fontSize: 15, color: cs.onSurface),
          ),
        ),
        if (r.message != null)
          InfoRow(
            label: l10n.note,
            child: Text(
              r.message!,
              style: TextStyle(fontSize: 15, color: cs.onSurface),
            ),
          ),
      ],
    );
  }
}
