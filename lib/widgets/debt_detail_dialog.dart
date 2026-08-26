/// REUSABLE DEBT DETAIL DIALOG
///
/// Shows comprehensive debt information: original amount, paid, remaining,
/// date, note, and a visual progress bar. Usable across the entire app.
///
/// Usage: showDebtDetailDialog(context, debtId: '...', amount: 50000, ...)
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/core/theme/app_colors.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'debt_payment_history_dialog.dart';

String _fmt(double n) {
  final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
  return s.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

/// Shows a modern debt detail dialog. Call from anywhere in the app.
Future<void> showDebtDetailDialog(
  BuildContext context, {
  required String debtId,
  required double amount,
  required double remaining,
  String? note,
  String? date,
  double paid = 0,
}) {
  return showDialog(
    context: context,
    builder: (_) => DebtDetailDialog(
      debtId: debtId,
      amount: amount,
      remaining: remaining,
      note: note,
      date: date,
      paid: paid,
    ),
  );
}

class DebtDetailDialog extends StatelessWidget {
  final String debtId;
  final double amount;
  final double remaining;
  final String? note;
  final String? date;
  final double paid;
  const DebtDetailDialog({
    super.key,
    required this.debtId,
    required this.amount,
    required this.remaining,
    this.note,
    this.date,
    this.paid = 0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final appColors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final progress = amount > 0 ? ((amount - remaining) / amount).clamp(0.0, 1.0) : 0.0;
    final isFullyPaid = remaining <= 0;

    return Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DialogHeader(l10n: l10n, cs: cs),
              const SizedBox(height: 20),
              _AmountCard(
                amount: amount,
                remaining: remaining,
                paid: paid,
                isFullyPaid: isFullyPaid,
                cs: cs,
                appColors: appColors,
                l10n: l10n,
              ),
              const SizedBox(height: 16),
              _ProgressBar(
                progress: progress,
                isFullyPaid: isFullyPaid,
                cs: cs,
                appColors: appColors,
                l10n: l10n,
              ),
              if (note != null && note!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.notes_rounded,
                  label: l10n.note,
                  value: note!,
                  cs: cs,
                ),
              ],
              if (date != null && date!.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.calendar_today_rounded,
                  label: l10n.dateLabel,
                  value: date!,
                  cs: cs,
                ),
              ],
              const SizedBox(height: 16),
              Semantics(
                label: l10n.paymentHistory,
                button: true,
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDebtPaymentHistoryDialog(
                        context,
                        debtId: debtId,
                        amount: amount,
                        remaining: remaining,
                        note: note,
                        date: date,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.payments_rounded, size: 18),
                    label: Text(l10n.paymentHistory),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _CloseButton(l10n: l10n, cs: cs),
            ],
          ),
        ),
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _DialogHeader({required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: cs.errorContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.receipt_long_rounded, size: 20, color: cs.error),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            l10n.debtDetails,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
        ),
        Semantics(
          label: MaterialLocalizations.of(context).closeButtonTooltip,
          button: true,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close_rounded, size: 18, color: cs.onSurfaceVariant),
            ),
          ),
        ),
      ],
    );
  }
}

class _AmountCard extends StatelessWidget {
  final double amount;
  final double remaining;
  final double paid;
  final bool isFullyPaid;
  final ColorScheme cs;
  final AppColors appColors;
  final AppLocalizations l10n;
  const _AmountCard({
    required this.amount,
    required this.remaining,
    required this.paid,
    required this.isFullyPaid,
    required this.cs,
    required this.appColors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isFullyPaid ? appColors.payment : cs.error;
    final statusBg = isFullyPaid ? appColors.paymentBg : cs.errorContainer;
    final statusLabel = isFullyPaid ? l10n.settled : l10n.owes;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.originalAmount,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  statusLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: statusColor,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _fmt(amount),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: l10n.amountPaid,
                  value: _fmt(paid),
                  color: appColors.payment,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: cs.outlineVariant.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _MiniStat(
                  label: l10n.remainingAmount,
                  value: _fmt(remaining > 0 ? remaining : 0),
                  color: remaining > 0 ? cs.error : appColors.payment,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MiniStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final bool isFullyPaid;
  final ColorScheme cs;
  final AppColors appColors;
  final AppLocalizations l10n;
  const _ProgressBar({
    required this.progress,
    required this.isFullyPaid,
    required this.cs,
    required this.appColors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final color = isFullyPaid ? appColors.payment : cs.error;
    final percentage = (progress * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.paid,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
            Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: cs.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: cs.onSurface,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _CloseButton extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _CloseButton({required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: () => Navigator.of(context).pop(),
        style: FilledButton.styleFrom(
          backgroundColor: cs.surfaceContainerHighest,
          foregroundColor: cs.onSurface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(
          MaterialLocalizations.of(context).closeButtonLabel,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
