import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class ErrorBanner extends StatelessWidget {
  final AppLocalizations l10n;
  final String error;
  final VoidCallback? onRetry;
  const ErrorBanner({
    super.key,
    required this.l10n,
    required this.error,
    this.onRetry,
  });

  String _mapErrorToMessage(String raw) {
    if (raw == 'api_key_not_configured') return l10n.apiKeyNotConfigured;
    if (raw == 'no_internet' || raw == 'noInternet') return l10n.noInternet;
    if (raw == 'no_speech_detected' || raw == 'noSpeechDetected') {
      return l10n.noSpeechDetected;
    }
    if (raw.contains('401') || raw.toLowerCase().contains('invalid api key')) {
      return l10n.apiKeyNotConfigured;
    }
    if (raw.contains('500') || raw.contains('503')) return l10n.serverError;
    if (raw.toLowerCase().contains('timeout') ||
        raw.toLowerCase().contains('deadline')) {
      return l10n.serverError;
    }
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.onErrorContainer, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _mapErrorToMessage(error),
              style: TextStyle(color: cs.onErrorContainer, fontSize: 13),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            TextButton(onPressed: onRetry, child: Text(l10n.retry)),
          ],
        ],
      ),
    );
  }
}
