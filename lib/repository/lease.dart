import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constant/constant.dart';
import '../model/get_lease.dart';
import '../model/lease.dart';

class LeaseRepository {
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
    print(jsonEncode(lease.toJson()));
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(lease.toJson()),
      );

      var responseData = jsonDecode(response.body);
      print(responseData);

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

  Future<List<Lease1>> fetchLease(String? adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adminId = prefs.getString("adminId");
    final response =
        await http.get(Uri.parse('$Api_url/api/leases/leases/$adminId'));
    print('$Api_url/api/leases/leases/$adminId');
    print(adminId);
    print(response.body);

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      List leasesJson = jsonResponse['data'];
      return leasesJson.map((data) => Lease1.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load lease');
    }
  }

  Future<Map<String, dynamic>> deleteLease({
    required String leaseId,
    required String companyName,
  }) async {
    try {
      final Uri uri = Uri.parse('$Api_url/api/leases/leases/$leaseId')
          .replace(queryParameters: {
        'company_name': companyName,
      });

      final http.Response response = await http.delete(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

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
    final String apiUrl =
        'http://192.168.1.16:4000/api/admin/admin_profile/$adminId';

    try {
      final http.Response response = await http.get(Uri.parse(apiUrl));

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

  Future<List<LeaseData>> fetchLeasesSummery(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print(id);
    final response =
        await http.get(Uri.parse('${Api_url}/api/tenant/rental_tenant/$id'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => LeaseData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  static Future<Map<String, dynamic>> fetchLeaseData(String leaseId) async {
    // Replace with your actual API call
    final response =
        await http.get(Uri.parse('$Api_url/api/leases/lease_summary/$leaseId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load lease data');
    }
  }
}
