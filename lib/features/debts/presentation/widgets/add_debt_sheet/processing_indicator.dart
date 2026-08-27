import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class ProcessingIndicator extends StatelessWidget {
  final AppLocalizations l10n;
  const ProcessingIndicator({super.key, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.parsingVoice,
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
