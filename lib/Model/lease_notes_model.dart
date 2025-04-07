class lease_notes {
  String? sId;
  String? noteId;
  String? adminId;
  String? leaseId;
  String? noteType;
  String? content;
  bool? isPrivate;
  bool? isDelete;
  String? createdAt;
  String? updatedAt;

  lease_notes(
      {this.sId,
        this.noteId,
        this.adminId,
        this.leaseId,
        this.noteType,
        this.content,
        this.isPrivate,
        this.isDelete,
        this.createdAt,
        this.updatedAt});

  lease_notes.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    noteId = json['note_id'];
    adminId = json['admin_id'];
    leaseId = json['lease_id'];
    noteType = json['note_type'];
    content = json['content'];
    isPrivate = json['is_private'];
    isDelete = json['is_delete'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['note_id'] = this.noteId;
    data['admin_id'] = this.adminId;
    data['lease_id'] = this.leaseId;
    data['note_type'] = this.noteType;
    data['content'] = this.content;
    data['is_private'] = this.isPrivate;
    data['is_delete'] = this.isDelete;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}
