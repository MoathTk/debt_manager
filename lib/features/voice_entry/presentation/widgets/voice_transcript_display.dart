/// VOICE ENTRY FEATURE — PRESENTATION LAYER: TRANSCRIPT DISPLAY
///
/// Shows the raw transcript text from speech recognition.
/// Displayed as a small, non-editable preview below the input fields.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';

class VoiceTranscriptDisplay extends StatelessWidget {
  final String transcript;

  const VoiceTranscriptDisplay({super.key, required this.transcript});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.transcribe_rounded,
            size: 16,
            color: cs.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              transcript,
              style: TextStyle(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
