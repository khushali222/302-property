class LeaseLedger {
  List<Data>? data;
  int? totalBalance;
  String? message;

  LeaseLedger({this.data, this.totalBalance, this.message});

  LeaseLedger.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = [];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    totalBalance = json['totalBalance'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['totalBalance'] = totalBalance;
    data['message'] = message;
    return data;
  }
}

class Data {
  String? sId;
  String? chargeId;
  String? adminId;
  String? leaseId;
  List<Entry>? entry;
  int? totalAmount;
  bool? isLeaseAdded;
  String? type;
  List<dynamic>? uploadedFile;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? iV;
  dynamic tenantData; // tenantData is dynamic to handle any JSON structure
  int? balance;

  Data({
    this.sId,
    this.chargeId,
    this.adminId,
    this.leaseId,
    this.entry,
    this.totalAmount,
    this.isLeaseAdded,
    this.type,
    this.uploadedFile,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.iV,
    this.tenantData,
    this.balance,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    chargeId = json['charge_id'];
    adminId = json['admin_id'];
    leaseId = json['lease_id'];
    if (json['entry'] != null) {
      entry = [];
      json['entry'].forEach((v) {
        entry!.add(Entry.fromJson(v));
      });
    }
    totalAmount = json['total_amount'];
    isLeaseAdded = json['is_leaseAdded'];
    type = json['type'];
    uploadedFile = json['uploaded_file'] ?? [];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    iV = json['__v'];
    tenantData = json['tenantData'];
    balance = json['balance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['charge_id'] = chargeId;
    data['admin_id'] = adminId;
    data['lease_id'] = leaseId;
    if (entry != null) {
      data['entry'] = entry!.map((v) => v.toJson()).toList();
    }
    data['total_amount'] = totalAmount;
    data['is_leaseAdded'] = isLeaseAdded;
    data['type'] = type;
    if (uploadedFile != null) {
      data['uploaded_file'] = uploadedFile;
    }
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['is_delete'] = isDelete;
    data['__v'] = iV;
    data['tenantData'] = tenantData;
    data['balance'] = balance;
    return data;
  }
}

class Entry {
  String? entryId;
  String? memo;
  String? account;
  int? amount;
  String? date;
  String? rentCycle;
  bool? isPaid;
  bool? isLateFee;
  bool? isRepeatable;
  String? chargeType;
  String? sId;

  Entry({
    this.entryId,
    this.memo,
    this.account,
    this.amount,
    this.date,
    this.rentCycle,
    this.isPaid,
    this.isLateFee,
    this.isRepeatable,
    this.chargeType,
    this.sId,
  });

  Entry.fromJson(Map<String, dynamic> json) {
    entryId = json['entry_id'];
    memo = json['memo'];
    account = json['account'];
    amount = json['amount'];
    date = json['date'];
    rentCycle = json['rent_cycle'];
    isPaid = json['is_paid'];
    isLateFee = json['is_lateFee'];
    isRepeatable = json['is_repeatable'];
    chargeType = json['charge_type'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['entry_id'] = entryId;
    data['memo'] = memo;
    data['account'] = account;
    data['amount'] = amount;
    data['date'] = date;
    data['rent_cycle'] = rentCycle;
    data['is_paid'] = isPaid;
    data['is_lateFee'] = isLateFee;
    data['is_repeatable'] = isRepeatable;
    data['charge_type'] = chargeType;
    data['_id'] = sId;
    return data;
  }
}
