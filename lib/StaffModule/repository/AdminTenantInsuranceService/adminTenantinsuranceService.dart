import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/AdminTenantInsuranceModel/adminTenantInsuranceModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class AdminTenantInsuranceRepository {
  Future<List<AdminTenantInsuranceModel>> fetchTenantInsurance(
      String tenantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final headers = {
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };
    final response = await http.get(
        Uri.parse('$Api_url/api/tenant/tenant_details/$tenantId'),
        headers: headers);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      List<AdminTenantInsuranceModel> tenantInsuranceList = [];

      if (jsonData['statusCode'] == 200) {
        final tenantData = jsonData['data'];
        print('tenant insurance ${response.body}');

        if (tenantData.isNotEmpty) {
          final tenantInsurance = tenantData[0]['tenantInsurance'] as List;

          tenantInsuranceList = tenantInsurance
              .map((insurance) => AdminTenantInsuranceModel.fromJson(insurance))
              .toList();
        }
      }
      return tenantInsuranceList;
    } else {
      print('ok');
      throw Exception('Failed to load tenant insurance data');
    }
  }

  Future<bool> deleteInsurancesProperties(String TenantInsurance_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse(
          '$Api_url/api/tenantinsurance/tenantinsurance/$TenantInsurance_id'),
      headers: <String, String>{
        'authorization': 'CRM $token',
        'id': 'CRM $id',

        //'Content-Type': 'application/json; charset=UTF-8',
      },
    );

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
