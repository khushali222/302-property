import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/Comunication_model/email_logtable.dart';
import '../../constant/constant.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
class EmailLogRepository {
  final String apiUrl = '${Api_url}/api/email-logs/logs';



  Future<Email_log_table> fetchEmailLog({int page = 1,int limit =10}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');

      final response = await apiGet(
        Uri.parse('$apiUrl/$id?page=$page&limit=$limit'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );


      if (response.statusCode == 200) {
        return Email_log_table.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to Acknowledgement payment');
      }
    } catch (e) {
      logError('Error fetching email logs: $e');
      throw Exception('Failed to Acknowledgement payment');
    }
  }

}