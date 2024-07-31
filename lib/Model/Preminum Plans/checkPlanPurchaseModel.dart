class checkPlanPurchaseModel {
  int? statusCode;
  String? message;
  checkPlanPurchaseData? data;

  checkPlanPurchaseModel({this.statusCode, this.message, this.data});

  checkPlanPurchaseModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null
        ? new checkPlanPurchaseData.fromJson(json['data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class checkPlanPurchaseData {
  String? sId;
  String? adminId;
  String? planId;
  String? purchaseId;
  int? planAmount;
  String? purchaseDate;
  String? expirationDate;
  String? status;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  bool? isActive;
  String? subscriptionId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  PlanDetail? planDetail;

  checkPlanPurchaseData(
      {this.sId,
      this.adminId,
      this.planId,
      this.purchaseId,
      this.planAmount,
      this.purchaseDate,
      this.expirationDate,
      this.status,
      this.city,
      this.state,
      this.postalCode,
      this.country,
      this.isActive,
      this.subscriptionId,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.planDetail});

  checkPlanPurchaseData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    adminId = json['admin_id'];
    planId = json['plan_id'];
    purchaseId = json['purchase_id'];
    planAmount = json['plan_amount'];
    purchaseDate = json['purchase_date'];
    expirationDate = json['expiration_date'];
    status = json['status'];
    city = json['city'];
    state = json['state'];
    postalCode = json['postal_code'];
    country = json['country'];
    isActive = json['is_active'];
    subscriptionId = json['subscription_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    planDetail = json['plan_detail'] != null
        ? new PlanDetail.fromJson(json['plan_detail'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['admin_id'] = this.adminId;
    data['plan_id'] = this.planId;
    data['purchase_id'] = this.purchaseId;
    data['plan_amount'] = this.planAmount;
    data['purchase_date'] = this.purchaseDate;
    data['expiration_date'] = this.expirationDate;
    data['status'] = this.status;
    data['city'] = this.city;
    data['state'] = this.state;
    data['postal_code'] = this.postalCode;
    data['country'] = this.country;
    data['is_active'] = this.isActive;
    data['subscription_id'] = this.subscriptionId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    if (this.planDetail != null) {
      data['plan_detail'] = this.planDetail!.toJson();
    }
    return data;
  }
}

class PlanDetail {
  String? sId;
  String? planId;
  String? planName;
  int? planPrice;
  String? billingInterval;
  List<Features>? features;
  Null? planDays;
  int? dayOfMonth;
  Null? planPeriods;
  String? billingOption;
  bool? isAnnualDiscount;
  int? propertyCount;
  int? tenantCount;
  int? leaseCount;
  int? rentalownerCount;
  int? applicantCount;
  int? staffmemberCount;
  bool? paymentFunctionality;
  Null? annualDiscount;
  String? createdAt;
  String? updatedAt;
  int? iV;
  int? vendorCount;

  PlanDetail(
      {this.sId,
      this.planId,
      this.planName,
      this.planPrice,
      this.billingInterval,
      this.features,
      this.planDays,
      this.dayOfMonth,
      this.planPeriods,
      this.billingOption,
      this.isAnnualDiscount,
      this.propertyCount,
      this.tenantCount,
      this.leaseCount,
      this.rentalownerCount,
      this.applicantCount,
      this.staffmemberCount,
      this.paymentFunctionality,
      this.annualDiscount,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.vendorCount});

  PlanDetail.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    planId = json['plan_id'];
    planName = json['plan_name'];
    planPrice = json['plan_price'];
    billingInterval = json['billing_interval'];
    if (json['features'] != null) {
      features = <Features>[];
      json['features'].forEach((v) {
        features!.add(new Features.fromJson(v));
      });
    }
    planDays = json['plan_days'];
    dayOfMonth = json['day_of_month'];
    planPeriods = json['plan_periods'];
    billingOption = json['billingOption'];
    isAnnualDiscount = json['is_annual_discount'];
    propertyCount = json['property_count'];
    tenantCount = json['tenant_count'];
    leaseCount = json['lease_count'];
    rentalownerCount = json['rentalowner_count'];
    applicantCount = json['applicant_count'];
    staffmemberCount = json['staffmember_count'];
    paymentFunctionality = json['payment_functionality'];
    annualDiscount = json['annual_discount'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    vendorCount = json['vendor_count'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['plan_id'] = this.planId;
    data['plan_name'] = this.planName;
    data['plan_price'] = this.planPrice;
    data['billing_interval'] = this.billingInterval;
    if (this.features != null) {
      data['features'] = this.features!.map((v) => v.toJson()).toList();
    }
    data['plan_days'] = this.planDays;
    data['day_of_month'] = this.dayOfMonth;
    data['plan_periods'] = this.planPeriods;
    data['billingOption'] = this.billingOption;
    data['is_annual_discount'] = this.isAnnualDiscount;
    data['property_count'] = this.propertyCount;
    data['tenant_count'] = this.tenantCount;
    data['lease_count'] = this.leaseCount;
    data['rentalowner_count'] = this.rentalownerCount;
    data['applicant_count'] = this.applicantCount;
    data['staffmember_count'] = this.staffmemberCount;
    data['payment_functionality'] = this.paymentFunctionality;
    data['annual_discount'] = this.annualDiscount;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['vendor_count'] = this.vendorCount;
    return data;
  }
}

class Features {
  String? features;

  Features({this.features});

  Features.fromJson(Map<String, dynamic> json) {
    features = json['features'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['features'] = this.features;
    return data;
  }
}
