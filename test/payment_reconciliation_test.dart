// Tests for PaymentReconciliationService (CRM-4660).
//
// This service decides what the user is told after a payment whose outcome the
// client never saw: "completed — do not pay again", "not processed — safe to
// retry", or "unknown". A wrong verdict here either causes a double charge or
// blocks a legitimate retry, so the verdicts are pinned down exhaustively.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/LeaseLedgerModel.dart';
import 'package:three_zero_two_property/repository/tenantDetail_payment/tenant_payment_repo.dart';
import 'package:three_zero_two_property/services/payment_reconciliation.dart';

/// Scripted repo: returns each queued response in order; `null` entries mean
/// "throw" (device offline). The last entry repeats for extra polls.
class _FakeRepo extends TenantLeaseRepository {
  final List<LeaseLedger?> script;
  int calls = 0;
  _FakeRepo(this.script);

  @override
  Future<LeaseLedger?> fetchLedgerWithTenant({
    required String leaseId,
    required String tenantId,
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    final step = script[calls.clamp(0, script.length - 1)];
    calls++;
    if (step == null) throw Exception('SocketException: network down');
    return step;
  }
}

LeaseLedger _ledger(List<Data> rows) => LeaseLedger()..data = rows;

Data _payment(String id, double amount, {bool deleted = false}) => Data(
      paymentId: id,
      totalAmount: amount,
      isDelete: deleted,
    );

// Fast backoff so the suite doesn't sleep for real.
const _fast = [Duration(milliseconds: 1)];
const _fast3 = [
  Duration(milliseconds: 1),
  Duration(milliseconds: 1),
  Duration(milliseconds: 1),
];

PaymentReconciliationService _svc(_FakeRepo repo) =>
    PaymentReconciliationService(repo: repo);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  guardTests();
  group('verdict: completed', () {
    test('new payment id since the snapshot, matching amount', () async {
      final repo = _FakeRepo([
        _ledger([_payment('old', 10.00), _payment('new', 10.00)])
      ]);
      final r = await _svc(repo).verify(
        leaseId: 'L',
        tenantId: 'T',
        amount: 10.00,
        before: {'old'},
        backoff: _fast,
      );
      expect(r.verdict, PaymentVerdict.completed);
      expect(r.payment?.paymentId, 'new');
      expect(r.isCompleted, isTrue);
      expect(r.isSafeToRetry, isFalse);
    });

    test('appears only on a later poll (ledger lags the gateway)', () async {
      final repo = _FakeRepo([
        _ledger([_payment('old', 5.00)]),
        _ledger([_payment('old', 5.00), _payment('new', 5.00)]),
      ]);
      final r = await _svc(repo).verify(
        leaseId: 'L',
        tenantId: 'T',
        amount: 5.00,
        before: {'old'},
        backoff: _fast3,
      );
      expect(r.verdict, PaymentVerdict.completed);
      expect(repo.calls, 2); // stopped as soon as it found it
    });

    test('sub-cent rounding still matches (10.004 vs 10.00)', () async {
      final repo = _FakeRepo([
        _ledger([_payment('new', 10.004)])
      ]);
      final r = await _svc(repo).verify(
        leaseId: 'L',
        tenantId: 'T',
        amount: 10.00,
        before: <String>{},
        backoff: _fast,
      );
      expect(r.verdict, PaymentVerdict.completed);
    });

    test('without a snapshot falls back to amount-only matching', () async {
      final repo = _FakeRepo([
        _ledger([_payment('any', 7.50)])
      ]);
      final r = await _svc(repo).verify(
        leaseId: 'L',
        tenantId: 'T',
        amount: 7.50,
        before: null, // snapshot failed pre-submit
        backoff: _fast,
      );
      expect(r.verdict, PaymentVerdict.completed);
    });
  });

  group('verdict: notFound (safe to retry)', () {
    test('ledger readable, no new row', () async {
      final repo = _FakeRepo([
        _ledger([_payment('old', 10.00)])
      ]);
      final r = await _svc(repo).verify(
        leaseId: 'L',
        tenantId: 'T',
        amount: 10.00,
        before: {'old'},
        backoff: _fast,
      );
      expect(r.verdict, PaymentVerdict.notFound);
      expect(r.isSafeToRetry, isTrue);
    });

    test('THE double-charge guard: pre-existing identical amount is NOT ours',
        () async {
      // User paid $1.00 yesterday; today's $1.00 attempt dropped. The old row
      // must not be mistaken for the new payment...
      final repo = _FakeRepo([
        _ledger([_payment('yesterday', 1.00)])
      ]);
      final r = await _svc(repo).verify(
        leaseId: 'L',
        tenantId: 'T',
        amount: 1.00,
        before: {'yesterday'},
        backoff: _fast,
      );
      // ...so the verdict is notFound (retry is genuinely safe).
      expect(r.verdict, PaymentVerdict.notFound);
    });

    test('new row with a DIFFERENT amount is not ours', () async {
      final repo = _FakeRepo([
        _ledger([_payment('new', 99.99)])
      ]);
      final r = await _svc(repo).verify(
        leaseId: 'L',
        tenantId: 'T',
        amount: 10.00,
        before: <String>{},
        backoff: _fast,
      );
      expect(r.verdict, PaymentVerdict.notFound);
    });

    test('soft-deleted row is ignored', () async {
      final repo = _FakeRepo([
        _ledger([_payment('new', 10.00, deleted: true)])
      ]);
      final r = await _svc(repo).verify(
        leaseId: 'L',
        tenantId: 'T',
        amount: 10.00,
        before: <String>{},
        backoff: _fast,
      );
      expect(r.verdict, PaymentVerdict.notFound);
    });

    test('offline first poll, readable second poll, nothing new', () async {
      final repo = _FakeRepo([
        null, // still offline
        _ledger([_payment('old', 10.00)]),
      ]);
      final r = await _svc(repo).verify(
        leaseId: 'L',
        tenantId: 'T',
        amount: 10.00,
        before: {'old'},
        backoff: _fast3,
      );
      expect(r.verdict, PaymentVerdict.notFound);
    });
  });

  group('verdict: unknown (never claim safe)', () {
    test('every poll throws — device stayed offline', () async {
      final repo = _FakeRepo([null]);
      final r = await _svc(repo).verify(
        leaseId: 'L',
        tenantId: 'T',
        amount: 10.00,
        before: <String>{},
        backoff: _fast3,
      );
      expect(r.verdict, PaymentVerdict.unknown);
      expect(r.isSafeToRetry, isFalse, reason: 'must never invite a retry');
      expect(repo.calls, 3); // used every backoff step before giving up
    });
  });

  group('snapshot', () {
    test('collects ids from both data and tenantPayments', () async {
      final ledger = LeaseLedger()
        ..data = [_payment('a', 1)]
        ..tenantPayments = [_payment('b', 2)];
      final repo = _FakeRepo([ledger]);
      final ids = await _svc(repo).snapshot(leaseId: 'L', tenantId: 'T');
      expect(ids, {'a', 'b'});
    });

    test('returns null instead of throwing when offline', () async {
      final repo = _FakeRepo([null]);
      final ids = await _svc(repo).snapshot(leaseId: 'L', tenantId: 'T');
      expect(ids, isNull); // must never block the payment itself
    });
  });
}

// ---------------------------------------------------------------------------
// Pre-submit duplicate guard. This one can BLOCK a real payment, so the
// fail-open behaviour matters more than the blocking behaviour: wrongly
// refusing someone's rent payment is worse than the double charge it guards.
// ---------------------------------------------------------------------------
void guardTests() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  PendingPaymentAttempt pending({
    String lease = 'L',
    double amount = 10.00,
    Duration age = Duration.zero,
  }) =>
      PendingPaymentAttempt(
        leaseId: lease,
        tenantId: 'T',
        amount: amount,
        before: {'old'},
        attemptedAt: DateTime.now().subtract(age),
      );

  group('duplicate guard', () {
    test('BLOCKS when the earlier attempt did post', () async {
      final repo = _FakeRepo([
        _ledger([_payment('old', 10.00), _payment('new', 10.00)])
      ]);
      final svc = _svc(repo);
      await svc.rememberPending(pending());
      final posted = await svc.blockingDuplicate(leaseId: 'L', tenantId: 'T');
      expect(posted, isNotNull, reason: 'must stop a second charge');
      expect(posted!.paymentId, 'new');
      expect(await svc.readPending(), isNull, reason: 'resolved -> cleared');
    });

    test('allows when the earlier attempt did NOT post', () async {
      final repo = _FakeRepo([
        _ledger([_payment('old', 10.00)])
      ]);
      final svc = _svc(repo);
      await svc.rememberPending(pending());
      expect(await svc.blockingDuplicate(leaseId: 'L', tenantId: 'T'), isNull);
      expect(await svc.readPending(), isNull, reason: 'confirmed absent -> cleared');
    });

    test('allows when there is no pending attempt at all', () async {
      final svc = _svc(_FakeRepo([_ledger([])]));
      expect(await svc.blockingDuplicate(leaseId: 'L', tenantId: 'T'), isNull);
    });

    test('FAILS OPEN when the ledger cannot be read', () async {
      final svc = _svc(_FakeRepo([null])); // offline
      await svc.rememberPending(pending());
      expect(await svc.blockingDuplicate(leaseId: 'L', tenantId: 'T'), isNull,
          reason: 'must never block a payment it cannot verify');
      expect(await svc.readPending(), isNotNull,
          reason: 'unresolved -> keep for the next attempt');
    });

    test('ignores a pending attempt from a DIFFERENT lease', () async {
      final repo = _FakeRepo([
        _ledger([_payment('new', 10.00)])
      ]);
      final svc = _svc(repo);
      await svc.rememberPending(pending(lease: 'OTHER'));
      expect(await svc.blockingDuplicate(leaseId: 'L', tenantId: 'T'), isNull);
    });

    test('ignores a stale attempt (older than maxAge)', () async {
      final repo = _FakeRepo([
        _ledger([_payment('new', 10.00)])
      ]);
      final svc = _svc(repo);
      await svc.rememberPending(pending(age: const Duration(days: 3)));
      expect(await svc.blockingDuplicate(leaseId: 'L', tenantId: 'T'), isNull);
    });

    test('survives a round-trip through storage', () async {
      final svc = _svc(_FakeRepo([_ledger([])]));
      await svc.rememberPending(pending(amount: 7.56));
      final back = await _svc(_FakeRepo([_ledger([])])).readPending();
      expect(back?.amount, 7.56);
      expect(back?.leaseId, 'L');
      expect(back?.before, {'old'});
    });
  });
}
