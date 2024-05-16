import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class StaffMemberRepository {
  final String apiUrl = 'https://saas.cloudrentalmanager.com/api/staffmember/staff_member';

  Future<Map<String, dynamic>> addStaffMember({
    required String? adminId,
    required String? staffmemberName,
    required String? staffmemberDesignation,
    required String staffmemberPhoneNumber,
    required String? staffmemberEmail,
    required String? staffmemberPassword,
  }) async {
    final Map<String, dynamic> data = {
      "admin_id": adminId,
      "staffmember_name": staffmemberName,
      "staffmember_designation": staffmemberDesignation,
      "staffmember_phoneNumber": staffmemberPhoneNumber,
      "staffmember_email": staffmemberEmail,
      "staffmember_password": staffmemberPassword,
    };
    // admin_id
    // staffmember_name
    // staffmember_designation
    // staffmember_phoneNumber
    // staffmember_email
    // staffmember_password
    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
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
      throw Exception('Failed to add StaffMember ');
    }
  }
}
