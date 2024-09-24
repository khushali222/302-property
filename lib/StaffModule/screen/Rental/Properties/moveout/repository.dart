import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class LeaseMoveoutRepository {
  final String apiUrl = '${Api_url}/api/moveout/lease_moveout/';


  Future<Map<String, dynamic>> addMoveoutTenant({
    required String? adminId,
    required String? tenantId,
    required String? leaseId,
    required String? moveoutNoticeGivenDate,
    required String? moveoutDate,

  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'tenant_id': tenantId,
      'lease_id': leaseId,
      'moveout_notice_given_date': moveoutNoticeGivenDate,
      'moveout_date': moveoutDate,
    };
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
   // String?  id = prefs.getString('adminId');
    String? id = prefs.getString("staff_id");
    final http.Response response = await http.post(
      Uri.parse('${Api_url}/api/moveout/lease_moveout/$leaseId'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    var responseData = json.decode(response.body);
    print('$apiUrl$leaseId');
   print(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add property type');
    }
  }
}
