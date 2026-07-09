import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/bid_request.dart';
import 'package:three_zero_two_property/constant/constant.dart';

/// Staff module repository for Bid Room (bid requests).
/// Uses same API as main app; kept separate for Staff module structure.
class StaffBidRoomRepository {
  Future<BidRequestResponse> fetchBidRequests({
    String? adminId,
    int limit = 10000,
    int page = 1,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('adminId');
      // Header `id` must be the staff member's OWN id (web parity): the server's
      // verifyToken resolves the staff branch by this header. Sending adminId
      // hits the admin branch and 401s at multi-co-admin companies (CRM-4479).
      // adminId stays in the URL path below (company scope).
      String? staffId = prefs.getString('staff_id');

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
          "id": "CRM $staffId",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return BidRequestResponse.fromJson(jsonData);
      } else {
        // Throw the server's own message (e.g. "User does not exist or is not
        // active."); the screen shows ONE toast. No toast here so a single
        // failure can't stack multiple conflicting toasts (CRM-4163 follow-up).
        final jsonData = json.decode(response.body);
        throw Exception(jsonData['message'] ?? 'Failed to fetch bid requests');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<BidRequestDetailResponse> fetchBidRequestDetails({
    required String bidRequestId,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      // Header `id` must be the staff member's OWN id (web parity) — see note in
      // fetchBidRequests above.
      String? staffId = prefs.getString('staff_id');

      if (staffId == null) {
        throw Exception('Staff ID is required');
      }

      final url = '${Api_url}/api/bid-request/bid-request/$bidRequestId';

      final response = await apiGet(
        Uri.parse(url),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $staffId",
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
      rethrow;
    }
  }
}
