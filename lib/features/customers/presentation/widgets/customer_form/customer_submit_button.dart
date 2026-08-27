import 'package:flutter/material.dart';

/// Full-width primary button used to submit customer forms.
class CustomerSubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CustomerSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

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
            Text(label),
          ],
        ),
      ),
    );
  }
}
