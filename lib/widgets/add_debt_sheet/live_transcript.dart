import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class LiveTranscript extends StatelessWidget {
  final AppLocalizations l10n;
  final String? transcript;
  const LiveTranscript({super.key, required this.l10n, this.transcript});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.error,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.listening,
                style: TextStyle(
                  color: cs.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            transcript?.isNotEmpty == true ? transcript! : l10n.speakNow,
            style: TextStyle(
              fontSize: 15,
              color: transcript?.isNotEmpty == true
                  ? cs.onErrorContainer
                  : cs.onErrorContainer.withValues(alpha: 0.5),
              fontStyle: transcript?.isNotEmpty == true
                  ? FontStyle.normal
                  : FontStyle.italic,
              height: 1.4,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
