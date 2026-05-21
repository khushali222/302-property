import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constant/constant.dart';

// class Transaction {
//   final String property;
//   final String tenantFirstName;
//   final String tenantLastName;
//   final DateTime? createdAt;
//   final String transactionId;
//   final String paymentType;
//   final String ccNumber;
//   final String cctype;
//    String? surcharge;
//
// String? reason;
//   var totalAmount;
//   final List<Entry> entries;
//
//   Transaction({
//     required this.property,
//     required this.tenantFirstName,
//     required this.tenantLastName,
//     required this.createdAt,
//     required this.transactionId,
//     required this.paymentType,
//     required this.ccNumber,
//     required this.totalAmount,
//     required this.cctype,
//      this.surcharge,
//     required this.entries,
//     this.reason
//   });
// }
// class Entry {
//   final String description;
//   var amount;
//
//   Entry({
//     required this.description,
//     required this.amount,
//   });
// }
// List<Transaction> parseTransactions(List<dynamic> jsonData) {
//
//   return jsonData.map((json) {
//    log(json.toString());
//     return Transaction(
//       property: json['rental_data'] != null ? json['rental_data']['rental_adress'] : 'N/A',
//       tenantFirstName: json['tenant_data'] != null ? json['tenant_data']['tenant_firstName'] : 'N/A',
//       tenantLastName: json['tenant_data'] != null ? json['tenant_data']['tenant_lastName'] : 'N/A',
//      // createdAt: DateTime.parse(json['createdAt']),
//       transactionId: json['transaction_id'] ?? "N/A",
//       paymentType: json['payment_type'],
//       ccNumber: json['cc_number'] ?? 'N/A',
//       totalAmount: json['total_amount'],
//       cctype: json['cc_type']??"",
//         reason: json['reason']??"",
//       surcharge:  json['surcharge'] == null ?  "0" : json['surcharge'].toString() ,
//       entries: json['entry'] != null
//           ? (json['entry'] as List<dynamic>).map((entry) {
//         return Entry(
//           description: entry['account'],
//           amount: entry['amount'],
//         );
//       }).toList()
//           : [],
//     );
//   }).toList();
// }

class DailyTransactionReportData {
  int statusCode;
  double grandTotal; // Added grandTotal field
  List<DailyTransactionReport> data;

  DailyTransactionReportData(
      {required this.statusCode, required this.grandTotal, required this.data});

  factory DailyTransactionReportData.fromJson(Map<String, dynamic> json) {
    return DailyTransactionReportData(
      statusCode: json['statusCode'],
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ??
          0.0, // Handle missing grandTotal
      data: List<DailyTransactionReport>.from(
          json['data'].map((x) => DailyTransactionReport.fromJson(x))),
    );
  }
}

class DailyTransactionReport {
  final String? date;
  final double? subtotal;
  final List<ChargeData>? charges;

  DailyTransactionReport({
    this.date,
    this.subtotal,
    this.charges,
  });

  static DailyTransactionReport fromJson(Map<String, dynamic> json) {
    return DailyTransactionReport(
      date: json['date'],
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      charges: (json['charges'] as List<dynamic>?)
          ?.map((e) => ChargeData.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'subtotal': subtotal,
      'charges': charges?.map((e) => e.toJson()).toList(),
    };
  }
}

class ChargeData {
  final String? id;
  final String? paymentId;
  final String? adminId;
  final String? leaseId;
  final String? tenantId;
  final int? customerVaultId;
  final int? billingId;
  final String? paymentType;
  final String? transactionId;
  final String? response;
  final List<EntryData>? entry;
  final double? totalAmount;
  final String? type;
  final String? cc_type;
  final String? cc_number;
  final String? reason;
  final List<dynamic>? paymentAttachment;
  final String? updatedAt;
  final bool? isDelete;
  final TenantData? tenantData;
  final RentalData? rentalData;
  final UnitData? unitData;

  ChargeData({
    this.id,
    this.paymentId,
    this.adminId,
    this.leaseId,
    this.tenantId,
    this.customerVaultId,
    this.billingId,
    this.paymentType,
    this.transactionId,
    this.response,
    this.entry,
    this.totalAmount,
    this.type,
    this.cc_type,
    this.cc_number,
    this.reason,
    this.paymentAttachment,
    this.updatedAt,
    this.isDelete,
    this.tenantData,
    this.rentalData,
    this.unitData,
  });

  static ChargeData fromJson(Map<String, dynamic> json) {
    return ChargeData(
      id: json['_id']?.toString(),
      paymentId: json['payment_id']?.toString(),
      adminId: json['admin_id']?.toString(),
      leaseId: json['lease_id']?.toString(),
      tenantId: json['tenant_id']?.toString(),
      customerVaultId: json['customer_vault_id'],
      billingId: json['billing_id'],
      paymentType: json['payment_type']?.toString(),
      transactionId: json['transaction_id']?.toString(),
      response: json['response']?.toString(),
      entry: (json['entry'] as List<dynamic>?)
          ?.map((e) => e is Map<String, dynamic> ? EntryData.fromJson(e) : null)
          .where((e) => e != null)
          .cast<EntryData>()
          .toList(),
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      type: json['type']?.toString(),
      cc_type: json['cc_type']?.toString(),
      cc_number: json['cc_number']?.toString(),
      reason: json['reason']?.toString(),
      paymentAttachment: json['payment_attachment'],
      updatedAt: json['updatedAt']?.toString(),
      isDelete: json['is_delete'],
      tenantData: json['tenant_data'] != null &&
              json['tenant_data'] is Map<String, dynamic>
          ? TenantData.fromJson(json['tenant_data'])
          : null,
      rentalData: json['rental_data'] != null &&
              json['rental_data'] is Map<String, dynamic>
          ? RentalData.fromJson(json['rental_data'])
          : null,
      unitData:
          json['unit_data'] != null && json['unit_data'] is Map<String, dynamic>
              ? UnitData.fromJson(json['unit_data'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'payment_id': paymentId,
      'admin_id': adminId,
      'lease_id': leaseId,
      'tenant_id': tenantId,
      'customer_vault_id': customerVaultId,
      'billing_id': billingId,
      'payment_type': paymentType,
      'transaction_id': transactionId,
      'response': response,
      'entry': entry?.map((e) => e.toJson()).toList(),
      'total_amount': totalAmount,
      'type': type,
      'cc_type': cc_type,
      'cc_number': cc_number,
      'reason': reason,
      'payment_attachment': paymentAttachment,
      'updatedAt': updatedAt,
      'is_delete': isDelete,
      'tenant_data': tenantData?.toJson(),
      'rental_data': rentalData?.toJson(),
      'unit_data': unitData?.toJson(),
    };
  }
}

class EntryData {
  final String? account;
  final double? amount;
  final String? chargeType;
  final String? date;

  EntryData({this.account, this.amount, this.chargeType, this.date});

  static EntryData fromJson(Map<String, dynamic> json) {
    return EntryData(
      account: json['account']?.toString(),
      amount: (json['amount'] as num?)?.toDouble(),
      chargeType: json['charge_type']?.toString(),
      date: json['date']?.toString(),
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

class TenantData {
  final String? tenantFirstName;
  final String? tenantLastName;

  TenantData({this.tenantFirstName, this.tenantLastName});

  static TenantData fromJson(Map<String, dynamic> json) {
    return TenantData(
      tenantFirstName: json['tenant_firstName']?.toString(),
      tenantLastName: json['tenant_lastName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_firstName': tenantFirstName,
      'tenant_lastName': tenantLastName,
    };
  }
}

class RentalData {
  final String? rentalAddress;

  RentalData({this.rentalAddress});

  static RentalData fromJson(Map<String, dynamic> json) {
    return RentalData(
      rentalAddress: json['rental_adress']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rental_adress': rentalAddress,
    };
  }
}

class UnitData {
  final String? rentalUnit;
  final String? rentalUnitAddress;

  UnitData({this.rentalUnit, this.rentalUnitAddress});

  static UnitData fromJson(Map<String, dynamic> json) {
    return UnitData(
      rentalUnit: json['rental_unit']?.toString(),
      rentalUnitAddress: json['rental_unit_adress']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rental_unit': rentalUnit,
      'rental_unit_adress': rentalUnitAddress,
    };
  }
}

class DailyTrasactionReport {
  final String baseUrl = '$Api_url/api/payment/todayspayment';

  Future<DailyTransactionReportData> fetchDailyTransactions(
      String adminId, String selectedStartDate, String selectedEndDate,
      {String? chargetype}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final String endpoint = '/$adminId';
    String url =
        '$baseUrl$endpoint?selectedDate=$selectedStartDate&selectedToDate=$selectedEndDate';

    if (chargetype != null) {
      url = '$url&selectedChargeType=$chargetype';
    }
    // print("API URL: $url");
    // print("selectedStartDate: '$selectedStartDate'");
    // print("selectedEndDate: '$selectedEndDate'");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );
      // print("report daily transaction ${response.body}");

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        // print(parsedJson);
        return DailyTransactionReportData.fromJson(parsedJson);
      } else {
        // Handle error response
        // print('Failed to load report. Status code: ${response.statusCode}');
        throw Exception('Failed to load renters insurance');
      }
    } catch (error) {
      // Handle error during fetch
      // print('Error fetching daily transaction reportsd: $error');
      throw Exception('Failed to load renters insurance');
    }
  }
}

class DailyTrasactionReportStaff {
  final String baseUrl = '$Api_url/api/payment/todayspayment';

  Future<DailyTransactionReportData> fetchDailyTransactionsstaff(
      String adminId, String selectedStartDate, String selectedEndDate,
      {String? chargetype}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("staff_id");
    final String endpoint = '/$adminId';
    String url =
        '$baseUrl$endpoint?selectedDate=$selectedStartDate&selectedToDate=$selectedEndDate';

    if (chargetype != null) {
      url = '$url&selectedChargeType=$chargetype';
    }
    // print(url);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );
      // print("report daily transaction ${response.body}");

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        // print(parsedJson);
        return DailyTransactionReportData.fromJson(parsedJson);
      } else {
        // Handle error response
        // print('Failed to load report. Status code: ${response.statusCode}');
        throw Exception('Failed to load renters insurance');
      }
    } catch (error) {
      // Handle error during fetch
      // print('Error fetching daily transaction reportsd: $error');
      throw Exception('Failed to load renters insurance');
    }
  }
}
