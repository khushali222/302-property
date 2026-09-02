import 'package:three_zero_two_property/Model/json_parse.dart';

class EmailTemplatesResponse {
  final int? statusCode;
  final List<EmailTemplate>? templates;
  final int? currentPage;
  final int? totalPages;
  final int? limit;

  EmailTemplatesResponse({
    this.statusCode,
    this.templates,
    this.currentPage,
    this.totalPages,
    this.limit,
  });

  factory EmailTemplatesResponse.fromJson(Map<String, dynamic> json) {
    return EmailTemplatesResponse(
      statusCode: asIntOrNull(json['statusCode']),
      templates: (json['templates'] as List?)
          ?.map((e) => EmailTemplate.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: asIntOrNull(json['currentPage']),
      totalPages: asIntOrNull(json['totalPages']),
      limit: asIntOrNull(json['limit']),
    );
  }
}

class EmailTemplate {
  final String? id;
  final String? templateId;
  final String? adminId;
  final String? name;
  final String? subject;
  final String? body;
  final String? type;
  final String? mailType;
  final bool? isDelete;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EmailTemplate({
    this.id,
    this.templateId,
    this.adminId,
    this.name,
    this.subject,
    this.body,
    this.type,
    this.mailType,
    this.isDelete,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory EmailTemplate.fromJson(Map<String, dynamic> json) {
    return EmailTemplate(
      id: json['_id'] as String?,
      templateId: json['template_id'] as String?,
      adminId: json['admin_id'] as String?,
      name: json['name'] as String?,
      subject: json['subject'] as String?,
      body: json['body'] as String?,
      type: json['type'] as String?,
      mailType: json['mail_type'] as String?,
      isDelete: json['is_delete'] as bool?,
      isActive: json['is_active'] as bool?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}
