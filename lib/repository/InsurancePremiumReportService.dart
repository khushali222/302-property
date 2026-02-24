import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/Model/InsurancePremiumReportModel.dart';

class InsurancePremiumReportService {
  // GET API: Fetch available years
  Future<List<String>> fetchInsurancePremiumYears(String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('$Api_url/api/rentals/insurance-premium-years/$adminId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $adminId",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true && jsonData['years'] != null) {
          return List<String>.from(jsonData['years']);
        }
        return [];
      } else {
        throw Exception('Failed to load years: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching insurance premium years: $e');
      throw Exception('Failed to load years: $e');
    }
  }

  // POST API: Fetch insurance premium report data
  Future<InsurancePremiumReportModel> fetchInsurancePremiumReport({
    required String adminId,
    required List<String> years,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    try {
      final response = await http.post(
        Uri.parse('$Api_url/api/rentals/insurance-premium-report'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $adminId",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "admin_id": adminId,
          "years": years,
        }),
      );
      print("insurance premium report ${response.body}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return InsurancePremiumReportModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load report: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching insurance premium report: $e');
      throw Exception('Failed to load report: $e');
    }
  }
}
