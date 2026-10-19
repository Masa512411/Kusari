import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kusari/models/habit.dart';
import 'package:kusari/providers/habit_repository_provider.dart';

final archivedHabitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repository = ref.watch(habitRepositoryProvider);
  final habits = await repository.getHabits(includeArchived: true);
  return habits.where((h) => h.archived).toList();
});
