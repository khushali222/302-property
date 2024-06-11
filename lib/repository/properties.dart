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
    print(response.body);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      print(jsonResponse);
      return jsonResponse.map((data) => Rentals.fromJson(data)).toList();
    } else {
      return [];
      //throw Exception('Failed to load data');
    }
  }


  Future<Map<String, dynamic>> EditProperties({
    required String? adminId,
    required String? propertyType,
    required String? propertySubType,
    required bool isMultiUnit,
    required String? id
  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'property_type': propertyType,
      'propertysub_type': propertySubType,
      'is_multiunit': isMultiUnit,
    };

    print('$apiUrl/$id');

    final http.Response response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
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