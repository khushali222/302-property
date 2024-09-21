import 'dart:convert';

// class ApiResponse {
//   final int statusCode;
//   final List<TenantData> data;
//   final int count;
//
//   ApiResponse({
//     required this.statusCode,
//     required this.data,
//     required this.count,
//   });
//
//   factory ApiResponse.fromJson(Map<String, dynamic> json) {
//     var dataList = json['data'] as List;
//     List<TenantData> dataObjects = dataList.map((item) => TenantData.fromJson(item)).toList();
//     return ApiResponse(
//       statusCode: json['statusCode'],
//       data: dataObjects,
//       count: json['count'],
//     );
//   }
// }

// class TenantData {
//    EmergencyContact? emergencyContact;
//    String? id;
//   // List<String>? tenantId;
//    String? adminId;
//    String? tenantFirstName;
//    String? tenantLastName;
//    String? tenantPhoneNumber;
//    String? tenantAlternativeNumber;
//    String? tenantEmail;
//    String? tenantAlternativeEmail;
//    String? tenantPassword;
//    String? tenantBirthDate;
//    String? taxPayerId;
//    String? comments;
//    String? createdAt;
//    String? updatedAt;
//    bool? isDelete;
//    int? v;
//    String? leaseId;
//    String? rentalId;
//    String? unitId;
//    String? leaseType;
//    String? startDate;
//    String? endDate;
//    double? leaseAmount;
//    List<dynamic>? uploadedFile;
//    List<Entry>? entry;
//    String? moveoutNoticeGivenDate;
//    String? moveoutDate;
//    List<dynamic>? moveoutTenant;
//    String? rentalOwnerId;
//    String? processorId;
//    String? propertyId;
//    String? rentalAddress;
//    bool? isRentOn;
//    String? rentalCity;
//    String? rentalState;
//    String? rentalCountry;
//    String? rentalPostcode;
//    String? rentalImage;
//    String? staffMemberId;
//    String? rentalUnit;
//    String? rentalUnitAddress;
//    String? rentalSqft;
//    String? rentalBath;
//    String? rentalBed;
//    List<dynamic>? rentalImages;
//
//   TenantData({
//      this.emergencyContact,
//      this.id,
//    //  this.tenantId,
//      this.adminId,
//      this.tenantFirstName,
//      this.tenantLastName,
//      this.tenantPhoneNumber,
//     this.tenantAlternativeNumber,
//      this.tenantEmail,
//     this.tenantAlternativeEmail,
//      this.tenantPassword,
//     this.tenantBirthDate,
//     this.taxPayerId,
//     this.comments,
//      this.createdAt,
//      this.updatedAt,
//      this.isDelete,
//      this.v,
//      this.leaseId,
//      this.rentalId,
//      this.unitId,
//      this.leaseType,
//      this.startDate,
//      this.endDate,
//     this.leaseAmount,
//      this.uploadedFile,
//      this.entry,
//     this.moveoutNoticeGivenDate,
//     this.moveoutDate,
//      this.moveoutTenant,
//      this.rentalOwnerId,
//      this.processorId,
//      this.propertyId,
//      this.rentalAddress,
//      this.isRentOn,
//      this.rentalCity,
//      this.rentalState,
//      this.rentalCountry,
//      this.rentalPostcode,
//      this.rentalImage,
//      this.staffMemberId,
//      this.rentalUnit,
//      this.rentalUnitAddress,
//      this.rentalSqft,
//      this.rentalBath,
//      this.rentalBed,
//      this.rentalImages,
//   });
//
//   factory TenantData.fromJson(Map<String, dynamic> json) {
//     var entryList = json['entry'] as List;
//     List<Entry> entryObjects = entryList.map((item) => Entry.fromJson(item)).toList();
//
//     return TenantData(
//       emergencyContact: EmergencyContact.fromJson(json['emergency_contact']),
//       id: json['_id']??"",
//    //   tenantId: List<String>.from(json['tenant_id']),
//       adminId: json['admin_id']??"",
//       tenantFirstName: json['tenant_firstName']??"",
//       tenantLastName: json['tenant_lastName']??"",
//       tenantPhoneNumber: json['tenant_phoneNumber']??"",
//       tenantAlternativeNumber: json['tenant_alternativeNumber']??"",
//       tenantEmail: json['tenant_email']??"",
//       tenantAlternativeEmail: json['tenant_alternativeEmail']??"",
//       tenantPassword: json['tenant_password']??"",
//       tenantBirthDate: json['tenant_birthDate']??"",
//       taxPayerId: json['taxPayer_id']??"",
//       comments: json['comments']??"",
//       createdAt: json['createdAt']??"",
//       updatedAt: json['updatedAt']??"",
//       isDelete: json['is_delete']??"",
//       v: json['__v']??"",
//       leaseId: json['lease_id']??"",
//       rentalId: json['rental_id']??"",
//       unitId: json['unit_id']??"",
//       leaseType: json['lease_type']??"",
//       startDate: json['start_date']??"",
//       endDate: json['end_date']??"",
//       leaseAmount: json['lease_amount']?.toDouble(),
//       uploadedFile: json['uploaded_file']??"",
//       entry: entryObjects,
//       moveoutNoticeGivenDate: json['moveout_notice_given_date']??"",
//       moveoutDate: json['moveout_date']??"",
//       moveoutTenant: json['moveout_tenant']??"",
//       rentalOwnerId: json['rentalowner_id']??"",
//       processorId: json['processor_id']??"",
//       propertyId: json['property_id']??"",
//       rentalAddress: json['rental_adress']??"",
//       isRentOn: json['is_rent_on']??"",
//       rentalCity: json['rental_city']??"",
//       rentalState: json['rental_state']??"",
//       rentalCountry: json['rental_country']??"",
//       rentalPostcode: json['rental_postcode']??"",
//       rentalImage: json['rental_image']??"",
//       staffMemberId: json['staffmember_id']??"",
//       rentalUnit: json['rental_unit']??"",
//       rentalUnitAddress: json['rental_unit_adress']??"",
//       rentalSqft: json['rental_sqft']??"",
//       rentalBath: json['rental_bath']??"",
//       rentalBed: json['rental_bed']??"",
//       rentalImages: json['rental_images']??"",
//     );
//   }
// }
//
// class EmergencyContact {
//    String? name;
//    String? relation;
//    String? email;
//    String? phoneNumber;
//
//   EmergencyContact({
//      this.name,
//      this.relation,
//      this.email,
//     this.phoneNumber,
//   });
//
//   factory EmergencyContact.fromJson(Map<String, dynamic> json) {
//     return EmergencyContact(
//       name: json['name'],
//       relation: json['relation'],
//       email: json['email'],
//       phoneNumber: json['phoneNumber'],
//     );
//   }
// }
//
// class Entry {
//    String? entryId;
//    String? date;
//    String? chargeType;
//    String? account;
//    String? rentCycle;
//    double? amount;
//    String? id;
//
//   Entry({
//      this.entryId,
//      this.date,
//      this.chargeType,
//      this.account,
//      this.rentCycle,
//     this.amount,
//      this.id,
//   });
//
//   factory Entry.fromJson(Map<String, dynamic> json) {
//     return Entry(
//       entryId: json['entry_id']??"",
//       date: json['date']??"",
//       chargeType: json['charge_type']??"",
//       account: json['account']??"",
//       rentCycle: json['rent_cycle']??"",
//       amount: json['amount']?.toDouble(),
//       id: json['_id']??"",
//     );
//   }
// }


// class RentalSummary {
//    String? id;
//    String? rentalId;
//    String? adminId;
//    String? rentalOwnerId;
//    String? propertyId;
//    String? rentalAddress;
//    bool? isRentOn;
//    String? rentalCity;
//    String? rentalState;
//    String? rentalCountry;
//    String? rentalPostcode;
//    String? rentalImage;
//    String? staffMemberId;
//    String? createdAt;
//    String? updatedAt;
//    List<LeaseTenantData>? leaseTenantData;
//    RentalOwnerData? rentalOwnerData;
//    PropertyTypeData? propertyTypeData;
//    StaffMemberData? staffMemberData;
//
//   RentalSummary({
//      this.id,
//      this.rentalId,
//      this.adminId,
//      this.rentalOwnerId,
//      this.propertyId,
//      this.rentalAddress,
//      this.isRentOn,
//      this.rentalCity,
//      this.rentalState,
//      this.rentalCountry,
//      this.rentalPostcode,
//      this.rentalImage,
//      this.staffMemberId,
//      this.createdAt,
//      this.updatedAt,
//     this.leaseTenantData,
//      this.rentalOwnerData,
//      this.propertyTypeData,
//      this.staffMemberData,
//   });
//
//   factory RentalSummary.fromJson(Map<String, dynamic> json) {
//     print(json["lease_tenant_data"]);
//     return RentalSummary(
//       id: json['_id']??"",
//       rentalId: json['rental_id']??"",
//       adminId: json['admin_id']??"",
//       rentalOwnerId: json['rentalowner_id']??"",
//       propertyId: json['property_id']??"",
//       rentalAddress: json['rental_adress']??"",
//       isRentOn: json['is_rent_on']??"",
//       rentalCity: json['rental_city']??"",
//       rentalState: json['rental_state']??"",
//       rentalCountry: json['rental_country']??"",
//       rentalPostcode: json['rental_postcode']??"",
//       rentalImage: json['rental_image']??"",
//       staffMemberId: json['staffmember_id']??"",
//       createdAt: json['createdAt']??"",
//       updatedAt:json['updatedAt']??"",
//       leaseTenantData: json["lease_tenant_data"] != null?  (json['lease_tenant_data'] as List)
//           .map((data) => LeaseTenantData.fromJson(data))
//           .toList():[],
//       // rentalOwnerData: RentalOwnerData.fromJson(json['rental_owner_data'] ?? {}),
//       // propertyTypeData: PropertyTypeData.fromJson(json['property_type_data'] ?? {}),
//       // staffMemberData: StaffMemberData.fromJson(json['staffmember_data'] ?? {}),
//     );
//   }
// }
//
// class LeaseTenantData {
//   final TenantData tenantData;
//   final LeaseData leaseData;
//
//   LeaseTenantData({required this.tenantData, required this.leaseData});
//
//   factory LeaseTenantData.fromJson(Map<String, dynamic> json) {
//     return LeaseTenantData(
//       tenantData: TenantData.fromJson(json['tenant_data']??{}),
//       leaseData: LeaseData.fromJson(json['lease_data']??{}),
//     );
//   }
// }
//
// class TenantData {
//    String? id;
//    String? tenantId;
//    String? adminId;
//    String? tenantFirstName;
//    String? tenantLastName;
//    String? tenantPhoneNumber;
//    String? tenantAlternativeNumber;
//    String? tenantEmail;
//    String? tenantAlternativeEmail;
//    String? tenantPassword;
//    String? tenantBirthDate;
//    String? taxPayerId;
//    String? comments;
//    String? createdAt;
//    String? updatedAt;
//    // bool? isDelete;
//  //  EmergencyContact? emergencyContact;
//
//   TenantData({
//      this.id,
//      this.tenantId,
//      this.adminId,
//      this.tenantFirstName,
//      this.tenantLastName,
//      this.tenantPhoneNumber,
//      this.tenantAlternativeNumber,
//      this.tenantEmail,
//      this.tenantAlternativeEmail,
//      this.tenantPassword,
//      this.tenantBirthDate,
//      this.taxPayerId,
//      this.comments,
//      this.createdAt,
//      this.updatedAt,
//     // required this.isDelete,
//     // this.emergencyContact,
//   });
//
//   factory TenantData.fromJson(Map<String, dynamic> json) {
//     return  TenantData(
//       id: json['_id'],
//       tenantId: json['tenant_id'],
//       adminId: json['admin_id'],
//       tenantFirstName: json['tenant_firstName'],
//       tenantLastName: json['tenant_lastName'],
//       tenantPhoneNumber: json['tenant_phoneNumber'],
//       tenantAlternativeNumber: json['tenant_alternativeNumber'],
//       tenantEmail: json['tenant_email'],
//       tenantAlternativeEmail: json['tenant_alternativeEmail'],
//       tenantPassword: json['tenant_password'],
//       tenantBirthDate: json['tenant_birthDate']??"",
//       taxPayerId: json['taxPayer_id'],
//       comments: json['comments'],
//       createdAt: json['createdAt']??"",
//       updatedAt: json['updatedAt']??"",
//       // isDelete: json['is_delete'],
//      // emergencyContact: EmergencyContact.fromJson(json['emergency_contact']??""),
//     );
//   }
// }
//
// class EmergencyContact {
//    String? name;
//    String? relation;
//    String? email;
//    String? phoneNumber;
//
//   EmergencyContact({
//      this.name,
//      this.relation,
//      this.email,
//      this.phoneNumber,
//   });
//
//   factory EmergencyContact.fromJson(Map<String, dynamic> json) {
//     return EmergencyContact(
//       name: json['name']??"",
//       relation: json['relation']??"",
//       email: json['email']??"",
//       phoneNumber: json['phoneNumber'],
//     );
//   }
// }
//
// class LeaseData {
//    String? id;
//    String? leaseId;
//    List<String>? tenantIds;
//    String? adminId;
//    String? rentalId;
//    String? unitId;
//    String? leaseType;
//    String? startDate;
//    String? endDate;
//    List<Entry>? entries;
//    String? createdAt;
//    String? updatedAt;
//    // bool? isDelete;
//
//   LeaseData({
//      this.id,
//      this.leaseId,
//      this.tenantIds,
//      this.adminId,
//      this.rentalId,
//      this.unitId,
//      this.leaseType,
//      this.startDate,
//      this.endDate,
//      this.entries,
//      this.createdAt,
//      this.updatedAt,
//     // this.isDelete,
//   });
//
//   factory LeaseData.fromJson(Map<String, dynamic> json) {
//     return LeaseData(
//       id: json['_id']??"",
//       leaseId: json['lease_id']??"",
//       tenantIds: List<String>.from(json['tenant_id']),
//       adminId: json['admin_id']??"",
//       rentalId: json['rental_id']??"",
//       unitId: json['unit_id']??"",
//       leaseType: json['lease_type']??"",
//       startDate: json['start_date']??"",
//       endDate:json['end_date']??"",
//       entries: (json['entry'] as List).map((data) => Entry.fromJson(data)).toList(),
//       createdAt: json['createdAt']??"",
//       updatedAt: json['updatedAt']??"",
//       // isDelete: json['is_delete']??"",
//     );
//   }
// }
//
// class Entry {
//    String? entryId;
//    String? date;
//    String? chargeType;
//    String? account;
//    String? rentCycle;
//    double? amount;
//
//   Entry({
//      this.entryId,
//      this.date,
//      this.chargeType,
//      this.account,
//      this.rentCycle,
//      this.amount,
//   });
//
//   factory Entry.fromJson(Map<String, dynamic> json) {
//     return Entry(
//       entryId: json['entry_id']??"",
//       date: json['date']??"",
//       chargeType: json['charge_type']??"",
//       account: json['account']??"",
//       rentCycle: json['rent_cycle']??"",
//       amount: json['amount']?.toDouble() ?? 0.0,
//     );
//   }
// }
//
// class RentalOwnerData {
//    String? id;
//    String? rentalOwnerId;
//    String? adminId;
//    String? firstName;
//    String? lastName;
//    String? companyName;
//    String? primaryEmail;
//    String? phoneNumber;
//    String? birthDate;
//    String? startDate;
//    String? endDate;
//    String? createdAt;
//    String? updatedAt;
//
//
//   RentalOwnerData({
//      this.id,
//      this.rentalOwnerId,
//      this.adminId,
//     this.firstName,
//      this.lastName,
//      this.companyName,
//      this.primaryEmail,
//      this.phoneNumber,
//      this.birthDate,
//      this.startDate,
//      this.endDate,
//      this.createdAt,
//      this.updatedAt,
//
//   });
//
//   factory RentalOwnerData.fromJson(Map<String, dynamic> json) {
//     return RentalOwnerData(
//       id: json['_id']??"",
//       rentalOwnerId: json['rentalowner_id']??"",
//       adminId: json['admin_id']??"",
//       firstName: json['rentalOwner_firstName']??"",
//       lastName: json['rentalOwner_lastName']??"",
//       companyName: json['rentalOwner_companyName']??"",
//       primaryEmail: json['rentalOwner_primaryEmail']??"",
//       phoneNumber: json['rentalOwner_phoneNumber']??"",
//       birthDate: json['birth_date']??"",
//       startDate:json['start_date']??"",
//       endDate: json['end_date']??"",
//       createdAt:json['createdAt']??"",
//       updatedAt: json['updatedAt']??"",
//
//     );
//   }
// }
//
// class PropertyTypeData {
//    String? id;
//    String? adminId;
//    String? propertyId;
//    String? propertyType;
//    String? propertySubType;
//    bool? isMultiUnit;
//    String? createdAt;
//    String? updatedAt;
//
//
//   PropertyTypeData({
//      this.id,
//      this.adminId,
//      this.propertyId,
//      this.propertyType,
//      this.propertySubType,
//      this.isMultiUnit,
//      this.createdAt,
//      this.updatedAt,
//
//   });
//
//   factory PropertyTypeData.fromJson(Map<String, dynamic> json) {
//     return PropertyTypeData(
//       id: json['_id']??"",
//       adminId: json['admin_id']??"",
//       propertyId: json['property_id']??"",
//       propertyType: json['property_type']??"",
//       propertySubType: json['propertysub_type']??"",
//       isMultiUnit: json['is_multiunit']??"",
//       createdAt: json['createdAt']??"",
//       updatedAt:json['updatedAt']??"",
//
//     );
//   }
// }
//
// class StaffMemberData {
//    String? id;
//    String? adminId;
//    String? staffMemberId;
//    String? staffMemberName;
//    String? staffMemberDesignation;
//    String? staffMemberPhoneNumber;
//    String? staffMemberEmail;
//    String? staffMemberPassword;
//    String? createdAt;
//    String? updatedAt;
//
//
//   StaffMemberData({
//      this.id,
//      this.adminId,
//      this.staffMemberId,
//      this.staffMemberName,
//      this.staffMemberDesignation,
//      this.staffMemberPhoneNumber,
//      this.staffMemberEmail,
//     this.staffMemberPassword,
//     this.createdAt,
//      this.updatedAt,
//
//   });
//
//   factory StaffMemberData.fromJson(Map<String, dynamic> json) {
//     return StaffMemberData(
//       id: json['_id']??"",
//       adminId: json['admin_id']??"",
//       staffMemberId: json['staffmember_id']??"",
//       staffMemberName: json['staffmember_name']??"",
//       staffMemberDesignation: json['staffmember_designation']??"",
//       staffMemberPhoneNumber: json['staffmember_phoneNumber']??"",
//       staffMemberEmail: json['staffmember_email']??"",
//       staffMemberPassword: json['staffmember_password']??"",
//       createdAt: json['createdAt']??"",
//       updatedAt: json['updatedAt']??"",
//
//     );
//   }
// }


// Define a Dart class for the emergency contact
class EmergencyContact {
  final String name;
  final String relation;
  final String email;
  final String phoneNumber;

  EmergencyContact({
    required this.name,
    required this.relation,
    required this.email,
    required this.phoneNumber,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? "",
      relation: json['relation'] ?? "",
      email: json['email'] ?? "",
      phoneNumber: json['phoneNumber'] ?? "",
    );
  }
}

class TenantData {
  final String? id;
  final List<String>? tenantId;
  final String? adminId;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String? alternativeNumber;
  final String? email;
  final String? alternativeEmail;
  final String? password;
  final String? birthDate;
  final String? taxPayerId;
  final String? comments;
  final String? createdAt;
  final String? updatedAt;
  final bool? isDelete;
  final String? leaseId;
  final String? rentalId;
  final String? unitId;
  final String? leaseType;
  final String? startDate;
  final String? endDate;
  final List<dynamic>? uploadedFile;
  final List<dynamic>? entry;
  final String? moveoutNoticeGivenDate;
  final String? moveoutDate;
  final List<dynamic>? moveoutTenant;
  final String? rentalOwnerId;
  final String? propertyId;
  final String? rentalAddress;
  final bool? isRentOn;
  final String? rentalCity;
  final String? rentalState;
  final String? rentalCountry;
  final String? rentalPostcode;
  final String? rentalImage;
  final String? staffMemberId;
  final String? rentalUnit;
  final String? rentalUnitAddress;
  final String? rentalSqft;
  final List<dynamic>? rentalImages;
  final EmergencyContact? emergencyContact;

  TenantData({
    this.id,
    this.tenantId,
    this.adminId,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.alternativeNumber,
    this.email,
    this.alternativeEmail,
    this.password,
    this.birthDate,
    this.taxPayerId,
    this.comments,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.leaseId,
    this.rentalId,
    this.unitId,
    this.leaseType,
    this.startDate,
    this.endDate,
    this.uploadedFile,
    this.entry,
    this.moveoutNoticeGivenDate,
    this.moveoutDate,
    this.moveoutTenant,
    this.rentalOwnerId,
    this.propertyId,
    this.rentalAddress,
    this.isRentOn,
    this.rentalCity,
    this.rentalState,
    this.rentalCountry,
    this.rentalPostcode,
    this.rentalImage,
    this.staffMemberId,
    this.rentalUnit,
    this.rentalUnitAddress,
    this.rentalSqft,
    this.rentalImages,
    this.emergencyContact,
  });

  factory TenantData.fromJson(Map<String, dynamic> json) {
    return TenantData(
      id: json['_id'],
      tenantId: json['tenant_id'] != null ? [json['tenant_id']] : null,
      adminId: json['admin_id'],
      firstName: json['tenant_firstName'],
      lastName: json['tenant_lastName'],
      phoneNumber: json['tenant_phoneNumber'],
      alternativeNumber: json['tenant_alternativeNumber'],
      email: json['tenant_email'],
      alternativeEmail: json['tenant_alternativeEmail'],
      password: json['tenant_password'],
      birthDate: json['tenant_birthDate'],
      taxPayerId: json['taxPayer_id'],
      comments: json['comments'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isDelete: json['is_delete'],
      leaseId: json['lease_id'],
      rentalId: json['rental_id'],
      unitId: json['unit_id'],
      leaseType: json['lease_type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      uploadedFile: json['uploaded_file'],
      entry: json['entry'],
      moveoutNoticeGivenDate: json['moveout_notice_given_date'],
      moveoutDate: json['moveout_date'],
      moveoutTenant: json['moveout_tenant'],
      rentalOwnerId: json['rentalowner_id'],
      propertyId: json['property_id'],
      rentalAddress: json['rental_adress'],
      isRentOn: json['is_rent_on'],
      rentalCity: json['rental_city'],
      rentalState: json['rental_state'],
      rentalCountry: json['rental_country'],
      rentalPostcode: json['rental_postcode'],
      rentalImage: json['rental_image'],
      staffMemberId: json['staffmember_id'],
      rentalUnit: json['rental_unit'],
      rentalUnitAddress: json['rental_unit_adress'],
      rentalSqft: json['rental_sqft'],
      rentalImages: json['rental_images'],
      emergencyContact: json['emergency_contact'] != null ? EmergencyContact.fromJson(json['emergency_contact']) : null,
    );
  }
}
