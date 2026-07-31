// Tests for the safe-JSON coercion helpers in lib/constant/constant.dart.
//
// The backend returns the same field as a String on one environment and a
// num/bool on another. A raw cast throws and takes the whole screen down, so
// every `fromJson` is supposed to go through these helpers. These tests pin
// their behaviour — including the surprising cases — so a future edit can't
// quietly change how a payload parses.

import 'package:flutter_test/flutter_test.dart';
import 'package:three_zero_two_property/constant/constant.dart';

void main() {
  group('asStr', () {
    test('passes strings through', () => expect(asStr('hello'), 'hello'));
    test('stringifies numbers', () => expect(asStr(42), '42'));
    test('stringifies bools', () => expect(asStr(true), 'true'));
    test('null becomes empty string', () => expect(asStr(null), ''));
    test('null honours the fallback', () => expect(asStr(null, '—'), '—'));
    test('zero is "0", not the fallback', () => expect(asStr(0, '—'), '0'));
  });

  group('asBool', () {
    test('real bools', () {
      expect(asBool(true), isTrue);
      expect(asBool(false), isFalse);
    });
    test('numbers: non-zero is true', () {
      expect(asBool(1), isTrue);
      expect(asBool(0), isFalse);
    });
    test('strings the API actually sends', () {
      expect(asBool('true'), isTrue);
      expect(asBool('TRUE'), isTrue);
      expect(asBool(' yes '), isTrue);
      expect(asBool('1'), isTrue);
      expect(asBool('false'), isFalse);
      expect(asBool('no'), isFalse);
    });
    test('null and junk fall back', () {
      expect(asBool(null), isFalse);
      expect(asBool(<String>[]), isFalse);
      expect(asBool(null, true), isTrue);
    });
  });

  group('asInt', () {
    test('ints and numeric strings', () {
      expect(asInt(7), 7);
      expect(asInt('7'), 7);
      expect(asInt(' 7 '), 7);
    });
    test('doubles are truncated, not rounded', () {
      expect(asInt(7.9), 7);
      expect(asInt(-7.9), -7);
    });
    test('null and junk fall back', () {
      expect(asInt(null), 0);
      expect(asInt('abc'), 0);
      expect(asInt(null, -1), -1);
    });
    test(
        'KNOWN TRAP: a decimal STRING yields the fallback, not the truncated '
        'value — "12.5" parses as 0, unlike the double 12.5 which is 12', () {
      expect(asInt('12.5'), 0);
      expect(asInt(12.5), 12);
    });
  });

  group('asDouble', () {
    test('nums and numeric strings', () {
      expect(asDouble(1.5), 1.5);
      expect(asDouble(2), 2.0);
      expect(asDouble('1.5'), 1.5);
      expect(asDouble(' 1.5 '), 1.5);
    });
    test('null and junk fall back', () {
      expect(asDouble(null), 0);
      expect(asDouble('abc'), 0);
      expect(asDouble(null, 9.99), 9.99);
    });
  });

  group('asNumN — for nullable money fields', () {
    test('null stays null (does NOT become 0)', () => expect(asNumN(null), isNull));
    test('preserves int vs double so payloads round-trip', () {
      expect(asNumN(5), 5);
      expect(asNumN(5), isA<int>());
      expect(asNumN(5.5), isA<double>());
    });
    test('parses numeric strings including decimals', () {
      expect(asNumN('1500.50'), 1500.50);
      expect(asNumN('1500'), 1500);
    });
    test('junk becomes null, not 0', () => expect(asNumN('abc'), isNull));
  });

  group('asIntN / asDoubleN', () {
    test('null stays null', () {
      expect(asIntN(null), isNull);
      expect(asDoubleN(null), isNull);
    });
    test('present values are coerced', () {
      expect(asIntN('12'), 12);
      expect(asDoubleN('12.5'), 12.5);
    });
  });

  group('asObject / asObjectList', () {
    test('a map comes back as a typed map', () {
      expect(asObject({'a': 1}), {'a': 1});
    });
    test('null or a non-map yields an empty map, never a throw', () {
      expect(asObject(null), isEmpty);
      expect(asObject('nope'), isEmpty);
      expect(asObject(<int>[1, 2]), isEmpty);
    });
    test('a list of objects is converted', () {
      expect(asObjectList([
        {'a': 1},
        {'b': 2}
      ]).length, 2);
    });
    test('null, a non-list, or mixed junk cannot crash a parse', () {
      expect(asObjectList(null), isEmpty);
      expect(asObjectList('nope'), isEmpty);
      expect(
        asObjectList([
          {'a': 1},
          'junk',
          null,
          42
        ]).length,
        1,
      );
    });
  });

  group('the crash this prevents', () {
    test('a payload that flips types between environments still parses', () {
      // Same record, two shapes the API is known to return.
      final stringy = {'id': '12', 'amount': '1500.50', 'active': 'true'};
      final numeric = {'id': 12, 'amount': 1500.50, 'active': true};

      for (final json in [stringy, numeric]) {
        expect(asInt(json['id']), 12);
        expect(asNumN(json['amount']), 1500.50);
        expect(asBool(json['active']), isTrue);
      }
    });
  });
}
