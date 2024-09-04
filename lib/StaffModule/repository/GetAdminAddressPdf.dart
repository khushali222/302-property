import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:http/http.dart' as http;

class GetAddressAdminPdfService {
  final String apiUrl = "${Api_url}/api/admin/admin_profile/";

  Future<profile> fetchAdminAddress() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('$apiUrl$adminid'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData["statusCode"] == 200) {
        return profile.fromJson(responseData["data"]);
      } else {
        throw Exception('Failed to load profile: Invalid status code');
      }
    } else {
      throw Exception('Failed to load profile');
    }
  }
}
