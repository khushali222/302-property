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

class TenantData {
   EmergencyContact? emergencyContact;
   String? id;
  // List<String>? tenantId;
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
   int? v;
   String? leaseId;
   String? rentalId;
   String? unitId;
   String? leaseType;
   String? startDate;
   String? endDate;
   double? leaseAmount;
   List<dynamic>? uploadedFile;
   List<Entry>? entry;
   String? moveoutNoticeGivenDate;
   String? moveoutDate;
   List<dynamic>? moveoutTenant;
   String? rentalOwnerId;
   String? processorId;
   String? propertyId;
   String? rentalAddress;
   bool? isRentOn;
   String? rentalCity;
   String? rentalState;
   String? rentalCountry;
   String? rentalPostcode;
   String? rentalImage;
   String? staffMemberId;
   String? rentalUnit;
   String? rentalUnitAddress;
   String? rentalSqft;
   String? rentalBath;
   String? rentalBed;
   List<dynamic>? rentalImages;

  TenantData({
     this.emergencyContact,
     this.id,
   //  this.tenantId,
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
     this.v,
     this.leaseId,
     this.rentalId,
     this.unitId,
     this.leaseType,
     this.startDate,
     this.endDate,
    this.leaseAmount,
     this.uploadedFile,
     this.entry,
    this.moveoutNoticeGivenDate,
    this.moveoutDate,
     this.moveoutTenant,
     this.rentalOwnerId,
     this.processorId,
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
     this.rentalBath,
     this.rentalBed,
     this.rentalImages,
  });

  factory TenantData.fromJson(Map<String, dynamic> json) {
    var entryList = json['entry'] as List;
    List<Entry> entryObjects = entryList.map((item) => Entry.fromJson(item)).toList();

    return TenantData(
      emergencyContact: EmergencyContact.fromJson(json['emergency_contact']),
      id: json['_id']??"",
   //   tenantId: List<String>.from(json['tenant_id']),
      adminId: json['admin_id']??"",
      tenantFirstName: json['tenant_firstName']??"",
      tenantLastName: json['tenant_lastName']??"",
      tenantPhoneNumber: json['tenant_phoneNumber']??"",
      tenantAlternativeNumber: json['tenant_alternativeNumber']??"",
      tenantEmail: json['tenant_email']??"",
      tenantAlternativeEmail: json['tenant_alternativeEmail']??"",
      tenantPassword: json['tenant_password']??"",
      tenantBirthDate: json['tenant_birthDate']??"",
      taxPayerId: json['taxPayer_id']??"",
      comments: json['comments']??"",
      createdAt: json['createdAt']??"",
      updatedAt: json['updatedAt']??"",
      isDelete: json['is_delete']??"",
      v: json['__v']??"",
      leaseId: json['lease_id']??"",
      rentalId: json['rental_id']??"",
      unitId: json['unit_id']??"",
      leaseType: json['lease_type']??"",
      startDate: json['start_date']??"",
      endDate: json['end_date']??"",
      leaseAmount: json['lease_amount']?.toDouble(),
      uploadedFile: json['uploaded_file']??"",
      entry: entryObjects,
      moveoutNoticeGivenDate: json['moveout_notice_given_date']??"",
      moveoutDate: json['moveout_date']??"",
      moveoutTenant: json['moveout_tenant']??"",
      rentalOwnerId: json['rentalowner_id']??"",
      processorId: json['processor_id']??"",
      propertyId: json['property_id']??"",
      rentalAddress: json['rental_adress']??"",
      isRentOn: json['is_rent_on']??"",
      rentalCity: json['rental_city']??"",
      rentalState: json['rental_state']??"",
      rentalCountry: json['rental_country']??"",
      rentalPostcode: json['rental_postcode']??"",
      rentalImage: json['rental_image']??"",
      staffMemberId: json['staffmember_id']??"",
      rentalUnit: json['rental_unit']??"",
      rentalUnitAddress: json['rental_unit_adress']??"",
      rentalSqft: json['rental_sqft']??"",
      rentalBath: json['rental_bath']??"",
      rentalBed: json['rental_bed']??"",
      rentalImages: json['rental_images']??"",
    );
  }
}

class EmergencyContact {
   String? name;
   String? relation;
   String? email;
   String? phoneNumber;

  EmergencyContact({
     this.name,
     this.relation,
     this.email,
    this.phoneNumber,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'],
      relation: json['relation'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }
}

class Entry {
   String? entryId;
   String? date;
   String? chargeType;
   String? account;
   String? rentCycle;
   double? amount;
   String? id;

  Entry({
     this.entryId,
     this.date,
     this.chargeType,
     this.account,
     this.rentCycle,
    this.amount,
     this.id,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      entryId: json['entry_id']??"",
      date: json['date']??"",
      chargeType: json['charge_type']??"",
      account: json['account']??"",
      rentCycle: json['rent_cycle']??"",
      amount: json['amount']?.toDouble(),
      id: json['_id']??"",
    );
  }
}