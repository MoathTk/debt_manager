/// VOICE ENTRY FEATURE — PRESENTATION LAYER: EDITABLE TRANSCRIPT
///
/// Shows the recorded transcript in an editable text field with
/// Parse and Cancel actions. Displayed after recording stops so
/// the user can review/correct before sending to AI.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class EditableTranscript extends StatefulWidget {
  final String transcript;
  final ValueChanged<String> onParse;
  final VoidCallback onCancel;

  const EditableTranscript({
    super.key,
    required this.transcript,
    required this.onParse,
    required this.onCancel,
  });

  @override
  State<EditableTranscript> createState() => _EditableTranscriptState();
}

class _EditableTranscriptState extends State<EditableTranscript> {
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.transcript);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.edit_note, size: 16, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                l10n.editTranscript,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _ctrl,
            maxLines: 3,
            style: const TextStyle(fontSize: 15, height: 1.4),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => widget.onParse(_ctrl.text),
                  icon: const Icon(Icons.send, size: 18),
                  label: Text(l10n.parse),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
