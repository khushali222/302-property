import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/Preminum%20Plans/purchaseFormModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class purchaseFormService {
  Future<int?> postPurchaseForm(purchaseFormModel purchaseForm) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };

    final body = jsonEncode(purchaseForm.toJson());

    try {
      final response = await http.post(
        Uri.parse('$Api_url/api/purchase/purchase'),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200) {
        print('pusrchase status code ${response.statusCode}');
        print('purchase reponse ${response.body}');
      }

      return response.statusCode;
    } catch (e) {
      print('Exception during POST request: $e');
      return null;
    }
  }
}
