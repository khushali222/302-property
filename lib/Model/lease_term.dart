/// One entry from GET /api/leases/{lease_id}/terms.
///
/// The server returns a hybrid history: terms it has on record, plus terms it
/// reconstructs from the Rent-account charge history for legacy leases that
/// were extended by editing the end date. Reconstructed terms come back with
/// `source: "inferred"` and web marks them with an "inferred" badge so nobody
/// mistakes an estimate for a recorded renewal.
class LeaseTerm {
  final String? startDate;
  final String? endDate;
  final num? rent;

  /// "recorded" for a real lease history entry, "inferred" when the server
  /// reconstructed the term from rent charges.
  final String? source;
  final String? leaseType;
  final String? status;

  const LeaseTerm({
    this.startDate,
    this.endDate,
    this.rent,
    this.source,
    this.leaseType,
    this.status,
  });

  bool get isInferred => source == 'inferred';

  /// Month-to-month / open-ended leases store a far-future sentinel end date
  /// (e.g. 2050-07-25). Web prints "ongoing" rather than that confusing year,
  /// judged per-term so a prior FIXED term still shows its real end date.
  bool get isOngoing {
    final end = endDate;
    if (end == null || end.length < 4) return false;
    final year = int.tryParse(end.substring(0, 4));
    return year != null && year >= 2049;
  }

  static LeaseTerm fromJson(Map<String, dynamic> json) => LeaseTerm(
        startDate: json['start_date']?.toString(),
        endDate: json['end_date']?.toString(),
        rent: json['rent'] is num
            ? json['rent'] as num
            : num.tryParse('${json['rent'] ?? ''}'),
        source: json['source']?.toString(),
        leaseType: json['lease_type']?.toString(),
        status: json['status']?.toString(),
      );

  /// Parses the `{ statusCode, data: [...] }` envelope the endpoint returns.
  static List<LeaseTerm> listFromResponse(dynamic decoded) {
    if (decoded is! Map) return const [];
    final data = decoded['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map>()
        .map((e) => LeaseTerm.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
