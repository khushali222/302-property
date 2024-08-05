import 'dart:developer';

class WorkOrderData_summery {
  String? id;
  String? workOrderId;
  String? adminId;
  String? rentalId;
  String? unitId;
  String? vendorId;
  String? tenantId;
  String? staffmemberId;
  String? workSubject;
  String? workCategory;
  bool? entryAllowed;
  String? workPerformed;
  List<dynamic>? workOrderImages;
  String? vendorNotes;
  String? priority;
  String? workChargeTo;
  String? status;
  String? date;
  List<WorkorderUpdates>? workorderUpdates;
  bool? isBillable;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? v;
  List<PartsandchargeData>? partsandchargeData;
  PropertyData? propertyData;
  UnitData? unitData;
  StaffData? staffData;
  VendorData? vendorData;
  TenantData? tenantData;

  WorkOrderData_summery(
      {this.id,
        this.workOrderId,
        this.adminId,
        this.rentalId,
        this.unitId,
        this.vendorId,
        this.tenantId,
        this.staffmemberId,
        this.workSubject,
        this.workCategory,
        this.entryAllowed,
        this.workPerformed,
        this.workOrderImages,
        this.vendorNotes,
        this.priority,
        this.workChargeTo,
        this.status,
        this.date,
        this.workorderUpdates,
        this.isBillable,
        this.createdAt,
        this.updatedAt,
        this.isDelete,
        this.v,
        this.partsandchargeData,
        this.propertyData,
        this.unitData,
        this.staffData,
        this.vendorData,
        this.tenantData});

  WorkOrderData_summery.fromJson(Map<String, dynamic> json) {
    log(json.toString());
    id = json['_id'];
    workOrderId = json['workOrder_id'];
    adminId = json['admin_id'];
    rentalId = json['rental_id'];
    unitId = json['unit_id'];
    vendorId = json['vendor_id'];
    tenantId = json['tenant_id'];
    staffmemberId = json['staffmember_id'];
    workSubject = json['work_subject'];
    workCategory = json['work_category'];
    entryAllowed = json['entry_allowed'];
    workPerformed = json['work_performed'];
    workOrderImages = json['workOrder_images'];
    vendorNotes = json['vendor_notes'] ??"N/A";
    priority = json['priority'];
    workChargeTo = json['work_charge_to'];
    status = json['status'];
    date = json['date'];
    if (json['workorder_updates'] != null) {
      workorderUpdates = <WorkorderUpdates>[];
      json['workorder_updates'].forEach((v) {
        workorderUpdates!.add(WorkorderUpdates.fromJson(v));
      });
    }
    isBillable = json['is_billable'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    v = json['__v'];
    if (json['partsandcharge_data'] != null) {
      partsandchargeData = <PartsandchargeData>[];
      json['partsandcharge_data'].forEach((v) {
        partsandchargeData!.add(PartsandchargeData.fromJson(v));
      });
    }
    propertyData = json['property_data'] != null
        ? PropertyData.fromJson(json['property_data'])
        : null;
    unitData = json['unit_data'] != null
        ? UnitData.fromJson(json['unit_data'])
        : null;
    staffData = json['staff_data'] != null
        ? StaffData.fromJson(json['staff_data'])
        : null;
    vendorData = json['vendor_data'] != null
        ? VendorData.fromJson(json['vendor_data'])
        : null;
    tenantData = json['tenant_data'] != null
        ? TenantData.fromJson(json['tenant_data'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['workOrder_id'] = workOrderId;
    data['admin_id'] = adminId;
    data['rental_id'] = rentalId;
    data['unit_id'] = unitId;
    data['vendor_id'] = vendorId;
    data['tenant_id'] = tenantId;
    data['staffmember_id'] = staffmemberId;
    data['work_subject'] = workSubject;
    data['work_category'] = workCategory;
    data['entry_allowed'] = entryAllowed;
    data['work_performed'] = workPerformed;
    data['workOrder_images'] = workOrderImages;
    data['vendor_notes'] = vendorNotes;
    data['priority'] = priority;
    data['work_charge_to'] = workChargeTo;
    data['status'] = status;
    data['date'] = date;
    if (workorderUpdates != null) {
      data['workorder_updates'] =
          workorderUpdates!.map((v) => v.toJson()).toList();
    }
    data['is_billable'] = isBillable;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['is_delete'] = isDelete;
    data['__v'] = v;
    if (partsandchargeData != null) {
      data['partsandcharge_data'] =
          partsandchargeData!.map((v) => v.toJson()).toList();
    }
    if (propertyData != null) {
      data['property_data'] = propertyData!.toJson();
    }
    if (unitData != null) {
      data['unit_data'] = unitData!.toJson();
    }
    if (staffData != null) {
      data['staff_data'] = staffData!.toJson();
    }
    if (vendorData != null) {
      data['vendor_data'] = vendorData!.toJson();
    }
    if (tenantData != null) {
      data['tenant_data'] = tenantData!.toJson();
    }
    return data;
  }
}

class WorkorderUpdates {
  String? status;
  String? date;
  String? staffmemberName;
  String? createdAt;
  String? updatedAt;
  String? statusUpdatedBy;
  String? id;

  WorkorderUpdates(
      {this.status,
        this.date,
        this.staffmemberName,
        this.createdAt,
        this.updatedAt,
        this.statusUpdatedBy,
        this.id});

  WorkorderUpdates.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    date = json['date'];
    staffmemberName = json['staffmember_name'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    statusUpdatedBy = json['statusUpdatedBy'];
    id = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['date'] = this.date;
    data['staffmember_name'] = this.staffmemberName;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['statusUpdatedBy'] = this.statusUpdatedBy;
    data['_id'] = this.id;
    return data;
  }
}

class PartsandchargeData {
  String? id;
  String? partsId;
  String? workOrderId;
  int? partsQuantity;
  String? account;
  String? chargeType;
  String? description;
  int? partsPrice;
  int? amount;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? v;

  PartsandchargeData(
      {this.id,
        this.partsId,
        this.workOrderId,
        this.partsQuantity,
        this.account,
        this.chargeType,
        this.description,
        this.partsPrice,
        this.amount,
        this.createdAt,
        this.updatedAt,
        this.isDelete,
        this.v});

  PartsandchargeData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    partsId = json['parts_id'];
    workOrderId = json['workOrder_id'];
    partsQuantity = json['parts_quantity'];
    account = json['account'];
    chargeType = json['charge_type'];
    description = json['description'];
    partsPrice = json['parts_price'];
    amount = json['amount'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    v = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['parts_id'] = this.partsId;
    data['workOrder_id'] = this.workOrderId;
    data['parts_quantity'] = this.partsQuantity;
    data['account'] = this.account;
    data['charge_type'] = this.chargeType;
    data['description'] = this.description;
    data['parts_price'] = this.partsPrice;
    data['amount'] = this.amount;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    data['__v'] = this.v;
    return data;
  }
}

class PropertyData {
  String? id;
  String? propertyName;
  String? rentaladress;
  String? rental_city;
  String? rental_state;
  String? rental_country;
  String? rental_postcode;
  String? rental_image;

  PropertyData({this.id, this.propertyName});

  PropertyData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    propertyName = json['property_name'];
    rentaladress = json['rental_adress'];
    rental_city = json['rental_city'];
    rental_state = json['rental_state'];
    rental_country = json['rental_country'];
    rental_postcode = json['rental_postcode'];
    rental_image = json['rental_image'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['property_name'] = this.propertyName;
    data['rental_adress'] = this.rentaladress;
    return data;
  }
}

class UnitData {
  String? id;
  String? unitName;

  UnitData({this.id, this.unitName});

  UnitData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    unitName = json['rental_unit_adress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['unit_name'] = this.unitName;
    return data;
  }
}

class StaffData {
  String? id;
  String? firstname;
  String? lastname;

  StaffData({this.id, this.firstname, this.lastname});

  StaffData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    firstname = json['staffmember_name']??"N/A";
    lastname = json['lastname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['staffmember_name'] = this.firstname;
    data['lastname'] = this.lastname;
    return data;
  }
}

class VendorData {
  String? id;
  String? companyName;

  VendorData({this.id, this.companyName});

  VendorData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    companyName = json['vendor_name'] ??"N/A";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['company_name'] = this.companyName;
    return data;
  }
}

class TenantData {
  String? id;
  String? firstname;
  String? lastname;

  TenantData({this.id, this.firstname, this.lastname});

  TenantData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    firstname = json['tenant_firstName'];
    lastname = json['tenant_lastName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['tenant_firstName'] = this.firstname;
    data['tenant_lastName'] = this.lastname;
    return data;
  }
}
