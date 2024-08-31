import 'dart:developer';

class pastPlansHistoryModel {
  int? statusCode;
  String? message;
  List<pastPlanData>? data;

  pastPlansHistoryModel({this.statusCode, this.message, this.data});

  pastPlansHistoryModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <pastPlanData>[];
      json['data'].forEach((v) {
        data!.add(new pastPlanData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class pastPlanData {
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
  String? cardType;
  String? cardNumber;
  String? cvv;
  String? createdAt;
  String? updatedAt;
  int? iV;
  bool? isActive;
  String? planName;
  int? planPrice;
  String? billingInterval;
  List<Features>? features;
  String? planDays;
  int? dayOfMonth;
  String? planPeriods;
  String? billingOption;
  bool? isAnnualDiscount;
  int? propertyCount;
  int? tenantCount;
  int? leaseCount;
  int? rentalownerCount;
  int? applicantCount;
  int? staffmemberCount;
  bool? paymentFunctionality;
  dynamic? annualDiscount;
  int? vendorCount;
  String? subscriptionId;

  pastPlanData(
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
      this.cardType,
      this.cardNumber,
      this.cvv,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.isActive,
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
      this.vendorCount,
      this.subscriptionId});

  pastPlanData.fromJson(Map<String, dynamic> json) {
    log(json.toString());
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
    cardType = json['card_type'];
    cardNumber = json['card_number'];
    cvv = json['cvv'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    isActive = json['is_active'];
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
    vendorCount = json['vendor_count'];
    subscriptionId = json['subscription_id'];
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
    data['card_type'] = this.cardType;
    data['card_number'] = this.cardNumber;
    data['cvv'] = this.cvv;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['is_active'] = this.isActive;
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
    data['vendor_count'] = this.vendorCount;
    data['subscription_id'] = this.subscriptionId;
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
