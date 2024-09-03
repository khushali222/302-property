import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../../../Model/CompletedWorkOrdersModel.dart';

class CompletedWorkOrderService {
  Future<List<CompletedWorkData>> fetchCompletedWorkOrders() async {
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
          Uri.parse('$Api_url/api/work-order/complete-work-orders/$adminid'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        print(parsedJson);
        final completedWorkOrders =
            CompletedWorkOrdersModel.fromJson(parsedJson);
        return completedWorkOrders.data ?? [];
      } else {
        // Handle non-200 responses
        print('Failed to fetch complete workorders: ${response.body}');
        return [];
        // throw Exception(
        //     'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch all exceptions
      print('Error occurred: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}
