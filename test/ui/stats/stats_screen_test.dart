import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/database/database.dart' as d;
import 'package:kusari/models/date.dart';
import 'package:kusari/providers/database_provider.dart';
import 'package:kusari/repositories/habit_repository.dart';
import 'package:kusari/ui/stats/stats_screen.dart';

void main() {
  setUpAll(() {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  });

  late d.AppDatabase db;
  late HabitRepository repository;

  Widget buildApp() {
    return ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: const MaterialApp(home: StatsScreen()),
    );
  }

  setUp(() {
    db = d.AppDatabase(NativeDatabase.memory());
    repository = HabitRepository(db);
  });

  tearDown(() => db.close());

  testWidgets('習慣が0件のとき空状態メッセージが表示される', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('習慣がまだありません'), findsOneWidget);
  });

  testWidgets('習慣ごとの週間達成率が表示される', (tester) async {
    await repository.addHabit('筋トレ');
    final habitId = (await repository.getHabits()).single.id;
    final today = Date.today();
    await repository.toggleCompletion(habitId, today, today);

    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('習慣ごとの週間達成率'), findsOneWidget);
    expect(find.text('筋トレ'), findsOneWidget);
    expect(find.text('14%'), findsOneWidget);
  });
}
