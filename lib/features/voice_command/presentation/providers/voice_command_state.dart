/// VOICE COMMAND FEATURE — PRESENTATION LAYER: STATE
///
/// Immutable state class for the voice command feature.
/// Managed by [VoiceCommandNotifier] via Riverpod's StateNotifier.
///
/// Flow: idle → recording → transcribing → parsing → (customerMatching) → ready | error
/// ---------------------------------------------------------------------------
library;

import 'package:local_debt_management/features/customers/domain/entities/customer.dart';
import '../../../../data/models/transaction.dart';
import '../../domain/entities/voice_command.dart';

enum VoiceCommandStatus {
  idle,
  recording,
  transcribing,
  parsing,
  customerMatching,
  ready,
  error,
  saving,
}

class VoiceCommandState {
  final VoiceCommandStatus status;
  final VoiceCommand? command;
  final List<Customer> matchedCustomers;
  final List<Customer> allCustomers;
  final Customer? selectedCustomer;
  final String? error;
  final DateTime? recordingStarted;
  final double soundLevel;
  final String? recordedFilePath;
  final bool saveSuccess;
  final List<Map<String, dynamic>>? remainingDebts;
  final String? selectedDebtId;
  final double? maxPayment;
  final String? paymentWarning;
  final double? customerBalance;
  final List<Transaction>? transactionHistory;

  const VoiceCommandState({
    this.status = VoiceCommandStatus.idle,
    this.command,
    this.matchedCustomers = const [],
    this.allCustomers = const [],
    this.selectedCustomer,
    this.error,
    this.recordingStarted,
    this.soundLevel = 0.0,
    this.recordedFilePath,
    this.saveSuccess = false,
    this.remainingDebts,
    this.selectedDebtId,
    this.maxPayment,
    this.paymentWarning,
    this.customerBalance,
    this.transactionHistory,
  });

  VoiceCommandState copyWith({
    VoiceCommandStatus? status,
    bool clearCommand = false,
    VoiceCommand? command,
    List<Customer>? matchedCustomers,
    List<Customer>? allCustomers,
    bool clearSelectedCustomer = false,
    Customer? selectedCustomer,
    bool clearError = false,
    String? error,
    bool clearRecordingStarted = false,
    DateTime? recordingStarted,
    double? soundLevel,
    bool clearRecordedFilePath = false,
    String? recordedFilePath,
    bool? saveSuccess,
    bool clearRemainingDebts = false,
    List<Map<String, dynamic>>? remainingDebts,
    bool clearSelectedDebtId = false,
    String? selectedDebtId,
    bool clearMaxPayment = false,
    double? maxPayment,
    bool clearPaymentWarning = false,
    String? paymentWarning,
    bool clearCustomerBalance = false,
    double? customerBalance,
    bool clearTransactionHistory = false,
    List<Transaction>? transactionHistory,
  }) {
    return VoiceCommandState(
      status: status ?? this.status,
      command: clearCommand ? null : (command ?? this.command),
      matchedCustomers: matchedCustomers ?? this.matchedCustomers,
      allCustomers: allCustomers ?? this.allCustomers,
      selectedCustomer: clearSelectedCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      error: clearError ? null : (error ?? this.error),
      recordingStarted: clearRecordingStarted
          ? null
          : (recordingStarted ?? this.recordingStarted),
      soundLevel: soundLevel ?? this.soundLevel,
      recordedFilePath: clearRecordedFilePath
          ? null
          : (recordedFilePath ?? this.recordedFilePath),
      saveSuccess: saveSuccess ?? this.saveSuccess,
      remainingDebts: clearRemainingDebts
          ? null
          : (remainingDebts ?? this.remainingDebts),
      selectedDebtId: clearSelectedDebtId
          ? null
          : (selectedDebtId ?? this.selectedDebtId),
      maxPayment: clearMaxPayment ? null : (maxPayment ?? this.maxPayment),
      paymentWarning: clearPaymentWarning ? null : (paymentWarning ?? this.paymentWarning),
      customerBalance: clearCustomerBalance ? null : (customerBalance ?? this.customerBalance),
      transactionHistory: clearTransactionHistory
          ? null
          : (transactionHistory ?? this.transactionHistory),
    );
  }

  bool get isIdle => status == VoiceCommandStatus.idle;
  bool get isRecording => status == VoiceCommandStatus.recording;
  bool get isTranscribing => status == VoiceCommandStatus.transcribing;
  bool get isParsing => status == VoiceCommandStatus.parsing;
  bool get isCustomerMatching => status == VoiceCommandStatus.customerMatching;
  bool get isReady => status == VoiceCommandStatus.ready;
  bool get isError => status == VoiceCommandStatus.error;
  bool get isSaving => status == VoiceCommandStatus.saving;
  bool get isProcessing =>
      isTranscribing || isParsing || isCustomerMatching || isSaving;

  bool get hasSingleMatch => matchedCustomers.length == 1;
  bool get hasMultipleMatches =>
      matchedCustomers.length > 1 && matchedCustomers.length <= 3;
  bool get hasNoMatches => matchedCustomers.isEmpty && !isProcessing;
}
