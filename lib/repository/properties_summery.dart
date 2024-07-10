import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;
import 'package:three_zero_two_property/model/properties.dart';
import 'package:three_zero_two_property/model/properties_summery.dart';

import '../constant/constant.dart';
import '../model/unitsummery_propeties.dart';

// class Properies_summery_Repo{
//
//   Future<List<RentalSummary>> fetchPropertiessummery(String id) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     //String? id = prefs.getString("rentalid");
//     print(id);
//
//    // final response = await http.get(Uri.parse('${Api_url}/api/rentals/rental_summary/$id'));
//     final response = await http.get(Uri.parse('${Api_url}/api/api/tenant/rental_tenant/$id'));
//     print(response.body);
//     if (response.statusCode == 200) {
//       List jsonResponse = json.decode(response.body)['data'];
//       print(jsonResponse.first["lease_tenant_data"]);
//       return jsonResponse.map((data) => RentalSummary.fromJson(data)).toList();
//     }
//     return [];
//   }
//
//
//
//
// }
class Properies_summery_Repo{

  Future<List<TenantData>> fetchPropertiessummery(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? id = prefs.getString("rentalid");
    String?  id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    print(id);
    final response = await http.get(Uri.parse('${Api_url}/api/tenant/rental_tenant/$id'),

      headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => TenantData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> addUnit({
     String? adminId,
     String? unitId,
     String? rentalunit,
     String? rentalId,
     String? rentalunitadress,
     String? rentalsqft,
     String? rentalbath,
     String? rentalbed,
  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'unit_id': unitId,
      'rental_unit': rentalunit,
      'rental_id': rentalId,
      'rental_unit_adress': rentalunitadress,
      'rental_sqft': rentalsqft,
     'rental_bath': rentalbath,
    'rental_bed': rentalbed,
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final http.Response response = await http.post(
      Uri.parse('${Api_url}/api/unit/unit'),
      headers: <String, String>{
        "authorization" : "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    var responseData = json.decode(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add unit');
    }
  }

  Future<List<unit_properties>> fetchunit(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? id = prefs.getString("rentalid");
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    print(id);
    print("obj");
    final response = await http.get(Uri.parse('${Api_url}/api/unit/rental_unit/$id'),

      headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => unit_properties.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> addappliances({
    String? adminId,
    String? unitId,
    String? applianceid,
    String? appliancename,
    String? appliancedescription,
    String? installeddate,

  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'unit_id': unitId,
      'appliance_id': applianceid,
      'appliance_name': appliancename,
      'appliance_description': appliancedescription,
      'installed_date': installeddate,

    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final http.Response response = await http.post(
      Uri.parse('${Api_url}/api/appliance/appliance'),
      headers: <String, String>{
        "authorization" : "CRM $token",
        'Content-Type': 'application/json; charset=UTF-8',
        "id":"CRM $id",
      },
      body: jsonEncode(data),
    );
    print(response.body);
    var responseData = json.decode(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg:"add appliances successfully");
      return json.decode(response.body);
    } else {
      Fluttertoast.showToast(msg: "Failed to add appliances");
      throw Exception('Failed to add appliances');
    }
  }

  Future<Map<String, dynamic>> Editunit({
    String? adminId,
    String? id,
    String? unitId,
    String? rentalunit,
    String? rentalId,
    String? rentalunitadress,
    String? rentalsqft,
    String? rentalbath,
    String? rentalbed,
  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'unit_id': unitId,
      'rental_unit': rentalunit,
      'rental_id': rentalId,
      'rental_unit_adress': rentalunitadress,
      'rental_sqft': rentalsqft,
      'rental_bath': rentalbath,
      'rental_bed': rentalbed,
    };

   // print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final http.Response response = await http.put(
      Uri.parse('${Api_url}/api/unit/unit/$unitId'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        "authorization" : "CRM $token",
        "id":"CRM $id",
      },
      body: jsonEncode(data),
    );
    print(jsonEncode(data));
    print(unitId);

    var responseData = json.decode(response.body);
    print(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add property type');
    }
  }

  Future<Map<String, dynamic>> Deleteunit({
    required String? unitId
  }) async {
    // print('$apiUrl/$id');
    print('hello 123 ${unitId}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final http.Response response = await http.delete(
      Uri.parse('${Api_url}/api/unit/unit/$unitId'),
      headers: <String, String>{
        "authorization" : "CRM $token",
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
      throw Exception('Failed to add property type');
    }
  }

  // Future<Rentals> fetchrentalDetails(String rentalId) async {
  //
  //   final response = await http.get(Uri.parse('${Api_url}/api/rentals/rental_summary/$rentalId'));
  //
  //   print(response.body);
  //   print(rentalId);
  //   print('${Api_url}/api/rentals/rental_summary/$rentalId');
  //
  //   if (response.statusCode == 200) {
  //     final jsonResponse = json.decode(response.body);
  //     if (jsonResponse['data'] is List) {
  //       return Rentals.fromJson(jsonResponse['data'][0]);
  //     } else {
  //       return Rentals.fromJson(jsonResponse['data']);
  //     }
  //   } else {
  //     throw Exception('Failed to load rental');
  //   }
  // }

  Future<Rentals> fetchrentalDetails(String rentalId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http.get(
        Uri.parse('${Api_url}/api/rentals/rental_summary/$rentalId'),
        headers: {
          "authorization": "CRM $token",
          "id":"CRM $id",
          "Content-Type": "application/json"
        }
    );
    print(response.body);
    print(rentalId);
    print('${Api_url}/api/rentals/rental_summary/$rentalId');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      if (jsonResponse['data'] is List) {
        return Rentals.fromJson(jsonResponse['data'][0]);
      } else {
        return Rentals.fromJson(jsonResponse['data']);
      }
    } else {
      throw Exception('Failed to load rental');
    }
  }

}

// class RentalSummaryRepository {
// final String baseUrl = 'https://saas.cloudrentalmanager.com/api/rentals/rental_summary';
//
// Future<RentalSummary> fetchRentalSummary(String rentalId) async {
// final response = await http.get(Uri.parse('$baseUrl/$rentalId'));
//
// if (response.statusCode == 200) {
// return RentalSummary.fromJson(json.decode(response.body)['data'][0]);
// } else {
// throw Exception('Failed to load rental summary');
// }
// }
// }