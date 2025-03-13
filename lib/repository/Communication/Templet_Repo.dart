import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Staff_Member/Edit_staff_member.dart';

import '../../Model/Comunication_model/templet.dart';
import '../../constant/constant.dart';

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
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    print(' templet add ${response.body}');
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
    final response = await http.get(Uri.parse('$apiUrl/$id'),
      headers: {"authorization" : "CRM $token","id":"CRM $id",},
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['templates'];
      return jsonResponse.map((data) => EmailTemplate.fromJson(data)).toList();
    } else {
      print('Failed to fetch templet: ${response.body}');
      return [];
      // throw Exception('Failed to load data');
    }
  }
  // Future<Map<String, dynamic>> Edit_staff_member({
  //   required String? adminId,
  //   required String? staffmemberName,
  //   required String? staffmemberDesignation,
  //   required String staffmemberPhoneNumber,
  //   required String? staffmemberEmail,
  //   String? staffmemberPassword,
  //   required String? Sid
  // }) async {
  //   final Map<String, dynamic> data = {
  //     "admin_id": adminId,
  //     "staffmember_name": staffmemberName,
  //     "staffmember_designation": staffmemberDesignation,
  //     "staffmember_phoneNumber": staffmemberPhoneNumber,
  //     "staffmember_email": staffmemberEmail,
  //     "staffmember_password": staffmemberPassword,
  //     //  "staffmember_password": staffmemberPassword,
  //
  //   };
  //   print(data);
  //   String apiUrl = "${Api_url}/api/staffmember/staff_member/$Sid";
  //   print(apiUrl);
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   String?  id = prefs.getString('adminId');
  //   final http.Response response = await http.put(
  //     Uri.parse(apiUrl),
  //     headers: <String, String>{
  //       "authorization" : "CRM $token",
  //       "id":"CRM $id",
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(data),
  //   );
  //   print('edit responce ${response.body}');
  //   var responseData = json.decode(response.body);
  //   if (responseData["statusCode"] == 200) {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     return json.decode(response.body);
  //   } else {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     throw Exception('Failed to add StaffMember ');
  //   }
  // }
  // Future<Map<String, dynamic>> DeleteStaffMember({
  //   required String? id,
  //   String? reason
  // }) async {
  //
  //   // print('$apiUrl/$id');
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   String?  adminid = prefs.getString('adminId');
  //   final http.Response response = await http.delete(
  //       Uri.parse('$apiUrl/$id'),
  //       headers: <String, String>{
  //         "authorization" : "CRM $token",
  //         "id":"CRM $adminid",
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode({"reason":reason})
  //   );
  //   var responseData = json.decode(response.body);
  //   print(response.body);
  //   if (responseData["statusCode"] == 200) {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     return json.decode(response.body);
  //
  //   } else {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     throw Exception('Failed to add property type');
  //   }
  // }
}
