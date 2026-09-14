import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/models/habit.dart';
import 'package:kusari/models/date.dart';

void main() {
  group('Habit', () {
    test('Habit のコンストラクタは正しく初期化する', () {
      final habit = Habit(
        id: 'habit1',
        name: 'Test Habit',
        createdAt: Date.fromLocal(DateTime(2024, 1, 10)),
        archived: false,
        sortOrder: 1,
      );

      expect(habit.id, 'habit1');
      expect(habit.name, 'Test Habit');
      expect(habit.createdAt, Date.fromLocal(DateTime(2024, 1, 10)));
      expect(habit.archived, isFalse);
      expect(habit.sortOrder, 1);
    });
  });
}
