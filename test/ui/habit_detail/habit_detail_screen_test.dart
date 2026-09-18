import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/database/database.dart' as d;
import 'package:kusari/models/date.dart';
import 'package:kusari/providers/database_provider.dart';
import 'package:kusari/repositories/habit_repository.dart';
import 'package:kusari/ui/habit_detail/habit_detail_screen.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late d.AppDatabase db;
  late HabitRepository repository;
  late String habitId;
  final today = Date.today();

  Widget buildApp(String id) {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(home: HabitDetailScreen(habitId: id)),
    );
  }

  setUp(() async {
    db = d.AppDatabase(NativeDatabase.memory());
    repository = HabitRepository(db);
    await repository.addHabit('筋トレ');
    habitId = (await repository.getHabits()).single.id;
  });

  tearDown(() => db.close());

  testWidgets('現在ストリーク・過去最長・累計が表示される', (tester) async {
    await repository.toggleCompletion(habitId, today.previous, today);
    await repository.toggleCompletion(habitId, today, today);

    await tester.pumpWidget(buildApp(habitId));
    await tester.pumpAndSettle();

    expect(find.text('🔥2'), findsOneWidget);
    expect(find.text('過去最長: 2'), findsOneWidget);
    expect(find.text('累計: 2'), findsOneWidget);
  });

  testWidgets('直近14日のドット列のうち達成日は塗りつぶされる', (tester) async {
    await repository.toggleCompletion(habitId, today, today);

    await tester.pumpWidget(buildApp(habitId));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.circle), findsOneWidget);
    expect(find.byIcon(Icons.circle_outlined), findsNWidgets(13));
  });

  testWidgets('今日のドットをタップすると完了になりストリークが更新される', (tester) async {
    await tester.pumpWidget(buildApp(habitId));
    await tester.pumpAndSettle();

    expect(find.text('🔥0'), findsOneWidget);

    await tester.tap(find.byKey(ValueKey('dot-${today.epochDay}')));
    await tester.pumpAndSettle();

    expect(find.text('🔥1'), findsOneWidget);
    expect(find.byIcon(Icons.circle), findsOneWidget);
  });

  testWidgets('一昨日のドットはタップしても変化しない（編集不可）', (tester) async {
    await tester.pumpWidget(buildApp(habitId));
    await tester.pumpAndSettle();

    final twoDaysAgo = today.previous.previous;
    await tester.tap(find.byKey(ValueKey('dot-${twoDaysAgo.epochDay}')));
    await tester.pumpAndSettle();

    expect(find.text('🔥0'), findsOneWidget);
  });

  testWidgets('週と月の集計が表示される', (tester) async {
    await repository.toggleCompletion(habitId, today, today);

    await tester.pumpWidget(buildApp(habitId));
    await tester.pumpAndSettle();

    expect(find.textContaining('今週:'), findsOneWidget);
    expect(find.textContaining('今月:'), findsOneWidget);
  });

  testWidgets('編集アイコンをタップすると習慣編集画面に遷移する', (tester) async {
    await tester.pumpWidget(buildApp(habitId));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.edit));
    await tester.pumpAndSettle();

    expect(find.text('習慣を編集'), findsOneWidget);
  });
}
