import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/logic/streak_calculator.dart';
import 'package:kusari/models/date.dart';

void main() {
  group('totalCompletions', () {
    Date date(int year, int month, int day) =>
        Date.fromLocal(DateTime(year, month, day));

    test('達成記録が空のとき 0 を返す', () {
      expect(totalCompletions({}, date(2024, 1, 10)), 0);
    });

    test('達成日数をそのまま数える', () {
      final completions = {
        date(2024, 1, 1),
        date(2024, 1, 2),
        date(2024, 1, 3),
      };
      expect(totalCompletions(completions, date(2024, 1, 10)), 3);
    });

    test('未来日付を無視する', () {
      final today = date(2024, 1, 2);
      final completions = {
        date(2024, 1, 1),
        date(2024, 1, 2),
        date(2024, 1, 3), // 未来
      };
      expect(totalCompletions(completions, today), 2);
    });
  });
}
