import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kusari/logic/stats_calculator.dart';
import 'package:kusari/models/date.dart';
import 'package:kusari/models/habit.dart';
import 'package:kusari/providers/habit_repository_provider.dart';

class HabitWeeklyRate {
  final Habit habit;
  final PeriodStats stats;

  const HabitWeeklyRate({required this.habit, required this.stats});
}

final habitWeeklyRatesProvider = FutureProvider<List<HabitWeeklyRate>>((
  ref,
) async {
  final repository = ref.watch(habitRepositoryProvider);
  final habits = await repository.getHabits();
  final today = Date.today();
  final weekStart = today.startOfWeek;

  final rates = <HabitWeeklyRate>[];
  for (final habit in habits) {
    final completions = await repository.getCompletions(habit.id);
    rates.add(
      HabitWeeklyRate(
        habit: habit,
        stats: weeklyStats(completions, weekStart, today),
      ),
    );
  }
  return rates;
});
