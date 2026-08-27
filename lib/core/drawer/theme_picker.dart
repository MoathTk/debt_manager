import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/Providers/theme_provider.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class ThemePicker extends ConsumerWidget {
  const ThemePicker({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final currentTheme = ref.watch(themeProvider);

    // 1. Composition: Wrapping the entire picker in a styled container
    // to give it a "card" or "panel" feel.
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow, // Modern M3 distinct surface color
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Keep it compact
        children: [
          Row(
            children: [
              // 2. Icon Highlighting: A tinted background behind the icon
              // is a staple of premium modern UI (like iOS/Android settings).
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons.palette_outlined,
                  size: 20,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              // 3. Stronger Typography: Slightly bumping the font weight.
              Text(
                l10n.theme,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 4. Forced Touch Target: Enforcing a minimum height of 48 pixels.
          SizedBox(
            width: double.infinity,
            height: 48,
            child: SegmentedButton<ThemeMode>(
              style: SegmentedButton.styleFrom(
                side: BorderSide(color: cs.outlineVariant.withValues( alpha: .5)),
              ),
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(
                    Icons.light_mode_rounded,
                  ), // Rounded icons look softer
                  label: Text('Light'), // * Consider adding l10n.light here
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded),
                  label: Text('Dark'), // * Consider adding l10n.dark here
                ),
              ],
              selected: {currentTheme},
              onSelectionChanged: (selected) {
                ref.read(themeProvider.notifier).setTheme(selected.first);

                // 5. UX Polish: Let the button's selection animation finish
                // for 200ms before dismissing the dialog/sheet.
                Future.delayed(const Duration(milliseconds: 200), onClose);
              },
            ),
          ),
        ],
      ),
    );
  }
}
