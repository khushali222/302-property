

// Safe money parsing only — `show` keeps the rest of constant.dart out of
// this model's namespace.
import 'package:three_zero_two_property/constant/constant.dart' show asDouble;

// class AccountTotalsReport {
//   String? _sId;
//   String? _rentalOwnerName;
//   int? _subTotal;
//   List<Payments>? _payments;
//   String? _rentalownerId;
//
//   AccountTotalsReport(
//       {String? sId,
//         String? rentalOwnerName,
//         int? subTotal,
//         List<Payments>? payments,
//         String? rentalownerId}) {
//     if (sId != null) {
//       this._sId = sId;
//     }
//     if (rentalOwnerName != null) {
//       this._rentalOwnerName = rentalOwnerName;
//     }
//     if (subTotal != null) {
//       this._subTotal = subTotal;
//     }
//     if (payments != null) {
//       this._payments = payments;
//     }
//     if (rentalownerId != null) {
//       this._rentalownerId = rentalownerId;
//     }
//   }
//
//   String? get sId => _sId;
//   set sId(String? sId) => _sId = sId;
//   String? get rentalOwnerName => _rentalOwnerName;
//   set rentalOwnerName(String? rentalOwnerName) =>
//       _rentalOwnerName = rentalOwnerName;
//   int? get subTotal => _subTotal;
//   set subTotal(int? subTotal) => _subTotal = subTotal;
//   List<Payments>? get payments => _payments;
//   set payments(List<Payments>? payments) => _payments = payments;
//   String? get rentalownerId => _rentalownerId;
//   set rentalownerId(String? rentalownerId) => _rentalownerId = rentalownerId;
//
//   AccountTotalsReport.fromJson(Map<String, dynamic> json) {
//     _sId = json['_id'];
//     _rentalOwnerName = json['rentalOwner_name'];
//     _subTotal = json['sub_total'];
//     if (json['payments'] != null) {
//       _payments = <Payments>[];
//       json['payments'].forEach((v) {
//         _payments!.add(new Payments.fromJson(v));
//       });
//     }
//     _rentalownerId = json['rentalowner_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['_id'] = this._sId;
//     data['rentalOwner_name'] = this._rentalOwnerName;
//     data['sub_total'] = this._subTotal;
//     if (this._payments != null) {
//       data['payments'] = this._payments!.map((v) => v.toJson()).toList();
//     }
//     data['rentalowner_id'] = this._rentalownerId;
//     return data;
//   }
// }
//
// class Payments {
//   String? _account;
//   int? _amount;
//   String? _sId;
//
//   Payments({String? account, int? amount, String? sId}) {
//     if (account != null) {
//       this._account = account;
//     }
//     if (amount != null) {
//       this._amount = amount;
//     }
//     if (sId != null) {
//       this._sId = sId;
//     }
//   }
//
//   String? get account => _account;
//   set account(String? account) => _account = account;
//   int? get amount => _amount;
//   set amount(int? amount) => _amount = amount;
//   String? get sId => _sId;
//   set sId(String? sId) => _sId = sId;
//
//   Payments.fromJson(Map<String, dynamic> json) {
//     _account = json['account'];
//     _amount = json['amount'];
//     _sId = json['_id'];
//   }
//
//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = new Map<String, dynamic>();
//     data['account'] = this._account;
//     data['amount'] = this._amount;
//     data['_id'] = this._sId;
//     return data;
//   }
// }



class Payment {
  String account;
  double amount;
  String? id; // Optional, as it may not be present in all payments

  Payment({
    required this.account,
    required this.amount,
    this.id,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      account: json['account'] ?? '',
      amount: asDouble(json['amount']),
      id: json['_id'], // Optional, may be null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'amount': amount,
      if (id != null) '_id': id,
    };
  }
}

// RentalOwner model
class AccountTotalsReport {
  String id;
  String rentalOwnerName;
  double subTotal;
  List<Payment> payments;

  AccountTotalsReport({
    required this.id,
    required this.rentalOwnerName,
    required this.subTotal,
    required this.payments,
  });

  factory AccountTotalsReport.fromJson(Map<String, dynamic> json) {

    // Null-tolerant: a report row without a payments array renders with an
    // empty list instead of failing the whole report.
    var paymentsFromJson = json['payments'] as List? ?? [];
    List<Payment> paymentList = paymentsFromJson.map((i) => Payment.fromJson(i)).toList();
    return AccountTotalsReport(
      id: json['_id']??"",
      rentalOwnerName: json['rentalOwner_name'],
      // asDouble (constant.dart): a malformed value becomes 0.0 instead of
      // throwing and blanking the whole report via the repo's catch.
      subTotal: asDouble(json['sub_total']),
      payments: paymentList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'rentalOwner_name': rentalOwnerName,
      'sub_total': subTotal,
      'payments': payments.map((payment) => payment.toJson()).toList(),
    };
  }
}

