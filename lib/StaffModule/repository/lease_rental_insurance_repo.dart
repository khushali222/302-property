import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
import 'package:three_zero_two_property/Model/Renters_Insurnce/Edit_insurnce.dart';
import 'package:three_zero_two_property/Model/lease_renter_insurance.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class RentersInsuranceService {
  /// Fetch renter insurance policies by tenant ID (GET /api/renter-insurance/policies-by-tenant/{tenantId}).
  /// Each policy gets computed [policyStatus]: FUTURE, ACTIVE, or EXPIRED.
  Future<List<lease_renter_insurance>> fetchPoliciesByTenant(
      String tenantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    try {
      final response = await apiGet(
        Uri.parse(
            '$Api_url/api/renter-insurance/policies-by-tenant/$tenantId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );
      if (response.statusCode == 200) {
        final parsed = jsonDecode(response.body);
        if (parsed['statusCode'] == 200 &&
            parsed['data'] != null &&
            parsed['data'] is List) {
          final List<lease_renter_insurance> list = [];
          for (var e in parsed['data'] as List) {
            final p = lease_renter_insurance.fromJson(
                Map<String, dynamic>.from(e as Map));
            p.policyStatus = lease_renter_insurance.computeStatus(
                p.effectiveDate, p.expirationDate);
            list.add(p);
          }
          return list;
        }
        return [];
      }
      return [];
    } catch (e) {
      logError('Error fetching policies by tenant: $e');
      return [];
    }
  }

  Future<List<lease_renter_insurance>> fetchRentersInsurance(
      String leaseid, {bool includeDeleted = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    try {
      final response = await apiGet(
          // Web parity: ?include_deleted=1 asks the server to also return
          // soft-deleted policies ("Show Deleted Policies" toggle).
          Uri.parse('$Api_url/api/renter-insurance/policies/$leaseid'
              '${includeDeleted ? '?include_deleted=1' : ''}'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
          });

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, parse the JSON

        final parsedJson = jsonDecode(response.body);
        List leasesJson = parsedJson['data'];

        try {
          return leasesJson.map((data) {
            return lease_renter_insurance.fromJson(data);
          }).toList();
        } catch (e) {
          logError('Error parsing data: $e');
          logError('Data that caused error: $leasesJson');
          return [];
        }
      } else {
        // If the server did not return a 200 OK response, throw an exception
        throw Exception('Failed to load renters insurance');
      }
    } catch (e) {
      // Handle any other exceptions
      logError('Error fetching data: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> deleteInsurance({
    required String renters_insurance_id,
  }) async {
    try {
      final Uri uri = Uri.parse(
          '$Api_url/api/renter-insurance/delete-policy/$renters_insurance_id');

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminid = prefs.getString('adminId');
      String? id = prefs.getString("staff_id");
      final http.Response response = await apiDelete(
        uri,
        headers: <String, String>{
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({}),
      );

      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: responseData["message"]);
        return json.decode(response.body);
      } else {
        Fluttertoast.showToast(msg: responseData["message"]);
        throw Exception('Failed to delete Insurance');
      }
    } catch (e) {
      throw Exception('Failed to delete Insurance: $e');
    }
  }

  Future<RentersEdit> fetchRentersDetails(String renters_insurance_id,
      {bool includeDeleted = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString('adminId');
    String? id = prefs.getString("staff_id");
    // Web parity: deleted policies are only returned by the detail endpoint
    // when ?include_deleted=1 is passed (the report/list adds it for deleted rows).
    final query = includeDeleted ? '?include_deleted=1' : '';
    final response = await apiGet(
      Uri.parse(
          '${Api_url}/api/renter-insurance/policy/$renters_insurance_id$query'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    ); // Update with your actual API URL
    //print('hello${response.body}');
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // List leasesJson = jsonResponse['data'];
      return RentersEdit.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load rentersdata');
    }
  }
}
