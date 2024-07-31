import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/AdminUser%20Permission/adminUserPermissionModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class PermissionService {
  static const String apiUrl = '';

  Future<UserPermissionData?> fetchPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$Api_url/api/permission/permission/$adminId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return UserPermissionData.fromJson(data['data']);
    } else {
      throw Exception('Failed to load permissions');
    }
  }

  Future<int> postUserPermissionData(UserPermissionData data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final Uri url = Uri.parse('$Api_url/api/permission/permission/');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $adminId",
        },
        body: json.encode(data.toJson()),
      );

      return response.statusCode;
    } catch (e) {
      print('Error: $e');
      return 500; // Return 500 as a fallback error code
    }
  }
}
