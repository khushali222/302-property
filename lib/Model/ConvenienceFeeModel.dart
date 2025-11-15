class ConvenienceFee {
  int? statusCode;
  List<Data>? data;
  String? message;

  ConvenienceFee({this.statusCode, this.data, this.message});

  factory ConvenienceFee.fromJson(Map<String, dynamic> json) {
    return ConvenienceFee(
      statusCode: json['statusCode'],
      data: json['data'] != null
          ? List<Data>.from(json['data'].map((v) => Data.fromJson(v)))
          : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'data': data?.map((v) => v.toJson()).toList(),
      'message': message,
    };
  }
}

class Data {
  String? leaseId;
  String? startDate;
  String? endDate;
  RentalData? rentalData;
  UnitData? unitData;
  List<TenantData>? tenantData;

  Data(
      {this.leaseId,
        this.startDate,
        this.endDate,
        this.rentalData,
        this.unitData,
        this.tenantData});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      leaseId: json['lease_id'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      rentalData: json['rentalData'] != null
          ? RentalData.fromJson(json['rentalData'])
          : null,
      unitData: json['unitData'] != null
          ? UnitData.fromJson(json['unitData'])
          : null,
      tenantData: json['tenantData'] != null
          ? List<TenantData>.from(json['tenantData'].map((v) => TenantData.fromJson(v)))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lease_id': leaseId,
      'start_date': startDate,
      'end_date': endDate,
      'rentalData': rentalData?.toJson(),
      'unitData': unitData?.toJson(),
      'tenantData': tenantData?.map((v) => v.toJson()).toList(),
    };
  }
}

class RentalData {
  String? rentalAddress;

  RentalData({this.rentalAddress});

  factory RentalData.fromJson(Map<String, dynamic> json) {
    return RentalData(
      rentalAddress: json['rental_adress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rental_adress': rentalAddress,
    };
  }
}

class UnitData {
  String? rentalUnit;
  String? rentalUnitAddress;

  UnitData({this.rentalUnit, this.rentalUnitAddress});

  factory UnitData.fromJson(Map<String, dynamic> json) {
    return UnitData(
      rentalUnit: json['rental_unit'],
      rentalUnitAddress: json['rental_unit_adress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rental_unit': rentalUnit,
      'rental_unit_adress': rentalUnitAddress,
    };
  }
}

class TenantData {
  String? tenantId;
  String? tenantFirstName;
  String? tenantLastName;
  int? overrideFee;

  TenantData(
      {this.tenantId,
        this.tenantFirstName,
        this.tenantLastName,
        this.overrideFee});

  factory TenantData.fromJson(Map<String, dynamic> json) {
    return TenantData(
      tenantId: json['tenant_id'],
      tenantFirstName: json['tenant_firstName'],
      tenantLastName: json['tenant_lastName'],
      overrideFee: json['override_fee'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'tenant_firstName': tenantFirstName,
      'tenant_lastName': tenantLastName,
      'override_fee': overrideFee,
    };
  }
}