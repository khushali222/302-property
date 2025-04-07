import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import '../../../Model/Comunication_model/email_logtable.dart';
import '../../../constant/constant.dart';
class EmailLogRepository {
  final String apiUrl = '${Api_url}/api/email-logs/logs';



  Future<List<Emails>> fetchEmailLog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? staffid = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await http.get(Uri.parse('$apiUrl/$id'),
      headers: {"authorization" : "CRM $token","id":"CRM $staffid",},
    );
    print("fetch mail ${response.body}");

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['emails'];
      return jsonResponse.map((data) => Emails.fromJson(data)).toList();
    } else {
      print('Failed to fetch emails: ${response.body}');
      return [];
      // throw Exception('Failed to load data');
    }
  }

}