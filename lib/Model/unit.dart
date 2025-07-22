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
  String? categoryId;
  String? applianceName;
  String? applianceDescription;
  String? type;
  String? brand;
  String? model;
  String? serialNumber;
  String? installedDate;
  String? warrantyExpiry;
  String? lastMaintenanceDate;
  String? maintenanceNotes;
  String? categoryName;
  String? status;
  List<dynamic>? filters;
  List<dynamic>? notes;
  List<dynamic>? maintenanceHistory;
  String? createdAt;
  String? updatedAt;
  int? iV;

  unit_appliance({
    this.sId,
    this.applianceId,
    this.adminId,
    this.unitId,
    this.categoryId,
    this.applianceName,
    this.applianceDescription,
    this.type,
    this.brand,
    this.model,
    this.serialNumber,
    this.installedDate,
    this.warrantyExpiry,
    this.lastMaintenanceDate,
    this.maintenanceNotes,
    this.categoryName,
    this.status,
    this.filters,
    this.notes,
    this.maintenanceHistory,
    this.createdAt,
    this.updatedAt,
    this.iV,
  });

  unit_appliance.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    applianceId = json['appliance_id'];
    adminId = json['admin_id'];
    unitId = json['unit_id'];
    categoryId = json['category_id'];
    applianceName = json['appliance_name'];
    applianceDescription = json['appliance_description'];
    type = json['type'];
    brand = json['brand'];
    model = json['model'];
    serialNumber = json['serial_number'];
    installedDate = json['installed_date'];
    warrantyExpiry = json['warranty_expiry'];
    lastMaintenanceDate = json['last_maintenance_date'];
    categoryName = json['category_name'];
    maintenanceNotes = json['maintenance_notes'];
    status = json['status'];
    filters = json['filters'];
    notes = json['notes'];
    maintenanceHistory = json['maintenance_history'];
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
    data['category_id'] = this.categoryId;
    data['appliance_name'] = this.applianceName;
    data['appliance_description'] = this.applianceDescription;
    data['type'] = this.type;
    data['brand'] = this.brand;
    data['model'] = this.model;
    data['serial_number'] = this.serialNumber;
    data['installed_date'] = this.installedDate;
    data['warranty_expiry'] = this.warrantyExpiry;
    data['last_maintenance_date'] = this.lastMaintenanceDate;
    data['category_name'] = this.categoryName;
    data['maintenance_notes'] = this.maintenanceNotes;
    data['status'] = this.status;
    data['filters'] = this.filters;
    data['notes'] = this.notes;
    data['maintenance_history'] = this.maintenanceHistory;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}
