import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Model/LivePropertyModel.dart';
import '../constant/constant.dart';

class LivePropertyRepository {
  Future<LivePropertyResponse> fetchLivePropertyReport(String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    final String url = '$Api_url/api/mortgage/report/$adminId';
    print(url);

    try {
      final response = await apiGet(Uri.parse(url), headers: {
        'Content-Type': 'application/json',
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      });
      print(response.body);
      if (response.statusCode == 200) {
        return LivePropertyResponse.fromJson(json.decode(response.body));
      } else {
        return LivePropertyResponse(
          statusCode: response.statusCode,
          message: "Failed to load live property report: ${response.body}",
        );
      }
    } catch (e) {
      return LivePropertyResponse(
        statusCode: 500,
        message: "Error fetching live property report: $e",
      );
    }
  }
}
