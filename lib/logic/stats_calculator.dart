import 'package:kusari/models/date.dart';

class PeriodStats {
  final int completedDays; // 分子
  final int totalDays; // 分母（週=7、月=その月の日数）
  final int longestRun; // 期間内の最長連続

  const PeriodStats({
    required this.completedDays,
    required this.totalDays,
    required this.longestRun,
  });

  double get rate => completedDays / totalDays;
}

PeriodStats _periodStats(
  Set<Date> completions,
  Date start,
  Date end,
  Date today,
) {
  final periodDates =
      completions.where((d) => start <= d && d <= end && d <= today).toList()
        ..sort();

  var longestRun = 0;
  var run = 0;
  Date? previous;
  for (final d in periodDates) {
    run = (previous != null && d.epochDay - previous.epochDay == 1)
        ? run + 1
        : 1;
    longestRun = run > longestRun ? run : longestRun;
    previous = d;
  }

  return PeriodStats(
    completedDays: periodDates.length,
    totalDays: end.epochDay - start.epochDay + 1,
    longestRun: longestRun,
  );
}

PeriodStats weeklyStats(Set<Date> completions, Date weekStart, Date today) {
  final weekEnd = Date(weekStart.epochDay + 6);
  return _periodStats(completions, weekStart, weekEnd, today);
}

PeriodStats monthlyStats(
  Set<Date> completions,
  int year,
  int month,
  Date today,
) {
  final start = Date.fromLocal(DateTime(year, month, 1));
  final end = Date.fromLocal(DateTime(year, month + 1, 0));
  return _periodStats(completions, start, end, today);
}
