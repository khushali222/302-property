import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';


import '../../../Model/LeaseLedgerModel.dart';
import '../../../constant/constant.dart';

import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
class TenantLeaseRepository {

  String baseUrl = '$Api_url/api/payment/tenant_ledger';
  Future<LeaseLedger?> fetchLeaseLedger(
      {String? fromDate, String? toDate,String? leaseId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    String url = '$baseUrl/$leaseId';
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
        final report = LeaseLedger.fromJson(parsedJson);
        return report;
      } else {

      }
    } on http.ClientException {

    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}