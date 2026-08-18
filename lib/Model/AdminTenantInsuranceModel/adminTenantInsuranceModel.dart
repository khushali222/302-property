class AdminTenantInsuranceModel {
  String? tenantInsuranceId;
  String? tenantId;
  String? adminId;
  String? policyId;
  String? provider;
  String? liabilityCoverage;
  String? effectiveDate;
  String? expirationDate;
  String? policy;
  String? status;
  String? createdAt;
  bool? isDelete;
  String? sId;
  int? iV;
  // New-API fields
  String? leaseId;
  String? phoneNumber;
  String? rentersInsuranceId;
  // Full covered-tenants list (renters insurance can cover more than one
  // tenant). Web always resends this list as-is on edit; tenantId alone
  // isn't enough to round-trip a save without silently dropping tenants.
  List<String>? tenants;

  AdminTenantInsuranceModel(
      {this.tenantInsuranceId,
      this.tenantId,
      this.adminId,
      this.policyId,
      this.provider,
      this.liabilityCoverage,
      this.effectiveDate,
      this.expirationDate,
      this.policy,
      this.status,
      this.createdAt,
      this.isDelete,
      this.sId,
      this.iV,
      this.leaseId,
      this.phoneNumber,
      this.rentersInsuranceId,
      this.tenants});

  AdminTenantInsuranceModel.fromJson(Map<String, dynamic> json) {
    tenantInsuranceId = json['TenantInsurance_id'];
    // new API returns tenants as a list; old API returns a single tenant_id
    tenantId = json['tenant_id'] ??
        (json['tenants'] is List && (json['tenants'] as List).isNotEmpty
            ? (json['tenants'] as List).first?.toString()
            : null);
    adminId = json['admin_id'];
    policyId = json['policy_id'];
    provider = json['Provider'] ?? json['insurance_company'];
    liabilityCoverage =
        (json['LiabilityCoverage'] ?? json['liability_coverage'])?.toString();
    effectiveDate = json['EffectiveDate'] ?? json['effective_date'];
    expirationDate = json['ExpirationDate'] ?? json['expiration_date'];
    policy = json['Policy'] ?? json['insurance_policy_document'];
    status = json['status'];
    createdAt = json['createdAt'] ?? json['date_created'];
    isDelete = json['is_delete'];
    sId = json['_id'];
    iV = json['__v'];
    // new-API only fields
    leaseId = json['lease_id'];
    phoneNumber = json['insurance_company_phone_number'];
    rentersInsuranceId = json['renters_insurance_id'];
    tenants = json['tenants'] is List
        ? (json['tenants'] as List).map((e) => e.toString()).toList()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TenantInsurance_id'] = this.tenantInsuranceId;
    data['tenant_id'] = this.tenantId;
    data['admin_id'] = this.adminId;
    data['policy_id'] = this.policyId;
    data['Provider'] = this.provider;
    data['LiabilityCoverage'] = this.liabilityCoverage;
    data['EffectiveDate'] = this.effectiveDate;
    data['ExpirationDate'] = this.expirationDate;
    data['Policy'] = this.policy;
    data['status'] = this.status;
    data['createdAt'] = this.createdAt;
    data['is_delete'] = this.isDelete;
    data['_id'] = this.sId;
    data['__v'] = this.iV;
    return data;
  }
}
