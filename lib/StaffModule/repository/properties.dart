import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/properties.dart';

import '../../constant/constant.dart';
import 'package:http/http.dart'as http;

import '../model/add_property.dart';

class PropertiesRepository {
  //final String apiUrl = '${Api_url}/api/propertytype/property_type';

  Future<List<Rentals>> fetchProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String?  id = prefs.getString('staff_id');
    String?  admin_id = prefs.getString('adminId');
    String? token = prefs.getString('token');

    final response = await http.get(Uri.parse('${Api_url}/api/rentals/rentals/$admin_id'),
      headers: {"authorization" : "CRM $token","id":"CRM $id",},);
    print('${Api_url}/api/rentals/rentals/$id');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['data'];
      return jsonResponse.map((data) => Rentals.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load data');
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

    //print('$apiUrl/$tenantId');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String?  id = prefs.getString('staff_id');
    String?  admin_id = prefs.getString('adminId');
    String? token = prefs.getString('token');
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
  // Future<void> updateRental(Rentals rentalrequest) async {
  //
  //   final url = Uri.parse('${Api_url}/api/rentals/rentals/${rentalrequest.rentalId}');
  //   print(rentalrequest.rentalId);
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String? token = prefs.getString("token");
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   };
  //   final body = jsonEncode({
  //     "rentalOwner": {
  //       "admin_id": rentalrequest.adminId,
  //       "rentalowner_id": rentalrequest.rentalOwnerId,
  //       "rentalOwner_firstName": rentalrequest.rentalOwnerData?.rentalOwnerFirstName,
  //       "rentalOwner_lastName": rentalrequest.rentalOwnerData?.rentalOwnerLastName,
  //       "rentalOwner_companyName": rentalrequest.rentalOwnerData?.rentalOwnerCompanyName,
  //       "rentalOwner_primaryEmail": rentalrequest.rentalOwnerData?.rentalOwnerPrimaryEmail,
  //       "rentalOwner_phoneNumber": rentalrequest.rentalOwnerData?.rentalOwnerPhoneNumber,
  //       "rentalOwner_homeNumber": rentalrequest.rentalOwnerData?.rentalOwnerHomeNumber,
  //       "rentalOwner_businessNumber": rentalrequest.rentalOwnerData?.rentalOwnerBuisinessNumber,
  //       "city": rentalrequest.rentalOwnerData?.city,
  //       "state": rentalrequest.rentalOwnerData?.state,
  //       "country": rentalrequest.rentalOwnerData?.country,
  //       "postal_code": rentalrequest.rentalOwnerData?.postalCode,
  //     },
  //     "rental": {
  //       "company_name": rentalrequest.rentalOwnerData?.rentalOwnerCompanyName,
  //       "rental_id": rentalrequest.rentalId,
  //       "property_id": rentalrequest.propertyId,
  //       "rental_adress": rentalrequest.rentalAddress,
  //       "rental_city": rentalrequest.rentalCity,
  //       "rental_state": rentalrequest.rentalState,
  //       "rental_country": rentalrequest.rentalCountry,
  //       "rental_postcode": rentalrequest.rentalPostcode,
  //       "staffmember_id": rentalrequest.staffMemberId,
  //     },
  //   });
  //   print(body);
  //   final response = await http.put(url, headers: headers, body: body);
  //   print(response.body);
  //   if (response.statusCode == 200) {
  //
  //     Fluttertoast.showToast(msg: "Rental Owner Updated Successfully");
  //     print('Rental and Rental Owner Updated Successfully');
  //   } else {
  //     Fluttertoast.showToast(msg: "Failed to update rental");
  //     print("object");
  //     throw Exception('Failed to update rental');
  //   }
  // }


  Future<void> updateRental1(Rentals rentalRequest) async {
    final url = Uri.parse('${Api_url}/api/rentals/rentals/${rentalRequest.rentalId}');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String?  id = prefs.getString('staff_id');
    String?  admin_id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    final headers = {
      'Content-Type': 'application/json',
      "id":"CRM $id",
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      "rentalOwner": {
        "admin_id": rentalRequest.adminId,
        "rentalowner_id": rentalRequest.rentalOwnerId,
        "rentalOwner_firstName": rentalRequest.rentalOwnerData?.rentalOwnerFirstName,
        "rentalOwner_lastName": rentalRequest.rentalOwnerData?.rentalOwnerLastName,
        "rentalOwner_companyName": rentalRequest.rentalOwnerData?.rentalOwnerCompanyName,
        "rentalOwner_primaryEmail": rentalRequest.rentalOwnerData?.rentalOwnerPrimaryEmail,
        "rentalOwner_phoneNumber": rentalRequest.rentalOwnerData?.rentalOwnerPhoneNumber,
        "city": rentalRequest.rentalOwnerData?.city,
        "state": rentalRequest.rentalOwnerData?.state,
        "country": rentalRequest.rentalOwnerData?.country,
        "postal_code": rentalRequest.rentalOwnerData?.postalCode,
      },
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
      },
    });
    final response = await http.put(url, headers: headers, body: body);
    print('${rentalRequest.rentalId}');
    print(response.body);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "properties updated successfully");
    } else {
      throw Exception('Failed to update properties');
    }

  }

  Future<void> updateRental(RentalRequest rentalRequest ,String rentalid) async {
    final url = Uri.parse('${Api_url}/api/rentals/rentals/$rentalid');
    print(rentalRequest.toJson());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String?  id = prefs.getString('staff_id');
    String?  admin_id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    print('${Api_url}/api/rentals/rentals/$rentalid');
    final headers = {
      'Content-Type': 'application/json',
      "id":"CRM $id",
      'Authorization': 'Bearer $token',
    };
    final body = jsonEncode({
      "rentalOwner": rentalRequest.rentalOwner!.toJson(),
      "rental": rentalRequest.rental!.toJson(),
      //"rental": rentalRequest.rental!.toJson(),
      "units": rentalRequest.units!.map((unit) => unit.toJson()).toList(),
    });
//   print('heloo ${rentalRequest.rental?.rentalId}');
    final response = await http.put(url, headers: headers, body: body);
  print(response.body);
    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Rental updated successfully");
    } else {
      throw Exception('Failed to update rental');
    }
  }

  Future<Map<String, dynamic>> DeleteProperties({
    required String? pro_id,

  }) async {

    // print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String?  id = prefs.getString('staff_id');
    String?  admin_id = prefs.getString('adminId');
    String? token = prefs.getString('token');
    final http.Response response = await http.delete(
      Uri.parse('${Api_url}/api/rentals/rental/$pro_id'),
      headers: <String, String>{
        "authorization" : "CRM $token",
        "id":"CRM $id",
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    var responseData = json.decode(response.body);
    print(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);

    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add property type');
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