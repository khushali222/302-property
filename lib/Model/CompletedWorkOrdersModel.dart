class CompletedWorkOrdersModel {
  int? statusCode;
  List<CompletedWorkData>? data;
  String? message;

  CompletedWorkOrdersModel({
    this.statusCode,
    this.data,
    this.message,
  });

  factory CompletedWorkOrdersModel.fromJson(Map<String, dynamic> json) {
    return CompletedWorkOrdersModel(
      statusCode: json['statusCode'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) =>
              CompletedWorkData.fromJson(item as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = this.message;
    return data;
  }
}

class CompletedWorkData {
  String? workOrderId;
  String? workSubject;
  String? workCategory;
  String? workPerformed;
  String? vendorNotes;
  String? priority;
  String? status;
  String? date;
  String? rentalAddress;
  String? rentalUnit;
  dynamic staffMember;

  CompletedWorkData({
    this.workOrderId,
    this.workSubject,
    this.workCategory,
    this.workPerformed,
    this.vendorNotes,
    this.priority,
    this.status,
    this.date,
    this.rentalAddress,
    this.rentalUnit,
    this.staffMember,
  });

  factory CompletedWorkData.fromJson(Map<String, dynamic> json) {
    return CompletedWorkData(
      workOrderId: json['workOrder_id'] as String?,
      workSubject: json['work_subject'] as String?,
      workCategory: json['work_category'] as String?,
      workPerformed: json['work_performed'] as String?,
      vendorNotes: json['vendor_notes'] as String?,
      priority: json['priority'] as String?,
      status: json['status'] as String?,
      date: json['date'] as String?,
      rentalAddress: json['rentalAddress'] as String?,
      rentalUnit: json['rentalUnit'] as String?,
      staffMember: json['staffMember'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['workOrder_id'] = this.workOrderId;
    data['work_subject'] = this.workSubject;
    data['work_category'] = this.workCategory;
    data['work_performed'] = this.workPerformed;
    data['vendor_notes'] = this.vendorNotes;
    data['priority'] = this.priority;
    data['status'] = this.status;
    data['date'] = this.date;
    data['rentalAddress'] = this.rentalAddress;
    data['rentalUnit'] = this.rentalUnit;
    data['staffMember'] = this.staffMember;
    return data;
  }
}
