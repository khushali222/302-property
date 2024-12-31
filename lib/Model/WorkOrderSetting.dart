class WorkOrderSetting {
  int? statusCode;
  String? message;
  Data? data;

  WorkOrderSetting({this.statusCode, this.message, this.data});

  WorkOrderSetting.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  WorkDefaults? workDefaults;
  StaffMember? staffMember;
  Vendor? vendor;

  Data({this.workDefaults, this.staffMember, this.vendor});

  Data.fromJson(Map<String, dynamic> json) {
    workDefaults = json['workDefaults'] != null
        ? new WorkDefaults.fromJson(json['workDefaults'])
        : null;
    staffMember = json['staffMember'] != null
        ? new StaffMember.fromJson(json['staffMember'])
        : null;
    vendor =
    json['vendor'] != null ? new Vendor.fromJson(json['vendor']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.workDefaults != null) {
      data['workDefaults'] = this.workDefaults!.toJson();
    }
    if (this.staffMember != null) {
      data['staffMember'] = this.staffMember!.toJson();
    }
    if (this.vendor != null) {
      data['vendor'] = this.vendor!.toJson();
    }
    return data;
  }
}

class WorkDefaults {
  String? sId;
  String? adminId;
  bool? entryAllowed;
  String? staffmemberId;
  String? vendorId;
  String? category;
  bool? isDelete;
  String? createdAt;
  String? updatedAt;


  WorkDefaults(
      {this.sId,
        this.adminId,
        this.entryAllowed,
        this.staffmemberId,
        this.vendorId,
        this.category,
        this.isDelete,
        this.createdAt,
        this.updatedAt,
        });

  WorkDefaults.fromJson(Map<String, dynamic> json) {
    print(json['staffmember_id']);
    sId = json['_id'];
    adminId = json['admin_id'];
    entryAllowed = json['entry_allowed'];
    staffmemberId = json['staffmember_id'];
    vendorId = json['vendor_id'];
    category = json['category'];
    isDelete = json['is_delete'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['admin_id'] = this.adminId;
    data['entry_allowed'] = this.entryAllowed;
    data['staffmember_id'] = this.staffmemberId;
    data['vendor_id'] = this.vendorId;
    data['category'] = this.category;
    data['is_delete'] = this.isDelete;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;

    return data;
  }
}

class StaffMember {
  String? sId;
  String? adminId;
  String? staffmemberId;
  String? staffmemberName;
  String? staffmemberDesignation;
  String? staffmemberPhoneNumber;
  String? staffmemberEmail;
  String? staffmemberPassword;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;


  StaffMember(
      {this.sId,
        this.adminId,
        this.staffmemberId,
        this.staffmemberName,
        this.staffmemberDesignation,
        this.staffmemberPhoneNumber,
        this.staffmemberEmail,
        this.staffmemberPassword,
        this.createdAt,
        this.updatedAt,
        this.isDelete,
        });

  StaffMember.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    adminId = json['admin_id'];
    staffmemberId = json['staffmember_id'];
    staffmemberName = json['staffmember_name'];
    staffmemberDesignation = json['staffmember_designation'];
    staffmemberPhoneNumber = json['staffmember_phoneNumber'];
    staffmemberEmail = json['staffmember_email'];
    staffmemberPassword = json['staffmember_password'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['admin_id'] = this.adminId;
    data['staffmember_id'] = this.staffmemberId;
    data['staffmember_name'] = this.staffmemberName;
    data['staffmember_designation'] = this.staffmemberDesignation;
    data['staffmember_phoneNumber'] = this.staffmemberPhoneNumber;
    data['staffmember_email'] = this.staffmemberEmail;
    data['staffmember_password'] = this.staffmemberPassword;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;

    return data;
  }
}

class Vendor {
  String? sId;
  String? vendorId;
  String? adminId;
  String? vendorName;
  String? vendorPhoneNumber;
  String? vendorEmail;
  String? vendorPassword;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;


  Vendor(
      {this.sId,
        this.vendorId,
        this.adminId,
        this.vendorName,
        this.vendorPhoneNumber,
        this.vendorEmail,
        this.vendorPassword,
        this.createdAt,
        this.updatedAt,
        this.isDelete,
        });

  Vendor.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    vendorId = json['vendor_id'];
    adminId = json['admin_id'];
    vendorName = json['vendor_name'];
    vendorPhoneNumber = json['vendor_phoneNumber'];
    vendorEmail = json['vendor_email'];
    vendorPassword = json['vendor_password'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['vendor_id'] = this.vendorId;
    data['admin_id'] = this.adminId;
    data['vendor_name'] = this.vendorName;
    data['vendor_phoneNumber'] = this.vendorPhoneNumber;
    data['vendor_email'] = this.vendorEmail;
    data['vendor_password'] = this.vendorPassword;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;

    return data;
  }
}
