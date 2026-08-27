import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/features/subscription/presentation/widgets/mutation_guard.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/core/widgets/app_snackbar.dart';
import '../../domain/entities/customer.dart';
import '../providers/customer_actions.dart';
import 'customer_form/customer_form_header.dart';
import 'customer_form/customer_form_shell.dart';
import 'customer_form/customer_name_phone_fields.dart';
import 'customer_form/customer_submit_button.dart';

/// Bottom sheet form for editing an existing customer.
void showEditCustomerSheet(
  BuildContext context,
  WidgetRef ref,
  Customer customer,
) {
  if (MutationGuard.checkBlocked(context, ref)) return;
  final l10n = AppLocalizations.of(context)!;
  final nameController = TextEditingController(text: customer.name);
  final phoneController = TextEditingController(text: customer.phone ?? '');
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _EditCustomerForm(
      l10n: l10n,
      nameController: nameController,
      phoneController: phoneController,
      formKey: formKey,
      onSave: () async {
        if (!formKey.currentState!.validate()) return;
        await updateCustomer(
          ProviderScope.containerOf(ctx),
          customer: customer,
          name: nameController.text.trim(),
          phone: phoneController.text.trim().isEmpty
              ? null
              : phoneController.text.trim(),
        );
        if (ctx.mounted) {
          Navigator.of(ctx).pop();
          showSuccessSnackBar(context, '${l10n.editCustomer} ✓');
        }
      },
    ),
  );
}

class _EditCustomerForm extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;

  const _EditCustomerForm({
    required this.l10n,
    required this.nameController,
    required this.phoneController,
    required this.formKey,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return CustomerFormShell(
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomerFormHeader(
              icon: Icons.edit_rounded,
              title: l10n.editCustomer,
              subtitle: l10n.phoneOptional,
            ),
            const SizedBox(height: 28),
            CustomerNamePhoneFields(
              l10n: l10n,
              nameController: nameController,
              phoneController: phoneController,
            ),
            const SizedBox(height: 32),
            CustomerSubmitButton(label: l10n.save, onPressed: onSave),
          ],
        ),
      ),
    );
  }
}
