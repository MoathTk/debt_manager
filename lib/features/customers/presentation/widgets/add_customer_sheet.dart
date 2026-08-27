import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/features/subscription/presentation/widgets/mutation_guard.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/core/widgets/app_snackbar.dart';
import '../../domain/entities/customer.dart';
import '../providers/customer_actions.dart';
import '../providers/customer_providers.dart';
import 'customer_form/customer_form_header.dart';
import 'customer_form/customer_form_shell.dart';
import 'customer_form/customer_name_phone_fields.dart';
import 'customer_form/customer_submit_button.dart';

/// Bottom sheet form for adding a new customer.
///
/// When [onCustomerAdded] is provided, it is called with the newly created
/// [Customer] after save (instead of showing a snackbar). This allows callers
/// to react to the new customer (e.g., auto-select it).
void showAddCustomerSheet(
  BuildContext context,
  WidgetRef ref, {
  ValueChanged<Customer>? onCustomerAdded,
}) {
  if (MutationGuard.checkBlocked(context, ref)) return;
  final l10n = AppLocalizations.of(context)!;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _AddCustomerForm(
      l10n: l10n,
      nameController: nameController,
      phoneController: phoneController,
      formKey: formKey,
      onSave: () async {
        if (!formKey.currentState!.validate()) return;
        final name = nameController.text.trim();
        final phone = phoneController.text.trim();
        final container = ProviderScope.containerOf(ctx);
        await addCustomer(
          container,
          name: name,
          phone: phone.isEmpty ? null : phone,
        );
        if (ctx.mounted) {
          Navigator.of(ctx).pop();
          if (onCustomerAdded != null) {
            final repo = container.read(customerRepositoryProvider);
            final results = await repo.search(name);
            if (results.isNotEmpty) onCustomerAdded(results.first);
          } else {
            showSuccessSnackBar(context, '${l10n.addCustomer} ✓');
          }
        }
      },
    ),
  );
}

class _AddCustomerForm extends StatelessWidget {
  final AppLocalizations l10n;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final GlobalKey<FormState> formKey;
  final VoidCallback onSave;

  const _AddCustomerForm({
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
              icon: Icons.person_add_rounded,
              title: l10n.addCustomer,
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
