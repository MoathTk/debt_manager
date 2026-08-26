/// REVIEW SUB-WIDGETS — ReviewActions
///
/// RULES: <80 lines per class, Theme.of(context), Semantics, l10n.
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class ReviewActions extends StatelessWidget {
  final AppLocalizations l10n;
  final VoidCallback onReRecord;
  final VoidCallback onConfirm;
  const ReviewActions({
    super.key,
    required this.l10n,
    required this.onReRecord,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Semantics(
          label: l10n.reRecord,
          button: true,
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: onReRecord,
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.mic_rounded, size: 18),
              label: Text(l10n.reRecord),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Semantics(
          label: l10n.acceptAndSave,
          button: true,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check_circle_rounded, size: 20),
              label: Text(l10n.acceptAndSave),
            ),
          ),
        ),
      ],
    );
  }
}
