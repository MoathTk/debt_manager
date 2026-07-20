library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/screens/home_screen.dart';
import '../providers/subscription_provider.dart';
import '../providers/subscription_state.dart';
import 'subscription_plan_picker_screen.dart';

class SubscriptionCheckScreen extends ConsumerStatefulWidget {
  const SubscriptionCheckScreen({super.key});

  @override
  ConsumerState<SubscriptionCheckScreen> createState() => _State();
}

class _State extends ConsumerState<SubscriptionCheckScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _scaleAnim = Tween(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _glowAnim = Tween(begin: 0.2, end: 0.5).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(subscriptionProvider);
    final l10n = AppLocalizations.of(context)!;
    final child = _buildChild(state, ref, l10n);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween(begin: 0.97, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildChild(
    SubscriptionState state,
    WidgetRef ref,
    AppLocalizations l10n,
  ) {
    if (state.isLoading && state.subscription == null) {
      
      return _LoadingView(
        key: const ValueKey('loading'),
        pulseCtrl: _pulseCtrl,
        scaleAnim: _scaleAnim,
        glowAnim: _glowAnim,
      );
    }
    if (state.error != null && state.subscription == null) {
      return _ErrorView(key: const ValueKey('error'), l10n: l10n, ref: ref);
    }
    if (state.subscription == null) {
      return const SubscriptionPlanPickerScreen(key: ValueKey('picker'));
    }
    return const HomeScreen(key: ValueKey('home'));
  }
}

class _LoadingView extends StatelessWidget {
  final AnimationController pulseCtrl;
  final Animation<double> scaleAnim;
  final Animation<double> glowAnim;

  const _LoadingView({
    super.key,
    required this.pulseCtrl,
    required this.scaleAnim,
    required this.glowAnim,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.primary.withValues(alpha: 0.08),
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              AnimatedBuilder(
                animation: pulseCtrl,
                builder: (context, _) => Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [cs.primary, cs.primary.withValues(alpha: 0.7)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cs.primary.withValues(alpha: glowAnim.value),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                  child: Transform.scale(
                    scale: scaleAnim.value,
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Debt Management',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: LinearProgressIndicator(
                  backgroundColor: cs.primary.withValues(alpha: 0.1),
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final AppLocalizations l10n;
  final WidgetRef ref;
  const _ErrorView({super.key, required this.l10n, required this.ref});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              cs.primary.withValues(alpha: 0.08),
              cs.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.errorContainer,
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    size: 40,
                    color: cs.error,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.syncStatusError,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.syncStatusError,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(subscriptionProvider.notifier).load(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: Text(l10n.syncNow),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
