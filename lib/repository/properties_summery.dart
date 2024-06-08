import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart'as http;
import 'package:three_zero_two_property/model/properties.dart';
import 'package:three_zero_two_property/model/properties_summery.dart';

import '../constant/constant.dart';

class Properies_summery_Repo{

  Future<List<TenantData>> fetchPropertiessummery(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //String? id = prefs.getString("rentalid");
    print(id);
    final response = await http.get(Uri.parse('${Api_url}/api/tenant/rental_tenant/$id'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => TenantData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }
}