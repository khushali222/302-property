import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/Preminum%20Plans/checkPlanPurchaseModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class CheckPlanPurchaseService {
  Future<checkPlanPurchaseModel?> fetchPlanPurchaseDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final headers = {
      'authorization': 'CRM $token',
      'id': 'CRM $adminId',
    };


    try {
      final response = await apiGet(
        Uri.parse('$Api_url/api/purchase/plan-purchase/$adminId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        return checkPlanPurchaseModel.fromJson(jsonResponse);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
