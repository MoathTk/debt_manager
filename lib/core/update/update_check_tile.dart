import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/services/update_service.dart';
import 'update_dialog.dart';

class UpdateCheckTile extends StatefulWidget {
  const UpdateCheckTile({super.key});

  @override
  State<UpdateCheckTile> createState() => _UpdateCheckTileState();
}

class _UpdateCheckTileState extends State<UpdateCheckTile> {
  bool _checking = false;

  Future<void> _check() async {
    setState(() => _checking = true);
    try {
      final info = await UpdateService.checkForUpdate();
      if (!mounted) return;
      if (info != null) {
        await showDialog<UpdateInfo>(
          context: context,
          builder: (_) => UpdateDialog(info: info),
        );
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Semantics(
      label: l10n.checkForUpdates,
      button: true,
      child: ListTile(
        leading: Icon(Icons.system_update_rounded, color: cs.onSurfaceVariant),
        title: Text(l10n.checkForUpdates),
        trailing: _checking
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.primary,
                ),
              )
            : Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: _checking ? null : _check,
      ),
    );
  }
}
