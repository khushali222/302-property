import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../Model/OpenWorkOrderReportModel.dart';

class OpenWorkOrderService {
  final String baseUrl = '$Api_url/api/work-order/open-work-orders';

  Future<List<WorkOrderReportData>> fetchOpenWorkOrders({
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    String url = '$baseUrl/$adminId';

    // Add query parameters if provided
    Map<String, String> queryParams = {};
    if (fromDate != null) queryParams['selectedDate'] = fromDate;
    if (toDate != null) queryParams['selectedToDate'] = toDate;
    if (status != null) queryParams['status'] = status;
    queryParams['caseInsensitive'] = 'true';

    if (queryParams.isNotEmpty) {
      url += '?' +
          queryParams.entries
              .map((e) =>
                  '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
              .join('&');
    }

    // Print the final API URL for debugging

    try {
      final response = await apiGet(Uri.parse(url), headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      });

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        final report = OpenWorkOrderReportModel.fromJson(parsedJson);
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

class ServerException implements Exception {
  final int statusCode;
  final String message;

  ServerException(this.statusCode, this.message);

  @override
  String toString() => 'ServerException: $message (status code: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}
