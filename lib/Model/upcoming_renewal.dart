import 'package:three_zero_two_property/Model/json_parse.dart';

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
  double? leaseAmount;

  List<Entry>? entry;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  List<MoveoutTenant>? moveoutTenant;
  double? iV;
  bool? isRenewing;
  double? remainingDays;
  String? rentalAddress;
  String? unit;
  List<String>? tenantNames;

  upcoming_renewal({
    this.sId,
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
    this.tenantNames,
  });

  upcoming_renewal.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    leaseId = json['lease_id'];
    tenantId = json['tenant_id']?.cast<String>();
    adminId = json['admin_id'];
    rentalId = json['rental_id'];
    unitId = json['unit_id'];
    leaseType = json['lease_type'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    leaseAmount = asDoubleOrNull(json['lease_amount']);

    if (json['entry'] != null) {
      entry = <Entry>[];
      json['entry'].forEach((v) {
        entry!.add(Entry.fromJson(v));
      });
    }

    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];

    if (json['moveout_tenant'] != null) {
      moveoutTenant = <MoveoutTenant>[];
      json['moveout_tenant'].forEach((v) {
        moveoutTenant!.add(MoveoutTenant.fromJson(v));
      });
    }

    iV = asDoubleOrNull(json['__v']);
    isRenewing = json['is_renewing'];
    remainingDays = asDoubleOrNull(json['remainingDays']);
    rentalAddress = json['rental_address'];
    unit = json['unit'];

    if (json['tenantNames'] != null) {
      tenantNames =
          (json['tenantNames'] as List).map((tenant) => tenant['name'].toString()).toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['lease_id'] = leaseId;
    data['tenant_id'] = tenantId;
    data['admin_id'] = adminId;
    data['rental_id'] = rentalId;
    data['unit_id'] = unitId;
    data['lease_type'] = leaseType;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['lease_amount'] = leaseAmount;

    if (entry != null) {
      data['entry'] = entry!.map((v) => v.toJson()).toList();
    }

    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['is_delete'] = isDelete;

    if (moveoutTenant != null) {
      data['moveout_tenant'] = moveoutTenant!.map((v) => v.toJson()).toList();
    }

    data['__v'] = iV;
    data['is_renewing'] = isRenewing;
    data['remainingDays'] = remainingDays;
    data['rental_address'] = rentalAddress;
    data['unit'] = unit;
    data['tenantNames'] = tenantNames;

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
  double? amount;
  String? sId;

  Entry({
    this.entryId,
    this.memo,
    this.date,
    this.chargeType,
    this.account,
    this.rentCycle,
    this.amount,
    this.sId,
  });

  Entry.fromJson(Map<String, dynamic> json) {
    entryId = json['entry_id'];
    memo = json['memo'];
    date = json['date'];
    chargeType = json['charge_type'];
    account = json['account'];
    rentCycle = json['rent_cycle'];
    amount = asDoubleOrNull(json['amount']);
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['entry_id'] = entryId;
    data['memo'] = memo;
    data['date'] = date;
    data['charge_type'] = chargeType;
    data['account'] = account;
    data['rent_cycle'] = rentCycle;
    data['amount'] = amount;
    data['_id'] = sId;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['moveout_notice_given_date'] = moveoutNoticeGivenDate;
    data['moveout_date'] = moveoutDate;
    data['_id'] = sId;
    return data;
  }
}
