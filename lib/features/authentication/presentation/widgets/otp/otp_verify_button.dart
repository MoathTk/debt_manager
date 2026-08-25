/// OTP verify button with loading spinner state.
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class OtpVerifyButton extends StatelessWidget {
  final bool loading;
  final bool canVerify;
  final VoidCallback? onVerify;

  const OtpVerifyButton({
    super.key,
    required this.loading,
    required this.canVerify,
    this.onVerify,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final tt = Theme.of(context).textTheme;

    if (loading) {
      return SizedBox(
        width: 54,
        height: 54,
        child: Card(
          elevation: 0,
          color: cs.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: cs.primary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: canVerify ? onVerify : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: cs.primary.withValues(alpha: 0.3),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.6),
          elevation: 2,
          shadowColor: cs.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 20, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              l10n.verifyCode,
              style: tt.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
