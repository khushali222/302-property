import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';

class Rental_PropertiesRepository{

  final String apiUrl = 'https://saas.cloudrentalmanager.com/api/rentals/rentals';

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

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
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

    final http.Response response = await http.post(

      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? rental_id = prefs.getString("adminId");
    var responseData = json.decode(response.body);

    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add property type');
    }
  }
}