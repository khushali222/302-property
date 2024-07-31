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
    amount = json['amount'];
    date = json['date'];
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
    return data;
  }
}
