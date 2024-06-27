// class propertytype {
//   String? Id;
//   String? adminId;
//   String? rentalowner_id;
//   String? rentalOwner_firstName;
//   String? rentalOwner_lastName;
//   String? rentalOwner_companyName;
//   String? rentalOwner_primaryEmail;
//   String? rentalOwner_alternateEmail;
//   String? rentalOwner_phoneNumber;
//   String? rentalOwner_homeNumber;
//   String? rentalOwner_businessNumber;
//   String? rentalOwner_homeNumber;
//   bool? isMultiunit;
//   String? createdAt;
//   String? updatedAt;
//   bool? isDelete;
//   int? iV;
//
//   propertytype(
//       {this.Id,
//         this.adminId,
//         this.rentalowner_id,
//         this.rentalOwner_firstName,
//         this.rentalOwner_lastName,
//         this.rentalOwner_companyName,
//         this.rentalOwner_primaryEmail,
//         this.rentalOwner_alternateEmail,
//         this.rentalOwner_phoneNumber,
//         this.rentalOwner_homeNumber,
//         this.rentalOwner_businessNumber,
//         this.rentalOwner_homeNumber,
//         this.rentalOwner_homeNumber,
//         this.isMultiunit,
//         this.createdAt,
//         this.updatedAt,
//         this.isDelete,
//         this.iV});
//
//   propertytype.fromJson(Map<String, dynamic> json) {
//     Id = json['_id'];
//     adminId = json['admin_id'];
//     rentalowner_id = json['rentalowner_id'];
//     rentalOwner_firstName = json['rentalOwner_firstName'];
//     rentalOwner_lastName = json['rentalOwner_lastName'];
//     rentalOwner_companyName = json['rentalOwner_companyName'];
//     rentalOwner_primaryEmail = json['rentalOwner_primaryEmail'];
//     rentalOwner_alternateEmail = json['rentalOwner_alternateEmail'];
//     rentalOwner_phoneNumber = json['rentalOwner_phoneNumber'];
//     rentalOwner_homeNumber = json['rentalOwner_homeNumber'];
//     rentalOwner_businessNumber = json['rentalOwner_businessNumber'];
//     rentalOwner_companyName = json['rentalOwner_companyName'];
//     rentalOwner_companyName = json['rentalOwner_companyName'];
//     isMultiunit = json['is_multiunit'];
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     isDelete = json['is_delete'];
//     iV = json['__v'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.Id;
//     data['admin_id'] = this.adminId;
//     data['rentalowner_id'] = this.rentalowner_id;
//     data['rentalOwner_firstName'] = this.rentalOwner_firstName;
//     data['rentalOwner_lastName'] = this.rentalOwner_lastName;
//     data['rentalOwner_companyName'] = this.rentalOwner_companyName;
//     data['rentalOwner_primaryEmail'] = this.rentalOwner_primaryEmail;
//     data['rentalOwner_alternateEmail'] = this.rentalOwner_alternateEmail;
//     data['rentalOwner_phoneNumber'] = this.rentalOwner_phoneNumber;
//     data['rentalOwner_homeNumber'] = this.rentalOwner_homeNumber;
//     data['rentalOwner_businessNumber'] = this.rentalOwner_businessNumber;
//     data['rentalOwner_homeNumber'] = this.rentalOwner_homeNumber;
//     data['rentalOwner_homeNumber'] = this.rentalOwner_homeNumber;
//     data['is_multiunit'] = this.isMultiunit;
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['is_delete'] = this.isDelete;
//     data['__v'] = this.iV;
//     return data;
//   }
// }

class RentalOwner {
  String? propertyId;
  String? sId;
  String? rentalOwnerId;
  String? rentalOwnerName;
  String? adminId;
  String? rentalOwnerFirstName;
  String? rentalOwnerLastName;
  String? rentalOwnerCompanyName;
  String? rentalOwnerPrimaryEmail;
  String? rentalOwnerAlternateEmail;
  String? rentalOwnerPhoneNumber;
  String? rentalOwnerHomeNumber;
  String? rentalOwnerBusinessNumber;
  String? birthDate;
  String? startDate;
  String? endDate;
  String? taxpayerId;
  String? textIdentityType;
  String? streetAddress;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  List<ProcessorList>? processorList;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? v;

  RentalOwner({
    this.propertyId,
    this.sId,
    this.rentalOwnerId,
    this.rentalOwnerName,
    this.adminId,
    this.rentalOwnerFirstName,
    this.rentalOwnerLastName,
    this.rentalOwnerCompanyName,
    this.rentalOwnerPrimaryEmail,
    this.rentalOwnerAlternateEmail,
    this.rentalOwnerPhoneNumber,
    this.rentalOwnerHomeNumber,
    this.rentalOwnerBusinessNumber,
    this.birthDate,
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
    var processorListFromJson = json['processor_list'] as List;
    List<ProcessorList> processorList = processorListFromJson.map((processorJson) => ProcessorList.fromJson(processorJson)).toList();
    return RentalOwner(
      propertyId: json['property_id'],
      sId: json['_id'],
      rentalOwnerId: json['rentalowner_id'],
      adminId: json['admin_id'],
      rentalOwnerName: json['rentalOwner_name'],
      rentalOwnerFirstName: json['rentalOwner_firstName'],
      rentalOwnerLastName: json['rentalOwner_lastName'],
      rentalOwnerCompanyName: json['rentalOwner_companyName'],
      rentalOwnerPrimaryEmail: json['rentalOwner_primaryEmail'],
      rentalOwnerAlternateEmail: json['rentalOwner_alternateEmail'],
      rentalOwnerPhoneNumber: json['rentalOwner_phoneNumber'],
      rentalOwnerHomeNumber: json['rentalOwner_homeNumber'],
      rentalOwnerBusinessNumber: json['rentalOwner_businessNumber'],
      birthDate: json['birth_date'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      taxpayerId: json['texpayer_id'],
      textIdentityType: json['text_identityType'],
      streetAddress: json['street_address'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postal_code'],
      processorList: processorList,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isDelete: json['is_delete'],
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['property_id'] = this.propertyId;
    data['_id'] = this.sId;
    data['rentalowner_id'] = this.rentalOwnerId;
    data['admin_id'] = this.adminId;
    data['rentalOwner_name'] = this.rentalOwnerName;
    data['rentalOwner_firstName'] = this.rentalOwnerFirstName;
    data['rentalOwner_lastName'] = this.rentalOwnerLastName;
    data['rentalOwner_companyName'] = this.rentalOwnerCompanyName;
    data['rentalOwner_primaryEmail'] = this.rentalOwnerPrimaryEmail;
    data['rentalOwner_alternateEmail'] = this.rentalOwnerAlternateEmail;
    data['rentalOwner_phoneNumber'] = this.rentalOwnerPhoneNumber;
    data['rentalOwner_homeNumber'] = this.rentalOwnerHomeNumber;
    data['rentalOwner_businessNumber'] = this.rentalOwnerBusinessNumber;
    data['birth_date'] = this.birthDate;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['texpayer_id'] = this.taxpayerId;
    data['text_identityType'] = this.textIdentityType;
    data['street_address'] = this.streetAddress;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['postal_code'] = this.postalCode;
    if (this.processorList != null) {
      data['processor_list'] = this.processorList!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    data['__v'] = this.v;
    return data;
  }
}

class ProcessorList {
  String? processorId;
  String? sId;

  ProcessorList({this.processorId, this.sId});

  factory ProcessorList.fromJson(Map<String, dynamic> json) {
    return ProcessorList(
      processorId: json['processor_id'],
      sId: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['processor_id'] = this.processorId;
    data['_id'] = this.sId;
    return data;
  }

}



