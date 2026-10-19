import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/models/date.dart';
import 'package:kusari/models/completion.dart';

void main() {
  group('Completion', () {
    test('Completion のコンストラクタは正しく初期化する', () {
      final completion = Completion(
        habitId: 'habit1',
        date: Date.fromLocal(DateTime(2024, 1, 10)),
      );

      expect(completion.date, Date.fromLocal(DateTime(2024, 1, 10)));
      expect(completion.habitId, 'habit1');
    });
  });
}
