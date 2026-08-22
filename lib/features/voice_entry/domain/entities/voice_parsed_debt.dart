/// VOICE ENTRY FEATURE — DOMAIN LAYER
///
/// This file defines the core entities for voice-based debt entry.
/// The domain layer is the innermost layer — it has ZERO dependencies
/// on Flutter, Firebase, SQLite, or any external package.
///
/// ARCHITECTURE RULE: Domain entities must never import from data/ or presentation/.
/// ---------------------------------------------------------------------------
library;

/// A single item parsed from a voice transcript.
///
/// Represents one product/service with its name and amount.
/// Example: "egg: 2000" → VoiceParsedItem(name: 'egg', amount: 2000)
class VoiceParsedItem {
  final String name;
  final double amount;

  const VoiceParsedItem({required this.name, required this.amount});

  VoiceParsedItem copyWith({String? name, double? amount}) {
    return VoiceParsedItem(
      name: name ?? this.name,
      amount: amount ?? this.amount,
    );
  }

  /// Format as "name: amount" for display in the note field.
  String toNoteLine() => '$name: ${amount.toInt()}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceParsedItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          amount == other.amount;

  @override
  int get hashCode => name.hashCode ^ amount.hashCode;

  @override
  String toString() => 'VoiceParsedItem(name: $name, amount: $amount)';
}

/// The complete parsed result from a voice transcript.
///
/// Contains all extracted items, the computed total, and an optional
/// due date if the speaker mentioned one.
class VoiceParsedDebt {
  final List<VoiceParsedItem> items;
  final double totalAmount;
  final DateTime? dueDate;

  const VoiceParsedDebt({
    required this.items,
    required this.totalAmount,
    this.dueDate,
  });

  /// Format items as a multi-line string for the debt note field.
  ///
  /// Example: "egg: 2000\ncola: 1250"
  String get formattedItems => items.map((i) => i.toNoteLine()).join('\n');

  VoiceParsedDebt copyWith({
    List<VoiceParsedItem>? items,
    double? totalAmount,
    bool clearDueDate = false,
    DateTime? dueDate,
  }) {
    return VoiceParsedDebt(
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    );
  }

  @override
  String toString() =>
      'VoiceParsedDebt(items: $items, total: $totalAmount, dueDate: $dueDate)';
}
