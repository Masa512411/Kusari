import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kusari/logic/habit_name_validator.dart';
import 'package:kusari/models/habit.dart';
import 'package:kusari/providers/habit_detail_provider.dart';
import 'package:kusari/providers/habit_repository_provider.dart';
import 'package:kusari/providers/habit_summaries_provider.dart';

class HabitEditScreen extends ConsumerStatefulWidget {
  final Habit? initialHabit;

  const HabitEditScreen({super.key, this.initialHabit});

  @override
  ConsumerState<HabitEditScreen> createState() => _HabitEditScreenState();
}

class _HabitEditScreenState extends ConsumerState<HabitEditScreen> {
  late final TextEditingController _controller;
  late bool _archived;
  String? _errorText;

  bool get _isEditing => widget.initialHabit != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialHabit?.name ?? '');
    _archived = widget.initialHabit?.archived ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final error = validateHabitName(_controller.text);
    if (error != null) {
      setState(() => _errorText = error);
      return;
    }

    final repository = ref.read(habitRepositoryProvider);
    final name = _controller.text.trim();

    if (_isEditing) {
      final habitId = widget.initialHabit!.id;
      await repository.renameHabit(habitId, name);
      await repository.setArchived(habitId, _archived);
      ref.invalidate(habitDetailProvider(habitId));
    } else {
      await repository.addHabit(name);
    }
    ref.invalidate(habitSummariesProvider);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _delete() async {
    final habit = widget.initialHabit!;
    final repository = ref.read(habitRepositoryProvider);
    final recordCount = (await repository.getCompletions(habit.id)).length;

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('習慣を削除しますか？'),
        content: Text('${habit.name}と、これまでの記録$recordCount日分を削除します。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('削除する'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final deleted = await repository.deleteHabit(habit.id);
    ref.invalidate(habitSummariesProvider);

    if (!mounted) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    navigator.popUntil((route) => route.isFirst);
    messenger.showSnackBar(
      SnackBar(
        content: Text('${deleted.habit.name}を削除しました'),
        action: SnackBarAction(
          label: '元に戻す',
          onPressed: () async {
            await repository.undoDelete(deleted);
            ref.invalidate(habitSummariesProvider);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? '習慣を編集' : '習慣を追加')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '習慣の名前',
                errorText: _errorText,
              ),
            ),
            if (_isEditing)
              SwitchListTile(
                title: const Text('アーカイブ'),
                value: _archived,
                onChanged: (value) => setState(() => _archived = value),
              ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: const Text('保存')),
            if (_isEditing) ...[
              const SizedBox(height: 8),
              TextButton(onPressed: _delete, child: const Text('削除')),
            ],
          ],
        ),
      ),
    );
  }
}
