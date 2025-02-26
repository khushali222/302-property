import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/constant.dart';

class PaymentCronjobRepository {
  final String apiUrl = '${Api_url}/api/payment/payment_acknowledge';
  Future<Map<String, dynamic>> Paymentacknowledge({
    String? paymentid,
    bool? failureacknowledged = false,
  }) async {
    final Map<String, dynamic> data = {
      'payment_id': paymentid,
      'failure_acknowledged': failureacknowledged,
    };

    // print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString('adminId');

    final http.Response response = await http.put(
      Uri.parse('$apiUrl/$paymentid'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    var responseData = json.decode(response.body);
    print('responce of crojob Acknowledgement ${response.body}');

    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(
          msg: responseData["message"] ?? "Acknowledgment successful");
      return responseData;
      // return json.decode(response.body);
    } else {
      Fluttertoast.showToast(
          msg: responseData["message"] ?? "Acknowledgment failed");
      throw Exception('Failed to Acknowledgement payment');
    }
  }

  Future<Map<String, dynamic>> PaymentRetry({
    String? paymentid,
    String? retryDate,
  }) async {
    final Map<String, dynamic> data = {
      'payment_id': paymentid,
      'retryDate': retryDate,
    };

    // print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString('adminId');

    final http.Response response = await http.put(
      Uri.parse('${Api_url}/api/payment/payment_retry/$paymentid'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    var responseData = json.decode(response.body);
    print('responce of crojob Retry ${response.body}');

    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(
          msg: responseData["message"] ?? "Payment retry scheduled successfully!");
      return responseData;
      // return json.decode(response.body);
    } else {
      Fluttertoast.showToast(msg: responseData["message"] ?? "Payment retry scheduled failed");
      throw Exception('Failed to Acknowledgement payment');
    }
  }
}
