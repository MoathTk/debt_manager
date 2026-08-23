import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../features/voice_entry/presentation/providers/voice_entry_provider.dart';
import '../../features/voice_entry/presentation/providers/voice_entry_state.dart';
import '../../features/voice_entry/presentation/widgets/mic_button.dart';

class AddDebtHeader extends StatelessWidget {
  final AppLocalizations l10n;
  final VoiceEntryState voiceState;
  const AddDebtHeader({
    super.key,
    required this.l10n,
    required this.voiceState,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.addDebt,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Semantics(
          label: voiceState.isRecording ? 'Stop recording' : 'Start recording',
          button: true,
          child: MicButton(
            onPressed: () {
              final notifier =
                  ProviderScope.containerOf(context)
                      .read(voiceEntryProvider.notifier);
              if (voiceState.isRecording) {
                notifier.stopRecording();
              } else {
                notifier.startRecording();
              }
            },
            isRecording: voiceState.isRecording,
            isProcessing: voiceState.isProcessing,
          ),
        ),
      ],
    );
  }
}
