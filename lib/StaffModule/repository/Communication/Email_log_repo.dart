import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';

import '../../../Model/Comunication_model/email_logtable.dart';
import '../../../constant/constant.dart';
class EmailLogRepository {
  final String apiUrl = '${Api_url}/api/email-logs/logs';



  // Future<List<Emails>> fetchEmailLog() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? id = prefs.getString("adminId");
  //   String? staffid = prefs.getString("staff_id");
  //   String? token = prefs.getString('token');
  //   final response = await apiGet(Uri.parse('$apiUrl/$id'),
  //     headers: {"authorization" : "CRM $token","id":"CRM $staffid",},
  //   );
  //   print("fetch mail ${response.body}");
  //
  //   if (response.statusCode == 200) {
  //     List jsonResponse = json.decode(response.body)['emails'];
  //     return jsonResponse.map((data) => Emails.fromJson(data)).toList();
  //   } else {
  //     print('Failed to fetch emails: ${response.body}');
  //     return [];
  //     // throw Exception('Failed to load data');
  //   }
  // }
  Future<List<Emails>> fetchEmailLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? staffid = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    // Check if required data is available
    if (id == null || token == null) {
      print('Missing adminId or token in SharedPreferences');
      return [];
    }

    final response = await apiGet(
      Uri.parse('$apiUrl/$id'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM ${staffid ?? id}",
      },
    );
    print("fetch mail ${response.body}");

    if (response.statusCode == 200) {
      print("fetch mailin email log repo ${response.body}");
      //show consolle like this fetch mailin email log repo {"statusCode":204,"message":"Mails not available"}
      if (response.body ==
          "{\"statusCode\":204,\"message\":\"Mails not available\"}") {
        return [];
      }
      List jsonResponse = json.decode(response.body)['emails'];
      return jsonResponse.map((data) => Emails.fromJson(data)).toList();
    } else if (response.statusCode == 204) {
      print('No emails available: ${response.body}');
      return [];
    } else {
      print('Failed to fetch emails: ${response.body}');
      return [];
      // throw Exception('Failed to load data');
    }
  }


}