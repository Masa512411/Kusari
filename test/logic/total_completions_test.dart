import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/logic/streak_calculator.dart';

void main() {
  group('totalCompletions', () {
    DateTime date(int year, int month, int day) => DateTime(year, month, day);

    test('達成記録が空のとき 0 を返す', () {
      expect(totalCompletions([]), 0);
    });

    test('達成日数をそのまま数える', () {
      expect(
        totalCompletions([
          date(2024, 1, 1),
          date(2024, 1, 2),
          date(2024, 1, 3),
        ]),
        3,
      );
    });

    test('同一日に重複記録があっても1日としてカウントする', () {
      final dates = [
        date(2024, 1, 1),
        date(2024, 1, 1), // 重複
        date(2024, 1, 2),
      ];
      expect(totalCompletions(dates), 2);
    });
  });
}
