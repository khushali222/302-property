
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../model/insurance.dart';
import '../model/tenant_property.dart';

class InsuranceRepository {
  Future<List<Insurance_data>> fetchInsurancesProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await http.get(Uri.parse('$Api_url/api/tenantinsurance/docinsurance/$id'), headers: {
      "id":"CRM $id",
      "authorization": "CRM $token",
      "Content-Type": "application/json"
    });

    print(response.body);
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Insurance_data.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load insurances');
    }
  }
  Future<bool> deleteInsurancesProperties(String TenantInsurance_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await http.delete(Uri.parse('$Api_url/api/tenantinsurance/tenantinsurance/$TenantInsurance_id'), headers: {
      "id":"CRM $id",
      "authorization": "CRM $token",
      "Content-Type": "application/json"
    });

    print(response.body);
    if (response.statusCode == 200) {
      var responseData = json.decode(response.body);
      Fluttertoast.showToast(msg: responseData["message"]);
    // List<dynamic> data = jsonDecode(response.body)['data'];
      return true;
    } else {
      throw Exception('Failed to load insurances');
    }
  }

}