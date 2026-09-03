import 'package:three_zero_two_property/constant/constant.dart';
class LivePropertyResponse {
  int? statusCode;
  String? message;
  List<LivePropertyData>? data;

  LivePropertyResponse({this.statusCode, this.message, this.data});

  LivePropertyResponse.fromJson(Map<String, dynamic> json) {
    statusCode = asIntN(json['statusCode']);
    message = json['message'];
    if (json['data'] != null) {
      data = <LivePropertyData>[];
      json['data'].forEach((v) {
        data!.add(LivePropertyData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class LivePropertyData {
  String? id;
  String? adminId;
  List<String>? properties;
  String? bankName;
  String? bankAddress;
  String? bankContactNo;
  String? bankEmail;
  String? relationshipManagerFirstName;
  String? relationshipManagerLastName;
  String? relationshipManagerPhone;
  String? relationshipManagerEmail;
  String? mortgageNumber;
  String? mortgageNo;
  /// `num?` + asNumN: the API can return this as an int, a decimal or a
  /// numeric string. A raw assignment to `int?` threw on anything but an
  /// int, and because it throws inside fromJson it took the whole list
  /// down, not just the one row.
  num? loanAmount;
  double? interestRate;
  String? startDate;
  String? endDate;
  String? status;
  double? monthlyPayment;
  int? remainingBalance;
  String? lastPaymentDate;
  String? nextPaymentDate;
  String? borrowerFirstName;
  String? borrowerLastName;
  String? borrowerSsn;
  String? borrowerAddress;
  String? borrowerPhone;
  String? borrowerEmail;
  String? createdBy;
  String? updatedBy;
  bool? isDelete;
  String? createdAt;
  String? updatedAt;
  int? v;
  PropertyInfo? property;
  RentalOwner? rentalOwner;
  PurchaseInfo? purchaseInfo;
  String? rentalFlip;
  String? placedInService;
  int? insuredYear;
  int? insuredValue;
  int? taxBill;
  int? monthlyRent;
  bool? hasMortgage;
  String? mortgageBank;
  int? mortgageBalance;
  double? interest;
  int? principal;
  double? payment;
  double? interestPercentage;
  String? interestType;
  String? mortgageDate;
  String? maturityDate;
  String? lastUpdateDate;

  LivePropertyData({
    this.id,
    this.adminId,
    this.properties,
    this.bankName,
    this.bankAddress,
    this.bankContactNo,
    this.bankEmail,
    this.relationshipManagerFirstName,
    this.relationshipManagerLastName,
    this.relationshipManagerPhone,
    this.relationshipManagerEmail,
    this.mortgageNumber,
    this.mortgageNo,
    this.loanAmount,
    this.interestRate,
    this.startDate,
    this.endDate,
    this.status,
    this.monthlyPayment,
    this.remainingBalance,
    this.lastPaymentDate,
    this.nextPaymentDate,
    this.borrowerFirstName,
    this.borrowerLastName,
    this.borrowerSsn,
    this.borrowerAddress,
    this.borrowerPhone,
    this.borrowerEmail,
    this.createdBy,
    this.updatedBy,
    this.isDelete,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.property,
    this.rentalOwner,
    this.purchaseInfo,
    this.rentalFlip,
    this.placedInService,
    this.insuredYear,
    this.insuredValue,
    this.taxBill,
    this.monthlyRent,
    this.hasMortgage,
    this.mortgageBank,
    this.mortgageBalance,
    this.interest,
    this.principal,
    this.payment,
    this.interestPercentage,
    this.interestType,
    this.mortgageDate,
    this.maturityDate,
    this.lastUpdateDate,
  });

  LivePropertyData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    adminId = json['admin_id'];
    properties = json['properties'] != null
        ? List<String>.from(json['properties'])
        : null;
    bankName = json['bank_name'];
    bankAddress = json['bank_address'];
    bankContactNo = json['bank_contact_no'];
    bankEmail = json['bank_email'];
    relationshipManagerFirstName = json['relationship_manager_first_name'];
    relationshipManagerLastName = json['relationship_manager_last_name'];
    relationshipManagerPhone = json['relationship_manager_phone'];
    relationshipManagerEmail = json['relationship_manager_email'];
    mortgageNumber = json['mortgage_number'];
    mortgageNo = json['mortgage_no'];
    loanAmount = asNumN(json['loan_amount']);

    // Properly cast to double if type is int for interestRate and other double fields
    interestRate = json['interest_rate'] != null
        ? (json['interest_rate'] is int
            ? (json['interest_rate'] as int).toDouble()
            : json['interest_rate'] is String
                ? double.tryParse(json['interest_rate'])
                : json['interest_rate'])
        : null;

    startDate = json['start_date'];
    endDate = json['end_date'];
    status = json['status'];

    monthlyPayment = json['monthly_payment'] != null
        ? (json['monthly_payment'] is int
            ? (json['monthly_payment'] as int).toDouble()
            : json['monthly_payment'] is String
                ? double.tryParse(json['monthly_payment'])
                : json['monthly_payment'])
        : null;

    remainingBalance = asIntN(json['remaining_balance']);

    lastPaymentDate = json['last_payment_date'];
    nextPaymentDate = json['next_payment_date'];
    borrowerFirstName = json['borrower_first_name'];
    borrowerLastName = json['borrower_last_name'];
    borrowerSsn = json['borrower_ssn'];
    borrowerAddress = json['borrower_address'];
    borrowerPhone = json['borrower_phone'];
    borrowerEmail = json['borrower_email'];
    createdBy = json['created_by'];
    updatedBy = json['updated_by'];
    isDelete = json['is_delete'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = asIntN(json['__v']);
    property = json['property'] != null
        ? PropertyInfo.fromJson(json['property'])
        : null;
    rentalOwner = json['rental_owner'] != null
        ? RentalOwner.fromJson(json['rental_owner'])
        : null;
    purchaseInfo = json['purchase_info'] != null
        ? PurchaseInfo.fromJson(json['purchase_info'])
        : null;
    rentalFlip = json['rental_flip'];
    placedInService = json['placed_in_service'];
    insuredYear = asIntN(json['insured_year']);
    insuredValue = asIntN(json['insured_value']);
    taxBill = asIntN(json['tax_bill']);
    monthlyRent = asIntN(json['monthly_rent']);
    hasMortgage = json['has_mortgage'];
    mortgageBank = json['mortgage_bank'];
    mortgageBalance = asIntN(json['mortgage_balance']);
    interest = json['interest'] != null
        ? (json['interest'] is int
            ? (json['interest'] as int).toDouble()
            : json['interest'] is String
                ? double.tryParse(json['interest'])
                : json['interest'])
        : null;
    principal = asIntN(json['principal']);
    payment = json['payment'] != null
        ? (json['payment'] is int
            ? (json['payment'] as int).toDouble()
            : json['payment'] is String
                ? double.tryParse(json['payment'])
                : json['payment'])
        : null;
    interestPercentage = json['interest_percentage'] != null
        ? (json['interest_percentage'] is int
            ? (json['interest_percentage'] as int).toDouble()
            : json['interest_percentage'] is String
                ? double.tryParse(json['interest_percentage'])
                : json['interest_percentage'])
        : null;
    interestType = json['interest_type'];
    mortgageDate = json['mortgage_date'];
    maturityDate = json['maturity_date'];
    lastUpdateDate = json['last_update_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['admin_id'] = adminId;
    data['properties'] = properties;
    data['bank_name'] = bankName;
    data['bank_address'] = bankAddress;
    data['bank_contact_no'] = bankContactNo;
    data['bank_email'] = bankEmail;
    data['relationship_manager_first_name'] = relationshipManagerFirstName;
    data['relationship_manager_last_name'] = relationshipManagerLastName;
    data['relationship_manager_phone'] = relationshipManagerPhone;
    data['relationship_manager_email'] = relationshipManagerEmail;
    data['mortgage_number'] = mortgageNumber;
    data['mortgage_no'] = mortgageNo;
    data['loan_amount'] = loanAmount;
    data['interest_rate'] = interestRate;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['status'] = status;
    data['monthly_payment'] = monthlyPayment;
    data['remaining_balance'] = remainingBalance;
    data['last_payment_date'] = lastPaymentDate;
    data['next_payment_date'] = nextPaymentDate;
    data['borrower_first_name'] = borrowerFirstName;
    data['borrower_last_name'] = borrowerLastName;
    data['borrower_ssn'] = borrowerSsn;
    data['borrower_address'] = borrowerAddress;
    data['borrower_phone'] = borrowerPhone;
    data['borrower_email'] = borrowerEmail;
    data['created_by'] = createdBy;
    data['updated_by'] = updatedBy;
    data['is_delete'] = isDelete;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = v;
    if (property != null) {
      data['property'] = property!.toJson();
    }
    if (rentalOwner != null) {
      data['rental_owner'] = rentalOwner!.toJson();
    }
    if (purchaseInfo != null) {
      data['purchase_info'] = purchaseInfo!.toJson();
    }
    data['rental_flip'] = rentalFlip;
    data['placed_in_service'] = placedInService;
    data['insured_year'] = insuredYear;
    data['insured_value'] = insuredValue;
    data['tax_bill'] = taxBill;
    data['monthly_rent'] = monthlyRent;
    data['has_mortgage'] = hasMortgage;
    data['mortgage_bank'] = mortgageBank;
    data['mortgage_balance'] = mortgageBalance;
    data['interest'] = interest;
    data['principal'] = principal;
    data['payment'] = payment;
    data['interest_percentage'] = interestPercentage;
    data['interest_type'] = interestType;
    data['mortgage_date'] = mortgageDate;
    data['maturity_date'] = maturityDate;
    data['last_update_date'] = lastUpdateDate;
    return data;
  }
}

class PropertyInfo {
  String? address;
  String? city;
  String? state;
  String? zipcode;
  String? subdivision;
  String? unit;

  PropertyInfo({
    this.address,
    this.city,
    this.state,
    this.zipcode,
    this.subdivision,
    this.unit,
  });

  PropertyInfo.fromJson(Map<String, dynamic> json) {
    address = json['address'];
    city = json['city'];
    state = json['state'];
    zipcode = json['zipcode'];
    subdivision = json['subdivision'];
    unit = json['unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['address'] = address;
    data['city'] = city;
    data['state'] = state;
    data['zipcode'] = zipcode;
    data['subdivision'] = subdivision;
    data['unit'] = unit;
    return data;
  }
}

class RentalOwner {
  String? name;
  String? company;
  String? email;
  String? phone;

  RentalOwner({
    this.name,
    this.company,
    this.email,
    this.phone,
  });

  RentalOwner.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    company = json['company'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['company'] = company;
    data['email'] = email;
    data['phone'] = phone;
    return data;
  }
}

class PurchaseInfo {
  String? purchaseDate;
  int? purchasePrice;
  String? parcelNumber;

  PurchaseInfo({
    this.purchaseDate,
    this.purchasePrice,
    this.parcelNumber,
  });

  PurchaseInfo.fromJson(Map<String, dynamic> json) {
    purchaseDate = json['purchase_date'];
    purchasePrice = asIntN(json['purchase_price']);
    parcelNumber = json['parcel_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['purchase_date'] = purchaseDate;
    data['purchase_price'] = purchasePrice;
    data['parcel_number'] = parcelNumber;
    return data;
  }
}
