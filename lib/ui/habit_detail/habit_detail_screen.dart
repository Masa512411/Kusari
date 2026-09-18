import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kusari/logic/edit_window.dart';
import 'package:kusari/models/date.dart';
import 'package:kusari/providers/habit_detail_provider.dart';
import 'package:kusari/providers/habit_repository_provider.dart';
import 'package:kusari/providers/habit_summaries_provider.dart';
import 'package:kusari/ui/habit_edit/habit_edit_screen.dart';

class HabitDetailScreen extends ConsumerWidget {
  final String habitId;

  const HabitDetailScreen({super.key, required this.habitId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(habitDetailProvider(habitId));

    final habit = detailAsync.value?.habit;

    return Scaffold(
      appBar: AppBar(
        title: Text(habit?.name ?? ''),
        actions: [
          if (habit != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => HabitEditScreen(initialHabit: habit),
                ),
              ),
            ),
        ],
      ),
      body: detailAsync.when(
        data: (detail) =>
            _HabitDetailBody(habitId: habitId, detail: detail),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
    );
  }
}

class _HabitDetailBody extends ConsumerWidget {
  final String habitId;
  final HabitDetail detail;

  const _HabitDetailBody({required this.habitId, required this.detail});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = Date.today();

    Future<void> toggle(Date date) async {
      await ref
          .read(habitRepositoryProvider)
          .toggleCompletion(habitId, date, today);
      ref.invalidate(habitDetailProvider(habitId));
      ref.invalidate(habitSummariesProvider);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '🔥${detail.currentStreak}',
              style: Theme.of(context).textTheme.displayMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text('過去最長: ${detail.longestStreak}'),
          Text('累計: ${detail.totalCompletions}'),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detail.recentDays.map((date) {
              final completed = detail.completions.contains(date);
              final editable = isEditable(date, today);
              return GestureDetector(
                key: ValueKey('dot-${date.epochDay}'),
                onTap: editable ? () => toggle(date) : null,
                child: Icon(
                  completed ? Icons.circle : Icons.circle_outlined,
                  color: editable ? null : Theme.of(context).disabledColor,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Text(
            '今週: ${detail.weeklyStats.completedDays}/${detail.weeklyStats.totalDays}日',
          ),
          Text(
            '今月: ${detail.monthlyStats.completedDays}/${detail.monthlyStats.totalDays}日',
          ),
        ],
      ),
    );
  }
}
