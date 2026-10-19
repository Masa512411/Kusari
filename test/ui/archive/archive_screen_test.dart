import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/database/database.dart';
import 'package:kusari/providers/database_provider.dart';
import 'package:kusari/repositories/habit_repository.dart';
import 'package:kusari/ui/archive/archive_screen.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  testWidgets('アーカイブ済みが0件のとき空状態メッセージが表示される', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(
            AppDatabase(NativeDatabase.memory()),
          ),
        ],
        child: const MaterialApp(home: ArchiveScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('アーカイブ済みの習慣はありません'), findsOneWidget);
  });

  testWidgets('アーカイブ済みの習慣のみ一覧に表示される', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repository = HabitRepository(db);
    await repository.addHabit('アクティブ');
    await repository.addHabit('休止中');
    final archivedId = (await repository.getHabits())
        .firstWhere((h) => h.name == '休止中')
        .id;
    await repository.setArchived(archivedId, true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: ArchiveScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('休止中'), findsOneWidget);
    expect(find.text('アクティブ'), findsNothing);
  });

  testWidgets('タップすると編集画面に遷移し、アーカイブを解除できる', (tester) async {
    final db = AppDatabase(NativeDatabase.memory());
    final repository = HabitRepository(db);
    await repository.addHabit('休止中');
    final habitId = (await repository.getHabits(
      includeArchived: true,
    )).single.id;
    await repository.setArchived(habitId, true);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(home: ArchiveScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('休止中'));
    await tester.pumpAndSettle();

    expect(find.byType(SwitchListTile), findsOneWidget);

    await tester.tap(find.byType(SwitchListTile));
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    final habits = await repository.getHabits();
    expect(habits.single.archived, isFalse);
  });
}
