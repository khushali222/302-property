import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';

import '../../../Model/Comunication_model/Send_email_table.dart';
import '../../../constant/constant.dart';

class SendemailRepository {
  final String apiUrl = '${Api_url}/api/email-logs';

  Future<Send_email_table> fetchSendEmailTable(
      {int limit = 10, int page = 1}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? staffid = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await apiGet(
      Uri.parse('$apiUrl/$id?page=$page&limit=$limit'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffid",
      },
    );
    print("fetch send mail ${response.body}");
    print("fetch url ${'$apiUrl/$id?page=$page&limit=$limit'}");
    //
    // if (response.statusCode == 200) {
    //  // List jsonResponse = json.decode(response.body)['emails'];
    //   final jsonResponsee = json.decode(response.body);
    //   final InsuranceResponse = Send_email_table.fromJson(jsonResponsee);
    //   return InsuranceResponse;
    //   //return jsonResponse.map((data) => Send_email_table.fromJson(data)).toList();
    // }
    // else {
    //   print('Failed to fetch emails: ${response.body}');
    //   return Send_email_table(
    //   );
    //   // return [];
    //    throw Exception('Failed to load data');
    // }
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      if (jsonResponse.containsKey('emails') &&
          jsonResponse['emails'] is List &&
          jsonResponse['emails'].isNotEmpty) {
        return Send_email_table.fromJson(jsonResponse);
      } else {
        print("No emails found in response");
        return Send_email_table(
            emails: [],
            totalEmails:
                0); // Return an empty object instead of throwing an error
      }
    } else if (response.statusCode == 204) {
      print("No emails available (204 No Content)");
      return Send_email_table(
          emails: [], totalEmails: 0); // Return an empty object
    } else {
      final jsonResponse = json.decode(response.body);
      String errorMessage = jsonResponse['message'] ?? 'Failed to load data';
      print('Failed to fetch emails: $errorMessage');
      throw Exception(errorMessage);
    }
  }
  Future<Map<String, dynamic>> DeleteSendMail({
    required String? email_id,
    String? reason
  }) async {

    //print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  adminid = prefs.getString('adminId');
    String? staffid = prefs.getString("staff_id");
    final http.Response response = await apiDelete(
        Uri.parse('$apiUrl/$email_id'),
        headers: <String, String>{

          "authorization": "CRM $token",
          "id":"CRM $staffid",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "reason":reason
        })
    );
    var responseData = json.decode(response.body);
    print(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to delete property type');
    }
  }
}
