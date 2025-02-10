class Recurring_Payments_Configuration {
  int? statusCode;
  String? message;
  List<Data>? data;
  double? grandTotal;

  Recurring_Payments_Configuration({
    this.statusCode,
    this.message,
    this.data,
    this.grandTotal,
  });

  Recurring_Payments_Configuration.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    grandTotal = json['grandTotal']?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['message'] = message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    data['grandTotal'] = grandTotal;
    return data;
  }
}

class Data {
  String? rentalId;
  String? rentalAdress;
  double? rentalSubtotal;
  List<Leases>? leases;

  Data({this.rentalId, this.rentalAdress, this.rentalSubtotal, this.leases});

  Data.fromJson(Map<String, dynamic> json) {
    rentalId = json['rental_id'];
    rentalAdress = json['rental_adress'];
    rentalSubtotal = (json['rentalSubtotal'] ?? 0).toDouble();
    if (json['leases'] != null) {
      leases = <Leases>[];
      json['leases'].forEach((v) {
        leases!.add(Leases.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['rental_id'] = rentalId;
    data['rental_adress'] = rentalAdress;
    data['rentalSubtotal'] = rentalSubtotal;
    if (leases != null) {
      data['leases'] = leases!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Leases {
  String? leaseId;
  String? endDate;
  String? rentalAdress;
  String? rentalUnit;
  String? rentalUnitAdress;
  List<Tenants>? tenants;

  Leases({
    this.leaseId,
    this.endDate,
    this.rentalAdress,
    this.rentalUnit,
    this.rentalUnitAdress,
    this.tenants,
  });

  Leases.fromJson(Map<String, dynamic> json) {
    leaseId = json['lease_id'];
    endDate = json['end_date'];
    rentalAdress = json['rental_adress'];
    rentalUnit = json['rental_unit'];
    rentalUnitAdress = json['rental_unit_adress'];
    if (json['tenants'] != null) {
      tenants = <Tenants>[];
      json['tenants'].forEach((v) {
        tenants!.add(Tenants.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['lease_id'] = leaseId;
    data['end_date'] = endDate;
    data['rental_adress'] = rentalAdress;
    data['rental_unit'] = rentalUnit;
    data['rental_unit_adress'] = rentalUnitAdress;
    if (tenants != null) {
      data['tenants'] = tenants!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Tenants {
  String? tenantId;
  String? tenantName;
  String? customerVaultId;
  List<Recurrings>? recurrings;

  Tenants({this.tenantId, this.tenantName, this.customerVaultId, this.recurrings});

  Tenants.fromJson(Map<String, dynamic> json) {
    tenantId = json['tenant_id'];
    tenantName = json['tenant_name'];
    customerVaultId = json['customer_vault_id'];
    if (json['recurrings'] != null) {
      recurrings = <Recurrings>[];
      json['recurrings'].forEach((v) {
        recurrings!.add(Recurrings.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['tenant_id'] = tenantId;
    data['tenant_name'] = tenantName;
    data['customer_vault_id'] = customerVaultId;
    if (recurrings != null) {
      data['recurrings'] = recurrings!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Recurrings {
  int? date;
  String? cardType;
  String? billingId;
  double? amount;
  String? account;
  String? sId;

  Recurrings({
    this.date,
    this.cardType,
    this.billingId,
    this.amount,
    this.account,
    this.sId,
  });

  Recurrings.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    cardType = json['card_type'];
    billingId = json['billing_id'];
    amount = (json['amount'] ?? 0).toDouble();
    account = json['account'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['date'] = date;
    data['card_type'] = cardType;
    data['billing_id'] = billingId;
    data['amount'] = amount;
    data['account'] = account;
    data['_id'] = sId;
    return data;
  }
}
