import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/Providers/locale_provider.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key, required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final currentLocale = ref.watch(localeProvider);

    // 1. Consistent Panel Design: Matches the ThemePicker perfectly.
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // 2. Icon Highlighting: Same tinted container treatment.
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: cs.primaryContainer,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Icon(
                  Icons
                      .language_rounded, // Changed to rounded variant for a softer look
                  size: 20,
                  color: cs.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 12),
              // 3. Consistent Typography
              Text(
                l10n.language,
                style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 4. Forced Touch Target: 48px height minimum.
          SizedBox(
            width: double.infinity,
            height: 48,
            child: SegmentedButton<String>(
              style: SegmentedButton.styleFrom(
                side: BorderSide(color: cs.outlineVariant.withValues(alpha: .5)),
              ),
              segments: const [
                ButtonSegment(
                  value: 'ar',
                  label: Text(
                    'العربية',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                ButtonSegment(
                  value: 'en',
                  label: Text(
                    'English',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
              selected: {currentLocale.languageCode},
              onSelectionChanged: (selected) {
                final code = selected.first;
                if (code == 'ar') {
                  ref.read(localeProvider.notifier).setArabic();
                } else {
                  ref.read(localeProvider.notifier).setEnglish();
                }

                // 5. UX Polish: The same 200ms delay so the user sees
                // the segment transition before the modal dismisses.
                Future.delayed(const Duration(milliseconds: 200), onClose);
              },
            ),
          ),
        ],
      ),
    );
  }
}
