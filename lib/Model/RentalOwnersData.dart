class RentalOwnerData {
  String? sId;
  String? rentalownerId;
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
  String? texpayerId;
  String? textIdentityType;
  String? streetAddress;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  List<ProcessorList>? processorList;
  List<String>? processorLists;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? iV;

  RentalOwnerData(
      {this.sId,
        this.rentalownerId,
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
        this.texpayerId,
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
        this.iV,
        this.processorLists
      });

  RentalOwnerData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    rentalownerId = json['rentalowner_id'];
    adminId = json['admin_id'];
    rentalOwnerFirstName = json['rentalOwner_firstName'];
    rentalOwnerLastName = json['rentalOwner_lastName'];
    rentalOwnerCompanyName = json['rentalOwner_companyName'];
    rentalOwnerPrimaryEmail = json['rentalOwner_primaryEmail'];
    rentalOwnerAlternateEmail = json['rentalOwner_alternateEmail'];
    rentalOwnerPhoneNumber = json['rentalOwner_phoneNumber'];
    rentalOwnerHomeNumber = json['rentalOwner_homeNumber'];
    rentalOwnerBusinessNumber = json['rentalOwner_businessNumber'];
    birthDate = json['birth_date'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    texpayerId = json['texpayer_id'];
    textIdentityType = json['text_identityType'];
    streetAddress = json['street_address'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    postalCode = json['postal_code'];
    if (json['processor_list'] != null) {
      processorList = <ProcessorList>[];
      json['processor_list'].forEach((v) {
        processorList!.add(new ProcessorList.fromJson(v));
      });
    }

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['rentalowner_id'] = this.rentalownerId;
    data['admin_id'] = this.adminId;
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
    data['texpayer_id'] = this.texpayerId;
    data['text_identityType'] = this.textIdentityType;
    data['street_address'] = this.streetAddress;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['postal_code'] = this.postalCode;
    if (this.processorList != null) {
      data['processor_list'] =
          this.processorList!.map((v) => v.toJson()).toList();
    }

    data['processor_list'] = processorLists;
    return data;
  }
}

class ProcessorList {
  String? processorId;
  String? sId;

  ProcessorList({this.processorId, this.sId});

  ProcessorList.fromJson(Map<String, dynamic> json) {
    processorId = json['processor_id'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['processor_id'] = this.processorId;
   // data['_id'] = this.sId;
    return data;
  }
}
