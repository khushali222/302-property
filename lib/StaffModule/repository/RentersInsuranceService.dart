import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class RentersInsuranceService {
  Future<List<RentersInsuranceData>> fetchRentersInsurance() async {
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    try {
      final response = await http.get(
          Uri.parse('$Api_url/api/tenantinsurance/report/$adminid'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON

        final parsedJson = jsonDecode(response.body);
        print(parsedJson);
        final completedWorkOrders = RentersInsuranceModel.fromJson(parsedJson);
        return completedWorkOrders.data ?? [];
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load renters insurance');
      }
    } catch (e) {
      // Handle any other exceptions
      print('Error fetching data: $e');
      return [];
    }
  }
}
