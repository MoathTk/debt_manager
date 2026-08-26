/// VOICE COMMAND FEATURE — PRESENTATION LAYER: PROVIDER
///
/// Manages the full voice command lifecycle:
/// record → transcribe → parse → match customer → route to action review.
///
/// Uses the same AudioRecorder pattern as VoiceEntryNotifier.
/// ---------------------------------------------------------------------------
library;

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:local_debt_management/services/connectivity_service.dart';
import '../../domain/entities/voice_command.dart';
import '../../domain/exceptions/voice_command_exception.dart';
import '../../../voice_entry/domain/exceptions/voice_entry_exception.dart';
import '../../domain/usecases/process_voice_command.dart';
import '../../data/repositories/voice_command_repository_impl.dart';
import 'voice_command_state.dart';
import '../../../voice_entry/data/datasources/ai_parsing_datasource.dart'
    as voice_entry;
import '../../../../Providers/database_provider.dart';
import '../../../../Providers/mutations.dart';
import '../../../../data/repositories/customer_repository.dart';
import '../../../../data/repositories/transaction_repository.dart';

final voiceCommandProvider =
    StateNotifierProvider.autoDispose<VoiceCommandNotifier, VoiceCommandState>(
  (ref) {
    final datasource = voice_entry.AiParsingDatasource(
      apiKey: const String.fromEnvironment('OPENAI_API_KEY'),
    );
    final repo = VoiceCommandRepositoryImpl(datasource);
    final customerRepo = ref.read(customerRepositoryProvider);
    final txRepo = ref.read(transactionRepositoryProvider);
    return VoiceCommandNotifier(ProcessVoiceCommand(repo), customerRepo, txRepo);
  },
);

class VoiceCommandNotifier extends StateNotifier<VoiceCommandState> {
  final ProcessVoiceCommand _processCommand;
  final CustomerRepository _customerRepo;
  final TransactionRepository _txRepo;
  final AudioRecorder _recorder = AudioRecorder();
  StreamSubscription<Amplitude>? _ampSub;

  VoiceCommandNotifier(this._processCommand, this._customerRepo, this._txRepo)
      : super(const VoiceCommandState());

  // ---------------------------------------------------------------------------
  // RECORDING
  // ---------------------------------------------------------------------------

  Future<void> startRecording() async {
    const apiKey = String.fromEnvironment('OPENAI_API_KEY');
    if (apiKey.isEmpty) {
      state = state.copyWith(
        status: VoiceCommandStatus.error,
        error: 'api_key_not_configured',
      );
      return;
    }

    try {
      if (!await _recorder.hasPermission()) {
        state = state.copyWith(
          status: VoiceCommandStatus.error,
          error: 'no_speech_detected',
        );
        return;
      }
    } catch (e) {
      state = state.copyWith(
        status: VoiceCommandStatus.error,
        error: 'no_speech_detected',
      );
      return;
    }

    final tempDir = Directory.systemTemp;
    final path =
        '${tempDir.path}/voice_cmd_${DateTime.now().millisecondsSinceEpoch}.m4a';

    try {
      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: path,
      );
    } catch (e) {
      state = state.copyWith(
        status: VoiceCommandStatus.error,
        error: 'no_speech_detected',
      );
      return;
    }

    state = state.copyWith(
      status: VoiceCommandStatus.recording,
      clearError: true,
      clearCommand: true,
      clearSelectedCustomer: true,
      recordingStarted: DateTime.now(),
      soundLevel: 0.0,
      recordedFilePath: path,
      saveSuccess: false,
    );

    _ampSub = _recorder
        .onAmplitudeChanged(const Duration(milliseconds: 200))
        .listen((amp) {
      if (!mounted || !state.isRecording) return;
      final normalized = pow(10, amp.current / 20).clamp(0.0, 1.0);
      state = state.copyWith(soundLevel: normalized.toDouble());
    });
  }

  Future<void> stopRecording() async {
    await _ampSub?.cancel();
    _ampSub = null;

    String? path;
    try {
      path = await _recorder.stop();
    } catch (_) {}

    if (!mounted) return;

    if (path == null || path.isEmpty) {
      state = state.copyWith(
        status: VoiceCommandStatus.error,
        error: 'no_speech_detected',
        clearRecordingStarted: true,
        soundLevel: 0.0,
      );
      return;
    }

    await _processAudio(path);
  }

  // ---------------------------------------------------------------------------
  // AI PROCESSING
  // ---------------------------------------------------------------------------

  Future<void> _processAudio(String filePath) async {
    if (!mounted) return;

    state = state.copyWith(
      status: VoiceCommandStatus.transcribing,
      clearRecordingStarted: true,
      soundLevel: 0.0,
    );

    if (!await ConnectivityService().checkConnection()) {
      if (mounted) {
        state = state.copyWith(
          status: VoiceCommandStatus.error,
          error: 'no_internet',
        );
      }
      return;
    }

    try {
      final command = await _processCommand(filePath);
      if (!mounted) return;

      state = state.copyWith(
        status: VoiceCommandStatus.parsing,
        command: command,
      );
      await _matchCustomer(command);
    } on VoiceCommandException catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: VoiceCommandStatus.error,
          error: e.message,
        );
      }
    } on VoiceEntryException catch (e) {
      if (mounted) {
        final msg = e.message;
        state = state.copyWith(
          status: VoiceCommandStatus.error,
          error: msg.contains('401') || msg.contains('API key')
              ? 'api_key_not_configured'
              : msg,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: VoiceCommandStatus.error,
          error: e.toString(),
        );
      }
    }
  }

  // ---------------------------------------------------------------------------
  // CUSTOMER MATCHING
  // ---------------------------------------------------------------------------

  Future<void> _matchCustomer(VoiceCommand command) async {
    if (!mounted) return;

    if (command.isAddCustomer) {
      state = state.copyWith(
        status: VoiceCommandStatus.ready,
        command: command,
      );
      return;
    }

    if (command.customerName.trim().isEmpty) {
      state = state.copyWith(
        status: command.isUnknown
            ? VoiceCommandStatus.error
            : VoiceCommandStatus.ready,
        error: command.isUnknown ? 'unknown_action' : null,
      );
      return;
    }

    state = state.copyWith(status: VoiceCommandStatus.customerMatching);

    try {
      final results = await _customerRepo.search(command.customerName);
      if (!mounted) return;

      if (results.length == 1) {
        state = state.copyWith(
          status: VoiceCommandStatus.ready,
          matchedCustomers: results,
          selectedCustomer: results.first,
          command: command.copyWith(customerId: results.first.id),
        );
        if (command.isRecordPayment || command.isViewBalance || command.isDeleteDebt) {
          await _fetchRemainingDebts(results.first.id);
        }
        if (command.isViewBalance || command.isViewHistory) {
          await _fetchCustomerBalance(results.first.id);
        }
        if (command.isViewHistory) {
          await _fetchTransactionHistory(results.first.id);
        }
      } else {
        state = state.copyWith(
          status: VoiceCommandStatus.ready,
          matchedCustomers: results,
          command: command,
        );
      }
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: VoiceCommandStatus.ready,
          matchedCustomers: const [],
          command: command,
        );
      }
    }
  }

  Future<void> _fetchRemainingDebts(String customerId) async {
    if (!mounted) return;
    try {
      final debts = await _txRepo.getDebtsWithRemaining(customerId);
      if (mounted) {
        state = state.copyWith(remainingDebts: debts);
      }
    } catch (_) {}
  }

  Future<void> _fetchCustomerBalance(String customerId) async {
    if (!mounted) return;
    try {
      final balance = await _txRepo.getCustomerBalance(customerId);
      if (mounted) {
        state = state.copyWith(customerBalance: balance);
      }
    } catch (_) {}
  }

  Future<void> _fetchTransactionHistory(String customerId) async {
    if (!mounted) return;
    try {
      final transactions = await _txRepo.getByCustomer(customerId);
      if (mounted) {
        state = state.copyWith(transactionHistory: transactions);
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------------
  // USER ACTIONS
  // ---------------------------------------------------------------------------

  void selectCustomer(dynamic customer) {
    if (!mounted) return;
    state = state.copyWith(
      selectedCustomer: customer,
      command: state.command?.copyWith(customerId: customer.id),
      clearSelectedDebtId: true,
      clearMaxPayment: true,
      clearPaymentWarning: true,
      clearCustomerBalance: true,
      clearRemainingDebts: true,
      clearTransactionHistory: true,
    );
    if (state.command?.isRecordPayment == true ||
        state.command?.isViewBalance == true ||
        state.command?.isDeleteDebt == true) {
      _fetchRemainingDebts(customer.id);
    }
    if (state.command?.isViewBalance == true ||
        state.command?.isViewHistory == true) {
      _fetchCustomerBalance(customer.id);
    }
    if (state.command?.isViewHistory == true) {
      _fetchTransactionHistory(customer.id);
    }
  }

  void selectDebt(String debtId, double max) {
    if (!mounted || state.command == null) return;
    state = state.copyWith(
      selectedDebtId: debtId,
      maxPayment: max,
      command: state.command!.copyWith(totalAmount: max),
      clearPaymentWarning: true,
    );
  }

  void updateAmount(double amount) {
    if (!mounted || state.command == null) return;
    final max = state.maxPayment;
    String? warning;
    double clamped = amount;
    if (max != null && amount > max) {
      clamped = max;
      warning = 'amount_exceeds_remaining';
    }
    state = state.copyWith(
      command: state.command!.copyWith(totalAmount: clamped),
      paymentWarning: warning,
    );
  }

  void updateItem(int index, VoiceCommandItem updated) {
    if (!mounted || state.command == null) return;
    final items = List<VoiceCommandItem>.from(state.command!.items);
    if (index < 0 || index >= items.length) return;
    items[index] = updated;
    final total = items.fold(0.0, (sum, i) => sum + i.amount);
    state = state.copyWith(
      command: state.command!.copyWith(items: items, totalAmount: total),
    );
  }

  void removeItem(int index) {
    if (!mounted || state.command == null) return;
    final items = List<VoiceCommandItem>.from(state.command!.items);
    if (index < 0 || index >= items.length) return;
    items.removeAt(index);
    final total = items.fold(0.0, (sum, i) => sum + i.amount);
    state = state.copyWith(
      command: state.command!.copyWith(items: items, totalAmount: total),
    );
  }

  void reRecord() {
    reset();
    startRecording();
  }

  void reset() {
    _ampSub?.cancel();
    _ampSub = null;
    _recorder.stop();
    state = const VoiceCommandState();
  }

  Future<bool> executePayment(ProviderContainer container) async {
    if (!mounted) return false;
    final cmd = state.command;
    if (cmd == null || cmd.customerId == null) return false;
    if (state.selectedDebtId == null) return false;

    state = state.copyWith(status: VoiceCommandStatus.saving);

    try {
      await recordPayment(
        container,
        customerId: cmd.customerId!,
        amount: cmd.totalAmount,
        debtId: state.selectedDebtId,
        note: cmd.note,
      );
      if (mounted) {
        state = state.copyWith(saveSuccess: true);
      }
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: VoiceCommandStatus.ready,
          error: e.toString(),
        );
      }
      return false;
    }
  }

  Future<bool> executeDeleteDebt(ProviderContainer container) async {
    if (!mounted) return false;
    final cmd = state.command;
    if (cmd == null || cmd.customerId == null) return false;
    if (state.selectedDebtId == null) return false;

    state = state.copyWith(status: VoiceCommandStatus.saving);

    try {
      await deleteDebt(
        container,
        state.selectedDebtId!,
        cmd.customerId!,
      );
      if (mounted) {
        state = state.copyWith(saveSuccess: true);
      }
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: VoiceCommandStatus.ready,
          error: e.toString(),
        );
      }
      return false;
    }
  }

  Future<bool> confirmAddCustomer(ProviderContainer container) async {
    if (!mounted) return false;
    final cmd = state.command;
    if (cmd == null || cmd.customerName.trim().isEmpty) return false;

    state = state.copyWith(status: VoiceCommandStatus.saving);

    try {
      await addCustomer(
        container,
        name: cmd.customerName.trim(),
        phone: cmd.phone?.trim().isEmpty == true ? null : cmd.phone?.trim(),
      );
      if (mounted) {
        state = state.copyWith(saveSuccess: true);
      }
      return true;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          status: VoiceCommandStatus.ready,
          error: e.toString(),
        );
      }
      return false;
    }
  }

  @override
  void dispose() {
    _ampSub?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
