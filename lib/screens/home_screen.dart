import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/theme_provider.dart';
import '../Providers/locale_provider.dart';
import 'dashboard_screen.dart';
import 'customers_screen.dart';

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

  final _screens = const [DashboardScreen(), CustomersScreen()];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _scaffoldKey.currentState!.openEndDrawer(),
          ),
        ],
      ),
      endDrawer: _SettingsDrawer(
        l10n: l10n,
        ref: ref,
        onClose: () => _scaffoldKey.currentState?.closeEndDrawer(),
      ),
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: _ModernNavBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          _NavItem(icon: Icons.home_rounded, activeIcon: Icons.home_rounded, label: l10n.home),
          _NavItem(icon: Icons.people_rounded, activeIcon: Icons.people_rounded, label: l10n.customers),
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

  _NavItem({required this.icon, required this.activeIcon, required this.label});
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
              child: Icon(
                isSelected ? item.activeIcon : item.icon,
                color: color,
                size: 26,
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

/// Side drawer with language and theme settings.
class _SettingsDrawer extends StatelessWidget {
  final AppLocalizations l10n;
  final WidgetRef ref;
  final VoidCallback onClose;

  const _SettingsDrawer({
    required this.l10n,
    required this.ref,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final currentTheme = ref.watch(themeProvider);

    final screenWidth = MediaQuery.of(context).size.width;

    return Drawer(
      width: screenWidth * 0.5,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(l10n.language, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'ar', label: Text('العربية')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {currentLocale.languageCode},
              onSelectionChanged: (selected) {
                final code = selected.first;
                if (code == 'ar') {
                  ref.read(localeProvider.notifier).setArabic();
                } else {
                  ref.read(localeProvider.notifier).setEnglish();
                }
                onClose();
              },
            ),
            const SizedBox(height: 24),
            Text('Theme', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: const Icon(Icons.dark_mode),
                ),
              ],
              selected: {currentTheme},
              onSelectionChanged: (selected) {
                ref.read(themeProvider.notifier).setTheme(selected.first);
                onClose();
              },
            ),
          ],
        ),
      ),
    );
  }
}
