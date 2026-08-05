// Regression test for the payment total_amount TYPE mismatch.
//
// The server adds the surcharge onto the posted total with:
//     req.body.total_amount += Number(req.body.surcharge);
// (Payment.js:669 for POST /payment, :1576 for POST /tenant-payment)
//
// JavaScript's += is addition for numbers but CONCATENATION for strings, so a
// mobile client posting "150.00" produced "150.005" instead of 155.00. Web was
// never affected because it posts a number. These tests pin the conversion the
// repositories now apply before sending.

import 'package:flutter_test/flutter_test.dart';

/// Mirrors what the payment repositories now put in the JSON body:
///   'total_amount': num.tryParse(totalAmount) ?? totalAmount
Object _payloadTotal(String totalAmount) =>
    num.tryParse(totalAmount) ?? totalAmount;

/// Mirrors the server's `total_amount += Number(surcharge)` for both types.
Object _serverAdd(Object postedTotal, num surcharge) {
  if (postedTotal is num) return postedTotal + surcharge; // real addition
  return '$postedTotal$surcharge'; // JS string concatenation
}

void main() {
  group('total_amount is posted as a number', () {
    test('a plain amount becomes a num, not a String', () {
      final v = _payloadTotal('150.00');
      expect(v, isA<num>());
      expect(v, 150.00);
    });

    test('a whole amount becomes a num', () {
      expect(_payloadTotal('20'), isA<num>());
      expect(_payloadTotal('20'), 20);
    });

    test('an unparseable value is left as-is, never invented as 0', () {
      // Sending 0 would record a $0 payment — worse than the original bug.
      expect(_payloadTotal('N/A'), 'N/A');
      expect(_payloadTotal(''), '');
    });
  });

  group('the corruption this prevents', () {
    test('OLD behaviour: posting a String concatenated the surcharge', () {
      final corrupted = _serverAdd('150.00', 5);
      expect(corrupted, '150.005'); // the bug
      expect(corrupted, isNot(155.00));
    });

    test('NEW behaviour: posting a num adds the surcharge correctly', () {
      final correct = _serverAdd(_payloadTotal('150.00'), 5);
      expect(correct, 155.00);
    });

    test('the tenant-payment route silently DROPPED the surcharge', () {
      // Payment.js:1578 does Number(total).toFixed(2) right after the +=. On
      // "150.005" that rounds back down to "150.00" — so the surcharge vanished
      // entirely and the stored total looks like a perfectly normal payment.
      // That is why this was never noticed: no nonsense value to spot.
      final corrupted = _serverAdd('150.00', 5) as String;
      expect(corrupted, '150.005');
      final normalised = double.parse(corrupted).toStringAsFixed(2);
      expect(normalised, '150.00'); // surcharge lost
      expect(normalised, isNot('155.00')); // what it should have been
    });

    test('a decimal surcharge also adds correctly now', () {
      expect(_serverAdd(_payloadTotal('99.99'), 2.5), 102.49);
    });
  });
}
