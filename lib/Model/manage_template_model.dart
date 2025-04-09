class Templates {
  String? type;
  List<Template>? templates;
  bool? isEnabled;

  Templates({this.type, this.templates, this.isEnabled});

  Templates.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    if (json['templates'] != null) {
      templates = <Template>[];
      json['templates'].forEach((v) {
        templates!.add(new Template.fromJson(v));
      });
    }
    isEnabled = json['is_enabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    if (this.templates != null) {
      data['templates'] = this.templates!.map((v) => v.toJson()).toList();
    }
    data['is_enabled'] = this.isEnabled;
    return data;
  }
}

class Template {
  String? sId;
  String? templateId;
  String? adminId;
  String? name;
  String? mailType;
  bool? isActive;

  Template(
      {this.sId,
        this.templateId,
        this.adminId,
        this.name,
        this.mailType,
        this.isActive});

  Template.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    templateId = json['template_id'];
    adminId = json['admin_id'];
    name = json['name'];
    mailType = json['mail_type'];
    isActive = json['is_active'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['template_id'] = this.templateId;
    data['admin_id'] = this.adminId;
    data['name'] = this.name;
    data['mail_type'] = this.mailType;
    data['is_active'] = this.isActive;
    return data;
  }
}
