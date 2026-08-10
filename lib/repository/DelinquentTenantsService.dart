import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/DelinquentTenantsModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class DelinquentTenantsSerivce {
// Define your API URL here

  Future<List<DelinquentTenantsData>> fetchDelinquentTenants() async {

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
        final delinquentTenants = DelinquentTenantsModel.fromJson(parsedJson);
        return delinquentTenants.data ?? [];
      } else if (response.statusCode == 404) {
        // The server reports an empty result set for this endpoint as a 404
        // ("No leases found for this admin") — that is a legitimate empty
        // report, not a failure.
        return [];
      } else {
        // A failed request is not an empty report. Throwing lets the caller
        // tell a real error apart from a legitimately empty result, so it can
        // offer a retry instead of showing "No Data Available".
        throw Exception('Failed to load delinquent tenants');
      }
    } catch (e) {
      // Handle any other exceptions
      logError('Error fetching data: $e');
      rethrow;
    }
  }
}
