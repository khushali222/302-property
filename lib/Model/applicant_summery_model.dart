class applicant_summery_details {
  String? sId;
  String? applicantId;
  String? adminId;
  String? applicantFirstName;
  String? applicantLastName;
  String? applicantEmail;
  String? applicantPhoneNumber;
  String? applicantHomeNumber;
  String? applicantBusinessNumber;
  String? applicantTelephoneNumber;
  List? applicantChecklist;
  List? applicantCheckedChecklist;
  bool? isMovedin;
  String? createdAt;
  String? updatedAt;
  List<ApplicantNotesAndFile>? applicantNotesAndFile;
  List<ApplicantStatus>? applicantStatus;

  bool? isApplicantDataEmpty;
  String? applicantEmailsendDate;

  LeaseData? leaseData;

  applicant_summery_details(
      {this.sId,
      this.applicantId,
      this.adminId,
      this.applicantFirstName,
      this.applicantLastName,
      this.applicantEmail,
      this.applicantPhoneNumber,
      this.applicantHomeNumber,
      this.applicantBusinessNumber,
      this.applicantTelephoneNumber,
      this.applicantChecklist,
      this.applicantCheckedChecklist,
      this.isMovedin,
      this.createdAt,
      this.updatedAt,
      this.applicantNotesAndFile,
      this.applicantStatus,
      this.isApplicantDataEmpty,
      this.applicantEmailsendDate,
      this.leaseData});

  applicant_summery_details.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    print(sId);
    applicantId = json['applicant_id'];
    print(applicantId);
    adminId = json['admin_id'];
    print(adminId);
    applicantFirstName = json['applicant_firstName'];
    print(applicantFirstName);
    applicantLastName = json['applicant_lastName'];
    print(applicantLastName);
    applicantEmail = json['applicant_email'];
    print(applicantEmail);
    applicantPhoneNumber = json['applicant_phoneNumber'];
    print(applicantPhoneNumber);
    applicantHomeNumber = json['applicant_homeNumber'];
    print(applicantHomeNumber);
    applicantBusinessNumber = json['applicant_businessNumber'];
    print(applicantBusinessNumber);
    applicantTelephoneNumber = json['applicant_telephoneNumber'];
    print(applicantTelephoneNumber);
    if (json['applicant_checklist'] != null) {
      applicantChecklist = <String>[];
      json['applicant_checklist'].forEach((v) {
        applicantChecklist!.add(v);
      });
    }
    print(applicantChecklist);
    applicantCheckedChecklist = json['applicant_checkedChecklist'];
    print(applicantCheckedChecklist);
    isMovedin = json['isMovedin'];
    print(isMovedin);
    createdAt = json['createdAt'];
    print(createdAt);
    updatedAt = json['updatedAt'];
    print(updatedAt);
    if (json['applicant_NotesAndFile'] != null) {
      applicantNotesAndFile = <ApplicantNotesAndFile>[];
      json['applicant_NotesAndFile'].forEach((v) {
        applicantNotesAndFile!.add(new ApplicantNotesAndFile.fromJson(v));
      });
    }
    print(applicantNotesAndFile);
    if (json['applicant_status'] != null) {
      applicantStatus = <ApplicantStatus>[];
      json['applicant_status'].forEach((v) {
        applicantStatus!.add(new ApplicantStatus.fromJson(v));
      });
    }
    print(applicantStatus);
    isApplicantDataEmpty = json['isApplicantDataEmpty'];
    print(isApplicantDataEmpty);
    applicantEmailsendDate = json['applicant_emailsend_date'];
    print(applicantEmailsendDate);
    leaseData = json['lease_data'] != null
        ? new LeaseData.fromJson(json['lease_data'])
        : null;
    print(leaseData);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['applicant_id'] = this.applicantId;
    data['admin_id'] = this.adminId;
    data['applicant_firstName'] = this.applicantFirstName;
    data['applicant_lastName'] = this.applicantLastName;
    data['applicant_email'] = this.applicantEmail;
    data['applicant_phoneNumber'] = this.applicantPhoneNumber;
    data['applicant_homeNumber'] = this.applicantHomeNumber;
    data['applicant_businessNumber'] = this.applicantBusinessNumber;
    data['applicant_telephoneNumber'] = this.applicantTelephoneNumber;
    /* if (this.applicantChecklist != null) {
      data['applicant_checklist'] =
          this.applicantChecklist!.map((v) => v.toJson()).toList();
    }*/
    data['applicant_checkedChecklist'] = this.applicantCheckedChecklist;
    data['isMovedin'] = this.isMovedin;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.applicantNotesAndFile != null) {
      data['applicant_NotesAndFile'] =
          this.applicantNotesAndFile!.map((v) => v.toJson()).toList();
    }
    if (this.applicantStatus != null) {
      data['applicant_status'] =
          this.applicantStatus!.map((v) => v.toJson()).toList();
    }

    data['isApplicantDataEmpty'] = this.isApplicantDataEmpty;
    data['applicant_emailsend_date'] = this.applicantEmailsendDate;

    if (this.leaseData != null) {
      data['lease_data'] = this.leaseData!.toJson();
    }
    return data;
  }
}

class ApplicantNotesAndFile {
  String? applicantNotes;
  String? applicantFile;
  String? sId;

  ApplicantNotesAndFile({this.applicantNotes, this.applicantFile, this.sId});

  ApplicantNotesAndFile.fromJson(Map<String, dynamic> json) {
    applicantNotes = json['applicant_notes'];
    applicantFile = json['applicant_file'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['applicant_notes'] = this.applicantNotes;
    data['applicant_file'] = this.applicantFile;
    data['_id'] = this.sId;
    return data;
  }
}

class ApplicantStatus {
  String? status;
  String? updateAt;
  String? statusUpdatedBy;
  String? sId;

  ApplicantStatus({this.status, this.updateAt, this.statusUpdatedBy, this.sId});

  ApplicantStatus.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    updateAt = json['updateAt'];
    statusUpdatedBy = json['statusUpdatedBy'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['updateAt'] = this.updateAt;
    data['statusUpdatedBy'] = this.statusUpdatedBy;
    data['_id'] = this.sId;
    return data;
  }
}

class LeaseData {
  String? sId;
  String? leaseId;
  String? applicantId;
  String? adminId;
  String? rentalId;
  String? unitId;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? rentalAdress;
  String? rentalUnit;

  LeaseData(
      {this.sId,
      this.leaseId,
      this.applicantId,
      this.adminId,
      this.rentalId,
      this.unitId,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.rentalAdress,
      this.rentalUnit});

  LeaseData.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    leaseId = json['lease_id'];
    applicantId = json['applicant_id'];
    adminId = json['admin_id'];
    rentalId = json['rental_id'];
    unitId = json['unit_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    rentalAdress = json['rental_adress'];
    rentalUnit = json['rental_unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['lease_id'] = this.leaseId;
    data['applicant_id'] = this.applicantId;
    data['admin_id'] = this.adminId;
    data['rental_id'] = this.rentalId;
    data['unit_id'] = this.unitId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['rental_adress'] = this.rentalAdress;
    data['rental_unit'] = this.rentalUnit;
    return data;
  }
}

class ApplicantContentDetails {
  int? statusCode;
  Data? data;
  String? message;

  ApplicantContentDetails({this.statusCode, this.data, this.message});

  ApplicantContentDetails.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class Data {
  EmergencyContact? emergencyContact;
  RentalHistory? rentalHistory;
  Employment? employment;
  String? sId;
  String? applicantId;
  String? adminId;
  String? applicantStreetAddress;
  String? applicantCity;
  String? applicantState;
  String? applicantCountry;
  String? applicantPostalCode;
  String? agreeBy;
  int? iV;
  String? applicantFirstName;
  String? applicantLastName;
  String? applicantEmail;
  String? applicantPhoneNumber;
  bool? isApplicantDataEmpty;

  Data({
    this.emergencyContact,
    this.rentalHistory,
    this.employment,
    this.sId,
    this.applicantId,
    this.adminId,
    this.applicantStreetAddress,
    this.applicantCity,
    this.applicantState,
    this.applicantCountry,
    this.applicantPostalCode,
    this.agreeBy,
    this.iV,
    this.applicantFirstName,
    this.applicantLastName,
    this.applicantEmail,
    this.applicantPhoneNumber,
    this.isApplicantDataEmpty = false,
  });

  Data.fromJson(Map<String, dynamic> json) {
    print(json['isApplicantDataEmpty']);
    emergencyContact = json['emergency_contact'] != null
        ? new EmergencyContact.fromJson(json['emergency_contact'])
        : null;
    rentalHistory = json['rental_history'] != null
        ? new RentalHistory.fromJson(json['rental_history'])
        : null;
    employment = json['employment'] != null
        ? new Employment.fromJson(json['employment'])
        : null;
    // sId = json['_id'];
    applicantId = json['applicant_id'];

    adminId = json['admin_id'];
    applicantStreetAddress = json['applicant_streetAddress'];
    applicantCity = json['applicant_city'];
    applicantState = json['applicant_state'];
    applicantCountry = json['applicant_country'];
    applicantPostalCode = json['applicant_postalCode'];

    agreeBy = json['agreeBy'];
    // iV = json['__v'];
    applicantFirstName = json['applicant_firstName'];
    applicantLastName = json['applicant_lastName'];
    applicantEmail = json['applicant_email'];
    applicantPhoneNumber = json['applicant_phoneNumber'];
    isApplicantDataEmpty = json['isApplicantDataEmpty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.emergencyContact != null) {
      data['emergency_contact'] = this.emergencyContact!.toJson();
    }
    if (this.rentalHistory != null) {
      data['rental_history'] = this.rentalHistory!.toJson();
    }
    if (this.employment != null) {
      data['employment'] = this.employment!.toJson();
    }
    // data['_id'] = this.sId;
    data['applicant_id'] = this.applicantId;
    data['admin_id'] = this.adminId;
    data['applicant_streetAddress'] = this.applicantStreetAddress;
    data['applicant_city'] = this.applicantCity;
    data['applicant_state'] = this.applicantState;
    data['applicant_country'] = this.applicantCountry;
    data['applicant_postalCode'] = this.applicantPostalCode;
    data['agreeBy'] = this.agreeBy;
    // data['__v'] = this.iV;
    data['applicant_firstName'] = this.applicantFirstName;
    data['applicant_lastName'] = this.applicantLastName;
    data['applicant_email'] = this.applicantEmail;
    data['applicant_phoneNumber'] = this.applicantPhoneNumber;
    return data;
  }
}

class EmergencyContact {
  String? firstName;
  String? lastName;
  String? relationship;
  String? email;
  int? phoneNumber;

  EmergencyContact(
      {this.firstName,
      this.lastName,
      this.relationship,
      this.email,
      this.phoneNumber});

  EmergencyContact.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    relationship = json['relationship'];
    email = json['email'];
    phoneNumber = json['phone_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['relationship'] = this.relationship;
    data['email'] = this.email;
    data['phone_number'] = this.phoneNumber;
    return data;
  }
}

class RentalHistory {
  String? rentalAdress;
  String? rentalCity;
  String? rentalState;
  String? rentalCountry;
  String? rentalPostcode;
  String? rentalOwnerFirstName;
  String? rentalOwnerLastName;
  String? startDate;
  String? endDate;
  String? rent;
  String? leavingReason;
  String? rentalOwnerPrimaryEmail;
  int? rentalOwnerPhoneNumber;

  RentalHistory(
      {this.rentalAdress,
      this.rentalCity,
      this.rentalState,
      this.rentalCountry,
      this.rentalPostcode,
      this.rentalOwnerFirstName,
      this.rentalOwnerLastName,
      this.startDate,
      this.endDate,
      this.rent,
      this.leavingReason,
      this.rentalOwnerPrimaryEmail,
      this.rentalOwnerPhoneNumber});

  RentalHistory.fromJson(Map<String, dynamic> json) {
    rentalAdress = json['rental_adress'];
    rentalCity = json['rental_city'];
    rentalState = json['rental_state'];
    rentalCountry = json['rental_country'];
    rentalPostcode = json['rental_postcode'];
    rentalOwnerFirstName = json['rentalOwner_firstName'];
    rentalOwnerLastName = json['rentalOwner_lastName'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    rent = json['rent'];
    leavingReason = json['leaving_reason'];
    rentalOwnerPrimaryEmail = json['rentalOwner_primaryEmail'];
    rentalOwnerPhoneNumber = json['rentalOwner_phoneNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rental_adress'] = this.rentalAdress;
    data['rental_city'] = this.rentalCity;
    data['rental_state'] = this.rentalState;
    data['rental_country'] = this.rentalCountry;
    data['rental_postcode'] = this.rentalPostcode;
    data['rentalOwner_firstName'] = this.rentalOwnerFirstName;
    data['rentalOwner_lastName'] = this.rentalOwnerLastName;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['rent'] = this.rent;
    data['leaving_reason'] = this.leavingReason;
    data['rentalOwner_primaryEmail'] = this.rentalOwnerPrimaryEmail;
    data['rentalOwner_phoneNumber'] = this.rentalOwnerPhoneNumber;
    return data;
  }
}

class Employment {
  String? name;
  String? streetAddress;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  String? employmentPrimaryEmail;
  int? employmentPhoneNumber;
  String? employmentPosition;
  String? supervisorFirstName;
  String? supervisorLastName;
  String? supervisorTitle;

  Employment(
      {this.name,
      this.streetAddress,
      this.city,
      this.state,
      this.country,
      this.postalCode,
      this.employmentPrimaryEmail,
      this.employmentPhoneNumber,
      this.employmentPosition,
      this.supervisorFirstName,
      this.supervisorLastName,
      this.supervisorTitle});

  Employment.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    streetAddress = json['streetAddress'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    postalCode = json['postalCode'];
    employmentPrimaryEmail = json['employment_primaryEmail'];
    employmentPhoneNumber = json['employment_phoneNumber'];
    employmentPosition = json['employment_position'];
    supervisorFirstName = json['supervisor_firstName'];
    supervisorLastName = json['supervisor_lastName'];
    supervisorTitle = json['supervisor_title'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['name'] = this.name;
    data['streetAddress'] = this.streetAddress;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['postalCode'] = this.postalCode;
    data['employment_primaryEmail'] = this.employmentPrimaryEmail;
    data['employment_phoneNumber'] = this.employmentPhoneNumber;
    data['employment_position'] = this.employmentPosition;
    data['supervisor_firstName'] = this.supervisorFirstName;
    data['supervisor_lastName'] = this.supervisorLastName;
    data['supervisor_title'] = this.supervisorTitle;
    return data;
  }
}

class NoteFile {
  String note;
  String files;

  NoteFile({
    required this.note,
    required this.files,
  });

  // Factory method to create a NoteFile from JSON
  factory NoteFile.fromJson(Map<String, dynamic> json) {
    return NoteFile(
      note: json['applicant_notes'] ?? '',
      files: json['applicant_file'] ?? '',
    );
  }

  // Method to convert a NoteFile to JSON
  Map<String, dynamic> toJson() {
    return {
      'applicant_notes': note,
      'applicant_file': files,
    };
  }
}

class ApproveRejectApplicantDetail {
  String? id;
  String? leaseId;
  String? applicantId;
  String? adminId;
  String? rentalId;
  String? unitId;
  String? createdAt;
  String? updatedAt;
  int? v;
  String? rentalAddress;
  String? rentalUnit;

  ApproveRejectApplicantDetail({
    this.id,
    this.leaseId,
    this.applicantId,
    this.adminId,
    this.rentalId,
    this.unitId,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.rentalAddress,
    this.rentalUnit,
  });

  ApproveRejectApplicantDetail.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    leaseId = json['lease_id'];
    applicantId = json['applicant_id'];
    adminId = json['admin_id'];
    rentalId = json['rental_id'];
    unitId = json['unit_id'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    v = json['__v'];
    rentalAddress = json['rental_adress'];
    rentalUnit = json['rental_unit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = id;
    data['lease_id'] = leaseId;
    data['applicant_id'] = applicantId;
    data['admin_id'] = adminId;
    data['rental_id'] = rentalId;
    data['unit_id'] = unitId;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['__v'] = v;
    data['rental_adress'] = rentalAddress;
    data['rental_unit'] = rentalUnit;
    return data;
  }
}
