class ScheduledCharges {
  String? taskId;
  String? actionDate;
  String? account;
  String? chargeType;
  String? description;
  double amount;
  String? leaseId;
  String? rentalId;
  String? rentalAddress;

  ScheduledCharges({
    this.taskId,
    this.actionDate,
    this.account,
    this.chargeType,
    this.description,
    double? amount,
    this.leaseId,
    this.rentalId,
    this.rentalAddress,
  }) : amount = amount ?? 0.0;

  ScheduledCharges.fromJson(Map<String, dynamic> json)
      : taskId = json['task_id'],
        actionDate = json['action_date'],
        account = json['account'],
        chargeType = json['charge_type'],
        description = json['description'],
        amount = (json['amount'] is int)
            ? (json['amount'] as int).toDouble()
            : (json['amount'] is String)
            ? double.tryParse(json['amount']) ?? 0.0
            : (json['amount'] is double)
            ? json['amount']
            : 0.0,
        leaseId = json['lease_id'],
        rentalId = json['rental_id'],
        rentalAddress = json['rental_address'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['task_id'] = taskId;
    data['action_date'] = actionDate;
    data['account'] = account;
    data['charge_type'] = chargeType;
    data['description'] = description;
    data['amount'] = amount;
    data['lease_id'] = leaseId;
    data['rental_id'] = rentalId;
    data['rental_address'] = rentalAddress;
    return data;
  }
}
