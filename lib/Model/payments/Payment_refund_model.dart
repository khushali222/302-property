class PaymentRefund {
  final String? id;
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
  final String? authCode;
  final String? responseCode;
  final String? avsResponse;
  final String? cvvResponse;
  final String? state;
  final List<Entry>? entry;
  final double? totalAmount;
  final String? type;
  final List<dynamic>? paymentAttachment;
  final String? createdAt;
  final String? updatedAt;
  final bool? isDelete;
  final TenantData? tenantData;
  final LeaseData? leaseData;

  PaymentRefund({
    this.id,
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
    this.authCode,
    this.responseCode,
    this.avsResponse,
    this.cvvResponse,
    this.state,
    this.entry,
    this.totalAmount,
    this.type,
    this.paymentAttachment,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.tenantData,
    this.leaseData,
  });

  static PaymentRefund fromJson(Map<String, dynamic> json) {
    return PaymentRefund(
      id: json["0"]['_id'] as String?,
      paymentId: json["0"]['payment_id'] as String?,
      adminId: json["0"]['admin_id'] as String?,
      leaseId: json["0"]['lease_id'] as String?,
      tenantId: json["0"]['tenant_id'] as String?,
      customerVaultId: json["0"]['customer_vault_id'] as int?,
      billingId: json["0"]['billing_id'] as int?,
      surcharge: (json["0"]['surcharge'] as num?)?.toDouble(),
      paymentType: json["0"]['payment_type'] as String?,
      transactionId: json["0"]['transaction_id'] as String?,
      response: json["0"]['response'] as String?,
      authCode: json["0"]['authcode'] as String?,
      responseCode: json["0"]['responseCode'] as String?,
      avsResponse: json["0"]['avsresponse'] as String?,
      cvvResponse: json["0"]['cvvresponse'] as String?,
      state: json["0"]['state'] as String?,
      entry: (json["0"]['entry'] as List?)?.map((e) => Entry.fromJson(e as Map<String, dynamic>)).toList(),
      totalAmount: (json["0"]['total_amount'] as num?)?.toDouble(),
      type: json["0"]['type'] as String?,
      paymentAttachment: json["0"]['payment_attachment'] as List<dynamic>?,
      createdAt: json["0"]['createdAt'] as String?,
      updatedAt: json["0"]['updatedAt'] as String?,
      isDelete: json["0"]['is_delete'] as bool?,
      tenantData: json['tenant_data'] != null ? TenantData.fromJson(json['tenant_data']) : null,
      leaseData: json['lease_data'] != null ? LeaseData.fromJson(json['lease_data']) : null,
    );
  }
}
class TenantData {
  final String? id;
  final String? tenantId;
  final String? adminId;
  final String? tenantFirstName;
  final String? tenantLastName;
  final String? tenantPhoneNumber;
  final String? tenantEmail;
  final String? tenantPassword;
  final bool? enableOverrideFee;
  final String? createdAt;
  final String? updatedAt;
  final bool? isDelete;
  final String? tenantBirthDate;

  TenantData({
    this.id,
    this.tenantId,
    this.adminId,
    this.tenantFirstName,
    this.tenantLastName,
    this.tenantPhoneNumber,
    this.tenantEmail,
    this.tenantPassword,
    this.enableOverrideFee,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.tenantBirthDate,
  });

  static TenantData fromJson(Map<String, dynamic> json) {
    return TenantData(
      id: json['_id'] as String?,
      tenantId: json['tenant_id'] as String?,
      adminId: json['admin_id'] as String?,
      tenantFirstName: json['tenant_firstName'] as String?,
      tenantLastName: json['tenant_lastName'] as String?,
      tenantPhoneNumber: json['tenant_phoneNumber'] as String?,
      tenantEmail: json['tenant_email'] as String?,
      tenantPassword: json['tenant_password'] as String?,
      enableOverrideFee: json['enable_override_fee'] as bool?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      isDelete: json['is_delete'] as bool?,
      tenantBirthDate: json['tenant_birthDate'] as String?,
    );
  }
}
class LeaseData {
  final String? leaseId;
  final String? startDate;
  final String? endDate;
  final String? status;
  final String? rentalAddress;

  LeaseData({
    this.leaseId,
    this.startDate,
    this.endDate,
    this.status,
    this.rentalAddress,
  });

  static LeaseData fromJson(Map<String, dynamic> json) {
    return LeaseData(
      leaseId: json['lease_id'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      status: json['status'] as String?,
      rentalAddress: json['rental_adress'] as String?,
    );
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
  final String? id;

  Entry({
    this.entryId,
    this.account,
    this.amount,
    this.date,
    this.duePaid,
    this.isPrepaid,
    this.memo,
    this.chargeType,
    this.id,
  });

  static Entry fromJson(Map<String, dynamic> json) {
    return Entry(
      entryId: json['entry_id'] as String?,
      account: json['account'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      date: json['date'] as String?,
      duePaid: json['due_paid'] as int?,
      isPrepaid: json['is_prepaid'] as bool?,
      memo: json['memo'] as String?,
      chargeType: json['charge_type'] as String?,
      id: json['_id'] as String?,
    );
  }
}

