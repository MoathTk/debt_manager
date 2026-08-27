import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_debt_management/l10n/app_localizations.dart';

class LiveTranscript extends StatefulWidget {
  final AppLocalizations l10n;
  final String? transcript;
  final double soundLevel;
  final DateTime? recordingStarted;
  const LiveTranscript({
    super.key,
    required this.l10n,
    this.transcript,
    this.soundLevel = 0.0,
    this.recordingStarted,
  });

  @override
  State<LiveTranscript> createState() => _LiveTranscriptState();
}

class _LiveTranscriptState extends State<LiveTranscript> {
  Timer? _timer;
  String _elapsed = '0:00';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(LiveTranscript oldWidget) {
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
    final hasText = widget.transcript?.isNotEmpty == true;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
          const SizedBox(height: 10),
          Text(
            hasText ? widget.transcript! : widget.l10n.speakNow,
            style: TextStyle(
              fontSize: 15,
              color: hasText
                  ? cs.onErrorContainer
                  : cs.onErrorContainer.withValues(alpha: 0.5),
              fontStyle: hasText ? FontStyle.normal : FontStyle.italic,
              height: 1.4,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
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
          // Stagger: center bars are taller, edge bars shorter
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
