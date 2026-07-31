import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/Dashbord_table/cronjob_payment_table.dart';
import 'package:three_zero_two_property/Model/Dashbord_table/lease_expiring_table.dart';
import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
import 'package:three_zero_two_property/Model/dashboard_polices.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class cronjob_payment_tableService {
  Future<LeaseResponse> fetchCronjob_payment(
  {int limit = 5,int page= 1}
      ) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    try {
      final response = await apiGet(
          Uri.parse('$Api_url/api/payment/cronjob-payments/$adminId?page=$page&limit=$limit'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });
      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON

        final parsedJson = jsonDecode(response.body);
        final InsuranceResponse = LeaseResponse.fromJson(parsedJson);
        return InsuranceResponse;
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load renters insurance');
      }
    } catch (e) {
      // Handle any other exceptions
      throw Exception('Failed to load renters insurance');
    }
  }
}