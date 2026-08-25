/// Countdown timer or resend button for OTP verification.
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class OtpResendSection extends StatelessWidget {
  final int resendSeconds;
  final VoidCallback? onResend;

  const OtpResendSection({
    super.key,
    required this.resendSeconds,
    this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    if (resendSeconds > 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: resendSeconds / 60,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              backgroundColor: cs.onSurfaceVariant.withValues(alpha: 0.1),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            l10n.resendIn(resendSeconds),
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      );
    }

    if (onResend == null) return const SizedBox.shrink();

    return TextButton.icon(
      onPressed: onResend,
      icon: Icon(Icons.refresh_rounded, size: 18, color: cs.primary),
      label: Text(
        l10n.resendCode,
        style: tt.bodyMedium?.copyWith(
          color: cs.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
