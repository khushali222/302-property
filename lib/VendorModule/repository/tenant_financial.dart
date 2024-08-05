import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/constant.dart';
import '../model/tenant_financial.dart';

class TenantFinancialRepository {


  Future<List<Data>> fetchTenantFinancial() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.get(Uri.parse('$Api_url/api/payment/tenant_financial/$id'), headers: {
      "id":"CRM $id",
      "authorization": "CRM $token",
      "Content-Type": "application/json"
    });
    print('financial table${response.body}');
    print(id);
    print(response.body);
    if (response.statusCode == 200) {
       List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => Data.fromJson(json)).toList();
      // return TenantFinancial.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load tenant financial data');
    }
  }


}
