import 'dart:convert';
import 'package:http/http.dart' as http;
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
    required List<Map<String,dynamic>> entries,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
  //  String? id = prefs.getString('adminId');
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');

    print("surcharge ${surcharge}");
    if(future_Date == false){
      final String baseUrl = '$Api_url/api/nmipayment/sale';
      print(baseUrl);
      Map<String,dynamic> paymentDetails = {
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
        if(jsonData["statusCode"] == 100){
          print(jsonData["data"]["responsetext"]);
          print(jsonData["data"]["transactionid"]);
          storePayment(companyName: company_name, adminId: adminId, tenantId: tenantId, leaseId: leaseid, paymentType: "Card", customerVaultId: customerVaultId, billingId: billingId, entries: entries, totalAmount: amount, isLeaseAdded:false, uploadedFile: "", transactionId: jsonData["data"]["transactionid"], responseText: jsonData["data"]["responsetext"],surcharge: surcharge);
          return "Payment Success";
        }
        else{
          throw Exception('Failed payment ${jsonData["message"]}');
        }
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to make payment');
      }
    }
    else{
      try{
        storePayment(companyName: company_name, adminId: adminId, tenantId: tenantId, leaseId: leaseid, paymentType: "Card", customerVaultId: customerVaultId, billingId: billingId, entries: entries, totalAmount: amount, isLeaseAdded:false, uploadedFile: "", transactionId: "", responseText: "PENDING",surcharge: surcharge);
        return "Payment Scheduled Successfully";
      }
      catch(e){
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
   required List<Map<String,dynamic>> entries,
    required String totalAmount,
    required bool isLeaseAdded,
    required String uploadedFile,
    required String transactionId,
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
        'customer_vault_id': customerVaultId,
        'billing_id': billingId,
        'entry': entries,
        'total_amount': totalAmount,
        'is_leaseAdded': isLeaseAdded,
        'uploaded_file': uploadedFile,
        'transaction_id': transactionId,
        'response': responseText,
      }),
    );
    print(response);
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
    required List<Map<String,dynamic>> entries,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');

    print("surcharge ${surcharge}");
    if(future_Date == false){
      final String baseUrl = '$Api_url/api/nmipayment/ACH_sale';
      print(baseUrl);
      Map<String,dynamic> paymentDetails = {
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
        if(jsonData["statusCode"] == 100){
          print(jsonData["data"]["responsetext"]);
          print(jsonData["data"]["transactionid"]);
          storePaymentAch(companyName: company_name, adminId: adminId, tenantId: tenantId, leaseId: leaseid, paymentType: "ACH", entries: entries, totalAmount: amount, isLeaseAdded:false, uploadedFile: "", transactionId: jsonData["data"]["transactionid"], responseText: jsonData["data"]["responsetext"],surcharge: surcharge);
          return "Payment Success";

        }
        else{
          throw Exception('Failed payment ${jsonData["message"]}');
        }
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to make payment');
      }
    }
    else{
      try{
        storePaymentAch(companyName: company_name, adminId: adminId, tenantId: tenantId, leaseId: leaseid, paymentType: "Card",  entries: entries, totalAmount: amount, isLeaseAdded:false, uploadedFile: "", transactionId: "", responseText: "PENDING",surcharge: surcharge);
        return "Payment Scheduled Successfully";
      }
      catch(e){
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

    required List<Map<String,dynamic>> entries,
    required String totalAmount,
    required bool isLeaseAdded,
    required String uploadedFile,
    required String transactionId,
    required String responseText,
    required String surcharge,
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
        'transaction_id': transactionId,
        'response': responseText,
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
    required List<Map<String,dynamic>> entries,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    print("surcharge ${surcharge}");
    if(future_Date == false){
      final String baseUrl = '$Api_url/api/nmipayment/ACH_sale';
      print(baseUrl);
      Map<String,dynamic> paymentDetails = {
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
        if(jsonData["statusCode"] == 100){
          print(jsonData["data"]["responsetext"]);
          print(jsonData["data"]["transactionid"]);
          storePaymentAch(companyName: company_name, adminId: adminId, tenantId: tenantId, leaseId: leaseid, paymentType: "ACH", entries: entries, totalAmount: amount, isLeaseAdded:false, uploadedFile: "", transactionId: jsonData["data"]["transactionid"], responseText: jsonData["data"]["responsetext"],surcharge: surcharge);
          return "Payment Success";
        }
        else{
          throw Exception('Failed payment ${jsonData["message"]}');
        }
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to make payment');
      }
    }
    else{
      try{
        storePaymentfornormal(companyName: company_name, adminId: adminId, tenantId: tenantId, leaseId: leaseid, paymentType: Check ? "Check" : "Cash",  entries: entries, totalAmount: amount, isLeaseAdded:false, uploadedFile: "", checknumber: Check_number, responseText: "PENDING",surcharge: surcharge);
        return "Payment Successfully";
      }
      catch(e){
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

    required List<Map<String,dynamic>> entries,
    required String totalAmount,
    required bool isLeaseAdded,
    required String uploadedFile,
    required String checknumber,
    required String responseText,
    required String surcharge,
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
      }),
    );

    if (response.statusCode == 200) {
      print(response.body);
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to payment ${jsonDecode(response.body)["message"]}');
    }
  }







}


