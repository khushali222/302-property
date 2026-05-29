import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../model/permission.dart';

class PermissionService {
  static Future<UserPermissions> fetchPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await apiGet(
      Uri.parse('$Api_url/api/permission/permission/$admin_id'),
        headers: {
          "id":"CRM $id",
          "authorization": "CRM $token",
          "Content-Type": "application/json"
        }
    );

    if (response.statusCode == 200) {
      log(response.body);
      final json = jsonDecode(response.body);

      if(json['data'] == null){
        return UserPermissions(propertyView: false, financialView: false, financialAdd: false, financialEdit: false, workorderView: false, workorderAdd: false, workorderEdit: false, documentsView: false, documentsAdd: false, documentsEdit: false);
      }
      return UserPermissions.fromJson(json['data']['tenant_permission']);
    } else {
      throw Exception('Failed to load permissions');
    }
  }
}
