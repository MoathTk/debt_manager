import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/widgets/drawer/side_drawer.dart';
import 'package:local_debt_management/widgets/sync_status_indicator.dart';
import '../l10n/app_localizations.dart';
import '../Providers/database_provider.dart';
import '../Providers/sync_provider.dart';
import '../features/subscription/presentation/widgets/subscription_status_icon.dart';

import 'dashboard_screen.dart';
import 'customers_screen.dart';
import 'reminders_screen.dart';

/// Main shell screen with bottom navigation bar and settings drawer.
///
/// Uses [IndexedStack] to preserve scroll state across tabs.
/// The endDrawer (right side) contains language and theme toggles.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(syncProvider.notifier).syncNow();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pendingAsync = ref.watch(pendingRemindersProvider);
    final pendingCount = pendingAsync.whenOrNull(
      data: (list) {
        final today = DateTime.now();
        final todayStr =
            '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        return list
            .where(
              (r) =>
                  r.isCompleted == 0 && r.reminderDate.compareTo(todayStr) < 0,
            )
            .length;
      },
    );

    final screens = [
      DashboardScreen(
        onNavigateToTab: (i) => setState(() => _currentIndex = i),
      ),
      const CustomersScreen(),
      const RemindersScreen(),
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        
        title: Text(l10n.appTitle, style: TextStyle(fontSize: 14)),

        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Theme.of(
              context,
            ).colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
        actions: [
          const SyncStatusIndicator(),
          const SubscriptionStatusIcon(),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: SettingsDrawer(
        l10n: l10n,
        onClose: () => _scaffoldKey.currentState?.closeEndDrawer(),
      ),
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: _ModernNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          _NavItem(
            icon: Icons.home_rounded,
            activeIcon: Icons.home_rounded,
            label: l10n.home,
          ),
          _NavItem(
            icon: Icons.people_rounded,
            activeIcon: Icons.people_rounded,
            label: l10n.customers,
          ),
          _NavItem(
            icon: Icons.notifications_none_rounded,
            activeIcon: Icons.notifications_active_rounded,
            label: l10n.reminders,
            badge: pendingCount,
          ),
        ],
      ),
    );
  }
}

/// A single navigation item definition.
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? badge;

  _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.badge,
  });
}

/// Modern floating bottom navigation bar with a pill-shaped indicator.
///
/// Features a rounded card-like bar, animated indicator dot,
/// and larger readable labels for all age groups.
class _ModernNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _ModernNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final isSelected = i == currentIndex;
            return _NavTab(
              item: items[i],
              isSelected: isSelected,
              onTap: () => onTap(i),
              theme: theme,
            );
          }),
        ),
      ),
    );
  }
}

/// A single tab in the navigation bar with animated indicator.
class _NavTab extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _NavTab({
    required this.item,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 80,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(
                horizontal: isSelected ? 18 : 0,
                vertical: isSelected ? 4 : 0,
              ),
              decoration: isSelected
                  ? BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    )
                  : null,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    isSelected ? item.activeIcon : item.icon,
                    color: color,
                    size: 26,
                  ),
                  if (item.badge != null && item.badge! > 0)
                    Positioned(
                      top: -4,
                      right: -10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${item.badge}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: color,
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
