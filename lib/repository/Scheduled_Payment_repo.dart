import 'dart:convert';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant/constant.dart';
import '../Model/Scheduled_Payment_model.dart';

class Scheduled_Payment_repo {
  Future<List<Scheduled_Payment>> fetchScheduled_Payment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");

    final response = await http
        .get(Uri.parse('${Api_url}/api/payment/upcomingpayment/$id'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $id",
    });
    print('shcedule payment ${response.body}');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse
          .map((data) => Scheduled_Payment.fromJson(data))
          .toList();
    } else {
      print('Failed to fetch renewal leases: ${response.body}');
      return [];
      // throw Exception('Failed to load data');
    }
  }

  Future<Map<String, dynamic>> DeleteScheduled_Payment(
      {required String? pro_id, String? reason}) async {
    final String apiUrl = '${Api_url}/api/payment/scheduled-payments/$pro_id';
    //print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString('adminId');
    String? companyName = prefs.getString('companyName');
    final http.Response response =
        await apiDelete(Uri.parse('$apiUrl?company_name=$companyName'),
            headers: <String, String>{
              "authorization": "CRM $token",
              "id": "CRM $adminid",
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode({"reason": reason}));
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
