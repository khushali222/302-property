import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../Model/activity.dart';
 // Import your model file

class ActivityRepository {

  Future<Activity_model> fetchActivities(int pageSize, int pageNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http.get(Uri.parse('$Api_url/api/activity/$id?pageSize=$pageSize&pageNumber=$pageNumber'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id":"CRM $id",
      'Content-Type': 'application/json; charset=UTF-8',
    },);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      // Assuming the response contains a list of activities in a key called 'data'

      return Activity_model.fromJson(jsonResponse);
    } else {
      throw Exception('Failed to load activities');
    }
  }
}