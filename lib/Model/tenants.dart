class TenantResponse {
  int? statusCode;
  List<Tenant>? data;

  TenantResponse({this.statusCode, this.data});

  TenantResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <Tenant>[];
      json['data'].forEach((v) {
        data!.add(Tenant.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tenant {
  String? id;
  String? tenantId;
  String? adminId;
  String? tenantFirstName;
  String? tenantLastName;
  String? tenantPhoneNumber;
  String? tenantAlternativeNumber;
  String? tenantEmail;
  String? tenantAlternativeEmail;
  String? tenantPassword;
  String? tenantBirthDate;
  bool? tenant_residentStatus;
  String? taxPayerId;
  String? comments;
  EmergencyContact? emergencyContact;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? v;
  String? rentalAddress;
  String? rentalUnit;
  String? rentshare;

  Tenant({
    this.id,
    this.tenantId,
    this.adminId,
    this.tenantFirstName,
    this.tenantLastName,
    this.tenantPhoneNumber,
    this.tenantAlternativeNumber,
    this.tenantEmail,
    this.tenantAlternativeEmail,
    this.tenantPassword,
    this.tenantBirthDate,
    this.taxPayerId,
    this.comments,
    this.emergencyContact,
    this.tenant_residentStatus,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.v,
    this.rentalAddress,
    this.rentalUnit,
    this.rentshare
  });

  Tenant.fromJson(Map<String, dynamic> json) {
    id = json['_id']??"";
    tenantId = json['tenant_id']??"";
    adminId = json['admin_id']??"";
    tenantFirstName = json['tenant_firstName']??"";
    tenantLastName = json['tenant_lastName']??"";
    tenantPhoneNumber = json['tenant_phoneNumber'].toString()??"";
    tenantAlternativeNumber = json['tenant_alternativeNumber'].toString()??"";
    tenantEmail = json['tenant_email']??"";
    tenant_residentStatus = json['tenant_residentStatus']??false;
    tenantAlternativeEmail = json['tenant_alternativeEmail']??"";
    tenantPassword = json['tenant_password']??"";
    tenantBirthDate = json['tenant_birthDate']??"";
    taxPayerId = json['taxPayer_id']??"";
    comments = json['comments']??"";
    emergencyContact = json['emergency_contact'] != null ? EmergencyContact.fromJson(json['emergency_contact']) : null;
    createdAt = json['createdAt']??"";
    updatedAt = json['updatedAt']??"";
    isDelete = json['is_delete']??"";
    v = json['__v']??"";
    rentalAddress = json['rental_adress']??"";
    rentalUnit = json['rental_unit']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['tenant_id'] = tenantId;
    data['admin_id'] = adminId;
    data['tenant_firstName'] = tenantFirstName;
    data['tenant_lastName'] = tenantLastName;
    data['tenant_phoneNumber'] = tenantPhoneNumber;
    data['tenant_alternativeNumber'] = tenantAlternativeNumber;
    data['tenant_email'] = tenantEmail;
    data['tenant_alternativeEmail'] = tenantAlternativeEmail;
    data['tenant_password'] = tenantPassword;
    data['tenant_birthDate'] = tenantBirthDate;
    data['taxPayer_id'] = taxPayerId;
    data['comments'] = comments;
    if (emergencyContact != null) {
      data['emergency_contact'] = emergencyContact!.toJson();
    }
    data['createdAt'] = updatedAt;
     data['updatedAt'] = createdAt;
    data['rental_adress'] = rentalAddress;
    data['rental_unit'] = rentalUnit;
    return data;
  }
}

class EmergencyContact {
  String? name;
  String? relation;
  String? email;
  String? phoneNumber;

  EmergencyContact({this.name, this.relation, this.email, this.phoneNumber});

  EmergencyContact.fromJson(Map<String, dynamic> json) {
    name = json['name']??"";
    relation = json['relation']??"";
    email = json['email']??"";
    phoneNumber = json['phoneNumber'].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['relation'] = relation;
    data['email'] = email;
    data['phoneNumber'] = phoneNumber;
    return data;
  }
}
