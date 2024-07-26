class PropertiesWorkOrders {
  int? statusCode;
  List<propertiesworkData>? data;
  List<dynamic>? completeData;
  int? count;
  int? completeCount;
  String? message;

  PropertiesWorkOrders({
    this.statusCode,
    this.data,
    this.completeData,
    this.count,
    this.completeCount,
    this.message,
  });

  PropertiesWorkOrders.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <propertiesworkData>[];
      json['data'].forEach((v) {
        data!.add(propertiesworkData.fromJson(v));
      });
    }
    if (json['complete_data'] != null) {
      completeData = [];
      json['complete_data'].forEach((v) {
        completeData!.add(v); // Assuming completeData items are dynamic
      });
    }
    count = json['count'];
    completeCount = json['complete_count'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (completeData != null) {
      data['complete_data'] = completeData;
    }
    data['count'] = count;
    data['complete_count'] = completeCount;
    data['message'] = message;
    return data;
  }
}

class propertiesworkData {
  String? sId;
  String? workOrderId;
  String? adminId;
  String? rentalId;
  String? unitId;
  String? vendorId;
  String? tenantId;
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
  int? iV;
  String? staffmemberName;

  propertiesworkData({
    this.sId,
    this.workOrderId,
    this.adminId,
    this.rentalId,
    this.unitId,
    this.vendorId,
    this.tenantId,
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
    this.staffmemberName,
  });

  propertiesworkData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    workOrderId = json['workOrder_id'];
    adminId = json['admin_id'];
    rentalId = json['rental_id'];
    unitId = json['unit_id'];
    vendorId = json['vendor_id'];
    tenantId = json['tenant_id'];
    workSubject = json['work_subject'];
    workCategory = json['work_category'];
    entryAllowed = json['entry_allowed'];
    workPerformed = json['work_performed'];
    if (json['workOrder_images'] != null) {
      workOrderImages = [];
      json['workOrder_images'].forEach((v) {
        workOrderImages!.add(v);
      });
    }
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
    staffmemberName = json['staffmember_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId;
    data['workOrder_id'] = workOrderId;
    data['admin_id'] = adminId;
    data['rental_id'] = rentalId;
    data['unit_id'] = unitId;
    data['vendor_id'] = vendorId;
    data['tenant_id'] = tenantId;
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
      data['workorder_updates'] =
          workorderUpdates!.map((v) => v.toJson()).toList();
    }
    data['is_billable'] = isBillable;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['is_delete'] = isDelete;
    data['__v'] = iV;
    data['staffmember_name'] = staffmemberName;
    return data;
  }
}

class WorkorderUpdates {
  String? status;
  String? date;
  String? createdAt;
  String? sId;

  WorkorderUpdates({this.status, this.date, this.createdAt, this.sId});

  WorkorderUpdates.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    date = json['date'];
    createdAt = json['createdAt'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    data['date'] = date;
    data['createdAt'] = createdAt;
    data['_id'] = sId;
    return data;
  }
}
