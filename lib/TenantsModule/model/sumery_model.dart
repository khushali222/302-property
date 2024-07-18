class summery_property {
  String? leaseId;
  List<String>? tenantId;
  String? adminId;
  String? rentalId;
  String? unitId;
  String? leaseType;
  String? startDate;
  String? endDate;
  List<TenantData>? tenantData;
  String? rentalAdress;
  String? rentalImage;
  String? rentalCity;
  String? rentalCountry;
  String? rentalPostcode;
  String? propertysubType;
  String? rentalUnit;
  String? rentalUnitAdress;
  String? rentalSqft;
  String? rentalOwnerName;
  String? rentalOwnerCompanyName;
  String? rentalOwnerPrimaryEmail;
  String? rentalOwnerPhoneNumber;
  String? staffmember_name;
  String? rental_bed;
  String? rental_bath;
  int? amount;
  String? date;

  summery_property(
      {this.leaseId,
        this.tenantId,
        this.adminId,
        this.rentalId,
        this.unitId,
        this.leaseType,
        this.startDate,
        this.endDate,
        this.tenantData,
        this.rentalAdress,
        this.rentalImage,
        this.rentalCity,
        this.rentalCountry,
        this.rentalPostcode,
        this.propertysubType,
        this.rentalUnit,
        this.rentalUnitAdress,
        this.rentalSqft,
        this.rentalOwnerName,
        this.rentalOwnerCompanyName,
        this.rentalOwnerPrimaryEmail,
        this.rentalOwnerPhoneNumber,
        this.amount,
        this.staffmember_name,
        this.rental_bath,
        this.rental_bed,
        this.date});

  summery_property.fromJson(Map<String, dynamic> json) {
    leaseId = json['lease_id'];
    tenantId = json['tenant_id'].cast<String>();
    adminId = json['admin_id'];
    rentalId = json['rental_id'];
    unitId = json['unit_id'];
    leaseType = json['lease_type'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    if (json['tenant_data'] != null) {
      tenantData = <TenantData>[];
      json['tenant_data'].forEach((v) {
        tenantData!.add(new TenantData.fromJson(v));
      });
    }
    rentalAdress = json['rental_adress'];
    rentalImage = json['rental_image'];
    rentalCity = json['rental_city'];
    rentalCountry = json['rental_country'];
    rentalPostcode = json['rental_postcode'];
    propertysubType = json['propertysub_type'];
    rentalUnit = json['rental_unit']??"N/A";
    rentalUnitAdress = json['rental_unit_adress']??"N/A";
    rentalSqft = json['rental_sqft']??"N/A";
    rentalOwnerName = json['rentalOwner_name'];
    rentalOwnerCompanyName = json['rentalOwner_companyName'];
    rentalOwnerPrimaryEmail = json['rentalOwner_primaryEmail'];
    rentalOwnerPhoneNumber = json['rentalOwner_phoneNumber'];
    amount = json['amount'];
    staffmember_name = json['staffmember_name'] ?? "N/A";
    rental_bed = json['rental_bed'] ?? "N/A";
    rental_bath = json['rental_bath'] ?? "N/A";
    date = json['date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lease_id'] = this.leaseId;
    data['tenant_id'] = this.tenantId;
    data['admin_id'] = this.adminId;
    data['rental_id'] = this.rentalId;
    data['unit_id'] = this.unitId;
    data['lease_type'] = this.leaseType;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    if (this.tenantData != null) {
      data['tenant_data'] = this.tenantData!.map((v) => v.toJson()).toList();
    }
    data['rental_adress'] = this.rentalAdress;
    data['rental_image'] = this.rentalImage;
    data['rental_city'] = this.rentalCity;
    data['rental_country'] = this.rentalCountry;
    data['rental_postcode'] = this.rentalPostcode;
    data['propertysub_type'] = this.propertysubType;
    data['rental_unit'] = this.rentalUnit;
    data['rental_unit_adress'] = this.rentalUnitAdress;
    data['rental_sqft'] = this.rentalSqft;
    data['rentalOwner_name'] = this.rentalOwnerName;
    data['rentalOwner_companyName'] = this.rentalOwnerCompanyName;
    data['rentalOwner_primaryEmail'] = this.rentalOwnerPrimaryEmail;
    data['rentalOwner_phoneNumber'] = this.rentalOwnerPhoneNumber;
    data['amount'] = this.amount;
    data['date'] = this.date;
    return data;
  }
}

class TenantData {
  EmergencyContact? emergencyContact;
  String? sId;
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
  String? taxPayerId;
  String? comments;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? iV;
  String? percentage;

  TenantData(
      {this.emergencyContact,
        this.sId,
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
        this.createdAt,
        this.updatedAt,
        this.isDelete,
        this.iV,
        this.percentage});

  TenantData.fromJson(Map<String, dynamic> json) {
    emergencyContact = json['emergency_contact'] != null
        ? new EmergencyContact.fromJson(json['emergency_contact'])
        : null;
    sId = json['_id'];
    tenantId = json['tenant_id'];
    adminId = json['admin_id'];
    tenantFirstName = json['tenant_firstName'];
    tenantLastName = json['tenant_lastName'];
    tenantPhoneNumber = json['tenant_phoneNumber'];
    tenantAlternativeNumber = json['tenant_alternativeNumber'];
    tenantEmail = json['tenant_email'];
    tenantAlternativeEmail = json['tenant_alternativeEmail'];
    tenantPassword = json['tenant_password'];
    tenantBirthDate = json['tenant_birthDate'];
    taxPayerId = json['taxPayer_id'];
    comments = json['comments'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    iV = json['__v'];
    percentage = json['percentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.emergencyContact != null) {
      data['emergency_contact'] = this.emergencyContact!.toJson();
    }
    data['_id'] = this.sId;
    data['tenant_id'] = this.tenantId;
    data['admin_id'] = this.adminId;
    data['tenant_firstName'] = this.tenantFirstName;
    data['tenant_lastName'] = this.tenantLastName;
    data['tenant_phoneNumber'] = this.tenantPhoneNumber;
    data['tenant_alternativeNumber'] = this.tenantAlternativeNumber;
    data['tenant_email'] = this.tenantEmail;
    data['tenant_alternativeEmail'] = this.tenantAlternativeEmail;
    data['tenant_password'] = this.tenantPassword;
    data['tenant_birthDate'] = this.tenantBirthDate;
    data['taxPayer_id'] = this.taxPayerId;
    data['comments'] = this.comments;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    data['__v'] = this.iV;
    data['percentage'] = this.percentage;
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
    name = json['name'];
    relation = json['relation'];
    email = json['email'];
    phoneNumber = json['phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['relation'] = this.relation;
    data['email'] = this.email;
    data['phoneNumber'] = this.phoneNumber;
    return data;
  }
}
