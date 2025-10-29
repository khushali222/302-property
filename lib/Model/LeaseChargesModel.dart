class LeaseCharges {
  int? statusCode;
  LeaseChargesData? data;
  String? message;

  LeaseCharges({this.statusCode, this.data, this.message});

  LeaseCharges.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    data =
        json['data'] != null ? LeaseChargesData.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class LeaseChargesData {
  String? leaseId;
  String? tenantNames;
  SecurityDeposits? securityDeposits;
  LateRentPayments? lateRentPayments;

  LeaseChargesData({
    this.leaseId,
    this.tenantNames,
    this.securityDeposits,
    this.lateRentPayments,
  });

  LeaseChargesData.fromJson(Map<String, dynamic> json) {
    leaseId = json['lease_id'];
    tenantNames = json['tenant_names'];
    securityDeposits = json['security_deposits'] != null
        ? SecurityDeposits.fromJson(json['security_deposits'])
        : null;
    lateRentPayments = json['late_rent_payments'] != null
        ? LateRentPayments.fromJson(json['late_rent_payments'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['lease_id'] = leaseId;
    data['tenant_names'] = tenantNames;
    if (securityDeposits != null) {
      data['security_deposits'] = securityDeposits!.toJson();
    }
    if (lateRentPayments != null) {
      data['late_rent_payments'] = lateRentPayments!.toJson();
    }
    return data;
  }
}

class SecurityDeposits {
  double? totalAmount;
  List<SecurityDepositEntry>? entries;
  int? totalEntries;

  SecurityDeposits({this.totalAmount, this.entries, this.totalEntries});

  SecurityDeposits.fromJson(Map<String, dynamic> json) {
    totalAmount = (json['total_amount'] as num?)?.toDouble();
    if (json['entries'] != null) {
      entries = [];
      json['entries'].forEach((v) {
        entries!.add(SecurityDepositEntry.fromJson(v));
      });
    }
    totalEntries = json['total_entries'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['total_amount'] = totalAmount;
    if (entries != null) {
      data['entries'] = entries!.map((v) => v.toJson()).toList();
    }
    data['total_entries'] = totalEntries;
    return data;
  }
}

class SecurityDepositEntry {
  String? entryId;
  String? account;
  double? amount;
  String? date;
  double? dueAmount;
  bool? isPaid;
  String? memo;
  String? chargeType;
  bool? isRepeatable;
  List<dynamic>? payments;
  String? chargeId;
  String? chargeCreatedAt;
  String? chargeUpdatedAt;

  SecurityDepositEntry({
    this.entryId,
    this.account,
    this.amount,
    this.date,
    this.dueAmount,
    this.isPaid,
    this.memo,
    this.chargeType,
    this.isRepeatable,
    this.payments,
    this.chargeId,
    this.chargeCreatedAt,
    this.chargeUpdatedAt,
  });

  SecurityDepositEntry.fromJson(Map<String, dynamic> json) {
    entryId = json['entry_id'];
    account = json['account'];
    amount = (json['amount'] as num?)?.toDouble();
    date = json['date'];
    dueAmount = (json['due_amount'] as num?)?.toDouble();
    isPaid = json['is_paid'];
    memo = json['memo'];
    chargeType = json['charge_type'];
    isRepeatable = json['is_repeatable'];
    payments = json['payments'];
    chargeId = json['charge_id'];
    chargeCreatedAt = json['charge_created_at'];
    chargeUpdatedAt = json['charge_updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['entry_id'] = entryId;
    data['account'] = account;
    data['amount'] = amount;
    data['date'] = date;
    data['due_amount'] = dueAmount;
    data['is_paid'] = isPaid;
    data['memo'] = memo;
    data['charge_type'] = chargeType;
    data['is_repeatable'] = isRepeatable;
    data['payments'] = payments;
    data['charge_id'] = chargeId;
    data['charge_created_at'] = chargeCreatedAt;
    data['charge_updated_at'] = chargeUpdatedAt;
    return data;
  }
}

class LateRentPayments {
  DateRange? dateRange;
  double? totalAmount;
  List<LateRentEntry>? entries;
  int? totalEntries;

  LateRentPayments({
    this.dateRange,
    this.totalAmount,
    this.entries,
    this.totalEntries,
  });

  LateRentPayments.fromJson(Map<String, dynamic> json) {
    dateRange = json['date_range'] != null
        ? DateRange.fromJson(json['date_range'])
        : null;
    totalAmount = (json['total_amount'] as num?)?.toDouble();
    if (json['entries'] != null) {
      entries = [];
      json['entries'].forEach((v) {
        entries!.add(LateRentEntry.fromJson(v));
      });
    }
    totalEntries = json['total_entries'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (dateRange != null) {
      data['date_range'] = dateRange!.toJson();
    }
    data['total_amount'] = totalAmount;
    if (entries != null) {
      data['entries'] = entries!.map((v) => v.toJson()).toList();
    }
    data['total_entries'] = totalEntries;
    return data;
  }
}

class DateRange {
  String? from;
  String? to;

  DateRange({this.from, this.to});

  DateRange.fromJson(Map<String, dynamic> json) {
    from = json['from'];
    to = json['to'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['from'] = from;
    data['to'] = to;
    return data;
  }
}

class LateRentEntry {
  String? entryId;
  String? account;
  double? amount;
  String? date;
  double? dueAmount;
  bool? isPaid;
  String? memo;
  String? chargeType;
  bool? isLateFee;
  bool? isRepeatable;
  List<dynamic>? payments;
  String? chargeId;
  String? chargeCreatedAt;
  String? chargeUpdatedAt;

  LateRentEntry({
    this.entryId,
    this.account,
    this.amount,
    this.date,
    this.dueAmount,
    this.isPaid,
    this.memo,
    this.chargeType,
    this.isLateFee,
    this.isRepeatable,
    this.payments,
    this.chargeId,
    this.chargeCreatedAt,
    this.chargeUpdatedAt,
  });

  LateRentEntry.fromJson(Map<String, dynamic> json) {
    entryId = json['entry_id'];
    account = json['account'];
    amount = (json['amount'] as num?)?.toDouble();
    date = json['date'];
    dueAmount = (json['due_amount'] as num?)?.toDouble();
    isPaid = json['is_paid'];
    memo = json['memo'];
    chargeType = json['charge_type'];
    isLateFee = json['is_lateFee'];
    isRepeatable = json['is_repeatable'];
    payments = json['payments'];
    chargeId = json['charge_id'];
    chargeCreatedAt = json['charge_created_at'];
    chargeUpdatedAt = json['charge_updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['entry_id'] = entryId;
    data['account'] = account;
    data['amount'] = amount;
    data['date'] = date;
    data['due_amount'] = dueAmount;
    data['is_paid'] = isPaid;
    data['memo'] = memo;
    data['charge_type'] = chargeType;
    data['is_lateFee'] = isLateFee;
    data['is_repeatable'] = isRepeatable;
    data['payments'] = payments;
    data['charge_id'] = chargeId;
    data['charge_created_at'] = chargeCreatedAt;
    data['charge_updated_at'] = chargeUpdatedAt;
    return data;
  }
}
