// Models for the Team & Access section.
//
// Backs the GET `${Api_url}/api/admin/team/team` response which returns both the
// company admins and the staff members in a single payload:
//   { "statusCode": 200, "admins": [...], "staff": [...] }
//
// Field naming / null-handling follows the existing model style (see
// `lib/Model/staffmember.dart`) so it stays consistent with the rest of the app.

class TeamData {
  final List<TeamAdmin> admins;
  final List<TeamStaff> staff;

  TeamData({this.admins = const [], this.staff = const []});

  factory TeamData.fromJson(Map<String, dynamic> json) {
    return TeamData(
      admins: (json['admins'] as List?)
              ?.map((e) => TeamAdmin.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      staff: (json['staff'] as List?)
              ?.map((e) => TeamStaff.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
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
    sId = json['_id'] ?? "";
    adminId = json['admin_id'] ?? "";
    firstName = json['first_name'] ?? "";
    lastName = json['last_name'] ?? "";
    email = json['email'] ?? "";
    phoneNumber = json['phone_number'] ?? "";
    isPending = json['is_pending'] ?? false;
    invitedAt = json['invited_at']?.toString() ?? "";
    invitedByAdminId = json['invited_by_admin_id']?.toString() ?? "";
    isAdminDelete = json['isAdmin_delete'] ?? false;
    createdAt = json['createdAt'] ?? "";
    updatedAt = json['updatedAt'] ?? "";
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
    sId = json['_id'] ?? "";
    adminId = json['admin_id'] ?? "";
    staffmemberId = json['staffmember_id'] ?? "";
    staffmemberName = json['staffmember_name'] ?? "";
    staffmemberEmail = json['staffmember_email'] ?? "";
    staffmemberPhoneNumber = json['staffmember_phoneNumber'] ?? "";
    staffmemberDesignation = json['staffmember_designation'] ?? "";
    isPending = json['is_pending'] ?? false;
    invitedAt = json['invited_at']?.toString() ?? "";
    invitedByAdminId = json['invited_by_admin_id']?.toString() ?? "";
    isDelete = json['is_delete'] ?? false;
    createdAt = json['createdAt'] ?? "";
    updatedAt = json['updatedAt'] ?? "";
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
