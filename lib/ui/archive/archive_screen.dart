import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kusari/providers/archived_habits_provider.dart';
import 'package:kusari/ui/habit_edit/habit_edit_screen.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final archived = ref.watch(archivedHabitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('アーカイブ済み')),
      body: archived.when(
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('アーカイブ済みの習慣はありません'));
          }
          return ListView.separated(
            itemCount: list.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final habit = list[index];
              return ListTile(
                title: Text(habit.name),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HabitEditScreen(initialHabit: habit),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('エラー: $error')),
      ),
    );
  }
}
