class ApplicantResponse {
  ApplicantResponse({
    required this.statusCode,
    required this.data,
    required this.message,
  });

  final int? statusCode;
  final List<Datum> data;
  final String? message;

  factory ApplicantResponse.fromJson(Map<String, dynamic> json) {
    return ApplicantResponse(
      statusCode: json["statusCode"],
      data: json["data"] == null
          ? []
          : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
      message: json["message"],
    );
  }

  Map<String, dynamic> toJson() => {
        "statusCode": statusCode,
        "data": data.map((x) => x?.toJson()).toList(),
        "message": message,
      };
}

class Datum {
  Datum(
      {this.id,
      this.applicantId,
      this.adminId,
      this.applicantFirstName,
      this.applicantLastName,
      this.applicantEmail,
      this.applicantPhoneNumber,
      this.applicantHomeNumber,
      this.applicantBusinessNumber,
      this.applicantTelephoneNumber,
      this.applicantChecklist = const [],
      this.applicantCheckedChecklist = const [],
      this.isMovedin,
      this.isApplicantDataEmpty,
      this.isDelete,
      this.createdAt,
      this.updatedAt,
      this.applicantNotesAndFile = const [],
      this.applicantStatus = const [],
      this.v,
      this.rentalData,
      this.unitData,
      this.applicantEmailsendDate,
      this.applicant,
      this.lease});

  final String? id;
  final String? applicantId;
  final String? adminId;
  final String? applicantFirstName;
  final String? applicantLastName;
  final String? applicantEmail;
  final dynamic? applicantPhoneNumber;
  final dynamic? applicantHomeNumber;
  final dynamic? applicantBusinessNumber;
  final dynamic? applicantTelephoneNumber;
  final List<dynamic> applicantChecklist;
  final List<String> applicantCheckedChecklist;
  final bool? isMovedin;
  final bool? isApplicantDataEmpty;
  final bool? isDelete;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<ApplicantNotesAndFile> applicantNotesAndFile;
  final List<ApplicantStatus> applicantStatus;
  final int? v;
  final RentalData? rentalData;
  final UnitData? unitData;
  final DateTime? applicantEmailsendDate;
  ApplicantDetails? applicant;
  LeaseApplicant? lease;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["_id"],
      applicantId: json["applicant_id"],
      adminId: json["admin_id"],
      applicantFirstName: json["applicant_firstName"],
      applicantLastName: json["applicant_lastName"],
      applicantEmail: json["applicant_email"],
      applicantPhoneNumber: json["applicant_phoneNumber"],
      applicantHomeNumber: json["applicant_homeNumber"],
      applicantBusinessNumber: json["applicant_businessNumber"],
      applicantTelephoneNumber: json["applicant_telephoneNumber"],
      applicantChecklist: json["applicant_checklist"] == null
          ? []
          : List<dynamic>.from(json["applicant_checklist"]!.map((x) => x)),
      applicantCheckedChecklist: json["applicant_checkedChecklist"] == null
          ? []
          : List<String>.from(
              json["applicant_checkedChecklist"]!.map((x) => x)),
      isMovedin: json["isMovedin"],
      isApplicantDataEmpty: json["isApplicantDataEmpty"],
      isDelete: json["is_delete"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      applicantNotesAndFile: json["applicant_NotesAndFile"] == null
          ? []
          : List<ApplicantNotesAndFile>.from(json["applicant_NotesAndFile"]!
              .map((x) => ApplicantNotesAndFile.fromJson(x))),
      applicantStatus: json["applicant_status"] == null
          ? []
          : List<ApplicantStatus>.from(json["applicant_status"]!
              .map((x) => ApplicantStatus.fromJson(x))),
      v: json["__v"],
      rentalData: json["rentalData"] == null
          ? null
          : RentalData.fromJson(json["rentalData"]),
      unitData:
          json["unitData"] == null ? null : UnitData.fromJson(json["unitData"]),
      applicantEmailsendDate:
          DateTime.tryParse(json["applicant_emailsend_date"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "applicant_id": applicantId,
        "admin_id": adminId,
        "applicant_firstName": applicantFirstName,
        "applicant_lastName": applicantLastName,
        "applicant_email": applicantEmail,
        "applicant_phoneNumber": applicantPhoneNumber,
        "applicant_homeNumber": applicantHomeNumber,
        "applicant_businessNumber": applicantBusinessNumber,
        "applicant_telephoneNumber": applicantTelephoneNumber,
        "applicant_checklist": applicantChecklist.map((x) => x).toList(),
        "applicant_checkedChecklist":
            applicantCheckedChecklist.map((x) => x).toList(),
        "isMovedin": isMovedin,
        "isApplicantDataEmpty": isApplicantDataEmpty,
        "is_delete": isDelete,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "applicant_NotesAndFile":
            applicantNotesAndFile.map((x) => x?.toJson()).toList(),
        "applicant_status": applicantStatus.map((x) => x?.toJson()).toList(),
        "__v": v,
        "rentalData": rentalData?.toJson(),
        "unitData": unitData?.toJson(),
        "applicant_emailsend_date": applicantEmailsendDate?.toIso8601String(),
        'applicant': applicant?.toJson(),
        'lease': lease?.toJson(),
      };
  Map<String, dynamic> toUpdateJson() {
    final Map<String, dynamic> data = {};
    if (applicant != null) data['applicant'] = applicant!.toJson();
    if (lease != null) data['lease'] = lease!.toJson();
    return data;
  }
}

class ApplicantNotesAndFile {
  ApplicantNotesAndFile({
    required this.applicantNotes,
    required this.applicantFile,
    required this.id,
  });

  final String? applicantNotes;
  final String? applicantFile;
  final String? id;

  factory ApplicantNotesAndFile.fromJson(Map<String, dynamic> json) {
    return ApplicantNotesAndFile(
      applicantNotes: json["applicant_notes"],
      applicantFile: json["applicant_file"],
      id: json["_id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "applicant_notes": applicantNotes,
        "applicant_file": applicantFile,
        "_id": id,
      };
}

class ApplicantStatus {
  ApplicantStatus({
    required this.status,
    required this.updateAt,
    required this.statusUpdatedBy,
    required this.id,
  });

  final String? status;
  final DateTime? updateAt;
  final String? statusUpdatedBy;
  final String? id;

  factory ApplicantStatus.fromJson(Map<String, dynamic> json) {
    return ApplicantStatus(
      status: json["status"],
      updateAt: DateTime.tryParse(json["updateAt"] ?? ""),
      statusUpdatedBy: json["statusUpdatedBy"],
      id: json["_id"],
    );
  }

  Map<String, dynamic> toJson() => {
        "status": status,
        "updateAt": updateAt?.toIso8601String(),
        "statusUpdatedBy": statusUpdatedBy,
        "_id": id,
      };
}

class RentalData {
  RentalData({
    required this.id,
    required this.rentalId,
    required this.adminId,
    required this.rentalownerId,
    required this.propertyId,
    required this.rentalAdress,
    required this.isRentOn,
    required this.rentalCity,
    required this.rentalState,
    required this.rentalCountry,
    required this.rentalPostcode,
    required this.rentalImage,
    required this.staffmemberId,
    required this.createdAt,
    required this.updatedAt,
    required this.isDelete,
    required this.v,
  });

  final String? id;
  final String? rentalId;
  final String? adminId;
  final String? rentalownerId;
  final String? propertyId;
  final String? rentalAdress;
  final bool? isRentOn;
  final String? rentalCity;
  final String? rentalState;
  final String? rentalCountry;
  final String? rentalPostcode;
  final String? rentalImage;
  final String? staffmemberId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isDelete;
  final int? v;

  factory RentalData.fromJson(Map<String, dynamic> json) {
    return RentalData(
      id: json["_id"],
      rentalId: json["rental_id"],
      adminId: json["admin_id"],
      rentalownerId: json["rentalowner_id"],
      propertyId: json["property_id"],
      rentalAdress: json["rental_adress"],
      isRentOn: json["is_rent_on"],
      rentalCity: json["rental_city"],
      rentalState: json["rental_state"],
      rentalCountry: json["rental_country"],
      rentalPostcode: json["rental_postcode"],
      rentalImage: json["rental_image"],
      staffmemberId: json["staffmember_id"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      isDelete: json["is_delete"],
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "rental_id": rentalId,
        "admin_id": adminId,
        "rentalowner_id": rentalownerId,
        "property_id": propertyId,
        "rental_adress": rentalAdress,
        "is_rent_on": isRentOn,
        "rental_city": rentalCity,
        "rental_state": rentalState,
        "rental_country": rentalCountry,
        "rental_postcode": rentalPostcode,
        "rental_image": rentalImage,
        "staffmember_id": staffmemberId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "is_delete": isDelete,
        "__v": v,
      };
}

class ApplicantDetails {
  String? adminId;
  String? applicantFirstName;
  String? applicantLastName;
  String? applicantEmail;
  String? applicantPhoneNumber;
  String? applicantHomeNumber;
  String? applicantTelephoneNumber;
  String? applicantBusinessNumber;

  ApplicantDetails({
    this.adminId,
    this.applicantFirstName,
    this.applicantLastName,
    this.applicantEmail,
    this.applicantPhoneNumber,
    this.applicantHomeNumber,
    this.applicantTelephoneNumber,
    this.applicantBusinessNumber,
  });

  factory ApplicantDetails.fromJson(Map<String, dynamic> json) {
    return ApplicantDetails(
      adminId: json['admin_id'] as String?,
      applicantFirstName: json['applicant_firstName'] as String?,
      applicantLastName: json['applicant_lastName'] as String?,
      applicantEmail: json['applicant_email'] as String?,
      applicantPhoneNumber: json['applicant_phoneNumber'] as String?,
      applicantHomeNumber: json['applicant_homeNumber'] as String?,
      applicantTelephoneNumber: json['applicant_telephoneNumber'] as String?,
      applicantBusinessNumber: json['applicant_businessNumber'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'applicant_firstName': applicantFirstName,
      'applicant_lastName': applicantLastName,
      'applicant_email': applicantEmail,
      'applicant_phoneNumber': applicantPhoneNumber,
      'applicant_homeNumber': applicantHomeNumber,
      'applicant_telephoneNumber': applicantTelephoneNumber,
      'applicant_businessNumber': applicantBusinessNumber,
    };
  }
}

class LeaseApplicant {
  String? rentalAddress;
  String? rentalUnit;
  String? adminId;

  LeaseApplicant({
    this.rentalAddress,
    this.rentalUnit,
    this.adminId,
  });

  factory LeaseApplicant.fromJson(Map<String, dynamic> json) {
    return LeaseApplicant(
      rentalAddress: json['rental_address'] as String?,
      rentalUnit: json['rental_unit'] as String?,
      adminId: json['admin_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rental_address': rentalAddress,
      'rental_unit': rentalUnit,
      'admin_id': adminId,
    };
  }
}

class UnitData {
  UnitData({
    required this.id,
    required this.unitId,
    required this.rentalUnit,
    required this.adminId,
    required this.rentalId,
    required this.rentalUnitAdress,
    required this.rentalSqft,
    required this.rentalImages,
    required this.createdAt,
    required this.updatedAt,
    required this.isDelete,
    required this.v,
    required this.rentalBath,
    required this.rentalBed,
  });

  final String? id;
  final String? unitId;
  final String? rentalUnit;
  final String? adminId;
  final String? rentalId;
  final String? rentalUnitAdress;
  final String? rentalSqft;
  final List<String> rentalImages;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isDelete;
  final int? v;
  final String? rentalBath;
  final String? rentalBed;

  factory UnitData.fromJson(Map<String, dynamic> json) {
    return UnitData(
      id: json["_id"],
      unitId: json["unit_id"],
      rentalUnit: json["rental_unit"],
      adminId: json["admin_id"],
      rentalId: json["rental_id"],
      rentalUnitAdress: json["rental_unit_adress"],
      rentalSqft: json["rental_sqft"],
      rentalImages: json["rental_images"] == null
          ? []
          : List<String>.from(json["rental_images"]!.map((x) => x)),
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      isDelete: json["is_delete"],
      v: json["__v"],
      rentalBath: json["rental_bath"],
      rentalBed: json["rental_bed"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "unit_id": unitId,
        "rental_unit": rentalUnit,
        "admin_id": adminId,
        "rental_id": rentalId,
        "rental_unit_adress": rentalUnitAdress,
        "rental_sqft": rentalSqft,
        "rental_images": rentalImages.map((x) => x).toList(),
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "is_delete": isDelete,
        "__v": v,
        "rental_bath": rentalBath,
        "rental_bed": rentalBed,
      };
}
