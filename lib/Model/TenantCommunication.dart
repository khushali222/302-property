import 'package:three_zero_two_property/constant/constant.dart';

class TenantCommunation {
  int? statusCode;
  List<Emails>? emails;
  int? totalEmails;
  int? currentPage;
  int? totalPages;

  TenantCommunation(
      {this.statusCode,
        this.emails,
        this.totalEmails,
        this.currentPage,
        this.totalPages});

  TenantCommunation.fromJson(Map<String, dynamic> json) {
    statusCode = asIntN(json['statusCode']);
    if (json['emails'] != null) {
      emails = <Emails>[];
      json['emails'].forEach((v) {
        emails!.add(new Emails.fromJson(v));
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

class Emails {
  String? emailId;
  String? subject;
  String? body;
  String? createdAt;
  String? from;
  String? email;
  bool? isAccepted;
  bool? isOpened;
  String? openedAt;
  String? tenantName;
  String? rentalAddress;

  Emails(
      {this.emailId,
        this.subject,
        this.body,
        this.createdAt,
        this.from,
        this.email,
        this.isAccepted,
        this.isOpened,
        this.openedAt,
        this.tenantName,
        this.rentalAddress});

  Emails.fromJson(Map<String, dynamic> json) {
    emailId = json['email_id'];
    subject = json['subject'];
    body = json['body'];
    createdAt = json['createdAt'];
    from = json['from'];
    email = json['email'];
    isAccepted = json['isAccepted'];
    isOpened = json['isOpened'];
    openedAt = json['openedAt'];
    tenantName = json['tenantName'];
    rentalAddress = json['rentalAddress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['email_id'] = this.emailId;
    data['subject'] = this.subject;
    data['body'] = this.body;
    data['createdAt'] = this.createdAt;
    data['from'] = this.from;
    data['email'] = this.email;
    data['isAccepted'] = this.isAccepted;
    data['isOpened'] = this.isOpened;
    data['openedAt'] = this.openedAt;
    data['tenantName'] = this.tenantName;
    data['rentalAddress'] = this.rentalAddress;
    return data;
  }
}
