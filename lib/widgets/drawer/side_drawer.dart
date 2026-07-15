import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'user_profile_header.dart';
import 'sync_section.dart';
import 'language_picker.dart';
import 'theme_picker.dart';
import 'data_management_section.dart';
import 'drawer_footer.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({
    super.key,
    required this.l10n,
    required this.onClose,
  });
  final AppLocalizations l10n;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Drawer(
      width: screenWidth * 0.85,
      backgroundColor: cs.surface,
      elevation: 1,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const UserProfileHeader(),
            const Divider(indent: 24, endIndent: 24),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                children: [
                  SyncSection(onClose: onClose),
                  const SizedBox(height: 24),
                  Text(
                    l10n.preferences,
                    style: tt.labelSmall?.copyWith(
                      color: cs.primary,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LanguagePicker(onClose: onClose),
                        const SizedBox(height: 24),
                        ThemePicker(onClose: onClose),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const DataManagementSection(),
                ],
              ),
            ),
            DrawerFooter(onClose: onClose),
          ],
        ),
      ),
    );
  }
}
