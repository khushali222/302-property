class ReopenWorkOrderResponse {
  int? statusCode;
  List<ReopenWorkOrderData>? data;
  String? message;

  ReopenWorkOrderResponse({this.statusCode, this.data, this.message});

  ReopenWorkOrderResponse.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json['data'] != null) {
      data = <ReopenWorkOrderData>[];
      json['data'].forEach((v) {
        data!.add(ReopenWorkOrderData.fromJson(v));
      });
    }
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = statusCode;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    return data;
  }
}

class ReopenWorkOrderData {
  String? workOrderId;
  String? ticketNumber;
  String? workSubject;
  String? workCategory;
  String? workPerformed;
  String? vendorNotes;
  String? priority;
  String? status;
  String? date;
  String? reopenDate;
  String? createdAt;
  String? updatedAt;
  String? rentalAddress;
  String? rentalUnit;
  String? staffmemberName;

  ReopenWorkOrderData({
    this.workOrderId,
    this.ticketNumber,
    this.workSubject,
    this.workCategory,
    this.workPerformed,
    this.vendorNotes,
    this.priority,
    this.status,
    this.date,
    this.reopenDate,
    this.createdAt,
    this.updatedAt,
    this.rentalAddress,
    this.rentalUnit,
    this.staffmemberName,
  });

  ReopenWorkOrderData.fromJson(Map<String, dynamic> json) {
    workOrderId = json['workOrder_id'];
    ticketNumber = json['ticket_number'];
    workSubject = json['work_subject'];
    workCategory = json['work_category'];
    workPerformed = json['work_performed'];
    vendorNotes = json['vendor_notes'];
    priority = json['priority'];
    status = json['status'];
    date = json['date'];
    reopenDate = json['reopen_date'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    rentalAddress = json['rental_adress'];
    rentalUnit = json['rental_unit'];
    staffmemberName = json['staffmember_name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['workOrder_id'] = workOrderId;
    data['ticket_number'] = ticketNumber;
    data['work_subject'] = workSubject;
    data['work_category'] = workCategory;
    data['work_performed'] = workPerformed;
    data['vendor_notes'] = vendorNotes;
    data['priority'] = priority;
    data['status'] = status;
    data['date'] = this.date;
    data['reopen_date'] = reopenDate;
    data['created_at'] = createdAt;
    data['updated_at'] = updatedAt;
    data['rental_adress'] = rentalAddress;
    data['rental_unit'] = rentalUnit;
    data['staffmember_name'] = staffmemberName;
    return data;
  }
}
