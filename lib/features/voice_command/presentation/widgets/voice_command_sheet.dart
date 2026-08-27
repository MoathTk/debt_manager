/// VOICE COMMAND FEATURE — PRESENTATION LAYER: VOICE COMMAND SHEET
///
/// Main bottom sheet for the voice command feature.
/// Starts compact (idle/recording), expands after AI response.
/// Uses DraggableScrollableSheet passed from home_screen.
///
/// RULES: <150 lines, Theme.of(context), Semantics, l10n.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';
import 'package:local_debt_management/core/sharedProviders/mutations.dart';
import 'package:local_debt_management/features/customers/presentation/widgets/add_customer_sheet.dart';
import '../providers/voice_command_provider.dart';
import '../providers/voice_command_state.dart';
import 'package:local_debt_management/features/debts/presentation/widgets/add_debt_sheet/recording_indicator.dart';
import 'add_debt_review.dart';
import 'add_customer_review.dart';
import 'delete_debt_review.dart';
import 'find_customer_review.dart';
import 'record_payment_review.dart';
import 'view_history_review.dart';

class VoiceCommandSheet extends ConsumerStatefulWidget {
  final ScrollController scrollController;
  final DraggableScrollableController dragController;
  const VoiceCommandSheet({
    super.key,
    required this.scrollController,
    required this.dragController,
  });
  @override
  ConsumerState<VoiceCommandSheet> createState() => _VoiceCommandSheetState();
}

class _VoiceCommandSheetState extends ConsumerState<VoiceCommandSheet> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(voiceCommandProvider);
    final notifier = ref.read(voiceCommandProvider.notifier);

    ref.listen<VoiceCommandState>(voiceCommandProvider, (prev, next) {
      if ((next.isReady || next.isError) && mounted) {
        widget.dragController.animateTo(
          0.85,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(context).viewInsets.bottom + 12,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(cs),
            const SizedBox(height: 12),
            _buildTitle(l10n, cs),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                controller: widget.scrollController,
                child: _buildBody(state, l10n, cs, notifier),
              ),
            ),
            if (state.isRecording || state.isProcessing) ...[
              const SizedBox(height: 16),
              _buildProgressIndicator(state, l10n, cs),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHandle(ColorScheme cs) {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: cs.onSurfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTitle(AppLocalizations l10n, ColorScheme cs) {
    return Semantics(
      header: true,
      child: Text(
        l10n.voiceInput,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
      ),
    );
  }

  Widget _buildBody(
    VoiceCommandState state,
    AppLocalizations l10n,
    ColorScheme cs,
    VoiceCommandNotifier notifier,
  ) {
    if (state.isError) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cs.errorContainer.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.error.withValues(alpha: 0.15)),
        ),
        child: _ErrorState(
          l10n: l10n,
          cs: cs,
          error: state.error,
          onRetry: () => notifier.reRecord(),
        ),
      );
    }
    if (state.isReady && state.command != null) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _buildReview(state, l10n, cs, notifier),
      );
    }
    return _MicArea(
      l10n: l10n,
      cs: cs,
      state: state,
      onToggle: () {
        if (state.isRecording) {
          notifier.stopRecording();
        } else {
          notifier.startRecording();
        }
      },
    );
  }

  Widget _buildReview(
    VoiceCommandState state,
    AppLocalizations l10n,
    ColorScheme cs,
    VoiceCommandNotifier notifier,
  ) {
    if (state.command!.isAddDebt) {
      return AddDebtReview(
        command: state.command!,
        matchedCustomers: state.matchedCustomers,
        allCustomers: state.allCustomers,
        selectedCustomer: state.selectedCustomer,
        onCustomerSelected: (c) => notifier.selectCustomer(c),
        onAddCustomer: () => showAddCustomerSheet(
          context,
          ref,
          onCustomerAdded: (c) => notifier.selectNewlyAddedCustomer(c),
        ),
        onConfirm: (cmd) => _saveDebt(cmd, notifier, l10n),
        onRetry: () => notifier.reRecord(),
        onReRecord: () => notifier.reRecord(),
        onRemoveItem: (i) => notifier.removeItem(i),
      );
    }
    if (state.command!.isViewBalance) {
      return ViewBalanceReview(
        customerName: state.command!.customerName,
        matchedCustomers: state.matchedCustomers,
        selectedCustomer: state.selectedCustomer,
        onCustomerSelected: (c) => notifier.selectCustomer(c),
        onReRecord: () => notifier.reRecord(),
        onConfirmPayment: () => _savePayment(notifier, l10n),
        customerBalance: state.customerBalance,
        remainingDebts: state.remainingDebts,
        selectedDebtId: state.selectedDebtId,
        paymentWarning: state.paymentWarning,
        maxPayment: state.maxPayment,
        onDebtSelected: (id, max) => notifier.selectDebt(id, max),
        onAmountChanged: (a) => notifier.updateAmount(a),
        paymentAmount: state.command!.totalAmount,
      );
    }
    if (state.command!.isRecordPayment) {
      return RecordPaymentReview(
        command: state.command!,
        matchedCustomers: state.matchedCustomers,
        selectedCustomer: state.selectedCustomer,
        remainingDebts: state.remainingDebts,
        selectedDebtId: state.selectedDebtId,
        paymentWarning: state.paymentWarning,
        maxPayment: state.maxPayment,
        onCustomerSelected: (c) => notifier.selectCustomer(c),
        onDebtSelected: (id, max) => notifier.selectDebt(id, max),
        onAmountChanged: (a) => notifier.updateAmount(a),
        onConfirm: () => _savePayment(notifier, l10n),
        onReRecord: () => notifier.reRecord(),
      );
    }
    if (state.command!.isAddCustomer) {
      return AddCustomerReview(
        command: state.command!,
        onConfirm: (cmd) => _saveCustomer(cmd, notifier, l10n),
        onReRecord: () => notifier.reRecord(),
      );
    }
    if (state.command!.isDeleteDebt) {
      return DeleteDebtReview(
        command: state.command!,
        matchedCustomers: state.matchedCustomers,
        selectedCustomer: state.selectedCustomer,
        onSelectCustomer: (c) => notifier.selectCustomer(c),
        remainingDebts: state.remainingDebts ?? [],
        selectedDebtId: state.selectedDebtId,
        onSelectDebt: (id) => notifier.selectDebt(id, 0),
        onConfirm: () => _handleDeleteDebt(notifier, l10n),
        onReRecord: () => notifier.reRecord(),
        isSaving: state.status == VoiceCommandStatus.saving,
      );
    }
    if (state.command!.isViewHistory) {
      return ViewHistoryReview(
        command: state.command!,
        matchedCustomers: state.matchedCustomers,
        selectedCustomer: state.selectedCustomer,
        onSelectCustomer: (c) => notifier.selectCustomer(c),
        balance: state.customerBalance,
        transactions: state.transactionHistory ?? [],
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _UnknownAction(
        l10n: l10n,
        cs: cs,
        onRetry: () => notifier.reRecord(),
      ),
    );
  }

  Widget _buildProgressIndicator(
    VoiceCommandState state,
    AppLocalizations l10n,
    ColorScheme cs,
  ) {
    final text = state.isTranscribing
        ? l10n.listening
        : state.isParsing
        ? l10n.parsingVoice
        : state.isCustomerMatching
        ? l10n.searchCustomers
        : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: cs.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveDebt(
    dynamic command,
    VoiceCommandNotifier notifier,
    AppLocalizations l10n,
  ) async {
    if (command.customerId == null || command.items.isEmpty) return;
    try {
      final note = command.items.map((i) => i.toNoteLine()).join('\n');
      final container = ProviderScope.containerOf(context, listen: false);
      await addDebt(
        container,
        customerId: command.customerId!,
        amount: command.totalAmount,
        note: note,
        reminderDate: command.dueDate,
      );
      if (mounted) {
        notifier.reset();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.acceptAndSave)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.serverError)));
      }
    }
  }

  Future<void> _savePayment(
    VoiceCommandNotifier notifier,
    AppLocalizations l10n,
  ) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final success = await notifier.executePayment(container);
    if (mounted) {
      if (success) {
        notifier.reset();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.paymentSuccess)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.serverError)));
      }
    }
  }

  Future<void> _saveCustomer(
    dynamic command,
    VoiceCommandNotifier notifier,
    AppLocalizations l10n,
  ) async {
    if (command.customerName.trim().isEmpty) return;
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final success = await notifier.confirmAddCustomer(container);
      if (mounted) {
        if (success) {
          notifier.reset();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.customerCreated)));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.serverError)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.serverError)));
      }
    }
  }

  Future<void> _handleDeleteDebt(
    VoiceCommandNotifier notifier,
    AppLocalizations l10n,
  ) async {
    final container = ProviderScope.containerOf(context, listen: false);
    final success = await notifier.executeDeleteDebt(container);
    if (mounted) {
      if (success) {
        notifier.reset();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.debtDeleted)));
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorSaving)));
      }
    }
  }
}

class _MicArea extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final VoiceCommandState state;
  final VoidCallback onToggle;
  const _MicArea({
    required this.l10n,
    required this.cs,
    required this.state,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 8),
        Semantics(
          label: state.isRecording ? l10n.cancel : l10n.speakNow,
          button: true,
          child: _PulsingMic(
            isRecording: state.isRecording,
            isProcessing: state.isProcessing,
            cs: cs,
            onPressed: onToggle,
          ),
        ),
        const SizedBox(height: 20),
        if (state.isRecording)
          RecordingIndicator(
            l10n: l10n,
            soundLevel: state.soundLevel,
            recordingStarted: state.recordingStarted,
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.graphic_eq_rounded,
                  size: 18,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.speakNow,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PulsingMic extends StatelessWidget {
  final bool isRecording;
  final bool isProcessing;
  final ColorScheme cs;
  final VoidCallback onPressed;
  const _PulsingMic({
    required this.isRecording,
    required this.isProcessing,
    required this.cs,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isRecording ? cs.error : cs.primary;
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isRecording) ...[
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.error.withValues(alpha: 0.08),
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.error.withValues(alpha: 0.15),
              ),
            ),
          ],
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isRecording ? 56.0 : 52.0,
            height: isRecording ? 56.0 : 52.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [activeColor, activeColor.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.35),
                  blurRadius: isRecording ? 20 : 12,
                  spreadRadius: isRecording ? 4 : 1,
                ),
              ],
            ),
            child: IconButton(
              onPressed: isProcessing ? null : onPressed,
              icon: isProcessing
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: cs.onPrimary,
                      ),
                    )
                  : AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isRecording ? Icons.mic : Icons.mic_none_rounded,
                        key: ValueKey(isRecording),
                        color: cs.onPrimary,
                        size: 26,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final String? error;
  final VoidCallback onRetry;
  const _ErrorState({
    required this.l10n,
    required this.cs,
    this.error,
    required this.onRetry,
  });

  String _mapError(String? error, AppLocalizations l10n) {
    switch (error) {
      case 'api_key_not_configured':
        return l10n.apiKeyNotConfigured;
      case 'no_internet':
        return l10n.noInternet;
      case 'no_speech_detected':
        return l10n.noSpeechDetected;
      case 'unknown_action':
        return l10n.voiceInputError;
      default:
        return l10n.serverError;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.errorContainer,
          ),
          child: Icon(Icons.error_outline_rounded, size: 28, color: cs.error),
        ),
        const SizedBox(height: 14),
        Text(
          _mapError(error, l10n),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              side: BorderSide(color: cs.error.withValues(alpha: 0.4)),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(
              l10n.retry,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}

class _UnknownAction extends StatelessWidget {
  final AppLocalizations l10n;
  final ColorScheme cs;
  final VoidCallback onRetry;
  const _UnknownAction({
    required this.l10n,
    required this.cs,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cs.surfaceContainerHighest,
          ),
          child: Icon(
            Icons.help_outline_rounded,
            size: 28,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          l10n.voiceInputError,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(Icons.mic_rounded, size: 18),
            label: Text(
              l10n.reRecord,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }
}
