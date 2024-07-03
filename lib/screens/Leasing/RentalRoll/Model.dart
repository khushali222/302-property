// import 'dart:convert';

// // ChargeData model
// class ChargeData {
//   final String adminId;
//   final List<ChargeEntry> entry;
//   final bool isLeaseAdded;

//   ChargeData(
//       {required this.adminId, required this.entry, required this.isLeaseAdded});

//   factory ChargeData.fromJson(Map<String, dynamic> json) {
//     return ChargeData(
//       adminId: json['admin_id'],
//       entry: List<ChargeEntry>.from(
//           json['entry'].map((e) => ChargeEntry.fromJson(e))),
//       isLeaseAdded: json['is_leaseAdded'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'admin_id': adminId,
//       'entry': entry.map((e) => e.toJson()).toList(),
//       'is_leaseAdded': isLeaseAdded,
//     };
//   }
// }

// class ChargeEntry {
//   final String account;
//   final double amount;
//   final String chargeType;
//   final String date;
//   final bool isRepeatable;
//   final String memo;
//   final String? rentCycle;
//   final String? tenantId;

//   ChargeEntry({
//     required this.account,
//     required this.amount,
//     required this.chargeType,
//     required this.date,
//     required this.isRepeatable,
//     required this.memo,
//     this.rentCycle,
//     this.tenantId,
//   });

//   factory ChargeEntry.fromJson(Map<String, dynamic> json) {
//     return ChargeEntry(
//       account: json['account'],
//       amount: json['amount'].toDouble(),
//       chargeType: json['charge_type'],
//       date: json['date'],
//       isRepeatable: json['is_repeatable'],
//       memo: json['memo'],
//       rentCycle: json['rent_cycle'],
//       tenantId: json['tenant_id'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'account': account,
//       'amount': amount,
//       'charge_type': chargeType,
//       'date': date,
//       'is_repeatable': isRepeatable,
//       'memo': memo,
//       'rent_cycle': rentCycle,
//       'tenant_id': tenantId,
//     };
//   }
// }

// // LeaseData model
// class LeaseData {
//   final String adminId;
//   final String companyName;
//   final String endDate;
//   final List<LeaseEntry> entry;
//   final double leaseAmount;
//   final String leaseType;
//   final String rentalId;
//   final String startDate;
//   final List<String> tenantId;
//   final bool tenantResidentStatus;
//   final String unitId;
//   final List<String> uploadedFile;

//   LeaseData({
//     required this.adminId,
//     required this.companyName,
//     required this.endDate,
//     required this.entry,
//     required this.leaseAmount,
//     required this.leaseType,
//     required this.rentalId,
//     required this.startDate,
//     required this.tenantId,
//     required this.tenantResidentStatus,
//     required this.unitId,
//     required this.uploadedFile,
//   });

//   factory LeaseData.fromJson(Map<String, dynamic> json) {
//     return LeaseData(
//       adminId: json['admin_id'],
//       companyName: json['company_name'],
//       endDate: json['end_date'],
//       entry: List<LeaseEntry>.from(
//           json['entry'].map((e) => LeaseEntry.fromJson(e))),
//       leaseAmount: json['lease_amount'].toDouble(),
//       leaseType: json['lease_type'],
//       rentalId: json['rental_id'],
//       startDate: json['start_date'],
//       tenantId: List<String>.from(json['tenant_id']),
//       tenantResidentStatus: json['tenant_residentStatus'],
//       unitId: json['unit_id'],
//       uploadedFile: List<String>.from(json['uploaded_file']),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'admin_id': adminId,
//       'company_name': companyName,
//       'end_date': endDate,
//       'entry': entry.map((e) => e.toJson()).toList(),
//       'lease_amount': leaseAmount,
//       'lease_type': leaseType,
//       'rental_id': rentalId,
//       'start_date': startDate,
//       'tenant_id': tenantId,
//       'tenant_residentStatus': tenantResidentStatus,
//       'unit_id': unitId,
//       'uploaded_file': uploadedFile,
//     };
//   }
// }

// class LeaseEntry {
//   final String account;
//   final double amount;
//   final String chargeType;
//   final String date;
//   final bool isRepeatable;
//   final String memo;
//   final String? rentCycle;
//   final String? tenantId;

//   LeaseEntry({
//     required this.account,
//     required this.amount,
//     required this.chargeType,
//     required this.date,
//     required this.isRepeatable,
//     required this.memo,
//     this.rentCycle,
//     this.tenantId,
//   });

//   factory LeaseEntry.fromJson(Map<String, dynamic> json) {
//     return LeaseEntry(
//       account: json['account'],
//       amount: json['amount'].toDouble(),
//       chargeType: json['charge_type'],
//       date: json['date'],
//       isRepeatable: json['is_repeatable'],
//       memo: json['memo'],
//       rentCycle: json['rent_cycle'],
//       tenantId: json['tenant_id'],
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'account': account,
//       'amount': amount,
//       'charge_type': chargeType,
//       'date': date,
//       'is_repeatable': isRepeatable,
//       'memo': memo,
//       'rent_cycle': rentCycle,
//       'tenant_id': tenantId,
//     };
//   }
// }

import 'dart:convert';

class Lease {
  ChargeData chargeData;
  CosignerData cosignerData;
  LeaseData leaseData;
  List<TenantData> tenantData;

  Lease({
    required this.chargeData,
    required this.cosignerData,
    required this.leaseData,
    required this.tenantData,
  });

  factory Lease.fromJson(Map<String, dynamic> json) {
    return Lease(
      chargeData: ChargeData.fromJson(json['chargeData']),
      cosignerData: CosignerData.fromJson(json['cosignerData']),
      leaseData: LeaseData.fromJson(json['leaseData']),
      tenantData: (json['tenantData'] as List)
          .map((i) => TenantData.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chargeData': chargeData.toJson(),
      'cosignerData': cosignerData.toJson(),
      'leaseData': leaseData.toJson(),
      'tenantData': tenantData.map((i) => i.toJson()).toList(),
    };
  }
}

class ChargeData {
  String adminId;
  List<Entry> entry;
  bool isLeaseAdded;

  ChargeData({
    required this.adminId,
    required this.entry,
    required this.isLeaseAdded,
  });

  factory ChargeData.fromJson(Map<String, dynamic> json) {
    return ChargeData(
      adminId: json['admin_id'],
      entry: (json['entry'] as List).map((i) => Entry.fromJson(i)).toList(),
      isLeaseAdded: json['is_leaseAdded'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'entry': entry.map((i) => i.toJson()).toList(),
      'is_leaseAdded': isLeaseAdded,
    };
  }
}

class Entry {
  String account;
  dynamic amount;
  String chargeType;
  String date;
  bool isRepeatable;
  String memo;
  String? rentCycle;
  String? tenantId;

  Entry({
    required this.account,
    required this.amount,
    required this.chargeType,
    required this.date,
    required this.isRepeatable,
    required this.memo,
    this.rentCycle,
    this.tenantId,
  });

  factory Entry.fromJson(Map<String, dynamic> json) {
    return Entry(
      account: json['account'],
      amount: json['amount'],
      chargeType: json['charge_type'],
      date: json['date'],
      isRepeatable: json['is_repeatable'],
      memo: json['memo'],
      rentCycle: json['rent_cycle'],
      tenantId: json['tenant_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'amount': amount,
      'charge_type': chargeType,
      'date': date,
      'is_repeatable': isRepeatable,
      'memo': memo,
      'rent_cycle': rentCycle,
      'tenant_id': tenantId,
    };
  }
}

class CosignerData {
  String adminId;
  String cosignerAddress;
  String cosignerAlternativeEmail;
  String cosignerAlternativeNumber;
  String cosignerCity;
  String cosignerCountry;
  String cosignerEmail;
  String cosignerFirstName;
  String cosignerId;
  String cosignerLastName;
  String cosignerPhoneNumber;
  String cosignerPostalcode;

  CosignerData({
    required this.adminId,
    required this.cosignerAddress,
    required this.cosignerAlternativeEmail,
    required this.cosignerAlternativeNumber,
    required this.cosignerCity,
    required this.cosignerCountry,
    required this.cosignerEmail,
    required this.cosignerFirstName,
    required this.cosignerId,
    required this.cosignerLastName,
    required this.cosignerPhoneNumber,
    required this.cosignerPostalcode,
  });

  factory CosignerData.fromJson(Map<String, dynamic> json) {
    return CosignerData(
      adminId: json['admin_id'],
      cosignerAddress: json['cosigner_address'],
      cosignerAlternativeEmail: json['cosigner_alternativeEmail'],
      cosignerAlternativeNumber: json['cosigner_alternativeNumber'],
      cosignerCity: json['cosigner_city'],
      cosignerCountry: json['cosigner_country'],
      cosignerEmail: json['cosigner_email'],
      cosignerFirstName: json['cosigner_firstName'],
      cosignerId: json['cosigner_id'],
      cosignerLastName: json['cosigner_lastName'],
      cosignerPhoneNumber: json['cosigner_phoneNumber'],
      cosignerPostalcode: json['cosigner_postalcode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'cosigner_address': cosignerAddress,
      'cosigner_alternativeEmail': cosignerAlternativeEmail,
      'cosigner_alternativeNumber': cosignerAlternativeNumber,
      'cosigner_city': cosignerCity,
      'cosigner_country': cosignerCountry,
      'cosigner_email': cosignerEmail,
      'cosigner_firstName': cosignerFirstName,
      'cosigner_id': cosignerId,
      'cosigner_lastName': cosignerLastName,
      'cosigner_phoneNumber': cosignerPhoneNumber,
      'cosigner_postalcode': cosignerPostalcode,
    };
  }
}

class LeaseData {
  String adminId;
  String companyName;
  String endDate;
  List<Entry> entry;
  int leaseAmount;
  String leaseType;
  String rentalId;
  String startDate;
  List<String> tenantId;
  bool tenantResidentStatus;
  String unitId;
  List<String> uploadedFile;

  LeaseData({
    required this.adminId,
    required this.companyName,
    required this.endDate,
    required this.entry,
    required this.leaseAmount,
    required this.leaseType,
    required this.rentalId,
    required this.startDate,
    required this.tenantId,
    required this.tenantResidentStatus,
    required this.unitId,
    required this.uploadedFile,
  });

  factory LeaseData.fromJson(Map<String, dynamic> json) {
    return LeaseData(
      adminId: json['admin_id'],
      companyName: json['company_name'],
      endDate: json['end_date'],
      entry: (json['entry'] as List).map((i) => Entry.fromJson(i)).toList(),
      leaseAmount: json['lease_amount'],
      leaseType: json['lease_type'],
      rentalId: json['rental_id'],
      startDate: json['start_date'],
      tenantId: List<String>.from(json['tenant_id']),
      tenantResidentStatus: json['tenant_residentStatus'],
      unitId: json['unit_id'],
      uploadedFile: List<String>.from(json['uploaded_file']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'company_name': companyName,
      'end_date': endDate,
      'entry': entry.map((i) => i.toJson()).toList(),
      'lease_amount': leaseAmount,
      'lease_type': leaseType,
      'rental_id': rentalId,
      'start_date': startDate,
      'tenant_id': tenantId,
      'tenant_residentStatus': tenantResidentStatus,
      'unit_id': unitId,
      'uploaded_file': uploadedFile,
    };
  }
}

class TenantData {
  String adminId;
  String comments;
  String createdAt;
  EmergencyContactLease emergencyContact;
  bool isDelete;
  String rentalAddress;
  String rentalUnit;
  String taxPayerId;
  String tenantAlternativeEmail;
  String tenantAlternativeNumber;
  String tenantBirthDate;
  String tenantEmail;
  String tenantFirstName;
  String tenantId;
  String tenantLastName;
  String tenantPassword;
  String tenantPhoneNumber;
  String updatedAt;
  int v;
  String id;

  TenantData({
    required this.adminId,
    required this.comments,
    required this.createdAt,
    required this.emergencyContact,
    required this.isDelete,
    required this.rentalAddress,
    required this.rentalUnit,
    required this.taxPayerId,
    required this.tenantAlternativeEmail,
    required this.tenantAlternativeNumber,
    required this.tenantBirthDate,
    required this.tenantEmail,
    required this.tenantFirstName,
    required this.tenantId,
    required this.tenantLastName,
    required this.tenantPassword,
    required this.tenantPhoneNumber,
    required this.updatedAt,
    required this.v,
    required this.id,
  });

  factory TenantData.fromJson(Map<String, dynamic> json) {
    return TenantData(
      adminId: json['admin_id'],
      comments: json['comments'],
      createdAt: json['createdAt'],
      emergencyContact:
          EmergencyContactLease.fromJson(json['emergency_contact']),
      isDelete: json['is_delete'],
      rentalAddress: json['rental_adress'],
      rentalUnit: json['rental_unit'],
      taxPayerId: json['taxPayer_id'],
      tenantAlternativeEmail: json['tenant_alternativeEmail'],
      tenantAlternativeNumber: json['tenant_alternativeNumber'],
      tenantBirthDate: json['tenant_birthDate'],
      tenantEmail: json['tenant_email'],
      tenantFirstName: json['tenant_firstName'],
      tenantId: json['tenant_id'],
      tenantLastName: json['tenant_lastName'],
      tenantPassword: json['tenant_password'],
      tenantPhoneNumber: json['tenant_phoneNumber'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'comments': comments,
      'createdAt': createdAt,
      'emergency_contact': emergencyContact.toJson(),
      'is_delete': isDelete,
      'rental_adress': rentalAddress,
      'rental_unit': rentalUnit,
      'taxPayer_id': taxPayerId,
      'tenant_alternativeEmail': tenantAlternativeEmail,
      'tenant_alternativeNumber': tenantAlternativeNumber,
      'tenant_birthDate': tenantBirthDate,
      'tenant_email': tenantEmail,
      'tenant_firstName': tenantFirstName,
      'tenant_id': tenantId,
      'tenant_lastName': tenantLastName,
      'tenant_password': tenantPassword,
      'tenant_phoneNumber': tenantPhoneNumber,
      'updatedAt': updatedAt,
      '__v': v,
      '_id': id,
    };
  }
}

class EmergencyContactLease {
  String name;
  String relation;
  String email;
  String phoneNumber;

  EmergencyContactLease({
    required this.name,
    required this.relation,
    required this.email,
    required this.phoneNumber,
  });

  factory EmergencyContactLease.fromJson(Map<String, dynamic> json) {
    return EmergencyContactLease(
      name: json['name'],
      relation: json['relation'],
      email: json['email'],
      phoneNumber: json['phoneNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relation': relation,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }
}
