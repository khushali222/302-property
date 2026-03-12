import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

      String? finalAdminId = adminId ?? id;
      if (finalAdminId == null) {
        throw Exception('Admin ID is required');
      }

      final url =
          '${Api_url}/api/bid-request/bid-requests/$finalAdminId?limit=$limit&page=$page';

      final response = await http.get(
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
        final jsonData = json.decode(response.body);
        Fluttertoast.showToast(
            msg: jsonData['message'] ?? 'Failed to fetch bid requests');
        throw Exception('Failed to fetch bid requests: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching bid requests: $e');
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

      final response = await http.get(
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
        Fluttertoast.showToast(
            msg: jsonData['message'] ?? 'Failed to fetch bid request details');
        throw Exception(
            'Failed to fetch bid request details: ${response.statusCode}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error fetching bid request details: $e');
      rethrow;
    }
  }
}
