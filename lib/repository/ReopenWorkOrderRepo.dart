import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/ReopenWorkOrderModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'dart:convert';

class ReopenWorkOrderRepository {
  final String baseUrl = '$Api_url/api/work-order/reopen-work-orders';

  Future<ReopenWorkOrderResponse> fetchReopenWorkOrders(String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    String url = '$baseUrl/$adminId';
    print('Fetching reopen work orders from: $url');

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      });

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ReopenWorkOrderResponse.fromJson(jsonData);
      } else {
        print(
            'Failed to load reopen work orders. Status code: ${response.statusCode}');
        return ReopenWorkOrderResponse(
          statusCode: response.statusCode,
          data: [],
          message: 'Failed to fetch data',
        );
      }
    } catch (error) {
      print('Error fetching reopen work orders: $error');
      return ReopenWorkOrderResponse(
        statusCode: 500,
        data: [],
        message: 'Error: $error',
      );
    }
  }
}
