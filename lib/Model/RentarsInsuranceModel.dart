class RentersInsuranceModel {
  List<RentersInsuranceData>? data;
  int? statusCode;
  String? message;

  RentersInsuranceModel({this.data, this.statusCode, this.message});

  RentersInsuranceModel.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <RentersInsuranceData>[];
      json['data'].forEach((v) {
        data!.add(RentersInsuranceData.fromJson(v));
      });
    }
    statusCode = json['statusCode'] as int?;
    message = json['message'] as String?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class RentersInsuranceData {
  String? leaseId;
  String? rentalAddress;
  List<Tenants>? tenants;

  RentersInsuranceData({this.leaseId, this.rentalAddress, this.tenants});

  RentersInsuranceData.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      print('Key: $key, Value: $value');
    });

    leaseId = json['lease_id'] as String?;
    rentalAddress = json['rental_address'] as String?;
    if (json['tenants'] != null) {
      tenants = <Tenants>[];
      json['tenants'].forEach((v) {
        tenants!.add(Tenants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lease_id'] = this.leaseId;
    data['rental_address'] = this.rentalAddress;
    if (this.tenants != null) {
      data['tenants'] = this.tenants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tenants {
  String? tenantId;
  String? tenantName;
  String? unitDetails;
  TenantInsurance? tenantInsurance;

  Tenants(
      {this.tenantId, this.tenantName, this.unitDetails, this.tenantInsurance});

  Tenants.fromJson(Map<String, dynamic> json) {
    tenantId = json['tenant_id'] as String?;
    tenantName = json['tenant_name'] as String?;
    unitDetails = json['unit_details'] as String?;
    tenantInsurance = json['tenantInsurance'] != null
        ? TenantInsurance.fromJson(
            json['tenantInsurance'] as Map<String, dynamic>)
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['tenant_id'] = this.tenantId;
    data['tenant_name'] = this.tenantName;
    data['unit_details'] = this.unitDetails;
    if (this.tenantInsurance != null) {
      data['tenantInsurance'] = this.tenantInsurance!.toJson();
    }
    return data;
  }
}

class TenantInsurance {
  String? sId;
  String? tenantInsuranceId;
  String? tenantId;
  String? adminId;
  String? policyId;
  String? provider;
  int? liabilityCoverage;
  String? effectiveDate;
  String? expirationDate;
  String? policy;
  String? createdAt;
  bool? isDelete;
  int? iV;

  TenantInsurance(
      {this.sId,
      this.tenantInsuranceId,
      this.tenantId,
      this.adminId,
      this.policyId,
      this.provider,
      this.liabilityCoverage,
      this.effectiveDate,
      this.expirationDate,
      this.policy,
      this.createdAt,
      this.isDelete,
      this.iV});

  TenantInsurance.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] as String?;
    tenantInsuranceId = json['TenantInsurance_id'] as String?;
    tenantId = json['tenant_id'] as String?;
    adminId = json['admin_id'] as String?;
    policyId = json['policy_id'] as String?;
    provider = json['Provider'] as String?;
    liabilityCoverage = json['LiabilityCoverage'] as int?;
    effectiveDate = json['EffectiveDate'] as String?;
    expirationDate = json['ExpirationDate'] as String?;
    policy = json['Policy'] as String?;
    createdAt = json['createdAt'] as String?;
    isDelete = json['is_delete'] as bool?;
    iV = json['__v'] as int?;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.sId;
    data['TenantInsurance_id'] = this.tenantInsuranceId;
    data['tenant_id'] = this.tenantId;
    data['admin_id'] = this.adminId;
    data['policy_id'] = this.policyId;
    data['Provider'] = this.provider;
    data['LiabilityCoverage'] = this.liabilityCoverage;
    data['EffectiveDate'] = this.effectiveDate;
    data['ExpirationDate'] = this.expirationDate;
    data['Policy'] = this.policy;
    data['createdAt'] = this.createdAt;
    data['is_delete'] = this.isDelete;
    data['__v'] = this.iV;
    return data;
  }
}
