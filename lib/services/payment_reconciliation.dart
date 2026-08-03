import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/LeaseLedgerModel.dart';
import 'package:three_zero_two_property/repository/tenantDetail_payment/tenant_payment_repo.dart';
import 'package:three_zero_two_property/services/app_log.dart';

/// A payment attempt whose outcome we never learned, remembered across app
/// restarts so the NEXT attempt on the same lease can be checked before it is
/// allowed to charge again.
class PendingPaymentAttempt {
  final String leaseId;
  final String tenantId;
  final double amount;
  final String? idempotencyKey;

  /// Payment ids on the ledger just before the attempt, so a payment that
  /// appears later can be told apart from an identical earlier one.
  final Set<String>? before;
  final DateTime attemptedAt;

  const PendingPaymentAttempt({
    required this.leaseId,
    required this.tenantId,
    required this.amount,
    required this.attemptedAt,
    this.idempotencyKey,
    this.before,
  });

  Map<String, dynamic> toJson() => {
        'lease_id': leaseId,
        'tenant_id': tenantId,
        'amount': amount,
        'idempotency_key': idempotencyKey,
        'before': before?.toList(),
        'attempted_at': attemptedAt.toIso8601String(),
      };

  static PendingPaymentAttempt? fromJson(Map<String, dynamic> json) {
    final lease = json['lease_id'];
    final tenant = json['tenant_id'];
    final at = DateTime.tryParse('${json['attempted_at']}');
    if (lease is! String || tenant is! String || at == null) return null;
    final rawBefore = json['before'];
    return PendingPaymentAttempt(
      leaseId: lease,
      tenantId: tenant,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      idempotencyKey: json['idempotency_key'] as String?,
      before: rawBefore is List ? rawBefore.map((e) => '$e').toSet() : null,
      attemptedAt: at,
    );
  }
}

/// What a reconciliation attempt concluded.
enum PaymentVerdict {
  /// A payment that was not on the ledger before the attempt now is — the
  /// charge went through despite the client never seeing the response.
  completed,

  /// The ledger was read successfully and no new payment appeared. Retrying is
  /// safe.
  notFound,

  /// The ledger could not be read (still offline, server down). Nothing can be
  /// concluded — the user must check manually and must NOT be told it is safe
  /// to retry.
  unknown,
}

class PaymentReconciliationResult {
  final PaymentVerdict verdict;

  /// The matched ledger row, when [verdict] is [PaymentVerdict.completed].
  final Data? payment;

  const PaymentReconciliationResult(this.verdict, [this.payment]);

  bool get isCompleted => verdict == PaymentVerdict.completed;
  bool get isSafeToRetry => verdict == PaymentVerdict.notFound;
}

/// Answers "did that payment actually go through?" after a request whose
/// outcome the client never learned — the connection dropped mid-flight.
///
/// The server does not currently echo our `X-Idempotency-Key` back on the
/// ledger, so an exact match on the key is impossible. Instead this takes a
/// snapshot of the ledger's payment ids *before* submitting and looks for an id
/// that wasn't there before. That distinguishes our payment from an earlier
/// identical one — matching on amount alone cannot.
class PaymentReconciliationService {
  final TenantLeaseRepository _repo;

  PaymentReconciliationService({TenantLeaseRepository? repo})
      : _repo = repo ?? TenantLeaseRepository();

  /// Ids of the payments already on the ledger. Call immediately BEFORE
  /// submitting. Best effort: returns null if the ledger can't be read, which
  /// downgrades a later check to amount-matching rather than blocking payment.
  Future<Set<String>?> snapshot({
    required String leaseId,
    required String tenantId,
  }) async {
    try {
      final ledger = await _repo.fetchLedgerWithTenant(
        leaseId: leaseId,
        tenantId: tenantId,
      );
      return _idsOf(ledger);
    } catch (e) {
      logError('reconciliation snapshot failed: $e');
      return null; // never block a payment because the snapshot failed
    }
  }

  /// Re-reads the ledger and decides whether [amount] was posted.
  ///
  /// Polls a few times because the record may lag the gateway response by a
  /// second or two, and because the device may still be reconnecting.
  Future<PaymentReconciliationResult> verify({
    required String leaseId,
    required String tenantId,
    required double amount,
    Set<String>? before,
    List<Duration> backoff = const [
      Duration(seconds: 2),
      Duration(seconds: 5),
      Duration(seconds: 10),
    ],
  }) async {
    var everRead = false;

    for (var i = 0; i < backoff.length; i++) {
      await Future.delayed(backoff[i]);

      LeaseLedger? ledger;
      try {
        ledger =
            await _repo.fetchLedgerWithTenant(leaseId: leaseId, tenantId: tenantId);
      } catch (e) {
        logError('reconciliation attempt ${i + 1} failed: $e');
        continue; // still offline — try again
      }
      if (ledger == null) continue;
      everRead = true;

      final match = _findNewPayment(ledger, before: before, amount: amount);
      if (match != null) {
        return PaymentReconciliationResult(PaymentVerdict.completed, match);
      }
    }

    // Read the ledger at least once and our payment wasn't on it -> safe to
    // retry. Never read it -> we genuinely do not know.
    return PaymentReconciliationResult(
      everRead ? PaymentVerdict.notFound : PaymentVerdict.unknown,
    );
  }

  Set<String> _idsOf(LeaseLedger? ledger) {
    final rows = <Data>[
      ...?ledger?.data,
      ...?ledger?.tenantPayments,
    ];
    return rows.map(_idOf).whereType<String>().toSet();
  }

  String? _idOf(Data d) => d.paymentId ?? d.sId ?? d.transactionid;

  /// A row counts as ours when its id is new since [before] and the amount
  /// matches. Without a snapshot, fall back to amount alone — weaker, so the
  /// caller should treat that as advisory.
  Data? _findNewPayment(
    LeaseLedger ledger, {
    required Set<String>? before,
    required double amount,
  }) {
    final rows = <Data>[
      ...?ledger.data,
      ...?ledger.tenantPayments,
    ];
    for (final row in rows) {
      if (row.isDelete == true) continue;
      final rowAmount = row.totalAmount;
      if (rowAmount == null) continue;
      if ((rowAmount - amount).abs() > 0.009) continue; // cent tolerance

      if (before != null) {
        final id = _idOf(row);
        if (id == null || before.contains(id)) continue; // already existed
      }
      return row;
    }
    return null;
  }

  // ---- Pending-attempt store + pre-submit guard ----------------------------
  // The reconciliation dialog tells the user what happened. This stops them
  // acting against it: if the previous attempt on this lease ended with an
  // unknown outcome, the NEXT submit is checked against the ledger first and
  // blocked when the payment already went through.

  static const _pendingKey = 'pending_payment_attempt';

  /// Remembers an attempt whose outcome we never learned. Survives app restart.
  Future<void> rememberPending(PendingPaymentAttempt attempt) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingKey, jsonEncode(attempt.toJson()));
    } catch (e) {
      logError('rememberPending failed: $e');
    }
  }

  Future<PendingPaymentAttempt?> readPending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_pendingKey);
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return PendingPaymentAttempt.fromJson(Map<String, dynamic>.from(decoded));
    } catch (e) {
      logError('readPending failed: $e');
      return null;
    }
  }

  Future<void> clearPending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingKey);
    } catch (e) {
      logError('clearPending failed: $e');
    }
  }

  /// Call immediately BEFORE submitting a payment.
  ///
  /// Returns the already-posted payment when the previous unknown-outcome
  /// attempt on this lease turns out to have gone through — the caller must
  /// then NOT submit. Returns null when it is safe to proceed.
  ///
  /// Deliberately fails open: if the ledger can't be read, or the pending
  /// record is stale/for another lease, this returns null and the payment
  /// proceeds. Blocking a legitimate payment is worse than the double-charge
  /// this guards against, which the dialog already warns about.
  Future<Data?> blockingDuplicate({
    required String leaseId,
    required String tenantId,
    Duration maxAge = const Duration(hours: 24),
  }) async {
    final pending = await readPending();
    if (pending == null) return null;

    // Different lease, or old enough that a match would be coincidence.
    final age = DateTime.now().difference(pending.attemptedAt);
    if (pending.leaseId != leaseId || age > maxAge || age.isNegative) {
      await clearPending();
      return null;
    }

    // Single check — the user is waiting on a button press, not a failure.
    final result = await verify(
      leaseId: pending.leaseId,
      tenantId: pending.tenantId,
      amount: pending.amount,
      before: pending.before,
      backoff: const [Duration.zero],
    );

    if (result.isCompleted) {
      await clearPending();
      return result.payment;
    }
    if (result.verdict == PaymentVerdict.notFound) {
      await clearPending(); // confirmed absent — retrying is genuinely safe
    }
    return null; // unknown -> fail open, let the payment through
  }
}
