class upcoming_renewal {
  String? sId;
  String? leaseId;
  List<String>? tenantId;
  String? adminId;
  String? rentalId;
  String? unitId;
  String? leaseType;
  String? startDate;
  String? endDate;
  int? leaseAmount;

  List<Entry>? entry;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  List<MoveoutTenant>? moveoutTenant;
  int? iV;
  bool? isRenewing;
  int? remainingDays;
  String? rentalAddress;
  String? unit;
  List<String>? tenantNames;

  upcoming_renewal(
      {this.sId,
        this.leaseId,
        this.tenantId,
        this.adminId,
        this.rentalId,
        this.unitId,
        this.leaseType,
        this.startDate,
        this.endDate,
        this.leaseAmount,
       
        this.entry,
        this.createdAt,
        this.updatedAt,
        this.isDelete,
        this.moveoutTenant,
        this.iV,
        this.isRenewing,
        this.remainingDays,
        this.rentalAddress,
        this.unit,
        this.tenantNames});

  upcoming_renewal.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    leaseId = json['lease_id'];
    tenantId = json['tenant_id'].cast<String>();
    adminId = json['admin_id'];
    rentalId = json['rental_id'];
    unitId = json['unit_id'];
    leaseType = json['lease_type'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    leaseAmount = json['lease_amount'];

    if (json['entry'] != null) {
      entry = <Entry>[];
      json['entry'].forEach((v) {
        entry!.add(new Entry.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    if (json['moveout_tenant'] != null) {
      moveoutTenant = <MoveoutTenant>[];
      json['moveout_tenant'].forEach((v) {
        moveoutTenant!.add(new MoveoutTenant.fromJson(v));
      });
    }
    iV = json['__v'];
    isRenewing = json['is_renewing'];
    remainingDays = json['remainingDays'];
    rentalAddress = json['rental_address'];
    unit = json['unit'];
    tenantNames = json['tenantNames'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['lease_id'] = this.leaseId;
    data['tenant_id'] = this.tenantId;
    data['admin_id'] = this.adminId;
    data['rental_id'] = this.rentalId;
    data['unit_id'] = this.unitId;
    data['lease_type'] = this.leaseType;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['lease_amount'] = this.leaseAmount;

    if (this.entry != null) {
      data['entry'] = this.entry!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    if (this.moveoutTenant != null) {
      data['moveout_tenant'] =
          this.moveoutTenant!.map((v) => v.toJson()).toList();
    }
    data['__v'] = this.iV;
    data['is_renewing'] = this.isRenewing;
    data['remainingDays'] = this.remainingDays;
    data['rental_address'] = this.rentalAddress;
    data['unit'] = this.unit;
    data['tenantNames'] = this.tenantNames;
    return data;
  }
}

class Entry {
  String? entryId;
  String? memo;
  String? date;
  String? chargeType;
  String? account;
  String? rentCycle;
  int? amount;
  String? sId;

  Entry(
      {this.entryId,
        this.memo,
        this.date,
        this.chargeType,
        this.account,
        this.rentCycle,
        this.amount,
        this.sId});

  Entry.fromJson(Map<String, dynamic> json) {
    entryId = json['entry_id'];
    memo = json['memo'];
    date = json['date'];
    chargeType = json['charge_type'];
    account = json['account'];
    rentCycle = json['rent_cycle'];
    amount = json['amount'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['entry_id'] = this.entryId;
    data['memo'] = this.memo;
    data['date'] = this.date;
    data['charge_type'] = this.chargeType;
    data['account'] = this.account;
    data['rent_cycle'] = this.rentCycle;
    data['amount'] = this.amount;
    data['_id'] = this.sId;
    return data;
  }
}

class MoveoutTenant {
  String? moveoutNoticeGivenDate;
  String? moveoutDate;
  String? sId;

  MoveoutTenant({this.moveoutNoticeGivenDate, this.moveoutDate, this.sId});

  MoveoutTenant.fromJson(Map<String, dynamic> json) {
    moveoutNoticeGivenDate = json['moveout_notice_given_date'];
    moveoutDate = json['moveout_date'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['moveout_notice_given_date'] = this.moveoutNoticeGivenDate;
    data['moveout_date'] = this.moveoutDate;
    data['_id'] = this.sId;
    return data;
  }
}