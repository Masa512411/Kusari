import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/logic/streak_calculator.dart';

void main() {
  group('longestStreak', () {
    DateTime date(int year, int month, int day) => DateTime(year, month, day);

    test('達成記録が空のとき 0 を返す', () {
      expect(longestStreak([]), 0);
    });

    test('全期間で最も長い連続区間の長さを返す', () {
      final dates = [
        date(2024, 1, 1),
        date(2024, 1, 2),
        date(2024, 1, 3),
      ];
      expect(longestStreak(dates), 3);
    });

    test('複数の連続区間があるとき最長のものを返す', () {
      // 3日連続 → 1日空き → 2日連続
      final dates = [
        date(2024, 1, 1),
        date(2024, 1, 2),
        date(2024, 1, 3),
        // 1/4 なし
        date(2024, 1, 5),
        date(2024, 1, 6),
      ];
      expect(longestStreak(dates), 3);
    });

    test('1日だけ達成のとき 1 を返す', () {
      expect(longestStreak([date(2024, 1, 1)]), 1);
    });

    test('同一日に重複記録があっても1日としてカウントする', () {
      final dates = [
        date(2024, 1, 1),
        date(2024, 1, 1), // 重複
        date(2024, 1, 2),
      ];
      expect(longestStreak(dates), 2);
    });
  });
}
