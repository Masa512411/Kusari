import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kusari/models/date.dart';
import 'package:kusari/providers/habit_repository_provider.dart';
import 'package:kusari/providers/habit_summaries_provider.dart';
import 'package:kusari/ui/habit_detail/habit_detail_screen.dart';
import 'package:kusari/ui/habit_edit/habit_edit_screen.dart';
import 'package:kusari/ui/home/habit_chain_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaries = ref.watch(habitSummariesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('kusari')),
      body: summaries.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('習慣がまだありません'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final summary = list[index];
              return HabitChainCard(
                summary: summary,
                onToggle: () => _toggleToday(ref, summary.habit.id),
                onOpenDetail: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        HabitDetailScreen(habitId: summary.habit.id),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const HabitEditScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _toggleToday(WidgetRef ref, String habitId) async {
    final today = Date.today();
    await ref
        .read(habitRepositoryProvider)
        .toggleCompletion(habitId, today, today);
    ref.invalidate(habitSummariesProvider);
  }
}
