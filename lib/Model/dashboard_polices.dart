class ExpiringRentersInsuranceResponse {
  final int? statusCode;
  final List<ExpiringRentersInsuranceData>? data;
  final Metadata? metadata;
  final String? message;

  ExpiringRentersInsuranceResponse({
    this.statusCode,
    this.data,
    this.metadata,
    this.message,
  });

  factory ExpiringRentersInsuranceResponse.fromJson(Map<String, dynamic> json) {
    return ExpiringRentersInsuranceResponse(
      statusCode: json['statusCode'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => ExpiringRentersInsuranceData.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata: json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'data': data?.map((e) => e.toJson()).toList(),
      'metadata': metadata?.toJson(),
      'message': message,
    };
  }
}

class ExpiringRentersInsuranceData {
  final String? id;
  final String? insuranceCompany;
  final String? policyId;
  final String? expirationDate;
  final int? liabilityCoverage;
  final String? rentersInsuranceId;
  final String? leaseId;
  final String? tenantId;
  final String? tenantName;
  final String? rentalAddress;

  ExpiringRentersInsuranceData({
    this.id,
    this.insuranceCompany,
    this.policyId,
    this.expirationDate,
    this.liabilityCoverage,
    this.rentersInsuranceId,
    this.leaseId,
    this.tenantId,
    this.tenantName,
    this.rentalAddress,
  });

  factory ExpiringRentersInsuranceData.fromJson(Map<String, dynamic> json) {
    return ExpiringRentersInsuranceData(
      id: json['_id'] as String?,
      insuranceCompany: json['insurance_company'] as String?,
      policyId: json['policy_id'] as String?,
      expirationDate: json['expiration_date'] ?? "",
      liabilityCoverage: json['liability_coverage'] as int?,
      rentersInsuranceId: json['renters_insurance_id'] as String?,
      leaseId: json['lease_id'] as String?,
      tenantId: json['tenant_id'] as String?,
      tenantName: json['tenant_name'] as String?,
      rentalAddress: json['rental_address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'insurance_company': insuranceCompany,
      'policy_id': policyId,
      'expiration_date': expirationDate,
      'liability_coverage': liabilityCoverage,
      'renters_insurance_id': rentersInsuranceId,
      'lease_id': leaseId,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'rental_address': rentalAddress,
    };
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
      total: json['total'] as int?,
      page: json['page'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
    };
  }
}