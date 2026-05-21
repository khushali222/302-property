import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/history_item_model.dart';
import '../enums/history_type.dart';
import '../constant/constant.dart';

class HistoryService {
  static Future<HistoryResponse> fetchHistory({
    required HistoryType historyType,
    required String entityId,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminId = prefs.getString("adminId");
      String? staffId = prefs.getString("staff_id");

      // Check if user is staff or admin and use appropriate ID in header
      // If staff_id exists and is not empty, use staff_id, otherwise use adminId
      String? id = (staffId != null && staffId.isNotEmpty) ? staffId : adminId;

      // print('🔵 HistoryService - Fetching history');
      // print('🔵 User Type: ${staffId != null && staffId.isNotEmpty ? "Staff" : "Admin"}');
      // print('🔵 ID used in header: $id');

      // Lease history uses a different endpoint
      String url;
      if (historyType == HistoryType.lease) {
        url = '$Api_url/api/leases/lease_history/$entityId';
      } else {
        url =
            '$Api_url/api/history/${historyType.apiPath}/$entityId?page=$page&limit=$limit&_t=${DateTime.now().millisecondsSinceEpoch}';
      }

      // print('🔵 URL: $url');
      // print('🔵 HistoryType: $historyType, API Path: ${historyType.apiPath}');
      // print('🔵 EntityId: $entityId');
      // print('🔵 Page: $page, Limit: $limit');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      // print('🔵 HistoryService - Response Status: ${response.statusCode}');
      // print('🔵 HistoryService - Response Body Length: ${response.body.length}');

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        // print('🔵 HistoryService - JSON decoded successfully');
        // print('🔵 HistoryService - Data array length: ${jsonData['data']?.length ?? 0}');

        // Check if this is frontend pagination (data length > limit) or backend pagination
        final dataLength = jsonData['data']?.length ?? 0;
        final isFrontendPagination =
            historyType == HistoryType.lease || dataLength > limit;

        // print('🔵 HistoryService - Is Frontend Pagination: $isFrontendPagination');

        final historyResponse = HistoryResponse.fromJson(
          jsonData,
          isLeaseHistory: historyType == HistoryType.lease,
          isFrontendPagination: isFrontendPagination,
          currentPage: page,
          itemsPerPage: limit,
        );
        // print('🔵 HistoryService - Parsed ${historyResponse.data.length} history items');
        // print('🔵 HistoryService - Pagination: Total=${historyResponse.pagination.total}, Pages=${historyResponse.pagination.totalPages}');
        return historyResponse;
      } else {
        // print('🔴 HistoryService - Error Status: ${response.statusCode}');
        // print('🔴 HistoryService - Error Body: ${response.body}');
        throw Exception('Failed to load history: ${response.statusCode}');
      }
    } catch (e) {
      // print('Error fetching history: $e');
      throw Exception('Error fetching history: $e');
    }
  }
}
