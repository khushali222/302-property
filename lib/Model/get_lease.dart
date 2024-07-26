class Lease1 {
  String? leaseId;
  String? adminId;
  List<String>? tenantIds;
  String? rentalId;
  String? unitId;
  String? leaseType;
  String? startDate;
  String? endDate;
  double? amount;
  String? rentCycle;
  String? rentDueDate;
  double? deposit;
  double? recurringCharge;
  String? tenantNames;
  String? rentalAddress;
  String? rentalUnit;
  String? createdAt;
  String? updatedAt;

  Lease1({
    this.leaseId,
    this.adminId,
    this.tenantIds,
    this.rentalId,
    this.unitId,
    this.leaseType,
    this.startDate,
    this.endDate,
    this.amount,
    this.rentCycle,
    this.rentDueDate,
    this.deposit,
    this.recurringCharge,
    this.tenantNames,
    this.rentalAddress,
    this.rentalUnit,
    this.createdAt,
    this.updatedAt,
  });

  factory Lease1.fromJson(Map<String, dynamic> json) {
    print(json);
    
    return Lease1(
      leaseId: json['lease_id'] as String?,
      adminId: json['admin_id'] as String?,
      tenantIds: (json['tenant_id'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      rentalId: json['rental_id'] as String?,
      unitId: json['unit_id'] as String?,
      leaseType: json['lease_type'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      rentCycle: json['rent_cycle'] as String?,
      rentDueDate: json['rent_duedate'] as String?,
      deposit: (json['deposite'] as num?)?.toDouble(),
      recurringCharge: (json['recurringCharge'] as num?)?.toDouble(),
      tenantNames: json['tenantNames'] as String?,
      rentalAddress: json['rental_adress'] as String?,
      rentalUnit: json['rental_unit'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lease_id': leaseId,
      'admin_id': adminId,
      'tenant_id': tenantIds,
      'rental_id': rentalId,
      'unit_id': unitId,
      'lease_type': leaseType,
      'start_date': startDate,
      'end_date': endDate,
      'amount': amount,
      'rent_cycle': rentCycle,
      'rent_duedate': rentDueDate,
      'deposite': deposit,
      'recurringCharge': recurringCharge,
      'tenantNames': tenantNames,
      'rental_adress': rentalAddress,
      'rental_unit': rentalUnit,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
