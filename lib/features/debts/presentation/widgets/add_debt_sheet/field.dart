import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DebtField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final bool decimal;
  final bool autofocus;
  final int? maxLines;
  final List<TextInputFormatter>? formatters;
  const DebtField({
    super.key,
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
