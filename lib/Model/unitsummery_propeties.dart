class unit_properties {
  String? Id;
  String? adminId;
  String? unitId;
  String? rentalunit;
  String? rentalId;
  String? rentalunitadress;
  String? rentalsqft;
  String? rentalbath;
  String? rentalbed;
  List<String>? rentalImages;
  int? tenantCount;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  int? iV;

  unit_properties(
      {this.Id,
        this.adminId,
        this.unitId,
        this.rentalunit,
        this.rentalId,
        this.rentalunitadress,
        this.rentalImages,
        this.rentalsqft,
        this.tenantCount,
        this.rentalbath,
        this.rentalbed,
        });

  unit_properties.fromJson(Map<String, dynamic> json) {
    print(json);
    print(json['rental_images']);
    Id = json['_id']??"";
    adminId = json['admin_id']??"";
    unitId = json['unit_id']??"";
    rentalunit = json['rental_unit']??"";
    rentalId = json['rental_id']??"";
    rentalunitadress = json['rental_unit_adress']??"";
    rentalsqft = json['rental_sqft']??"";
    tenantCount = json['tenantCount']??"";
    rentalbath = json['rental_bath']??"";
    rentalImages = (json['rental_images'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();
    rentalbed = json['rental_bed']??"";
    createdAt = json['createdAt']??"";
    updatedAt = json['updatedAt']??"";
    isDelete = json['is_delete']??"";
    iV = json['__v']??"";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.Id;
    data['admin_id'] = this.adminId;
    data['unit_id'] = this.unitId;
    data['rental_unit'] = this.rentalunit;
    data['rental_id'] = this.rentalId;
    data['rental_unit_adress'] = this.rentalunitadress;
    data['rental_images'] = rentalImages;
    data['rental_sqft'] = this.rentalsqft;
    data['tenantCount'] = this.tenantCount;
    data['__v'] = this.iV;
    return data;
  }
}
