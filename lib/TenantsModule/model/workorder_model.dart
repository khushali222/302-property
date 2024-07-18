// class WorkOrderResponse {
//   int? statusCode;
//   List<WorkOrder>? data;
//   int? count;
//   String? message;
//
//   WorkOrderResponse({this.statusCode, this.data, this.count, this.message});
//
//   factory WorkOrderResponse.fromJson(Map<String, dynamic> json) {
//     return WorkOrderResponse(
//       statusCode: json['statusCode'],
//       data: json['data'] != null
//           ? List<WorkOrder>.from(json['data'].map((x) => WorkOrder.fromJson(x)))
//           : null,
//       count: json['count'],
//       message: json['message'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {
//       'statusCode': this.statusCode,
//       'count': this.count,
//       'message': this.message,
//     };
//     if (this.data != null) {
//       data['data'] = this.data!.map((v) => v.toJson()).toList();
//     }
//     return data;
//   }
// }
//
// class WorkOrder {
//   String? workOrderId;
//   String? workSubject;
//   String? workCategory;
//   String? priority;
//   String? status;
//   bool? isBillable;
//   String? createdAt;
//   String? updatedAt;
//   String? date;
//   String? rentalId;
//   String? unitId;
//   String? rentalAddress;
//   String? rentalUnit;
//   String? staffMemberName;
//
//   WorkOrder({
//     this.workOrderId,
//     this.workSubject,
//     this.workCategory,
//     this.priority,
//     this.status,
//     this.isBillable,
//     this.createdAt,
//     this.updatedAt,
//     this.date,
//     this.rentalId,
//     this.unitId,
//     this.rentalAddress,
//     this.rentalUnit,
//     this.staffMemberName,
//   });
//
//   factory WorkOrder.fromJson(Map<String, dynamic> json) {
//     return WorkOrder(
//       workOrderId: json['workOrder_id'],
//       workSubject: json['work_subject'],
//       workCategory: json['work_category'],
//       priority: json['priority'],
//       status: json['status'],
//       isBillable: json['is_billable'],
//       createdAt: json['createdAt'],
//       updatedAt: json['updatedAt'],
//       date: json['date'],
//       rentalId: json['rental_id'],
//       unitId: json['unit_id'],
//       rentalAddress: json['rental_adress'],
//       rentalUnit: json['rental_unit'],
//       staffMemberName: json['staffmember_name'],
//     );
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {
//       'workOrder_id': this.workOrderId,
//       'work_subject': this.workSubject,
//       'work_category': this.workCategory,
//       'priority': this.priority,
//       'status': this.status,
//       'is_billable': this.isBillable,
//       'createdAt': this.createdAt,
//       'updatedAt': this.updatedAt,
//       'date': this.date,
//       'rental_id': this.rentalId,
//       'unit_id': this.unitId,
//       'rental_adress': this.rentalAddress,
//       'rental_unit': this.rentalUnit,
//       'staffmember_name': this.staffMemberName,
//     };
//     return data;
//   }
// }

class WorkOrder {
  String? workOrderId;
  String? workSubject;
  String? workCategory;
  String? priority;
  String? status;
  bool? isBillable;
  String? createdAt;
  String? updatedAt;
  String? date;
  String? rentalId;
  String? unitId;
  String? rentalAddress;
  String? rentalUnit;
  String? staffMemberName;

  WorkOrder({
    this.workOrderId,
    this.workSubject,
    this.workCategory,
    this.priority,
    this.status,
    this.isBillable,
    this.createdAt,
    this.updatedAt,
    this.date,
    this.rentalId,
    this.unitId,
    this.rentalAddress,
    this.rentalUnit,
    this.staffMemberName,
  });

  WorkOrder.fromJson(Map<String, dynamic> json) {
    print(json);
    workOrderId = json['workOrder_id']??"";
    workSubject = json['work_subject']??"";
    workCategory = json['work_category']??"";
    priority = json['priority']??"";
    status = json['status']??"";
    isBillable = json['is_billable']??"";
    createdAt = json['createdAt']??"";
    updatedAt = json['updatedAt']??"";
    date = json['date']??"";
    rentalId = json['rental_id']??"";
    unitId = json['unit_id']??"";
    rentalAddress = json['rental_adress']??"";
    rentalUnit = json['rental_unit']??"";
    staffMemberName = json['staffmember_name']??"";
  }
}