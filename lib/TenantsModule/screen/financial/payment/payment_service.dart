import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/lease.dart';

import '../../../../constant/constant.dart';

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
        'date': date,
        'address1': address1,
        'processor_id': processorId,
        'notificationTime': notificationTime,
        'lease_id': leaseid,
        'entry': entries,
        'scheduledPayment': scheduledPayment,
      };
      print(paymentDetails);

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"paymentDetails": paymentDetails}),
      );

      print(response.statusCode);
      print(" payment responce ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 100) {
          print(jsonData["data"]["responsetext"]);
          print(jsonData["data"]["transactionid"]);

          // Wait for both services to complete using Future.wait
          await Future.wait([
            storePayment(
                companyName: company_name,
                adminId: adminId,
                tenantId: tenantId,
                leaseId: leaseid,
                paymentAmountType: paymentAmountType,
                paymentType: "Card",
                customerVaultId: customerVaultId,
                billingId: billingId,
                totalAmount: amount,
                isLeaseAdded: false,
                uploadedFile: "",
                date: date,
                scheduledPayment: scheduledPayment,
                transactionId: jsonData["data"]["transactionid"],
                responseText: "SUCCESS",
                surcharge: surcharge,
                notificationTime: notificationTime),
          ]);
          return "Payment Success";
        } else {
          throw Exception('Failed payment ${jsonData["message"]}');
        }
      } else {
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
            notificationTime: notificationTime);
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
  }) async {
    final String baseUrl = '$Api_url/api/payment/tenant-payment';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');
    print(totalAmount);
    print((double.parse(totalAmount) - double.parse(surcharge)).toString());
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
      'total_amount': double.parse(totalAmount),
      'surcharge': double.parse(surcharge),
      'is_leaseAdded': isLeaseAdded,
      'uploaded_file': uploadedFile,
      'transaction_id': transactionId,
      'response': responseText,
      'date': date,
      'scheduleRecurring': scheduledPayment
    }));
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        "Content-Type": "application/json",
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
        'total_amount': double.parse(totalAmount),
        'surcharge': double.parse(surcharge),
        'is_leaseAdded': isLeaseAdded,
        'uploaded_file': uploadedFile,
        'transaction_id': transactionId,
        'response': responseText,
        'date': date,
        'scheduleRecurring': scheduledPayment
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
        'date': date,
        'lease_id': leaseid,
        'address1': address1,
        'processor_id': processorId,
        'entry': entries,
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
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"paymentDetails": paymentDetails, "is_web": true}),
      );

      if (response.statusCode == 200) {
        print(response.body);
        var jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 100) {
          final data = jsonData["data"];
          final transactionId = data["transactionid"]?.toString() ?? "";
          final responseText = data["responsetext"]?.toString() ?? "SUCCESS";
          final authcode = data["authcode"]?.toString() ?? "";
          final responseCode = data["response_code"]?.toString() ?? "100";
          await storePaymentAch(
            adminId: adminId,
            tenantId: tenantId,
            leaseId: leaseid,
            entries: entries,
            totalAmount: amount,
            surcharge: surcharge,
            transactionId: transactionId,
            responseText: responseText,
            authcode: authcode,
            responseCode: responseCode,
            paymentAmountType: paymentAmountType ?? "full",
            date: date,
          );
          return "Payment Success";
        } else {
          throw Exception('Failed payment ${jsonData["message"]}');
        }
      } else {
        throw Exception('Failed to make payment');
      }
    } else {
      try {
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
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        "Content-Type": "application/json",
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
        'date': date,
        'address1': address1,
        'processor_id': processorId,
      };
      print(paymentDetails);
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({"paymentDetails": paymentDetails}),
      );
      if (response.statusCode == 200) {
        print(response.body);
        var jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 100) {
          final data = jsonData["data"];
          await storePaymentAch(
            adminId: adminId,
            tenantId: tenantId,
            leaseId: leaseid,
            entries: entries,
            totalAmount: amount,
            surcharge: surcharge,
            transactionId: data["transactionid"]?.toString() ?? "",
            responseText: data["responsetext"]?.toString() ?? "SUCCESS",
            authcode: data["authcode"]?.toString() ?? "",
            responseCode: data["response_code"]?.toString() ?? "100",
            paymentAmountType: "full",
            date: date,
          );
          return "Payment Success";
        } else {
          throw Exception('Failed payment ${jsonData["message"]}');
        }
      } else {
        throw Exception('Failed to make payment');
      }
    } else {
      try {
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

    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        "Content-Type": "application/json",
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
