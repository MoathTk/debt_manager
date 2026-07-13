import '../l10n/app_localizations.dart';
import 'period_chips.dart';

/// Date calculation helpers for period navigation.
class PeriodHelper {
  static ({DateTime start, DateTime end}) dateRange(
    PeriodType type,
    DateTime ref,
  ) {
    switch (type) {
      case PeriodType.day:
        final d = DateTime(ref.year, ref.month, ref.day);
        return (start: d, end: d.add(const Duration(days: 1)));
      case PeriodType.week:
        final wd = ref.weekday;
        final mon = DateTime(ref.year, ref.month, ref.day - wd + 1);
        return (start: mon, end: mon.add(const Duration(days: 7)));
      case PeriodType.month:
        final first = DateTime(ref.year, ref.month, 1);
        final last = DateTime(ref.year, ref.month + 1, 0);
        return (start: first, end: last.add(const Duration(days: 1)));
      case PeriodType.year:
        final first = DateTime(ref.year, 1, 1);
        final last = DateTime(ref.year, 12, 31);
        return (start: first, end: last.add(const Duration(days: 1)));
    }
  }

  static DateTime shift(PeriodType type, DateTime ref, int dir) {
    switch (type) {
      case PeriodType.day:
        return ref.add(Duration(days: dir));
      case PeriodType.week:
        return ref.add(Duration(days: dir * 7));
      case PeriodType.month:
        return DateTime(ref.year, ref.month + dir, 1);
      case PeriodType.year:
        return DateTime(ref.year + dir, 1, 1);
    }
  }

  static String label(PeriodType type, DateTime ref, AppLocalizations l10n) {
    switch (type) {
      case PeriodType.day:
        return '${ref.day}/${ref.month}/${ref.year}';
      case PeriodType.week:
        final d = dateRange(type, ref);
        final end = d.end.subtract(const Duration(days: 1));
        return '${d.start.day}/${d.start.month} – ${end.day}/${end.month}';
      case PeriodType.month:
        return '${ref.month}/${ref.year}';
      case PeriodType.year:
        return '${ref.year}';
    }
  }

  static bool isCurrent(PeriodType type, DateTime ref) {
    final now = DateTime.now();
    switch (type) {
      case PeriodType.day:
        return ref.year == now.year &&
            ref.month == now.month &&
            ref.day == now.day;
      case PeriodType.week:
        final d = dateRange(type, ref);
        return now.isAfter(d.start.subtract(const Duration(days: 1))) &&
            now.isBefore(d.end);
      case PeriodType.month:
        return ref.year == now.year && ref.month == now.month;
      case PeriodType.year:
        return ref.year == now.year;
    }
  }
}
