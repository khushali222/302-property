import 'package:three_zero_two_property/services/app_log.dart';
// Safe money parsing only — `show` keeps the rest of constant.dart out of
// this model's namespace.
import 'package:three_zero_two_property/constant/constant.dart' show asDouble;

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
      // asDouble (constant.dart): int/double/numeric-string all parse safely;
      // a malformed value becomes 0.0 instead of throwing and blanking the
      // whole report (the repo's catch returns [] on any row error).
      subTotal: asDouble(json['sub_total']),
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
  String? paymentId;
  String? adminId;
  String? leaseId;
  String? tenantId;
  double surcharge;
  String? customerVaultId;
  String? billingId;
  String? transactionId;
  String? response;
  List<Entry> entry;
  double totalAmount;
  String? paymentType;
  String? type;
  List<dynamic>? paymentAttachment;
  DateTime createdAt;
  DateTime updatedAt;
  bool isDelete;
  TenantData? tenantData;
  RentalData? rentalData;
  RentalOwnerData? rentalOwnerData;
  Map<String, dynamic>? checkAccount;
  String? ccType;
  String? ccNumber;
  String? transactionType;
  String? responseText;

  Payment({
     this.paymentId,
     this.adminId,
     this.leaseId,
     this.tenantId,
     required this.surcharge,
     this.customerVaultId,
     this.billingId,
     this.transactionId,
     this.response,
    required this.entry,
    required this.totalAmount,
     this.paymentType,
     this.type,
     this.paymentAttachment,
    required this.createdAt,
    required this.updatedAt,
    required this.isDelete,
     this.tenantData,
     this.rentalData,
     this.rentalOwnerData,
     this.checkAccount,
     this.ccType,
     this.ccNumber,
     this.transactionType,
    this.responseText
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    // Log the full JSON to see the structure

    try {
      // Print each field as we parse it to identify where the issue happens
      String ccType = (json['cc_type'] is Map<String, dynamic>) ? 'N/A' : (json['cc_type'] ?? 'N/A');
    //  print('ccType: $ccType');

      String ccNumber = (json['cc_number'] is Map<String, dynamic>) ? 'N/A' : (json['cc_number'] ?? 'N/A');
     // print('ccNumber: $ccNumber');

      String transactionType = (json['transaction_type'] is Map<String, dynamic>) ? '' : (json['transaction_type'] ?? '');
   //   print('transactionType: $transactionType');

      return Payment(
        paymentId: json['payment_id'] ?? '',
        adminId: json['admin_id'] ?? '',
        leaseId: json['lease_id'] ?? '',
        tenantId: json['tenant_id'] ?? '',
        surcharge: asDouble(json['surcharge']),
        customerVaultId: json['customer_vault_id']?.toString() ?? '',
        billingId: json['billing_id']?.toString() ?? '',
        transactionId: json['transaction_id'] ?? 'N/A',
        response: json['response'] ?? '',
        entry: (json['entry'] as List<dynamic>?)
            ?.map((entryJson) => Entry.fromJson(entryJson))
            .toList() ??
            [],
         totalAmount: asDouble(json['total_amount']),
        paymentType: json['payment_type'] ?? '',
        type: json['type'] ?? '',
        paymentAttachment: List<dynamic>.from(json['payment_attachment'] ?? []),
         createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
         updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
         isDelete: json['is_delete'] ?? false,
        tenantData: TenantData.fromJson(json['tenant_data'] ?? {}),
        rentalData: RentalData.fromJson(json['rental_data'] ?? {}),
        rentalOwnerData: RentalOwnerData.fromJson(json['rental_owner_data'] ?? {}),
        checkAccount: (json['check_account'] != null && json['check_account'] is Map<String, dynamic>)
            ? json['check_account']
            : {},
        ccType: ccType,
        ccNumber: ccNumber,
        responseText: json['responseText'],
        transactionType: transactionType,
      );
    } catch (e) {
      // Catch errors and log the issue
      logError('Error parsing Payment JSON: $e');
      rethrow;
    }
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
      'tenant_data': tenantData!.toJson(),
      'rental_data': rentalData!.toJson(),
      'rental_owner_data': rentalOwnerData!.toJson(),
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
      amount: asDouble(json['amount']),
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
