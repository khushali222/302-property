// class ChargeResponses {
//    int? statusCode;
//    String? chargeId;
//    String? adminId;
//    String? tenantId;
//    String? leaseId;
//    List<Entrycharge>? entry;
//    String? message;
//
//   ChargeResponses({
//      this.statusCode,
//      this.chargeId,
//      this.adminId,
//      this.tenantId,
//      this.leaseId,
//      this.entry,
//      this.message,
//   });
//
//   factory ChargeResponses.fromJson(Map<String, dynamic> json) {
//     return ChargeResponses(
//       statusCode: json['statusCode']??"",
//       chargeId: json['charge_id']??"",
//       adminId: json['admin_id']??"",
//       tenantId: json['tenant_id']??"",
//       leaseId: json['lease_id']??"",
//       entry: (json['entry'] as List).map((i) => Entrycharge.fromJson(i)).toList(),
//       message: json['message']??"",
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'statusCode': statusCode,
//       'charge_id': chargeId,
//       'admin_id': adminId,
//       'tenant_id': tenantId,
//       'lease_id': leaseId,
//       'entry': entry?.map((i) => i.toJson()).toList(),
//       'message': message,
//     };
//   }
// }
//
// class Entrycharge {
//    String? entryId;
//    String? memo;
//    String? account;
//    int? amount;
//    String? date;
//    bool? isPaid;
//    bool? isLateFee;
//    bool? isRepeatable;
//    String? chargeType;
//    String? id;
//    int? chargeAmount;
//    String? chargeId;
//
//    Entrycharge({
//      this.entryId,
//      this.memo,
//      this.account,
//      this.amount,
//      this.date,
//      this.isPaid,
//      this.isLateFee,
//      this.isRepeatable,
//      this.chargeType,
//      this.id,
//      this.chargeAmount,
//      this.chargeId,
//   });
//
//   factory Entrycharge.fromJson(Map<String, dynamic> json) {
//     return Entrycharge(
//       entryId: json['entry_id']??"",
//       memo: json['memo']??"",
//       account: json['account']??"",
//       amount: json['amount']??"",
//       date: json['date']??"",
//       isPaid: json['is_paid']??"",
//       isLateFee: json['is_lateFee']??"",
//       isRepeatable: json['is_repeatable']??"",
//       chargeType: json['charge_type']??"",
//       id: json['_id']??"",
//       chargeAmount: json['charge_amount']??"",
//       chargeId: json['charge_id']??"",
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'entry_id': entryId,
//       'memo': memo,
//       'account': account,
//       'amount': amount,
//       'date': date,
//       'is_paid': isPaid,
//       'is_lateFee': isLateFee,
//       'is_repeatable': isRepeatable,
//       'charge_type': chargeType,
//       '_id': id,
//       'charge_amount': chargeAmount,
//       'charge_id': chargeId,
//     };
//   }
// }

class ChargeResponses {
  int? statusCode;
  String? chargeId;
  String? adminId;
  String? tenantId;
  String? leaseId;
  List<Entrycharge>? entry;
  String? message;

  ChargeResponses({
    this.statusCode,
    this.chargeId,
    this.adminId,
    this.tenantId,
    this.leaseId,
    this.entry,
    this.message,
  });

  factory ChargeResponses.fromJson(Map<String, dynamic> json) {
    print(json);
    print(json['statusCode'].runtimeType);
    print(json['charge_id'].runtimeType);
    print(json['admin_id'].runtimeType);
    print(json['tenant_id'].runtimeType);
    print(json['lease_id'].runtimeType);
    print(json['entry'].runtimeType);

    return ChargeResponses(
      statusCode: json['statusCode'] as int?,
      chargeId: json['charge_id'] as String?,
      adminId: json['admin_id'] as String?,
      tenantId: json['tenant_id'] as String?,
      leaseId: json['lease_id'] as String?,
      entry: (json['entry'] as List<dynamic>?)
          ?.map((e) => Entrycharge.fromJson(e as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'charge_id': chargeId,
      'admin_id': adminId,
      'tenant_id': tenantId,
      'lease_id': leaseId,
      'entry': entry?.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }
}

class Entrycharge {
  String? entryId;
  String? memo;
  String? account;
  int? amount;
  String? date;
  bool? isPaid;
  bool? isLateFee;
  bool? isRepeatable;
  String? chargeType;
  String? id;
  double? chargeAmount;
  String? chargeId;

  Entrycharge({
    this.entryId,
    this.memo,
    this.account,
    this.amount,
    this.date,
    this.isPaid,
    this.isLateFee,
    this.isRepeatable,
    this.chargeType,
    this.id,
    this.chargeAmount,
    this.chargeId,
  });

  factory Entrycharge.fromJson(Map<String, dynamic> json) {

    return Entrycharge(
      entryId: json['entry_id'] as String?,
      memo: json['memo'] as String?,
      account: json['account'] as String?,
      amount: json['amount'] as int?,
      date: json['date'] as String?,
      isPaid: json['is_paid'] as bool?,
      isLateFee: json['is_lateFee'] as bool?,
      isRepeatable: json['is_repeatable'] as bool?,
      chargeType: json['charge_type'] as String?,
      id: json['_id'] as String?,
      chargeAmount: (json['due_amount'] is int)
          ? (json['due_amount'] as int).toDouble()
          : json['due_amount'] as double?,
      //chargeId: json['charge_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'entry_id': entryId,
      'memo': memo,
      'account': account,
      'amount': amount,
      'date': date,
      'is_paid': isPaid,
      'is_lateFee': isLateFee,
      'is_repeatable': isRepeatable,
      'charge_type': chargeType,
      '_id': id,
      'due_amount': chargeAmount,
      'charge_id': chargeId,
    };
  }
}
