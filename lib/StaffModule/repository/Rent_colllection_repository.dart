import 'dart:convert';

import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Model/Rent_collection_model.dart';
import '../../constant/constant.dart';

class RentColllectionReport {
  final String baseUrl = '$Api_url/api/rental_owner/rent-collection-report';

  /// Staff must send their OWN id in the `id` header (staff_id / userId).
  /// Admin sends adminId. Sending adminId as Staff 401s (CRM-4479).
  String? _actingId(SharedPreferences prefs) {
    final role = prefs.getString('role');
    if (role == 'Staffmember') {
      final staffId = prefs.getString('staff_id');
      if (staffId != null && staffId.isNotEmpty) return staffId;
      final userId = prefs.getString('userId');
      if (userId != null && userId.isNotEmpty) return userId;
    }
    return prefs.getString('adminId');
  }

  Future<Rentcollection_model> FetchRentColllection(
      String adminId, String selectedmonth, String selectedyear,
      {String? chargetype}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    final String? authId = _actingId(prefs);
    final String effectiveAdminId =
        adminId.isNotEmpty ? adminId : (prefs.getString('adminId') ?? '');

    // URL path = company scope (adminId). Header `id` = logged-in user's own id.
    final String endpoint = '/$effectiveAdminId';
    String url = '$baseUrl$endpoint?month=$selectedmonth&year=$selectedyear';

    if (chargetype != null) {
      url = '$url&selectedChargeType=$chargetype';
    }

    print('[RentCollection][StaffRepo] role=${prefs.getString('role')} '
        'authIdLen=${authId?.length ?? 0} pathAdminIdLen=${effectiveAdminId.length}');
    print(url);

    try {
      final response = await apiGet(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $authId",
        },
      );
      print("report rent collection ${response.body}");

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        print("=== STAFF MODULE - FULL API JSON RESPONSE ===");
        print(parsedJson);

        if (parsedJson['summary'] != null) {
          print("=== STAFF MODULE - SUMMARY ORDER FROM JSON ===");
          List summaryList = parsedJson['summary'];
          for (int i = 0; i < summaryList.length; i++) {
            print(
                "$i: ${summaryList[i]['rentalOwnerCompany']} - \$${summaryList[i]['totalPending']}");
          }
        }

        return Rentcollection_model.fromJson(parsedJson);
      } else {
        print(
            '[RentCollection][StaffRepo] failed status=${response.statusCode} body=${response.body}');
        throw Exception('Failed to load rent collection report');
      }
    } catch (error) {
      print('[RentCollection][StaffRepo] error: $error');
      throw Exception('Failed to load rent collection');
    }
  }
}
