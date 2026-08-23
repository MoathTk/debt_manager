import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';
import '../../Providers/mutations.dart';
import '../../features/subscription/presentation/widgets/mutation_guard.dart';
import '../../features/voice_entry/presentation/providers/voice_entry_provider.dart';
import '../../features/voice_entry/domain/entities/voice_parsed_debt.dart';
import '../../features/voice_entry/presentation/widgets/parsed_items_review.dart';
import 'handle.dart';
import 'header.dart';
import 'recording_indicator.dart';
import 'processing_indicator.dart';
import 'error_banner.dart';
import 'field.dart';
import '../amount_input_formatter.dart';
import '../reminder_date_picker.dart';

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
    setState(() {
      _amount.text = parsed.totalAmount.toInt().toString();
      _note.text = parsed.formattedItems;
      _reminderDate = parsed.dueDate;
    });
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final voiceState = ref.watch(voiceEntryProvider);

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: SingleChildScrollView(
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
              const BottomSheetHandle(),
              const SizedBox(height: 20),
              AddDebtHeader(l10n: l10n, voiceState: voiceState),
              if (voiceState.isRecording) ...[
                const SizedBox(height: 12),
                RecordingIndicator(
                  l10n: l10n,
                  soundLevel: voiceState.soundLevel,
                  recordingStarted: voiceState.recordingStarted,
                ),
              ],
              if (voiceState.isProcessing) ...[
                const SizedBox(height: 12),
                ProcessingIndicator(l10n: l10n),
              ],
              if (voiceState.isError && voiceState.error != null) ...[
                const SizedBox(height: 12),
                ErrorBanner(
                  l10n: l10n,
                  error: voiceState.error!,
                  onRetry: voiceState.transcript != null
                      ? () =>
                            ref.read(voiceEntryProvider.notifier).retryParsing()
                      : null,
                ),
              ],
              if (voiceState.isReady && voiceState.parsedDebt != null) ...[
                const SizedBox(height: 12),
                ParsedItemsReview(
                  parsedDebt: voiceState.parsedDebt!,
                  transcript: voiceState.transcript,
                  onChanged: (updated) {
                    ref
                        .read(voiceEntryProvider.notifier)
                        .updateParsedDebt(updated);
                  },
                  onAccept: () {
                    _autoFillFromVoice(voiceState.parsedDebt!);
                  },
                  onRetry: () {
                    ref.read(voiceEntryProvider.notifier).retryParsing();
                  },
                  onReRecord: () {
                    ref.read(voiceEntryProvider.notifier).reRecord();
                  },
                ),
              ],
              const SizedBox(height: 24),
              DebtField(
                ctrl: _amount,
                label: l10n.amount,
                decimal: true,
                autofocus: true,
                formatters: [ThousandsSeparatorInputFormatter()],
              ),
              const SizedBox(height: 16),
              DebtField(ctrl: _note, label: l10n.noteOptional, maxLines: null),
              const SizedBox(height: 16),
              ReminderDatePicker(
                selectedDate: _reminderDate,
                onDateChanged: (d) => setState(() => _reminderDate = d),
              ),
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
      ),
    );
  }
}
