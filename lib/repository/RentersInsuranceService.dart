import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class RentersInsuranceService {
  Future<List<RentersInsuranceData>> fetchRentersInsurance(
      {bool isStaff = false, bool includeDeleted = false}) async {
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final headerId =
        isStaff ? (prefs.getString('staff_id') ?? adminId) : adminId;
    // Web parity: "Show Deleted Policies" appends ?include_deleted=1 so the
    // report also returns soft-deleted (is_delete: true) policies.
    final query = includeDeleted ? '?include_deleted=1' : '';
    try {
      final response = await apiGet(
          Uri.parse('$Api_url/api/renter-insurance/report/$adminId$query'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $headerId",
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
