import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/logic/streak_calculator.dart';
import 'package:kusari/models/date.dart';

void main() {
  group('currentStreak', () {
    late Date today;

    setUp(() {
      today = Date.fromLocal(DateTime(2024, 1, 10));
    });

    Date daysAgo(int n) => Date(today.epochDay - n);

    test('達成記録が空のとき 0 を返す', () {
      expect(currentStreak({}, today), 0);
    });

    test('今日だけ達成のとき 1 を返す', () {
      expect(currentStreak({today}, today), 1);
    });

    test('昨日・今日と連続で達成のとき 2 を返す', () {
      expect(currentStreak({daysAgo(1), today}, today), 2);
    });

    test('一昨日・昨日・今日と3日連続のとき 3 を返す', () {
      expect(currentStreak({daysAgo(2), daysAgo(1), today}, today), 3);
    });

    test('一昨日達成・昨日未達成・今日達成のとき 1 を返す（昨日で途切れ）', () {
      expect(currentStreak({daysAgo(2), today}, today), 1);
    });

    test('今日は未達成だが昨日まで3日連続のとき 3 を返す（猶予ルール）', () {
      expect(currentStreak({daysAgo(3), daysAgo(2), daysAgo(1)}, today), 3);
    });

    test('今日も昨日も未達成（一昨日まで達成）のとき 0 を返す', () {
      expect(currentStreak({daysAgo(3), daysAgo(2)}, today), 0);
    });

    test('未来日付の達成記録は無視して今日基準で計算する', () {
      expect(currentStreak({today.next, today}, today), 1);
    });

    test('月をまたぐ連続を正しく数える（1月31日〜2月2日）', () {
      final t = Date.fromLocal(DateTime(2024, 2, 2));
      final completions = {
        Date.fromLocal(DateTime(2024, 1, 31)),
        Date.fromLocal(DateTime(2024, 2, 1)),
        Date.fromLocal(DateTime(2024, 2, 2)),
      };
      expect(currentStreak(completions, t), 3);
    });

    test('年をまたぐ連続を正しく数える（12月31日〜1月1日）', () {
      final t = Date.fromLocal(DateTime(2024, 1, 1));
      final completions = {
        Date.fromLocal(DateTime(2023, 12, 31)),
        Date.fromLocal(DateTime(2024, 1, 1)),
      };
      expect(currentStreak(completions, t), 2);
    });

    test('うるう年の2月29日を含む連続を正しく数える', () {
      final t = Date.fromLocal(DateTime(2024, 3, 1));
      final completions = {
        Date.fromLocal(DateTime(2024, 2, 28)),
        Date.fromLocal(DateTime(2024, 2, 29)),
        Date.fromLocal(DateTime(2024, 3, 1)),
      };
      expect(currentStreak(completions, t), 3);
    });

    test('数年分の記録があっても正しく計算できる', () {
      final start = Date.fromLocal(DateTime(2020, 1, 1));
      final t = Date(start.epochDay + 1500);
      final completions = {
        for (var i = 0; i <= 1500; i++) Date(start.epochDay + i),
      };
      expect(currentStreak(completions, t), 1501);
    });
  });
}
