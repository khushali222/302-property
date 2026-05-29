import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/constant.dart';
import 'package:three_zero_two_property/Model/LeaseLedgerModel.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';

class TenantLeaseRepository {
  static Future<Map<String, String>> _headers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final adminId = prefs.getString('adminId');
    return {
      'authorization': 'CRM $token',
      'id': 'CRM $adminId',
    };
  }

  /// Legacy endpoint — all ledger entries for a lease (no tenant filter).
  Future<LeaseLedger?> fetchLeaseLedger(
      {String? fromDate, String? toDate, String? leaseId}) async {
    String url = '$Api_url/api/payment/tenant_ledger/$leaseId';
    if (fromDate != null && toDate != null) {
      url += '?from_date=$fromDate&to_date=$toDate';
    }
    try {
      final response =
          await apiGet(Uri.parse(url), headers: await _headers());
      if (response.statusCode == 200) {
        return LeaseLedger.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      throw Exception('fetchLeaseLedger error: $e');
    }
    return null;
  }

  /// All ledger entries for a lease — no tenant filter.
  /// GET /api/payment/lease_ledger/{leaseId}
  Future<LeaseLedger?> fetchAllLedger({
    required String leaseId,
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    final params = <String, String>{};
    if (fromDate != null && fromDate.isNotEmpty) params['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) params['to_date'] = toDate;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final uri = Uri.parse('$Api_url/api/payment/lease_ledger/$leaseId')
        .replace(queryParameters: params.isEmpty ? null : params);
    try {
      final response = await apiGet(uri, headers: await _headers());
      if (response.statusCode == 200) {
        return LeaseLedger.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      throw Exception('fetchAllLedger error: $e');
    }
    return null;
  }

  /// Ledger entries filtered to one tenant — returns tenantPayments + tenantData.
  /// GET /api/payment/lease_ledger/{leaseId}?tenant_id={tenantId}
  Future<LeaseLedger?> fetchLedgerWithTenant({
    required String leaseId,
    required String tenantId,
    String? fromDate,
    String? toDate,
    String? search,
  }) async {
    final params = <String, String>{'tenant_id': tenantId};
    if (fromDate != null && fromDate.isNotEmpty) params['from_date'] = fromDate;
    if (toDate != null && toDate.isNotEmpty) params['to_date'] = toDate;
    if (search != null && search.isNotEmpty) params['search'] = search;
    final uri = Uri.parse('$Api_url/api/payment/lease_ledger/$leaseId')
        .replace(queryParameters: params);
    try {
      final response = await apiGet(uri, headers: await _headers());
      if (response.statusCode == 200) {
        return LeaseLedger.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      throw Exception('fetchLedgerWithTenant error: $e');
    }
    return null;
  }
}