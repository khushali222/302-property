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
    applicantCheckedChecklist =
        json['applicant_checkedChecklist'];
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
