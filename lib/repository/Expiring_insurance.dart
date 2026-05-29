import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/Expiring_insurance_model.dart';
import 'package:three_zero_two_property/Model/ReportExpiringLease.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class ExpiringInsuranceTableService {
  String baseUrl = '$Api_url/api/renter-insurance/expiring-policies';

  Future<List<RentersInsuranceData>> fetchExpiringInsurnce(
      {String? startDate, String? endDate}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    String url = '$baseUrl';
    if (startDate != null && endDate != null) {
      url += '?start_date=$startDate&end_date=$endDate';
    }

    try {
      print('entry');
      final response = await apiGet(Uri.parse(url), headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      });
   print(url);
   print('abc ${response.body}');
      if (response.statusCode == 200) {
        print('response.body ${response.body}');
        final parsedJson = jsonDecode(response.body);
        print('parsedJson: $parsedJson');
        final report = RentersInsuranceResponse.fromJson(parsedJson);
        print('parsed ReportExpiringLeaseTable: ${report.data}');
        return report.data ?? [];
      } else {
        throw ServerException(response.statusCode,
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } on http.ClientException {
      throw NetworkException(
          'Failed to connect to the server. Please check your internet connection.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class ServerException implements Exception {
  final int statusCode;
  final String message;
  ServerException(this.statusCode, this.message);
}
