String formatAmount(double? amount) {
  if (amount == null) return '';

  // Check if the amount is a whole number
  if (amount % 1 == 0) {
    // If it's a whole number, return without decimal
    return amount.toInt().toString();
  }
  // If it has decimals, return with decimal places
  return amount.toString();
}



class Properties_Revenu_model {
  String? sId;
  String? paymentId;
  String? adminId;
  String? leaseId;
  String? tenantId;
  int? customerVaultId;
  int? billingId;
  dynamic totalAmount; // Change to dynamic to preserve original type
  double? surcharge;
  String? paymentType;
  String? transactionId;
  String? response;
  String? authcode;
  String? responseCode;
  String? avsresponse;
  String? cvvresponse;
  String? state;
  List<Entry>? entry;
  String? type;
  List<dynamic>? paymentAttachment;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  LeaseDataa? leaseData;
  UnitDataa? unitData;
  TenantDataa? tenantData;

  // Add getter for formatted amount that preserves original type
  String get formattedTotalAmount {
    if (totalAmount == null) return '';
    // Return the original value as string without any conversion
    return totalAmount.toString();
  }

  Properties_Revenu_model({
    this.sId,
    this.paymentId,
    this.adminId,
    this.leaseId,
    this.tenantId,
    this.customerVaultId,
    this.billingId,
    this.totalAmount,
    this.surcharge,
    this.paymentType,
    this.transactionId,
    this.response,
    this.authcode,
    this.responseCode,
    this.avsresponse,
    this.cvvresponse,
    this.state,
    this.entry,
    this.type,
    this.paymentAttachment,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.leaseData,
    this.unitData,
    this.tenantData,
  });

  Properties_Revenu_model.fromJson(Map<String, dynamic> json) {

    sId = json['_id'];
    paymentId = json['payment_id'];
    adminId = json['admin_id'];
    leaseId = json['lease_id'];
    tenantId = json['tenant_id'];
    customerVaultId = json['customer_vault_id']?.toInt();
    billingId = json['billing_id']?.toInt();
    // Keep the original type (int or double) from API
    totalAmount = json['total_amount'];
    surcharge = json['surcharge'] != null
        ? (json['surcharge'] is int
            ? (json['surcharge'] as int).toDouble()
            : json['surcharge'])
        : null;
    paymentType = json['payment_type'];
    // transactionId = json['transaction_id'];
    transactionId = json.containsKey('transaction_id') ? json['transaction_id'] : null;
    response = json['response'];
    authcode = json['authcode'];
    responseCode = json['responseCode'];
    avsresponse = json['avsresponse'];
    cvvresponse = json['cvvresponse'];
    state = json['state'];
    if (json['entry'] != null) {
      entry = <Entry>[];
      json['entry'].forEach((v) {
        entry!.add(new Entry.fromJson(v));
      });
    }
    type = json['type'];
    paymentAttachment = json["payment_attachment"] as List<dynamic>?;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];

    leaseData = json['leaseData'] != null
        ? new LeaseDataa.fromJson(json['leaseData'])
        : null;
    unitData = json['unitData'] != null
        ? new UnitDataa.fromJson(json['unitData'])
        : null;
    tenantData = json['tenantData'] != null
        ? new TenantDataa.fromJson(json['tenantData'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['payment_id'] = this.paymentId;
    data['admin_id'] = this.adminId;
    data['lease_id'] = this.leaseId;
    data['tenant_id'] = this.tenantId;
    data['customer_vault_id'] = this.customerVaultId;
    data['billing_id'] = this.billingId;
    data['surcharge'] = this.surcharge;
    data['payment_type'] = this.paymentType;
    data['transaction_id'] = this.transactionId;
    data['response'] = this.response;
    data['authcode'] = this.authcode;
    data['responseCode'] = this.responseCode;
    data['avsresponse'] = this.avsresponse;
    data['cvvresponse'] = this.cvvresponse;
    data['state'] = this.state;
    if (this.entry != null) {
      data['entry'] = this.entry!.map((v) => v.toJson()).toList();
    }
    data['total_amount'] = this.totalAmount;
    data['type'] = this.type;
    if (this.paymentAttachment != null) {
      data['payment_attachment'] =
          this.paymentAttachment!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    if (this.leaseData != null) {
      data['leaseData'] = this.leaseData!.toJson();
    }
    if (this.unitData != null) {
      data['unitData'] = this.unitData!.toJson();
    }
    if (this.tenantData != null) {
      data['tenantData'] = this.tenantData!.toJson();
    }
    return data;
  }
}

class Entry {
  String? entryId;
  String? account;
  double? amount;
  String? date;
  int? duePaid;
  bool? isPrepaid;
  String? memo;
  String? chargeType;
  String? sId;
  String? status;

  Entry(
      {this.entryId,
      this.account,
      this.amount,
      this.date,
      this.duePaid,
      this.isPrepaid,
      this.memo,
      this.chargeType,
      this.sId,
      this.status});

  Entry.fromJson(Map<String, dynamic> json) {
    entryId = json['entry_id'];
    account = json['account'];
    amount = json['amount'] != null
        ? (json['amount'] is int
            ? (json['amount'] as int).toDouble()
            : json['amount'])
        : null;
    date = json['date'] ?? "";
    // Handle numeric conversion for integer fields
    duePaid = json['due_paid'] != null ? json['due_paid'].toInt() : null;
    isPrepaid = json['is_prepaid'];
    memo = json['memo'];
    chargeType = json['charge_type'];
    sId = json['_id'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['entry_id'] = this.entryId;
    data['account'] = this.account;
    data['amount'] = this.amount;
    data['date'] = this.date;
    data['due_paid'] = this.duePaid;
    data['is_prepaid'] = this.isPrepaid;
    data['memo'] = this.memo;
    data['charge_type'] = this.chargeType;
    data['_id'] = this.sId;
    data['status'] = this.status;
    return data;
  }

  String get formattedAmount => formatAmount(amount);
}

class LeaseDataa {
  String? sId;
  String? leaseId;
  String? adminId;
  String? rentalId;
  String? unitId;
  List<String>? tenantId;
  String? startDate;
  String? endDate;
  String? leaseType;
  int? leaseAmount;
  List<dynamic>? uploadedFile;
  int? rentDueAmount;
  int? rentDaysPastDue;
  String? lateFeeCharged;
  String? lateFeeChargeDate;
  String? externalLeaseId;
  List<Entry_revenu>? entry;
  bool? isRenewing;
  bool? isDelete;
  String? createdAt;
  String? updatedAt;
  List<dynamic>? moveoutTenant;
  int? iV;
  int? balance;
  List<LeaseHistory>? leaseHistory;

  LeaseDataa(
      {this.sId,
      this.leaseId,
      this.adminId,
      this.rentalId,
      this.unitId,
      this.tenantId,
      this.startDate,
      this.endDate,
      this.leaseType,
      this.leaseAmount,
      this.uploadedFile,
      this.rentDueAmount,
      this.rentDaysPastDue,
      this.lateFeeCharged,
      this.lateFeeChargeDate,
      this.externalLeaseId,
      this.entry,
      this.isRenewing,
      this.isDelete,
      this.createdAt,
      this.updatedAt,
      this.moveoutTenant,
      this.iV,
      this.balance,
      this.leaseHistory});

  LeaseDataa.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    leaseId = json['lease_id'];
    adminId = json['admin_id'];
    rentalId = json['rental_id'];
    unitId = json['unit_id'];
    tenantId = json['tenant_id'].cast<String>();
    startDate = json['start_date'];
    endDate = json['end_date'];
    leaseType = json['lease_type'];
    // Handle numeric conversion for integer fields
    leaseAmount =
        json['lease_amount'] != null ? json['lease_amount'].toInt() : null;
    uploadedFile = json['uploaded_file'] ?? [];
    rentDueAmount =
        json['rentDueAmount'] != null ? json['rentDueAmount'].toInt() : null;
    rentDaysPastDue = json['rentDaysPastDue'] != null
        ? json['rentDaysPastDue'].toInt()
        : null;
    lateFeeCharged = json['lateFeeCharged'];
    lateFeeChargeDate = json['lateFeeChargeDate'];
    externalLeaseId = json['externalLeaseId'];
    if (json['entry'] != null) {
      entry = <Entry_revenu>[];
      json['entry'].forEach((v) {
        entry!.add(new Entry_revenu.fromJson(v));
      });
    }
    isRenewing = json['is_renewing'];
    isDelete = json['is_delete'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    moveoutTenant = json['moveout_tenant'] ?? [];
    iV = json['__v'] != null ? json['__v'].toInt() : null;
    balance = json['balance'] != null ? json['balance'].toInt() : null;
    if (json['leaseHistory'] != null) {
      leaseHistory = <LeaseHistory>[];
      json['leaseHistory'].forEach((v) {
        leaseHistory!.add(new LeaseHistory.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['lease_id'] = this.leaseId;
    data['admin_id'] = this.adminId;
    data['rental_id'] = this.rentalId;
    data['unit_id'] = this.unitId;
    data['tenant_id'] = this.tenantId;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['lease_type'] = this.leaseType;
    data['lease_amount'] = this.leaseAmount;
    if (uploadedFile != null) {
      data['uploaded_file'] = uploadedFile;
    }
    data['rentDueAmount'] = this.rentDueAmount;
    data['rentDaysPastDue'] = this.rentDaysPastDue;
    data['lateFeeCharged'] = this.lateFeeCharged;
    data['lateFeeChargeDate'] = this.lateFeeChargeDate;
    data['externalLeaseId'] = this.externalLeaseId;
    if (this.entry != null) {
      data['entry'] = this.entry!.map((v) => v.toJson()).toList();
    }
    data['is_renewing'] = this.isRenewing;
    data['is_delete'] = this.isDelete;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.moveoutTenant != null) {
      data['moveout_tenant'] =
          this.moveoutTenant!.map((v) => v.toJson()).toList();
    }
    data['__v'] = this.iV;
    data['balance'] = this.balance;
    if (this.leaseHistory != null) {
      data['leaseHistory'] = this.leaseHistory!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Entry_revenu {
  String? entryId;
  String? account;
  double? amount;
  String? date;
  String? chargeType;
  String? memo;
  String? rentCycle;
  String? sId;

  Entry_revenu(
      {this.entryId,
      this.account,
      this.amount,
      this.date,
      this.chargeType,
      this.memo,
      this.rentCycle,
      this.sId});

  Entry_revenu.fromJson(Map<String, dynamic> json) {
    entryId = json['entry_id'];
    account = json['account'];
    amount = json['amount'] != null
        ? (json['amount'] is int
            ? (json['amount'] as int).toDouble()
            : json['amount'])
        : null;
    date = json['date'] ?? "";
    chargeType = json['charge_type'];
    memo = json['memo'];
    rentCycle = json['rent_cycle'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['entry_id'] = this.entryId;
    data['account'] = this.account;
    data['amount'] = this.amount;
    data['date'] = this.date;
    data['charge_type'] = this.chargeType;
    data['memo'] = this.memo;
    data['rent_cycle'] = this.rentCycle;
    data['_id'] = this.sId;
    return data;
  }

  String get formattedAmount => formatAmount(amount);
}

class LeaseHistory {
  String? historyId;
  String? startDate;
  String? endDate;
  int? amount;
  String? sId;

  LeaseHistory(
      {this.historyId, this.startDate, this.endDate, this.amount, this.sId});

  LeaseHistory.fromJson(Map<String, dynamic> json) {

    historyId = json['history_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    // Handle numeric conversion for integer fields
    amount = json['amount'] != null ? json['amount'].toInt() : null;
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['history_id'] = this.historyId;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['amount'] = this.amount;
    data['_id'] = this.sId;
    return data;
  }

  String get formattedAmount => amount?.toString() ?? '';
}

class UnitDataa {
  String? sId;
  String? unitId;
  String? rentalUnit;
  String? adminId;
  String? rentalId;
  String? rentalUnitAdress;
  String? rentalSqft;
  List<dynamic>? rentalImages;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? iV;

  UnitDataa(
      {this.sId,
      this.unitId,
      this.rentalUnit,
      this.adminId,
      this.rentalId,
      this.rentalUnitAdress,
      this.rentalSqft,
      this.rentalImages,
      this.createdAt,
      this.updatedAt,
      this.isDelete,
      this.iV});

  UnitDataa.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    unitId = json['unit_id'];
    rentalUnit = json['rental_unit'];
    adminId = json['admin_id'];
    rentalId = json['rental_id'];
    rentalUnitAdress = json['rental_unit_adress'];
    rentalSqft = json['rental_sqft'];
    rentalImages = json['rental_images'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['unit_id'] = this.unitId;
    data['rental_unit'] = this.rentalUnit;
    data['admin_id'] = this.adminId;
    data['rental_id'] = this.rentalId;
    data['rental_unit_adress'] = this.rentalUnitAdress;
    data['rental_sqft'] = this.rentalSqft;
    if (this.rentalImages != null) {
      data['rental_images'] =
          this.rentalImages!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    data['__v'] = this.iV;
    return data;
  }
}

class TenantDataa {
  String? sId;
  String? tenantId;
  String? adminId;
  String? tenantFirstName;
  String? tenantLastName;
  String? tenantPhoneNumber;
  String? tenantAlternativeNumber;
  String? tenantEmail;
  String? tenantAlternativeEmail;
  String? tenantPassword;
  String? tenantBirthDate;
  String? taxPayerId;
  String? comments;
  EmergencyContact? emergencyContact;
  bool? enableOverrideFee;
  int? overrideFee;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? iV;

  TenantDataa(
      {this.sId,
      this.tenantId,
      this.adminId,
      this.tenantFirstName,
      this.tenantLastName,
      this.tenantPhoneNumber,
      this.tenantAlternativeNumber,
      this.tenantEmail,
      this.tenantAlternativeEmail,
      this.tenantPassword,
      this.tenantBirthDate,
      this.taxPayerId,
      this.comments,
      this.emergencyContact,
      this.enableOverrideFee,
      this.overrideFee,
      this.createdAt,
      this.updatedAt,
      this.isDelete,
      this.iV});

  TenantDataa.fromJson(Map<String, dynamic> json) {

    sId = json['_id'];
    tenantId = json['tenant_id'];
    adminId = json['admin_id'];
    tenantFirstName = json['tenant_firstName'];
    tenantLastName = json['tenant_lastName'];
    tenantPhoneNumber = json['tenant_phoneNumber'];
    tenantAlternativeNumber = json['tenant_alternativeNumber'];
    tenantEmail = json['tenant_email'];
    tenantAlternativeEmail = json['tenant_alternativeEmail'];
    tenantPassword = json['tenant_password'];
    tenantBirthDate = json['tenant_birthDate'];
    taxPayerId = json['taxPayer_id'];
    comments = json['comments'];
    emergencyContact = json['emergency_contact'] != null
        ? new EmergencyContact.fromJson(json['emergency_contact'])
        : null;
    enableOverrideFee = json['enable_override_fee'];
    overrideFee = json['override_fee'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['tenant_id'] = this.tenantId;
    data['admin_id'] = this.adminId;
    data['tenant_firstName'] = this.tenantFirstName;
    data['tenant_lastName'] = this.tenantLastName;
    data['tenant_phoneNumber'] = this.tenantPhoneNumber;
    data['tenant_alternativeNumber'] = this.tenantAlternativeNumber;
    data['tenant_email'] = this.tenantEmail;
    data['tenant_alternativeEmail'] = this.tenantAlternativeEmail;
    data['tenant_password'] = this.tenantPassword;
    data['tenant_birthDate'] = this.tenantBirthDate;
    data['taxPayer_id'] = this.taxPayerId;
    data['comments'] = this.comments;
    if (this.emergencyContact != null) {
      data['emergency_contact'] = this.emergencyContact!.toJson();
    }
    data['enable_override_fee'] = this.enableOverrideFee;
    data['override_fee'] = this.overrideFee;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    data['__v'] = this.iV;
    return data;
  }
}

class EmergencyContact {
  String? name;
  String? relation;
  String? email;
  String? phoneNumber;

  EmergencyContact({this.name, this.relation, this.email, this.phoneNumber});

  EmergencyContact.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    relation = json['relation'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['relation'] = this.relation;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    return data;
  }
}
