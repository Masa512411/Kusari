import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/database/database.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() => db.close());

    test('Habit と Completion を挿入して読み出せる', () async {
      await db
          .into(db.habits)
          .insert(
            HabitsCompanion.insert(
              id: 'habit1',
              name: 'Test Habit',
              createdAt: 19700,
              sortOrder: 0,
            ),
          );
      await db
          .into(db.completions)
          .insert(CompletionsCompanion.insert(habitId: 'habit1', date: 19700));

      final habits = await db.select(db.habits).get();
      final completions = await db.select(db.completions).get();

      expect(habits, hasLength(1));
      expect(completions, hasLength(1));
      expect(completions.single.habitId, 'habit1');
    });

    test('habitId, date の組み合わせは一意（複合主キー）', () async {
      await db
          .into(db.habits)
          .insert(
            HabitsCompanion.insert(
              id: 'habit1',
              name: 'Test Habit',
              createdAt: 19700,
              sortOrder: 0,
            ),
          );
      await db
          .into(db.completions)
          .insert(CompletionsCompanion.insert(habitId: 'habit1', date: 19700));

      expect(
        () => db
            .into(db.completions)
            .insert(
              CompletionsCompanion.insert(habitId: 'habit1', date: 19700),
            ),
        throwsA(anything),
      );
    });

    test('Habit を削除すると関連する Completion もカスケード削除される', () async {
      await db
          .into(db.habits)
          .insert(
            HabitsCompanion.insert(
              id: 'habit1',
              name: 'Test Habit',
              createdAt: 19700,
              sortOrder: 0,
            ),
          );
      await db
          .into(db.completions)
          .insert(CompletionsCompanion.insert(habitId: 'habit1', date: 19700));

      await db.delete(db.habits).go();

      final completions = await db.select(db.completions).get();
      expect(completions, isEmpty);
    });
  });
}
