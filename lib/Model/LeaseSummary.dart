import 'package:three_zero_two_property/Model/tenants.dart';

class LeaseSummary {
  Data? data;
  String? message;

  LeaseSummary({this.data, this.message});

  LeaseSummary.fromJson(Map<String, dynamic> json) {
    data = json['data'] != null ? Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = message;
    return data;
  }
}

class Data {
  String? leaseId;
  List<String>? tenantId;
  String? adminId;
  String? rentalId;
  String? unitId;
  String? leaseType;
  String? startDate;
  String? endDate;
  String? moveout_date;
  String? moveout_notice_given_date;

  List<Tenant>? tenantData;
  String? rentalAddress;
  String? rentalImage;
  String? rentalCity;
  String? rentalCountry;
  String? rentalPostcode;
  String? propertySubType;
  String? rentalUnit;
  String? rentalUnitAddress;
  String? rentalSqft;
  String? rentalOwnerName;
  String? rentalOwnerCompanyName;
  String? rentalOwnerPrimaryEmail;
  String? rentalOwnerPhoneNumber;
  int? amount;
  String? date;
  List<RenewLeases>? renewLeases;
  Data({
    this.leaseId,
    this.tenantId,
    this.adminId,
    this.rentalId,
    this.unitId,
    this.leaseType,
    this.startDate,
    this.endDate,
    this.tenantData,
    this.rentalAddress,
    this.rentalImage,
    this.rentalCity,
    this.rentalCountry,
    this.rentalPostcode,
    this.propertySubType,
    this.rentalUnit,
    this.rentalUnitAddress,
    this.rentalSqft,
    this.rentalOwnerName,
    this.rentalOwnerCompanyName,
    this.rentalOwnerPrimaryEmail,
    this.rentalOwnerPhoneNumber,
    this.amount,
    this.date,
    this.moveout_date,
    this.moveout_notice_given_date,
    this.renewLeases
  });

  Data.fromJson(Map<String, dynamic> json) {
    leaseId = json['lease_id']; 
    tenantId =
        json['tenant_id'] != null ? List<String>.from(json['tenant_id']) : [];
    adminId = json['admin_id'];
    rentalId = json['rental_id'];
    unitId = json['unit_id'];
    leaseType = json['lease_type'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    tenantData = json['tenant_data'] != null
        ? (json['tenant_data'] as List).map((e) => Tenant.fromJson(e)).toList()
        : [];
    rentalAddress = json['rental_adress'];
    rentalImage = json['rental_image'];
    rentalCity = json['rental_city'];
    rentalCountry = json['rental_country'];
    rentalPostcode = json['rental_postcode'];
    propertySubType = json['propertysub_type'];
    rentalUnit = json['rental_unit'];
    rentalUnitAddress = json['rental_unit_adress'];
    rentalSqft = json['rental_sqft'];
    rentalOwnerName = json['rentalOwner_name'];
    rentalOwnerCompanyName = json['rentalOwner_companyName'];
    rentalOwnerPrimaryEmail = json['rentalOwner_primaryEmail'];
    rentalOwnerPhoneNumber = json['rentalOwner_phoneNumber'];
    moveout_notice_given_date = json['moveout_notice_given_date'];
    moveout_date = json['moveout_date'];

    amount = json['amount'];
    date = json['date'];
    if (json['renewLeases'] != null) {
      renewLeases = <RenewLeases>[];
      json['renewLeases'].forEach((v) {
        renewLeases!.add(new RenewLeases.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['lease_id'] = leaseId;
    data['tenant_id'] = tenantId;
    data['admin_id'] = adminId;
    data['rental_id'] = rentalId;
    data['unit_id'] = unitId;
    data['lease_type'] = leaseType;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    if (tenantData != null) {
      data['tenant_data'] = tenantData!.map((v) => v.toJson()).toList();
    }
    data['rental_address'] = rentalAddress;
    data['rental_image'] = rentalImage;
    data['rental_city'] = rentalCity;
    data['rental_country'] = rentalCountry;
    data['rental_postcode'] = rentalPostcode;
    data['propertysub_type'] = propertySubType;
    data['rental_unit'] = rentalUnit;
    data['rental_unit_address'] = rentalUnitAddress;
    data['rental_sqft'] = rentalSqft;
    data['rentalOwner_name'] = rentalOwnerName;
    data['rentalOwner_companyName'] = rentalOwnerCompanyName;
    data['rentalOwner_primaryEmail'] = rentalOwnerPrimaryEmail;
    data['rentalOwner_phoneNumber'] = rentalOwnerPhoneNumber;
    data['amount'] = amount;
    data['date'] = date;
    if (this.renewLeases != null) {
      data['renewLeases'] = this.renewLeases!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class LeaseTenant {
  String leaseId;
  String tenantId;
  String adminId;
  String rentalId;
  String? moveoutNoticeGivenDate;
  String? moveoutDate;
  String unitId;
  String leaseType;
  String startDate;
  String endDate;
  String tenantFirstName;
  String tenantLastName;
  String tenantPhoneNumber;
  String tenantEmail;
  String rentalAddress;
  String rentalUnit;

  LeaseTenant({
    required this.leaseId,
    required this.tenantId,
    required this.adminId,
    required this.rentalId,
    this.moveoutNoticeGivenDate,
    this.moveoutDate,
    required this.unitId,
    required this.leaseType,
    required this.startDate,
    required this.endDate,
    required this.tenantFirstName,
    required this.tenantLastName,
    required this.tenantPhoneNumber,
    required this.tenantEmail,
    required this.rentalAddress,
    required this.rentalUnit,
  });

  factory LeaseTenant.fromJson(Map<String, dynamic> json) {
    print(json);
    return LeaseTenant(
      leaseId: json['lease_id'],
      tenantId: json['tenant_id'],
      adminId: json['admin_id'],
      rentalId: json['rental_id'],
      moveoutNoticeGivenDate: json['moveout_notice_given_date'] ?? "",
      moveoutDate: json['moveout_date'] ?? "",
      unitId: json['unit_id']??"",
      leaseType: json['lease_type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      tenantFirstName: json['tenant_firstName'],
      tenantLastName: json['tenant_lastName'],
      tenantPhoneNumber: json['tenant_phoneNumber'],
      tenantEmail: json['tenant_email'],
      rentalAddress: json['rental_adress'],
      rentalUnit: json['rental_unit'] ??"",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lease_id': leaseId,
      'tenant_id': tenantId,
      'admin_id': adminId,
      'rental_id': rentalId,
      'moveout_notice_given_date': moveoutNoticeGivenDate,
      'moveout_date': moveoutDate,
      'unit_id': unitId,
      'lease_type': leaseType,
      'start_date': startDate,
      'end_date': endDate,
      'tenant_firstName': tenantFirstName,
      'tenant_lastName': tenantLastName,
      'tenant_phoneNumber': tenantPhoneNumber,
      'tenant_email': tenantEmail,
      'rental_adress': rentalAddress,
      'rental_unit': rentalUnit,
    };
  }
}
class RenewLeases {
  String? sId;
  String? renewId;
  String? leaseId;
  String? adminId;
  String? leaseType;
  String? startDate;
  String? endDate;
  int? amount;
  int? leaseAmount;
  bool? isDelete;
  String? createdAt;
  String? updatedAt;
  int? iV;

  RenewLeases(
      {this.sId,
        this.renewId,
        this.leaseId,
        this.adminId,
        this.leaseType,
        this.startDate,
        this.endDate,
        this.amount,
        this.leaseAmount,
        this.isDelete,
        this.createdAt,
        this.updatedAt,
        this.iV});

  RenewLeases.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    renewId = json['renew_id'];
    leaseId = json['lease_id'];
    adminId = json['admin_id'];
    leaseType = json['lease_type'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    amount = json['amount'];
    leaseAmount = json['lease_amount'];
    isDelete = json['is_delete'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['renew_id'] = this.renewId;
    data['lease_id'] = this.leaseId;
    data['admin_id'] = this.adminId;
    data['lease_type'] = this.leaseType;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['amount'] = this.amount;
    data['lease_amount'] = this.leaseAmount;
    data['is_delete'] = this.isDelete;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}