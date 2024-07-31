class Insurance_data {
  String? tenantInsuranceId;
  String? tenantId;
  String? adminId;
  String? policyId;
  String? provider;
  int? liabilityCoverage;
  String? effectiveDate;
  String? expirationDate;
  String? policy;
  String? status;
  String? createdAt;
  bool? isDelete;
  String? sId;
  int? iV;

  Insurance_data(
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
        this.iV});

  Insurance_data.fromJson(Map<String, dynamic> json) {
    tenantInsuranceId = json['TenantInsurance_id'];
    tenantId = json['tenant_id'];
    adminId = json['admin_id'];
    policyId = json['policy_id'];
    provider = json['Provider'];
    liabilityCoverage = json['LiabilityCoverage'];
    effectiveDate = json['EffectiveDate'];
    expirationDate = json['ExpirationDate'];
    policy = json['Policy'];
    status = json['status'];
    createdAt = json['createdAt'];
    isDelete = json['is_delete'];
    sId = json['_id'];
    iV = json['__v'];
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
