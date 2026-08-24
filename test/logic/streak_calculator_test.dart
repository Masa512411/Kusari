import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/logic/streak_calculator.dart';

void main() {
  group('currentStreak', () {
    late DateTime today;

    setUp(() {
      today = DateTime(2024, 1, 10);
    });

    DateTime daysAgo(int n) => today.subtract(Duration(days: n));

    test('達成記録が空のとき 0 を返す', () {
      expect(currentStreak([], today), 0);
    });

    test('今日だけ達成のとき 1 を返す', () {
      expect(currentStreak([today], today), 1);
    });

    test('昨日・今日と連続で達成のとき 2 を返す', () {
      expect(currentStreak([daysAgo(1), today], today), 2);
    });

    test('一昨日達成・昨日未達成・今日達成のとき 1 を返す（昨日で途切れ）', () {
      expect(currentStreak([daysAgo(2), today], today), 1);
    });

    test('今日は未達成だが昨日まで3日連続のとき 3 を返す（猶予ルール）', () {
      expect(currentStreak([daysAgo(3), daysAgo(2), daysAgo(1)], today), 3);
    });

    test('今日も昨日も未達成（一昨日まで達成）のとき 0 を返す', () {
      expect(currentStreak([daysAgo(3), daysAgo(2)], today), 0);
    });

    test('未来日付の達成記録は無視して今日基準で計算する', () {
      final tomorrow = today.add(const Duration(days: 1));
      expect(currentStreak([tomorrow, today], today), 1);
    });
  });
}
