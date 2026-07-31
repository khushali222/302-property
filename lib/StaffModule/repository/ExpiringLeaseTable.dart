import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/ReportExpiringLease.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class ExpiringLeaseTableService {
  String baseUrl = '$Api_url/api/leases/expire';

  Future<List<ReportExpiringLeaseData>> fetchExpiringLeases(
      {String? fromDate, String? toDate}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    String url = '$baseUrl/$adminid';
    if (fromDate != null && toDate != null) {
      url += '?from_date=$fromDate&to_date=$toDate';
    }

    try {
      final response = await apiGet(Uri.parse(url), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        final report = ReportExpiringLeaseTable.fromJson(parsedJson);
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
