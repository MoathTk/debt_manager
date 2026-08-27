import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class RecordingIndicator extends StatefulWidget {
  final AppLocalizations l10n;
  final double soundLevel;
  final DateTime? recordingStarted;
  const RecordingIndicator({
    super.key,
    required this.l10n,
    this.soundLevel = 0.0,
    this.recordingStarted,
  });

  @override
  State<RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<RecordingIndicator> {
  Timer? _timer;
  String _elapsed = '0:00';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(RecordingIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recordingStarted != null && _timer == null) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || widget.recordingStarted == null) {
        _timer?.cancel();
        return;
      }
      final diff = DateTime.now().difference(widget.recordingStarted!);
      setState(() {
        _elapsed =
            '${diff.inMinutes}:${(diff.inSeconds % 60).toString().padLeft(2, '0')}';
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          SoundLevelBars(level: widget.soundLevel, color: cs.error),
          const SizedBox(width: 8),
          Text(
            widget.l10n.listening,
            style: TextStyle(
              color: cs.error,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            _elapsed,
            style: TextStyle(
              color: cs.onErrorContainer.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              fontSize: 12,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class SoundLevelBars extends StatelessWidget {
  final double level;
  final Color color;
  const SoundLevelBars({super.key, required this.level, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(5, (i) {
          final multipliers = [0.4, 0.7, 1.0, 0.7, 0.4];
          final target = (level * multipliers[i]).clamp(0.15, 1.0);
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 3,
              height: target * 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
          );
        }),
      ),
    );
  }
}
