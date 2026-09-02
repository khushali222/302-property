import 'package:three_zero_two_property/Model/json_parse.dart';

class RentersEdit {
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
  final String? insurancePolicyDocument;
  final bool? active;
  final String? dateCreated;
  final String? dateModified;
  final List<TenantDetails>? tenantDetails;

  RentersEdit({
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
    this.insurancePolicyDocument,
    this.active,
    this.dateCreated,
    this.dateModified,
    this.tenantDetails,
  });

  factory RentersEdit.fromJson(Map<String, dynamic> json) {
    return RentersEdit(
      id: json['_id'] as String?,
      rentersInsuranceId: json['renters_insurance_id'] as String?,
      leaseId: json['lease_id'] as String?,
      tenants:
          (json['tenants'] as List<dynamic>?)?.map((e) => e as String).toList(),
      insuranceCompany: json['insurance_company'] as String?,
      insuranceCompanyPhoneNumber:
          json['insurance_company_phone_number'] as String?,
      policyId: json['policy_id'] as String?,
      effectiveDate: json['effective_date'] ?? "",
      expirationDate: json['expiration_date'] ?? "",
      liabilityCoverage: asIntOrNull(json['liability_coverage']),
      insurancePolicyDocument: json['insurance_policy_document'] as String?,
      active: json['active'] as bool?,
      dateCreated: json['date_created'] as String?,
      dateModified: json['date_modified'] as String?,
      tenantDetails: (json['tenant_details'] as List<dynamic>?)
          ?.map((e) => TenantDetails.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TenantDetails {
  final String? tenantId;
  final String? tenantFirstName;
  final String? tenantLastName;
  final String? tenantEmail;

  TenantDetails({
    this.tenantId,
    this.tenantFirstName,
    this.tenantLastName,
    this.tenantEmail,
  });

  factory TenantDetails.fromJson(Map<String, dynamic> json) {
    return TenantDetails(
      tenantId: json['tenant_id'] as String?,
      tenantFirstName: json['tenant_firstName'] as String?,
      tenantLastName: json['tenant_lastName'] as String?,
      tenantEmail: json['tenant_email'] as String?,
    );
  }
}
