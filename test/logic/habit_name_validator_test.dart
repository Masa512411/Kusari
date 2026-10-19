import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/logic/habit_name_validator.dart';

void main() {
  group('validateHabitName', () {
    test('通常の名前は null（エラーなし）を返す', () {
      expect(validateHabitName('筋トレ'), isNull);
    });

    test('空文字はエラーを返す', () {
      expect(validateHabitName(''), isNotNull);
    });

    test('前後の空白のみの文字列はエラーを返す', () {
      expect(validateHabitName('   '), isNotNull);
    });

    test('50文字ちょうどはエラーなし', () {
      expect(validateHabitName('あ' * 50), isNull);
    });

    test('51文字はエラーを返す', () {
      expect(validateHabitName('あ' * 51), isNotNull);
    });
  });
}
