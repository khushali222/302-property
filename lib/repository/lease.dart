import 'dart:convert';
import 'dart:developer';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/constant.dart';
import '../model/EnterChargeModel.dart';
import '../model/LeaseLedgerModel.dart';
import '../model/LeaseSummary.dart';
import '../model/edit_lease.dart';
import '../model/get_lease.dart';
import '../model/lease.dart';
import '../model/LeaseChargesModel.dart';
import 'ExpiringLeaseTable.dart';

class LeasesPagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  const LeasesPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });
}

class LeasesPageResult {
  final List<Lease1> items;
  final LeasesPagination? pagination;

  LeasesPageResult({required this.items, this.pagination});
}

int _leaseJsonInt(dynamic v, [int fallback = 0]) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return fallback;
}

class LeaseRepository {
  String baseUrl = '$Api_url/api/payment/charges_payments';
  // Future<void> postLease(Lease lease) async {
  //
  //   final response = await http.post(
  //     Uri.parse('${Api_url}/api/leases/leases'),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(lease.toJson()),
  //   );
  //   print('${Api_url}/api/leases/leases');
  //   if (response.statusCode == 200) {
  //     print(response.body);
  //     print('Lease posted successfully');
  //   } else {
  //     print('Failed to post lease: ${response.body}');
  //   }
  // }

  Future<bool> postLease(Lease lease) async {
    final url = Uri.parse('${Api_url}/api/leases/leases');
    print(url);
    log(jsonEncode(lease.toJson()));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    try {
      final response = await http.post(
        url,
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json'
        },
        body: jsonEncode(lease.toJson()),
      );

      var responseData = jsonDecode(response.body);
      print('Response body of the lease :${response.body}');
      log(response.body);
      print('Lease Object: ${jsonEncode(lease.toJson())}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['statusCode'] == 200) {
          print('Response successfully: ${responseData['data']}');

          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Successfully added lease');

          return true;
        } else {
          print('Failed to add lease: ${responseData}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to add lease');
          return false;
        }
      } else {
        print('Failed to add lease: ${responseData}');
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Failed to add lease');
        return false;
      }
    } catch (error) {
      print('Exception occurred: $error');
      Fluttertoast.showToast(msg: 'An error occurred');
      return false;
    }
  }

  // Future<bool>  ifApplicantMoveInTrue(String applicantId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   String? id = prefs.getString('adminId');
  //   final String url = '$Api_url/api/applicant/applicant-movein';
  //   final Map<String, dynamic> body = {
  //     'isMovedin': true,
  //     'applicant_status': [
  //       {
  //         'status': 'Approved',
  //         'statusUpdatedBy': 'Admin',
  //       },
  //     ],
  //   };
  //
  //   try {
  //     final response = await http.put(
  //       Uri.parse(url),
  //       headers: {
  //         'authorization': 'CRM $token',
  //         'id': 'CRM $id',
  //         'Content-Type': 'application/json'
  //       },
  //       body: json.encode(body),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('Applicant status updated successfully');
  //       return true;
  //     } else {
  //       print('Failed to update applicant status: ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Error updating applicant status: $e');
  //     return false;
  //   }
  // }
  Future<bool> ifApplicantMoveInTrue(
      String applicantId, List<String> applicantIds) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    final String url = '$Api_url/api/applicant/applicant-movein';
    final Map<String, dynamic> body = {
      'ids': applicantIds.isNotEmpty ? applicantIds : applicantIds,
      'updates': {
        'isMovedin': true,
        'applicant_status': [
          {
            'status': 'Approved',
            'statusUpdatedBy': 'Admin',
          },
        ],
      }
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'authorization': 'CRM $token',
          'id': 'CRM $id',
          'Content-Type': 'application/json'
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('Applicant status updated successfully');
        return true;
      } else {
        print('Failed to update applicant status: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating applicant status: $e');
      return false;
    }
  }

  Future<bool> updateLease(Lease lease, {bool? achAccepted}) async {
    print("calling navigate main");
    print(lease);
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');

    final payload = lease.toJson();
    if (achAccepted != null) {
      final leaseData = payload['leaseData'];
      if (leaseData is Map<String, dynamic>) {
        leaseData['achAccepted'] = achAccepted;
      }
    }
    final encodedBody = json.encode(payload);

    print('Lease ID: ${lease.leaseData.leaseId}');
    print('Token: $token');
    print('Admin ID: $id');
    print('API URL: $Api_url/api/leases/leases/${lease.leaseData.leaseId}');
    print('Lease Data: $encodedBody');

    try {
      print('Entering the try block');
      final response = await http.put(
        Uri.parse('$Api_url/api/leases/leases/${lease.leaseData.leaseId}'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json'
        },
        body: encodedBody,
      );
      print('Request complete');
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      var responseData = jsonDecode(response.body);
      print('Response Data for update : $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('HTTP request successful (${response.statusCode})');
        if (responseData['statusCode'] == 200) {
          print('SUCCESS: Lease updated successfully');
          print('Response data: ${responseData['data']}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Successfully updated lease');
          print('=== LeaseRepository.updateLease SUCCESS ===');
          return true;
        } else {
          print(
              'ERROR: API returned error status code: ${responseData['statusCode']}');
          print('Error message: ${responseData['message']}');
          print('Full response: ${responseData}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to update lease');
          print('=== LeaseRepository.updateLease FAILED ===');
          return false;
        }
      } else {
        print(
            'ERROR: HTTP request failed with status code: ${response.statusCode}');
        print('Failed to add lease: ${responseData}');
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Failed to update lease');
        print('=== LeaseRepository.updateLease FAILED ===');
        return false;
      }
    } catch (error) {
      print('EXCEPTION in LeaseRepository.updateLease: $error');
      print('Exception type: ${error.runtimeType}');
      Fluttertoast.showToast(msg: 'An error occurred: $error');
      print('=== LeaseRepository.updateLease EXCEPTION ===');
      return false;
    }
  }

  Future<bool> updateLeasePaymentSettings({
    required String leaseId,
    required bool leasePaymentSettings,
    required bool achAccepted,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    final String companyName = prefs.getString('companyName') ?? '';

    // Backend expects the full lease payload shape (chargeData/cosignerData/leaseData/tenantData).
    // Build it from the latest saved lease details to avoid pushing unsaved UI edits.
    final details = await fetchLeaseDetails(leaseId);

    dynamic stripMongoKeys(dynamic value) {
      if (value is List) {
        return value.map(stripMongoKeys).toList();
      }
      if (value is Map) {
        final out = <String, dynamic>{};
        value.forEach((k, v) {
          final key = k.toString();
          if (key == '_id' || key == '__v') return;
          out[key] = stripMongoKeys(v);
        });
        return out;
      }
      return value;
    }

    // Use parsed `details.lease.entry` so `_id` from backend isn't re-sent.
    final List<dynamic> allEntries =
        details.lease.entry.map((e) => e.toJson()).toList();

    final cosigner = (details.cosigner != null && details.cosigner!.isNotEmpty)
        ? details.cosigner!.first
        : null;

    final payload = {
      'chargeData': {
        'admin_id': details.lease.adminId,
        'entry': allEntries,
        'is_leaseAdded': true,
      },
      'cosignerData': {
        'admin_id': details.lease.adminId,
        'cosigner_address': cosigner?.streetAddress ?? '',
        'cosigner_alternativeEmail': cosigner?.alterEmail ?? '',
        'cosigner_alternativeNumber': cosigner?.workNumber ?? '',
        'cosigner_city': cosigner?.city ?? '',
        'cosigner_country': cosigner?.country ?? '',
        'cosigner_email': cosigner?.email ?? '',
        'cosigner_firstName': cosigner?.firstName ?? '',
        // Some payload builders use Mongo _id here; keep fallback for compatibility.
        'cosigner_id': cosigner?.c_id ?? cosigner?.cosignerId ?? '',
        'cosigner_lastName': cosigner?.lastName ?? '',
        'cosigner_phoneNumber': cosigner?.phoneNumber ?? '',
        'cosigner_postalcode': cosigner?.postalCode ?? '',
      },
      'leaseData': {
        'lease_id': details.lease.leaseId,
        'admin_id': details.lease.adminId,
        'company_name': companyName,
        'end_date': details.lease.endDate,
        'entry': allEntries,
        'lease_amount': details.lease.leaseAmount.toString(),
        'lease_type': details.lease.leaseType,
        'rental_id': details.lease.rentalId,
        'start_date': details.lease.startDate,
        'tenant_id': details.lease.tenantId,
        'tenant_residentStatus': false,
        'unit_id': details.lease.unitId,
        'uploaded_file': details.lease.uploadedFile,
        'creditCardAccepted': details.lease.creditCardAccepted,
        'debitCardAccepted': details.lease.debitCardAccepted,
        'achAccepted': achAccepted,
        'leasePaymentSettings': leasePaymentSettings,
      },
      'tenantData': details.tenant
              ?.map((t) => stripMongoKeys((t as dynamic).toJson()))
              .toList() ??
          [],
    };

    try {
      final response = await http.put(
        Uri.parse('$Api_url/api/leases/leases/$leaseId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json'
        },
        body: json.encode(payload),
      );

      var responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['statusCode'] == 200) {
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Lease payment settings updated');
          return true;
        } else {
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to update lease');
          return false;
        }
      } else {
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Failed to update lease');
        return false;
      }
    } catch (error) {
      Fluttertoast.showToast(msg: 'An error occurred: $error');
      return false;
    }
  }

  // Future<List<Lease1>> fetchLease(String? adminId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   adminId = prefs.getString("adminId");
  //   final response = await http.get(Uri.parse('$Api_url/api/leases/leases/$adminId'));
  //   print('$Api_url/api/leases/leases/$adminId');
  //   print(adminId);
  //   print(response.body);
  //   //  print('$baseUrl/rental-owners/$adminId');
  //   if (response.statusCode == 200) {
  //     List jsonResponse = json.decode(response.body);
  //     return jsonResponse.map((data) => Lease1.fromJson(data)).toList();
  //   } else {
  //     throw Exception('Failed to load lease');
  //   }
  // }

  /// Paginated leases (same query shape as web).
  Future<LeasesPageResult> fetchLeasePage({
    required int page,
    required int limit,
    String search = '',
    required String status,
    String sortBy = 'end_date',
    String sortOrder = 'descending',
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final adminId = prefs.getString("adminId");
    String? id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    final uri = Uri.parse('$Api_url/api/leases/leases/$adminId').replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        'search': search,
        'status': status,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      },
    );
    print(uri);
    final response = await http.get(
      uri,
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );

    final empty = LeasesPageResult(items: [], pagination: null);
    if (response.statusCode != 200) {
      print('Failed to fetch lease page: ${response.body}');
      return empty;
    }
    final jsonResponse = json.decode(response.body) as Map<String, dynamic>;
    final raw = jsonResponse['data'];
    if (raw is! List) return empty;
    final items =
        raw.map((e) => Lease1.fromJson(e as Map<String, dynamic>)).toList();

    LeasesPagination? pagination;
    final pRaw = jsonResponse['pagination'];
    if (pRaw is Map<String, dynamic>) {
      pagination = LeasesPagination(
        currentPage: _leaseJsonInt(pRaw['currentPage'], 1),
        totalPages: _leaseJsonInt(pRaw['totalPages'], 1).clamp(1, 1 << 30),
        totalItems: _leaseJsonInt(pRaw['totalItems']),
        itemsPerPage: _leaseJsonInt(pRaw['itemsPerPage'], limit),
      );
    }
    return LeasesPageResult(items: items, pagination: pagination);
  }

  /// Full list for screens that still need every lease (aggregates paginated API).
  Future<List<Lease1>> fetchLease(String? adminId) async {
    final all = <Lease1>[];
    var page = 1;
    const limit = 200;
    while (true) {
      final r = await fetchLeasePage(
        page: page,
        limit: limit,
        search: '',
        status: 'all',
        sortBy: 'end_date',
        sortOrder: 'descending',
      );
      all.addAll(r.items);
      final p = r.pagination;
      if (p == null || r.items.isEmpty || page >= p.totalPages) break;
      page++;
    }
    return all;
  }

  Future<Map<String, dynamic>> deleteLease(
      {required String leaseId,
      required String companyName,
      String? reason}) async {
    try {
      final Uri uri = Uri.parse('$Api_url/api/leases/leases/$leaseId')
          .replace(queryParameters: {
        'company_name': companyName,
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('adminId');
      final http.Response response = await http.delete(uri,
          headers: <String, String>{
            "authorization": "CRM $token",
            "id": "CRM $id",
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({"reason": reason}));

      var responseData = json.decode(response.body);
      print(response.body);
      print(leaseId);
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: responseData["message"]);
        return json.decode(response.body);
      } else {
        Fluttertoast.showToast(msg: responseData["message"]);
        throw Exception('Failed to delete lease');
      }
    } catch (e) {
      throw Exception('Failed to delete lease: $e');
    }
  }

  Future<String> fetchCompanyName(String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    final String apiUrl = '${Api_url}/api/admin/admin_profile/$adminId';

    try {
      final http.Response response = await http.get(
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

  // Future<List<LeaseData>> fetchLeasesSummery(String id) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String?  id = prefs.getString('adminId');
  //   String? token = prefs.getString('token');
  //   final response =
  //       await http.get(Uri.parse('${Api_url}/api/tenant/rental_tenant/$id'),headers: {"authorization" : "CRM $token","id":"CRM $id",},);
  //   if (response.statusCode == 200) {
  //     List jsonResponse = json.decode(response.body)['data'];
  //     return jsonResponse.map((data) => LeaseData.fromJson(data)).toList();
  //   } else {
  //     throw Exception('Failed to load data');
  //   }
  // }

  static Future<Map<String, dynamic>> fetchLeaseData(String leaseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    // Replace with your actual API call
    final response = await http.get(
      Uri.parse('$Api_url/api/leases/lease_summary/$leaseId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load lease data');
    }
  }

  // Future<void> updateLease(Lease1 lease) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   String?  id = prefs.getString('adminId');
  //   final response = await http.put(
  //     Uri.parse('$Api_url/api/leases/leases/${lease.leaseId}'),
  //
  //     headers: {
  //       "authorization" : "CRM $token",
  //       "id":"CRM $id",
  //       'Content-Type': 'application/json',
  //     },
  //     body: json.encode(lease.toJson()),
  //   );
  //
  //   print(lease.leaseId);
  //   var responseData = json.decode(response.body);
  //   print(response.body);
  //   print(responseData);
  //
  //   if (responseData["statusCode"] == 200) {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //   } else {
  //     Fluttertoast.showToast(msg: responseData["message"]);
  //     throw Exception('Failed to update lease');
  //   }
  // }
/*  Future<bool> updateLease(Lease lease) async {
    print(lease);
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');

    print('Lease ID: ${lease.leaseData.leaseId}');
    print('Token: $token');
    print('Admin ID: $id');
    print('API URL: $Api_url/api/leases/leases/${lease.leaseData.leaseId}');
    print('Lease Data: ${json.encode(lease)}');

    try {
      print('Entering the try block');
      final response = await http.put(
        Uri.parse('$Api_url/api/leases/leases/${lease.leaseData.leaseId}'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json'
        },
        body: json.encode(lease),
      );
      print('Request complete');

      var responseData = jsonDecode(response.body);
      print('Response Data: $responseData');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['statusCode'] == 200) {
          print('Response successfully: ${responseData['data']}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Successfully updated lease');

          return true;
        } else {
          print('Failed to add lease: ${responseData}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to update lease');
          return false;
        }
      } else {
        print('Failed to add lease: ${responseData}');
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Failed to update lease');
        return false;
      }
    } catch (error) {
      print('Exception occurred: $error');
      Fluttertoast.showToast(msg: 'An error occurred: $error');
      return false;
    }
  }*/

  Future<LeaseDetails> fetchLeaseDetails(String leaseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    final response = await http.get(
      Uri.parse('${Api_url}/api/leases/get_lease/$leaseId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    ); // Update with your actual API URL
    print('update fetch ${response.body}');
    print('${Api_url}/api/leases/get_lease/$leaseId');
    print(leaseId);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // List leasesJson = jsonResponse['data'];
      return LeaseDetails.fromJson(jsonResponse['data']);
    } else {
      throw Exception('Failed to load lease');
    }
  }

  /*Future<bool> ifApplicantMoveInTrue(String applicantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    final String url = '$Api_url/api/applicant/applicant/$applicantId';
    final Map<String, dynamic> body = {
      'isMovedin': true,
      'applicant_status': [
        {
          'status': 'Approved',
          'statusUpdatedBy': 'Admin',
        },
      ],
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'authorization': 'CRM $token',
          'id': 'CRM $id',
          'Content-Type': 'application/json'
        },
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        print('Applicant status updated successfully');
        return true;
      } else {
        print('Failed to update applicant status: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating applicant status: $e');
      return false;
    }
  }*/
  static Future<LeaseSummary> fetchLeaseSummary(String leaseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");
    try {
      print('$Api_url/api/leases/lease_summary/$leaseId');
      final response = await http.get(
        Uri.parse('$Api_url/api/leases/lease_summary/$leaseId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );
      // log(response.body);
      // print(json);
      // log('JSON being parsed: ${response.body}');

      // print('lease renewal ${response.body}');
      if (response.statusCode == 200) {
        return LeaseSummary.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load lease summary');
      }
    } catch (e) {
      throw Exception('Error fetching lease data: $e');
    }
  }

  static Future<List<LeaseTenant>> fetchLeaseTenants(String leaseId) async {
    final url = Uri.parse('$Api_url/api/tenant/leases/$leaseId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");
    //  try {
    final response = await http.get(
      url,
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      // Parsing the list of leases from the response
      List<dynamic> leaseList = data['data'];
      List<LeaseTenant> leaseTenants = leaseList.map((leaseJson) {
        return LeaseTenant.fromJson(leaseJson);
      }).toList();

      return leaseTenants;
    } else {
      throw Exception('Failed to load lease data');
    }
    /*  } catch (e) {
      throw Exception('Error fetching lease data: $e');
    }*/
  }

  // Future<LeaseLedger?> fetchLeaseLedger(String leaseId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   String? id = prefs.getString("adminId");
  //   final response = await http.get(
  //     Uri.parse('$Api_url/api/payment/charges_payments/$leaseId'),
  //     headers: {
  //       "authorization": "CRM $token",
  //       "id": "CRM $id",
  //     },
  //   );
  //   print('$Api_url/api/payment/charges_payments/$leaseId');
  //  // print(response.body);
  //  // print(leaseId);
  //   //print($id);
  //   if (response.statusCode == 200) {
  //     return LeaseLedger.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Failed to load lease ledger');
  //   }
  // }
  // Future<LeaseLedger?> fetchLeaseLedger({String? leaseId,String? fromDate, String? toDate}) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   String? id = prefs.getString("adminId");
  //   final response = await http.get(
  //     Uri.parse('$Api_url/api/payment/charges_payments/$leaseId'),
  //     headers: {
  //       "authorization": "CRM $token",
  //       "id": "CRM $id",
  //     },
  //   );
  //   print('$Api_url/api/payment/charges_payments/$leaseId');
  //   // print(response.body);
  //   // print(leaseId);
  //   //print($id);
  //   if (response.statusCode == 200) {
  //     return LeaseLedger.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Failed to load lease ledger');
  //   }
  // }
  Future<LeaseLedger?> fetchLeaseLedger(
      {String? fromDate, String? toDate, String? leaseId}) async {
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
      print('response.body lease all  ${response.body}');
      if (response.statusCode == 200) {
        print('response.body ${response.body}');
        final parsedJson = jsonDecode(response.body);
        print('parsedJson: $parsedJson');
        final report = LeaseLedger.fromJson(parsedJson);
        print('parsed ReportExpiringLeaseTable: ${report.data}');
        return report;
      } else {
        throw ServerException(response.statusCode,
            'Failed to load data. Status code: ${response.statusCode}');
      }
    } on http.ClientException {
      throw NetworkException(
          'Failed to connect to the server. Please check your internet connection.');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  Future<int> postCharge(Charge charge) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");
    final response = await http.post(
      Uri.parse('$Api_url/api/charge/charge'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'CRM $token',
        "id": "CRM $id",
      },
      body: jsonEncode(charge.toJson()),
    );
    print('charge respo ${response.body}');
    if (response.statusCode == 200) {
      // Fluttertoast.showToast(msg: 'Charge delete successfully');
      // Successfully posted
      print('Charge posted successfully');
    } else {
      // Handle error
      //  Fluttertoast.showToast(msg: 'Failed to delete charge');
      print('Failed to post charge: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    return response.statusCode;
  }

  Future<int> EditCharge(Charge charge, String charge_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");
    final response = await http.put(
      Uri.parse('$Api_url/api/charge/charge/$charge_id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'CRM $token',
        "id": "CRM $id",
      },
      body: jsonEncode(charge.toJson()),
    );
    print('charge respo ${response.body}');
    if (response.statusCode == 200) {
      // Successfully posted
      print('Charge posted successfully');
    } else {
      // Handle error
      print('Failed to post charge: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    return response.statusCode;
  }

  Future<int> DeleteCharge(String charge_id, String? reason) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");
    final response =
        await http.delete(Uri.parse('$Api_url/api/charge/charge/$charge_id'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'CRM $token',
              "id": "CRM $id",
            },
            body: jsonEncode({"reason": reason}));
    print('charge respo ${response.body}');
    if (response.statusCode == 200) {
      // Successfully posted
      print('Charge posted successfully');
    } else {
      // Handle error
      print('Failed to post charge: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    return response.statusCode;
  }

  Future<int> DeletePayment(String payment_id, String? reason) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");
    final response =
        await http.delete(Uri.parse('$Api_url/api/payment/payment/$payment_id'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'CRM $token',
              "id": "CRM $id",
            },
            body: jsonEncode({"reason": reason}));
    print('charge respo ${response.body}');
    if (response.statusCode == 200) {
      // Successfully posted
      print('Charge posted successfully');
    } else {
      // Handle error
      print('Failed to post charge: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    return response.statusCode;
  }

  Future<LeaseCharges?> fetchLeaseCharges(String leaseId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");

    try {
      final response = await http.get(
        Uri.parse('$Api_url/api/leases/lease-charges/$leaseId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      print('Lease charges URL: $Api_url/api/leases/lease-charges/$leaseId');
      print('Lease charges response: ${response.body}');

      if (response.statusCode == 200) {
        return LeaseCharges.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            'Failed to load lease charges. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lease charges: $e');
      throw Exception('Error fetching lease charges: $e');
    }
  }
}
