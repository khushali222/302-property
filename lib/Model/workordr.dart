// class WorkOrderItem {
//    WorkOrderData? workOrderData;
//    RentalAddress? rentalAddress;
//    RentalUnit? rentalUnit;
//    StaffMember? staffMember;
//
//   WorkOrderItem({
//      this.workOrderData,
//     this.rentalAddress,
//     this.rentalUnit,
//     this.staffMember,
//   });
//
//   factory WorkOrderItem.fromJson(Map<String, dynamic> json) {
//     return WorkOrderItem(
//       workOrderData: WorkOrderData.fromJson(json['workOrderData']??""),
//       rentalAddress: json['rentalAddress'] != null
//           ? RentalAddress.fromJson(json['rentalAddress'])
//           : null,
//       rentalUnit: json['rentalUnit'] != null
//           ? RentalUnit.fromJson(json['rentalUnit'])
//           : null,
//       staffMember: json['staffMember'] != null
//           ? StaffMember.fromJson(json['staffMember'])
//           : null,
//     );
//   }
// }
//
// class WorkOrderData {
//   String? id;
//   String? workOrderId;
//   String? adminId;
//   String? rentalId;
//   String? unitId;
//   String? vendorId;
//   String? tenantId;
//   String? workSubject;
//   String? workCategory;
//   bool? entryAllowed;
//   String? workPerformed;
//   List<String>? workOrderImages;
//   String? vendorNotes;
//   String? priority;
//   String? workChargeTo;
//   String? status;
//   String? date;
//   List<WorkOrderUpdate>? workOrderUpdates;
//   bool? isBillable;
//   String? createdAt;
//   String? updatedAt;
//   bool? isDelete;
//   int? v;
//
//   WorkOrderData({
//     this.id,
//     this.workOrderId,
//     this.adminId,
//     this.rentalId,
//     this.unitId,
//     this.vendorId,
//     this.tenantId,
//     this.workSubject,
//     this.workCategory,
//     this.entryAllowed,
//     this.workPerformed,
//     this.workOrderImages,
//     this.vendorNotes,
//     this.priority,
//     this.workChargeTo,
//     this.status,
//     this.date,
//     this.workOrderUpdates,
//     this.isBillable,
//     this.createdAt,
//     this.updatedAt,
//     this.isDelete,
//     this.v,
//   });
//
//   factory WorkOrderData.fromJson(Map<String, dynamic> json) {
//     var list = json['workOrder_images'] as List;
//     List<String> workOrderImagesList = list.map((i) => i.toString()).toList();
//
//     var updatesList = json['workorder_updates'] as List;
//     List<WorkOrderUpdate> workOrderUpdatesList = updatesList.map((i) => WorkOrderUpdate.fromJson(i)).toList();
//
//     return WorkOrderData(
//       id: json['_id'],
//       workOrderId: json['workOrder_id'],
//       adminId: json['admin_id'],
//       rentalId: json['rental_id'],
//       unitId: json['unit_id'],
//       vendorId: json['vendor_id'],
//       tenantId: json['tenant_id'],
//       workSubject: json['work_subject'],
//       workCategory: json['work_category'],
//       entryAllowed: json['entry_allowed'],
//       workPerformed: json['work_performed'],
//       workOrderImages: workOrderImagesList,
//       vendorNotes: json['vendor_notes'],
//       priority: json['priority'],
//       workChargeTo: json['work_charge_to'],
//       status: json['status'],
//       date: json['date'],
//       workOrderUpdates: workOrderUpdatesList,
//       isBillable: json['is_billable'],
//       createdAt: json['createdAt'],
//       updatedAt: json['updatedAt'],
//       isDelete: json['is_delete'],
//       v: json['__v'],
//     );
//   }
// }
//
// class WorkOrderUpdate {
//   String? status;
//   String? date;
//   String? createdAt;
//   String? id;
//
//   WorkOrderUpdate({
//     this.status,
//     this.date,
//     this.createdAt,
//     this.id,
//   });
//
//   factory WorkOrderUpdate.fromJson(Map<String, dynamic> json) {
//     return WorkOrderUpdate(
//       status: json['status'],
//       date: json['date'],
//       createdAt: json['createdAt'],
//       id: json['_id'],
//     );
//   }
// }
//
//
//
// class RentalAddress {
//   final String id;
//   final String rentalId;
//   final String adminId;
//   final String rentalOwnerId;
//   final String propertyId;
//   final String rentalAddress;
//   final bool isRentOn;
//   final String rentalCity;
//   final String rentalState;
//   final String rentalCountry;
//   final String rentalPostcode;
//   final String rentalImage;
//   final String staffMemberId;
//   final String createdAt;
//   final String updatedAt;
//   final bool isDelete;
//
//   RentalAddress({
//     required this.id,
//     required this.rentalId,
//     required this.adminId,
//     required this.rentalOwnerId,
//     required this.propertyId,
//     required this.rentalAddress,
//     required this.isRentOn,
//     required this.rentalCity,
//     required this.rentalState,
//     required this.rentalCountry,
//     required this.rentalPostcode,
//     required this.rentalImage,
//     required this.staffMemberId,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.isDelete,
//   });
//
//   factory RentalAddress.fromJson(Map<String, dynamic> json) {
//     return RentalAddress(
//       id: json['_id'],
//       rentalId: json['rental_id'],
//       adminId: json['admin_id'],
//       rentalOwnerId: json['rentalowner_id'],
//       propertyId: json['property_id'],
//       rentalAddress: json['rental_adress'],
//       isRentOn: json['is_rent_on'],
//       rentalCity: json['rental_city'],
//       rentalState: json['rental_state'],
//       rentalCountry: json['rental_country'],
//       rentalPostcode: json['rental_postcode'],
//       rentalImage: json['rental_image'],
//       staffMemberId: json['staffmember_id'],
//       createdAt: json['createdAt'],
//       updatedAt: json['updatedAt'],
//       isDelete: json['is_delete'],
//     );
//   }
// }
//
// class RentalUnit {
//   final String id;
//   final String unitId;
//   final String rentalUnit;
//   final String rentalId;
//   final String rentalUnitAddress;
//   final String rentalSqft;
//   final String? rentalBath;
//   final String? rentalBed;
//   final List<String>? rentalImages;
//   final String createdAt;
//   final String updatedAt;
//   final bool isDelete;
//
//   RentalUnit({
//     required this.id,
//     required this.unitId,
//     required this.rentalUnit,
//     required this.rentalId,
//     required this.rentalUnitAddress,
//     required this.rentalSqft,
//     this.rentalBath,
//     this.rentalBed,
//     this.rentalImages,
//     required this.createdAt,
//     required this.updatedAt,
//     required this.isDelete,
//   });
//
//   factory RentalUnit.fromJson(Map<String, dynamic> json) {
//     return RentalUnit(
//       id: json['_id'],
//       unitId: json['unit_id'],
//       rentalUnit: json['rental_unit'],
//       rentalId: json['rental_id'],
//       rentalUnitAddress: json['rental_unit_adress'],
//       rentalSqft: json['rental_sqft'],
//       rentalBath: json['rental_bath'],
//       rentalBed: json['rental_bed'],
//       rentalImages: json['rental_images'] != null
//           ? List<String>.from(json['rental_images'])
//           : null,
//       createdAt: json['createdAt'],
//       updatedAt: json['updatedAt'],
//       isDelete: json['is_delete'],
//     );
//   }
// }
//
// class StaffMember {
//   final String id;
//   final String name;
//   final String email;
//   final String phone;
//   // Add other fields as needed
//
//   StaffMember({
//     required this.id,
//     required this.name,
//     required this.email,
//     required this.phone,
//   });
//
//   factory StaffMember.fromJson(Map<String, dynamic> json) {
//     return StaffMember(
//       id: json['_id'],
//       name: json['name'],
//       email: json['email'],
//       phone: json['phone'],
//       // Map other fields as needed
//     );
//   }
// }
//
//
//
class WorkOrderItem {
  List<Data>? data;

  WorkOrderItem({this.data});

  WorkOrderItem.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  WorkOrderData? workOrderData;
  RentalAddress? rentalAddress;
  RentalUnit? rentalUnit;
  StaffMember? staffMember;

  Data({this.workOrderData, this.rentalAddress, this.rentalUnit, this.staffMember});

  Data.fromJson(Map<String, dynamic> json) {

    workOrderData = json['workOrderData'] != null
        ? WorkOrderData.fromJson(json['workOrderData'])
        : null;
    rentalAddress = json['rentalAddress'] != null
        ? RentalAddress.fromJson(json['rentalAddress'])
        : null;
    rentalUnit = json['rentalUnit'] != null
        ? RentalUnit.fromJson(json['rentalUnit'])
        : null;
    staffMember = json['staffMember'] != null
        ? StaffMember.fromJson(json['staffMember'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.workOrderData != null) {
      data['workOrderData'] = this.workOrderData!.toJson();
    }
    if (this.rentalAddress != null) {
      data['rentalAddress'] = this.rentalAddress!.toJson();
    }
    if (this.rentalUnit != null) {
      data['rentalUnit'] = this.rentalUnit!.toJson();
    }
    if (this.staffMember != null) {
      data['staffMember'] = this.staffMember!.toJson();
    }
    return data;
  }
}

class WorkOrderData {
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
  String? staffmemberId;

  WorkOrderData(
      {this.sId,
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
        this.staffmemberId});

  WorkOrderData.fromJson(Map<String, dynamic> json) {

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
    workOrderImages = json['workOrder_images']?.cast<String>();
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
    iV = json['__v'] != null ? int.tryParse(json['__v'].toString()) : null;
    staffmemberId = json['staffmember_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.sId;
    data['workOrder_id'] = this.workOrderId;
    data['admin_id'] = this.adminId;
    data['rental_id'] = this.rentalId;
    data['unit_id'] = this.unitId;
    data['vendor_id'] = this.vendorId;
    data['tenant_id'] = this.tenantId;
    data['work_subject'] = this.workSubject;
    data['work_category'] = this.workCategory;
    data['entry_allowed'] = this.entryAllowed;
    data['work_performed'] = this.workPerformed;
    data['workOrder_images'] = this.workOrderImages;
    data['vendor_notes'] = this.vendorNotes;
    data['priority'] = this.priority;
    data['work_charge_to'] = this.workChargeTo;
    data['status'] = this.status;
    data['date'] = this.date;
    if (this.workorderUpdates != null) {
      data['workorder_updates'] =
          this.workorderUpdates!.map((v) => v.toJson()).toList();
    }
    data['is_billable'] = this.isBillable;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    data['__v'] = this.iV;
    data['staffmember_id'] = this.staffmemberId;
    return data;
  }
}

class WorkorderUpdates {
  String? status;
  String? date;
  String? createdAt;
  String? sId;
  String? staffmemberName;
  String? statusUpdatedBy;
  String? message;
  String? updatedAt;
  String? staffmemberId;
  UpdatedBy? updatedBy;

  WorkorderUpdates(
      {this.status,
        this.date,
        this.createdAt,
        this.sId,
        this.staffmemberName,
        this.statusUpdatedBy,
        this.message,
        this.updatedAt,
        this.staffmemberId,
        this.updatedBy});

  WorkorderUpdates.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    date = json['date'];
    createdAt = json['createdAt'];
    sId = json['_id'];
    staffmemberName = json['staffmember_name'];
    statusUpdatedBy = json['statusUpdatedBy'];
    message = json['message'];
    updatedAt = json['updatedAt'];
    staffmemberId = json['staffmember_id'];
    updatedBy = json['updated_by'] != null
        ? UpdatedBy.fromJson(json['updated_by'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = this.status;
    data['date'] = this.date;
    data['createdAt'] = this.createdAt;
    data['_id'] = this.sId;
    data['staffmember_name'] = this.staffmemberName;
    data['statusUpdatedBy'] = this.statusUpdatedBy;
    data['message'] = this.message;
    data['updatedAt'] = this.updatedAt;
    data['staffmember_id'] = this.staffmemberId;
    if (this.updatedBy != null) {
      data['updated_by'] = this.updatedBy!.toJson();
    }
    return data;
  }
}

class UpdatedBy {
  String? adminId;

  UpdatedBy({this.adminId});

  UpdatedBy.fromJson(Map<String, dynamic> json) {
    adminId = json['admin_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['admin_id'] = this.adminId;
    return data;
  }
}

class RentalAddress {
  String? sId;
  String? rentalId;
  String? adminId;
  String? rentalownerId;
  String? propertyId;
  String? rentalAdress;
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
  int? iV;
  String? processorId;

  RentalAddress(
      {this.sId,
        this.rentalId,
        this.adminId,
        this.rentalownerId,
        this.propertyId,
        this.rentalAdress,
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
        this.iV,
        this.processorId});

  RentalAddress.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    rentalId = json['rental_id'];
    adminId = json['admin_id'];
    rentalownerId = json['rentalowner_id'];
    propertyId = json['property_id'];
    rentalAdress = json['rental_adress'];
    isRentOn = json['isRentOn'];
    rentalCity = json['rentalCity'];
    rentalState = json['rentalState'];
    rentalCountry = json['rentalCountry'];
    rentalPostcode = json['rentalPostcode'];
    rentalImage = json['rentalImage'];
    staffmemberId = json['staffmember_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    iV = json['__v'] != null ? int.tryParse(json['__v'].toString()) : null;
    processorId = json['processor_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.sId;
    data['rental_id'] = this.rentalId;
    data['admin_id'] = this.adminId;
    data['rentalowner_id'] = this.rentalownerId;
    data['property_id'] = this.propertyId;
    data['rental_adress'] = this.rentalAdress;
    data['isRentOn'] = this.isRentOn;
    data['rentalCity'] = this.rentalCity;
    data['rentalState'] = this.rentalState;
    data['rentalCountry'] = this.rentalCountry;
    data['rentalPostcode'] = this.rentalPostcode;
    data['rentalImage'] = this.rentalImage;
    data['staffmember_id'] = this.staffmemberId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    data['__v'] = this.iV;
    data['processor_id'] = this.processorId;
    return data;
  }
}

class RentalUnit {
  String? sId;
  String? rentalId;
  String? rentalownerId;
  String? propertyId;
  String? unitName;
  String? unitNumber;
  String? unitFloor;
  bool? isAvailable;
  String? unitSize;
  String? unitType;
  String? unitDescription;
  String? unitPrice;
  String? unitImage;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? iV;
  String? processorId;

  RentalUnit(
      {this.sId,
        this.rentalId,
        this.rentalownerId,
        this.propertyId,
        this.unitName,
        this.unitNumber,
        this.unitFloor,
        this.isAvailable,
        this.unitSize,
        this.unitType,
        this.unitDescription,
        this.unitPrice,
        this.unitImage,
        this.createdAt,
        this.updatedAt,
        this.isDelete,
        this.iV,
        this.processorId});

  RentalUnit.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    rentalId = json['rental_id'];
    rentalownerId = json['rentalowner_id'];
    propertyId = json['property_id'];
    unitName = json['unitName'];
    unitNumber = json['unitNumber'];
    unitFloor = json['unitFloor'];
    isAvailable = json['isAvailable'];
    unitSize = json['unitSize'];
    unitType = json['unitType'];
    unitDescription = json['unitDescription'];
    unitPrice = json['unitPrice'];
    unitImage = json['unitImage'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    iV = json['__v'] != null ? int.tryParse(json['__v'].toString()) : null;
    processorId = json['processor_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.sId;
    data['rental_id'] = this.rentalId;
    data['rentalowner_id'] = this.rentalownerId;
    data['property_id'] = this.propertyId;
    data['unitName'] = this.unitName;
    data['unitNumber'] = this.unitNumber;
    data['unitFloor'] = this.unitFloor;
    data['isAvailable'] = this.isAvailable;
    data['unitSize'] = this.unitSize;
    data['unitType'] = this.unitType;
    data['unitDescription'] = this.unitDescription;
    data['unitPrice'] = this.unitPrice;
    data['unitImage'] = this.unitImage;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    data['__v'] = this.iV;
    data['processor_id'] = this.processorId;
    return data;
  }
}

class StaffMember {
  String? sId;
  String? staffmemberName;
  String? staffmemberEmail;
  String? staffmemberPhoneNumber; // Change this to int if appropriate
  String? staffmemberRole;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? iV;

  StaffMember(
      {this.sId,
        this.staffmemberName,
        this.staffmemberEmail,
        this.staffmemberPhoneNumber,
        this.staffmemberRole,
        this.createdAt,
        this.updatedAt,
        this.isDelete,
        this.iV});

  StaffMember.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    staffmemberName = json['staffmember_name']  != null ?json['staffmember_name'].toString():null;
    staffmemberEmail = json['staffmember_email'];
    staffmemberPhoneNumber = json['staffmember_phoneNumber'] != null
        ? json['staffmember_phoneNumber'].toString()
        : null;
    staffmemberRole = json['staffmember_role'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    iV = json['__v'] != null ? int.tryParse(json['__v'].toString()) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.sId;
    data['staffmember_name'] = this.staffmemberName;
    data['staffmember_email'] = this.staffmemberEmail;
    data['staffmember_phoneNumber'] = this.staffmemberPhoneNumber;
    data['staffmember_role'] = this.staffmemberRole;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    data['__v'] = this.iV;
    return data;
  }
}

