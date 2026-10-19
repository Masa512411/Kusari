import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/database/database.dart' as d;
import 'package:kusari/models/date.dart';
import 'package:kusari/repositories/habit_repository.dart';

void main() {
  group('HabitRepository', () {
    late d.AppDatabase db;
    late HabitRepository repository;

    setUp(() {
      db = d.AppDatabase(NativeDatabase.memory());
      repository = HabitRepository(db);
    });

    tearDown(() => db.close());

    test('習慣を追加すると一覧に1件現れる', () async {
      await repository.addHabit('筋トレ');

      final habits = await repository.getHabits();

      expect(habits, hasLength(1));
      expect(habits.single.name, '筋トレ');
    });
  });

  group('HabitRepository.toggleCompletion', () {
    late d.AppDatabase db;
    late HabitRepository repository;
    late String habitId;
    late Date today;

    setUp(() async {
      db = d.AppDatabase(NativeDatabase.memory());
      repository = HabitRepository(db);
      await repository.addHabit('筋トレ');
      habitId = (await repository.getHabits()).single.id;
      today = Date.fromLocal(DateTime(2024, 1, 10));
    });

    tearDown(() => db.close());

    test('今日をトグルすると達成記録が追加される', () async {
      await repository.toggleCompletion(habitId, today, today);

      final completions = await repository.getCompletions(habitId);
      expect(completions, {today});
    });

    test('達成済みの今日を再度トグルすると記録が消える', () async {
      await repository.toggleCompletion(habitId, today, today);
      await repository.toggleCompletion(habitId, today, today);

      final completions = await repository.getCompletions(habitId);
      expect(completions, isEmpty);
    });

    test('昨日をトグルすると達成記録が追加される', () async {
      final yesterday = today.previous;

      await repository.toggleCompletion(habitId, yesterday, today);

      final completions = await repository.getCompletions(habitId);
      expect(completions, {yesterday});
    });

    test('一昨日をトグルしようとすると拒否される', () async {
      final twoDaysAgo = today.previous.previous;

      expect(
        () => repository.toggleCompletion(habitId, twoDaysAgo, today),
        throwsA(isA<EditWindowViolation>()),
      );
    });

    test('明日をトグルしようとすると拒否される', () async {
      final tomorrow = today.next;

      expect(
        () => repository.toggleCompletion(habitId, tomorrow, today),
        throwsA(isA<EditWindowViolation>()),
      );
    });
  });

  group('HabitRepository 並び順', () {
    late d.AppDatabase db;
    late HabitRepository repository;

    setUp(() {
      db = d.AppDatabase(NativeDatabase.memory());
      repository = HabitRepository(db);
    });

    tearDown(() => db.close());

    test('新規作成した習慣は一覧の末尾に追加される（sortOrderの昇順で返る）', () async {
      await repository.addHabit('1番目');
      await repository.addHabit('2番目');
      await repository.addHabit('3番目');

      final habits = await repository.getHabits();

      expect(habits.map((h) => h.name).toList(), ['1番目', '2番目', '3番目']);
    });

    test('reorderHabits で渡した順序が一覧に反映される', () async {
      await repository.addHabit('1番目');
      await repository.addHabit('2番目');
      await repository.addHabit('3番目');
      final habits = await repository.getHabits();
      final ids = habits.map((h) => h.id).toList();

      await repository.reorderHabits([ids[2], ids[0], ids[1]]);

      final reordered = await repository.getHabits();
      expect(reordered.map((h) => h.id).toList(), [ids[2], ids[0], ids[1]]);
    });

    test('全件削除後に新規作成すると sortOrder が 0 から採番される', () async {
      await repository.addHabit('最初の習慣');
      final firstId = (await repository.getHabits()).single.id;
      await repository.deleteHabit(firstId);

      await repository.addHabit('次の習慣');

      final habits = await repository.getHabits();
      expect(habits.single.sortOrder, 0);
    });
  });

  group('HabitRepository 削除とUndo', () {
    late d.AppDatabase db;
    late HabitRepository repository;
    late String habitId;
    late Date today;

    setUp(() async {
      db = d.AppDatabase(NativeDatabase.memory());
      repository = HabitRepository(db);
      await repository.addHabit('筋トレ');
      habitId = (await repository.getHabits()).single.id;
      today = Date.fromLocal(DateTime(2024, 1, 10));
      await repository.toggleCompletion(habitId, today, today);
    });

    tearDown(() => db.close());

    test('習慣を削除すると一覧から消え、関連する達成記録も消える', () async {
      await repository.deleteHabit(habitId);

      final habits = await repository.getHabits();
      final completions = await repository.getCompletions(habitId);

      expect(habits, isEmpty);
      expect(completions, isEmpty);
    });

    test('記録0件の習慣を削除しても正常に削除できる', () async {
      await repository.addHabit('記録なし習慣');
      final emptyHabitId = (await repository.getHabits())
          .firstWhere((h) => h.name == '記録なし習慣')
          .id;

      await repository.deleteHabit(emptyHabitId);

      final habits = await repository.getHabits();
      expect(habits.any((h) => h.id == emptyHabitId), isFalse);
    });

    test('Undoすると習慣と達成記録が同じidで元通りになる', () async {
      final deleted = await repository.deleteHabit(habitId);

      await repository.undoDelete(deleted);

      final habits = await repository.getHabits();
      final completions = await repository.getCompletions(habitId);
      expect(habits, hasLength(1));
      expect(habits.single.id, habitId);
      expect(habits.single.name, '筋トレ');
      expect(completions, {today});
    });

    test('Undoすると元のsortOrderの位置に戻る', () async {
      await repository.addHabit('2番目の習慣');
      final secondId = (await repository.getHabits())
          .firstWhere((h) => h.name == '2番目の習慣')
          .id;

      final deleted = await repository.deleteHabit(habitId);
      await repository.undoDelete(deleted);

      final habits = await repository.getHabits();
      expect(habits.map((h) => h.id).toList(), [habitId, secondId]);
    });
  });

  group('HabitRepository 編集', () {
    late d.AppDatabase db;
    late HabitRepository repository;
    late String habitId;

    setUp(() async {
      db = d.AppDatabase(NativeDatabase.memory());
      repository = HabitRepository(db);
      await repository.addHabit('筋トレ');
      habitId = (await repository.getHabits()).single.id;
    });

    tearDown(() => db.close());

    test('renameHabit で名前が変更される', () async {
      await repository.renameHabit(habitId, '腹筋');

      final habits = await repository.getHabits();
      expect(habits.single.name, '腹筋');
    });

    test('setArchived で archived が true になる', () async {
      await repository.setArchived(habitId, true);

      final habits = await repository.getHabits(includeArchived: true);
      expect(habits.single.archived, isTrue);
    });

    test('setArchived で archived を false に戻せる', () async {
      await repository.setArchived(habitId, true);
      await repository.setArchived(habitId, false);

      final habits = await repository.getHabits(includeArchived: true);
      expect(habits.single.archived, isFalse);
    });
  });

  group('HabitRepository アーカイブ', () {
    late d.AppDatabase db;
    late HabitRepository repository;

    setUp(() {
      db = d.AppDatabase(NativeDatabase.memory());
      repository = HabitRepository(db);
    });

    tearDown(() => db.close());

    test('getHabits はデフォルトでアーカイブ済みを除外する', () async {
      await repository.addHabit('アクティブ');
      await repository.addHabit('アーカイブ対象');
      final archivedId = (await repository.getHabits())
          .firstWhere((h) => h.name == 'アーカイブ対象')
          .id;
      await repository.setArchived(archivedId, true);

      final habits = await repository.getHabits();

      expect(habits.map((h) => h.name).toList(), ['アクティブ']);
    });

    test('includeArchived: true を指定するとアーカイブ済みも含めて返る', () async {
      await repository.addHabit('アクティブ');
      await repository.addHabit('アーカイブ対象');
      final archivedId = (await repository.getHabits())
          .firstWhere((h) => h.name == 'アーカイブ対象')
          .id;
      await repository.setArchived(archivedId, true);

      final habits = await repository.getHabits(includeArchived: true);

      expect(habits.map((h) => h.name).toList(), ['アクティブ', 'アーカイブ対象']);
    });

    test('アーカイブ済みの習慣も削除できる', () async {
      await repository.addHabit('アーカイブ対象');
      final habitId = (await repository.getHabits()).single.id;
      await repository.setArchived(habitId, true);

      await repository.deleteHabit(habitId);

      final habits = await repository.getHabits(includeArchived: true);
      expect(habits, isEmpty);
    });
  });
}
