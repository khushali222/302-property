import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../Model/bid_request.dart';
import '../../constant/constant.dart';

class VendorBidRepository {
  Future<BidRequestResponse> fetchVendorBidRequests({
    required String vendorId,
    int limit = 10000,
    int page = 1,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    String? status,
  }) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      // For vendor requests, we typically use the vendorId.
      // The API endpoint is: /api/bid-request/bid-requests/vendor/:vendorId

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      };
      if (status != null && status.isNotEmpty && status != 'All') {
        queryParams['status'] = status;
      }

      final url = Uri.parse(
              '${Api_url}/api/bid-request/bid-requests/vendor/$vendorId')
          .replace(queryParameters: queryParams)
          .toString();

      print('Fetching vendor bid requests from: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: <String, String>{
          "authorization": "CRM $token",
          "id":
              "CRM $vendorId", // Assuming the header requires the ID of the requester
        },
      );

      print('Vendor bid requests response status: ${response.statusCode}');
      // print('Vendor bid requests response body: ${response.body}');

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
      print('Error fetching vendor bid requests: $e');
      Fluttertoast.showToast(msg: 'Error fetching bid requests: $e');
      rethrow;
    }
  }

  // If needed, we can also add fetchBidRequestDetails here,
  // reusing the existing endpoint if it's accessible to vendors
  // or a specific vendor details endpoint if it exists.
  // For now, assuming the public/common details endpoint works.
}
