
import 'package:flutter/material.dart';

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
  bool? tenantResidentStatus;
  TextEditingController? rentShareController;
  String? comments;
  EmergencyContact? emergencyContact;
  List<TenantLeaseData>? leaseData; // Changed to match JSON field name
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? v;
  String? rentalAddress;
  String? rentalUnit;
  String? rentshare;
  bool? enableoverrideFee;
  double? overRideFee;

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
    this.tenantResidentStatus,
    this.comments,
    this.rentshare,
    this.emergencyContact,
    this.tenant_residentStatus,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.v,
    this.rentalAddress,
    this.rentalUnit,
    this.rentShareController,
    this.leaseData,
    this.enableoverrideFee,
    this.overRideFee,
  }); // Added leaseData

  Tenant.fromJson(Map<String, dynamic> json) {
    tenantId = json['tenant_id'];
    tenantResidentStatus = json['tenant_residentStatus'];
    adminId = json['admin_id'];
    tenantFirstName = json['tenant_firstName'].toString();
    tenantLastName = json['tenant_lastName'].toString();
    tenantPhoneNumber = json['tenant_phoneNumber'].toString();
    tenantAlternativeNumber = json['tenant_alternativeNumber'].toString();
    tenantEmail = json['tenant_email'].toString();
    tenantAlternativeEmail = json['tenant_alternativeEmail'].toString();
    tenantPassword = json['tenant_password'];
    tenantBirthDate = json['tenant_birthDate'];
    taxPayerId = json['taxPayer_id'];
    comments = json['comments'];
    emergencyContact = json['emergency_contact'] != null
        ? EmergencyContact.fromJson(json['emergency_contact'])
        : null;
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    rentalAddress = json['rental_adress'] ?? '';

    rentalUnit = json['rental_unit'];
    overRideFee = json['override_fee'] != null
        ? double.tryParse(json['override_fee'].toString())
        : null;
    enableoverrideFee = json['enable_override_fee'];
    if (json['leaseData'] != null) {
      // Fixed the field name
      leaseData = <TenantLeaseData>[];
      json['leaseData'].forEach((v) {
        leaseData!.add(TenantLeaseData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['tenant_id'] = tenantId;
    data['admin_id'] = adminId;
    data['tenant_residentStatus'] = tenantResidentStatus;
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
    data['override_fee'] = overRideFee;
    data['enable_override_fee'] = enableoverrideFee;
    data['rental_unit'] = rentalUnit;
    if (leaseData != null) {
      data['leaseData'] =
          leaseData!.map((v) => v.toJson()).toList(); // Fixed the field name
    }
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
    name = json['name'] ?? "";
    relation = json['relation'] ?? "";
    email = json['email'] ?? "";
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

class TenantLeaseData {
  String? leaseId;
  String? startDate;
  String? endDate;
  String? leaseType;
  String? rentalId;
  String? rentalAdress;
  String? rentalownerId;
  String? unitId;
  String? rentalUnit;
  int? rentAmount;

  TenantLeaseData(
      {this.leaseId,
      this.startDate,
      this.endDate,
      this.leaseType,
      this.rentalId,
      this.rentalAdress,
      this.rentalownerId,
      this.unitId,
      this.rentalUnit,
      this.rentAmount});

  TenantLeaseData.fromJson(Map<String, dynamic> json) {
    leaseId = json['lease_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    leaseType = json['lease_type'];
    rentalId = json['rental_id'];
    rentalAdress = json['rental_adress'];
    rentalownerId = json['rentalowner_id'];
    unitId = json['unit_id'];
    rentalUnit = json['rental_unit'];
    rentAmount = json['rent_amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lease_id'] = leaseId;
    data['start_date'] = startDate;
    data['end_date'] = endDate;
    data['lease_type'] = leaseType;
    data['rental_id'] = rentalId;
    data['rental_adress'] = rentalAdress;
    data['rentalowner_id'] = rentalownerId;
    data['unit_id'] = unitId;
    data['rental_unit'] = rentalUnit;
    data['rent_amount'] = rentAmount;
    return data;
  }
}
