// Models for the Team & Access section.
//
// Backs the GET `${Api_url}/api/admin/team/team` response which returns both the
// company admins and the staff members in a single payload:
//   { "statusCode": 200, "admins": [...], "staff": [...] }
//
// Field naming / null-handling follows the existing model style (see
// `lib/Model/staffmember.dart`) so it stays consistent with the rest of the app.
//
// Every field is parsed through the shared safe-coercion helpers in
// `constant/constant.dart` (asStr / asBool / asObjectList), so a loosely-typed
// backend value (e.g. a phone number sent as a number on production) can never
// throw a TypeError — on any environment.

import 'package:three_zero_two_property/constant/constant.dart';

class TeamData {
  final List<TeamAdmin> admins;
  final List<TeamStaff> staff;

  TeamData({this.admins = const [], this.staff = const []});

  factory TeamData.fromJson(Map<String, dynamic> json) {
    return TeamData(
      admins:
          asObjectList(json['admins']).map((e) => TeamAdmin.fromJson(e)).toList(),
      staff: asObjectList(json['staff']).map((e) => TeamStaff.fromJson(e)).toList(),
    );
  }
}

class TeamAdmin {
  String? sId;
  String? adminId;
  String? firstName;
  String? lastName;
  String? email;
  String? phoneNumber;
  bool? isPending;
  String? invitedAt;
  String? invitedByAdminId;
  bool? isAdminDelete;
  String? createdAt;
  String? updatedAt;

  TeamAdmin({
    this.sId,
    this.adminId,
    this.firstName,
    this.lastName,
    this.email,
    this.phoneNumber,
    this.isPending,
    this.invitedAt,
    this.invitedByAdminId,
    this.isAdminDelete,
    this.createdAt,
    this.updatedAt,
  });

  TeamAdmin.fromJson(Map<String, dynamic> json) {
    sId = asStr(json['_id']);
    adminId = asStr(json['admin_id']);
    firstName = asStr(json['first_name']);
    lastName = asStr(json['last_name']);
    email = asStr(json['email']);
    phoneNumber = asStr(json['phone_number']);
    isPending = asBool(json['is_pending']);
    invitedAt = asStr(json['invited_at']);
    invitedByAdminId = asStr(json['invited_by_admin_id']);
    isAdminDelete = asBool(json['isAdmin_delete']);
    createdAt = asStr(json['createdAt']);
    updatedAt = asStr(json['updatedAt']);
  }

  Map<String, dynamic> toJson() => {
        '_id': sId,
        'admin_id': adminId,
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone_number': phoneNumber,
        'is_pending': isPending,
        'invited_at': invitedAt,
        'invited_by_admin_id': invitedByAdminId,
        'isAdmin_delete': isAdminDelete,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  /// "Mark Due" — convenience for list rows.
  String get fullName => "${firstName ?? ''} ${lastName ?? ''}".trim();
}

class TeamStaff {
  String? sId;
  String? adminId;
  String? staffmemberId;
  String? staffmemberName;
  String? staffmemberEmail;
  String? staffmemberPhoneNumber;
  String? staffmemberDesignation;
  bool? isPending;
  String? invitedAt;
  String? invitedByAdminId;
  bool? isDelete;
  String? createdAt;
  String? updatedAt;

  TeamStaff({
    this.sId,
    this.adminId,
    this.staffmemberId,
    this.staffmemberName,
    this.staffmemberEmail,
    this.staffmemberPhoneNumber,
    this.staffmemberDesignation,
    this.isPending,
    this.invitedAt,
    this.invitedByAdminId,
    this.isDelete,
    this.createdAt,
    this.updatedAt,
  });

  TeamStaff.fromJson(Map<String, dynamic> json) {
    sId = asStr(json['_id']);
    adminId = asStr(json['admin_id']);
    staffmemberId = asStr(json['staffmember_id']);
    staffmemberName = asStr(json['staffmember_name']);
    staffmemberEmail = asStr(json['staffmember_email']);
    // Phone can arrive as a number (e.g. 7125551212) or a string across envs.
    staffmemberPhoneNumber = asStr(json['staffmember_phoneNumber']);
    staffmemberDesignation = asStr(json['staffmember_designation']);
    isPending = asBool(json['is_pending']);
    invitedAt = asStr(json['invited_at']);
    invitedByAdminId = asStr(json['invited_by_admin_id']);
    isDelete = asBool(json['is_delete']);
    createdAt = asStr(json['createdAt']);
    updatedAt = asStr(json['updatedAt']);
  }

  Map<String, dynamic> toJson() => {
        '_id': sId,
        'admin_id': adminId,
        'staffmember_id': staffmemberId,
        'staffmember_name': staffmemberName,
        'staffmember_email': staffmemberEmail,
        'staffmember_phoneNumber': staffmemberPhoneNumber,
        'staffmember_designation': staffmemberDesignation,
        'is_pending': isPending,
        'invited_at': invitedAt,
        'invited_by_admin_id': invitedByAdminId,
        'is_delete': isDelete,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
