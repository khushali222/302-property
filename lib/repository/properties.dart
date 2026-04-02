import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/properties.dart';

import '../constant/constant.dart';
import 'package:http/http.dart' as http;

import '../model/add_property.dart';

/// Pagination metadata from GET /api/rentals/rentals/:adminId?page=&limit=&search=&sortBy=&sortOrder=
class RentalsPaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  RentalsPaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });
}

/// One page of rentals; [pagination] is null when the API omits pagination (legacy).
class RentalsPageResult {
  final List<Rentals> items;
  final RentalsPaginationInfo? pagination;

  RentalsPageResult({required this.items, this.pagination});
}

class PropertiesRepository {
  final String apiUrl = '${Api_url}/api/propertytype/property_type';

  /// Paginated rentals list (backend-driven page/limit/search/sort).
  Future<RentalsPageResult> fetchPropertiesPage({
    required int page,
    required int limit,
    String search = '',
    String sortBy = 'createdAt',
    String sortOrder = 'asc',
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final uri = Uri.parse('${Api_url}/api/rentals/rentals/$id').replace(
      queryParameters: {
        'page': '$page',
        'limit': '$limit',
        'search': search,
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      },
    );

    final response = await http.get(
      uri,
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print('$uri');
    print('properties ${response.body}');
    if (response.statusCode != 200) {
      print('Failed to fetch properties: ${response.body}');
      return RentalsPageResult(items: [], pagination: null);
    }

    final body = json.decode(response.body) as Map<String, dynamic>;
    final dataRaw = body['data'];
    final List<Rentals> items = dataRaw is List
        ? dataRaw
            .map((e) => Rentals.fromJson(e as Map<String, dynamic>))
            .toList()
        : [];

    RentalsPaginationInfo? pagination;
    final p = body['pagination'];
    if (p is Map<String, dynamic>) {
      pagination = RentalsPaginationInfo(
        currentPage: (p['currentPage'] is int)
            ? p['currentPage'] as int
            : int.tryParse('${p['currentPage']}') ?? page,
        totalPages: (p['totalPages'] is int)
            ? p['totalPages'] as int
            : int.tryParse('${p['totalPages']}') ?? 1,
        totalItems: (p['totalItems'] is int)
            ? p['totalItems'] as int
            : int.tryParse('${p['totalItems']}') ?? items.length,
        itemsPerPage: (p['itemsPerPage'] is int)
            ? p['itemsPerPage'] as int
            : int.tryParse('${p['itemsPerPage']}') ?? limit,
      );
    }

    return RentalsPageResult(items: items, pagination: pagination);
  }

  /// All rentals for admin (aggregates paginated API). Prefer [fetchPropertiesPage] in UI when possible.
  Future<List<Rentals>> fetchProperties() async {
    final List<Rentals> all = [];
    int page = 1;
    const int limit = 100;
    while (true) {
      final chunk = await fetchPropertiesPage(
        page: page,
        limit: limit,
        search: '',
        sortBy: 'createdAt',
        sortOrder: 'asc',
      );
      all.addAll(chunk.items);
      final p = chunk.pagination;
      if (p == null ||
          page >= p.totalPages ||
          chunk.items.isEmpty) {
        break;
      }
      page++;
    }
    return all;
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
      throw Exception('Failed to add property type');
    }
  }

  Future<void> updateRental1(Rentals rentalRequest) async {
    final url =
        Uri.parse('${Api_url}/api/rentals/rentals/${rentalRequest.rentalId}');
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
      "rentalOwner_companyName":
          rentalRequest.rentalOwnerData?.rentalOwnerCompanyName,
      "rentalOwner_primaryEmail":
          rentalRequest.rentalOwnerData?.rentalOwnerPrimaryEmail,
      "rentalOwner_phoneNumber":
          rentalRequest.rentalOwnerData?.rentalOwnerPhoneNumber,
      "rentalOwner_homeNumber":
          rentalRequest.rentalOwnerData?.rentalOwnerHomeNumber ?? "",
      "rentalOwner_businessNumber":
          rentalRequest.rentalOwnerData?.rentalOwnerBuisinessNumber ?? "",
      "city": rentalRequest.rentalOwnerData?.city,
      "state": rentalRequest.rentalOwnerData?.state,
      "country": rentalRequest.rentalOwnerData?.country,
      "postal_code": rentalRequest.rentalOwnerData?.postalCode,
      "processor_list": rentalRequest.rentalOwnerData?.processorList
    };

    // Format units data according to API requirements
    print('Formatting units for API request:');
    print('Raw units data: ${rentalRequest.units}');

    final List<Map<String, dynamic>> formattedUnits =
        rentalRequest.units?.map((unit) {
              print('Processing unit for API request:');
              print('Raw unit data: $unit');

              // For Commercial single unit, ensure sqft is in the correct field
              var formattedUnit = {
                "admin_id": rentalRequest.adminId,
                "unit_id": unit["unit_id"] ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                "rental_unit": unit["rental_unit"] ??
                    "Unit 1", // Default to "Unit 1" if empty
                "rental_unit_adress": unit["rental_unit_adress"] ?? "",
                "rental_sqft": unit["rental_sqft"] ??
                    unit["rental_unit"] ??
                    "", // Try to get sqft from rental_unit if rental_sqft is empty
                "rental_bath": unit["rental_bath"] ?? "",
                "rental_bed": unit["rental_bed"] ?? "",
                "rental_images": unit["rental_images"] ?? []
              };

              print('Formatted unit data:');
              print('- Unit ID: ${formattedUnit["unit_id"]}');
              print('- Unit Name: ${formattedUnit["rental_unit"]}');
              print('- Unit Address: ${formattedUnit["rental_unit_adress"]}');
              print('- Unit Sqft: ${formattedUnit["rental_sqft"]}');
              print('- Bath: ${formattedUnit["rental_bath"]}');
              print('- Bed: ${formattedUnit["rental_bed"]}');

              return formattedUnit;
            }).toList() ??
            [];
    print('Formatted units: $formattedUnits');
    print("api unit reponce $formattedUnits");
    
    // Build rental data map
    Map<String, dynamic> rentalData = {
      "admin_id": rentalRequest.adminId,
      "company_name": rentalRequest.rentalOwnerData?.rentalOwnerCompanyName,
      "rental_id": rentalRequest.rentalId,
      "property_id": rentalRequest.propertyId,
      "rentalowner_id": rentalRequest.rentalOwnerId,
      "rental_adress": rentalRequest.rentalAddress,
      "rental_city": rentalRequest.rentalCity,
      "rental_state": rentalRequest.rentalState,
      "rental_country": rentalRequest.rentalCountry,
      "rental_postcode": rentalRequest.rentalPostcode,
      "staffmember_id": rentalRequest.staffMemberId,
      "processor_id": rentalRequest.processor_id,
    };
    
    // Add placed_in_service and insured_values using dynamic access
    try {
      final placedInService = (rentalRequest as dynamic).placedInService;
      if (placedInService != null && placedInService.toString().isNotEmpty) {
        rentalData["placed_in_service"] = placedInService;
      }
      
      final insuredValues = (rentalRequest as dynamic).insuredValues;
      if (insuredValues != null && (insuredValues as List).isNotEmpty) {
        rentalData["insured_values"] = (insuredValues as List).map((iv) => {
          "year": (iv as dynamic).year,
          "insured_value": (iv as dynamic).insuredValue?.toString() ?? ""
        }).toList();
      }
    } catch (e) {
      print('Error accessing placedInService/insuredValues: $e');
    }
    
    final body = jsonEncode({
      "rentalOwner": rentalOwnerData,
      "rental": rentalData,
      "units": formattedUnits // Add units to the request
    });

    print('Request URL: $url');
    print('Request Headers: $headers');
    print('Request Body: $body');

    final response = await http.put(url, headers: headers, body: body);
    final responseBody = jsonDecode(response.body);

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    final rentalOwnerResponse = responseBody['data']['rentalOwner'];
    print(
        'Rental Owner Data from Response: ${jsonEncode(rentalOwnerResponse)}');

    if (response.statusCode == 200) {
      Fluttertoast.showToast(msg: "Properties updated successfully");
    } else {
      throw Exception('Failed to update properties');
    }
  }

  Future<Map<String, dynamic>> DeleteProperties(
      {required String? id, String? reason
      // required String? companyName,
      }) async {
    // print('$apiUrl/$id');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString('adminId');
    String? token = prefs.getString('token');
    String? companyName = prefs.getString('companyName');
    print('company name $companyName');
    print(adminid);
    final http.Response response = await http.delete(
        Uri.parse('${Api_url}/api/rentals/rental/$id')
            .replace(queryParameters: {
          'company_name': companyName,
        }),
        headers: <String, String>{
          "authorization": "CRM $token",
          "id": "CRM $adminid",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({"reason": reason})
        // body: jsonEncode(<String, String>{
        //   'company_name': companyName??"",
        // }),
        );
    print(Uri.parse('${Api_url}/api/rentals/rental/$id')
        .replace(queryParameters: {
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
