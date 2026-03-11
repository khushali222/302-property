

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
  String? ticketNumber;
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
    this.ticketNumber,
    this.staffMemberName,
  });

  WorkOrder.fromJson(Map<String, dynamic> json) {
   // print(json);
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
    ticketNumber = json['ticket_number']??"";
    staffMemberName = json['staffmember_name']??"N/A";
  }
}