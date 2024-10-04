import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;
import 'package:three_zero_two_property/model/properties.dart';
import 'package:three_zero_two_property/model/properties_summery.dart';

import '../constant/constant.dart';
import '../model/properties_workorders.dart';
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

  Future<List<TenantData>> fetchPropertiessummery(String rentalId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? id = prefs.getString("rentalid");
    String?  id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    print(id);
    final response = await http.get(Uri.parse('${Api_url}/api/tenant/rental_tenant/$rentalId'),
      headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    if (response.statusCode == 200) {

      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => TenantData.fromJson(data)).toList();
    } else {
      print('Failed to fetch property type: ${response.body}');
      return [];
      //throw Exception('Failed to load data');
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
    List<String?>? rentalImages,
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
      'rental_images':rentalImages
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

  Future<List<unit_properties>> fetchunit(String rentalId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? id = prefs.getString("rentalid");
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    print(id);
    print("obj");
    final response = await http.get(Uri.parse('${Api_url}/api/unit/rental_unit/$rentalId'),
      headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    // print(jsonEncode('data'));
    print('unit responce ${response.body}');
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
  Future<Map<String, dynamic>> Editappliances({
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
    final http.Response response = await http.put(
      Uri.parse('${Api_url}/api/appliance/appliance/$applianceid'),
      headers: <String, String>{
        "authorization" : "CRM $token",
        'Content-Type': 'application/json; charset=UTF-8',
        "id":"CRM $id",
      },
      body: jsonEncode(data),

    );
    print(applianceid);
    print('hii api${response.body}');
    var responseData = json.decode(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg:"edit appliances successfully");
      return json.decode(response.body);
    } else {
      Fluttertoast.showToast(msg: "Failed to edit appliances");
      throw Exception('Failed to edit appliances');
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
    List<String?>? rentalImages,
  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'unit_id': unitId,
      'rental_unit': rentalunit,
      'rental_id': rentalId,
      'rental_images':rentalImages,
      'rental_unit_adress': rentalunitadress,
      'rental_sqft': rentalsqft,
      'rental_bath': rentalbath,
      'rental_bed': rentalbed,
      'rental_images':rentalImages
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

  Future<Map<String, dynamic>> Deleteapplences({
    required String? appliance_id
  }) async {
    // print('$apiUrl/$id');
    print('hello 123 ${appliance_id}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final http.Response response = await http.delete(
      Uri.parse('${Api_url}/api/appliance/appliance/$appliance_id'),
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
      throw Exception('Failed to delete applences');
    }
  }
  Future<Map<String, dynamic>> Deleteunit({
    required String? unitId
  }) async {
    // print('$apiUrl/$id');

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
    //log(response.body);
   // print(rentalId);
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

  Future<List<propertiesworkData>> fetchWorkOrders(String rentalId) async {
    // Retrieve admin ID and token from SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    // Define the URL and headers for the request
    final response = await http.get(
      Uri.parse('$Api_url/api/work-order/rental_workorder/$rentalId'),
      headers: {
        'authorization': 'CRM $token',
        'id': 'CRM $id',
      },
    );
    // Check the response status
    print(response.body);
    print(rentalId);
    if (response.statusCode == 200) {
      // Parse the JSON response
      List jsonResponse = json.decode(response.body)['data'];
      // Map the JSON data to List<Data> and return
      return jsonResponse.map((data) => propertiesworkData.fromJson(data)).toList();
    } else {
      // Throw an exception if the request failed
      throw Exception('No work order found');
    }
  }

}

