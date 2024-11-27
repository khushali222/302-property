import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/RentPastDueModel.dart';
import 'package:three_zero_two_property/Model/WorkOrderSetting.dart';

import '../constant/constant.dart';

Future<Data> fetchWorkOrderSetting() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  String? id = prefs.getString("adminId");
  String url = '${Api_url}/api/work-order/work-defaults/${id}';

  print('Fetching work order setting: $url');
  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        "authorization": "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    print('work order setting response: ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic>? jsonData = json.decode(response.body);
      return Data.fromJson(jsonData!["data"]);

    } else {
      print('Failed to load work order setting. Status code: ${response.statusCode}');
      throw Exception('Failed to work order setting');
    }
  } catch (error) {
    print('Error work order setting: $error');
    throw Exception('Error work order setting');
  }
}