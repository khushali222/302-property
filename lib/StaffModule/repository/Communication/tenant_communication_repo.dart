import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/TenantCommunication.dart';
import '../../../constant/constant.dart';


import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
class EmailLogRepository {
  final String apiUrl = '${Api_url}/api/email-logs/tenant-email';



  Future<TenantCommunation> fetchEmailLog(String lease_id,{int page = 1,int limit =10,bool isTenant =false}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');

      String? ApiUrl = isTenant ? '${Api_url}/api/email-logs/tenant-email/$lease_id?page=$page&limit=$limit' :'$apiUrl/$lease_id?page=$page&limit=$limit';
      print(ApiUrl);

      final response = await http.get(
        Uri.parse('$ApiUrl'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      print("fetch mail ${response.body}");

      if (response.statusCode == 200) {
        return TenantCommunation.fromJson(json.decode(response.body));
      } else if (response.statusCode == 204) {
        return TenantCommunation(statusCode: 204, emails: [], totalEmails: 0, currentPage: 1, totalPages: 0);
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