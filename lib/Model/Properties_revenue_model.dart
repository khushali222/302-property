class Properties_revenue_model {
  final String? sId;
  final String? paymentId;
  final String? adminId;
  final String? leaseId;
  final String? tenantId;
  final int? customerVaultId;
  final int? billingId;
  final double? surcharge;
  final String? paymentType;
  final String? transactionId;
  final String? response;
  final String? authcode;
  final String? responseCode;
  final String? avsresponse;
  final String? cvvresponse;
  final String? state;
  final List<Entry>? entry;
  final double? totalAmount;
  final String? type;
  final String? createdAt;
  final String? updatedAt;
  final bool? isDelete;
  final int? iV;

  Properties_revenue_model({
    this.sId,
    this.paymentId,
    this.adminId,
    this.leaseId,
    this.tenantId,
    this.customerVaultId,
    this.billingId,
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
    this.totalAmount,
    this.type,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.iV,
  });

  factory Properties_revenue_model.fromJson(Map<String, dynamic> json) {
    return Properties_revenue_model(
      sId: json['_id'],
      paymentId: json['payment_id'],
      adminId: json['admin_id'],
      leaseId: json['lease_id'],
      tenantId: json['tenant_id'],
      customerVaultId: json['customer_vault_id'],
      billingId: json['billing_id'],
      surcharge: (json['surcharge'] as num?)?.toDouble(),
      paymentType: json['payment_type'],
      transactionId: json['transaction_id'],
      response: json['response'],
      authcode: json['authcode'],
      responseCode: json['responseCode'],
      avsresponse: json['avsresponse'],
      cvvresponse: json['cvvresponse'],
      state: json['state'],
      entry: (json['entry'] as List<dynamic>?)
          ?.map((e) => Entry.fromJson(e))
          .toList(),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      type: json['type'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isDelete: json['is_delete'],
      iV: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'payment_id': paymentId,
      'admin_id': adminId,
      'lease_id': leaseId,
      'tenant_id': tenantId,
      'customer_vault_id': customerVaultId,
      'billing_id': billingId,
      'surcharge': surcharge,
      'payment_type': paymentType,
      'transaction_id': transactionId,
      'response': response,
      'authcode': authcode,
      'responseCode': responseCode,
      'avsresponse': avsresponse,
      'cvvresponse': cvvresponse,
      'state': state,
      'entry': entry?.map((e) => e.toJson()).toList(),
      'total_amount': totalAmount,
      'type': type,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'is_delete': isDelete,
      '__v': iV,
    };
  }
}
class Entry {
  final String? entryId;
  final String? account;
  final double? amount;
  final String? date;
  final int? duePaid;
  final bool? isPrepaid;
  final String? memo;
  final String? chargeType;
  final String? sId;
  final String? status;

  Entry({
    this.entryId,
    this.account,
    this.amount,
    this.date,
    this.duePaid,
    this.isPrepaid,
    this.memo,
    this.chargeType,
    this.sId,
    this.status,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      entryId: json['entry_id'],
      account: json['account'],
      amount: (json['amount'] as num?)?.toDouble(),
      date: json['date'],
      duePaid: json['due_paid'],
      isPrepaid: json['is_prepaid'],
      memo: json['memo'],
      chargeType: json['charge_type'],
      sId: json['_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entry_id': entryId,
      'account': account,
      'amount': amount,
      'date': date,
      'due_paid': duePaid,
      'is_prepaid': isPrepaid,
      'memo': memo,
      'charge_type': chargeType,
      '_id': sId,
      'status': status,
    };
  }
}
