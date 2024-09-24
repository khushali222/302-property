class Charge {
  String adminId;
  String tenantId;
  String leaseId;
  List<Entry> entry;
  int totalAmount;
  List<String> uploadedFile;
  bool isLeaseAdded;

  Charge({
    required this.adminId,
    required this.tenantId,
    required this.leaseId,
    required this.entry,
    required this.totalAmount,
    required this.uploadedFile,
    required this.isLeaseAdded,
  });

  factory Charge.fromJson(Map<String, dynamic> json) {
    return Charge(
      adminId: json['admin_id'],
      tenantId: json['tenant_id'],
      leaseId: json['lease_id'],
      entry: (json['entry'] as List).map((e) => Entry.fromJson(e)).toList(),
      totalAmount: json['total_amount'],
      uploadedFile: List<String>.from(json['uploaded_file']),
      isLeaseAdded: json['is_leaseAdded'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'tenant_id': tenantId,
      'lease_id': leaseId,
      'entry': entry.map((e) => e.toJson()).toList(),
      'total_amount': totalAmount,
      'uploaded_file': uploadedFile,
      'is_leaseAdded': isLeaseAdded,
    };
  }
}

class Entry {
  String account;
  int amount;
  int dueAmount;
  String memo;
  String date;
  String chargeType;
  bool isRepeatable;

  Entry({
    required this.account,
    required this.amount,
    required this.dueAmount,
    required this.memo,
    required this.date,
    required this.chargeType,
    required this.isRepeatable,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      account: json['account'],
      amount: json['amount'],
      dueAmount: json['due_amount'] != null ?  json['due_amount'] : 0,
      memo: json['memo'],
      date: json['date'],
      chargeType: json['charge_type'],
      isRepeatable: json['is_repeatable'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'amount': amount,
      'due_amount': dueAmount,
      'memo': memo,
      'date': date,
      'charge_type': chargeType,
      'is_repeatable': isRepeatable,
    };
  }
}
