// Helper function to safely convert to double
double _toDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    if (value.isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }
  return 0.0;
}

// Helper function to safely convert to int
int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    if (value.isEmpty) return 0;
    return int.tryParse(value) ?? 0;
  }
  return 0;
}

class LeaseRenewalReport {
  final List<LeaseEnding> leasesEnding;
  final List<MonthToMonthLease> mtmLeases;
  final Summary summary;

  LeaseRenewalReport({
    required this.leasesEnding,
    required this.mtmLeases,
    required this.summary,
  });

  factory LeaseRenewalReport.fromJson(Map<String, dynamic> json) {
    return LeaseRenewalReport(
      leasesEnding: (json['leases_ending'] as List?)
              ?.map((e) => LeaseEnding.fromJson(e))
              .toList() ??
          [],
      mtmLeases: (json['mtm_leases'] as List?)
              ?.map((e) => MonthToMonthLease.fromJson(e))
              .toList() ??
          [],
      summary: Summary.fromJson(json['summary'] ?? {}),
    );
  }
}

class LeaseEnding {
  final String propertyId;
  final String propertyAddress;
  final String propertyCity;
  final String propertyState;
  final String propertyType;
  final bool trashServiceAvailable;
  final double trashServiceMonthlyCost;
  final List<Tenant> tenants;
  final RentData rentData;
  final Deposits deposits;
  final Metrics metrics;
  final String tenantNeedsTrashService;
  final List<Note> notes;

  LeaseEnding({
    required this.propertyId,
    required this.propertyAddress,
    required this.propertyCity,
    required this.propertyState,
    required this.propertyType,
    required this.trashServiceAvailable,
    required this.trashServiceMonthlyCost,
    required this.tenants,
    required this.rentData,
    required this.deposits,
    required this.metrics,
    required this.tenantNeedsTrashService,
    required this.notes,
  });

  factory LeaseEnding.fromJson(Map<String, dynamic> json) {
    return LeaseEnding(
      propertyId: json['property_id']?.toString() ?? '',
      propertyAddress: json['property_address']?.toString() ?? '',
      propertyCity: json['property_city']?.toString() ?? '',
      propertyState: json['property_state']?.toString() ?? '',
      propertyType: json['property_type']?.toString() ?? '',
      trashServiceAvailable: json['trash_service_available'] ?? false,
      trashServiceMonthlyCost: _toDouble(json['trash_service_monthly_cost']),
      tenants: (json['tenants'] as List?)
              ?.map((e) => Tenant.fromJson(e))
              .toList() ??
          [],
      rentData: RentData.fromJson(json['rent_data'] ?? {}),
      deposits: Deposits.fromJson(json['deposits'] ?? {}),
      metrics: Metrics.fromJson(json['metrics'] ?? {}),
      tenantNeedsTrashService:
          json['tenant_needs_trash_service']?.toString() ?? 'No',
      notes: (json['notes'] as List?)
              ?.map((e) => Note.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class MonthToMonthLease {
  final String propertyId;
  final String propertyAddress;
  final String propertyCity;
  final String propertyState;
  final String propertyType;
  final bool trashServiceAvailable;
  final double trashServiceMonthlyCost;
  final List<Tenant> tenants;
  final RentData rentData;
  final Deposits deposits;
  final Metrics metrics;
  final String tenantNeedsTrashService;
  final List<Note> notes;

  MonthToMonthLease({
    required this.propertyId,
    required this.propertyAddress,
    required this.propertyCity,
    required this.propertyState,
    required this.propertyType,
    required this.trashServiceAvailable,
    required this.trashServiceMonthlyCost,
    required this.tenants,
    required this.rentData,
    required this.deposits,
    required this.metrics,
    required this.tenantNeedsTrashService,
    required this.notes,
  });

  factory MonthToMonthLease.fromJson(Map<String, dynamic> json) {
    return MonthToMonthLease(
      propertyId: json['property_id']?.toString() ?? '',
      propertyAddress: json['property_address']?.toString() ?? '',
      propertyCity: json['property_city']?.toString() ?? '',
      propertyState: json['property_state']?.toString() ?? '',
      propertyType: json['property_type']?.toString() ?? '',
      trashServiceAvailable: json['trash_service_available'] ?? false,
      trashServiceMonthlyCost: _toDouble(json['trash_service_monthly_cost']),
      tenants: (json['tenants'] as List?)
              ?.map((e) => Tenant.fromJson(e))
              .toList() ??
          [],
      rentData: RentData.fromJson(json['rent_data'] ?? {}),
      deposits: Deposits.fromJson(json['deposits'] ?? {}),
      metrics: Metrics.fromJson(json['metrics'] ?? {}),
      tenantNeedsTrashService:
          json['tenant_needs_trash_service']?.toString() ?? 'No',
      notes: (json['notes'] as List?)
              ?.map((e) => Note.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Tenant {
  final String tenantId;
  final String tenantName;
  final String tenantEmail;
  final String tenantPhone;

  Tenant({
    required this.tenantId,
    required this.tenantName,
    required this.tenantEmail,
    required this.tenantPhone,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      tenantId: json['tenant_id']?.toString() ?? '',
      tenantName: json['tenant_name']?.toString() ?? '',
      tenantEmail: json['tenant_email']?.toString() ?? '',
      tenantPhone: json['tenant_phone']?.toString() ?? '',
    );
  }
}

class RentData {
  final double rentYear1;
  final double rentYear2;
  final double rentYear3;
  final int year1;
  final int year2;
  final int year3;
  final double newRentAmount;
  final String newRentIncludesTrashService;
  final double rentIncrease;
  final String lastIncreaseDate;

  RentData({
    required this.rentYear1,
    required this.rentYear2,
    required this.rentYear3,
    required this.year1,
    required this.year2,
    required this.year3,
    required this.newRentAmount,
    required this.newRentIncludesTrashService,
    required this.rentIncrease,
    required this.lastIncreaseDate,
  });

  factory RentData.fromJson(Map<String, dynamic> json) {
    return RentData(
      rentYear1: _toDouble(json['rent_year1']),
      rentYear2: _toDouble(json['rent_year2']),
      rentYear3: _toDouble(json['rent_year3']),
      year1: _toInt(json['year1']),
      year2: _toInt(json['year2']),
      year3: _toInt(json['year3']),
      newRentAmount: _toDouble(json['new_rent_amount']),
      newRentIncludesTrashService:
          json['new_rent_includes_trash_service']?.toString() ?? 'No',
      rentIncrease: _toDouble(json['rent_increase']),
      lastIncreaseDate: json['last_increase_date']?.toString() ?? '',
    );
  }
}

class Deposits {
  final double totalDeposits;
  final List<TenantDeposit> tenantDeposits;

  Deposits({
    required this.totalDeposits,
    required this.tenantDeposits,
  });

  factory Deposits.fromJson(Map<String, dynamic> json) {
    return Deposits(
      totalDeposits: _toDouble(json['total_deposits']),
      tenantDeposits: (json['tenant_deposits'] as List?)
              ?.map((e) => TenantDeposit.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class TenantDeposit {
  final String tenantId;
  final double depositAmount;

  TenantDeposit({
    required this.tenantId,
    required this.depositAmount,
  });

  factory TenantDeposit.fromJson(Map<String, dynamic> json) {
    return TenantDeposit(
      tenantId: json['tenant_id']?.toString() ?? '',
      depositAmount: _toDouble(json['deposit_amount']),
    );
  }
}

class Metrics {
  final int timeLateCount;
  final int courtFilings;

  Metrics({
    required this.timeLateCount,
    required this.courtFilings,
  });

  factory Metrics.fromJson(Map<String, dynamic> json) {
    return Metrics(
      timeLateCount: _toInt(json['time_late_count']),
      courtFilings: _toInt(json['court_filings']),
    );
  }
}

class Note {
  final String noteId;
  final String noteType;
  final String content;
  final bool isPrivate;
  final String createdAt;

  Note({
    required this.noteId,
    required this.noteType,
    required this.content,
    required this.isPrivate,
    required this.createdAt,
  });

  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      noteId: json['note_id']?.toString() ?? '',
      noteType: json['note_type']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      isPrivate: json['is_private'] ?? false,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class Summary {
  final int totalActiveLeases;
  final int totalProperties;
  final int totalLeasesEnding;
  final int totalMtmLeases;
  final int totalTenants;

  Summary({
    required this.totalActiveLeases,
    required this.totalProperties,
    required this.totalLeasesEnding,
    required this.totalMtmLeases,
    required this.totalTenants,
  });

  factory Summary.fromJson(Map<String, dynamic> json) {
    return Summary(
      totalActiveLeases: _toInt(json['total_active_leases']),
      totalProperties: _toInt(json['total_properties']),
      totalLeasesEnding: _toInt(json['total_leases_ending']),
      totalMtmLeases: _toInt(json['total_mtm_leases']),
      totalTenants: _toInt(json['total_tenants']),
    );
  }
}

