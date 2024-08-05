import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class SubscriptionService {
  Future<int> cancelSubscription(String subscriptionId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    String? superadmin_id = prefs.getString('superadminId');

    try {
      final response = await http.post(
        Uri.parse('$Api_url/api/nmipayment/custom-delete-subscription'),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $adminId",
        },
        body: json.encode(
            {'subscription_id': subscriptionId, 'admin_id': superadmin_id}),
      );

      // Return only the response code
      return response.statusCode;
    } catch (e) {
      print('Error: $e');
      return 500; // Return 500 as a fallback error code
    }
  }

  Future<int> cancelFromDataBaseSubscription(String purchaseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    try {
      final response = await http.delete(
        Uri.parse('$Api_url/api/purchase/purchase/$purchaseId'),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $adminId",
        },
        body: json.encode({
          // 'admin_id': a,
          'admin_id': adminId,
        }),
      );

      // Return only the response code
      return response.statusCode;
    } catch (e) {
      print('Error: $e');
      return 500; // Return 500 as a fallback error code
    }
  }
}
