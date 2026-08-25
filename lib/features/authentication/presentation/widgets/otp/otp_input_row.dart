/// Row of 6 OTP digit fields with error banner.
library;

import 'package:flutter/material.dart';
import 'otp_digit_field.dart';

class OtpInputRow extends StatelessWidget {
  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final ValueChanged<int> onChanged;
  final String? error;

  const OtpInputRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hasError = error != null;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: OtpDigitField(
                controller: controllers[i],
                focusNode: focusNodes[i],
                hasError: hasError,
                onChanged: (_) => onChanged(i),
              ),
            );
          }),
        ),
        if (hasError) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: cs.errorContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 16, color: cs.error),
                const SizedBox(width: 6),
                Text(
                  error!,
                  style: tt.bodySmall?.copyWith(color: cs.error),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
