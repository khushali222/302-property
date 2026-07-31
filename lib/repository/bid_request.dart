import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/bid_request.dart';
import '../constant/constant.dart';

class BidRequestRepository {
  Future<BidRequestResponse> fetchBidRequests({
    String? adminId,
    int limit = 10000,
    int page = 1,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('adminId');

      // Use provided adminId or fallback to stored adminId
      String? finalAdminId = adminId ?? id;

      if (finalAdminId == null) {
        throw Exception('Admin ID is required');
      }

      final url =
          '${Api_url}/api/bid-request/bid-requests/$finalAdminId?limit=$limit&page=$page';


      final response = await apiGet(
        Uri.parse(url),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $finalAdminId",
        },
      );


      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return BidRequestResponse.fromJson(jsonData);
      } else {
        // Throw the server's own message; the screen shows a single toast so a
        // single failure can't stack multiple conflicting toasts (CRM-4163).
        final jsonData = json.decode(response.body);
        throw Exception(jsonData['message'] ?? 'Failed to fetch bid requests');
      }
    } catch (e) {
      logError('Error fetching bid requests: $e');
      rethrow;
    }
  }

  Future<BidRequestDetailResponse> fetchBidRequestDetails({
    required String bidRequestId,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('adminId');

      if (id == null) {
        throw Exception('Admin ID is required');
      }

      final url = '${Api_url}/api/bid-request/bid-request/$bidRequestId';


      final response = await apiGet(
        Uri.parse(url),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );


      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return BidRequestDetailResponse.fromJson(jsonData);
      } else {
        final jsonData = json.decode(response.body);
        throw Exception(
            jsonData['message'] ?? 'Failed to fetch bid request details');
      }
    } catch (e) {
      logError('Error fetching bid request details: $e');
      rethrow;
    }
  }
}

