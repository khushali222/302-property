import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/ReopenWorkOrderModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'dart:convert';

/// Staff module repository for Reopen Work Orders.
/// Uses staff_id in request header and adminId in URL (content scoped by backend).
class ReopenWorkOrderStaffRepository {
  final String baseUrl = '$Api_url/api/work-order/reopen-work-orders';

  Future<ReopenWorkOrderResponse> fetchReopenWorkOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? staffId = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    if (adminId == null || adminId.isEmpty) {
      return ReopenWorkOrderResponse(
        statusCode: 400,
        data: [],
        message: 'Admin ID not found',
      );
    }

    String url = '$baseUrl/$adminId';

    try {
      final response = await http.get(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        "authorization": "CRM $token",
        "id": "CRM ${staffId ?? adminId}",
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return ReopenWorkOrderResponse.fromJson(jsonData);
      } else {
        return ReopenWorkOrderResponse(
          statusCode: response.statusCode,
          data: [],
          message: 'Failed to fetch data',
        );
      }
    } catch (error) {
      return ReopenWorkOrderResponse(
        statusCode: 500,
        data: [],
        message: 'Error: $error',
      );
    }
  }
}
