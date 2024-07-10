import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;
import '../constant/constant.dart';
import '../model/added_total.dart';

class Added_TotalRepository{

  Future<List<Rentaladded>> fetchRentaladded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    if (id == null) {
      throw Exception('No adminId found in SharedPreferences');
    }

    final response = await http.get(Uri.parse('${Api_url}/api/rentals/rental-owners/$id'),
      headers: {
        "id":"CRM $id",
      "authorization" : "CRM $token"
      },);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Rentaladded.fromJson(data)).toList();

    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<List<Staffadded>> fetchStaffMemberadded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    if (id == null) {
      throw Exception('No adminId found in SharedPreferences');
    }
    final response = await http.get(Uri.parse('${Api_url}/api/staffmember/limitation/$id'),headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Staffadded.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
  Future<List<Rentalwneradded>> fetchRentalowneradded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");

    String? token = prefs.getString('token');
    if (id == null) {
      throw Exception('No adminId found in SharedPreferences');
    }
    final response = await http.get(Uri.parse('${Api_url}/api/staffmember/limitation/$id'),headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Rentalwneradded.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

}