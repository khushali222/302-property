import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../Model/RentalOwnersData.dart';
import 'package:http/http.dart'as http;

import '../constant/constant.dart';

class RentalOwnerService {
 // final String baseUrl = 'http://192.168.1.26:4000/api/rentals';

  Future<List<RentalOwnerData>> fetchRentalOwners(String? adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adminId = prefs.getString("adminId");
    final response = await http.get(Uri.parse('$Api_url/api/rentals/rental-owners/$adminId'));
    //print(response.body);
  //  print('$baseUrl/rental-owners/$adminId');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => RentalOwnerData.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load rental owners');
    }
  }
  Future<bool> addRentalOwner(RentalOwnerData rentalOwner) async {
    final response = await http.post(
      Uri.parse("$Api_url/api/rental_owner/rental_owner"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(rentalOwner.toJson()),
    );

    print(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      // Success
      print('Rental owner added successfully');
      return true;
    } else {
      // Failure
      return false;
      throw Exception('Failed to add rental owner');
    }
  }

}