// import 'dart:convert';
//
// class RentPastDue {
//   final int currentMonthRentDue;
//   final int lastMonthRentDue;
//   final int currentMonthRentPaid;
//   final int lastMonthRentPaid;
//   final int totalRentPastDue;
//   final CurrentDueRentCharges currentDueRentCharges;
//   final LastDueRentCharges lastDueRentCharges;
//   final DueRentCharges dueRentCharges;
//   final CurrentPayments currentPayments;
//   final LastPayments lastPayments;
//
//   RentPastDue({
//     required this.currentMonthRentDue,
//     required this.lastMonthRentDue,
//     required this.currentMonthRentPaid,
//     required this.lastMonthRentPaid,
//     required this.totalRentPastDue,
//     required this.currentDueRentCharges,
//     required this.lastDueRentCharges,
//     required this.dueRentCharges,
//     required this.currentPayments,
//     required this.lastPayments,
//   });
//
//   factory RentPastDue.fromJson(Map<String, dynamic> json) {
//     return RentPastDue(
//       currentMonthRentDue: json['currentMonthRentDue'] ?? 0,
//       lastMonthRentDue: json['lastMonthRentDue'] ?? 0,
//       currentMonthRentPaid: json['currentMonthRentPaid'] ?? 0,
//       lastMonthRentPaid: json['lastMonthRentPaid'] ?? 0,
//       totalRentPastDue: json['totalRentPastDue'] ?? 0,
//       currentDueRentCharges: CurrentDueRentCharges.fromJson(json['currentDueRentCharges']),
//       lastDueRentCharges: LastDueRentCharges.fromJson(json['lastDueRentCharges']),
//       dueRentCharges: DueRentCharges.fromJson(json['dueRentCharges']),
//       currentPayments: CurrentPayments.fromJson(json['currentPayments']),
//       lastPayments: LastPayments.fromJson(json['lastPayments']),
//     );
//   }
// }
//
// class CurrentDueRentCharges {
//   final List<Charge> charges;
//   final int total;
//
//   CurrentDueRentCharges({
//     required this.charges,
//     required this.total,
//   });
//
//   factory CurrentDueRentCharges.fromJson(Map<String, dynamic> json) {
//     var chargesList = json['charges'] as List? ?? [];
//     List<Charge> charges = chargesList.map((i) => Charge.fromJson(i)).toList();
//
//     return CurrentDueRentCharges(
//       charges: charges,
//       total: json['total'] ?? 0,
//     );
//   }
// }
//
// class LastDueRentCharges {
//   final List<dynamic> charges; // Assuming it can be empty
//   final int total;
//
//   LastDueRentCharges({
//     required this.charges,
//     required this.total,
//   });
//
//   factory LastDueRentCharges.fromJson(Map<String, dynamic> json) {
//     return LastDueRentCharges(
//       charges: json['charges'] ?? [],
//       total: json['total'] ?? 0,
//     );
//   }
// }
//
// class DueRentCharges {
//   final List<Charge> charges;
//   final int total;
//
//   DueRentCharges({
//     required this.charges,
//     required this.total,
//   });
//
//   factory DueRentCharges.fromJson(Map<String, dynamic> json) {
//     var chargesList = json['charges'] as List? ?? [];
//     List<Charge> charges = chargesList.map((i) => Charge.fromJson(i)).toList();
//
//     return DueRentCharges(
//       charges: charges,
//       total: json['total'] ?? 0,
//     );
//   }
// }
//
// class Charge {
//   final String leaseId;
//   final RentalData rentalData;
//   final TenantData tenantData;
//   final UnitData unitData;
//   final List<Entry> entry;
//   final int total;
//
//   Charge({
//     required this.leaseId,
//     required this.rentalData,
//     required this.tenantData,
//     required this.unitData,
//     required this.entry,
//     required this.total,
//   });
//
//   factory Charge.fromJson(Map<String, dynamic> json) {
//     var entryList = json['entry'] as List? ?? [];
//     List<Entry> entries = entryList.map((i) => Entry.fromJson(i)).toList();
//
//     return Charge(
//       leaseId: json['lease_id'] ?? '',
//       rentalData: RentalData.fromJson(json['rental_data']),
//       tenantData: TenantData.fromJson(json['tenant_data']),
//       unitData: UnitData.fromJson(json['unit_data']),
//       entry: entries,
//       total: json['total'] ?? 0,
//     );
//   }
// }
//
// class RentalData {
//   final String id;
//   final String rentalId;
//   final String adminId;
//   final String rentalOwnerId;
//   final String propertyId;
//   final String rentalAddress;
//   final bool isRentOn;
//   final String rentalCity;
//   final String rentalState;
//   final String rentalCountry;
//   final String rentalPostcode;
//   final String rentalImage;
//   final String staffMemberId;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   RentalData({
//     required this.id,
//     required this.rentalId,
//     required this.adminId,
//     required this.rentalOwnerId,
//     required this.propertyId,
//     required this.rentalAddress,
//     required this.isRentOn,
//     required this.rentalCity,
//     required this.rentalState,
//     required this.rentalCountry,
//     required this.rentalPostcode,
//     required this.rentalImage,
//     required this.staffMemberId,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory RentalData.fromJson(Map<String, dynamic> json) {
//     return RentalData(
//       id: json['_id'] ?? '',
//       rentalId: json['rental_id'] ?? '',
//       adminId: json['admin_id'] ?? '',
//       rentalOwnerId: json['rentalowner_id'] ?? '',
//       propertyId: json['property_id'] ?? '',
//       rentalAddress: json['rental_adress'] ?? '',
//       isRentOn: json['is_rent_on'] ?? false,
//       rentalCity: json['rental_city'] ?? '',
//       rentalState: json['rental_state'] ?? '',
//       rentalCountry: json['rental_country'] ?? '',
//       rentalPostcode: json['rental_postcode'] ?? '',
//       rentalImage: json['rental_image'] ?? '',
//       staffMemberId: json['staffmember_id'] ?? '',
//       createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
//       updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
//     );
//   }
// }
//
// class TenantData {
//   final String id;
//   final String tenantId;
//   final String adminId;
//   final String tenantFirstName;
//   final String tenantLastName;
//   final String tenantPhoneNumber;
//   final String tenantAlternativeNumber;
//   final String tenantEmail;
//   final String tenantAlternativeEmail;
//   final String tenantPassword;
//   final String tenantBirthDate;
//   final String taxPayerId;
//   final String comments;
//   final EmergencyContact emergencyContact;
//   final bool enableOverrideFee;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   TenantData({
//     required this.id,
//     required this.tenantId,
//     required this.adminId,
//     required this.tenantFirstName,
//     required this.tenantLastName,
//     required this.tenantPhoneNumber,
//     required this.tenantAlternativeNumber,
//     required this.tenantEmail,
//     required this.tenantAlternativeEmail,
//     required this.tenantPassword,
//     required this.tenantBirthDate,
//     required this.taxPayerId,
//     required this.comments,
//     required this.emergencyContact,
//     required this.enableOverrideFee,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory TenantData.fromJson(Map<String, dynamic> json) {
//     return TenantData(
//       id: json['_id'] ?? '',
//       tenantId: json['tenant_id'] ?? '',
//       adminId: json['admin_id'] ?? '',
//       tenantFirstName: json['tenant_firstName'] ?? '',
//       tenantLastName: json['tenant_lastName'] ?? '',
//       tenantPhoneNumber: json['tenant_phoneNumber'] ?? '',
//       tenantAlternativeNumber: json['tenant_alternativeNumber'] ?? '',
//       tenantEmail: json['tenant_email'] ?? '',
//       tenantAlternativeEmail: json['tenant_alternativeEmail'] ?? '',
//       tenantPassword: json['tenant_password'] ?? '',
//       tenantBirthDate: json['tenant_birthDate'] ?? '',
//       taxPayerId: json['taxPayer_id'] ?? '',
//       comments: json['comments'] ?? '',
//       emergencyContact: EmergencyContact.fromJson(json['emergency_contact'] ?? {}),
//       enableOverrideFee: json['enable_override_fee'] ?? false,
//       createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
//       updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
//     );
//   }
// }
//
// class EmergencyContact {
//   final String name;
//   final String relation;
//   final String email;
//   final String phoneNumber;
//
//   EmergencyContact({
//     required this.name,
//     required this.relation,
//     required this.email,
//     required this.phoneNumber,
//   });
//
//   factory EmergencyContact.fromJson(Map<String, dynamic> json) {
//     return EmergencyContact(
//       name: json['name'] ?? '',
//       relation: json['relation'] ?? '',
//       email: json['email'] ?? '',
//       phoneNumber: json['phoneNumber'] ?? '',
//     );
//   }
// }
//
// class UnitData {
//   final String id;
//   final String unitId;
//   final String rentalUnit;
//   final String adminId;
//   final String rentalId;
//   final String rentalUnitAddress;
//   final String rentalSqft;
//   final String rentalBath;
//   final String rentalBed;
//   final List<String>? rentalImages; // Assuming this can be null
//   final DateTime createdAt;
//   final DateTime updatedAt;
//
//   UnitData({
//     required this.id,
//     required this.unitId,
//     required this.rentalUnit,
//     required this.adminId,
//     required this.rentalId,
//     required this.rentalUnitAddress,
//     required this.rentalSqft,
//     required this.rentalBath,
//     required this.rentalBed,
//     this.rentalImages,
//     required this.createdAt,
//     required this.updatedAt,
//   });
//
//   factory UnitData.fromJson(Map<String, dynamic> json) {
//     return UnitData(
//       id: json['_id'] ?? '',
//       unitId: json['unit_id'] ?? '',
//       rentalUnit: json['rental_unit'] ?? '',
//       adminId: json['admin_id'] ?? '',
//       rentalId: json['rental_id'] ?? '',
//       rentalUnitAddress: json['rental_unit_adress'] ?? '',
//       rentalSqft: json['rental_sqft'] ?? '',
//       rentalBath: json['rental_bath'] ?? '',
//       rentalBed: json['rental_bed'] ?? '',
//       rentalImages: json['rental_images'] != null ? List<String>.from(json['rental_images']) : null,
//       createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
//       updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toString()),
//     );
//   }
// }
//
// class Entry {
//   final String entryId;
//   final String account;
//   final int amount;
//   final String date;
//   final int dueAmount;
//   final bool isPaid;
//   final String memo;
//   final String chargeType;
//   final bool isRepeatable;
//   final bool isLateFee;
//   final String id;
//   final List<dynamic> payments; // Assuming payments can be empty
//
//   Entry({
//     required this.entryId,
//     required this.account,
//     required this.amount,
//     required this.date,
//     required this.dueAmount,
//     required this.isPaid,
//     required this.memo,
//     required this.chargeType,
//     required this.isRepeatable,
//     required this.isLateFee,
//     required this.id,
//     required this.payments,
//   });
//
//   factory Entry.fromJson(Map<String, dynamic> json) {
//     return Entry(
//       entryId: json['entry_id'] ?? '',
//       account: json['account'] ?? '',
//       amount: json['amount'] ?? 0,
//       date: json['date'] ?? '',
//       dueAmount: json['due_amount'] ?? 0,
//       isPaid: json['is_paid'] ?? false,
//       memo: json['memo'] ?? '',
//       chargeType: json['charge_type'] ?? '',
//       isRepeatable: json['is_repeatable'] ?? false,
//       isLateFee: json['is_lateFee'] ?? false,
//       id: json['_id'] ?? '',
//       payments: json['payments'] ?? [],
//     );
//   }
// }
//
// class CurrentPayments {
//   final List<Payment> payments;
//   final int total;
//
//   CurrentPayments({
//     required this.payments,
//     required this.total,
//   });
//
//   factory CurrentPayments.fromJson(Map<String, dynamic> json) {
//     var paymentsList = json['payments'] as List? ?? [];
//     List<Payment> payments = paymentsList.map((i) => Payment.fromJson(i)).toList();
//
//     return CurrentPayments(
//       payments: payments,
//       total: json['total'] ?? 0,
//     );
//   }
// }
//
// class Payment {
//   final String leaseId;
//   final RentalData rentalData;
//   final TenantData tenantData;
//   final UnitData unitData;
//   final List<Entry> entry;
//   final int total;
//
//   Payment({
//     required this.leaseId,
//     required this.rentalData,
//     required this.tenantData,
//     required this.unitData,
//     required this.entry,
//     required this.total,
//   });
//
//   factory Payment.fromJson(Map<String, dynamic> json) {
//     var entryList = json['entry'] as List? ?? [];
//     List<Entry> entries = entryList.map((i) => Entry.fromJson(i)).toList();
//
//     return Payment(
//       leaseId: json['lease_id'] ?? '',
//       rentalData: RentalData.fromJson(json['rental_data']),
//       tenantData: TenantData.fromJson(json['tenant_data']),
//       unitData: UnitData.fromJson(json['unit_data']),
//       entry: entries,
//       total: json['total'] ?? 0,
//     );
//   }
// }
//
// class LastPayments {
//   final List< Payment> payments;
//   final int total;
//
//   LastPayments({
//     required this.payments,
//     required this.total,
//   });
//
//   factory LastPayments.fromJson(Map<String, dynamic> json) {
//     var paymentsList = json['payments'] as List? ?? [];
//     List<Payment> payments = paymentsList.map((i) => Payment.fromJson(i)).toList();
//
//     return LastPayments(
//       payments: payments,
//       total: json['total'] ?? 0,
//     );
//   }
// }

import 'dart:convert';

class RentPastDue {
  final double? currentMonthRentDue;
  final double? lastMonthRentDue;
  final double? currentMonthRentPaid;
  final double? lastMonthRentPaid;
  final double? totalRentPastDue;
  final CurrentDueRentCharges? currentDueRentCharges;
  final LastDueRentCharges? lastDueRentCharges;
  final DueRentCharges? dueRentCharges;
  final CurrentPayments? currentPayments;
  final LastPayments? lastPayments;

  RentPastDue({
    this.currentMonthRentDue,
    this.lastMonthRentDue,
    this.currentMonthRentPaid,
    this.lastMonthRentPaid,
    this.totalRentPastDue,
    this.currentDueRentCharges,
    this.lastDueRentCharges,
    this.dueRentCharges,
    this.currentPayments,
    this.lastPayments,
  });

  factory RentPastDue.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RentPastDue();
    return RentPastDue(
      currentMonthRentDue: (json['currentMonthRentDue'] as num?)?.toDouble(),
      lastMonthRentDue: (json['lastMonthRentDue'] as num?)?.toDouble(),
      currentMonthRentPaid: (json['currentMonthRentPaid'] as num?)?.toDouble(),
      lastMonthRentPaid: (json['lastMonthRentPaid'] as num?)?.toDouble(),
      totalRentPastDue: (json['totalRentPastDue'] as num?)?.toDouble(),
      currentDueRentCharges: json['currentDueRentCharges'] != null
          ? CurrentDueRentCharges.fromJson(json['currentDueRentCharges'])
          : null,
      lastDueRentCharges: json['lastDueRentCharges'] != null
          ? LastDueRentCharges.fromJson(json['lastDueRentCharges'])
          : null,
      dueRentCharges: json['dueRentCharges'] != null
          ? DueRentCharges.fromJson(json['dueRentCharges'])
          : null,
      currentPayments: json['currentPayments'] != null
          ? CurrentPayments.fromJson(json['currentPayments'])
          : null,
      lastPayments: json['lastPayments'] != null
          ? LastPayments.fromJson(json['lastPayments'])
          : null,
    );
  }
}

class CurrentDueRentCharges {
  final List<Transaction>? charges;
  final double? total;

  CurrentDueRentCharges({this.charges, this.total});

  factory CurrentDueRentCharges.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CurrentDueRentCharges();
    return CurrentDueRentCharges(
      charges: (json['charges'] as List?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>?))
          .toList(),
      total: (json['total'] as num?)?.toDouble(),
    );
  }
}

class LastDueRentCharges {
  final List<Transaction>? charges;
  final double? total;

  LastDueRentCharges({this.charges, this.total});

  factory LastDueRentCharges.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LastDueRentCharges();
    return LastDueRentCharges(
      charges: (json['charges'] as List?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>?))
          .toList(),
      total: (json['total'] as num?)?.toDouble(),
    );
  }
}

class DueRentCharges {
  final List<Transaction>? charges;
  final double? total;

  DueRentCharges({this.charges, this.total});

  factory DueRentCharges.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DueRentCharges();
    return DueRentCharges(
      charges: (json['charges'] as List?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>?))
          .toList(),
      total: (json['total'] as num?)?.toDouble(),
    );
  }
}

class Charge {
  final String? leaseId;
  final RentalData? rentalData;
  final TenantData? tenantData;
  final UnitData? unitData;
  final List<Entry>? entry;
  final double? total;

  Charge({
    this.leaseId,
    this.rentalData,
    this.tenantData,
    this.unitData,
    this.entry,
    this.total,
  });

  factory Charge.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Charge();
    return Charge(
      leaseId: json['lease_id'] as String?,
      rentalData: json['rental_data'] != null
          ? RentalData.fromJson(json['rental_data'] as Map<String, dynamic>?)
          : null,
      tenantData: json['tenant_data'] != null
          ? TenantData.fromJson(json['tenant_data'] as Map<String, dynamic>?)
          : null,
      unitData: json['unit_data'] != null
          ? UnitData.fromJson(json['unit_data'] as Map<String, dynamic>?)
          : null,
      entry: (json['entry'] as List?)
          ?.map((e) => Entry.fromJson(e as Map<String, dynamic>?))
          .toList(),
      total: (json['total'] as num?)?.toDouble(),
    );
  }
}

class RentalData {
  final String? city;
  final String? address;

  RentalData({this.city, this.address});

  factory RentalData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return RentalData();
    return RentalData(
      city: json['rental_city'] ?? "",
      address: json['rental_adress'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rental_city': city,
      'rental_adress': address,
    };
  }
}

class TenantData {
  final String? tenantFirstName;
  final String? email;
  final String? tenantLastName;

  TenantData({this.tenantFirstName, this.email, this.tenantLastName});

  factory TenantData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TenantData();
    return TenantData(
      tenantFirstName: json['tenant_firstName'] as String?,
      tenantLastName: json['tenant_lastName'] as String?,
      email: json['email'] as String?,
    );
  }
}

class UnitData {
  final String? rentalUnit;
  final String? rentalUnitAddress;

  UnitData({this.rentalUnit, this.rentalUnitAddress});

  factory UnitData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UnitData();
    return UnitData(
      rentalUnit: json['rental_unit'] as String?,
      rentalUnitAddress: json['rental_unit_address'] as String?,
    );
  }
}

class Entry {
  final String? entryId;
  final double? amount;

  Entry({this.entryId, this.amount});

  factory Entry.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Entry();
    return Entry(
      entryId: json['entry_id'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
    );
  }
}

class CurrentPayments {
  final List<Transaction>? payments;
  final double? total;

  CurrentPayments({this.payments, this.total});

  factory CurrentPayments.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CurrentPayments();
    return CurrentPayments(
      payments: (json['payments'] as List?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>?))
          .toList(),
      total: (json['total'] as num?)?.toDouble(),
    );
  }
}

class LastPayments {
  final List<Transaction>? payments;
  final double? total;

  LastPayments({this.payments, this.total});

  factory LastPayments.fromJson(Map<String, dynamic>? json) {
    if (json == null) return LastPayments();
    return LastPayments(
      payments: (json['payments'] as List?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>?))
          .toList(),
      total: (json['total'] as num?)?.toDouble(),
    );
  }
}

class Transaction {
  final String? paymentId;
  final double? total;
  final RentalData? rentalData;
  final TenantData? tenantData;

  Transaction({this.paymentId, this.total, this.rentalData, this.tenantData});

  factory Transaction.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Transaction();
    return Transaction(
      paymentId: json['payment_id'] as String?,
      total: (json['total'] as num?)?.toDouble(),
      rentalData: json['rental_data'] != null
          ? RentalData.fromJson(json['rental_data'] as Map<String, dynamic>?)
          : null,
      tenantData: json['tenant_data'] != null
          ? TenantData.fromJson(json['tenant_data'] as Map<String, dynamic>?)
          : null,
    );
  }
}


