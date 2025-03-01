import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/constant.dart';

class PaymentCronjobRepository {
  final String apiUrl = '${Api_url}/api/payment/payment_acknowledge';
  Future<Map<String, dynamic>> Paymentacknowledge({
    required BuildContext context,
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
      // Fluttertoast.showToast(
      //     msg: responseData["message"] ?? "Acknowledgment successful");
      Alert(
        context: context,
        type: AlertType.success,
        title: "Success",
        desc:
        responseData["message"] ?? "Failed Payment Acknowledge Successfully!",
        style: AlertStyle(
          backgroundColor: Colors.white,
        ),
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () => Navigator.pop(context),
            color: blueColor,
          ),
        ],
      ).show();
      return responseData;
      // return json.decode(response.body);
    } else {
      Fluttertoast.showToast(
          msg: responseData["message"] ?? "Acknowledgment failed");
      throw Exception('Failed to Acknowledgement payment');
    }
  }

  Future<Map<String, dynamic>> PaymentRetry({
    required BuildContext context,
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
      // Fluttertoast.showToast(
      //     msg: responseData["message"] ??
      //         "Payment retry scheduled successfully!");

      Alert(
        context: context,
        type: AlertType.success,
        title: "Success",
        desc:
            responseData["message"] ?? "Payment retry scheduled successfully!",
        style: AlertStyle(
          backgroundColor: Colors.white,
        ),
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () => Navigator.pop(context),
            color: blueColor,
          ),
        ],
      ).show();
      return responseData;
      // return json.decode(response.body);
    } else {
      Fluttertoast.showToast(
          msg: responseData["message"] ?? "Payment retry scheduled failed");
      throw Exception('Failed to Acknowledgement payment');
    }
  }
  Future<Map<String, dynamic>> PaymentReSchedule({
    required BuildContext context,
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
      Uri.parse('${Api_url}/api/payment/PaymentReSchedule/$paymentid'),
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
      // Fluttertoast.showToast(
      //     msg: responseData["message"] ??
      //         "Payment retry scheduled successfully!");

      Alert(
        context: context,
        type: AlertType.success,
        title: "Success",
        desc:
        responseData["message"] ?? "Payment rescheduled successfully!",
        style: AlertStyle(
          backgroundColor: Colors.white,
        ),
        buttons: [
          DialogButton(
            child: Text(
              "Ok",
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () => Navigator.pop(context),
            color: blueColor,
          ),
        ],
      ).show();
      return responseData;
      // return json.decode(response.body);
    } else {
      Fluttertoast.showToast(
          msg: responseData["message"] ?? "Payment rescheduled failed");
      throw Exception('Failed to Acknowledgement payment');
    }
  }
}
