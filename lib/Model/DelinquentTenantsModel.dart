class DelinquentTenantsModel {
  List<DelinquentTenantsData>? data;
  PdfDelinquentTenantsData? grandtotal;
  int? statusCode;
  String? message;

  DelinquentTenantsModel({
    this.data,
    this.grandtotal,
    this.statusCode,
    this.message,
  });

  DelinquentTenantsModel.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      print('Key: $key, Value: $value');
    });
    if (json['data'] != null) {
      data = <DelinquentTenantsData>[];
      json['data'].forEach((v) {
        data!.add(DelinquentTenantsData.fromJson(v));
      });
    }
    grandtotal = json['grandtotal'] != null
        ? PdfDelinquentTenantsData.fromJson(json['grandtotal'])
        : null;
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.grandtotal != null) {
      data['grandtotal'] = this.grandtotal!.toJson();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class DelinquentTenantsData {
  String? leaseId;
  String? rentalAddress;
  List<Tenants>? tenants;
  PdfDelinquentTenantsData? alltotalamount;

  DelinquentTenantsData({
    this.leaseId,
    this.rentalAddress,
    this.tenants,
    this.alltotalamount,
  });

  DelinquentTenantsData.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      print('Key: $key, Value: $value');
    });
    leaseId = json['lease_id'];
    rentalAddress = json['rental_address'];
    if (json['tenants'] != null) {
      tenants = <Tenants>[];
      json['tenants'].forEach((v) {
        tenants!.add(Tenants.fromJson(v));
      });
    }
    alltotalamount = json['alltotalamount'] != null
        ? PdfDelinquentTenantsData.fromJson(json['alltotalamount'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lease_id'] = this.leaseId;
    data['rental_address'] = this.rentalAddress;
    if (this.tenants != null) {
      data['tenants'] = this.tenants!.map((v) => v.toJson()).toList();
    }
    if (this.alltotalamount != null) {
      data['alltotalamount'] = this.alltotalamount!.toJson();
    }
    return data;
  }
}

class Tenants {
  String? unitDetails;
  String? tenantId;
  String? tenantName;
  List<Charges>? charges;
  PdfDelinquentTenantsData? pdfDelinquentTenantsData;

  Tenants({
    this.unitDetails,
    this.tenantId,
    this.tenantName,
    this.charges,
    this.pdfDelinquentTenantsData,
  });

  Tenants.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      print('Key: $key, Value: $value');
    });
    unitDetails = json['unit_details'];
    tenantId = json['tenant_id'];
    tenantName = json['tenant_name'];
    if (json['Charges'] != null) {
      charges = <Charges>[];
      json['Charges'].forEach((v) {
        charges!.add(Charges.fromJson(v));
      });
    }
    pdfDelinquentTenantsData = json['pdf_data'] != null
        ? PdfDelinquentTenantsData.fromJson(json['pdf_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unit_details'] = this.unitDetails;
    data['tenant_id'] = this.tenantId;
    data['tenant_name'] = this.tenantName;
    if (this.charges != null) {
      data['Charges'] = this.charges!.map((v) => v.toJson()).toList();
    }
    if (this.pdfDelinquentTenantsData != null) {
      data['pdf_data'] = this.pdfDelinquentTenantsData!.toJson();
    }
    return data;
  }
}

class Charges {
  String? sId;
  String? chargeId;
  String? adminId;
  String? tenantId;
  String? leaseId;
  List<Entry>? entry;
  int? totalAmount;
  bool? isLeaseAdded;
  String? type;
  List<String>? uploadedFile; // Changed from List<Null> to List<String>
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? iV;

  Charges({
    this.sId,
    this.chargeId,
    this.adminId,
    this.tenantId,
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
  });

  Charges.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      print('Key: $key, Value: $value');
    });
    sId = json['_id'];
    chargeId = json['charge_id'];
    adminId = json['admin_id'];
    tenantId = json['tenant_id'];
    leaseId = json['lease_id'];
    if (json['entry'] != null) {
      entry = <Entry>[];
      json['entry'].forEach((v) {
        entry!.add(Entry.fromJson(v));
      });
    }
    totalAmount = json['total_amount'];
    isLeaseAdded = json['is_leaseAdded'];
    type = json['type'];
    if (json['uploaded_file'] != null) {
      uploadedFile = List<String>.from(json['uploaded_file']);
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.sId;
    data['charge_id'] = this.chargeId;
    data['admin_id'] = this.adminId;
    data['tenant_id'] = this.tenantId;
    data['lease_id'] = this.leaseId;
    if (this.entry != null) {
      data['entry'] = this.entry!.map((v) => v.toJson()).toList();
    }
    data['total_amount'] = this.totalAmount;
    data['is_leaseAdded'] = this.isLeaseAdded;
    data['type'] = this.type;
    if (this.uploadedFile != null) {
      data['uploaded_file'] = this.uploadedFile;
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    data['__v'] = this.iV;
    return data;
  }
}

class Entry {
  String? entryId;
  String? memo;
  String? account;
  int? amount;
  String? date;
  bool? isPaid;
  bool? isLateFee;
  bool? isRepeatable;
  String? chargeType;
  String? sId;
  String? dueAmount;

  Entry({
    this.entryId,
    this.memo,
    this.account,
    this.amount,
    this.date,
    this.isPaid,
    this.isLateFee,
    this.isRepeatable,
    this.chargeType,
    this.sId,
    this.dueAmount,
  });

  Entry.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      print('Key: $key, Value: $value');
    });
    entryId = json['entry_id'];
    memo = json['memo'];
    account = json['account'];
    amount = json['amount'];
    date = json['date'];
    isPaid = json['is_paid'];
    isLateFee = json['is_lateFee'];
    isRepeatable = json['is_repeatable'];
    chargeType = json['charge_type'];
    sId = json['_id'];
    dueAmount = json['due_amount'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['entry_id'] = this.entryId;
    data['memo'] = this.memo;
    data['account'] = this.account;
    data['amount'] = this.amount;
    data['date'] = this.date;
    data['is_paid'] = this.isPaid;
    data['is_lateFee'] = this.isLateFee;
    data['is_repeatable'] = this.isRepeatable;
    data['charge_type'] = this.chargeType;
    data['_id'] = this.sId;
    data['due_amount'] = this.dueAmount;
    return data;
  }
}

class PdfDelinquentTenantsData {
  String? last30Days;
  String? last31To60Days;
  String? last61To90Days;
  String? last91PlusDays;
  String? totalDaysAmount;

  PdfDelinquentTenantsData({
    this.last30Days,
    this.last31To60Days,
    this.last61To90Days,
    this.last91PlusDays,
    this.totalDaysAmount,
  });

  PdfDelinquentTenantsData.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      print('Key: $key, Value: $value');
    });
    last30Days = json['last_30_days'].toString();
    last31To60Days = json['last_31_to_60_days'].toString();
    last61To90Days = json['last_61_to_90_days'].toString();
    last91PlusDays = json['last_91_plus_days'].toString();
    totalDaysAmount = json['totalDaysAmount'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['last_30_days'] = this.last30Days;
    data['last_31_to_60_days'] = this.last31To60Days;
    data['last_61_to_90_days'] = this.last61To90Days;
    data['last_91_plus_days'] = this.last91PlusDays;
    data['totalDaysAmount'] = this.totalDaysAmount;
    return data;
  }
}
