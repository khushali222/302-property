import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/Dashbord_table/Payment_refund_model.dart';
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

    final http.Response response = await apiPut(
      Uri.parse('$apiUrl/$paymentid'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    var responseData = json.decode(response.body);

    if (responseData["statusCode"] == 200) {
      // Fluttertoast.showToast(
      //     msg: responseData["message"] ?? "Acknowledgment successful");
      Alert(
        context: context,
        type: AlertType.success,
        title: "Success",
        desc: responseData["message"] ??
            "Failed Payment Acknowledge Successfully!",
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

    final http.Response response = await apiPut(
      Uri.parse('${Api_url}/api/payment/payment_retry/$paymentid'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    var responseData = json.decode(response.body);

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

    final http.Response response = await apiPut(
      Uri.parse('${Api_url}/api/payment/payment_reschedule/$paymentid'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    var responseData = json.decode(response.body);

    if (responseData["statusCode"] == 200) {
      // Fluttertoast.showToast(
      //     msg: responseData["message"] ??
      //         "Payment retry scheduled successfully!");

      Alert(
        context: context,
        type: AlertType.success,
        title: "Success",
        desc: responseData["message"] ?? "Payment rescheduled successfully!",
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

  Future<Map<String, dynamic>> VoidCron({
    required BuildContext context,
    required String? pay_id,
    required String? void_reason,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString('adminId');

    final http.Response response = await apiPost(
      Uri.parse('${Api_url}/api/nmipayment/void-payment/$pay_id'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
        "X-Idempotency-Key": Uuid().v4(),
      },
      body: jsonEncode({
        "voidDetails": {
          "admin_id": adminid,
          "void_reason": void_reason,
        }
      }),
    );

    var responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      Alert(
        context: context,
        type: AlertType.success,
        title: "Success",
        desc: responseData["message"] ?? "Payment successfully voided.",
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
      Fluttertoast.showToast(msg: responseData["message"]);
      return responseData;
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to void payment');
    }
  }

  Future<List<PaymentRefund>> fetchPaymentRefunds(String paymentId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminId = prefs.getString('adminId');

      final response = await apiGet(
        Uri.parse('$Api_url/api/payment/payment/$paymentId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $adminId",
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );


      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData is Map<String, dynamic> && jsonData.containsKey('data')) {
          final data = jsonData['data'];

          if (data is Map<String, dynamic> && data.containsKey('0')) {
            final refundData = data;
            return [PaymentRefund.fromJson(refundData)];
          } else {
            throw Exception("Invalid data format: Missing '0' key in 'data'");
          }
        } else {
          throw Exception("Unexpected response format");
        }
      } else {
        throw Exception(
            'Failed to load payment refunds: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching payment refunds: $e');
    }
  }

  Future<dynamic> confirmRefund({
    required String paymentId,
    required String paymentType,
    required String transactionId,
    required double refundAmount,
    required String refundDate,
    required String memo,
    required String tenantFirstName,
    required String tenantLastName,
    required String tenantEmail,
    required String tenantId,
    required String leaseId,
    required List<Map<String, dynamic>> entry,
    String? customerVaultId,
    String? billingId,
    required BuildContext context,
  }) async {
    final String apiUrll = (paymentType == "Cash" || paymentType == "Check")
        ? "$Api_url/api/nmipayment/manual-refund/$paymentId"
        : "$Api_url/api/nmipayment/new-refund";
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString('adminId');
    final Map<String, dynamic> commonData = {
      "admin_id": adminid,
      "transactionId": transactionId,
      "amount": refundAmount,
      "payment_type": paymentType,
      "total_amount": refundAmount,
      "tenant_firstName": tenantFirstName,
      "tenant_lastName": tenantLastName,
      "tenantName": "$tenantFirstName $tenantLastName".trim(),
      "tenant_id": tenantId,
      "lease_id": leaseId,
      "email_name": tenantEmail,
      "type": "Refund",
      "entry": entry
          .map((item) => {
                "amount": item["amount"],
                "account": item["account"],
                "date": refundDate,
                "memo": memo,
              })
          .toList(),
    };

    if (paymentType == "Card" || paymentType == "ACH") {
      commonData["customer_vault_id"] = customerVaultId;
      commonData["billing_id"] = billingId;
    }

    final response = await apiPost(
      Uri.parse(apiUrll),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
        "X-Idempotency-Key": Uuid().v4(),
      },
      body: jsonEncode({"refundDetails": commonData}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return null;
    }
  }

  // Bulk Retry API
  Future<Map<String, dynamic>?> bulkRetry({
    required BuildContext context,
    required List<String> paymentIds,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString('adminId');

    final http.Response response = await apiPut(
      Uri.parse('${Api_url}/api/payment/payment_bulk_retry'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'payment_ids': paymentIds,
      }),
    );

    var responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else {
      return null;
    }
  }

  // Bulk Reschedule API
  Future<Map<String, dynamic>?> bulkReschedule({
    required BuildContext context,
    required List<String> paymentIds,
    required String retryDate,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString('adminId');

    final http.Response response = await apiPut(
      Uri.parse('${Api_url}/api/payment/payment_bulk_reschedule'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'payment_ids': paymentIds,
        'retryDate': retryDate,
      }),
    );

    var responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else {
      return null;
    }
  }

  // Bulk Acknowledge API
  Future<Map<String, dynamic>?> bulkAcknowledge({
    required BuildContext context,
    required List<String> paymentIds,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString('adminId');

    final http.Response response = await apiPut(
      Uri.parse('${Api_url}/api/payment/payment_bulk_acknowledge'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'payment_ids': paymentIds,
        'failure_acknowledged': true,
      }),
    );

    var responseData = json.decode(response.body);

    if (response.statusCode == 200) {
      return responseData;
    } else {
      return null;
    }
  }
}
