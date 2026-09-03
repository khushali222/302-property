import 'package:three_zero_two_property/constant/constant.dart';

class Send_email_table {
  int? statusCode;
  List<Emailss>? emails;
  int? totalEmails;
  int? currentPage;
  int? totalPages;

  Send_email_table(
      {this.statusCode,
      this.emails,
      this.totalEmails,
      this.currentPage,
      this.totalPages});

  Send_email_table.fromJson(Map<String, dynamic> json) {
    statusCode = asIntN(json['statusCode']);
    if (json['emails'] != null) {
      emails = <Emailss>[];
      json['emails'].forEach((v) {
        emails!.add(new Emailss.fromJson(v));
      });
    }
    totalEmails = asIntN(json['totalEmails']);
    currentPage = asIntN(json['currentPage']);
    totalPages = asIntN(json['totalPages']);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    if (this.emails != null) {
      data['emails'] = this.emails!.map((v) => v.toJson()).toList();
    }
    data['totalEmails'] = this.totalEmails;
    data['currentPage'] = this.currentPage;
    data['totalPages'] = this.totalPages;
    return data;
  }
}

class Emailss {
  String? sId;
  String? emailId;
  String? adminId;
  String? tenantId;
  String? leaseId;
  String? rentalAddress;
  String? from;
  List<String>? to;
  List<String>? accepted;
  List<String>? rejected;
  String? subject;
  String? body;
  bool? sendByAdmin;
  bool? isDelete;
  List<Opens>? opens;
  String? createdAt;
  String? updatedAt;

  Emailss(
      {this.sId,
      this.emailId,
      this.adminId,
      this.tenantId,
      this.leaseId,
      this.rentalAddress,
      this.from,
      this.to,
      this.accepted,
      this.rejected,
      this.subject,
      this.body,
      this.sendByAdmin,
      this.isDelete,
      this.opens,
      this.createdAt,
      this.updatedAt});

  Emailss.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    emailId = json['email_id'];
    adminId = json['admin_id'];
    tenantId = json['tenant_id'];
    leaseId = json['lease_id'];
    rentalAddress = json['rentalAddress'];
    from = json['from'];
    if (json['to'] != null) {
      to = (json['to'] as List)
          .where((item) => item != null)
          .cast<String>()
          .toList();
    } else {
      to = [];
    }
    if (json['accepted'] != null) {
      accepted = (json['accepted'] as List)
          .where((item) => item != null)
          .cast<String>()
          .toList();
    } else {
      accepted = [];
    }
    if (json['rejected'] != null) {
      rejected = (json['rejected'] as List)
          .where((item) => item != null)
          .cast<String>()
          .toList();
    } else {
      rejected = [];
    }
    subject = json['subject'];
    body = json['body'];
    sendByAdmin = json['send_by_admin'];
    isDelete = json['is_delete'];
    if (json['opens'] != null) {
      opens = <Opens>[];
      json['opens'].forEach((v) {
        opens!.add(new Opens.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['email_id'] = this.emailId;
    data['admin_id'] = this.adminId;
    data['tenant_id'] = this.tenantId;
    data['lease_id'] = this.leaseId;
    data['rentalAddress'] = this.rentalAddress;
    data['from'] = this.from;
    data['to'] = this.to ?? [];
    data['accepted'] = this.accepted ?? [];
    data['rejected'] = this.rejected ?? [];
    data['subject'] = this.subject;
    data['body'] = this.body;
    data['send_by_admin'] = this.sendByAdmin;
    data['is_delete'] = this.isDelete;
    if (this.opens != null) {
      data['opens'] = this.opens!.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class Opens {
  String? openedBy;
  String? openedAt;
  String? sId;

  Opens({this.openedBy, this.openedAt, this.sId});

  Opens.fromJson(Map<String, dynamic> json) {
    openedBy = json['opened_by'];
    openedAt = json['openedAt'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['opened_by'] = this.openedBy;
    data['openedAt'] = this.openedAt;
    data['_id'] = this.sId;
    return data;
  }
}
