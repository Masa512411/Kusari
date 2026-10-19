import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/models/date.dart';

void main() {
  group('Date', () {
    test('fromLocal は年月日から Date を作る', () {
      final date = Date.fromLocal(DateTime(2024, 1, 10));
      expect(date, Date.fromLocal(DateTime(2024, 1, 10)));
    });

    test('fromLocal は時刻を切り捨てて暦日だけを見る', () {
      final morning = Date.fromLocal(DateTime(2024, 1, 10, 0, 0));
      final night = Date.fromLocal(DateTime(2024, 1, 10, 23, 59));
      expect(morning, night);
    });

    test('年月日が異なれば等しくない', () {
      final a = Date.fromLocal(DateTime(2024, 1, 10));
      final b = Date.fromLocal(DateTime(2024, 1, 11));
      expect(a == b, isFalse);
    });

    test('等しい Date は同じ hashCode を持つ', () {
      final a = Date.fromLocal(DateTime(2024, 1, 10));
      final b = Date.fromLocal(DateTime(2024, 1, 10));
      expect(a.hashCode, b.hashCode);
    });

    test('next は翌日の Date を返す', () {
      final date = Date.fromLocal(DateTime(2024, 1, 10));
      expect(date.next, Date.fromLocal(DateTime(2024, 1, 11)));
    });

    test('previous は前日の Date を返す', () {
      final date = Date.fromLocal(DateTime(2024, 1, 10));
      expect(date.previous, Date.fromLocal(DateTime(2024, 1, 9)));
    });

    test('next は月末をまたいで正しく計算する', () {
      final date = Date.fromLocal(DateTime(2024, 1, 31));
      expect(date.next, Date.fromLocal(DateTime(2024, 2, 1)));
    });

    test('next は年末をまたいで正しく計算する', () {
      final date = Date.fromLocal(DateTime(2024, 12, 31));
      expect(date.next, Date.fromLocal(DateTime(2025, 1, 1)));
    });

    test('previous はうるう年の2月29日をまたいで正しく計算する', () {
      final date = Date.fromLocal(DateTime(2024, 3, 1));
      expect(date.previous, Date.fromLocal(DateTime(2024, 2, 29)));
    });

    test('<= は日付の前後関係を正しく判定する', () {
      final earlier = Date.fromLocal(DateTime(2024, 1, 10));
      final later = Date.fromLocal(DateTime(2024, 1, 11));
      expect(earlier <= later, isTrue);
      expect(later <= earlier, isFalse);
      expect(earlier <= earlier, isTrue);
    });

    test('compareTo で日付順にソートできる', () {
      final dates = [
        Date.fromLocal(DateTime(2024, 1, 3)),
        Date.fromLocal(DateTime(2024, 1, 1)),
        Date.fromLocal(DateTime(2024, 1, 2)),
      ]..sort();

      expect(dates, [
        Date.fromLocal(DateTime(2024, 1, 1)),
        Date.fromLocal(DateTime(2024, 1, 2)),
        Date.fromLocal(DateTime(2024, 1, 3)),
      ]);
    });

    test('toDateTime は年月日が一致するUTCのDateTimeを返す', () {
      final date = Date.fromLocal(DateTime(2024, 1, 10));
      expect(date.toDateTime(), DateTime.utc(2024, 1, 10));
    });

    test('startOfWeek: 月曜日は自分自身を返す', () {
      final monday = Date.fromLocal(DateTime(2024, 1, 8));
      expect(monday.startOfWeek, monday);
    });

    test('startOfWeek: 日曜日は6日前の月曜日を返す', () {
      final sunday = Date.fromLocal(DateTime(2024, 1, 14));
      expect(sunday.startOfWeek, Date.fromLocal(DateTime(2024, 1, 8)));
    });

    test('startOfWeek: 月をまたいでも正しく計算する', () {
      final date = Date.fromLocal(DateTime(2024, 2, 1)); // 木曜日
      expect(date.startOfWeek, Date.fromLocal(DateTime(2024, 1, 29))); // 月曜日
    });
  });
}
