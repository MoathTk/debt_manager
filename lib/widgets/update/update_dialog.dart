import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/services/update_service.dart';
import 'update_dialog_header.dart';
import 'update_dialog_content.dart';
import 'update_dialog_actions.dart';

class UpdateDialog extends StatefulWidget {
  final UpdateInfo info;
  const UpdateDialog({super.key, required this.info});

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;
  var _contentState = UpdateContentState.idle;
  double? _progress;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get _canDismiss => !widget.info.forceUpdate;

  Future<void> _startDownload() async {
    final url = widget.info.apkUrl;
    if (url == null) {
      if (mounted) setState(() => _contentState = UpdateContentState.error);
      return;
    }
    setState(() => _contentState = UpdateContentState.downloading);
    try {
      final result = await UpdateService.downloadAndInstall(
        url,
        onProgress: (p) {
          if (mounted) setState(() => _progress = p);
        },
      );
      if (!mounted) return;
      setState(() {
        _contentState = result == DownloadResult.success
            ? UpdateContentState.success
            : UpdateContentState.error;
      });
    } catch (_) {
      if (mounted) setState(() => _contentState = UpdateContentState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final dialog = Semantics(
      label: l10n.updateAvailable,
      child: AlertDialog(
        clipBehavior: Clip.antiAlias,
        contentPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UpdateDialogHeader(pulse: _pulseAnim, forceUpdate: widget.info.forceUpdate),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: UpdateDialogContent(
                  key: ValueKey(_contentState),
                  state: _contentState,
                  currentVersion: widget.info.currentVersion,
                  latestVersion: widget.info.latestVersion,
                  releaseNotes: widget.info.releaseNotes,
                  progress: _progress,
                  onRetry: _contentState == UpdateContentState.error ? _startDownload : null,
                ),
              ),
            ),
          ],
        ),
        actions: [
          UpdateDialogActions(
            state: _contentState,
            canDismiss: _canDismiss,
            onUpdate: _startDownload,
            onDismiss: () => Navigator.of(context).pop(),
          ),
        ],
        actionsPadding: EdgeInsets.zero,
      ),
    );

    if (!_canDismiss) return PopScope(canPop: false, child: dialog);
    return dialog;
  }
}
