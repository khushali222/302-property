class PropertyInsuranceResponse {
  int? statusCode;
  bool? success;
  List<PropertyInsuranceData>? data;

  PropertyInsuranceResponse({this.statusCode, this.success, this.data});

  PropertyInsuranceResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    if (json['data'] != null) {
      data = <PropertyInsuranceData>[];
      json['data'].forEach((v) {
        data!.add(PropertyInsuranceData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['success'] = success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PropertyInsuranceData {
  bool? isDelete;
  String? id;
  String? propertyId;
  String? adminId;
  String? insuranceCompanyName;
  String? policyNumber;
  String? policyType;
  String? formNumber;
  String? namedInsured;
  String? mailingAddress;
  String? propertyAddress;
  String? additionalInsured;
  String? effectiveDate;
  String? expirationDate;
  String? cancellationNoticeDate;
  double? premiumAmount;
  double? deductible;
  String? paymentTerms;
  String? claimsContactInfo;
  String? agentName;
  String? agentPhone;
  String? agentEmail;
  String? brokerName;
  String? underwritingOffice;
  String? status;
  String? notes;
  String? createdAt;
  String? updatedAt;
  int? v;

  PropertyInsuranceData({
    this.isDelete,
    this.id,
    this.propertyId,
    this.adminId,
    this.insuranceCompanyName,
    this.policyNumber,
    this.policyType,
    this.formNumber,
    this.namedInsured,
    this.mailingAddress,
    this.propertyAddress,
    this.additionalInsured,
    this.effectiveDate,
    this.expirationDate,
    this.cancellationNoticeDate,
    this.premiumAmount,
    this.deductible,
    this.paymentTerms,
    this.claimsContactInfo,
    this.agentName,
    this.agentPhone,
    this.agentEmail,
    this.brokerName,
    this.underwritingOffice,
    this.status,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  PropertyInsuranceData.fromJson(Map<String, dynamic> json) {
    isDelete = json['is_delete'];
    id = json['_id'];
    propertyId = json['propertyId'];
    adminId = json['admin_id'];
    insuranceCompanyName = json['insurance_company_name'];
    policyNumber = json['policy_number'];
    policyType = json['policy_type'];
    formNumber = json['form_number'];
    namedInsured = json['named_insured'];
    mailingAddress = json['mailing_address'];
    propertyAddress = json['property_address'];
    additionalInsured = json['additional_insured'];
    effectiveDate = json['effective_date'];
    expirationDate = json['expiration_date'];
    cancellationNoticeDate = json['cancellation_notice_date'];
    premiumAmount = json['premium_amount'] != null
        ? double.tryParse(json['premium_amount'].toString())
        : null;
    deductible = json['deductible'] != null
        ? double.tryParse(json['deductible'].toString())
        : null;
    paymentTerms = json['payment_terms'];
    claimsContactInfo = json['claims_contact_info'];
    agentName = json['agent_name'];
    agentPhone = json['agent_phone'];
    agentEmail = json['agent_email'];
    brokerName = json['broker_name'];
    underwritingOffice = json['underwriting_office'];
    status = json['status'];
    notes = json['notes'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['is_delete'] = isDelete;
    data['_id'] = id;
    data['propertyId'] = propertyId;
    data['admin_id'] = adminId;
    data['insurance_company_name'] = insuranceCompanyName;
    data['policy_number'] = policyNumber;
    data['policy_type'] = policyType;
    data['form_number'] = formNumber;
    data['named_insured'] = namedInsured;
    data['mailing_address'] = mailingAddress;
    data['property_address'] = propertyAddress;
    data['additional_insured'] = additionalInsured;
    data['effective_date'] = effectiveDate;
    data['expiration_date'] = expirationDate;
    data['cancellation_notice_date'] = cancellationNoticeDate;
    data['premium_amount'] = premiumAmount;
    data['deductible'] = deductible;
    data['payment_terms'] = paymentTerms;
    data['claims_contact_info'] = claimsContactInfo;
    data['agent_name'] = agentName;
    data['agent_phone'] = agentPhone;
    data['agent_email'] = agentEmail;
    data['broker_name'] = brokerName;
    data['underwriting_office'] = underwritingOffice;
    data['status'] = status;
    data['notes'] = notes;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = v;
    return data;
  }
}
