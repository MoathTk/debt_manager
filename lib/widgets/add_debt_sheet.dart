import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/mutations.dart';
import 'amount_input_formatter.dart';
import 'reminder_date_picker.dart';

/// Bottom sheet for adding a new debt (pure addition, no linking).
void showAddDebtSheet(BuildContext context, WidgetRef ref, String customerId) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AddDebtBody(customerId: customerId),
  );
}

class _AddDebtBody extends ConsumerStatefulWidget {
  final String customerId;
  const _AddDebtBody({required this.customerId});
  @override
  ConsumerState<_AddDebtBody> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_AddDebtBody> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;
  DateTime? _reminderDate;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final val = parseAmount(_amount.text.trim());
    if (val == null || val <= 0) return;
    setState(() => _saving = true);
    await addDebt(
      ref,
      customerId: widget.customerId,
      amount: val,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      reminderDate: _reminderDate,
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(theme),
            const SizedBox(height: 20),
            Text(
              l10n.addDebt,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 24),
            _Field(
              ctrl: _amount,
              label: l10n.amount,
              decimal: true,
              autofocus: true,
              formatters: [ThousandsSeparatorInputFormatter()],
            ),
            const SizedBox(height: 16),
            _Field(ctrl: _note, label: l10n.noteOptional),
            const SizedBox(height: 16),
            ReminderDatePicker(
              selectedDate: _reminderDate,
              onDateChanged: (d) => setState(() => _reminderDate = d),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
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
          ],
        ),
      ),
    );
  }

  Widget _handle(ThemeData theme) => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool decimal;
  final bool autofocus;
  final List<TextInputFormatter>? formatters;
  const _Field({
    required this.ctrl,
    required this.label,
    this.decimal = false,
    this.autofocus = false,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      autofocus: autofocus,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      inputFormatters: formatters,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
