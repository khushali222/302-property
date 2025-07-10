class Properties_lease_model {
  String? leaseId;
  String? adminId;
  List<String>? tenantId;
  String? rentalId;
  String? unitId;
  String? leaseType;
  String? startDate;
  String? endDate;
  double? amount;
  String? rentCycle;
  String? rentDuedate;
  double? deposite;
  double? recurringCharge;
  String? tenantNames;
  String? rentalAddress;
  String? rentalUnit;
  String? createdAt;
  String? updatedAt;
  int? remainingDays;
  double? totalBalance;

  Properties_lease_model({
    this.leaseId,
    this.adminId,
    this.tenantId,
    this.rentalId,
    this.unitId,
    this.leaseType,
    this.startDate,
    this.endDate,
    this.amount,
    this.rentCycle,
    this.rentDuedate,
    this.deposite,
    this.recurringCharge,
    this.tenantNames,
    this.rentalAddress,
    this.rentalUnit,
    this.createdAt,
    this.updatedAt,
    this.remainingDays,
    this.totalBalance,
  });

  factory Properties_lease_model.fromJson(Map<String, dynamic> json) {
    // Handle remainingDays special case
    int? parsedRemainingDays;
    var remainingDaysValue = json['remainingDays'];
    if (remainingDaysValue != null) {
      if (remainingDaysValue is int) {
        parsedRemainingDays = remainingDaysValue;
      } else if (remainingDaysValue is String) {
        if (remainingDaysValue != "---") {
          parsedRemainingDays = int.tryParse(remainingDaysValue);
        }
      }
    }

    // Handle end_date special case
    String? endDate = json['end_date'];
    if (endDate == "At Will") {
      endDate = "At Will"; // Keep as is
    } else if (endDate == null || endDate.isEmpty) {
      endDate = "";
    }

    return Properties_lease_model(
      leaseId: json['lease_id'] ?? "",
      adminId: json['admin_id'] ?? "",
      tenantId: (json['tenant_id'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      rentalId: json['rental_id'] ?? "",
      unitId: json['unit_id'] ?? "",
      leaseType: json['lease_type'] ?? "",
      startDate: json['start_date'] ?? "",
      endDate: endDate,
      amount: (json['amount'] ?? 0).toDouble(),
      rentCycle: json['rent_cycle'] ?? "",
      rentDuedate: json['rent_duedate'] ?? "",
      deposite: (json['deposite'] ?? 0).toDouble(),
      recurringCharge: (json['recurringCharge'] ?? 0).toDouble(),
      tenantNames: json['tenantNames'] ?? "",
      rentalAddress: json['rental_adress'] ?? "",
      rentalUnit: json['rental_unit'] ?? "",
      createdAt: json['createdAt'] ?? "",
      updatedAt: json['updatedAt'] ?? "",
      remainingDays: parsedRemainingDays,
      totalBalance: (json['totalBalance'] ?? 0).toDouble(),
    );
  }
}
