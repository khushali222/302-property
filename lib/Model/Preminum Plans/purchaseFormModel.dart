class purchaseFormModel {
  String? adminId;
  String? planId;
  String? planAmount;
  String? purchaseDate;
  String? expirationDate;
  String? planDurationMonths;
  String? status;
  String? address;
  String? city;
  String? state;
  String? postalCode;
  String? country;
  String? cardType;
  String? cardNumber;
  String? cvv;
  String? cardholderName;
  bool? isActive;
  String? dayOfMonth;
  String? billingInterval;
  String? subscriptionId;

  purchaseFormModel(
      {this.adminId,
      this.planId,
      this.planAmount,
      this.purchaseDate,
      this.expirationDate,
      this.planDurationMonths,
      this.status,
      this.address,
      this.city,
      this.state,
      this.postalCode,
      this.country,
      this.cardType,
      this.cardNumber,
      this.cvv,
      this.cardholderName,
      this.isActive,
      this.dayOfMonth,
      this.billingInterval,
      this.subscriptionId});

  purchaseFormModel.fromJson(Map<String, dynamic> json) {
    adminId = json['admin_id'];
    planId = json['plan_id'];
    planAmount = json['plan_amount'];
    purchaseDate = json['purchase_date'];
    expirationDate = json['expiration_date'];
    planDurationMonths = json['plan_duration_months'];
    status = json['status'];
    address = json['address'];
    city = json['city'];
    state = json['state'];
    postalCode = json['postal_code'];
    country = json['country'];
    cardType = json['card_type'];
    cardNumber = json['card_number'];
    cvv = json['cvv'];
    cardholderName = json['cardholder_name'];
    isActive = json['is_active'];
    dayOfMonth = json['day_of_month'];
    billingInterval = json['billing_interval'];
    subscriptionId = json['subscription_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['admin_id'] = this.adminId;
    data['plan_id'] = this.planId;
    data['plan_amount'] = this.planAmount;
    data['purchase_date'] = this.purchaseDate;
    data['expiration_date'] = this.expirationDate;
    data['plan_duration_months'] = this.planDurationMonths;
    data['status'] = this.status;
    data['address'] = this.address;
    data['city'] = this.city;
    data['state'] = this.state;
    data['postal_code'] = this.postalCode;
    data['country'] = this.country;
    data['card_type'] = this.cardType;
    data['card_number'] = this.cardNumber;
    data['cvv'] = this.cvv;
    data['cardholder_name'] = this.cardholderName;
    data['is_active'] = this.isActive;
    data['day_of_month'] = this.dayOfMonth;
    data['billing_interval'] = this.billingInterval;
    data['subscription_id'] = this.subscriptionId;
    return data;
  }
}
