import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../Model/All_categories_model.dart';
import '../constant/constant.dart';

class FetchAllcategories {
  Future<List<allcategories_model>> fetchAllCategories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminId = prefs.getString('adminId');
    String? staffId = prefs.getString("staff_id");
    String? id = (staffId != null && staffId.isNotEmpty) ? staffId : adminId;

    final response = await http.get(
      Uri.parse('${Api_url}/api/settings/allCategories/$adminId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => allcategories_model.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }


}