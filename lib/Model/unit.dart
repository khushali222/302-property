class unit_lease {
  String? tenantId;
  String? tenantFirstName;
  String? tenantLastName;
  String? startDate;
  String? endDate;
  String? leaseId;
  String? leaseType;
  int? amount;

  unit_lease(
      {this.tenantId,
        this.tenantFirstName,
        this.tenantLastName,
        this.startDate,
        this.endDate,
        this.leaseId,
        this.leaseType,
        this.amount});

  unit_lease.fromJson(Map<String, dynamic> json) {
    tenantId = json['tenant_id'];
    tenantFirstName = json['tenant_firstName'];
    tenantLastName = json['tenant_lastName'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    leaseId = json['lease_id'];
    leaseType = json['lease_type'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tenant_id'] = this.tenantId;
    data['tenant_firstName'] = this.tenantFirstName;
    data['tenant_lastName'] = this.tenantLastName;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['lease_id'] = this.leaseId;
    data['lease_type'] = this.leaseType;
    data['amount'] = this.amount;
    return data;
  }
}
class unit_appliance {
  String? sId;
  String? applianceId;
  String? adminId;
  String? unitId;
  String? applianceName;
  String? applianceDescription;
  String? installedDate;
  String? createdAt;
  String? updatedAt;
  int? iV;

  unit_appliance(
      {this.sId,
        this.applianceId,
        this.adminId,
        this.unitId,
        this.applianceName,
        this.applianceDescription,
        this.installedDate,
        this.createdAt,
        this.updatedAt,
        this.iV});

  unit_appliance.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    applianceId = json['appliance_id'];
    adminId = json['admin_id'];
    unitId = json['unit_id'];
    applianceName = json['appliance_name'];
    applianceDescription = json['appliance_description'];
    installedDate = json['installed_date'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['appliance_id'] = this.applianceId;
    data['admin_id'] = this.adminId;
    data['unit_id'] = this.unitId;
    data['appliance_name'] = this.applianceName;
    data['appliance_description'] = this.applianceDescription;
    data['installed_date'] = this.installedDate;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

