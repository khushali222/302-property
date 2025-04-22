class lease_communications {
  int? statusCode;
  List<Emails>? emails;
  int? totalEmails;
  int? currentPage;
  int? totalPages;

  lease_communications(
      {this.statusCode,
        this.emails,
        this.totalEmails,
        this.currentPage,
        this.totalPages});

  lease_communications.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    if (json['emails'] != null) {
      emails = <Emails>[];
      json['emails'].forEach((v) {
        emails!.add(new Emails.fromJson(v));
      });
    }
    totalEmails = json['totalEmails'];
    currentPage = json['currentPage'];
    totalPages = json['totalPages'];
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

class Emails {
  String? sId;
  String? emailId;
  String? adminId;
  String? tenantId;
  String? leaseId;
  String? rentalAddress;
  String? from;
  List<String>? to;
  List<String>? accepted;
  List<dynamic>? rejected;
  String? subject;
  String? body;
  bool? sendByAdmin;
  bool? isDelete;
  List<dynamic>? opens;
  String? createdAt;
  String? updatedAt;

  Emails(
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

  Emails.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    emailId = json['email_id'];
    adminId = json['admin_id'];
    tenantId = json['tenant_id'];
    leaseId = json['lease_id'];
    rentalAddress = json['rentalAddress'];
    from = json['from'];
    to = json['to'].cast<String>();
    accepted = json['accepted'].cast<String>();
    if (json['rejected'] != null) {
      rejected = [];
      json['rejected'].forEach((v) {
        rejected!.add(v);
      });
    }
    subject = json['subject'];
    body = json['body'];
    sendByAdmin = json['send_by_admin'];
    isDelete = json['is_delete'];
    if (json['opens'] != null) {
      opens = [];
      json['opens'].forEach((v) {
        opens!.add(v);
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
    data['to'] = this.to;
    data['accepted'] = this.accepted;
    if (this.rejected != null) {
      data['rejected'] = this.rejected!.map((v) => v.toJson()).toList();
    }
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
