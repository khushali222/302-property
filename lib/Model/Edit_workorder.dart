class EditWorkorders {
  int? statusCode;
  EditData? data;
  String? message;

  EditWorkorders({this.statusCode, this.data, this.message});

  EditWorkorders.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    data = json['data'] != null ? EditData.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class EditData {
  String? sId;
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
  List<String>? workOrderImages;
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
  int? iV;
  List<PartsandchargeData>? partsandchargeData;
  PropertyData? propertyData;
  UnitData? unitData;
  StaffData? staffData;
  VendorData? vendorData;
  TenantData? tenantData;

  EditData({
    this.sId,
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
    this.iV,
    this.partsandchargeData,
    this.propertyData,
    this.unitData,
    this.staffData,
    this.vendorData,
    this.tenantData,
  });

  EditData.fromJson(Map<String, dynamic> json) {
    print(json['vendor_id']);
    sId = json['_id'];
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
    workOrderImages = json['workOrder_images'] != null ? List<String>.from(json['workOrder_images']) : null;
    vendorNotes = json['vendor_notes'];
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
    iV = json['__v'];
    if (json['partsandcharge_data'] != null) {
      partsandchargeData = <PartsandchargeData>[];
      json['partsandcharge_data'].forEach((v) {
        partsandchargeData!.add(PartsandchargeData.fromJson(v));
      });
    }
    propertyData = json['property_data'] != null ? PropertyData.fromJson(json['property_data']) : null;
    unitData = json['unit_data'] != null ? UnitData.fromJson(json['unit_data']) : null;
    staffData = json['staff_data'] != null ? StaffData.fromJson(json['staff_data']) : null;
    vendorData = json['vendor_data'] != null ? VendorData.fromJson(json['vendor_data']) : null;
    tenantData = json['tenant_data'] != null ? TenantData.fromJson(json['tenant_data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
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
    if (workOrderImages != null) {
      data['workOrder_images'] = workOrderImages;
    }
    data['vendor_notes'] = vendorNotes;
    data['priority'] = priority;
    data['work_charge_to'] = workChargeTo;
    data['status'] = status;
    data['date'] = date;
    if (workorderUpdates != null) {
      data['workorder_updates'] = workorderUpdates!.map((v) => v.toJson()).toList();
    }
    data['is_billable'] = isBillable;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['is_delete'] = isDelete;
    data['__v'] = iV;
    if (partsandchargeData != null) {
      data['partsandcharge_data'] = partsandchargeData!.map((v) => v.toJson()).toList();
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
  String? statusUpdatedBy;
  String? sId;

  WorkorderUpdates({
    this.status,
    this.date,
    this.staffmemberName,
    this.createdAt,
    this.statusUpdatedBy,
    this.sId,
  });

  WorkorderUpdates.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    date = json['date'];
    staffmemberName = json['staffmember_name'];
    createdAt = json['createdAt'];
    statusUpdatedBy = json['statusUpdatedBy'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['status'] = status;
    data['date'] = date;
    data['staffmember_name'] = staffmemberName;
    data['createdAt'] = createdAt;
    data['statusUpdatedBy'] = statusUpdatedBy;
    data['_id'] = sId;
    return data;
  }
}

class PartsandchargeData {
  String? sId;
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
  int? iV;

  PartsandchargeData({
    this.sId,
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
    this.iV,
  });

  PartsandchargeData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
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
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['parts_id'] = partsId;
    data['workOrder_id'] = workOrderId;
    data['parts_quantity'] = partsQuantity;
    data['account'] = account;
    data['charge_type'] = chargeType;
    data['description'] = description;
    data['parts_price'] = partsPrice;
    data['amount'] = amount;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['is_delete'] = isDelete;
    data['__v'] = iV;
    return data;
  }
}

class PropertyData {
  String? sId;
  String? propertyName;
  String? address;

  PropertyData({this.sId, this.propertyName, this.address});

  PropertyData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    propertyName = json['property_name'];
    address = json['rental_adress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['property_name'] = propertyName;
    data['rental_adress'] = address;
    return data;
  }
}

class UnitData {
  String? sId;
  String? unitNo;

  UnitData({this.sId, this.unitNo});

  UnitData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    unitNo = json['unit_no'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['unit_no'] = unitNo;
    return data;
  }
}

class StaffData {
  String? sId;
  String? staffName;
  String? role;

  StaffData({this.sId, this.staffName, this.role});

  StaffData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    staffName = json['staff_name'];
    role = json['role'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['staff_name'] = staffName;
    data['role'] = role;
    return data;
  }
}

class VendorData {
  String? sId;
  String? vendorName;
  String? vendorType;

  VendorData({this.sId, this.vendorName, this.vendorType});

  VendorData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    vendorName = json['vendor_name'];
    vendorType = json['vendor_type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['vendor_name'] = vendorName;
    data['vendor_type'] = vendorType;
    return data;
  }
}

class TenantData {
  String? sId;
  String? tenantName;
  String? phoneNumber;
  String? email;

  TenantData({this.sId, this.tenantName, this.phoneNumber, this.email});

  TenantData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    tenantName = json['tenant_name'];
    phoneNumber = json['phone_number'];
    email = json['email'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['_id'] = sId;
    data['tenant_name'] = tenantName;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    return data;
  }
}
