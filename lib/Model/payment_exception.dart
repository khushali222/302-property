class Payment_Exception {
  int? statusCode;
  List<Data>? data;
  String? message;

  Payment_Exception({this.statusCode, this.data, this.message});

  factory Payment_Exception.fromJson(Map<String, dynamic> json) {
    return Payment_Exception(
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
  String? sId;
  String? paymentId;
  String? adminId;
  String? leaseId;
  String? paymentType;
  String? response;
  List<Entryy>? entry;
  int? totalAmount;
  String? type;
  List<Null>? paymentAttachment;
  String? createdAt;
  String? updatedAt;
  String? checknumber;
  bool? isDelete;
  RentalData? rentalData;

  Data({
    this.sId,
    this.paymentId,
    this.adminId,
    this.leaseId,
    this.paymentType,
    this.response,
    this.entry,
    this.totalAmount,
    this.type,
    this.paymentAttachment,
    this.createdAt,
    this.checknumber,
    this.updatedAt,
    this.isDelete,
    this.rentalData,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      sId: json['_id']??"",
      paymentId: json['payment_id']??"",
      adminId: json['admin_id']??"",
      leaseId: json['lease_id']??"",
      paymentType: json['payment_type']??"",
      response: json['response']??"",
      entry: json['entry'] != null
          ? List<Entryy>.from(json['entry'].map((v) => Entryy.fromJson(v)))
          : null,
      totalAmount: json['total_amount']  as int?,
      type: json['type'],
      paymentAttachment: json['payment_attachment'] != null
          ? List<Null>.from(json['payment_attachment'].map((v) => null)) // Assuming you meant to handle nulls differently
          : null,
      createdAt: json['createdAt']??"",
      checknumber: json['check_number']??"",
      updatedAt: json['updatedAt'] ??"",
      isDelete: json['is_delete']??"",
      rentalData: json['rental_data'] != null
          ? RentalData.fromJson(json['rental_data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': sId,
      'payment_id': paymentId,
      'admin_id': adminId,
      'lease_id': leaseId,
      'payment_type': paymentType,
      'response': response,
      'entry': entry?.map((v) => v.toJson()).toList(),
      'total_amount': totalAmount,
      'type': type,
      'payment_attachment': paymentAttachment,
      'createdAt': createdAt,
      'check_number': checknumber,
      'updatedAt': updatedAt,
      'is_delete': isDelete,
      'rental_data': rentalData?.toJson(),
    };
  }
}

class Entryy {
  String? account;
  int? amount;
  String? chargeType;
  String? date;

  Entryy({this.account, this.amount, this.chargeType, this.date});

  factory Entryy.fromJson(Map<String, dynamic> json) {
    return Entryy(
      account: json['account']??"",
      amount: json['amount'] as int?,
      chargeType: json['charge_type']??"",
      date: json['date']??"",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'amount': amount,
      'charge_type': chargeType,
      'date': date,
    };
  }
}

class RentalData {
  String? rentalAdress;

  RentalData({this.rentalAdress});

  factory RentalData.fromJson(Map<String, dynamic> json) {
    return RentalData(
      rentalAdress: json['rental_adress'] ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rental_adress': rentalAdress,
    };
  }
}