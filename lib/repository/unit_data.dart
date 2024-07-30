import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/unit.dart';
import '../constant/constant.dart';

class UnitData {
  final String baseUrl = '${Api_url}/api/';


  Future<List<unit_appliance>> fetchApplianceData(String unitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final url = Uri.parse("${baseUrl}appliance/appliance/$unitId");
    print(url);

    try {
      final response = await http.get(url,headers: {"authorization" : "CRM $token","id":"CRM $id",},);
      print(response.body);
      print(["data"].first.length);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body)["data"];
        return data.map((item) => unit_appliance.fromJson(item)).toList();
      } else {
        print('Failed to fetch data: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  Future<List<unit_lease>> fetchUnitLeases(String unitId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final response = await http.get(Uri.parse('${baseUrl}leases/unit_leases/$unitId'),headers: {"authorization" : "CRM $token","id":"CRM $id",},);

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)["data"];
      List<unit_lease> leases = body.map((dynamic item) => unit_lease.fromJson(item)).toList();
      return leases;
    } else {
      throw Exception('Failed to load leases');
    }
  }
}
