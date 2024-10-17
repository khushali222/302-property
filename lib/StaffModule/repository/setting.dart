import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart'as http;


import '../../../constant/constant.dart';
import '../../model/setting.dart';

class SurchargeRepository {
  final String baseUrl;

  SurchargeRepository({required this.baseUrl});

  Future<Setting1> fetchSurchargeData(String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http.get(
        Uri.parse('$baseUrl/api/surcharge/surcharge/getadmin/$adminId'),
        headers: {
          "authorization": "CRM $token",
          "id":"CRM $id",
          "Content-Type": "application/json"
        }
    );
    final response_Data = jsonDecode(response.body);
    print(response_Data);
    if (response_Data["statusCode"] == 200) {
      // final apiResponse = ApiResponse.fromJson(jsonDecode(response.body));
      final apiResponse = Setting1.fromJson(jsonDecode(response.body)["data"][0]);
      return apiResponse;
    } else {
      throw Exception('Failed to load surcharge data');
    }
  }

  Future<List<Setting1>> fetchUpdat(Map<String,dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(jsonEncode(data));
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.put(
        Uri.parse('${Api_url}/api/surcharge/surcharge/$id'),
        headers: {"authorization" : "CRM $token","id":"CRM $id",},
        body:data );
    final response_Data = jsonDecode(response.body,);
    if (response_Data["statusCode"] == 200) {
      final apiResponse = ApiResponse.fromJson(jsonDecode(response.body)["data"]);
      return apiResponse.data;
    } else {
      throw Exception('Failed to update the data');
    }
  }

  Future<bool> updateSurchargeData(String surchargeId, Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http.put(
      Uri.parse('$baseUrl/api/surcharge/surcharge/$surchargeId'),
      headers: {
        "authorization" : "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    print(response.body);


    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> AddSurgeData(String surchargeId, Map<String, dynamic> data) async {
    print("$baseUrl/api/surcharge/surcharge");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http.post(
      Uri.parse('$baseUrl/api/surcharge/surcharge'),
      headers: {
        "authorization" : "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }
}
class latefeeRepository {
  final String baseUrl;

  latefeeRepository({required this.baseUrl});

  Future<Setting2> fetchLatefeesData(String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http.get(Uri.parse('$baseUrl/api/latefee/latefee/$adminId'),headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    final response_Data = jsonDecode(response.body);
    print(response_Data);
    if (response_Data["statusCode"] == 200) {
      print("callling latefee");
      print(jsonDecode(response.body)["data"]);
      // final apiResponse = ApiResponse.fromJson(jsonDecode(response.body));
      final apiResponse = Setting2.fromJson(jsonDecode(response.body)["data"]);
      return apiResponse;
    } else {
      throw Exception('Failed to load surcharge data');
    }
  }

  Future<bool> updateLatefeesData(String surchargeId, Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http.put(
      Uri.parse('$baseUrl/api/latefee/latefee/$surchargeId'),
      headers: {
        "authorization" : "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    print('$baseUrl/api/latefee/latefee/$surchargeId');
    print(response.body);


    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> AddLatefeesData(String surchargeId, Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    print("$Api_url/api/latefee/latefee");
    print(data);
    final response = await http.post(
      Uri.parse('$Api_url/api/latefee/latefee'),
      headers: {
        "authorization" : "CRM $token",
        'Content-Type': 'application/json',
        "id":"CRM $id",
      },
      body: jsonEncode(data),
    );
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

}

class mailserviceRepository {
  final String baseUrl;
  mailserviceRepository({required this.baseUrl});

  Future<Setting3> fetchMailData(String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http.get(Uri.parse('$baseUrl/api/mail_permission/$adminId'),headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    final response_Data = jsonDecode(response.body);
    print('mail data $response_Data');
    if (response_Data["statusCode"] == 200) {
      print("callling latefee");
      print(jsonDecode(response.body)["data"]);

      // final apiResponse = ApiResponse.fromJson(jsonDecode(response.body));
      final apiResponse = Setting3.fromJson(jsonDecode(response.body)["data"]);
      return apiResponse;
    } else {
      throw Exception('Failed to load mail data');
    }
  }

  Future<bool> updateMailData( Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http.put(
      Uri.parse('$Api_url/api/mail_permission/$id'),
      headers: {
        "authorization" : "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> AddMailData( id,Map<String, dynamic> data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    print("$Api_url/api/mail_permission");
    print(data);
    final response = await http.post(
      Uri.parse('$Api_url/api/mail_permission'),
      headers: {
        "authorization" : "CRM $token",
        'Content-Type': 'application/json',
        "id":"CRM $id",
      },
      body: jsonEncode(data),
    );
    print(response.body);
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

}

class accountRepository{


  Future<List<Setting4>> fetchAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    String? staffid = prefs.getString("staff_id");

    final response = await http.get(
      Uri.parse('${Api_url}/api/accounts/accounts/$id'),
      headers: {
        'authorization': 'CRM $token',
        'id': 'CRM $staffid',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => Setting4.fromJson(data)).toList();
    } else {
      print('Failed to fetch settings: ${response.body}');
      return [];
    }
  }

  Future<Map<String, dynamic>> addAccount({
    required String? adminId,
    required String? account,
    required String? accounttype,
    required String? fundtype,
    required String? chargetype,
    required String? notes,
  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'account': account,
      'account_type': accounttype,
      'fund_type': fundtype,
      'charge_type': chargetype,
      'notes': notes,
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    String? stffid = prefs.getString("staff_id");
    final http.Response response = await http.post(
      Uri.parse('${Api_url}/api/accounts/accounts'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id":"CRM $stffid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    var responseData = json.decode(response.body);

    print('account ${response.body}');
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add account');
    }
  }

  Future<Map<String, dynamic>> DeleteAccount({
    required String? account_id
  }) async {


    //print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  adminid = prefs.getString('adminId');
    String? id = prefs.getString("staff_id");


    final http.Response response = await http.delete(
      Uri.parse('${Api_url}/api/accounts/accounts/$account_id'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var responseData = json.decode(response.body);
    print(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to delete account');
    }
  }
}