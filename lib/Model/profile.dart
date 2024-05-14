class profile {
  String? sId;
  String? adminId;
  String? roll;
  String? firstName;
  String? lastName;
  String? email;
  String? companyName;
  int? phoneNumber;
  String? createdAt;
  String? updatedAt;
  bool? isAdminDelete;
  bool? isAddbySuperdmin;
  String? status;
  int? iV;

  profile(
      {this.sId,
        this.adminId,
        this.roll,
        this.firstName,
        this.lastName,
        this.email,
        this.companyName,
        this.phoneNumber,
        this.createdAt,
        this.updatedAt,
        this.isAdminDelete,
        this.isAddbySuperdmin,
        this.status,
        this.iV});

  profile.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    adminId = json['admin_id'];
    roll = json['roll'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    email = json['email'];
    companyName = json['company_name'];
    phoneNumber = json['phone_number'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isAdminDelete = json['isAdmin_delete'];
    isAddbySuperdmin = json['is_addby_superdmin'];
    status = json['status'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['admin_id'] = this.adminId;
    data['roll'] = this.roll;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['email'] = this.email;
    data['company_name'] = this.companyName;
    data['phone_number'] = this.phoneNumber;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['isAdmin_delete'] = this.isAdminDelete;
    data['is_addby_superdmin'] = this.isAddbySuperdmin;
    data['status'] = this.status;
    data['__v'] = this.iV;
    return data;
  }
}
