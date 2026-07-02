import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:three_zero_two_property/model/lease.dart';

import '../../../../constant/constant.dart';

String get _clientSource => Platform.isIOS ? 'mobile-ios' : 'mobile-android';

class PaymentService {
  Future<String> makePaymentforcard({
    required String adminId,
    required String firstName,
    required String lastName,
    required String emailName,
    required String customerVaultId,
    required String billingId,
    required String surcharge,
    required String amount,
    required String tenantId,
    required String date,
    required String address1,
    required String processorId,
    required String leaseid,
    required String company_name,
    required bool future_Date,
    required bool scheduledPayment,
    required List<Map<String, dynamic>> entries,
    String? notificationTime,
    required String paymentAmountType,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');

    print("surcharge $surcharge");

    if (future_Date == false) {
      final String baseUrl = '$Api_url/api/nmipayment/sale';
      print(baseUrl);
      Map<String, dynamic> paymentDetails = {
        'admin_id': adminId,
        'first_name': firstName,
        'last_name': lastName,
        'email_name': emailName,
        'customer_vault_id': customerVaultId,
        'billing_id': billingId,
        'surcharge': surcharge,
        'amount': amount,
        'tenantId': tenantId,
        'tenant_id': tenantId,
        'date': date,
        'address1': address1,
        'processor_id': processorId,
        'notificationTime': notificationTime,
        'lease_id': leaseid,
        'tenantName': '$firstName $lastName',
        'source': 'tenant',
        'entry': entries.map((e) => {
          'entry_id': e['entry_id'],
          'account': e['account'],
          'amount': e['amount'],
          'balance': e['balance'],
          'memo': e['memo'],
          'date': e['date'],
          'charge_type': e['charge_type'],
        }).toList(),
        'scheduledPayment': scheduledPayment,
      };
      print(paymentDetails);

      final response = await apiPost(
        Uri.parse(baseUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
          "X-Idempotency-Key": Uuid().v4(),
          "X-Client-Source": _clientSource,
        },
        body: jsonEncode({"paymentDetails": paymentDetails, "is_web": true}),
      );

      print("[CARD PAYMENT] /api/nmipayment/sale status: ${response.statusCode}");
      print("[CARD PAYMENT] /api/nmipayment/sale response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 100) {
          print("[CARD PAYMENT] SUCCESS — transactionId: ${jsonData["data"]["transactionid"]}, responseText: ${jsonData["data"]["responsetext"]}");

          // NOTE: /api/nmipayment/sale now saves payment to DB internally (backend change by Neil).
          // storePayment() call removed to prevent duplicate transaction entries.
          // OLD FLOW (commented out — restore if backend reverts):
          // await Future.wait([
          //   storePayment(
          //       companyName: company_name,
          //       adminId: adminId,
          //       tenantId: tenantId,
          //       leaseId: leaseid,
          //       paymentAmountType: paymentAmountType,
          //       paymentType: "Card",
          //       customerVaultId: customerVaultId,
          //       billingId: billingId,
          //       totalAmount: amount,
          //       isLeaseAdded: false,
          //       uploadedFile: "",
          //       date: date,
          //       scheduledPayment: scheduledPayment,
          //       transactionId: jsonData["data"]["transactionid"],
          //       responseText: "SUCCESS",
          //       surcharge: surcharge,
          //       notificationTime: notificationTime),
          // ]);

          return "Payment Success";
        } else {
          print("[CARD PAYMENT] FAILED — ${jsonData["message"]}");
          throw Exception('Failed payment ${jsonData["message"]}');
        }
      } else {
        print("[CARD PAYMENT] HTTP ERROR — status: ${response.statusCode}, body: ${response.body}");
        throw Exception('Failed to make payment');
      }
    } else {
      try {
        // Store payment for future transactions
        await storePayment(
            companyName: company_name,
            adminId: adminId,
            tenantId: tenantId,
            leaseId: leaseid,
            paymentType: "Card",
            customerVaultId: customerVaultId,
            billingId: billingId,
            paymentAmountType: paymentAmountType,
            totalAmount: amount,
            isLeaseAdded: false,
            scheduledPayment: scheduledPayment,
            uploadedFile: "",
            transactionId: "",
            date: date,
            responseText: "PENDING",
            surcharge: surcharge,
            notificationTime: notificationTime,
            entries: entries);
        return "Payment Scheduled Successfully";
      } catch (e) {
        throw Exception(e);
      }
    }
    return "";
  }

  Future<Map<String, dynamic>> storePayment({
    required String companyName,
    required String adminId,
    required String tenantId,
    required String leaseId,
    required String paymentType,
    required String customerVaultId,
    required String billingId,
    String? notificationTime,
    required String totalAmount,
    required bool isLeaseAdded,
    required String uploadedFile,
    required String transactionId,
    required String responseText,
    required String surcharge,
    required String paymentAmountType,
    required String date,
    required bool scheduledPayment,
    List<Map<String, dynamic>>? entries,
  }) async {
    final String baseUrl = '$Api_url/api/payment/tenant-payment';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');
    print(totalAmount);
    print(((double.tryParse(totalAmount) ?? 0.0) - (double.tryParse(surcharge) ?? 0.0)).toString());
    log(jsonEncode(<String, dynamic>{
      'company_name': companyName,
      'admin_id': adminId,
      'tenant_id': tenantId,
      'lease_id': leaseId,
      'payment_type': paymentType,
      'paymentAmountType': paymentAmountType,
      'customer_vault_id': customerVaultId,
      'billing_id': billingId,
      'notificationTime': notificationTime,
      'total_amount': (double.tryParse(totalAmount) ?? 0.0),
      'surcharge': (double.tryParse(surcharge) ?? 0.0),
      'is_leaseAdded': isLeaseAdded,
      'uploaded_file': uploadedFile,
      'transaction_id': transactionId,
      'response': responseText,
      'date': date,
      'scheduleRecurring': scheduledPayment
    }));
    final response = await apiPost(
      Uri.parse(baseUrl),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        "Content-Type": "application/json",
          "X-Idempotency-Key": Uuid().v4(),
          "X-Client-Source": _clientSource,
      },
      body: jsonEncode(<String, dynamic>{
        'company_name': companyName,
        'admin_id': adminId,
        'tenant_id': tenantId,
        'lease_id': leaseId,
        'payment_type': paymentType,
        'paymentAmountType': paymentAmountType,
        'customer_vault_id': customerVaultId,
        'billing_id': billingId,
        'notificationTime': notificationTime,
        'total_amount': (double.tryParse(totalAmount) ?? 0.0),
        'surcharge': (double.tryParse(surcharge) ?? 0.0),
        'is_leaseAdded': isLeaseAdded,
        'uploaded_file': uploadedFile,
        'transaction_id': transactionId,
        'response': responseText,
        'date': date,
        'scheduleRecurring': scheduledPayment,
        'is_web': true,
        'type': 'Payment',
        if (entries != null) 'entry': entries,
      }),
    );

    print(response);
    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to payment ${jsonDecode(response.body)["message"]}');
    }
  }

  Future<String> makePaymentforach({
    required String adminId,
    required String firstName,
    required String lastName,
    required String emailName,
    required String surcharge,
    required String amount,
    required String tenantId,
    required String date,
    required String address1,
    required String processorId,
    required String leaseid,
    required String company_name,
    required String account_type,
    required String account_holder_type,
    required String checkaccount,
    required String checkaba,
    required String checkname,
    required bool future_Date,
    required List<Map<String, dynamic>> entries,
    String? billingId,
    String? customerVaultId,
    String? paymentAmountType,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');

    print("surcharge ${surcharge}");
    if (future_Date == false) {
      final String baseUrl = '$Api_url/api/nmipayment/ACH_sale';
      print(baseUrl);
      Map<String, dynamic> paymentDetails = {
        'admin_id': adminId,
        'first_name': firstName,
        'last_name': lastName,
        'email_name': emailName,
        'surcharge': surcharge,
        'amount': amount,
        'tenantId': tenantId,
        'tenant_id': tenantId,
        'date': date,
        'lease_id': leaseid,
        'address1': address1,
        'processor_id': processorId,
        'tenantName': '$firstName $lastName',
        'source': 'tenant',
        'entry': entries.map((e) => {
          'entry_id': e['entry_id'],
          'account': e['account'],
          'amount': e['amount'],
          'balance': e['balance'],
          'memo': e['memo'],
          'date': e['date'],
          'charge_type': e['charge_type'],
        }).toList(),
      };
      if (billingId != null && billingId.isNotEmpty && customerVaultId != null && customerVaultId.isNotEmpty) {
        paymentDetails['billing_id'] = billingId;
        paymentDetails['customer_vault_id'] = customerVaultId;
        paymentDetails['paymentType'] = 'check';
      } else {
        paymentDetails['checkname'] = checkname;
        paymentDetails['account_type'] = account_type;
        paymentDetails['checkaccount'] = checkaccount;
        paymentDetails['checkaba'] = checkaba;
        paymentDetails['account_holder_type'] = account_holder_type;
      }
      print(paymentDetails);

      final response = await apiPost(
        Uri.parse(baseUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
          "X-Idempotency-Key": Uuid().v4(),
          "X-Client-Source": _clientSource,
        },
        body: jsonEncode({"paymentDetails": paymentDetails, "is_web": true}),
      );

      print("[ACH PAYMENT] /api/nmipayment/ACH_sale status: ${response.statusCode}");
      print("[ACH PAYMENT] /api/nmipayment/ACH_sale response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 100) {
          final data = jsonData["data"];
          final transactionId = data["transactionid"]?.toString() ?? "";
          final responseText = data["responsetext"]?.toString() ?? "SUCCESS";
          print("[ACH PAYMENT] SUCCESS — transactionId: $transactionId, responseText: $responseText");

          // NOTE: /api/nmipayment/ACH_sale now saves payment to DB internally (backend change by Neil).
          // storePaymentAch() call removed to prevent duplicate transaction entries.
          // OLD FLOW (commented out — restore if backend reverts):
          // final authcode = data["authcode"]?.toString() ?? "";
          // final responseCode = data["response_code"]?.toString() ?? "100";
          // await storePaymentAch(
          //   adminId: adminId,
          //   tenantId: tenantId,
          //   leaseId: leaseid,
          //   entries: entries,
          //   totalAmount: amount,
          //   surcharge: surcharge,
          //   transactionId: transactionId,
          //   responseText: responseText,
          //   authcode: authcode,
          //   responseCode: responseCode,
          //   paymentAmountType: paymentAmountType ?? "full",
          //   date: date,
          // );

          return "Payment Success";
        } else {
          print("[ACH PAYMENT] FAILED — ${jsonData["message"]}");
          throw Exception('Failed payment ${jsonData["message"]}');
        }
      } else {
        print("[ACH PAYMENT] HTTP ERROR — status: ${response.statusCode}, body: ${response.body}");
        throw Exception('Failed to make payment');
      }
    } else {
      try {
        // Scheduled future ACH payment — still uses /api/payment/tenant-payment directly (no NMI call)
        await storePaymentAch(
          adminId: adminId,
          tenantId: tenantId,
          leaseId: leaseid,
          entries: entries,
          totalAmount: amount,
          surcharge: surcharge,
          transactionId: "",
          responseText: "PENDING",
          authcode: "",
          responseCode: "",
          paymentAmountType: paymentAmountType ?? "full",
          date: date,
        );
        return "Payment Scheduled Successfully";
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  Future<Map<String, dynamic>> storePaymentAch({
    required String adminId,
    required String tenantId,
    required String leaseId,
    required List<Map<String, dynamic>> entries,
    required String totalAmount,
    required String surcharge,
    required String transactionId,
    required String responseText,
    required String authcode,
    required String responseCode,
    required String paymentAmountType,
    required String date,
  }) async {
    final String baseUrl = '$Api_url/api/payment/tenant-payment';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');
    final notificationTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final body = <String, dynamic>{
      'admin_id': adminId,
      'tenant_id': tenantId,
      'lease_id': leaseId,
      'surcharge': double.tryParse(surcharge) ?? 0.0,
      'total_amount': double.tryParse(totalAmount) ?? 0.0,
      'entry': entries,
      'date': date,
      'transaction_id': transactionId,
      'response': responseText,
      'responseCode': responseCode,
      'authcode': authcode,
      'avsresponse': '',
      'cvvresponse': '',
      'payment_type': 'ACH',
      'paymentAmountType': paymentAmountType,
      'is_leaseAdded': false,
      'is_web': true,
      'notificationTime': notificationTime,
      'scheduleRecurring': false,
      'state': 'settling',
      'reference': '',
    };
    final response = await apiPost(
      Uri.parse(baseUrl),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        "Content-Type": "application/json",
          "X-Idempotency-Key": Uuid().v4(),
          "X-Client-Source": _clientSource,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to payment ${jsonDecode(response.body)["message"]}');
    }
  }

  Future<String> makePaymentfornormal({
    required String adminId,
    required String firstName,
    required String lastName,
    required String emailName,
    //  required String customerVaultId,
    //required String billingId,
    required String surcharge,
    required String amount,
    required String tenantId,
    required String date,
    required String address1,
    required String processorId,
    required String leaseid,
    required String company_name,
    /* required String account_type,
    required String account_holder_type,
    required String checkaccount,
    required String checkaba,
    required String checkname,*/
    required bool future_Date,
    required String Check_number,
    required bool Check,
    required String payment_method,
    required List<Map<String, dynamic>> entries,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');
    print("surcharge ${surcharge}");
    if (future_Date == false) {
      final String baseUrl = '$Api_url/api/nmipayment/ACH_sale';
      print(baseUrl);
      Map<String, dynamic> paymentDetails = {
        'admin_id': adminId,
        'first_name': firstName,
        'last_name': lastName,
        'email_name': emailName,
        'lease_id': leaseid,
        /*'checkname': checkname,
        'account_type': account_type,
        'checkaccount': checkaccount,
        'checkaba': checkaba,
        'account_holder_type': account_holder_type,*/
        'surcharge': surcharge,
        'amount': amount,
        'tenantId': tenantId,
        'tenant_id': tenantId,
        'date': date,
        'address1': address1,
        'processor_id': processorId,
      };
      print(paymentDetails);
      final response = await apiPost(
        Uri.parse(baseUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
          "X-Idempotency-Key": Uuid().v4(),
          "X-Client-Source": _clientSource,
        },
        body: jsonEncode({"paymentDetails": paymentDetails, "is_web": true}),
      );
      print("[NORMAL/CHECK PAYMENT] /api/nmipayment/ACH_sale status: ${response.statusCode}");
      print("[NORMAL/CHECK PAYMENT] /api/nmipayment/ACH_sale response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 100) {
          final data = jsonData["data"];
          print("[NORMAL/CHECK PAYMENT] SUCCESS — transactionId: ${data["transactionid"]}, responseText: ${data["responsetext"]}");

          // NOTE: /api/nmipayment/ACH_sale now saves payment to DB internally (backend change by Neil).
          // storePaymentAch() call removed to prevent duplicate transaction entries.
          // OLD FLOW (commented out — restore if backend reverts):
          // await storePaymentAch(
          //   adminId: adminId,
          //   tenantId: tenantId,
          //   leaseId: leaseid,
          //   entries: entries,
          //   totalAmount: amount,
          //   surcharge: surcharge,
          //   transactionId: data["transactionid"]?.toString() ?? "",
          //   responseText: data["responsetext"]?.toString() ?? "SUCCESS",
          //   authcode: data["authcode"]?.toString() ?? "",
          //   responseCode: data["response_code"]?.toString() ?? "100",
          //   paymentAmountType: "full",
          //   date: date,
          // );

          return "Payment Success";
        } else {
          print("[NORMAL/CHECK PAYMENT] FAILED — ${jsonData["message"]}");
          throw Exception('Failed payment ${jsonData["message"]}');
        }
      } else {
        print("[NORMAL/CHECK PAYMENT] HTTP ERROR — status: ${response.statusCode}, body: ${response.body}");
        throw Exception('Failed to make payment');
      }
    } else {
      try {
        // Scheduled future check/normal payment — still uses /api/payment/payment directly
        storePaymentfornormal(
            companyName: company_name,
            adminId: adminId,
            tenantId: tenantId,
            leaseId: leaseid,
            paymentType: payment_method,
            entries: entries,
            totalAmount: amount,
            isLeaseAdded: false,
            uploadedFile: "",
            checknumber: Check_number,
            responseText: "PENDING",
            surcharge: surcharge);
        return "Payment Successfully";
      } catch (e) {
        throw Exception(e);
      }
    }
  }

  Future<Map<String, dynamic>> storePaymentfornormal({
    required String companyName,
    required String adminId,
    required String tenantId,
    required String leaseId,
    required String paymentType,
    required List<Map<String, dynamic>> entries,
    required String totalAmount,
    required bool isLeaseAdded,
    required String uploadedFile,
    required String checknumber,
    required String responseText,
    required String surcharge,
  }) async {
    final String baseUrl = '$Api_url/api/payment/payment';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');

    final response = await apiPost(
      Uri.parse(baseUrl),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        "Content-Type": "application/json",
          "X-Idempotency-Key": Uuid().v4(),
          "X-Client-Source": _clientSource,
      },
      body: jsonEncode(<String, dynamic>{
        'company_name': companyName,
        'admin_id': adminId,
        'tenant_id': tenantId,
        'lease_id': leaseId,
        'payment_type': paymentType,
        'entry': entries,
        'total_amount': totalAmount,
        'is_leaseAdded': isLeaseAdded,
        'uploaded_file': uploadedFile,
        'check_number': checknumber,
        'response': "SUCCESS",
      }),
    );
    print("payment ${response.body}");
    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to payment ${jsonDecode(response.body)["message"]}');
    }
  }
}
