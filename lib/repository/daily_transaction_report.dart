import 'dart:convert';
import 'dart:developer';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../constant/constant.dart';

class Transaction {
  final String property;
  final String tenantFirstName;
  final String tenantLastName;
  final DateTime createdAt;
  final String transactionId;
  final String paymentType;
  final String ccNumber;
  final String cctype;
   String? surcharge;

String? reason;
  var totalAmount;
  final List<Entry> entries;

  Transaction({
    required this.property,
    required this.tenantFirstName,
    required this.tenantLastName,
    required this.createdAt,
    required this.transactionId,
    required this.paymentType,
    required this.ccNumber,
    required this.totalAmount,
    required this.cctype,
     this.surcharge,
    required this.entries,
    this.reason
  });
}
class Entry {
  final String description;
  var amount;

  Entry({
    required this.description,
    required this.amount,
  });
}
List<Transaction> parseTransactions(List<dynamic> jsonData) {

  return jsonData.map((json) {
   log(json.toString());
    return Transaction(
      property: json['rental_data'] != null ? json['rental_data']['rental_adress'] : 'N/A',
      tenantFirstName: json['tenant_data'] != null ? json['tenant_data']['tenant_firstName'] : 'N/A',
      tenantLastName: json['tenant_data'] != null ? json['tenant_data']['tenant_lastName'] : 'N/A',
      createdAt: DateTime.parse(json['createdAt']),
      transactionId: json['transaction_id'] ?? "N/A",
      paymentType: json['payment_type'],
      ccNumber: json['cc_number'] ?? 'N/A',
      totalAmount: json['total_amount'],
      cctype: json['cc_type']??"",
        reason: json['reason']??"",
      surcharge:  json['surcharge'] == null ?  "0" : json['surcharge'].toString() ,
      entries: json['entry'] != null
          ? (json['entry'] as List<dynamic>).map((entry) {
        return Entry(
          description: entry['account'],
          amount: entry['amount'],
        );
      }).toList()
          : [],
    );
  }).toList();
}
class DailyTrasactionReport{

  Future<List<Transaction>> fetchTransactions(String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    print("${Api_url}/api/payment/todayspayment/$id?selectedDate=$date");
    final response = await http.get(
      Uri.parse('${Api_url}/api/payment/dailyreport/$id?selectedDate=$date'),
      headers: {
        'Content-Type': 'application/json',
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body)["data"];
      return parseTransactions(jsonData);
    } else {
      throw Exception('Failed to load transactions');
    }
  }

}