class applience_details_model {
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
  String? status;
  List<Filters>? filters;
  String? createdAt;
  String? updatedAt;
  List<dynamic>? notes;
  List<dynamic>? maintenanceHistory;
  int? iV;

  applience_details_model(
      {this.sId,
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
        this.status,
        this.filters,
        this.createdAt,
        this.updatedAt,
        this.notes,
        this.maintenanceHistory,
        this.iV});

  applience_details_model.fromJson(Map<String, dynamic> json) {
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
    maintenanceNotes = json['maintenance_notes'];
    status = json['status'];
    if (json['filters'] != null) {
      filters = <Filters>[];
      json['filters'].forEach((v) {
        filters!.add(new Filters.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    notes = json['notes'];
    maintenanceHistory = json['maintenance_history'];
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
    data['maintenance_notes'] = this.maintenanceNotes;
    data['status'] = this.status;
    if (this.filters != null) {
      data['filters'] = this.filters!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.notes != null) {
      data['notes'] = this.notes!.map((v) => v.toJson()).toList();
    }
    if (this.maintenanceHistory != null) {
      data['maintenance_history'] =
          this.maintenanceHistory!.map((v) => v.toJson()).toList();
    }
    data['__v'] = this.iV;
    return data;
  }
}

class Filters {
  String? filterId;
  String? filterName;
  String? filterSize;
  String? sId;

  Filters({this.filterId, this.filterName, this.filterSize, this.sId});

  Filters.fromJson(Map<String, dynamic> json) {
    filterId = json['filter_id'];
    filterName = json['filter_name'];
    filterSize = json['filter_size'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['filter_id'] = this.filterId;
    data['filter_name'] = this.filterName;
    data['filter_size'] = this.filterSize;
    data['_id'] = this.sId;
    return data;
  }
}
