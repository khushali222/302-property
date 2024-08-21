class Setting1 {
  String id;
  String adminId;
  String surchargeId;
  int surchargePercent;
  String createdAt;
  String updatedAt;
  bool isDelete;
  int v;
  int surchargePercentDebit;
  int surchargePercentACH;
  double surchargeFlatACH;

  Setting1({
    required this.id,
    required this.adminId,
    required this.surchargeId,
    required this.surchargePercent,
    required this.createdAt,
    required this.updatedAt,
    required this.isDelete,
    required this.v,
    required this.surchargePercentDebit,
    required this.surchargePercentACH,
    required this.surchargeFlatACH,
  });

  factory Setting1.fromJson(Map<String, dynamic> json) {
    return Setting1(
      id: json['_id'],
      adminId: json['admin_id'],
      surchargeId: json['surcharge_id'],
      surchargePercent: json['surcharge_percent'] ?? 0.0,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isDelete: json['is_delete'],
      v: json['__v'],
      surchargePercentDebit: json['surcharge_percent_debit'] ?? 0.0,
      surchargePercentACH: json['surcharge_percent_ACH'] ?? 0.0,
      surchargeFlatACH: json['surcharge_flat_ACH'] != null
          ? json['surcharge_flat_ACH'].toDouble()
          : 0.0,
    );
  }
}

// Map<String, dynamic> toJson() {
//   final Map<String, dynamic> data = new Map<String, dynamic>();
//   data['_id'] = this.sId;
//   data['admin_id'] = this.adminId;
//   data['surcharge_id'] = this.roll;
//   data['surcharge_percent'] = this.firstName;
//   data['email'] = this.email;
//   data['company_name'] = this.companyName;
//   data['phone_number'] = this.phoneNumber;
//   data['createdAt'] = this.createdAt;
//   data['updatedAt'] = this.updatedAt;
//   data['isAdmin_delete'] = this.isAdminDelete;
//   data['is_addby_superdmin'] = this.isAddbySuperdmin;
//   data['status'] = this.status;
//   data['__v'] = this.iV;
//   return data;
// }

class Setting2 {
  String id;
  String adminId;
  String latefeeId;

  String duration;
  String late_fee;

  Setting2({
    required this.id,
    required this.adminId,
    required this.latefeeId,
    required this.duration,
    required this.late_fee,

  });

  factory Setting2.fromJson(Map<String, dynamic> json) {
    return Setting2(

      id: json['_id'],
      adminId: json['admin_id'],
      latefeeId: json['latefee_id'],
      duration: json['duration'].toString(),
      late_fee: json['late_fee'].toString(),
    );
  }
}
class Setting3 {
  String id;
  String adminId;
  String latefeeId;

  String duration;
  String late_fee;

  Setting3({
    required this.id,
    required this.adminId,
    required this.latefeeId,
    required this.duration,
    required this.late_fee,

  });

  factory Setting3.fromJson(Map<String, dynamic> json) {
    return Setting3(

      id: json['_id'],
      adminId: json['admin_id'],
      latefeeId: json['latefee_id'],
      duration: json['duration'].toString(),
      late_fee: json['late_fee'].toString(),
    );
  }
}
class ApiResponse {
  List<Setting1> data;
  int statusCode;
  String message;

  ApiResponse({
    required this.data,
    required this.statusCode,
    required this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    var list = json['data'] as List;
    List<Setting1> dataList = list.map((i) => Setting1.fromJson(i)).toList();

    return ApiResponse(
      data: dataList,
      statusCode: json['statusCode'],
      message: json['message'],
    );
  }
}

// class Surcharge {
//   String? id;
//   String? adminId;
//   String? surchargeId;
//   double? surchargePercent;
//   String? createdAt;
//   String? updatedAt;
//   bool? isDeleted;
//   int? version;
//   double? surchargePercentDebit;
//   double? surchargePercentACH;
//   double? surchargeFlatACH;
//
//   Surcharge({
//     this.id,
//     this.adminId,
//     this.surchargeId,
//     this.surchargePercent,
//     this.createdAt,
//     this.updatedAt,
//     this.isDeleted,
//     this.version,
//     this.surchargePercentDebit,
//     this.surchargePercentACH,
//     this.surchargeFlatACH,
//   });
//
//   Surcharge.fromJson(Map<String, dynamic> json) {
//     id = json['_id'];
//     adminId = json['admin_id'];
//     surchargeId = json['surcharge_id'];
//     surchargePercent = json['surcharge_percent']?.toDouble();
//     createdAt = json['createdAt'];
//     updatedAt = json['updatedAt'];
//     isDeleted = json['is_delete'];
//     version = json['__v'];
//     surchargePercentDebit = json['surcharge_percent_debit']?.toDouble();
//     surchargePercentACH = json['surcharge_percent_ACH']?.toDouble();
//     surchargeFlatACH = json['surcharge_flat_ACH']?.toDouble();
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this.id;
//     data['admin_id'] = this.adminId;
//     data['surcharge_id'] = this.surchargeId;
//     data['surcharge_percent'] = this.surchargePercent;
//     data['createdAt'] = this.createdAt;
//     data['updatedAt'] = this.updatedAt;
//     data['is_delete'] = this.isDeleted;
//     data['__v'] = this.version;
//     data['surcharge_percent_debit'] = this.surchargePercentDebit;
//     data['surcharge_percent_ACH'] = this.surchargePercentACH;
//     data['surcharge_flat_ACH'] = this.surchargeFlatACH;
//     return data;
//   }
// }
