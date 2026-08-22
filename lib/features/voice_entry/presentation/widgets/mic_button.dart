/// VOICE ENTRY FEATURE — PRESENTATION LAYER: MIC BUTTON
///
/// Animated microphone button for voice input.
/// Shows a pulsing animation while recording and a spinner while processing.
/// ---------------------------------------------------------------------------
library;

import 'package:flutter/material.dart';

class MicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isRecording;
  final bool isProcessing;

  const MicButton({
    super.key,
    required this.onPressed,
    this.isRecording = false,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      width: 44,
      height: 44,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isRecording
              ? cs.error
              : isProcessing
                  ? cs.surfaceContainerHighest
                  : cs.primaryContainer,
          boxShadow: isRecording
              ? [
                  BoxShadow(
                    color: cs.error.withValues(alpha: 0.4),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: IconButton(
          onPressed: isProcessing ? null : onPressed,
          icon: isProcessing
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.onSurfaceVariant,
                  ),
                )
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isRecording ? Icons.mic : Icons.mic_none_rounded,
                    key: ValueKey(isRecording),
                    color: isRecording ? cs.onError : cs.onPrimaryContainer,
                    size: 22,
                  ),
                ),
        ),
      ),
    );
  }
}
