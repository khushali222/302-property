import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/setting.dart';
import 'package:http/http.dart'as http;



class SurchargeRepository {
  final String baseUrl;

  SurchargeRepository({required this.baseUrl});

  Future<Setting1> fetchSurchargeData(String adminId) async {
    final response = await http.get(Uri.parse('$baseUrl/api/surcharge/surcharge/getadmin/$adminId'));
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
    final response = await http.put(Uri.parse('https://saas.cloudrentalmanager.com/api/surcharge/surcharge/$id'),body:data );
    final response_Data = jsonDecode(response.body,);
    if (response_Data["statusCode"] == 200) {
      final apiResponse = ApiResponse.fromJson(jsonDecode(response.body)["data"]);
      return apiResponse.data;
    } else {
      throw Exception('Failed to update the data');
    }
  }

  Future<bool> updateSurchargeData(String surchargeId, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/surcharge/surcharge/$surchargeId'),
      headers: {'Content-Type': 'application/json'},
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
    final response = await http.post(
      Uri.parse('$baseUrl/api/surcharge/surcharge'),
      headers: {'Content-Type': 'application/json'},
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