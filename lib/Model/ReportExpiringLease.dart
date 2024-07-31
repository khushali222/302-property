class ReportExpiringLeaseTable {
  final int? statusCode;
  final List<ReportExpiringLeaseData>? data;

  ReportExpiringLeaseTable({this.statusCode, this.data});

  factory ReportExpiringLeaseTable.fromJson(Map<String, dynamic> json) {
    return ReportExpiringLeaseTable(
      statusCode: json['statusCode'],
      data: json['data'] != null
          ? List<ReportExpiringLeaseData>.from(
              json['data'].map((v) => ReportExpiringLeaseData.fromJson(v)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'data': data?.map((v) => v.toJson()).toList(),
    };
  }
}

class ReportExpiringLeaseData {
  final String? leaseId;
  final String? adminId;
  final List<String>? tenantId;
  final String? rentalId;
  final String? unitId;
  final String? leaseType;
  final String? startDate;
  final String? endDate;
  final int? amount;
  final int? recurring;
  final String? tenantNames;
  final String? rentalAddress;
  final String? rentalUnit;
  final String? createdAt;
  final String? updatedAt;
  final String? status;

  ReportExpiringLeaseData({
    this.leaseId,
    this.adminId,
    this.tenantId,
    this.rentalId,
    this.unitId,
    this.leaseType,
    this.startDate,
    this.endDate,
    this.amount,
    this.recurring,
    this.tenantNames,
    this.rentalAddress,
    this.rentalUnit,
    this.createdAt,
    this.updatedAt,
    this.status,
  });

  factory ReportExpiringLeaseData.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      print('Key: $key, Value: $value');
    });

    return ReportExpiringLeaseData(
      leaseId: json['lease_id'],
      adminId: json['admin_id'],
      tenantId: json['tenant_id'] != null
          ? List<String>.from(json['tenant_id'])
          : null,
      rentalId: json['rental_id'],
      unitId: json['unit_id'],
      leaseType: json['lease_type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      amount: json['amount'],
      recurring: json['recurring'],
      tenantNames: json['tenantNames'],
      rentalAddress: json['rental_address'],
      rentalUnit: json['rental_unit'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lease_id': leaseId,
      'admin_id': adminId,
      'tenant_id': tenantId,
      'rental_id': rentalId,
      'unit_id': unitId,
      'lease_type': leaseType,
      'start_date': startDate,
      'end_date': endDate,
      'amount': amount,
      'recurring': recurring,
      'tenantNames': tenantNames,
      'rental_address': rentalAddress,
      'rental_unit': rentalUnit,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'status': status,
    };
  }
}
