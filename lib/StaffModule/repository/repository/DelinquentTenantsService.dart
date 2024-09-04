import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/DelinquentTenantsModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class DelinquentTenantsSerivce {
// Define your API URL here

  Future<List<DelinquentTenantsData>> fetchDelinquentTenants() async {
    print('Fetching delinquent tenants');

    // Get SharedPreferences instance and retrieve token
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    try {
      final response = await http
          .get(Uri.parse('$Api_url/api/charge/delinquent/$adminId'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      });

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON

        final parsedJson = jsonDecode(response.body);
        print(parsedJson);
        final delinquentTenants = DelinquentTenantsModel.fromJson(parsedJson);
        return delinquentTenants.data ?? [];
      } else {
        // If the server did not return a 200 OK response, throw an exception
        print('Failed to fetch delinquent tenants: ${response.body}');
        return [];
        // throw Exception('Failed to load delinquent tenants');
      }
    } catch (e) {
      // Handle any other exceptions
      print('Error fetching data: $e');
      return [];
    }
  }
}
