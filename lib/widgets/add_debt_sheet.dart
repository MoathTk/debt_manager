import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../Providers/mutations.dart';
import '../features/subscription/presentation/widgets/mutation_guard.dart';
import '../features/voice_entry/presentation/providers/voice_entry_provider.dart';
import '../features/voice_entry/presentation/providers/voice_entry_state.dart';
import '../features/voice_entry/domain/entities/voice_parsed_debt.dart';
import '../features/voice_entry/presentation/widgets/mic_button.dart';
import '../features/voice_entry/presentation/widgets/voice_transcript_display.dart';
import 'amount_input_formatter.dart';
import 'reminder_date_picker.dart';

/// Bottom sheet for adding a new debt (pure addition, no linking).
void showAddDebtSheet(BuildContext context, WidgetRef ref, String customerId) {
  if (MutationGuard.checkBlocked(context, ref)) return;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _AddDebtBody(customerId: customerId),
  );
}

class _AddDebtBody extends ConsumerStatefulWidget {
  final String customerId;
  const _AddDebtBody({required this.customerId});
  @override
  ConsumerState<_AddDebtBody> createState() => _BodyState();
}

class _BodyState extends ConsumerState<_AddDebtBody> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;
  DateTime? _reminderDate;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  void _autoFillFromVoice(VoiceParsedDebt parsed) {
    _amount.text = parsed.totalAmount.toInt().toString();
    _note.text = parsed.formattedItems;
    _reminderDate = parsed.dueDate;
  }

  Future<void> _save() async {
    final val = parseAmount(_amount.text.trim());
    if (val == null || val <= 0) return;
    setState(() => _saving = true);
    await addDebt(
      ProviderScope.containerOf(context),
      customerId: widget.customerId,
      amount: val,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
      reminderDate: _reminderDate,
    );
    ref.read(voiceEntryProvider.notifier).reset();
    if (mounted) Navigator.pop(context);
  }

  Future<void> _onMicPressed() async {
    final voiceState = ref.read(voiceEntryProvider);
    final notifier = ref.read(voiceEntryProvider.notifier);

    if (voiceState.isRecording) {
      // Don't await — let stopRecording() run in the background
      // so the UI unfreezes immediately
      notifier.stopRecording();
    } else {
      await notifier.startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final voiceState = ref.watch(voiceEntryProvider);

    // Auto-fill fields when AI parsing completes
    ref.listen<VoiceEntryState>(voiceEntryProvider, (prev, next) {
      if (next.isReady && next.parsedDebt != null) {
        _autoFillFromVoice(next.parsedDebt!);
      }
    });

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          24,
          24,
          24,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _handle(theme),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.addDebt,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                MicButton(
                  onPressed: _onMicPressed,
                  isRecording: voiceState.isRecording,
                  isProcessing: voiceState.isProcessing,
                ),
              ],
            ),
            if (voiceState.isRecording) ...[
              const SizedBox(height: 12),
              _LiveTranscript(
                l10n: l10n,
                transcript: voiceState.transcript,
              ),
            ],
            if (voiceState.isParsing) ...[
              const SizedBox(height: 12),
              _ProcessingIndicator(l10n: l10n),
            ],
            if (voiceState.isError && voiceState.error != null) ...[
              const SizedBox(height: 12),
              _ErrorBanner(message: voiceState.error!),
            ],
            const SizedBox(height: 24),
            _Field(
              ctrl: _amount,
              label: l10n.amount,
              decimal: true,
              autofocus: true,
              formatters: [ThousandsSeparatorInputFormatter()],
            ),
            const SizedBox(height: 16),
            _Field(ctrl: _note, label: l10n.noteOptional, maxLines: null),
            const SizedBox(height: 16),
            ReminderDatePicker(
              selectedDate: _reminderDate,
              onDateChanged: (d) => setState(() => _reminderDate = d),
            ),
            if (voiceState.isReady && voiceState.transcript != null) ...[
              const SizedBox(height: 16),
              VoiceTranscriptDisplay(transcript: voiceState.transcript!),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : Text(
                        l10n.save,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _handle(ThemeData theme) => Container(
    width: 40,
    height: 4,
    decoration: BoxDecoration(
      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
      borderRadius: BorderRadius.circular(2),
    ),
  );
}

class _LiveTranscript extends StatelessWidget {
  final AppLocalizations l10n;
  final String? transcript;
  const _LiveTranscript({required this.l10n, this.transcript});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 8,
                height: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.error,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.listening,
                style: TextStyle(
                  color: cs.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            transcript?.isNotEmpty == true ? transcript! : l10n.speakNow,
            style: TextStyle(
              fontSize: 15,
              color: transcript?.isNotEmpty == true
                  ? cs.onErrorContainer
                  : cs.onErrorContainer.withValues(alpha: 0.5),
              fontStyle: transcript?.isNotEmpty == true
                  ? FontStyle.normal
                  : FontStyle.italic,
              height: 1.4,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProcessingIndicator extends StatelessWidget {
  final AppLocalizations l10n;
  const _ProcessingIndicator({required this.l10n});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            l10n.parsingVoice,
            style: TextStyle(
              color: cs.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 16, color: cs.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: cs.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool decimal;
  final bool autofocus;
  final int? maxLines;
  final List<TextInputFormatter>? formatters;
  const _Field({
    required this.ctrl,
    required this.label,
    this.decimal = false,
    this.autofocus = false,
    this.maxLines,
    this.formatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      autofocus: autofocus,
      keyboardType: decimal
          ? const TextInputType.numberWithOptions(decimal: true)
          : null,
      inputFormatters: formatters,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 18),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
