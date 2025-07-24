class allcategories_model {
  String? id;
  String? categoryId;
  String? adminId;
  String? name;
  bool? isDefault;
  bool? isDelete;
  String? createdAt;
  String? updatedAt;
  List<String>? brands;

  allcategories_model({
    this.id,
    this.categoryId,
    this.adminId,
    this.name,
    this.isDefault,
    this.isDelete,
    this.createdAt,
    this.updatedAt,
    this.brands,
  });

  allcategories_model.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    categoryId = json['category_id'];
    adminId = json['admin_id'];
    name = json['name'];
    isDefault = json['is_default'];
    isDelete = json['is_delete'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    brands = json['brands'] != null ? List<String>.from(json['brands']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.id;
    data['category_id'] = this.categoryId;
    data['admin_id'] = this.adminId;
    data['name'] = this.name;
    data['is_default'] = this.isDefault;
    data['is_delete'] = this.isDelete;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    if (this.brands != null) {
      data['brands'] = this.brands;
    }
    return data;
  }
}
