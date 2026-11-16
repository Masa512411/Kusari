import 'package:flutter_test/flutter_test.dart';
import 'package:kusari/logic/milestone.dart';

void main() {
  group('reachedMilestone', () {
    test('ストリークが変化していない場合は null', () {
      expect(reachedMilestone(3, 3), isNull);
    });

    test('ストリークが減った場合（取り消し）は null', () {
      expect(reachedMilestone(7, 6), isNull);
    });

    test('増えたが閾値ではない場合は null', () {
      expect(reachedMilestone(4, 5), isNull);
    });

    test('ちょうど7になった場合は7を返す', () {
      expect(reachedMilestone(6, 7), 7);
    });

    test('ちょうど30になった場合は30を返す', () {
      expect(reachedMilestone(29, 30), 30);
    });

    test('ちょうど100になった場合は100を返す', () {
      expect(reachedMilestone(99, 100), 100);
    });

    test('ちょうど365になった場合は365を返す', () {
      expect(reachedMilestone(364, 365), 365);
    });

    test('閾値を飛び越えた場合は null', () {
      expect(reachedMilestone(0, 10), isNull);
    });
  });
}
