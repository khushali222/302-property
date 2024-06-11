class Staffmembers {
  String? sId;
  String? adminId;
  String? staffmemberId;
  String? staffmemberName;
  String? staffmemberDesignation;
  String? staffmemberPhoneNumber;
  String? staffmemberEmail;
  String? staffmemberPassword;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? iV;

  Staffmembers(
      {this.sId,
        this.adminId,
        this.staffmemberId,
        this.staffmemberName,
        this.staffmemberDesignation,
        this.staffmemberPhoneNumber,
        this.staffmemberEmail,
        this.staffmemberPassword,
        this.createdAt,
        this.updatedAt,
        this.isDelete,
        this.iV});

  Staffmembers.fromJson(Map<String, dynamic> json) {
    sId = json['_id']??"";
    adminId = json['admin_id']??"";
    staffmemberId = json['staffmember_id']??"";
    staffmemberName = json['staffmember_name']??"";
    staffmemberDesignation = json['staffmember_designation']??"";
    staffmemberPhoneNumber = json['staffmember_phoneNumber']??"";
    staffmemberEmail = json['staffmember_email']??"";
    staffmemberPassword = json['staffmember_password']??"";
    createdAt = json['createdAt']??"";
    updatedAt = json['updatedAt']??"";
    isDelete = json['is_delete']??"";
    iV = json['__v']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['admin_id'] = this.adminId;
    data['staffmember_id'] = this.staffmemberId;
    data['staffmember_name'] = this.staffmemberName;
    data['staffmember_designation'] = this.staffmemberDesignation;
    data['staffmember_phoneNumber'] = this.staffmemberPhoneNumber;
    data['staffmember_email'] = this.staffmemberEmail;
    data['staffmember_password'] = this.staffmemberPassword;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    data['__v'] = this.iV;
    return data;
  }
}
