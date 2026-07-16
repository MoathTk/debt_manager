import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/mutations.dart';
import '../Providers/database_provider.dart';
import '../features/subscription/presentation/widgets/mutation_guard.dart';
import 'amount_input_formatter.dart';
import 'app_snackbar.dart';
import 'debt_selector_tile.dart';

void showRecordPaymentSheet(
  BuildContext context,
  WidgetRef ref,
  String customerId,
) {
  if (MutationGuard.checkBlocked(context, ref)) return;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _Body(customerId: customerId),
  );
}

class _Body extends ConsumerStatefulWidget {
  final String customerId;
  const _Body({required this.customerId});
  @override
  ConsumerState<_Body> createState() => _S();
}

class _S extends ConsumerState<_Body> {
  String? _debtId;
  double _max = 0;
  final _amt = TextEditingController();
  final _note = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _amt.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_debtId == null) return;
    final v = parseAmount(_amt.text.trim());
    if (v == null || v <= 0) return;
    if (v > _max) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        showErrorSnackBar(context, l10n.amountCannotExceedRemaining);
      }
      return;
    }
    setState(() => _busy = true);
    await recordPayment(
      ProviderScope.containerOf(context),
      customerId: widget.customerId,
      amount: v,
      debtId: _debtId,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final debtsAsync = ref.watch(debtsWithRemainingProvider(widget.customerId));

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.35,
      maxChildSize: 0.9,
      expand: false,
      builder: (ctx, scrollCtrl) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            12,
            24,
            MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: ListView(
            controller: scrollCtrl,
            padding: EdgeInsets.zero,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  l10n.recordPayment,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  l10n.selectDebt,
                  style: TextStyle(
                    fontSize: 15,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              debtsAsync.when(
                data: (ds) {
                  if (ds.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noOutstandingDebts,
                            style: theme.textTheme.titleMedium,
                          ),
                          Text(
                            l10n.noOutstandingDebtsMessage,
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ...List.generate(ds.length, (i) {
                        final d = ds[i];
                        return DebtSelectorTile(
                          id: d['id'] as String,
                          amount: (d['amount'] as num).toDouble(),
                          remaining: (d['remaining'] as num).toDouble(),
                          note: d['note'] as String?,
                          isSelected: _debtId == d['id'],
                          onTap: () => setState(() {
                            _debtId = d['id'] as String;
                            _max = (d['remaining'] as num).toDouble();
                          }),
                        );
                      }),
                    ],
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
                error: (e, _) => Text('Error: $e'),
              ),
              if (_debtId != null) ...[
                const SizedBox(height: 20),
                _inp(_amt, '${l10n.amount} (max ${formatAmount(_max)})', true, true),
                const SizedBox(height: 14),
                _inp(_note, l10n.noteOptional),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _busy ? null : _save,
                    child: _busy
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          )
                        : Text(
                            l10n.save,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _inp(TextEditingController c, String label, [bool num = false, bool autofocus = false]) =>
      TextField(
        controller: c,
        autofocus: autofocus,
        keyboardType: num
            ? const TextInputType.numberWithOptions(decimal: true)
            : null,
        inputFormatters: num ? [ThousandsSeparatorInputFormatter()] : null,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
}
