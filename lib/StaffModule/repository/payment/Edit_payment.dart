import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:three_zero_two_property/model/lease.dart';

import '../../../constant/constant.dart';

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
    String? id = prefs.getString('staff_id');
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
        'date': date,
        'address1': address1,
        'processor_id': processorId,
        'tenantName': tenantname,
        'notificationTime': notificationTime,
        'lease_id': leaseid,
        'entry': updatedEntries,
        // 'entry':entries,
      };
      log(paymentDetails.toString());
      final response = await apiPost(
        Uri.parse(baseUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json",
          "X-Idempotency-Key": Uuid().v4(),
          "X-Client-Source": _clientSource,
        },
        body: jsonEncode({
          "paymentDetails": paymentDetails,
        }),
      );
      print('card for real ${response.body}');
      if (response.statusCode == 200) {
        print(response.body);
        var jsonData = jsonDecode(response.body);
        if (jsonData["statusCode"] == 100) {
          print(jsonData["data"]["responsetext"]);
          print(jsonData["data"]["transactionid"]);
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
              //  entries: entries,
              totalAmount: amount,
              isLeaseAdded: false,
              uploadedFile: [],
              transactionId: jsonData["data"]["transactionid"],
              // responseText: jsonData["data"]["responsetext"],
              responseText: "SUCCESS",
              surcharge: surcharge,
              notificationTime: notificationTime,
            )
          ]);
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
    String? staffId = prefs.getString('staff_id');
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    print(entries);
    final Map<String, dynamic> requestBody = {
      'company_name': companyName,
      'admin_id': id,
      'tenant_id': tenantId,
      'lease_id': leaseId,
      'payment_type': paymentType,
      'customer_vault_id': customerVaultId,
      'billing_id': billingId,
      'entry': entries,
      'total_amount': double.tryParse(totalAmount) ?? 0.0,
      'surcharge': surcharge,
      'is_leaseAdded': isLeaseAdded,
      'uploaded_file': uploadedFile,
      'transaction_id': transactionId,
      'response': responseText,
      'notificationTime': notificationTime,
      'is_web': true,
      'user_active_recently': true,
    };
    final response = await apiPost(
      Uri.parse(baseUrl),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffId",
        "Content-Type": "application/json",
          "X-Idempotency-Key": Uuid().v4(),
          "X-Client-Source": _clientSource,
      },
      body: jsonEncode(requestBody),
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
    String? id = prefs.getString('staff_id');
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
          await Future.wait([
            storePaymentAch(
                companyName: company_name,
                adminId: adminId,
                tenantId: tenantId,
                leaseId: leaseid,
                paymentType: "ACH",
                entries: updatedEntries,
                //  entries: entries,
                totalAmount: amount,
                isLeaseAdded: false,
                uploadedFile: [],
                transactionId: jsonData["data"]["transactionid"],
                //    responseText: jsonData["data"]["responsetext"],
                responseText: "SUCCESS",
                surcharge: surcharge,
                notificationTime: notificationTime)
          ]);
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
    String? staffId = prefs.getString('staff_id');
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');

    final Map<String, dynamic> requestBody = {
      'company_name': companyName,
      'admin_id': id,
      'tenant_id': tenantId,
      'lease_id': leaseId,
      'payment_type': paymentType,
      'entry': entries,
      'total_amount': double.tryParse(totalAmount) ?? 0.0,
      'surcharge': surcharge,
      'is_leaseAdded': isLeaseAdded,
      'uploaded_file': uploadedFile,
      'transaction_id': transactionId,
      'response': responseText,
      'notificationTime': notificationTime,
      'is_web': true,
      'user_active_recently': true,
    };
    final response = await apiPost(
      Uri.parse(baseUrl),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffId",
        "Content-Type": "application/json",
          "X-Idempotency-Key": Uuid().v4(),
          "X-Client-Source": _clientSource,
      },
      body: jsonEncode(requestBody),
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
    required String paymentId,
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
    String? id = prefs.getString('staff_id');
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
    print(updatedEntries);
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
        'date': date,
        'address1': address1,
        'processor_id': processorId,
        'lease_id': leaseid,
        'entry': updatedEntries,
        //'entry': entries,
        // 'notificationTime':notificationTime,
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
              isLeaseAdded: true,
              uploadedFile: "",
              checknumber: Check_number,
              responseText: "PENDING",
              surcharge: surcharge,
              notificationTime: notificationTime,
              paymentId: paymentId)
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
    String? paymentId,
  }) async {
    final String baseUrl = '$Api_url/api/payment/payment/$paymentId';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');

    final Map<String, dynamic> requestBody = {
      'company_name': companyName,
      'admin_id': id,
      'tenant_id': tenantId,
      'lease_id': leaseId,
      'payment_id': paymentId,
      'payment_type': paymentType,
      'entry': entries,
      'total_amount': totalAmount,
      'surcharge': surcharge,
      'uploaded_file': uploadedFile,
      'check_number': checknumber,
      'notificationTime': notificationTime,
      'is_web': true,
      'user_active_recently': true,
    };
    final response = await apiPut(
      Uri.parse(baseUrl),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        "Content-Type": "application/json",
          "X-Idempotency-Key": Uuid().v4(),
          "X-Client-Source": _clientSource,
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to payment ${jsonDecode(response.body)["message"]}');
    }
  }

  Future<Map<String, dynamic>> storePaymentForEdit({
    required String companyName,
    required String adminId,
    required String tenantId,
    required String tenantName,
    required String leaseId,
    required String paymentId,
    required String customerVaultId,
    required String billingId,
    required List<Map<String, dynamic>> entries,
    required double totalAmount,
    required List<String>? uploadedFile,
    String? checkNumber,
  }) async {
    final String baseUrl = '$Api_url/api/payment/payment/$paymentId';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');

    final Map<String, dynamic> requestBody = {
      'payment_id': paymentId,
      'company_name': companyName,
      'admin_id': adminId,
      'tenant_id': tenantId,
      'tenantName': tenantName,
      'lease_id': leaseId,
      'customer_vault_id': customerVaultId,
      'billing_id': billingId,
      'check_number': checkNumber ?? "",
      'entry': entries,
      'total_amount': totalAmount,
      'uploaded_file': uploadedFile ?? [],
      'is_web': true,
      'user_active_recently': true,
    };
    final response = await apiPut(
      Uri.parse(baseUrl),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        "Content-Type": "application/json",
        "X-Idempotency-Key": Uuid().v4(),
        "X-Client-Source": _clientSource,
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to update payment ${jsonDecode(response.body)["message"]}');
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
//     final response = await apiPost(
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
