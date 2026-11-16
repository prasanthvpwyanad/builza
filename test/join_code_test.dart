import 'dart:math';

import 'package:builza/core/utils/join_code.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates an 8-character unambiguous code', () {
    final code = generateJoinCode(Random(4));
    expect(code.length, joinCodeLength);
    expect(RegExp(r'^[A-Z0-9]{8}$').hasMatch(code), isTrue);
    expect(code.contains(RegExp(r'[01IOL]')), isFalse);
  });

  test('normalizes and formats invite codes', () {
    expect(normalizeJoinCode('ab cd-23'), 'ABCD23');
    expect(isValidJoinCode('abcd-efgh'), isTrue);
    expect(isValidJoinCode('short'), isFalse);
    expect(formatJoinCode('ABCDEFGH'), 'ABCD-EFGH');
  });
}
