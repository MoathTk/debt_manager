/// Subscription feature — Clock tamper warning screen
///
/// Full-screen warning when the device clock has been rolled back.
/// Shows a clear message explaining the issue and a refresh button
/// that requires internet connectivity to re-verify with NTP.
/// No data access, no tabs — just the warning.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/core/services/connectivity_service.dart';
import '../providers/subscription_provider.dart';

class ClockTamperScreen extends ConsumerStatefulWidget {
  const ClockTamperScreen({super.key});

  @override
  ConsumerState<ClockTamperScreen> createState() => _ClockTamperScreenState();
}

class _ClockTamperScreenState extends ConsumerState<ClockTamperScreen> {
  bool _isRefreshing = false;

  Future<void> _onRefresh() async {
    final l10n = AppLocalizations.of(context)!;
    final isConnected = await ConnectivityService().checkConnection();

    if (!isConnected && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.blockedRequiresInternet),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    setState(() => _isRefreshing = true);
    try {
      await ref.read(subscriptionProvider.notifier).load();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: colorScheme.error.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    size: 44,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.blockedTitle,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.blockedClockRollback,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.5,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  l10n.blockedDataSafe,
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _isRefreshing ? null : _onRefresh,
                    icon: _isRefreshing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: Text(
                      _isRefreshing ? '' : l10n.blockedRefresh,
                      style: const TextStyle(fontSize: 15),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      foregroundColor: colorScheme.onError,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.blockedRequiresInternet,
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
