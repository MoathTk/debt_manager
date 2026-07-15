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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.language, size: 20, color: cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Text(l10n.language, style: tt.titleMedium),
        ]),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<String>(
            segments: const [
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
        ),
      ],
    );
  }
}
