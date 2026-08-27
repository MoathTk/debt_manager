import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'customer_input_field.dart';

/// Name + phone input fields shared by the add/edit customer sheets.
class CustomerNamePhoneFields extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  const CustomerNamePhoneFields({
    super.key,
    required this.l10n,
    required this.nameController,
    required this.phoneController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomerInputField(
          controller: nameController,
          label: l10n.customerName,
          hint: 'Mohammed Ali',
          prefixIcon: Icons.person_outline_rounded,
          autofocus: true,
          textInputAction: TextInputAction.next,
          textCapitalization: TextCapitalization.words,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
        ),
        const SizedBox(height: 16),
        CustomerInputField(
          controller: phoneController,
          label: l10n.customerPhone,
          hint: '07XX XXX XXXX',
          prefixIcon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          validator: (v) {
            if (v == null || v.trim().isEmpty) return null;
            if (v.trim().length != 11) return l10n.phoneInvalid;
            return null;
          },
        ),
      ],
    );
  }
}
