// class RentersInsuranceResponse {
//   final int? statusCode;
//   final List<RentersInsuranceData>? data;
//
//
//   RentersInsuranceResponse({
//     this.statusCode,
//     this.data,
//
//   });
//
//   factory RentersInsuranceResponse.fromJson(Map<String, dynamic> json) {
//     return RentersInsuranceResponse(
//       statusCode: json['statusCode'] as int?,
//       data: (json['data'] as List<dynamic>?)
//           ?.map((e) => RentersInsuranceData.fromJson(e as Map<String, dynamic>))
//           .toList(),
//
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'statusCode': statusCode,
//       'data': data?.map((e) => e.toJson()).toList(),
//
//     };
//   }
// }

class RentersInsuranceResponse {
  final int? statusCode;
  final List<RentersInsuranceData>? data;

  RentersInsuranceResponse({this.statusCode, this.data});

  factory RentersInsuranceResponse.fromJson(Map<String, dynamic> json) {
    return RentersInsuranceResponse(
      statusCode: json['statusCode'],
      data: json['data'] != null
          ? List<RentersInsuranceData>.from(
              json['data'].map((v) => RentersInsuranceData.fromJson(v)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}

class RentersInsuranceData {
  final String? id;
  final String? rentersInsuranceId;
  final String? leaseId;
  final List<String>? tenants;
  final String? insuranceCompany;
  final String? insuranceCompanyPhoneNumber;
  final String? policyId;
  final String? effectiveDate;
  final String? expirationDate;
  final dynamic liabilityCoverage;
  final List<TenantDetails>? tenantDetails;

  RentersInsuranceData({
    this.id,
    this.rentersInsuranceId,
    this.leaseId,
    this.tenants,
    this.insuranceCompany,
    this.insuranceCompanyPhoneNumber,
    this.policyId,
    this.effectiveDate,
    this.expirationDate,
    this.liabilityCoverage,
    this.tenantDetails,
  });

  factory RentersInsuranceData.fromJson(Map<String, dynamic> json) {
    return RentersInsuranceData(
      id: json['_id'] ?? "",
      rentersInsuranceId: json['renters_insurance_id'] ?? "",
      leaseId: json['lease_id'] ?? "",
      tenants:
          json['tenants'] != null ? List<String>.from(json['tenants']) : null,
      insuranceCompany: json['insurance_company'] ?? "",
      insuranceCompanyPhoneNumber: json['insurance_company_phone_number'] ?? "",
      policyId: json['policy_id'] ?? "",
      effectiveDate: json['effective_date'] ?? "",
      expirationDate: json['expiration_date'] ?? "",
      liabilityCoverage: json['liability_coverage'] ?? 00,
      tenantDetails: (json['tenant_details'] as List<dynamic>?)
          ?.map((e) => TenantDetails.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'renters_insurance_id': rentersInsuranceId,
      'lease_id': leaseId,
      'tenants': tenants,
      'insurance_company': insuranceCompany,
      'insurance_company_phone_number': insuranceCompanyPhoneNumber,
      'policy_id': policyId,
      'effective_date': effectiveDate,
      'expiration_date': expirationDate,
      'liability_coverage': liabilityCoverage,
      'tenant_details': tenantDetails?.map((e) => e.toJson()).toList(),
    };
  }
}

class TenantDetails {
  final String? tenantFirstName;
  final String? tenantLastName;
  final String? tenantEmail;

  TenantDetails({
    this.tenantFirstName,
    this.tenantLastName,
    this.tenantEmail,
  });

  factory TenantDetails.fromJson(Map<String, dynamic> json) {
    return TenantDetails(
      tenantFirstName: json['tenant_firstName'] ?? "",
      tenantLastName: json['tenant_lastName'] ?? "",
      tenantEmail: json['tenant_email'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_firstName': tenantFirstName,
      'tenant_lastName': tenantLastName,
      'tenant_email': tenantEmail,
    };
  }
}
