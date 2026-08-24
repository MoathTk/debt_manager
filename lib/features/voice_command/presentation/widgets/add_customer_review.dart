/// VOICE COMMAND FEATURE — PRESENTATION LAYER: ADD CUSTOMER REVIEW
///
/// Review screen for "add_customer" voice commands.
/// Shows parsed customer name, optional phone, and confirm/re-record actions.
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import '../../domain/entities/voice_command.dart';

class AddCustomerReview extends StatefulWidget {
  final VoiceCommand command;
  final ValueChanged<VoiceCommand> onConfirm;
  final VoidCallback onReRecord;
  const AddCustomerReview({
    super.key,
    required this.command,
    required this.onConfirm,
    required this.onReRecord,
  });

  @override
  State<AddCustomerReview> createState() => _AddCustomerReviewState();
}

class _AddCustomerReviewState extends State<AddCustomerReview> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.command.customerName);
    _phoneController = TextEditingController(text: widget.command.phone ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.tertiary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Header(l10n: l10n, cs: cs),
          const SizedBox(height: 12),
          _NameField(l10n: l10n, cs: cs, controller: _nameController),
          const SizedBox(height: 10),
          _PhoneField(
            l10n: l10n,
            cs: cs,
            controller: _phoneController,
          ),
          const SizedBox(height: 12),
          _Actions(
            l10n: l10n,
            onReRecord: widget.onReRecord,
            onConfirm: () {
              final cmd = widget.command.copyWith(
                customerName: _nameController.text.trim(),
                phone: _phoneController.text.trim().isEmpty
                    ? null
                    : _phoneController.text.trim(),
              );
              widget.onConfirm(cmd);
            },
          ),
        ],
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
    return Row(
      children: [
        Icon(Icons.person_add_rounded, size: 16, color: cs.tertiary),
        const SizedBox(width: 6),
        Text(
          l10n.addCustomer,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.tertiary,
          ),
        ),
      ],
    );
  }
}

class _NameField extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final TextEditingController controller;
  const _NameField({
    required this.l10n,
    required this.cs,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: l10n.customerName,
        prefixIcon: const Icon(Icons.person_rounded, size: 18),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.tertiary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _PhoneField extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final TextEditingController controller;
  const _PhoneField({
    required this.l10n,
    required this.cs,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.phone,
      maxLength: 11,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        counterText: '',
        labelText: l10n.customerPhone,
        prefixIcon: const Icon(Icons.phone_rounded, size: 18),
        filled: true,
        fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: cs.tertiary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onReRecord;
  final VoidCallback onConfirm;
  const _Actions({
    required this.l10n,
    required this.onReRecord,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label: l10n.reRecord,
          button: true,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onReRecord,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.mic_rounded, size: 18),
              label: Text(l10n.reRecord),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: l10n.confirmAndSave,
          button: true,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(l10n.confirmAndSave),
            ),
          ),
        ),
      ],
    );
  }
}
