import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Staff_Member/Edit_staff_member.dart';

import '../../../Model/Comunication_model/templet.dart';
import '../../../constant/constant.dart';



class TempletRepository {
  final String apiUrl = '${Api_url}/api/templates';

  Future<Map<String, dynamic>> addTemplet({
    required String? adminId,
    required String? name,
    required String? subject,
    required String body,
    required String? type,
    required String? mail_type,
  }) async {
    final Map<String, dynamic> data = {
      "admin_id": adminId,
      "name": name,
      "subject": subject,
      "body": body,
      "type": type,
      "mail_type": mail_type,
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString('adminId');
    String? staffid = prefs.getString("staff_id");
    final http.Response response = await apiPost(
      Uri.parse(apiUrl),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $staffid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    var responseData = json.decode(response.body);
    if (responseData["statusCode"] == 201) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add Templet ');
    }
  }

  Future<List<EmailTemplate>> fetchTemplets() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    String? staffid = prefs.getString("staff_id");
    final response = await apiGet(Uri.parse('$apiUrl/$id'),
      headers: {"authorization" : "CRM $token","id":"CRM $staffid",},
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['templates'];
      return jsonResponse.map((data) => EmailTemplate.fromJson(data)).toList();
    } else {
      return [];
      // throw Exception('Failed to load data');
    }
  }
  Future<Map<String, dynamic>> Edit_Templet({
    required String? template_id,
    required String? adminId,
    required String? name,
    required String? subject,
    required String body,
    required String? type,
    required String? mail_type,
  }) async {
    final Map<String, dynamic> data = {
      "admin_id": adminId,
      "template_id": template_id,
      "name": name,
      "subject": subject,
      "body": body,
      "type": type,
      "mail_type": mail_type,
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    String? staffid = prefs.getString("staff_id");
    final http.Response response = await apiPut(
      Uri.parse('$apiUrl/$template_id'),
      headers: <String, String>{
        "authorization" : "CRM $token",
        "id":"CRM $staffid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    var responseData = json.decode(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to edit templet ');
    }
  }
  Future<Map<String, dynamic>> DeleteTemplet({
    required String? id,
    String? reason
  }) async {

    // print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  adminid = prefs.getString('adminId');
    String? staffid = prefs.getString("staff_id");
    final http.Response response = await apiDelete(
        Uri.parse('$apiUrl/$id'),
        headers: <String, String>{
          "authorization" : "CRM $token",
          "id":"CRM $staffid",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"reason":reason})
    );
    var responseData = json.decode(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to delete templet');
    }
  }
}
