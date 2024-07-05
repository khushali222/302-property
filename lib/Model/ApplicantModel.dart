class ApplicantData {
  ApplicantDetails? applicant;
  LeaseApplicant? lease;

  ApplicantData({this.applicant, this.lease});

  ApplicantData.fromJson(Map<String, dynamic> json) {
    applicant = json['applicant'] != null
        ? ApplicantDetails.fromJson(json['applicant'])
        : null;
    lease =
        json['lease'] != null ? LeaseApplicant.fromJson(json['lease']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (applicant != null) {
      data['applicant'] = applicant!.toJson();
    }
    if (lease != null) {
      data['lease'] = lease!.toJson();
    }
    return data;
  }
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

  ApplicantDetails.fromJson(Map<String, dynamic> json) {
    adminId = json['admin_id'];
    applicantFirstName = json['applicant_firstName'];
    applicantLastName = json['applicant_lastName'];
    applicantEmail = json['applicant_email'];
    applicantPhoneNumber = json['applicant_phoneNumber'];
    applicantHomeNumber = json['applicant_homeNumber'];
    applicantTelephoneNumber = json['applicant_telephoneNumber'];
    applicantBusinessNumber = json['applicant_businessNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['admin_id'] = adminId;
    data['applicant_firstName'] = applicantFirstName;
    data['applicant_lastName'] = applicantLastName;
    data['applicant_email'] = applicantEmail;
    data['applicant_phoneNumber'] = applicantPhoneNumber;
    data['applicant_homeNumber'] = applicantHomeNumber;
    data['applicant_telephoneNumber'] = applicantTelephoneNumber;
    data['applicant_businessNumber'] = applicantBusinessNumber;
    return data;
  }
}

class LeaseApplicant {
  String? rentalAddress;
  String? rentalUnit;
  String? adminId;

  LeaseApplicant({this.rentalAddress, this.rentalUnit, this.adminId});

  LeaseApplicant.fromJson(Map<String, dynamic> json) {
    rentalAddress = json['rental_address'];
    rentalUnit = json['rental_unit'];
    adminId = json['admin_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rental_address'] = rentalAddress;
    data['rental_unit'] = rentalUnit;
    data['admin_id'] = adminId;
    return data;
  }
}
