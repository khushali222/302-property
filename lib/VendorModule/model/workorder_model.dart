class WorkOrder {
  String? id;
  String? workOrderId;
  String? adminId;
  String? rentalId;
  String? unitId;
  String? vendorId;
  String? tenantId;
  String? leaseId;
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
  List<WorkOrderUpdate>? workorderUpdates;
  bool? isBillable;
  String? createdAt;
  String? updatedAt;
  String? ticketNumber;
  bool? isDelete;
  int? v;
  UnitData? unitData;
  RentalData? rentalData;

  WorkOrder({
    this.id,
    this.workOrderId,
    this.adminId,
    this.rentalId,
    this.unitId,
    this.vendorId,
    this.tenantId,
    this.leaseId,
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
    this.ticketNumber,
    this.v,
    this.unitData,
    this.rentalData,
  });

  WorkOrder.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    workOrderId = json['workOrder_id'];
    adminId = json['admin_id'];
    rentalId = json['rental_id'];
    unitId = json['unit_id'];
    vendorId = json['vendor_id'];
    tenantId = json['tenant_id'];
    leaseId = json['lease_id'];
    staffmemberId = json['staffmember_id'];
    workSubject = json['work_subject'];
    workCategory = json['work_category'];
    entryAllowed = json['entry_allowed'];
    workPerformed = json['work_performed'];
    workOrderImages = json['workOrder_images']?.cast<String>();
    vendorNotes = json['vendor_notes'];
    priority = json['priority'];
    workChargeTo = json['work_charge_to'];
    status = json['status'];
    ticketNumber = json['ticket_number'];
    date = json['date'];

    if (json['workorder_updates'] != null) {
      workorderUpdates = <WorkOrderUpdate>[];
      json['workorder_updates'].forEach((v) {
        workorderUpdates!.add(WorkOrderUpdate.fromJson(v));
      });
    }

    isBillable = json['is_billable'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    v = json['__v'];

    unitData = json['unit_data'] != null ? UnitData.fromJson(json['unit_data']) : null;
    rentalData = json['rental_data'] != null ? RentalData.fromJson(json['rental_data']) : null;
  }
}

class WorkOrderUpdate {
  String? status;
  String? date;
  String? staffmemberName;
  String? createdAt;
  String? updatedAt;
  String? statusUpdatedBy;
  List<String>? workOrderUpdateImages;
  String? id;

  WorkOrderUpdate({
    this.status,
    this.date,
    this.staffmemberName,
    this.createdAt,
    this.updatedAt,
    this.statusUpdatedBy,
    this.workOrderUpdateImages,
    this.id,
  });

  WorkOrderUpdate.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    date = json['date'];
    staffmemberName = json['staffmember_name'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    statusUpdatedBy = json['statusUpdatedBy'];
    workOrderUpdateImages = json['workOrderUpdate_images']?.cast<String>();
    id = json['_id'];
  }
}

class UnitData {
  // Add unit data fields if needed
  UnitData.fromJson(Map<String, dynamic> json) {
    // Parse unit data fields
  }
}

class RentalData {
  String? id;
  String? rentalId;
  String? adminId;
  String? rentalownerId;
  String? processorId;
  String? propertyId;
  String? rentalAddress;
  bool? isRentOn;
  String? rentalCity;
  String? rentalState;
  String? rentalCountry;
  String? rentalPostcode;
  String? rentalImage;
  String? staffmemberId;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? v;

  RentalData({
    this.id,
    this.rentalId,
    this.adminId,
    this.rentalownerId,
    this.processorId,
    this.propertyId,
    this.rentalAddress,
    this.isRentOn,
    this.rentalCity,
    this.rentalState,
    this.rentalCountry,
    this.rentalPostcode,
    this.rentalImage,
    this.staffmemberId,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.v,
  });

  RentalData.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    rentalId = json['rental_id'];
    adminId = json['admin_id'];
    rentalownerId = json['rentalowner_id'];
    processorId = json['processor_id'];
    propertyId = json['property_id'];
    rentalAddress = json['rental_adress'];
    isRentOn = json['is_rent_on'];
    rentalCity = json['rental_city'];
    rentalState = json['rental_state'];
    rentalCountry = json['rental_country'];
    rentalPostcode = json['rental_postcode'];
    rentalImage = json['rental_image'];
    staffmemberId = json['staffmember_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    v = json['__v'];
  }
}
