import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/rental_properties.dart';

import '../../../constant/constant.dart';
import '../../model/add_property.dart';

class Rental_PropertiesRepository{

  final String apiUrl = '${Api_url}/api/rentals/rentals';

  Future<Map<String, dynamic>> addProperties({

    required String? adminId,
    required String? property_id,
    required String? rental_adress,
    required String?  rental_city,
    required String?   rental_state,
    required String?   rental_country,
    required String?    rental_postcode,
    required String?    staffmember_id,
    required String?    processor_id,

  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'property_id': property_id,
      'rental_adress': rental_adress,
      'rental_city':  rental_city,
      'rental_state':   rental_state,
      ' rental_country':   rental_country,
      '  rental_postcode':    rental_postcode,
      ' staffmember_id':    staffmember_id,
      ' processor_id':  processor_id,

    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
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
      throw Exception('Failed to add property type');
    }
  }

  Future<Map<String, dynamic>> addRentals({
    required String? adminId,
    required String? rentalowner_id,
   required String? processor_list,
    required String? rentalOwner_firstName,
    required String? rentalOwner_lastName,
    required String? rentalOwner_companyName,
    required String? rentalOwner_primaryEmail,
    required String? rentalOwner_phoneNumber,
    required String? rentalOwner_businessNumber,


  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'rentalowner_id': rentalowner_id,
      'processor_list': processor_list,
      'rentalOwner_firstName':  rentalOwner_firstName,
      'rentalOwner_lastName':  rentalOwner_lastName ,
      ' rentalOwner_companyName':   rentalOwner_companyName,
      '  rentalOwner_primaryEmail':    rentalOwner_primaryEmail,
      ' rentalOwner_phoneNumber':    rentalOwner_phoneNumber,
      ' rentalOwner_businessNumber':  rentalOwner_businessNumber,

    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        "authorization" : "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    String? rental_id = prefs.getString("adminId");
   // var responseData = json.decode(response.body);

    // if (responseData["statusCode"] == 200) {
    //   Fluttertoast.showToast(msg: responseData["message"]);
    //   return json.decode(response.body);
    //
    // } else {
    //   Fluttertoast.showToast(msg: responseData["message"]);
    //   throw Exception('Failed to add property type');
    // }
    final responseData = json.decode(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      // Assuming responseData contains a field indicating whether the rental owner exists
      final rentalOwnerExists = responseData["rentalOwnerExists"];
      return rentalOwnerExists ?? false; // Return rentalOwnerExists if not null, otherwise return false
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to check property');
    }

  }

  Future<bool> checkIfRentalOwnerExists({
   // required String rentalowner_id,
     String? rentalOwner_firstName,
     String? rentalOwner_lastName,
    required String rentalOwner_name,
    required String rentalOwner_companyName,
    required String rentalOwner_primaryEmail,
    required String rentalOwner_alternativeEmail,
    required String rentalOwner_phoneNumber,
    required String rentalOwner_homeNumber,
    required String rentalOwner_businessNumber,
  }) async {
    final Map<String, dynamic> requestData = {
     // 'rentalowner_id': rentalowner_id,
      'rentalOwner_firstName': rentalOwner_firstName,
      'rentalOwner_lastName': rentalOwner_lastName,
      'rentalOwner_name': rentalOwner_name,
      'rentalOwner_companyName': rentalOwner_companyName,
      'rentalOwner_primaryEmail': rentalOwner_primaryEmail,
      'rentalOwner_alternativeEmail': rentalOwner_alternativeEmail,
      'rentalOwner_phoneNumber': rentalOwner_phoneNumber,
      'rentalOwner_homeNumber': rentalOwner_homeNumber,
      'rentalOwner_businessNumber': rentalOwner_businessNumber,
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http.post(
      Uri.parse('${Api_url}/api/rental_owner/check_rental_owner'),
      headers: <String, String>{
        "authorization" : "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(requestData),
    );
    var responseData = json.decode(response.body);
    print(response.body);
    if (responseData["statusCode"] == 200) {
    //  Fluttertoast.showToast(msg: responseData["message"]);
      print(responseData);
        if(responseData["statusCode"]== 200){
          return true;
        }
        else{
          return false;
        }
        // return json.decode(requestData.length);
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to check property');
      return false;
    }
  }






  Future<Map<String, dynamic>> DeleteRentalOwner({
    required String? id
  }) async {

   // print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final http.Response response = await http.delete(
      Uri.parse('$apiUrl/$id'),
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

  Future<void> createRental(RentalRequest rentalRequest) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        "authorization" : "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json'},
      body: jsonEncode(rentalRequest.toJson()),
    );
     print('create rental ${response.body}');
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Properties added successfully");
      // Handle success
      print('Properties added successfully');
    } else {
      Fluttertoast.showToast(msg: "Failed to add properties");
      // Handle error
      print('Failed to add properties: ${response.body}');
    }
  }

}




