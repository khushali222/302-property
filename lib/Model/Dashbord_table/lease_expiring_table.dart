class ExpiringLeasesResponse {
  final List<LeaseDataExpiring>? data;
  final Metadata? metadata;
  final int? statusCode;
  final String? message;

  ExpiringLeasesResponse({
    this.data,
    this.metadata,
    this.statusCode,
    this.message,
  });

  factory ExpiringLeasesResponse.fromJson(Map<String, dynamic> json) {
    return ExpiringLeasesResponse(
      data: (json['data'] as List?)?.map((e) => LeaseDataExpiring.fromJson(e)).toList(),
      metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
      statusCode: json['statusCode'],
      message: json['message'],
    );
  }
}

class LeaseDataExpiring {
  final String? id;
  final String? leaseId;
  final String? rentalAddress;
  final String? unit;
  final String? tenantId;
  final String? tenantName;
  final String? endDate;

  LeaseDataExpiring({
    this.id,
    this.leaseId,
    this.rentalAddress,
    this.unit,
    this.tenantId,
    this.tenantName,
    this.endDate,
  });

  factory LeaseDataExpiring.fromJson(Map<String, dynamic> json) {
    return LeaseDataExpiring(
      id: json['_id'],
      leaseId: json['lease_id'],
      rentalAddress: json['rental_address'],
      unit: json['unit'],
      tenantId: json['tenant_id'],
      tenantName: json['tenant_name'],
      endDate: json['end_date'],
    );
  }
}

class Metadata {
  final int? total;
  final int? page;

  Metadata({
    this.total,
    this.page,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      total: json['total'],
      page: json['page'],
    );
  }
}
