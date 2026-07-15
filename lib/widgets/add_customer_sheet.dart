import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/mutations.dart';
import 'app_snackbar.dart';

/// Modern bottom sheet form for adding a new customer.
///
/// Features filled input fields, smooth animations, and clear hierarchy.
/// Designed for quick, effortless customer creation.
void showAddCustomerSheet(BuildContext context, WidgetRef ref) {
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
        await addCustomer(
          ProviderScope.containerOf(ctx),
          name: nameController.text.trim(),
          phone: phoneController.text.trim().isEmpty
              ? null
              : phoneController.text.trim(),
        );
        if (ctx.mounted) {
          Navigator.of(ctx).pop();
          showSuccessSnackBar(context, '${l10n.addCustomer} ✓');
        }
      },
    ),
  );
}

/// The form widget extracted for clean code and proper context access.
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
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPadding + 24),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DragHandle(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 20),
            _Header(l10n: l10n),
            const SizedBox(height: 28),
            _NameField(controller: nameController, l10n: l10n),
            const SizedBox(height: 16),
            _PhoneField(controller: phoneController, l10n: l10n),
            const SizedBox(height: 32),
            _SaveButton(l10n: l10n, onPressed: onSave),
          ],
        ),
      ),
    );
  }
}

/// Draggable handle indicator at the top of the sheet.
class _DragHandle extends StatelessWidget {
  final Color color;

  const _DragHandle({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

/// Sheet header with icon and title.
class _Header extends StatelessWidget {
  final AppLocalizations l10n;

  const _Header({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.person_add_rounded,
            color: theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.addCustomer,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                l10n.phoneOptional,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Name input field with filled styling and validation.
class _NameField extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations l10n;

  const _NameField({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.words,
      autofocus: true,
      textInputAction: TextInputAction.next,
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: l10n.customerName,
        hintText: 'Mohammed Ali',
        prefixIcon: const Icon(Icons.person_outline_rounded),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? l10n.nameRequired : null,
    );
  }
}

/// Phone input field with filled styling.
class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final AppLocalizations l10n;

  const _PhoneField({required this.controller, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: l10n.customerPhone,
        hintText: '07XX XXX XXXX',
        prefixIcon: const Icon(Icons.phone_rounded),
        filled: true,
        fillColor: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null;
        if (v.trim().length != 11) return l10n.phoneInvalid;
        return null;
      },
    );
  }
}

/// Full-width save button with gradient effect.
class _SaveButton extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onPressed;

  const _SaveButton({required this.l10n, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
          textStyle: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 22),
            const SizedBox(width: 10),
            Text(l10n.save),
          ],
        ),
      ),
    );
  }
}
