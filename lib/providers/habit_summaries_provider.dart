import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kusari/logic/streak_calculator.dart';
import 'package:kusari/models/date.dart';
import 'package:kusari/models/habit.dart';
import 'package:kusari/providers/habit_repository_provider.dart';

class HabitSummary {
  final Habit habit;
  final int currentStreak;
  final bool isCompletedToday;
  final Set<Date> completions;

  const HabitSummary({
    required this.habit,
    required this.currentStreak,
    required this.isCompletedToday,
    required this.completions,
  });
}

final habitSummariesProvider = FutureProvider<List<HabitSummary>>((
  ref,
) async {
  final repository = ref.watch(habitRepositoryProvider);
  final habits = await repository.getHabits();
  final today = Date.today();

  final summaries = <HabitSummary>[];
  for (final habit in habits) {
    final completions = await repository.getCompletions(habit.id);
    summaries.add(
      HabitSummary(
        habit: habit,
        currentStreak: currentStreak(completions, today),
        isCompletedToday: completions.contains(today),
        completions: completions,
      ),
    );
  }
  return summaries;
});
