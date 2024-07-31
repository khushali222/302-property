class OpenWorkOrderReportModel {
  final int? statusCode;
  final List<WorkOrderReportData>? data;
  final String? message;

  OpenWorkOrderReportModel({
    this.statusCode,
    this.data,
    this.message,
  });

  factory OpenWorkOrderReportModel.fromJson(Map<String, dynamic> json) {
    return OpenWorkOrderReportModel(
      statusCode: json['statusCode'] as int?,
      data: (json['data'] as List<dynamic>?)
          ?.map((item) =>
              WorkOrderReportData.fromJson(item as Map<String, dynamic>))
          .toList(),
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'data': data?.map((item) => item.toJson()).toList(),
      'message': message,
    };
  }
}

class WorkOrderReportData {
  final String? workOrderId;
  final String? workSubject;
  final String? workCategory;
  final String? workPerformed;
  final String? vendorNotes;
  final String? priority;
  final String? status;
  final String? date;
  final String? rentalAddress;
  final String? rentalUnit;
  final String? staffMemberName;

  WorkOrderReportData({
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
    this.staffMemberName,
  });

  factory WorkOrderReportData.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
      print('Key: $key, Value: $value');
    });
    return WorkOrderReportData(
      workOrderId: json['workOrder_id'] as String?,
      workSubject: json['work_subject'] as String?,
      workCategory: json['work_category'] as String?,
      workPerformed: json['work_performed'] as String?,
      vendorNotes: json['vendor_notes'] as String?,
      priority: json['priority'] as String?,
      status: json['status'] as String?,
      date: json['date'] as String?,
      rentalAddress: json['rental_adress'] as String?,
      rentalUnit: json['rental_unit'] as String?,
      staffMemberName: json['staff_member_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'workOrder_id': workOrderId,
      'work_subject': workSubject,
      'work_category': workCategory,
      'work_performed': workPerformed,
      'vendor_notes': vendorNotes,
      'priority': priority,
      'status': status,
      'date': date,
      'rental_address': rentalAddress,
      'rental_unit': rentalUnit,
      'staff_member_name': staffMemberName,
    };
  }
}
