import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

enum UpdateContentState { idle, downloading, error, success }

class UpdateDialogContent extends StatelessWidget {
  final UpdateContentState state;
  final String currentVersion;
  final String latestVersion;
  final String? releaseNotes;
  final double? progress;
  final VoidCallback? onRetry;

  const UpdateDialogContent({
    super.key,
    required this.state,
    required this.currentVersion,
    required this.latestVersion,
    this.releaseNotes,
    this.progress,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.maxFinite,
        child: switch (state) {
          UpdateContentState.idle => _VersionInfo(
              currentVersion: currentVersion,
              latestVersion: latestVersion,
              releaseNotes: releaseNotes,
            ),
          UpdateContentState.downloading => _ProgressView(progress: progress ?? 0.0),
          UpdateContentState.error => _ErrorView(onRetry: onRetry),
          UpdateContentState.success => _SuccessView(),
        },
      );
}

class _VersionInfo extends StatelessWidget {
  final String currentVersion;
  final String latestVersion;
  final String? releaseNotes;

  const _VersionInfo({
    required this.currentVersion,
    required this.latestVersion,
    this.releaseNotes,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '${l10n.currentVersion} $currentVersion, ${l10n.latestVersion} $latestVersion',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _VersionChip(label: l10n.currentVersion, version: currentVersion),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.arrow_forward_rounded, size: 16, color: cs.onSurfaceVariant),
              ),
              _VersionChip(label: l10n.latestVersion, version: latestVersion, highlight: true),
            ],
          ),
        ),
        if (releaseNotes != null && releaseNotes!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(l10n.releaseNotes, style: tt.labelMedium?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Semantics(
              label: releaseNotes,
              child: Text(releaseNotes!, style: tt.bodySmall),
            ),
          ),
        ],
      ],
    );
  }
}

class _VersionChip extends StatelessWidget {
  final String label;
  final String version;
  final bool highlight;

  const _VersionChip({
    required this.label,
    required this.version,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 2),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: highlight ? cs.primaryContainer : cs.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            version,
            style: tt.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: highlight ? cs.onPrimaryContainer : cs.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressView extends StatelessWidget {
  final double progress;

  const _ProgressView({required this.progress});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final percent = (progress * 100).toInt();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '${l10n.downloading} $percent%',
          value: percent.toString(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: cs.surfaceContainerHighest,
              color: cs.primary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$percent%',
          style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: cs.primary),
        ),
        const SizedBox(height: 4),
        Text(l10n.downloading, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback? onRetry;

  const _ErrorView({this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline_rounded, size: 40, color: cs.error),
        const SizedBox(height: 12),
        Semantics(
          label: l10n.updateFailed,
          child: Text(l10n.updateFailed, style: tt.bodyMedium, textAlign: TextAlign.center),
        ),
        if (onRetry != null) ...[
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.updateRetry),
          ),
        ],
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.check_circle_outline_rounded, size: 40, color: cs.primary),
        const SizedBox(height: 12),
        Semantics(
          label: l10n.tapToInstall,
          child: Text(l10n.tapToInstall, style: tt.bodyMedium, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}
