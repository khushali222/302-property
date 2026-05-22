import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
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
    required List<String>? uploadedFile,
    required List<Map<String, dynamic>> entries,
    String? tenantname,
    String? notificationTime,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    List<Map<String, dynamic>> updatedEntries = entries.map((entry) {
      // Determine charge_type based on newfield and account
      String? chargeType;

      if (entry['newfield'] == true) {
        // If newfield is true, check account values
        if (entry['account'] == "Late Fee Income" ||
            entry['account'] == "Pre-payments" ||
            entry['account'] == "Security Deposit") {
          chargeType = entry['account']; // Assign account value as charge_type
        } else if (entry['account'] == "Rent Income") {
          chargeType = "Rent"; // Set charge_type as "Rent"
        } else {
          chargeType = "One Time Charge"; // Default to "One Time Charge"
        }
      } else {
        // If newfield is false, keep the existing charge_type logic
        chargeType = entry['sub_charge_type'] ?? entry['charge_type'];
      }

      return {
        ...entry, // Keep existing data
        'charge_type': chargeType, // Set the dynamically calculated charge_type
      };
    }).toList();

    print("surcharge ${surcharge}");
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
        'tenantName':tenantname,
        'notificationTime':notificationTime,
        'entry': updatedEntries.map((e) => {
          'entry_id': e['entry_id'],
          'account': e['account'],
          'amount': e['amount'],
          'balance': e['balance'],
          'memo': e['memo'],
          'date': e['date'],
        }).toList(),
        // OLD was: lease_id missing from staff card payload — backend couldn't identify which lease
        'lease_id': leaseid,
        // NEW: added to match web payload — backend uses these to identify source
        'user_active_recently': true,
      };
    //  log(paymentDetails.toString());

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
          "X-Idempotency-Key": Uuid().v4(),
          "X-Client-Source": _clientSource,
        },
        // NEW: added is_web: true at body level to match web payload
        // OLD was: body: jsonEncode({"paymentDetails": paymentDetails})
        body: jsonEncode({"paymentDetails": paymentDetails, "is_web": true}),
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 100) {
          print("========== CARD PAYMENT SUCCESS ==========");
          print("Transaction ID : ${jsonData["data"]["transactionid"]}");
          print("Response       : ${jsonData["data"]["responsetext"]}");
          print("Amount         : $amount  |  Surcharge: $surcharge");
          print("---------- ENTRIES ----------");
          for (var e in updatedEntries) {
            print("  account: ${e['account']} | charge_type: ${e['charge_type']} | amount: ${e['amount']} | balance: ${e['balance']}");
          }
          print("==========================================");

          // NEW: backend now saves the payment record to DB internally after /api/nmipayment/sale
          // storePayment() removed to prevent duplicate transaction entries (same change as tenant module)
          // OLD storePayment call kept below as reference — restore if backend reverts:
          // await Future.wait([
          //   storePayment(
          //       companyName: company_name,
          //       adminId: adminId,
          //       tenantId: tenantId,
          //       leaseId: leaseid,
          //       paymentType: "Card",
          //       customerVaultId: customerVaultId,
          //       billingId: billingId,
          //       entries: updatedEntries,
          //       totalAmount: amount,
          //       isLeaseAdded: false,
          //       uploadedFile: [],
          //       transactionId: jsonData["data"]["transactionid"],
          //       responseText: "SUCCESS",
          //       surcharge: surcharge,
          //       notificationTime: notificationTime,
          //   )
          // ]);

          return "Payment Success";
        } else {
          throw Exception('Failed payment ${jsonData["message"]}');
        }
        return jsonDecode(response.body);
      } else {
        print(response.statusCode);
        print(response.body);
        throw Exception('Failed to make payment');
      }
    } else {
      try {
        // OLD was: storePayment(...) without await — fire and forget, errors silently swallowed
        await Future.wait([
          storePayment(
              companyName: company_name,
              adminId: adminId,
              tenantId: tenantId,
              leaseId: leaseid,
              paymentType: "Card",
              customerVaultId: customerVaultId,
              billingId: billingId,
              entries: updatedEntries,
              //entries: entries,
              totalAmount: amount,
              isLeaseAdded: false,
              uploadedFile: [],
              transactionId: "",
              responseText: "PENDING",
              surcharge: surcharge,
              notificationTime: notificationTime)
        ]);
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
    required List<Map<String, dynamic>> entries,
    required String totalAmount,
    required bool isLeaseAdded,
    required List<String>? uploadedFile,
    required String transactionId,
    required String responseText,
    required String surcharge,
    String? notificationTime,
  }) async {
    final String baseUrl = '$Api_url/api/payment/payment';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final response = await http.post(
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
        'admin_id': adminid,
        'tenant_id': tenantId,
        'lease_id': leaseId,
        'payment_type': paymentType,
        'customer_vault_id': customerVaultId,
        'billing_id': billingId,
        'entry': entries,
        'total_amount': double.parse(totalAmount),
        'surcharge': surcharge,
        'is_leaseAdded': isLeaseAdded,
        'uploaded_file': uploadedFile,
        'transaction_id': transactionId,
        'response': responseText,
        'notificationTime': notificationTime,
        'is_web': true,
        'user_active_recently': true,
      }),
    );

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
    required List<String>? uploadedFile,
    required List<Map<String, dynamic>> entries,
    String? tenantname,
    String? notificationTime,
    String? billingId,
    String? customerVaultId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    List<Map<String, dynamic>> updatedEntries = entries.map((entry) {
      // Determine charge_type based on newfield and account
      String? chargeType;

      if (entry['newfield'] == true) {
        // If newfield is true, check account values
        if (entry['account'] == "Late Fee Income" ||
            entry['account'] == "Pre-payments" ||
            entry['account'] == "Security Deposit") {
          chargeType = entry['account']; // Assign account value as charge_type
        } else if (entry['account'] == "Rent Income") {
          chargeType = "Rent"; // Set charge_type as "Rent"
        } else {
          chargeType = "One Time Charge"; // Default to "One Time Charge"
        }
      } else {
        // If newfield is false, keep the existing charge_type logic
        chargeType = entry['sub_charge_type'] ?? entry['charge_type'];
      }

      return {
        ...entry, // Keep existing data
        'charge_type': chargeType, // Set the dynamically calculated charge_type
      };
    }).toList();

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
        'entry': updatedEntries.map((e) => {
          'entry_id': e['entry_id'],
          'account': e['account'],
          'amount': e['amount'],
          'balance': e['balance'],
          'memo': e['memo'],
          'date': e['date'],
        }).toList(),
        'address1': address1,
        'processor_id': processorId,
        'tenantName': tenantname,
        'notificationTime': notificationTime,
        'lease_id': leaseid,
        'user_active_recently': true,
      };
      if (billingId != null &&
          billingId.isNotEmpty &&
          customerVaultId != null &&
          customerVaultId.isNotEmpty) {
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
          "X-Idempotency-Key": Uuid().v4(),
          "X-Client-Source": _clientSource,
        },
        // NEW: added is_web: true at body level to match web payload
        // OLD was: body: jsonEncode({"paymentDetails": paymentDetails})
        body: jsonEncode({"paymentDetails": paymentDetails, "is_web": true}),
      );

      if (response.statusCode == 200) {
        print(response.body);
        var jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 100) {
          print(jsonData["data"]["responsetext"]);
          print(jsonData["data"]["transactionid"]);

          // NEW: backend now saves the payment record to DB internally after /api/nmipayment/ACH_sale
          // storePaymentAch() removed to prevent duplicate entries (same change as tenant module)
          // OLD storePaymentAch call kept below as reference — restore if backend reverts:
          // await Future.wait([
          //   storePaymentAch(
          //       companyName: company_name,
          //       adminId: adminId,
          //       tenantId: tenantId,
          //       leaseId: leaseid,
          //       paymentType: "ACH",
          //       entries: updatedEntries,
          //       totalAmount: amount,
          //       isLeaseAdded: false,
          //       uploadedFile: [],
          //       transactionId: jsonData["data"]["transactionid"],
          //       responseText: "SUCCESS",
          //       surcharge: surcharge,
          //       notificationTime: notificationTime,
          //   )
          // ]);

          return "Payment Success";
        } else {
          throw Exception('Failed payment ${jsonData["message"]}');
        }
        return jsonDecode(response.body);
      } else {
        print(response.statusCode);
        print(response.body);
        throw Exception('Failed to make payment');
      }
    } else {
      try {
        // OLD was: storePaymentAch(...) without await — fire and forget, errors silently swallowed
        // OLD was: paymentType: "Card" — wrong type for ACH scheduled payment
        await Future.wait([
          storePaymentAch(
              companyName: company_name,
              adminId: adminId,
              tenantId: tenantId,
              leaseId: leaseid,
              paymentType: "ACH",
              entries: updatedEntries,
              //entries: entries,
              totalAmount: amount,
              isLeaseAdded: false,
              uploadedFile: [],
              transactionId: "",
              responseText: "PENDING",
              surcharge: surcharge,
              notificationTime: notificationTime)
        ]);
        return "Payment Scheduled Successfully";
      } catch (e) {
        throw Exception(e);
      }
    }
    return "";
  }

  Future<Map<String, dynamic>> storePaymentAch({
    required String companyName,
    required String adminId,
    required String tenantId,
    required String leaseId,
    required String paymentType,
    required List<Map<String, dynamic>> entries,
    required String totalAmount,
    required bool isLeaseAdded,
    required List<String>? uploadedFile,
    required String transactionId,
    required String responseText,
    required String surcharge,
    String? notificationTime,
  }) async {
    final String baseUrl = '$Api_url/api/payment/payment';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final response = await http.post(
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
        'admin_id': adminid,
        'tenant_id': tenantId,
        'lease_id': leaseId,
        'payment_type': paymentType,

        'entry': entries,
        'total_amount': double.parse(totalAmount),
        'surcharge': surcharge,
        'is_leaseAdded': isLeaseAdded,
        'uploaded_file': uploadedFile,
        'transaction_id': transactionId,
        'response': responseText,
        'notificationTime': notificationTime,
        'is_web': true,
        'user_active_recently': true,
      }),
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
    required String payment_method,
    required bool future_Date,
    required String Check_number,
    required bool Check,
    required List<String>? uploadedFile,
    required List<Map<String, dynamic>> entries,
    String? notificationTime,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    List<Map<String, dynamic>> updatedEntries = entries.map((entry) {
      // Determine charge_type based on newfield and account
      String? chargeType;

      if (entry['newfield'] == true) {
        // If newfield is true, check account values
        if (entry['account'] == "Late Fee Income" ||
            entry['account'] == "Pre-payments" ||
            entry['account'] == "Security Deposit") {
          chargeType = entry['account']; // Assign account value as charge_type
        } else if (entry['account'] == "Rent Income") {
          chargeType = "Rent"; // Set charge_type as "Rent"
        } else {
          chargeType = "One Time Charge"; // Default to "One Time Charge"
        }
      } else {
        // If newfield is false, keep the existing charge_type logic
        chargeType = entry['sub_charge_type'] ?? entry['charge_type'];
      }

      return {
        ...entry, // Keep existing data
        'charge_type': chargeType, // Set the dynamically calculated charge_type
      };
    }).toList();
    print("surcharge ${surcharge}");
    if (future_Date == false) {
      final String baseUrl = '$Api_url/api/nmipayment/ACH_sale';
      print(baseUrl);
      Map<String, dynamic> paymentDetails = {
        'admin_id': adminId,
        'first_name': firstName,
        'last_name': lastName,
        'email_name': emailName,
        /*'checkname': checkname,
        'account_type': account_type,
        'checkaccount': checkaccount,
        'checkaba': checkaba,
        'account_holder_type': account_holder_type,*/
        'surcharge': surcharge,
        'amount': amount,
        'tenantId': tenantId,
        'tenant_id': tenantId,
        'entry': updatedEntries.map((e) => {
          'entry_id': e['entry_id'],
          'account': e['account'],
          'amount': e['amount'],
          'balance': e['balance'],
          'memo': e['memo'],
          'date': e['date'],
        }).toList(),
        'date': date,
        'address1': address1,
        'processor_id': processorId,
        'lease_id': leaseid,
        'user_active_recently': true,
      };
      print(paymentDetails);
      final response = await http.post(
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
      if (response.statusCode == 200) {
        print(response.body);
        var jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 100) {
          print(jsonData["data"]["responsetext"]);
          print(jsonData["data"]["transactionid"]);
          await storePaymentAch(
              companyName: company_name,
              adminId: adminId,
              tenantId: tenantId,
              leaseId: leaseid,
              paymentType: "ACH",
              entries: updatedEntries,
              // entries: entries,
              totalAmount: amount,
              isLeaseAdded: false,
              uploadedFile: [],
              transactionId: jsonData["data"]["transactionid"],
              responseText: jsonData["data"]["responsetext"],
              surcharge: surcharge,
              notificationTime: notificationTime,
          );
          return "Payment Success";
        } else {
          throw Exception('Failed payment ${jsonData["message"]}');
        }
        return jsonDecode(response.body);
      } else {
        print(response.statusCode);
        print(response.body);
        throw Exception('Failed to make payment');
      }
    } else {
      try {
        await Future.wait([
          storePaymentfornormal(
              companyName: company_name,
              adminId: adminId,
              tenantId: tenantId,
              leaseId: leaseid,
              paymentType: payment_method,
              entries: updatedEntries,
              //entries: entries,
              totalAmount: amount,
              isLeaseAdded: false,
              uploadedFile: "",
              checknumber: Check_number,
              responseText: "PENDING",
              surcharge: surcharge,
              notificationTime: notificationTime
          )
        ]);
        return "Payment Successfully";
      } catch (e) {
        throw Exception(e);
      }
    }
    return "";
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
    String? notificationTime,
  }) async {
    final String baseUrl = '$Api_url/api/payment/payment';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final response = await http.post(
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
        // Cash / Check / Money Order / Cashier's Check / Manual are recorded
        // immediately by the staff, so the ledger needs response = "SUCCESS"
        // (caller still passes "PENDING" but we ignore it here, matching the
        // original behavior before the recent refactor). Do NOT change without
        // also fixing the ledger filter.
        'response': "SUCCESS",
        'notificationTime': notificationTime,
        'is_web': true,
        'user_active_recently': true,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to payment ${jsonDecode(response.body)["message"]}');
    }
  }
}
