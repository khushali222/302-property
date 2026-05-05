import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/lease.dart';

import '../../constant/constant.dart';

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
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    // List<Map<String, dynamic>> updatedEntries = entries.map((entry) {
    //   return {
    //     ...entry, // Keep existing data
    //     'charge_type': entry['newfield'] == true
    //         ? 'One Time Charge'
    //         : (entry['sub_charge_type'] ?? entry['charge_type']), // Apply condition
    //     // Remove the sub_charge_type by setting it to null
    //   };
    // }).toList();
    List<Map<String, dynamic>> updatedEntries = entries.map((entry) {
      // Determine charge_type based on newfield and account
      String? chargeType;

      if (entry['newfield'] == true) {
        // If newfield is true, check account values
        if (entry['account'] == "Late Fee Income" || entry['account'] == "Pre-payments" || entry['account'] == "Security Deposit") {
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
    print("updateddd entries ${updatedEntries}");
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
        'date': date,
        'address1': address1,
        'processor_id': processorId,
        'tenantName': tenantname,
        'notificationTime': notificationTime,
        'lease_id': leaseid,
        'entry': updatedEntries,
        // 'entry':entries,
        // NEW: added to match web payload — backend uses these to identify source
        'user_active_recently': true,
      };
      log(paymentDetails.toString());
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        // NEW: added is_web: true at body level to match web payload
        // OLD was: body: jsonEncode({"paymentDetails": paymentDetails})
        body: jsonEncode({
          "paymentDetails": paymentDetails,
          "is_web": true,
        }),
      );
      print('card for real ${response.body}');
      if (response.statusCode == 200) {
        print(response.body);
        var jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 100) {
          print(jsonData["data"]["responsetext"]);
          print(jsonData["data"]["transactionid"]);

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
          //       nmiResponse: jsonData)
          // ]);

          return "Payment Success";
        } else {
          throw Exception(' ${jsonData["message"]}');
        }
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to make payment');
      }
    } else {
      try {
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
            // entries: entries,
            totalAmount: amount,
            isLeaseAdded: false,
            uploadedFile: [],
            transactionId: "",
            responseText: "PENDING",
            surcharge: surcharge,
            notificationTime: notificationTime,
          )
        ]);
        return "Payment Scheduled Successfully";
      } catch (e) {
        throw Exception(e);
      }
    }
    return "";
  }

  Future<Map<String, dynamic>> storePayment(
      {required String companyName,
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
      var nmiResponse}) async {
    final String baseUrl = '$Api_url/api/payment/payment';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    print(entries);
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        "Content-Type": "application/json",
      },
      body: jsonEncode(<String, dynamic>{
        'company_name': companyName,
        'admin_id': id,
        'tenant_id': tenantId,
        'lease_id': leaseId,
        'payment_type': paymentType,
        'customer_vault_id': customerVaultId,
        'billing_id': billingId,
        'entry': entries,
        'total_amount': (double.parse(totalAmount) - double.parse(surcharge)),
        'surcharge': surcharge,
        'is_leaseAdded': isLeaseAdded,
        'uploaded_file': uploadedFile,
        'transaction_id': transactionId,
        'response': responseText,
        'notificationTime': notificationTime,
        // NMI response fields — only available for immediate (non-PENDING) payments
        // Commented out to prevent null crash on future-dated (PENDING) payments where nmiResponse is null
        // Restore if backend needs these fields for settled card payments:
        // "authcode": nmiResponse["data"]["authcode"],
        // "avsresponse": nmiResponse["data"]["avsresponse"],
        // "cvvresponse": nmiResponse["data"]["cvvresponse"],
        // "responseCode": nmiResponse["data"]["response_code"],
        // "state": "settling"
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to payment ${jsonDecode(response.body)["message"]}');
    }
  }

  Future<String> makePaymentforach({
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
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    // List<Map<String, dynamic>> updatedEntries = entries.map((entry) {
    //   return {
    //     ...entry, // Keep existing data
    //     'charge_type': entry['newfield'] == true
    //         ? 'One Time Charge'
    //         : (entry['sub_charge_type'] ?? entry['charge_type']), // Apply condition
    //     // Remove the sub_charge_type by setting it to null
    //   };
    // }).toList();
    List<Map<String, dynamic>> updatedEntries = entries.map((entry) {
      // Determine charge_type based on newfield and account
      String? chargeType;

      if (entry['newfield'] == true) {
        // If newfield is true, check account values
        if (entry['account'] == "Late Fee Income" || entry['account'] == "Pre-payments" || entry['account'] == "Security Deposit") {
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
        'checkname': checkname,
        'account_type': account_type,
        'checkaccount': checkaccount,
        'checkaba': checkaba,
        'account_holder_type': account_holder_type,
        'surcharge': surcharge,
        'amount': amount,
        'tenantId': tenantId,
        'date': date,
        'address1': address1,
        'processor_id': processorId,
        'tenantName': tenantname,
        'notificationTime': notificationTime,
        'lease_id': leaseid,
        'entry': updatedEntries,
        // 'entry': entries,
        // NEW: added to match web payload — backend uses these to identify source
        'user_active_recently': true,
      };
      print(paymentDetails);
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        // NEW: added is_web: true at body level to match web payload
        // OLD was: body: jsonEncode({"paymentDetails": paymentDetails})
        body: jsonEncode({
          "paymentDetails": paymentDetails,
          "is_web": true,
        }),
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
          //       notificationTime: notificationTime)
          // ]);

          return "Payment Success";
        } else {
          throw Exception('Failed payment ${jsonData["message"]}');
        }
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to make payment');
      }
    } else {
      try {
        await Future.wait([
          storePaymentAch(
              companyName: company_name,
              adminId: adminId,
              tenantId: tenantId,
              leaseId: leaseid,
              // OLD was: paymentType: "Card" — wrong type for ACH scheduled payment
              paymentType: "ACH",
              entries: updatedEntries,
              // entries: entries,
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
    String? id = prefs.getString('adminId');
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
        'admin_id': id,
        'tenant_id': tenantId,
        'lease_id': leaseId,
        'payment_type': paymentType,

        'entry': entries,
        // 'total_amount': totalAmount,
        'total_amount': (double.parse(totalAmount) - double.parse(surcharge)),
        'surcharge': surcharge,
        'is_leaseAdded': isLeaseAdded,
        'uploaded_file': uploadedFile,
        'transaction_id': transactionId,
        'response': responseText,
        'notificationTime': notificationTime,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to payment ${jsonDecode(response.body)["message"]}');
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
    required List<String>? uploadedFile,
    required List<Map<String, dynamic>> entries,
    String? notificationTime,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    // List<Map<String, dynamic>> updatedEntries = entries.map((entry) {
    //   return {
    //     ...entry, // Keep existing data
    //     'charge_type': entry['newfield'] == true
    //         ? 'One Time Charge'
    //         : (entry['sub_charge_type'] ?? entry['charge_type']), // Apply condition
    //     // Remove the sub_charge_type by setting it to null
    //   };
    // }).toList();
    List<Map<String, dynamic>> updatedEntries = entries.map((entry) {
      // Determine charge_type based on newfield and account
      String? chargeType;

      if (entry['newfield'] == true) {
        // If newfield is true, check account values
        if (entry['account'] == "Late Fee Income" || entry['account'] == "Pre-payments" || entry['account'] == "Security Deposit") {
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
        'date': date,
        'address1': address1,
        'processor_id': processorId,
        'lease_id': leaseid,
        'entry': updatedEntries,
        //'entry': entries,
        // 'notificationTime':notificationTime,
      };
      print(paymentDetails);

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "paymentDetails": paymentDetails,
        }),
      );
      if (response.statusCode == 200) {
        print(response.body);
        var jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 100) {
          print(jsonData["data"]["responsetext"]);
          print(jsonData["data"]["transactionid"]);
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
              notificationTime: notificationTime)
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
    String? id = prefs.getString('adminId');
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
        'admin_id': id,
        'tenant_id': tenantId,
        'lease_id': leaseId,
        'payment_type': paymentType,
        'entry': entries,
        'total_amount': totalAmount,
        'is_leaseAdded': isLeaseAdded,
        'uploaded_file': uploadedFile,
        'check_number': checknumber,
        'response': "SUCCESS",
        'notificationTime': notificationTime,
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to payment ${jsonDecode(response.body)["message"]}');
    }
  }

  // Future<String> makePaymentforCashier({
  //   required String adminId,
  //   required String firstName,
  //   required String lastName,
  //   required String emailName,
  //   //  required String customerVaultId,
  //   //required String billingId,
  //   required String surcharge,
  //   required String amount,
  //   required String tenantId,
  //   required String date,
  //   required String address1,
  //   required String processorId,
  //   required String leaseid,
  //   required String company_name,
  //   /* required String account_type,
  //   required String account_holder_type,
  //   required String checkaccount,
  //   required String checkaba,
  //   required String checkname,*/
  //   required bool future_Date,
  //   required String Check_number,
  //   required bool Check,
  //   required String uploadedFile,
  //   required List<Map<String, dynamic>> entries,
  // }) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? id = prefs.getString('adminId');
  //   String? token = prefs.getString('token');
  //
  //   print("surcharge: $surcharge");
  //
  //   // Using '/payment/payment' API for Cashier payments
  //   final String baseUrl = '$Api_url/api/payment/payment';
  //   print(baseUrl);
  //
  //   Map<String, dynamic> paymentDetails = {
  //     'admin_id': adminId,
  //     'first_name': firstName,
  //     'last_name': lastName,
  //     'email_name': emailName,
  //     'surcharge': surcharge,
  //     'amount': amount,
  //     'tenantId': tenantId,
  //     'date': date,
  //     'address1': address1,
  //     'processor_id': processorId,
  //     'leaseId': leaseid,
  //   };
  //
  //   print("Payment Details: $paymentDetails");
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(baseUrl),
  //       headers: {
  //         "authorization": "CRM $token",
  //         "id": "CRM $id",
  //         "Content-Type": "application/json",
  //       },
  //       body: jsonEncode({
  //         "paymentDetails": paymentDetails,
  //         "uploadedFile": uploadedFile,
  //         "entries": entries,
  //         "payment_type": "Cashier", // Specify the payment type
  //         "future_date": future_Date,
  //         "check_number": Check_number,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       var jsonData = jsonDecode(response.body);
  //       if (jsonData["statusCode"] == 100) {
  //         print("Response Text: ${jsonData["data"]["responsetext"]}");
  //         print("Transaction ID: ${jsonData["data"]["transactionid"]}");
  //
  //         // Store payment after successful response
  //         storePaymentfornormal(
  //           companyName: company_name,
  //           adminId: adminId,
  //           tenantId: tenantId,
  //           leaseId: leaseid,
  //           paymentType: "Cashier",
  //           entries: entries,
  //           totalAmount: amount,
  //           isLeaseAdded: false,
  //           uploadedFile: uploadedFile,
  //           transactionId: jsonData["data"]["transactionid"],
  //           responseText: jsonData["data"]["responsetext"],
  //           surcharge: surcharge, checknumber: '',
  //         );
  //         return "Payment Successful";
  //       } else {
  //         throw Exception('Payment failed: ${jsonData["message"]}');
  //       }
  //     } else {
  //       throw Exception('Failed to make payment');
  //     }
  //   } catch (e) {
  //     throw Exception('Error: $e');
  //   }
  // }
}
