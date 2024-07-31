class CardsDetailModel {
  int? statusCode;
  List<CardData>? data;
  int? count;
  String? message;

  CardsDetailModel({this.statusCode, this.data, this.count, this.message});

  CardsDetailModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <CardData>[];
      json['data'].forEach((v) {
        data!.add(new CardData.fromJson(v));
      });
    }
    count = json['count'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['count'] = this.count;
    data['message'] = this.message;
    return data;
  }
}

class CardData {
  String? sId;
  String? planId;
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
  int? vendorCount;
  bool? paymentFunctionality;
  String? annualDiscount;
  String? createdAt;
  String? updatedAt;
  int? iV;

  CardData(
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
      this.vendorCount,
      this.paymentFunctionality,
      this.annualDiscount,
      this.createdAt,
      this.updatedAt,
      this.iV});

  CardData.fromJson(Map<String, dynamic> json) {
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
    planDays = json['plan_days'].toString();
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
    vendorCount = json['vendor_count'];
    paymentFunctionality = json['payment_functionality'];
    annualDiscount = json['annual_discount'].toString();
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
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
    data['vendor_count'] = this.vendorCount;
    data['payment_functionality'] = this.paymentFunctionality;
    data['annual_discount'] = this.annualDiscount;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
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
