class Scheduled_Payment {
  String? sId;
  String? leaseId;
  String? rentalAddress;
  String? rentalUnit;
  Tenant? tenant;
  double? totalAmount;
  String? paymentType;
  String? date;
  String? account;

  Scheduled_Payment(
      {this.sId,
        this.leaseId,
        this.rentalAddress,
        this.rentalUnit,
        this.tenant,
        this.totalAmount,
        this.paymentType,
        this.account,
        this.date});

  Scheduled_Payment.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    leaseId = json['lease_id'];
    rentalAddress = json['rental_address'];
    rentalUnit = json['rental_unit'];
    tenant = json['tenant'] != null ? Tenant.fromJson(json['tenant']) : null;
    totalAmount = (json['total_amount'] is int)
        ? (json['total_amount'] as int).toDouble()
        : (json['total_amount'] is String)
            ? double.tryParse(json['total_amount'])
            : (json['total_amount'] is double)
                ? json['total_amount']
                : null;
    paymentType = json['payment_type'];
    account = json["account"];
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['lease_id'] = this.leaseId;
    data['rental_address'] = this.rentalAddress;
    data['rental_unit'] = this.rentalUnit;
    if (this.tenant != null) {
      data['tenant'] = this.tenant!.toJson();
    }
    data['total_amount'] = this.totalAmount;
    data['payment_type'] = this.paymentType;
    data['date'] = this.date;
    data["account"] = this.account;
    return data;
  }
}

class Tenant {
  String? tenantId;
  String? tenantName;

  Tenant({this.tenantId, this.tenantName});

  Tenant.fromJson(Map<String, dynamic> json) {
    tenantId = json['tenant_id'];
    tenantName = json['tenant_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tenant_id'] = this.tenantId;
    data['tenant_name'] = this.tenantName;
    return data;
  }
}