import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../../Model/lease_communication.dart';
import '../../../constant/constant.dart';
class EmailLogRepository {
  final String apiUrl = '${Api_url}/api/email-logs/emaillogs_lease';



  Future<lease_communications> fetchEmailLog(String lease_id,{int page = 1,int limit =10}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      String? staffid = prefs.getString("staff_id");

      final response = await http.get(
        Uri.parse('$apiUrl/$lease_id?page=$page&limit=$limit'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $staffid",
        },
      );

      print("fetch mail ${response.body}");

      if (response.statusCode == 200) {
        return lease_communications.fromJson(json.decode(response.body));
      } else {
        print('Failed to fetch emails: ${response.body}');
        throw Exception('Failed to Acknowledgement payment');
      }
    } catch (e) {
      print('Error fetching email logs: $e');
      throw Exception('Failed to Acknowledgement payment');
    }
  }

}