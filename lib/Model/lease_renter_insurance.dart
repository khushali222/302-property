class lease_renter_insurance {
  String? sId;
  String? rentersInsuranceId;
  String? leaseId;
  List<String>? tenants;
  String? insuranceCompany;
  String? insuranceCompanyPhoneNumber;
  String? policyId;
  String? effectiveDate;
  String? expirationDate;
  int? liabilityCoverage;
  String? insurancePolicyDocument;
  bool? active;
  bool? isDelete;
  String? dateCreated;
  String? dateModified;
  List<TenantDetails>? tenantDetails;

  lease_renter_insurance(
      {this.sId,
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
        this.isDelete,
        this.dateCreated,
        this.dateModified,
        this.tenantDetails});

  lease_renter_insurance.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    rentersInsuranceId = json['renters_insurance_id'];
    leaseId = json['lease_id'];
    tenants = json['tenants'].cast<String>();
    insuranceCompany = json['insurance_company'];
    insuranceCompanyPhoneNumber = json['insurance_company_phone_number'];
    policyId = json['policy_id'];
    effectiveDate = json['effective_date'];
    expirationDate = json['expiration_date'];
    liabilityCoverage = json['liability_coverage'];
    insurancePolicyDocument = json['insurance_policy_document'];
    active = json['active'];
    isDelete = json['is_delete'];
    dateCreated = json['date_created'];
    dateModified = json['date_modified'];
    if (json['tenant_details'] != null) {
      tenantDetails = <TenantDetails>[];
      json['tenant_details'].forEach((v) {
        tenantDetails!.add(new TenantDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['renters_insurance_id'] = this.rentersInsuranceId;
    data['lease_id'] = this.leaseId;
    data['tenants'] = this.tenants;
    data['insurance_company'] = this.insuranceCompany;
    data['insurance_company_phone_number'] = this.insuranceCompanyPhoneNumber;
    data['policy_id'] = this.policyId;
    data['effective_date'] = this.effectiveDate;
    data['expiration_date'] = this.expirationDate;
    data['liability_coverage'] = this.liabilityCoverage;
    data['insurance_policy_document'] = this.insurancePolicyDocument;
    data['active'] = this.active;
    data['is_delete'] = this.isDelete;
    data['date_created'] = this.dateCreated;
    data['date_modified'] = this.dateModified;
    if (this.tenantDetails != null) {
      data['tenant_details'] =
          this.tenantDetails!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TenantDetails {
  String? tenantId;
  String? tenantFirstName;
  String? tenantLastName;
  String? tenantEmail;

  TenantDetails(
      {this.tenantId,
        this.tenantFirstName,
        this.tenantLastName,
        this.tenantEmail});

  TenantDetails.fromJson(Map<String, dynamic> json) {
    tenantId = json['tenant_id'];
    tenantFirstName = json['tenant_firstName'];
    tenantLastName = json['tenant_lastName'];
    tenantEmail = json['tenant_email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tenant_id'] = this.tenantId;
    data['tenant_firstName'] = this.tenantFirstName;
    data['tenant_lastName'] = this.tenantLastName;
    data['tenant_email'] = this.tenantEmail;
    return data;
  }
}
