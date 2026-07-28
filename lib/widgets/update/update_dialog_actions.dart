import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'update_dialog_content.dart';

class UpdateDialogActions extends StatelessWidget {
  final UpdateContentState state;
  final bool canDismiss;
  final VoidCallback onUpdate;
  final VoidCallback onDismiss;

  const UpdateDialogActions({
    super.key,
    required this.state,
    required this.canDismiss,
    required this.onUpdate,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: switch (state) {
        UpdateContentState.downloading => const SizedBox.shrink(),
        UpdateContentState.success => FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.updateDone),
          ),
        UpdateContentState.error => FilledButton(
            onPressed: onUpdate,
            child: Text(l10n.updateRetry),
          ),
        UpdateContentState.idle => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (canDismiss)
                TextButton(onPressed: onDismiss, child: Text(l10n.updateLater)),
              FilledButton(onPressed: onUpdate, child: Text(l10n.updateNow)),
            ],
          ),
      },
    );
  }
}
