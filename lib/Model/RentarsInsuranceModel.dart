
import 'package:three_zero_two_property/constant/constant.dart';

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
    statusCode = asIntN(json['statusCode']);
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
  String? id;
  RentersInsurance? rentersInsurance;
  String? leaseId;
  String? rentalAddress;
  String? tenantId;
  String? tenantName;
  String? unitDetails;

  RentersInsuranceData({
    this.id,
    this.rentersInsurance,
    this.leaseId,
    this.rentalAddress,
    this.tenantId,
    this.tenantName,
    this.unitDetails,
  });

  RentersInsuranceData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    rentersInsurance = json['rentersInsurance'] != null
        ? RentersInsurance.fromJson(json['rentersInsurance'])
        : null;
    leaseId = json['lease_id'];
    rentalAddress = json['rental_address'];
    tenantId = json['tenant_id'];
    tenantName = json['tenant_name'];
    unitDetails = json['unit_details'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = id;
    if (rentersInsurance != null) {
      data['rentersInsurance'] = rentersInsurance!.toJson();
    }
    data['lease_id'] = leaseId;
    data['rental_address'] = rentalAddress;
    data['tenant_id'] = tenantId;
    data['tenant_name'] = tenantName;
    data['unit_details'] = unitDetails;
    return data;
  }
}

class RentersInsurance {
  String? id;
  String? rentersInsuranceId;
  String? leaseId;
  String? adminId;
  List<String>? tenants;
  String? insuranceCompany;
  String? insuranceCompanyPhoneNumber;
  String? policyId;
  String? effectiveDate;
  String? expirationDate;
  dynamic liabilityCoverage;
  String? insurancePolicyDocument;
  bool? active;
  bool? isDelete;
  String? dateCreated;
  String? dateModified;
  int? v;

  RentersInsurance({
    this.id,
    this.rentersInsuranceId,
    this.leaseId,
    this.adminId,
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
    this.v,
  });

  RentersInsurance.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    rentersInsuranceId = json['renters_insurance_id'];
    leaseId = json['lease_id'];
    adminId = json['admin_id'];
    tenants = json['tenants'] != null ? List<String>.from(json['tenants']) : [];
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
    v = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = id;
    data['renters_insurance_id'] = rentersInsuranceId;
    data['lease_id'] = leaseId;
    data['admin_id'] = adminId;
    data['tenants'] = tenants;
    data['insurance_company'] = insuranceCompany;
    data['insurance_company_phone_number'] = insuranceCompanyPhoneNumber;
    data['policy_id'] = policyId;
    data['effective_date'] = effectiveDate;
    data['expiration_date'] = expirationDate;
    data['liability_coverage'] = liabilityCoverage;
    data['insurance_policy_document'] = insurancePolicyDocument;
    data['active'] = active;
    data['is_delete'] = isDelete;
    data['date_created'] = dateCreated;
    data['date_modified'] = dateModified;
    data['__v'] = v;
    return data;
  }
}
