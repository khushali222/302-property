class Activity_model{
  List<Activity_data>? data;
  int? totaldata;

  Activity_model({
    this.data,
    this.totaldata
});
  Activity_model.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      data = <Activity_data>[];
      json['data'].forEach((v) {
        data!.add(new Activity_data.fromJson(v));
      });
    }
    totaldata = json['totalRecords'];
  }

}


class Activity_data {
  String? sId;
  String? activityId;
  String? adminId;
  String? action;
  String? entity;
  String? entityId;
  String? activityBy;
  String? activityByUsername;
  Activity? activity;
  String? reason;
  bool? isDelete;
  String? createdAt;
  String? updatedAt;
  int? iV;

  Activity_data(
      {this.sId,
        this.activityId,
        this.adminId,
        this.action,
        this.entity,
        this.entityId,
        this.activityBy,
        this.activityByUsername,
        this.activity,
        this.reason,
        this.isDelete,
        this.createdAt,
        this.updatedAt,
        this.iV});

  Activity_data.fromJson(Map<String, dynamic> json) {

    sId = json['_id'];
    activityId = json['activity_id'];
    adminId = json['admin_id'];
    action = json['action'];
    entity = json['entity'];
    entityId = json['entity_id'];
    activityBy = json['activity_by'];
    activityByUsername = json['activity_by_username'];
    activity = json['activity'] != null
        ? new Activity.fromJson(json['activity'])
        : null;
    reason = json['reason'];
    isDelete = json['is_delete'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['activity_id'] = this.activityId;
    data['admin_id'] = this.adminId;
    data['action'] = this.action;
    data['entity'] = this.entity;
    data['entity_id'] = this.entityId;
    data['activity_by'] = this.activityBy;
    data['activity_by_username'] = this.activityByUsername;
    if (this.activity != null) {
      data['activity'] = this.activity!.toJson();
    }
    data['reason'] = this.reason;
    data['is_delete'] = this.isDelete;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    return data;
  }
}

class Activity {
  String? description;

  Activity({this.description});

  Activity.fromJson(Map<String, dynamic> json) {
    description = json['description'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['description'] = this.description;
    return data;
  }
}
