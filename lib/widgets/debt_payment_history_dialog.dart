/// DEBT PAYMENT HISTORY DIALOG
///
/// Shows all payments made against a specific debt in chronological order.
/// Displays date, amount paid, and running remaining balance for each payment.
///
/// Usage: showDebtPaymentHistoryDialog(context, debtId: '...', amount: 50000, ...)
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/core/theme/app_colors.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/Providers/database_provider.dart';
import 'package:local_debt_management/data/models/transaction.dart';

String _fmt(double n) {
  final s = n % 1 == 0 ? n.toStringAsFixed(0) : n.toStringAsFixed(2);
  return s.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

Future<void> showDebtPaymentHistoryDialog(
  BuildContext context, {
  required String debtId,
  required double amount,
  required double remaining,
  String? note,
  String? date,
  String? highlightPaymentId,
}) {
  return showDialog(
    context: context,
    builder: (_) => DebtPaymentHistoryDialog(
      debtId: debtId,
      amount: amount,
      remaining: remaining,
      note: note,
      date: date,
      highlightPaymentId: highlightPaymentId,
    ),
  );
}

class DebtPaymentHistoryDialog extends ConsumerWidget {
  final String debtId;
  final double amount;
  final double remaining;
  final String? note;
  final String? date;
  final String? highlightPaymentId;
  const DebtPaymentHistoryDialog({
    super.key,
    required this.debtId,
    required this.amount,
    required this.remaining,
    this.note,
    this.date,
    this.highlightPaymentId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final appColors = AppColors.of(context);
    final l10n = AppLocalizations.of(context)!;
    final paymentsAsync = ref.watch(paymentsByDebtProvider(debtId));
    final paid = amount - remaining;
    final isFullyPaid = remaining <= 0;

    return Dialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Header(l10n: l10n, cs: cs),
            _Summary(
              amount: amount,
              paid: paid,
              remaining: remaining,
              isFullyPaid: isFullyPaid,
              cs: cs,
              appColors: appColors,
              l10n: l10n,
            ),
            const SizedBox(height: 4),
            Flexible(
              child: paymentsAsync.when(
                data: (payments) {
                  if (payments.isEmpty) {
                    return _Empty(l10n: l10n, cs: cs);
                  }
                  return _PaymentList(
                    payments: payments,
                    totalAmount: amount,
                    highlightPaymentId: highlightPaymentId,
                    cs: cs,
                    appColors: appColors,
                    l10n: l10n,
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('Error: $e'),
                ),
              ),
            ),
            _CloseButton(l10n: l10n, cs: cs),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _Header({required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.payments_rounded, size: 20, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              l10n.paymentHistory,
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
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final double amount;
  final double paid;
  final double remaining;
  final bool isFullyPaid;
  final ColorScheme cs;
  final AppColors appColors;
  final AppLocalizations l10n;
  const _Summary({
    required this.amount,
    required this.paid,
    required this.remaining,
    required this.isFullyPaid,
    required this.cs,
    required this.appColors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: (isFullyPaid ? appColors.payment : cs.error)
              .withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (isFullyPaid ? appColors.payment : cs.error)
                .withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _SummaryItem(
                label: l10n.originalAmount,
                value: _fmt(amount),
                color: cs.onSurface,
                l10n: l10n,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: cs.outlineVariant.withValues(alpha: 0.3),
            ),
            Expanded(
              child: _SummaryItem(
                label: l10n.amountPaid,
                value: _fmt(paid),
                color: appColors.payment,
                l10n: l10n,
              ),
            ),
            Container(
              width: 1,
              height: 36,
              color: cs.outlineVariant.withValues(alpha: 0.3),
            ),
            Expanded(
              child: _SummaryItem(
                label: l10n.remainingAmount,
                value: _fmt(remaining > 0 ? remaining : 0),
                color: remaining > 0 ? cs.error : appColors.payment,
                l10n: l10n,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final AppLocalizations l10n;
  const _SummaryItem({
    required this.label,
    required this.value,
    required this.color,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _PaymentList extends StatefulWidget {
  final List<Transaction> payments;
  final double totalAmount;
  final String? highlightPaymentId;
  final ColorScheme cs;
  final AppColors appColors;
  final AppLocalizations l10n;
  const _PaymentList({
    required this.payments,
    required this.totalAmount,
    this.highlightPaymentId,
    required this.cs,
    required this.appColors,
    required this.l10n,
  });

  @override
  State<_PaymentList> createState() => _PaymentListState();
}

class _PaymentListState extends State<_PaymentList> {
  final _scrollCtrl = ScrollController();
  final _highlightKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.highlightPaymentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToHighlight());
    }
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToHighlight() {
    if (!_highlightKey.currentContext!.mounted) return;
    Scrollable.ensureVisible(
      _highlightKey.currentContext!,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
      itemCount: widget.payments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, i) {
        final txn = widget.payments[i];
        double runningRemaining = widget.totalAmount;
        for (final p in widget.payments) {
          if (p.date.compareTo(txn.date) <= 0) {
            runningRemaining -= p.amount;
          }
        }
        final isHighlighted = txn.id == widget.highlightPaymentId;
        return _PaymentRow(
          key: isHighlighted ? _highlightKey : null,
          payment: txn,
          remaining: runningRemaining,
          isFirst: i == 0,
          isLast: i == widget.payments.length - 1,
          isHighlighted: isHighlighted,
          cs: widget.cs,
          appColors: widget.appColors,
          l10n: widget.l10n,
        );
      },
    );
  }
}

class _PaymentRow extends StatelessWidget {
  final Transaction payment;
  final double remaining;
  final bool isFirst;
  final bool isLast;
  final bool isHighlighted;
  final ColorScheme cs;
  final AppColors appColors;
  final AppLocalizations l10n;
  const _PaymentRow({
    super.key,
    required this.payment,
    required this.remaining,
    required this.isFirst,
    required this.isLast,
    this.isHighlighted = false,
    required this.cs,
    required this.appColors,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = payment.date.length >= 10
        ? payment.date.substring(0, 10)
        : payment.date;
    final isSettled = remaining <= 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted
            ? cs.error.withValues(alpha: 0.08)
            : cs.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: isHighlighted
            ? Border.all(color: cs.error.withValues(alpha: 0.4), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          if (isHighlighted) ...[
            Icon(Icons.arrow_right_rounded, size: 22, color: cs.error),
            const SizedBox(width: 4),
          ],
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? cs.error.withValues(alpha: 0.12)
                  : appColors.payment.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isHighlighted ? Icons.arrow_right_rounded : Icons.check_rounded,
              size: 16,
              color: isHighlighted ? cs.error : appColors.payment,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                if (payment.note?.isNotEmpty == true)
                  Text(
                    payment.note!,
                    style: TextStyle(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
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
                '-${_fmt(payment.amount)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isHighlighted ? cs.error : appColors.payment,
                ),
              ),
              Text(
                '${l10n.remaining}: ${_fmt(remaining > 0 ? remaining : 0)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isSettled
                      ? appColors.payment
                      : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _Empty({required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.noPaymentsYet,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  const _CloseButton({required this.l10n, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: SizedBox(
        width: double.infinity,
        height: 44,
        child: FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          style: FilledButton.styleFrom(
            backgroundColor: cs.surfaceContainerHighest,
            foregroundColor: cs.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            MaterialLocalizations.of(context).closeButtonLabel,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}
