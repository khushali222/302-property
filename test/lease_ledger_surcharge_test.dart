// Regression test for the ledger 'surcharge' parse.
//
// CalculateBalanceForLease reads via Payment.aggregate([...]), which bypasses
// Mongoose's schema casting — an aggregate returns whatever is literally
// stored in MongoDB. A legacy record or manual DB edit with a non-numeric
// surcharge (e.g. "", "N/A") used to crash Data.fromJson with double.parse,
// taking down ledger rendering on Financial.dart, make_payment.dart and
// Tenant_payments.dart. This pins the fix: bad data degrades to 0.0 instead.

import 'package:flutter_test/flutter_test.dart';
import 'package:three_zero_two_property/model/LeaseLedgerModel.dart';

void main() {
  group('Data.fromJson surcharge', () {
    test('parses a normal numeric surcharge', () {
      final data = Data.fromJson({'surcharge': 12.5});
      expect(data.surcharge, 12.5);
    });

    test('parses a numeric string surcharge', () {
      final data = Data.fromJson({'surcharge': '7.25'});
      expect(data.surcharge, 7.25);
    });

    test('absent surcharge defaults to 0.0', () {
      final data = Data.fromJson({});
      expect(data.surcharge, 0.0);
    });

    test('non-numeric surcharge degrades to 0.0 instead of throwing', () {
      // This is the exact case that used to crash: double.parse('N/A') throws
      // a FormatException with no catch anywhere above it in fromJson.
      final data = Data.fromJson({'surcharge': 'N/A'});
      expect(data.surcharge, 0.0);
    });

    test('empty-string surcharge degrades to 0.0 instead of throwing', () {
      final data = Data.fromJson({'surcharge': ''});
      expect(data.surcharge, 0.0);
    });
  });
}
