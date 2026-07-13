import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/AdminUser%20Permission/adminUserPermissionModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class PermissionService {
  static const String apiUrl = '';

  Future<UserPermissionData?> fetchPermissions() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    // The `id` header must be the acting user's OWN id. For a Staff user that is
    // staff_id; for an Admin the own-id IS adminId, so Admin behaviour is unchanged.
    final String? actingId = prefs.getString('role') == 'Staffmember'
        ? prefs.getString('staff_id')
        : adminId;

    final response = await apiGet(
      Uri.parse('$Api_url/api/permission/permission/$adminId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $actingId",
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
    // Same rule as fetchPermissions: send the acting user's OWN id (staff_id for
    // Staff, adminId for Admin) so saving works for Staff and is unchanged for Admin.
    final String? actingId = prefs.getString('role') == 'Staffmember'
        ? prefs.getString('staff_id')
        : adminId;

    try {
      final response = await apiPost(
        Uri.parse('$Api_url/api/permission/permission/'),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $actingId",
        },
        body: json.encode(data.toJson()),
      );
      print(response.body);
      return response.statusCode;
    } catch (e) {
      print('Error: $e');
      return 500; // Return 500 as a fallback error code
    }
  }
}
