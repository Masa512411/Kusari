import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/logic/streak_calculator.dart';
import 'package:kusari/models/date.dart';

void main() {
  group('longestStreak', () {
    Date date(int year, int month, int day) =>
        Date.fromLocal(DateTime(year, month, day));

    test('達成記録が空のとき 0 を返す', () {
      expect(longestStreak({}, date(2024, 1, 10)), 0);
    });

    test('全期間で最も長い連続区間の長さを返す', () {
      final completions = {
        date(2024, 1, 1),
        date(2024, 1, 2),
        date(2024, 1, 3),
      };
      expect(longestStreak(completions, date(2024, 1, 10)), 3);
    });

    test('複数の連続区間があるとき最長のものを返す', () {
      // 3日連続 → 1日空き → 2日連続
      final completions = {
        date(2024, 1, 1),
        date(2024, 1, 2),
        date(2024, 1, 3),
        // 1/4 なし
        date(2024, 1, 5),
        date(2024, 1, 6),
      };
      expect(longestStreak(completions, date(2024, 1, 10)), 3);
    });

    test('1日だけ達成のとき 1 を返す', () {
      expect(longestStreak({date(2024, 1, 1)}, date(2024, 1, 10)), 1);
    });

    test('進行中のストリークが最長のとき、それを返す', () {
      final today = date(2024, 1, 5);
      final completions = {
        date(2024, 1, 1),
        date(2024, 1, 2),
        // 1/3 なし
        date(2024, 1, 4),
        date(2024, 1, 5),
      };
      expect(longestStreak(completions, today), 2);
    });

    test('猶予ルール適用中（今日未達成）でも実際の達成日だけで計算される', () {
      final today = date(2024, 1, 5);
      final completions = {
        date(2024, 1, 2),
        date(2024, 1, 3),
        date(2024, 1, 4),
        // 1/5（today）は未達成
      };
      expect(longestStreak(completions, today), 3);
    });

    test('未来日付を無視する', () {
      final today = date(2024, 1, 3);
      final completions = {
        date(2024, 1, 1),
        date(2024, 1, 2),
        date(2024, 1, 3),
        date(2024, 1, 4), // 未来
        date(2024, 1, 5), // 未来
      };
      expect(longestStreak(completions, today), 3);
    });
  });
}
