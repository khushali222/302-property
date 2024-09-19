class RentalOwnerReport {
  String rentalOwnerId;
  String rentalOwnerName;
  double subTotal;
  List<Payment> payments;

  RentalOwnerReport({
    required this.rentalOwnerId,
    required this.rentalOwnerName,
    required this.subTotal,
    required this.payments,
  });

  factory RentalOwnerReport.fromJson(Map<String, dynamic> json) {
    return RentalOwnerReport(
      rentalOwnerId: json['rentalowner_id'] ?? '',
      rentalOwnerName: json['rentalOwner_name'] ?? '',
      // Check the type of amount and convert to double if it's an int
      subTotal: json['sub_total'] is int
          ? (json['sub_total'] as int).toDouble()
          : (json['sub_total'] ?? 0.0) as double,

      payments: (json['payments'] as List<dynamic>?)
          ?.map((paymentJson) => Payment.fromJson(paymentJson))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rentalowner_id': rentalOwnerId,
      'rentalOwner_name': rentalOwnerName,
      'sub_total': subTotal,
      'payments': payments.map((payment) => payment.toJson()).toList(),
    };
  }
}

class Payment {
  String paymentId;
  String adminId;
  String leaseId;
  String tenantId;
  double surcharge;
  String customerVaultId;
  String billingId;
  String transactionId;
  String response;
  List<Entry> entry;
  double totalAmount;
  String paymentType;
  String type;
  List<dynamic> paymentAttachment;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDelete;
  TenantData tenantData;
  RentalData rentalData;
  RentalOwnerData rentalOwnerData;
  Map<String, dynamic> checkAccount;
  String ccType;
  String ccNumber;
  String transactionType;

  Payment({
    required this.paymentId,
    required this.adminId,
    required this.leaseId,
    required this.tenantId,
    required this.surcharge,
    required this.customerVaultId,
    required this.billingId,
    required this.transactionId,
    required this.response,
    required this.entry,
    required this.totalAmount,
    required this.paymentType,
    required this.type,
    required this.paymentAttachment,
    required this.createdAt,
    required this.updatedAt,
    required this.isDelete,
    required this.tenantData,
    required this.rentalData,
    required this.rentalOwnerData,
    required this.checkAccount,
    required this.ccType,
    required this.ccNumber,
    required this.transactionType,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['payment_id'] ?? '',
      adminId: json['admin_id'] ?? '',
      leaseId: json['lease_id'] ?? '',
      tenantId: json['tenant_id'] ?? '',
      surcharge: (json['surcharge'] as num?)?.toDouble() ?? 0.0,
      customerVaultId: json['customer_vault_id']?.toString() ?? '',
      billingId: json['billing_id']?.toString() ?? '',
      transactionId: json['transaction_id'] ?? 'N/A',
      response: json['response'] ?? '',
      entry: (json['entry'] as List<dynamic>?)
          ?.map((entryJson) => Entry.fromJson(entryJson))
          .toList() ??
          [],
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      paymentType: json['payment_type'] ?? '',
      type: json['type'] ?? '',
      paymentAttachment: List<dynamic>.from(json['payment_attachment'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      isDelete: json['is_delete'] ?? false,
      tenantData: TenantData.fromJson(json['tenant_data'] ?? {}),
      rentalData: RentalData.fromJson(json['rental_data'] ?? {}),
      rentalOwnerData: RentalOwnerData.fromJson(json['rental_owner_data'] ?? {}),
      checkAccount: json['check_account'] ?? {},
      ccType: json['cc_type'] ?? 'N/A',
      ccNumber: json['cc_number'] ?? 'N/A',
      transactionType: json['transaction_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_id': paymentId,
      'admin_id': adminId,
      'lease_id': leaseId,
      'tenant_id': tenantId,
      'surcharge': surcharge,
      'customer_vault_id': customerVaultId,
      'billing_id': billingId,
      'transaction_id': transactionId,
      'response': response,
      'entry': entry.map((entry) => entry.toJson()).toList(),
      'total_amount': totalAmount,
      'payment_type': paymentType,
      'type': type,
      'payment_attachment': paymentAttachment,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'is_delete': isDelete,
      'tenant_data': tenantData.toJson(),
      'rental_data': rentalData.toJson(),
      'rental_owner_data': rentalOwnerData.toJson(),
      'check_account': checkAccount,
      'cc_type': ccType,
      'cc_number': ccNumber,
      'transaction_type': transactionType,
    };
  }
}

class Entry {
  String account;
  double amount;
  String chargeType;

  Entry({
    required this.account,
    required this.amount,
    required this.chargeType,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      account: json['account'] ?? '',
      // Check the type of amount and convert to double if it's an int
      amount: json['amount'] is int
          ? (json['amount'] as int).toDouble()
          : (json['amount'] ?? 0.0) as double,
      chargeType: json['charge_type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'amount': amount,
      'charge_type': chargeType,
    };
  }
}

class TenantData {
  String tenantFirstName;
  String tenantLastName;

  TenantData({
    required this.tenantFirstName,
    required this.tenantLastName,
  });

  factory TenantData.fromJson(Map<String, dynamic> json) {
    return TenantData(
      tenantFirstName: json['tenant_firstName'] ?? '',
      tenantLastName: json['tenant_lastName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_firstName': tenantFirstName,
      'tenant_lastName': tenantLastName,
    };
  }
}

class RentalData {
  String rentalOwnerId;
  String rentalAddress;

  RentalData({
    required this.rentalOwnerId,
    required this.rentalAddress,
  });

  factory RentalData.fromJson(Map<String, dynamic> json) {
    return RentalData(
      rentalOwnerId: json['rentalowner_id'] ?? '',
      rentalAddress: json['rental_adress'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rentalowner_id': rentalOwnerId,
      'rental_adress': rentalAddress,
    };
  }
}

class RentalOwnerData {
  String rentalOwnerId;
  String rentalOwnerName;

  RentalOwnerData({
    required this.rentalOwnerId,
    required this.rentalOwnerName,
  });

  factory RentalOwnerData.fromJson(Map<String, dynamic> json) {
    return RentalOwnerData(
      rentalOwnerId: json['rentalowner_id'] ?? '',
      rentalOwnerName: json['rentalOwner_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rentalowner_id': rentalOwnerId,
      'rentalOwner_name': rentalOwnerName,
    };
  }
}
