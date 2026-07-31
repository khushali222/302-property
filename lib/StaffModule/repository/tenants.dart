import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Model/tenants.dart';
import '../../../constant/constant.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';

class TenantsPagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  const TenantsPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });
}

class TenantsV2ListResult {
  final Map<String, List<Tenant>> categorized;
  final Map<String, int> counts;
  final TenantsPagination? pagination;

  TenantsV2ListResult({
    required this.categorized,
    required this.counts,
    this.pagination,
  });
}

int _tenantJsonInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return fallback;
}

class TenantsRepository {
  final String apiUrl = '${Api_url}/api//tenant/tenants';

  /// Parses v2 list response: unified [data.tenants] + [is_current_tenant], or legacy
  /// [currentTenants] / [formerTenants] arrays.
  Map<String, List<Tenant>> _categorizedTenantsFromV2Data(
      Map<String, dynamic>? data) {
    final categorizedTenants = <String, List<Tenant>>{
      'currentTenants': [],
      'formerTenants': [],
      'currentApplicants': [],
    };
    if (data == null) return categorizedTenants;

    final tenantsRaw = data['tenants'];
    if (tenantsRaw is List && tenantsRaw.isNotEmpty) {
      for (final item in tenantsRaw) {
        if (item is! Map<String, dynamic>) continue;
        final t = Tenant.fromJson(item);
        if (item['is_current_tenant'] == true) {
          categorizedTenants['currentTenants']!.add(t);
        } else {
          categorizedTenants['formerTenants']!.add(t);
        }
      }
    } else {
      if (data['currentTenants'] != null) {
        final list = data['currentTenants'] as List;
        categorizedTenants['currentTenants'] =
            list.map((e) => Tenant.fromJson(e as Map<String, dynamic>)).toList();
      }
      if (data['formerTenants'] != null) {
        final list = data['formerTenants'] as List;
        categorizedTenants['formerTenants'] =
            list.map((e) => Tenant.fromJson(e as Map<String, dynamic>)).toList();
      }
    }

    if (data['currentApplicants'] != null) {
      final list = data['currentApplicants'] as List;
      categorizedTenants['currentApplicants'] =
          list.map((e) => Tenant.fromJson(e as Map<String, dynamic>)).toList();
    }

    return categorizedTenants;
  }

  Map<String, int> _countsFromV2Data(Map<String, dynamic>? dataMap) {
    final counts = <String, int>{};
    if (dataMap == null) return counts;
    final raw = dataMap['counts'];
    if (raw is! Map) return counts;
    final m = Map<String, dynamic>.from(raw);
    counts['currentCount'] = _tenantJsonInt(m['currentCount']);
    counts['formerCount'] = _tenantJsonInt(m['formerCount']);
    counts['applicantCount'] = _tenantJsonInt(m['applicantCount']);
    return counts;
  }

  TenantsPagination? _paginationFromRoot(
      Map<String, dynamic> jsonResponse, int limitFallback) {
    final pRaw = jsonResponse['pagination'];
    if (pRaw is! Map<String, dynamic>) return null;
    return TenantsPagination(
      currentPage: _tenantJsonInt(pRaw['currentPage'], 1),
      totalPages: _tenantJsonInt(pRaw['totalPages'], 1).clamp(1, 1 << 30),
      totalItems: _tenantJsonInt(pRaw['totalItems']),
      itemsPerPage: _tenantJsonInt(pRaw['itemsPerPage'], limitFallback),
    );
  }

  Future<List<Tenant>> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await apiGet(
      Uri.parse('${Api_url}/api/tenant/tenants/$adminid'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    // if (response.statusCode == 200) {
    //   List jsonResponse = json.decode(response.body)['data'];
    //   return jsonResponse.map((data) => Tenant.fromJson(data)).toList();
    // } else {
    //   print('Failed to fetch tenants: ${response.body}');
    //   return [];
    //  // throw Exception('Failed to load data');
    // }
    if (response.statusCode == 200) {
      // Decode the JSON response
      final jsonResponse = json.decode(response.body);

      // Access the 'data' object and then the 'tenants' list
      if (jsonResponse['data'] != null &&
          jsonResponse['data']['tenants'] != null) {
        List tenantsJson =
            jsonResponse['data']['tenants']; // Access the tenants list
        return tenantsJson
            .map((data) => Tenant.fromJson(data))
            .toList(); // Map to Tenant objects
      } else {
        return [];
      }
    } else {
      return [];
    }
  }

  /// Paginated v2 list (same query shape as web).
  Future<TenantsV2ListResult> fetchTenantsV2Page({
    required int page,
    required int limit,
    String search = '',
    String tenantType = 'current',
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final uri =
        Uri.parse('${Api_url}/api/tenant/tenants/v2/$adminid').replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        'search': search,
        'tenantType': tenantType,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      },
    );
    final response = await apiGet(
      uri,
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    final empty = TenantsV2ListResult(
      categorized: {
        'currentTenants': [],
        'formerTenants': [],
        'currentApplicants': [],
      },
      counts: {},
      pagination: null,
    );
    if (response.statusCode != 200) {
      return empty;
    }
    final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    final dataMap = jsonResponse['data'];
    if (dataMap is! Map<String, dynamic>) return empty;
    final categorized = _categorizedTenantsFromV2Data(dataMap);
    final counts = _countsFromV2Data(dataMap);
    final pagination = _paginationFromRoot(jsonResponse, limit);
    return TenantsV2ListResult(
      categorized: categorized,
      counts: counts,
      pagination: pagination,
    );
  }

  // New method to fetch categorized tenants (current, former, applicants)
  Future<Map<String, List<Tenant>>> fetchTenantsV2() async {
    final r = await fetchTenantsV2Page(
      page: 1,
      limit: 5000,
      search: '',
      tenantType: 'all',
      sortBy: 'createdAt',
      sortOrder: 'desc',
    );
    return r.categorized;
  }

  Future<List<Tenant>> fetchLeaseTenants(String tenantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await apiGet(
      Uri.parse('${Api_url}/api/tenant/tenants/$tenantId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => Tenant.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  // Web-aligned Add Tenant (Staff). Takes a ready-made body mirroring the web
  // POST /tenant/tenants payload, instead of Tenant.toJson(). The legacy
  // addTenant(Tenant) below is left untouched for other callers.
  Future<bool> addTenantPayload(Map<String, dynamic> body) async {
    final url = Uri.parse('${Api_url}/api/tenant/tenants');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    try {
      final response = await apiPost(
        url,
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
        body: jsonEncode(body),
      );

      var responseData = jsonDecode(response.body);
      // [EC-DEBUG] Temporary diagnostic (remove later) — did the server stamp a
      // contact_id on each emergency contact? NO_ID => server did NOT stamp it.
      final ecResp = responseData['data']?['emergency_contacts'];

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['statusCode'] == 200) {
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Successfully added tenant');
          return true;
        } else {
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to add tenant');
          return false;
        }
      } else {
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Failed to add tenant');
        return false;
      }
    } catch (error) {
      logError('Exception occurred: $error');
      Fluttertoast.showToast(msg: 'An error occurred');
      return false;
    }
  }

  // Web-aligned Account & Login action (Staff): send account-setup /
  // resend / reset-password email. Server picks the template.
  Future<bool> sendSetupEmail(String tenantId) async {
    final url =
        Uri.parse('${Api_url}/api/tenant/tenants/$tenantId/send-setup-email');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    try {
      final response = await apiPost(
        url,
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
        body: jsonEncode({}),
      );
      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['statusCode'] == 200) {
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Email sent successfully.');
        return true;
      } else {
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Failed to send email');
        return false;
      }
    } catch (error) {
      logError('sendSetupEmail error: $error');
      Fluttertoast.showToast(msg: 'An error occurred');
      return false;
    }
  }

  // Web parity (TenantsTable.js): toggle a tenant's 2FA from the row actions.
  // Enable posts method "email"; the flag takes effect on the tenant's next
  // login. Disable sends user_type + user_id only, matching the web body.
  Future<bool> setTenant2FA({
    required String tenantId,
    required bool enable,
    String? email,
    String? phoneNumber,
  }) async {
    final url = Uri.parse(
        '${Api_url}/api/2fa/${enable ? "admin-enable-2fa" : "admin-disable-2fa"}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    try {
      final response = await apiPost(
        url,
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
        body: jsonEncode(enable
            ? {
                'user_type': 'tenant',
                'user_id': tenantId,
                'method': 'email',
                'email': email,
                'phone_number': phoneNumber,
              }
            : {
                'user_type': 'tenant',
                'user_id': tenantId,
              }),
      );
      var responseData = jsonDecode(response.body);
      if (response.statusCode == 200 && responseData['statusCode'] == 200) {
        Fluttertoast.showToast(
            msg:
                '2FA ${enable ? "enabled" : "disabled"} successfully for tenant');
        return true;
      } else {
        Fluttertoast.showToast(
            msg: responseData['message'] ??
                'Failed to ${enable ? "enable" : "disable"} 2FA');
        return false;
      }
    } catch (error) {
      logError('setTenant2FA error: $error');
      Fluttertoast.showToast(msg: 'An error occurred');
      return false;
    }
  }

  Future<bool> addTenant(Tenant tenant) async {
    final url = Uri.parse('${Api_url}/api/tenant/tenants');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    try {
      final response = await apiPost(
        url,
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
        body: jsonEncode(tenant.toJson()),
      );

      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['statusCode'] == 200) {
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Successfully added tenant');

          return true;
        } else {
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to add tenant');
          return false;
        }
      } else {
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Failed to add tenant');
        return false;
      }
    } catch (error) {
      logError('Exception occurred: $error');
      Fluttertoast.showToast(msg: 'An error occurred');
      return false;
    }
  }

  // Future<Map<String, dynamic>>
  // editTenant(
  //     {
  //   required String tenantId,
  //   required String adminId,
  //   required String tenantFirstName,
  //   required String tenantLastName,
  //   required String tenantPhoneNumber,
  //   required String tenantAlternativeNumber,
  //   required String tenantEmail,
  //   required String tenantAlternativeEmail,
  //   required String tenantPassword,
  //   required String tenantBirthDate,
  //   required String taxPayerId,
  //   required String comments,
  //   required String emergencyContactName,
  //   required String emergencyContactRelation,
  //   required String emergencyContactEmail,
  //   required String emergencyContactPhoneNumber,
  // }) async {
  //   // Data to be sent in the PUT request
  //   final Map<String, dynamic> data = {
  //     'admin_id': adminId,
  //     'tenant_firstName': tenantFirstName,
  //     'tenant_lastName': tenantLastName,
  //     'tenant_phoneNumber': tenantPhoneNumber,
  //     'tenant_alternativeNumber': tenantAlternativeNumber,
  //     'tenant_email': tenantEmail,
  //     'tenant_alternativeEmail': tenantAlternativeEmail,
  //     'tenant_password': tenantPassword,
  //     'tenant_birthDate': tenantBirthDate,
  //     'taxPayer_id': taxPayerId,
  //     'comments': comments,
  //     'emergency_contact': {
  //       'name': emergencyContactName,
  //       'relation': emergencyContactRelation,
  //       'email': emergencyContactEmail,
  //       'phoneNumber': emergencyContactPhoneNumber,
  //     },
  //   };
  //
  //   // Printing the URL for debugging
  //
  //   print('$apiUrl/$tenantId');
  //
  //   // Making the PUT request
  //
  //   final http.Response response = await apiPut(
  //     Uri.parse('$apiUrl/$tenantId'),
  //     headers: <String, String>{
  //       'Content-Type': 'application/json; charset=UTF-8',
  //     },
  //     body: jsonEncode(data),
  //   );
  //
  //   // Decoding the response
  //   var responseData = json.decode(response.body);
  //
  //   // Debugging the response
  //   print(response.body);
  //    print(responseData);
  //   // Handling the response
  //   if (responseData["statusCode"] == 200) {
  //     // Showing success toast
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     return responseData; // returning the parsed response
  //   } else {
  //     // Showing failure toast
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     throw Exception('Failed to update tenant');
  //   }
  // }
  // Future<Map<String, dynamic>> editTenant({
  //   required String tenantId,
  //   required String adminId,
  //   required String tenantFirstName,
  //   required String tenantLastName,
  //   required String tenantPhoneNumber,
  //   required String tenantAlternativeNumber,
  //   required String tenantEmail,
  //   required String tenantAlternativeEmail,
  //   required String tenantPassword,
  //   required String tenantBirthDate,
  //   required String taxPayerId,
  //   required String comments,
  //   required String emergencyContactName,
  //   required String emergencyContactRelation,
  //   required String emergencyContactEmail,
  //   required String emergencyContactPhoneNumber,
  // }) async {
  //   final Map<String, dynamic> data = {
  //     'admin_id': adminId,
  //     'tenant_firstName': tenantFirstName,
  //     'tenant_lastName': tenantLastName,
  //     'tenant_phoneNumber': tenantPhoneNumber,
  //     'tenant_alternativeNumber': tenantAlternativeNumber,
  //     'tenant_email': tenantEmail,
  //     'tenant_alternativeEmail': tenantAlternativeEmail,
  //     'tenant_password': tenantPassword,
  //     'tenant_birthDate': tenantBirthDate,
  //     'taxPayer_id': taxPayerId,
  //     'comments': comments,
  //     'emergency_contact': {
  //       'name': emergencyContactName,
  //       'relation': emergencyContactRelation,
  //       'email': emergencyContactEmail,
  //       'phoneNumber': emergencyContactPhoneNumber,
  //     },
  //   };
  //
  //   print('$apiUrl/$tenantId');
  //
  //   try {
  //     final http.Response response = await apiPut(
  //       Uri.parse('$apiUrl/$tenantId'),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(data),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       var responseData = json.decode(response.body);
  //       Fluttertoast.showToast(msg: responseData["message"]);
  //       return responseData;
  //     } else {
  //       // Print the response body if the status code is not 200
  //       print('Failed response: ${response.body}');
  //       Fluttertoast.showToast(msg: 'Failed to update tenant. Please try again.');
  //       throw Exception('Failed to update tenant');
  //     }
  //   } catch (e) {
  //     // Catch and print any errors that occur
  //     print('Error: $e');
  //     Fluttertoast.showToast(msg: 'An error occurred. Please try again.');
  //     throw Exception('Failed to update tenant');
  //   }
  // }
  // Web-aligned Edit Tenant (Staff). Takes a ready-made body mirroring the
  // web PUT /tenant/tenants/:id payload. The legacy editTenant(...) below is
  // left untouched for other callers.
  Future<bool> editTenantPayload(
      String tenantId, Map<String, dynamic> body) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('staff_id');
    final http.Response response = await apiPut(
      Uri.parse('$Api_url/api/tenant/tenants/$tenantId'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(body),
    );
    var responseData = json.decode(response.body);
    // [EC-DEBUG] Temporary diagnostic (remove later) — did the server stamp a
    // contact_id on each emergency contact? NO_ID => server did NOT stamp it.
    final ecResp = responseData['data']?['emergency_contacts'];
    if (responseData["statusCode"] == 200) {
      return true;
    } else {
      Fluttertoast.showToast(
          msg: responseData["message"] ?? 'Failed to update tenant');
      return false;
    }
  }

  Future<Map<String, dynamic>> editTenant({
    required String tenantId,
    required String adminId,
    required String tenantFirstName,
    required String tenantLastName,
    required String tenantPhoneNumber,
    required String tenantAlternativeNumber,
    required String tenantEmail,
    required String tenantAlternativeEmail,
    required String tenantPassword,
    String? tenantBirthDate,
    required String taxPayerId,
    required String comments,
    required String emergencyContactName,
    required String emergencyContactRelation,
    required String emergencyContactEmail,
    required String emergencyContactPhoneNumber,
    required String companyName,
    required String overRideFee,
    required String enableOverRideFee,
    required bool allowAch,
    required bool allowCard,
    bool showSuccessToast = true,
  }) async {
    final Map<String, dynamic> data = {
      'admin_id': adminId,
      'tenant_id': tenantId,
      'tenant_firstName': tenantFirstName,
      'tenant_lastName': tenantLastName,
      'tenant_phoneNumber': tenantPhoneNumber,
      'tenant_alternativeNumber': tenantAlternativeNumber,
      'tenant_email': tenantEmail,
      'tenant_alternativeEmail': tenantAlternativeEmail,
      'tenant_password': tenantPassword,
      'tenant_birthDate': tenantBirthDate,
      'taxPayer_id': taxPayerId,
      'comments': comments,
      'emergency_contact': {
        'name': emergencyContactName,
        'relation': emergencyContactRelation,
        'email': emergencyContactEmail,
        'phoneNumber': emergencyContactPhoneNumber,
      },
      'override_fee': overRideFee,
      'enable_override_fee': enableOverRideFee,
      'allow_ach': allowAch,
      'allow_card': allowCard,
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    final http.Response response = await apiPut(
      Uri.parse('$Api_url/api/tenant/tenants/$tenantId'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    var responseData = json.decode(response.body);
    if (responseData["statusCode"] == 200) {
      if (showSuccessToast) {
        Fluttertoast.showToast(msg: responseData["message"]);
      }
      return json.decode(response.body);
    } else if (responseData["statusCode"] == 201) {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Email already exists');
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to edit property type');
    }
  }

  /// PUT `/api/tenant/tenants/:id` using current [tenant] fields and updated payment flags.
  Future<Map<String, dynamic>> editTenantFromModel(
    Tenant tenant, {
    required bool allowAch,
    required bool allowCard,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final resolvedAdminId = (tenant.adminId ?? '').isNotEmpty
        ? tenant.adminId!
        : (prefs.getString('adminId') ?? '');
    final ec = tenant.emergencyContact;
    return editTenant(
      tenantId: tenant.tenantId ?? '',
      adminId: resolvedAdminId,
      tenantFirstName: tenant.tenantFirstName ?? '',
      tenantLastName: tenant.tenantLastName ?? '',
      tenantPhoneNumber: tenant.tenantPhoneNumber ?? '',
      tenantAlternativeNumber: tenant.tenantAlternativeNumber ?? '',
      tenantEmail: tenant.tenantEmail ?? '',
      tenantAlternativeEmail: tenant.tenantAlternativeEmail ?? '',
      tenantPassword: tenant.tenantPassword?.toString() ?? '',
      tenantBirthDate: tenant.tenantBirthDate,
      taxPayerId: tenant.taxPayerId ?? '',
      comments: tenant.comments ?? '',
      emergencyContactName: ec?.name ?? '',
      emergencyContactRelation: ec?.relation ?? '',
      emergencyContactEmail: ec?.email ?? '',
      emergencyContactPhoneNumber: ec?.phoneNumber ?? '',
      companyName: '',
      overRideFee: tenant.overRideFee?.toString() ?? '',
      enableOverRideFee: (tenant.enableoverrideFee == true).toString(),
      allowAch: allowAch,
      allowCard: allowCard,
      showSuccessToast: false,
    );
  }

  Future<Map<String, dynamic>> deleteTenant(
      {required String tenantId,
      required String companyName,
      required String tenantEmail,
      String? reason}) async {
    try {
      final Uri uri = Uri.parse('$Api_url/api/tenant/tenant/$tenantId')
          .replace(queryParameters: {
        'company_name': companyName,
        'tenant_email': tenantEmail,
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminid = prefs.getString("adminId");
      String? id = prefs.getString("staff_id");
      final http.Response response = await apiDelete(uri,
          headers: <String, String>{
            "authorization": "CRM $token",
            "id": "CRM $id",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({"reason": reason}));

      var responseData = json.decode(response.body);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: responseData["message"]);
        return json.decode(response.body);
      } else {
        Fluttertoast.showToast(msg: responseData["message"]);
        throw Exception('Failed to delete tenant');
      }
    } catch (e) {
      throw Exception('Failed to delete tenant: $e');
    }
  }

  Future<List<Tenant>>? fetchTenantsummery(String tenantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    final response = await apiGet(
      Uri.parse('$Api_url/api/tenant/tenant_details/$tenantId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)["data"];

      return jsonResponse.map((data) => Tenant.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load tenant');
    }
  }

  /// POST: Add new emergency contact to emergency_contacts array.
  Future<bool> addEmergencyContact(
    String tenantId, {
    required String name,
    required String relation,
    required String email,
    required String phoneNumber,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("staff_id");
    final response = await apiPost(
      Uri.parse('$Api_url/api/tenant/tenants/$tenantId/emergency-contacts'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        "Content-Type": "application/json",
      },
      body: json.encode({
        'name': name.trim().isEmpty ? '' : name.trim(),
        'relation': relation.trim().isEmpty ? '' : relation.trim(),
        'email': email.trim().isEmpty ? '' : email.trim(),
        'phoneNumber': phoneNumber.trim().isEmpty ? '' : phoneNumber.trim(),
      }),
    );
    if (response.statusCode == 200) return true;
    throw Exception('Failed to add emergency contact: ${response.body}');
  }

  /// PUT: Update the single emergency_contact (primary).
  Future<bool> updateEmergencyContactPrimary(
    String tenantId, {
    required String name,
    required String relation,
    required String email,
    required String phoneNumber,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("staff_id");
    final response = await apiPut(
      Uri.parse('$Api_url/api/tenant/tenants/$tenantId/emergency-contact'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        "Content-Type": "application/json",
      },
      body: json.encode({
        'name': name.trim().isEmpty ? '' : name.trim(),
        'relation': relation.trim().isEmpty ? '' : relation.trim(),
        'email': email.trim().isEmpty ? '' : email.trim(),
        'phoneNumber': phoneNumber.trim().isEmpty ? '' : phoneNumber.trim(),
      }),
    );
    if (response.statusCode == 200) return true;
    throw Exception('Failed to update emergency contact: ${response.body}');
  }

  /// PUT: Update one item in emergency_contacts by contact_id.
  Future<bool> updateEmergencyContact(
    String tenantId,
    String contactId, {
    required String name,
    required String relation,
    required String email,
    required String phoneNumber,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("staff_id");
    final response = await apiPut(
      Uri.parse(
          '$Api_url/api/tenant/tenants/$tenantId/emergency-contacts/$contactId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
        "Content-Type": "application/json",
      },
      body: json.encode({
        'name': name.trim().isEmpty ? '' : name.trim(),
        'relation': relation.trim().isEmpty ? '' : relation.trim(),
        'email': email.trim().isEmpty ? '' : email.trim(),
        'phoneNumber': phoneNumber.trim().isEmpty ? '' : phoneNumber.trim(),
      }),
    );
    if (response.statusCode == 200) return true;
    throw Exception('Failed to update emergency contact: ${response.body}');
  }

  /// DELETE: Remove emergency contact from emergency_contacts (only for non-primary).
  Future<bool> deleteEmergencyContact(String tenantId, String contactId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("staff_id");
    final response = await apiDelete(
      Uri.parse(
          '$Api_url/api/tenant/tenants/$tenantId/emergency-contacts/$contactId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    if (response.statusCode == 200) return true;
    throw Exception('Failed to delete emergency contact: ${response.body}');
  }

  Future<String> fetchCompanyName(String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    final String apiUrl = '$Api_url/api/admin/admin_profile/$adminId';

    try {
      final http.Response response = await apiGet(
        Uri.parse(apiUrl),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        // Check if company_name exists in response and is not null
        if (data.containsKey('data') &&
            data['data'] != null &&
            data['data']['company_name'] != null) {
          return data['data']['company_name'].toString();
        } else {
          throw Exception('Company name not found in response');
        }
      } else {
        throw Exception(
            'Failed to fetch company name. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch company name: $e');
    }
  }
}
