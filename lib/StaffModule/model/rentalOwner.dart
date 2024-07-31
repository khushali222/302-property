// import 'dart:convert';
//
// class Processor {
//   String processorId;
//   String id;
//
//   Processor({
//     required this.processorId,
//     required this.id,
//   });
//
//   factory Processor.fromJson(Map<String, dynamic> json) {
//     return Processor(
//       processorId: json['processor_id'] ?? '',
//       id: json['_id'] ?? '',
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       'processor_id': processorId,
//       '_id': id,
//     };
//   }
// }
// class ProcessorList {
//   String? processorId;
//   String? sId;
//
//   ProcessorList({this.processorId, this.sId});
//
//   ProcessorList.fromJson(Map<String, dynamic> json) {
//     processorId = json['processor_id'];
//     sId = json['_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['processor_id'] = this.processorId;
//     // data['_id'] = this.sId;
//     return data;
//   }
// }
// class RentalOwner {
//   String? id;
//   String? rentalownerId;
//   String? adminId;
//   String? rentalOwnerFirstName;
//   String? rentalOwnerLastName;
//   String? rentalOwnerName;
//   String? rentalOwnerCompanyName;
//   String? rentalOwnerPrimaryEmail;
//   String? rentalOwnerAlternateEmail;
//   String? rentalOwnerPhoneNumber;
//   String? rentalOwnerHomeNumber;
//   String? rentalOwnerBusinessNumber;
//   String? startDate;
//   String? endDate;
//   String? taxpayerId;
//   String? textIdentityType;
//   String? streetAddress;
//   String? city;
//   String? state;
//   String? country;
//   String? postalCode;
//   List<Processor>? processorList;
//   String? createdAt;
//   String? updatedAt;
//   bool? isDelete;
//   int? v;
//
//   RentalOwner({
//     this.id,
//     this.rentalownerId,
//     this.adminId,
//     this.rentalOwnerFirstName,
//     this.rentalOwnerLastName,
//     this.rentalOwnerName,
//     this.rentalOwnerCompanyName,
//     this.rentalOwnerPrimaryEmail,
//     this.rentalOwnerAlternateEmail,
//     this.rentalOwnerPhoneNumber,
//     this.rentalOwnerHomeNumber,
//     this.rentalOwnerBusinessNumber,
//     this.startDate,
//     this.endDate,
//     this.taxpayerId,
//     this.textIdentityType,
//     this.streetAddress,
//     this.city,
//     this.state,
//     this.country,
//     this.postalCode,
//     this.processorList,
//     this.createdAt,
//     this.updatedAt,
//     this.isDelete,
//     this.v,
//   });
//
//   factory RentalOwner.fromJson(Map<String, dynamic> json) {
//     return RentalOwner(
//       id: json['_id']??"",
//       rentalownerId: json['rentalowner_id']??"",
//       adminId: json['admin_id']??"",
//       rentalOwnerFirstName: json['rentalOwner_firstName']??"",
//       rentalOwnerLastName: json['rentalOwner_lastName']??"",
//       rentalOwnerName: json['rentalOwner_name']??"",
//       rentalOwnerCompanyName: json['rentalOwner_companyName']??"",
//       rentalOwnerPrimaryEmail: json['rentalOwner_primaryEmail']??"",
//       rentalOwnerAlternateEmail: json['rentalOwner_alternateEmail']??"",
//       rentalOwnerPhoneNumber: json['rentalOwner_phoneNumber']??"",
//       rentalOwnerHomeNumber: json['rentalOwner_homeNumber']??"",
//       rentalOwnerBusinessNumber: json['rentalOwner_businessNumber']??"",
//       startDate: json['start_date']??"",
//       endDate: json['end_date']??"",
//       taxpayerId: json['texpayer_id']??"",
//       textIdentityType: json['text_identityType']??"",
//       streetAddress: json['street_address']??"",
//       city: json['city']??"",
//       state: json['state']??"",
//       country: json['country']??"",
//       postalCode: json['postal_code']??"",
//       processorList: (json['processor_list'] as List?)
//           ?.map((i) => Processor.fromJson(i))
//           .toList(),
//       createdAt: json['createdAt']??"",
//       updatedAt: json['updatedAt']??"",
//       isDelete: json['is_delete']??"",
//       v: json['__v']??"",
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     return {
//       '_id': id,
//       'rentalowner_id': rentalownerId,
//       'admin_id': adminId,
//       'rentalOwner_firstName': rentalOwnerFirstName,
//       'rentalOwner_lastName': rentalOwnerLastName,
//       'rentalOwner_name': rentalOwnerName,
//       'rentalOwner_companyName': rentalOwnerCompanyName,
//       'rentalOwner_primaryEmail': rentalOwnerPrimaryEmail,
//       'rentalOwner_alternateEmail': rentalOwnerAlternateEmail,
//       'rentalOwner_phoneNumber': rentalOwnerPhoneNumber,
//       'rentalOwner_homeNumber': rentalOwnerHomeNumber,
//       'rentalOwner_businessNumber': rentalOwnerBusinessNumber,
//       'start_date': startDate,
//       'end_date': endDate,
//       'texpayer_id': taxpayerId,
//       'text_identityType': textIdentityType,
//       'street_address': streetAddress,
//       'city': city,
//       'state': state,
//       'country': country,
//       'postal_code': postalCode,
//       'processor_list': processorList?.map((e) => e.toJson()).toList(),
//       'createdAt': createdAt,
//       'updatedAt': updatedAt,
//       'is_delete': isDelete,
//       '__v': v,
//     };
//   }
// }

import 'dart:convert';

class Processor {
  String processorId;
  String id;

  Processor({
    required this.processorId,
    required this.id,
  });

  factory Processor.fromJson(Map<String, dynamic> json) {
    return Processor(
      processorId: json['processor_id'] ?? '',
      id: json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'processor_id': processorId,
      '_id': id,
    };
  }
}

class RentalOwner {
  String? id;
  String? rentalownerId;
  String? adminId;
  String? rentalOwnerFirstName;
  String? rentalOwnerLastName;
  String? rentalOwnerName;
  String? rentalOwnerCompanyName;
  String? rentalOwnerPrimaryEmail;
  String? rentalOwnerAlternateEmail;
  String? rentalOwnerPhoneNumber;
  String? rentalOwnerHomeNumber;
  String? rentalOwnerBusinessNumber;
  String? startDate;
  String? endDate;
  String? taxpayerId;
  String? textIdentityType;
  String? streetAddress;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  List<Processor>? processorList;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? v;

  RentalOwner({
    this.id,
    this.rentalownerId,
    this.adminId,
    this.rentalOwnerFirstName,
    this.rentalOwnerLastName,
    this.rentalOwnerName,
    this.rentalOwnerCompanyName,
    this.rentalOwnerPrimaryEmail,
    this.rentalOwnerAlternateEmail,
    this.rentalOwnerPhoneNumber,
    this.rentalOwnerHomeNumber,
    this.rentalOwnerBusinessNumber,
    this.startDate,
    this.endDate,
    this.taxpayerId,
    this.textIdentityType,
    this.streetAddress,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.processorList,
    this.createdAt,
    this.updatedAt,
    this.isDelete,
    this.v,
  });

  factory RentalOwner.fromJson(Map<String, dynamic> json) {
    return RentalOwner(
      id: json['_id'] ?? '',
      rentalownerId: json['rentalowner_id'] ?? '',
      adminId: json['admin_id'] ?? '',
      rentalOwnerFirstName: json['rentalOwner_firstName'] ?? '',
      rentalOwnerLastName: json['rentalOwner_lastName'] ?? '',
      rentalOwnerName: json['rentalOwner_name'] ?? '',
      rentalOwnerCompanyName: json['rentalOwner_companyName'] ?? '',
      rentalOwnerPrimaryEmail: json['rentalOwner_primaryEmail'] ?? '',
      rentalOwnerAlternateEmail: json['rentalOwner_alternateEmail'] ?? '',
      rentalOwnerPhoneNumber: json['rentalOwner_phoneNumber'] ?? '',
      rentalOwnerHomeNumber: json['rentalOwner_homeNumber'] ?? '',
      rentalOwnerBusinessNumber: json['rentalOwner_businessNumber'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      taxpayerId: json['texpayer_id'] ?? '',
      textIdentityType: json['text_identityType'] ?? '',
      streetAddress: json['street_address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      postalCode: json['postal_code'] ?? '',
      processorList: (json['processor_list'] as List<dynamic>?)
          ?.map((e) => Processor.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      isDelete: json['is_delete'] ?? false,
      v: json['__v'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'rentalowner_id': rentalownerId,
      'admin_id': adminId,
      'rentalOwner_firstName': rentalOwnerFirstName,
      'rentalOwner_lastName': rentalOwnerLastName,
      'rentalOwner_name': rentalOwnerName,
      'rentalOwner_companyName': rentalOwnerCompanyName,
      'rentalOwner_primaryEmail': rentalOwnerPrimaryEmail,
      'rentalOwner_alternateEmail': rentalOwnerAlternateEmail,
      'rentalOwner_phoneNumber': rentalOwnerPhoneNumber,
      'rentalOwner_homeNumber': rentalOwnerHomeNumber,
      'rentalOwner_businessNumber': rentalOwnerBusinessNumber,
      'start_date': startDate,
      'end_date': endDate,
      'texpayer_id': taxpayerId,
      'text_identityType': textIdentityType,
      'street_address': streetAddress,
      'city': city,
      'state': state,
      'country': country,
      'postal_code': postalCode,
      'processor_list': processorList?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'is_delete': isDelete,
      '__v': v,
    };
  }
}
