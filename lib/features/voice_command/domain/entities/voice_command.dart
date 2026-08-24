/// VOICE COMMAND FEATURE — DOMAIN LAYER: ENTITIES
///
/// Core entities for the voice command feature.
/// The domain layer has ZERO dependencies on external packages.
/// ---------------------------------------------------------------------------
library;

/// Actions the AI can detect from a voice command.
enum VoiceAction {
  addDebt,
  recordPayment,
  viewBalance,
  addCustomer,
  deleteDebt,
  viewHistory,
  unknown,
}

/// A parsed voice command from the AI.
///
/// Contains the detected action, extracted customer name, items (for add_debt),
/// and the raw transcript. The customerId is resolved locally after AI parsing.
class VoiceCommand {
  final VoiceAction action;
  final String customerName;
  final String? customerId;
  final String? phone;
  final List<VoiceCommandItem> items;
  final double totalAmount;
  final DateTime? dueDate;
  final String? note;
  final String transcript;

  const VoiceCommand({
    required this.action,
    required this.customerName,
    this.customerId,
    this.phone,
    this.items = const [],
    this.totalAmount = 0,
    this.dueDate,
    this.note,
    required this.transcript,
  });

  VoiceCommand copyWith({
    VoiceAction? action,
    String? customerName,
    String? customerId,
    bool clearCustomerId = false,
    String? phone,
    bool clearPhone = false,
    List<VoiceCommandItem>? items,
    double? totalAmount,
    bool clearDueDate = false,
    DateTime? dueDate,
    bool clearNote = false,
    String? note,
  }) {
    return VoiceCommand(
      action: action ?? this.action,
      customerName: customerName ?? this.customerName,
      customerId: clearCustomerId ? null : (customerId ?? this.customerId),
      phone: clearPhone ? null : (phone ?? this.phone),
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      note: clearNote ? null : (note ?? this.note),
      transcript: transcript,
    );
  }

  bool get isAddDebt => action == VoiceAction.addDebt;
  bool get isRecordPayment => action == VoiceAction.recordPayment;
  bool get isViewBalance => action == VoiceAction.viewBalance;
  bool get isAddCustomer => action == VoiceAction.addCustomer;
  bool get isDeleteDebt => action == VoiceAction.deleteDebt;
  bool get isViewHistory => action == VoiceAction.viewHistory;
  bool get isUnknown => action == VoiceAction.unknown;
  bool get hasCustomerMatch => customerId != null;
}

/// A single item extracted from a voice command (for add_debt).
class VoiceCommandItem {
  final String name;
  final double amount;

  const VoiceCommandItem({required this.name, required this.amount});

  VoiceCommandItem copyWith({String? name, double? amount}) {
    return VoiceCommandItem(
      name: name ?? this.name,
      amount: amount ?? this.amount,
    );
  }

  String toNoteLine() => '$name: ${amount.toInt()}';
}
