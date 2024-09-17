import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/properties.dart';

import '../constant/constant.dart';
import 'package:http/http.dart'as http;

import '../model/add_property.dart';

class PropertiesRepository {
  final String apiUrl = '${Api_url}/api/propertytype/property_type';

  Future<List<Rentals>> fetchProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await http.get(Uri.parse('${Api_url}/api/rentals/rentals/$id'),
      headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    print('${Api_url}/api/rentals/rentals/$id');
    print('properties ${response.body}');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => Rentals.fromJson(data)).toList();
    } else {
      print('Failed to fetch properties: ${response.body}');
      return [];
     // throw Exception('Failed to load data');
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
    required String tenantBirthDate,
    required String taxPayerId,
    required String comments,
    required String emergencyContactName,
    required String emergencyContactRelation,
    required String emergencyContactEmail,
    required String emergencyContactPhoneNumber,
    required String companyName,
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
      }
    };

    print('$apiUrl/$tenantId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final http.Response response = await http.put(
      Uri.parse('$Api_url/api/tenant/tenants/$tenantId'),
      headers: <String, String>{
        "authorization" : "CRM $token",
        "id":"CRM $id",
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
      throw Exception('Failed to add property type');
    }
  }


  Future<void> updateRental1(Rentals rentalRequest) async {
    final url = Uri.parse('${Api_url}/api/rentals/rentals/${rentalRequest.rentalId}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    String? id = prefs.getString('adminId');
    final headers = {
      'Content-Type': 'application/json',
      "id": "CRM $id",
      'Authorization': 'Bearer $token',
    };

    final rentalOwnerData = {
      "admin_id": rentalRequest.adminId,
      "rentalowner_id": rentalRequest.rentalOwnerData?.rentalOwnerId,
      "rentalOwner_name": rentalRequest.rentalOwnerData?.rentalOwnerName,
      "rentalOwner_companyName": rentalRequest.rentalOwnerData?.rentalOwnerCompanyName,
      "rentalOwner_primaryEmail": rentalRequest.rentalOwnerData?.rentalOwnerPrimaryEmail,
      "rentalOwner_phoneNumber": rentalRequest.rentalOwnerData?.rentalOwnerPhoneNumber,
      "rentalOwner_homeNumber":rentalRequest.rentalOwnerData?.rentalOwnerHomeNumber??"",
      "rentalOwner_businessNumber":rentalRequest.rentalOwnerData?.rentalOwnerBuisinessNumber??"",
      "city": rentalRequest.rentalOwnerData?.city,
      "state": rentalRequest.rentalOwnerData?.state,
      "country": rentalRequest.rentalOwnerData?.country,
      "postal_code": rentalRequest.rentalOwnerData?.postalCode,
    //  "processor_list":rentalRequest.rentalOwnerData!.processorList
    };

    final body = jsonEncode({
      "rentalOwner": rentalOwnerData,
      "rental": {
        "company_name": rentalRequest.rentalOwnerData?.rentalOwnerCompanyName,
        "rental_id": rentalRequest.rentalId,
        "property_id": rentalRequest.propertyId,
        "rental_adress": rentalRequest.rentalAddress,
        "rental_city": rentalRequest.rentalCity,
        "rental_state": rentalRequest.rentalState,
        "rental_country": rentalRequest.rentalCountry,
        "rental_postcode": rentalRequest.rentalPostcode,
        "staffmember_id": rentalRequest.staffMemberId,
       // "processor_id":rentalRequest.processor_id

      },
    });

    final response = await http.put(url, headers: headers, body: body);
    final responseBody = jsonDecode(response.body);


    final rentalOwnerResponse = responseBody['data']['rentalOwner'];
    print('Rental Owner Data from Response: ${jsonEncode(rentalOwnerResponse)}');

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Properties updated successfully");
    } else {
      throw Exception('Failed to update properties');
    }
  }

  Future<Map<String, dynamic>> DeleteProperties({
    required String? id,
   // required String? companyName,
  }) async {

    // print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String?  adminid = prefs.getString('adminId');
    String? token = prefs.getString('token');
    String? companyName = prefs.getString('companyName');
    print('company name $companyName');
    print(adminid);
    final http.Response response = await http.delete(
      Uri.parse('${Api_url}/api/rentals/rental/$id').replace(queryParameters: {
        'company_name': companyName,
      }),
      headers: <String, String>{
        "authorization" : "CRM $token",
        "id":"CRM $adminid",
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // body: jsonEncode(<String, String>{
      //   'company_name': companyName??"",
      // }),
    );
    print( Uri.parse('${Api_url}/api/rentals/rental/$id').replace(queryParameters: {
      'company_name': companyName,
    }));
    print('delete ${Api_url}/api/rentals/rental/$id');

    var responseData = json.decode(response.body);
    print(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to delete property type');
    }
  }

  // Future<LeaseDetails> fetchLeaseDetails(String leaseId) async {
  //   final response = await http.get(Uri.parse('${Api_url}/api/leases/get_lease/$leaseId')); // Update with your actual API URL
  //   print(response.body);
  //   print(leaseId);
  //   print(leaseId);
  //   if (response.statusCode == 200) {
  //     final jsonResponse = json.decode(response.body);
  //     // List leasesJson = jsonResponse['data'];
  //
  //     return  LeaseDetails.fromJson(jsonResponse['data']);
  //   } else {
  //     throw Exception('Failed to load lease');
  //   }
  // }
}