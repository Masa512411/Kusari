import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/models/date.dart';
import 'package:kusari/logic/edit_window.dart';

void main() {
  group('isEditable', () {
    test('todayと同じ日付を渡すとtrueを返す', () {
      final today = Date.today();
      expect(isEditable(today, today), isTrue);
    });

    test('一昨日（todayの2日前）を渡すと false を返す', () {
      final today = Date.today();
      final twoDaysAgo = today.previous.previous;
      expect(isEditable(twoDaysAgo, today), isFalse);
    });
    test('昨日（todayの1日前）を渡すと true を返す', () {
      final today = Date.today();
      final yesterday = today.previous;
      expect(isEditable(yesterday, today), isTrue);
    });

    test(' 明日（todayの1日後）を渡すと false を返す', () {
      final today = Date.today();
      final tomorrow = today.next;
      expect(isEditable(tomorrow, today), isFalse);
    });
  });
}
