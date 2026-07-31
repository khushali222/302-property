import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Model/PropertyInsuranceModel.dart';
import '../constant/constant.dart';

class PropertyInsuranceRepository {
  Future<PropertyInsuranceResponse> fetchPropertyInsuranceSummary(
      String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final String url =
        '$Api_url/api/property-insurance/summary-report/$adminId';

    try {
      final response = await apiGet(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      });

      if (response.statusCode == 200) {
        return PropertyInsuranceResponse.fromJson(json.decode(response.body));
      } else {
        return PropertyInsuranceResponse(
          statusCode: response.statusCode,
          success: false,
        );
      }
    } catch (e) {
      return PropertyInsuranceResponse(
        statusCode: 500,
        success: false,
      );
    }
  }
}
