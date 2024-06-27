import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/properties.dart';

import '../constant/constant.dart';
import 'package:http/http.dart'as http;

class PropertiesRepository {
  final String apiUrl = '${Api_url}/api/propertytype/property_type';



  Future<List<Rentals>> fetchProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");

    final response = await http.get(Uri.parse('${Api_url}/api/rentals/rentals/$id'));
    print('${Api_url}/api/rentals/rentals/$id');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => Rentals.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> updateRental(Rentals properties) async {

    final url = Uri.parse('${Api_url}/api/rentals/rentals/${properties.rentalId}');
    print(properties.rentalId);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString("token");
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      "rentalOwner": {
        "admin_id": properties.adminId,
        "rentalowner_id": properties.rentalOwnerId,
        "rentalOwner_firstName": properties.rentalOwnerData?.rentalOwnerFirstName,
        "rentalOwner_lastName": properties.rentalOwnerData?.rentalOwnerLastName,
        "rentalOwner_companyName": properties.rentalOwnerData?.rentalOwnerCompanyName,
        "rentalOwner_primaryEmail": properties.rentalOwnerData?.rentalOwnerPrimaryEmail,
        "rentalOwner_phoneNumber": properties.rentalOwnerData?.rentalOwnerPhoneNumber,
        "rentalOwner_homeNumber": properties.rentalOwnerData?.rentalOwnerHomeNumber,
        "rentalOwner_businessNumber": properties.rentalOwnerData?.rentalOwnerBuisinessNumber,
        "city": properties.rentalOwnerData?.city,
        "state": properties.rentalOwnerData?.state,
        "country": properties.rentalOwnerData?.country,
        "postal_code": properties.rentalOwnerData?.postalCode,
      },
      "rental": {
        "company_name": properties.rentalOwnerData?.rentalOwnerCompanyName,
        "rental_id": properties.rentalId,
        "property_id": properties.propertyId,
        "rental_adress": properties.rentalAddress,
        "rental_city": properties.rentalCity,
        "rental_state": properties.rentalState,
        "rental_country": properties.rentalCountry,
        "rental_postcode": properties.rentalPostcode,
        "staffmember_id": properties.staffMemberId,
      },
    });
    print(body);
    final response = await http.put(url, headers: headers, body: body);
    print(response.body);
    if (response.statusCode == 200) {

      Fluttertoast.showToast(msg: "Rental Owner Updated Successfully");
      print('Rental and Rental Owner Updated Successfully');
    } else {
      Fluttertoast.showToast(msg: "Failed to update rental");
      print("object");
      throw Exception('Failed to update rental');
    }
  }

  Future<Map<String, dynamic>> DeleteProperties({
    required String? id
  }) async {

    print('$apiUrl/$id');

    final http.Response response = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: <String, String>{
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
}