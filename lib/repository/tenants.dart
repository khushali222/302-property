import 'dart:convert';
import 'dart:core';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../Model/tenants.dart';
import '../constant/constant.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' as http;

class TenantsRepository {
  final String apiUrl = '${Api_url}/api//tenant/tenants';

  Future<List<Tenant>> fetchTenants() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Api_url}/api/tenant/tenants/$id'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print(response.body);
    print('${Api_url}/api/tenant/tenants/$id');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => Tenant.fromJson(data)).toList();
    } else {
      print('Failed to fetch tenants: ${response.body}');
      return [];
     // throw Exception('Failed to load data');
    }
  }

  Future<List<Tenant>> fetchLeaseTenants(String tenantId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Api_url}/api/tenant/tenants/$tenantId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print(response.body);
    print('${Api_url}/api/tenant_details/$id');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => Tenant.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<bool> addTenant(Tenant tenant) async {
    final url = Uri.parse('${Api_url}/api/tenant/tenants');
    print(url);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    print(jsonEncode(tenant.toJson()));
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
        body: jsonEncode(tenant.toJson()),
      );

      var responseData = jsonDecode(response.body);
      print(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (responseData['statusCode'] == 200) {
          print('Response successfully: ${responseData['data']}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Successfully added tenant');

          return true;
        } else {
          print('Failed to add tenant: ${responseData}');
          Fluttertoast.showToast(
              msg: responseData['message'] ?? 'Failed to add tenant');
          return false;
        }
      } else {
        print('Failed to add tenant: ${responseData}');
        Fluttertoast.showToast(
            msg: responseData['message'] ?? 'Failed to add tenant');
        return false;
      }
    } catch (error) {
      print('Exception occurred: $error');
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
  //   final http.Response response = await http.put(
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
  //     final http.Response response = await http.put(
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
    required String tenantBirthDate,
    required String taxPayerId,
    required String comments,
    required String emergencyContactName,
    required String emergencyContactRelation,
    required String emergencyContactEmail,
    required String emergencyContactPhoneNumber,
    required String companyName,
    required String overRideFee,
    required String enableOverRideFee,
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
    };
    print('Data is :$data');

    print('$apiUrl/$tenantId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    final http.Response response = await http.put(
      Uri.parse('$Api_url/api/tenant/tenants/$tenantId'),
      headers: <String, String>{
        "authorization": "CRM $token",
        "id": "CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    var responseData = json.decode(response.body);
    print(response.body);
    print(responseData);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to edit property type');
    }
  }

  Future<Map<String, dynamic>> deleteTenant({
    required String tenantId,
    required String companyName,
    required String tenantEmail,
    String? reason
  }) async {
    try {
      final Uri uri = Uri.parse('$Api_url/api/tenant/tenant/$tenantId')
          .replace(queryParameters: {
        'company_name': companyName,
        'tenant_email': tenantEmail,
      });
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('adminId');
      final http.Response response = await http.delete(
        uri,
        headers: <String, String>{
          "authorization": "CRM $token",
          "id": "CRM $id",
          'Content-Type': 'application/json; charset=UTF-8',
        },
          body: jsonEncode({"reason":reason})
      );

      var responseData = json.decode(response.body);
      print(response.body);
      print(tenantId);
      print(tenantEmail);
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
    String? id = prefs.getString('adminId');
    print(tenantId);
    final response = await http.get(
      Uri.parse('$Api_url/api/tenant/tenant_details/$tenantId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)["data"];
      print(jsonResponse);

      return jsonResponse.map((data) => Tenant.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load tenant');
    }
  }

  Future<String> fetchCompanyName(String adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString('adminId');
    final String apiUrl = '$Api_url/api/admin/admin_profile/$adminId';

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
}
