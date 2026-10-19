import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/logic/stats_calculator.dart';
import 'package:kusari/models/date.dart';

void main() {
  Date date(int year, int month, int day) =>
      Date.fromLocal(DateTime(year, month, day));

  group('weeklyStats', () {
    // 2024-01-08(月) 〜 2024-01-14(日)
    final weekStart = date(2024, 1, 8);
    final today = date(2024, 1, 20);

    test('期間内に達成が無いとき 達成日数0・達成率0', () {
      final stats = weeklyStats({}, weekStart, today);
      expect(stats.completedDays, 0);
      expect(stats.totalDays, 7);
      expect(stats.rate, 0);
    });

    test('週の境界（月曜始まり）を正しく判定する', () {
      final completions = {
        date(2024, 1, 7), // 前週の日曜（範囲外）
        date(2024, 1, 8), // 月（範囲内）
        date(2024, 1, 14), // 日（範囲内）
        date(2024, 1, 15), // 翌週の月（範囲外）
      };
      final stats = weeklyStats(completions, weekStart, today);
      expect(stats.completedDays, 2);
    });

    test('分母は常に7', () {
      final stats = weeklyStats({date(2024, 1, 8)}, weekStart, today);
      expect(stats.totalDays, 7);
    });

    test('週内の最長連続を正しく返す', () {
      final completions = {
        date(2024, 1, 8),
        date(2024, 1, 9),
        date(2024, 1, 10),
        // 1/11 なし
        date(2024, 1, 12),
        date(2024, 1, 13),
      };
      final stats = weeklyStats(completions, weekStart, today);
      expect(stats.longestRun, 3);
    });

    test('週をまたぐ連続は週の境界で切られて計算される', () {
      final completions = {
        date(2024, 1, 6),
        date(2024, 1, 7), // 前週（範囲外）
        date(2024, 1, 8),
        date(2024, 1, 9), // 今週はここまでの2日だけ連続
      };
      final stats = weeklyStats(completions, weekStart, today);
      expect(stats.longestRun, 2);
    });

    test('未来日付を無視する', () {
      final earlyToday = date(2024, 1, 9);
      final completions = {
        date(2024, 1, 8),
        date(2024, 1, 9),
        date(2024, 1, 10), // 未来
      };
      final stats = weeklyStats(completions, weekStart, earlyToday);
      expect(stats.completedDays, 2);
    });

    test('週の全日達成のとき達成率100%', () {
      final completions = {
        for (var d = 0; d < 7; d++) Date(weekStart.epochDay + d),
      };
      final stats = weeklyStats(completions, weekStart, today);
      expect(stats.rate, 1.0);
    });
  });

  group('monthlyStats', () {
    final today = date(2024, 1, 20);

    test('期間内に達成が無いとき 達成日数0・達成率0', () {
      final stats = monthlyStats({}, 2024, 1, today);
      expect(stats.completedDays, 0);
      expect(stats.rate, 0);
    });

    test('月の境界（1日〜月末）を正しく判定する', () {
      final afterMonthEnd = date(2024, 2, 5);
      final completions = {
        date(2023, 12, 31), // 前月（範囲外）
        date(2024, 1, 1), // 範囲内
        date(2024, 1, 31), // 範囲内
        date(2024, 2, 1), // 翌月（範囲外）
      };
      final stats = monthlyStats(completions, 2024, 1, afterMonthEnd);
      expect(stats.completedDays, 2);
    });

    test('進行中の月でも分母は月の日数のまま変わらない', () {
      final midMonthToday = date(2024, 1, 15);
      final stats = monthlyStats({}, 2024, 1, midMonthToday);
      expect(stats.totalDays, 31);
    });

    test('うるう年の2月は分母29', () {
      final stats = monthlyStats({}, 2024, 2, date(2024, 2, 29));
      expect(stats.totalDays, 29);
    });

    test('平年の2月は分母28', () {
      final stats = monthlyStats({}, 2023, 2, date(2023, 2, 28));
      expect(stats.totalDays, 28);
    });

    test('30日の月は分母30', () {
      final stats = monthlyStats({}, 2024, 4, date(2024, 4, 30));
      expect(stats.totalDays, 30);
    });

    test('31日の月は分母31', () {
      final stats = monthlyStats({}, 2024, 1, date(2024, 1, 31));
      expect(stats.totalDays, 31);
    });

    test('月の最終日に全日達成のとき達成率100%', () {
      final lastDay = date(2024, 4, 30);
      final completions = {
        for (var d = 0; d < 30; d++) Date(date(2024, 4, 1).epochDay + d),
      };
      final stats = monthlyStats(completions, 2024, 4, lastDay);
      expect(stats.rate, 1.0);
    });

    test('月内の最長連続を正しく返す', () {
      final completions = {
        date(2024, 1, 1),
        date(2024, 1, 2),
        date(2024, 1, 3),
        // 1/4 なし
        date(2024, 1, 5),
      };
      final stats = monthlyStats(completions, 2024, 1, today);
      expect(stats.longestRun, 3);
    });

    test('月をまたぐ連続は月の境界で切られて計算される', () {
      final completions = {
        date(2023, 12, 30),
        date(2023, 12, 31), // 前月（範囲外）
        date(2024, 1, 1),
        date(2024, 1, 2), // 今月はここまでの2日だけ連続
      };
      final stats = monthlyStats(completions, 2024, 1, today);
      expect(stats.longestRun, 2);
    });

    test('未来日付を無視する', () {
      final earlyToday = date(2024, 1, 2);
      final completions = {
        date(2024, 1, 1),
        date(2024, 1, 2),
        date(2024, 1, 3), // 未来
      };
      final stats = monthlyStats(completions, 2024, 1, earlyToday);
      expect(stats.completedDays, 2);
    });
  });
}
