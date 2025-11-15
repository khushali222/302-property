import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../model/vendor_permission_model.dart';


class PermissionService {
  static Future<UserPermissions> fetchPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("vendor_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await http.get(
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
        return UserPermissions( workorderView: false,  workorderEdit: false,);
      }
      return UserPermissions.fromJson(json['data']['vendor_permission']);
    } else {
      throw Exception('Failed to load permissions');
    }
  }
}
