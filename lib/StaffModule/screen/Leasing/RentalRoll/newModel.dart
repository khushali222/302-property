class LeaseDatas {
  final String leaseId;
  final List<String> tenantId;
  final String adminId;
  final String rentalId;
  final String unitId;
  final String leaseType;
  final String startDate;
  final String endDate;
  final String rentalAddress;
  final String rentalImage;
  final int amount;
  final String date;
  final List<TenantDatas> tenantData;

  LeaseDatas({
    required this.leaseId,
    required this.tenantId,
    required this.adminId,
    required this.rentalId,
    required this.unitId,
    required this.leaseType,
    required this.startDate,
    required this.endDate,
    required this.rentalAddress,
    required this.rentalImage,
    required this.amount,
    required this.date,
    required this.tenantData,
  });

  factory LeaseDatas.fromJson(Map<String, dynamic> json) {
    var tenantList = json['tenant_data'] as List;
    List<TenantDatas> tenants =
        tenantList.map((i) => TenantDatas.fromJson(i)).toList();

    return LeaseDatas(
      leaseId: json['lease_id'],
      tenantId: List<String>.from(json['tenant_id']),
      adminId: json['admin_id'],
      rentalId: json['rental_id'],
      unitId: json['unit_id'],
      leaseType: json['lease_type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      rentalAddress: json['rental_adress'],
      rentalImage: json['rental_image'],
      amount: json['amount'],
      date: json['date'],
      tenantData: tenants,
    );
  }
}

class TenantDatas {
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;

  TenantDatas({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
  });

  factory TenantDatas.fromJson(Map<String, dynamic> json) {
    return TenantDatas(
      firstName: json['tenant_firstName'],
      lastName: json['tenant_lastName'],
      email: json['tenant_email'],
      phoneNumber: json['tenant_phoneNumber'],
    );
  }
}
