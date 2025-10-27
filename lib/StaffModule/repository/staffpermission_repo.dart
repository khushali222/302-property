import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../model/staffpermission.dart';

class StaffPermissionService {
  static Future<StaffPermission> fetchPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await http.get(
        Uri.parse('$Api_url/api/permission/permission/$admin_id'),
        headers: {
          "id": "CRM $id",
          "authorization": "CRM $token",
          "Content-Type": "application/json"
        });

    if (response.statusCode == 200) {
      log(response.body);
      final json = jsonDecode(response.body);

      // Check if permissions exist in the response
      if (json['data'] != null && json['data']['staff_permission'] != null) {
        return StaffPermission.fromJson(json['data']['staff_permission']);
      } else {
        // No permissions set for this staff member, return default permissions (all false)
        return StaffPermission();
      }
    } else {
      throw Exception('Failed to load permissions');
    }
  }
}
