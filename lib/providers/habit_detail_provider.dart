import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kusari/logic/stats_calculator.dart';
import 'package:kusari/logic/streak_calculator.dart';
import 'package:kusari/models/date.dart';
import 'package:kusari/models/habit.dart';
import 'package:kusari/providers/habit_repository_provider.dart';

const recentDaysCount = 14;

class HabitDetail {
  final Habit habit;
  final int currentStreak;
  final int longestStreak;
  final int totalCompletions;
  final PeriodStats weeklyStats;
  final PeriodStats monthlyStats;
  final List<Date> recentDays;
  final Set<Date> completions;

  const HabitDetail({
    required this.habit,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalCompletions,
    required this.weeklyStats,
    required this.monthlyStats,
    required this.recentDays,
    required this.completions,
  });
}

final habitDetailProvider = FutureProvider.family<HabitDetail, String>((
  ref,
  habitId,
) async {
  final repository = ref.watch(habitRepositoryProvider);
  final habits = await repository.getHabits(includeArchived: true);
  final habit = habits.firstWhere((h) => h.id == habitId);
  final completions = await repository.getCompletions(habitId);
  final today = Date.today();

  final recentDays = [
    for (var i = recentDaysCount - 1; i >= 0; i--) Date(today.epochDay - i),
  ];

  return HabitDetail(
    habit: habit,
    currentStreak: currentStreak(completions, today),
    longestStreak: longestStreak(completions, today),
    totalCompletions: totalCompletions(completions, today),
    weeklyStats: weeklyStats(completions, today.startOfWeek, today),
    monthlyStats: monthlyStats(
      completions,
      today.toDateTime().year,
      today.toDateTime().month,
      today,
    ),
    recentDays: recentDays,
    completions: completions,
  );
});
