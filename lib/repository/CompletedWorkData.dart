import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../Model/CompletedWorkOrdersModel.dart';

class CompletedWorkOrderService {
  Future<List<CompletedWorkData>> fetchCompletedWorkOrders({
    String? fromDate,
    String? toDate,
    String? status,
  }) async {
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    String url = '$Api_url/api/work-order/complete-work-orders/$adminId';

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
    print('=== API CALL DEBUG (COMPLETED) ===');
    print('Final URL: $url');
    print('Query Params: $queryParams');
    print('Headers: authorization: CRM $token, id: CRM $adminId');
    print('==================================');

    try {
      final response = await apiGet(Uri.parse(url), headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      });

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        print(parsedJson);
        final completedWorkOrders =
            CompletedWorkOrdersModel.fromJson(parsedJson);
        return completedWorkOrders.data ?? [];
      } else {
        // Handle non-200 responses
        print('Failed to fetch complete workorders: ${response.body}');
        return [];
        // throw Exception(
        //     'Failed to load data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch all exceptions
      print('Error occurred: $e');
      throw Exception('Unexpected error: $e');
    }
  }
}
