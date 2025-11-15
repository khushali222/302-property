import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/constant.dart';
import '../../model/LeaseLedgerModel.dart';
import 'package:http/http.dart' as http;
class TenantLeaseRepository {

  String baseUrl = '$Api_url/api/payment/tenant_ledger';
  Future<LeaseLedger?> fetchLeaseLedger(
      {String? fromDate, String? toDate,String? leaseId}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    String url = '$baseUrl/$leaseId';
    if (fromDate != null && toDate != null) {
      url += '?from_date=$fromDate&to_date=$toDate';
    }
    print(' lease url $url');
    try {
      print('entry');
      final response = await http.get(Uri.parse(url), headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      });

      if (response.statusCode == 200) {
        print('response.body ${response.body}');
        final parsedJson = jsonDecode(response.body);
        print('parsedJson: $parsedJson');
        final report = LeaseLedger.fromJson(parsedJson);
        print('parsed ReportExpiringLeaseTable: ${report.data}');
        return report;
      } else {

      }
    } on http.ClientException {

    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}