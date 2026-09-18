import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/database/database.dart' as d;
import 'package:kusari/models/habit.dart';
import 'package:kusari/providers/database_provider.dart';
import 'package:kusari/repositories/habit_repository.dart';
import 'package:kusari/ui/habit_edit/habit_edit_screen.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late d.AppDatabase db;
  late HabitRepository repository;

  Widget buildApp(Habit? initialHabit) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: HabitEditScreen(initialHabit: initialHabit)),
    );
  }

  setUp(() {
    db = d.AppDatabase(NativeDatabase.memory());
    repository = HabitRepository(db);
  });

  tearDown(() => db.close());

  testWidgets('追加モード: 空文字で保存しようとするとエラーが表示される', (tester) async {
    await tester.pumpWidget(buildApp(null));
    await tester.pumpAndSettle();

    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(find.text('名前を入力してください'), findsOneWidget);
  });

  testWidgets('追加モード: 名前を入力して保存すると習慣が作成される', (tester) async {
    await tester.pumpWidget(buildApp(null));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '筋トレ');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    final habits = await repository.getHabits();
    expect(habits.single.name, '筋トレ');
  });

  testWidgets('編集モード: 初期値が名前欄に表示される', (tester) async {
    await repository.addHabit('筋トレ');
    final habit = (await repository.getHabits()).single;

    await tester.pumpWidget(buildApp(habit));
    await tester.pumpAndSettle();

    expect(find.text('筋トレ'), findsOneWidget);
  });

  testWidgets('編集モード: 名前を変更して保存するとrenameされる', (tester) async {
    await repository.addHabit('筋トレ');
    final habit = (await repository.getHabits()).single;

    await tester.pumpWidget(buildApp(habit));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '腹筋');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    final habits = await repository.getHabits();
    expect(habits.single.name, '腹筋');
  });

  testWidgets('編集モード: アーカイブをオンにして保存するとarchivedがtrueになる', (tester) async {
    await repository.addHabit('筋トレ');
    final habit = (await repository.getHabits()).single;

    await tester.pumpWidget(buildApp(habit));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(SwitchListTile));
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    final habits = await repository.getHabits();
    expect(habits.single.archived, isTrue);
  });

  testWidgets('削除: 確認ダイアログで確定すると削除されUndoスナックバーが表示される', (tester) async {
    await repository.addHabit('筋トレ');
    final habit = (await repository.getHabits()).single;

    await tester.pumpWidget(buildApp(habit));
    await tester.pumpAndSettle();

    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();

    expect(find.text('筋トレと、これまでの記録0日分を削除します。'), findsOneWidget);

    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();

    final habits = await repository.getHabits();
    expect(habits, isEmpty);
    expect(find.text('元に戻す'), findsOneWidget);
  });

  testWidgets('削除後にUndoを押すと元に戻る', (tester) async {
    await repository.addHabit('筋トレ');
    final habit = (await repository.getHabits()).single;

    await tester.pumpWidget(buildApp(habit));
    await tester.pumpAndSettle();

    await tester.tap(find.text('削除'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('削除する'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('元に戻す'));
    await tester.pumpAndSettle();

    final habits = await repository.getHabits();
    expect(habits.single.name, '筋トレ');
  });
}
