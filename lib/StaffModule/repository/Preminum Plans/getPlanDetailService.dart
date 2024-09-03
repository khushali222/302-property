import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/Preminum%20Plans/getPlanDetailModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class getPlanDetailService {
  Future<getPlanDetailModel?> fetchPlanPurchaseDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$Api_url/api/purchase/plan-purchase/$adminId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $adminId",
        },
      );

      if (response.statusCode == 200) {
        return getPlanDetailModel.fromJson(json.decode(response.body));
      } else {
        // Handle error
        print('Failed to load plan purchase details');
        return null;
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
