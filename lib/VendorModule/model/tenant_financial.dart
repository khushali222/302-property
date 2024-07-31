
class TenantFinancial {
  int? statusCode;
  List<Data>? data;
  double? totalBalance;
  String? message;

  TenantFinancial({
    this.statusCode,
    this.data,
    this.totalBalance,
    this.message,
  });

  factory TenantFinancial.fromJson(Map<String, dynamic> json) {
    return TenantFinancial(
      statusCode: json['statusCode'],
      data: json['data'] != null
          ? List<Data>.from(json['data'].map((x) => Data.fromJson(x)))
          : null,
      totalBalance: json['totalBalance']?.toDouble(), // Convert totalBalance to double
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'statusCode': this.statusCode,
      'totalBalance': this.totalBalance,
      'message': this.message,
    };
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? id;
  String? leaseId;
  String? tenantId;
  int? customerVaultId;
  int? billingId;
  String? transactionId;
  String? response;
  List<Entry>? entry;
  double? totalAmount;
  String? paymentType;
  String? type;
  List<dynamic>? paymentAttachment;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;

  double? balance;
  String? paymentId;
  String? adminId;
  double? surcharge;

  Data({
    this.id,
    this.leaseId,
    this.tenantId,
    this.customerVaultId,
    this.billingId,
    this.transactionId,
    this.response,
    this.entry,
    this.totalAmount,
    this.paymentType,
    this.type,
    this.paymentAttachment,
    this.createdAt,
    this.updatedAt,
    this.isDelete,

    this.balance,
    this.paymentId,
    this.adminId,
    this.surcharge,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json['_id'],
      leaseId: json['lease_id'],
      tenantId: json['tenant_id'],
      customerVaultId: json['customer_vault_id'],
      billingId: json['billing_id'],
      transactionId: json['transaction_id'],
      response: json['response'],
      entry: json['entry'] != null
          ? List<Entry>.from(json['entry'].map((x) => Entry.fromJson(x)))
          : null,
      totalAmount: json['total_amount']?.toDouble(), // Convert total_amount to double
      paymentType: json['payment_type'],
      type: json['type'],
      paymentAttachment: json['payment_attachment'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isDelete: json['is_delete'],

      balance: json['balance']?.toDouble(), // Convert balance to double
      paymentId: json['payment_id'],
      adminId: json['admin_id'],
      surcharge: json['surcharge']?.toDouble(), // Convert surcharge to double
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      '_id': this.id,
      'lease_id': this.leaseId,
      'tenant_id': this.tenantId,
      'customer_vault_id': this.customerVaultId,
      'billing_id': this.billingId,
      'transaction_id': this.transactionId,
      'response': this.response,
      'total_amount': this.totalAmount,
      'payment_type': this.paymentType,
      'type': this.type,
      'payment_attachment': this.paymentAttachment,
      'createdAt': this.createdAt,
      'updatedAt': this.updatedAt,
      'is_delete': this.isDelete,

      'balance': this.balance,
      'payment_id': this.paymentId,
      'admin_id': this.adminId,
      'surcharge': this.surcharge,
    };
    if (this.entry != null) {
      data['entry'] = this.entry!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Entry {
  String? account;
  dynamic? amount;
  String? date;
  String? id;
  String? entryId;
  String? memo;
  String? chargeType;

  Entry({
    this.account,
    this.amount,
    this.date,
    this.id,
    this.entryId,
    this.memo,
    this.chargeType,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      account: json['account'],
      amount: json['amount'],
      date: json['date'],
      id: json['_id'],
      entryId: json['entry_id'],
      memo: json['memo'],
      chargeType: json['charge_type'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'account': this.account,
      'amount': this.amount,
      'date': this.date,
      '_id': this.id,
      'entry_id': this.entryId,
      'memo': this.memo,
      'charge_type': this.chargeType,
    };
    return data;
  }
}
