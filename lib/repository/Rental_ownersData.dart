import 'dart:convert';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Rental/Rentalowner/rentalowner_summery.dart';

import '../Model/RentalOwnersData.dart';
import 'package:http/http.dart'as http;

import '../constant/constant.dart';
import '../model/rentalOwner.dart';
import '../model/rentalowners_summery.dart';

class RentalOwnerService {
 // final String baseUrl = 'http://192.168.1.26:4000/api/rentals';

  Future<List<RentalOwner>> fetchRentalOwners(String? adminId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    adminId = prefs.getString("adminId");
    final response = await http.get(Uri.parse('$Api_url/api/rentals/rental-owners/$adminId'));
    print(adminId);
    print(response.body);
  //  print('$baseUrl/rental-owners/$adminId');
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => RentalOwner.fromJson(data)).toList();
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

  // Future<void> updateRentalOwner(RentalOwnerData rentalOwner) async {
  //
  //   final url = Uri.parse('${Api_url}/api/rentals/rentals/${rentalOwner.rentalownerId}');
  //   print(rentalOwner.rentalownerId);
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final String? token = prefs.getString("token");
  //
  //   final headers = {
  //     'Content-Type': 'application/json',
  //     'Authorization': 'Bearer $token',
  //   };
  //   final body = jsonEncode({
  //     "rentalOwner": {
  //       "admin_id": rentalOwner.adminId,
  //       "rentalowner_id": rentalOwner.rentalownerId,
  //       "rentalOwner_firstName": rentalOwner.rentalOwnerFirstName,
  //       "rentalOwner_lastName": rentalOwner.rentalOwnerLastName,
  //       "rentalOwner_companyName": rentalOwner.rentalOwnerCompanyName,
  //       "rentalOwner_primaryEmail": rentalOwner.rentalOwnerPrimaryEmail,
  //       "rentalOwner_phoneNumber": rentalOwner.rentalOwnerPhoneNumber,
  //       "rentalOwner_homeNumber": rentalOwner.rentalOwnerHomeNumber,
  //       "rentalOwner_businessNumber": rentalOwner.rentalOwnerBusinessNumber,
  //       "street_address": rentalOwner.streetAddress,
  //       "start_date": rentalOwner.startDate,
  //       "end_date": rentalOwner.endDate,
  //       "texpayer_id": rentalOwner.texpayerId,
  //       "text_identityType": rentalOwner.textIdentityType,
  //       "city": rentalOwner.city,
  //       "state":rentalOwner.state,
  //       "country": rentalOwner.country,
  //       "postal_code": rentalOwner.postalCode,
  //     },
  //
  //   });
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
  Future<Map<String, dynamic>> Edit_Rentalowners({
    String? sId,
    String? rentalownerId,
    String? adminId,
    String? rentalOwnerName,
    String? rentalOwnerCompanyName,
    String? rentalOwnerPrimaryEmail,
    String? rentalOwnerAlternateEmail,
    String? rentalOwnerPhoneNumber,
    String? rentalOwnerHomeNumber,
    String? rentalOwnerBusinessNumber,
    String? birthDate,
    String? startDate,
    String? endDate,
    String? texpayerId,
    String? textIdentityType,
    String? streetAddress,
    String? city,
    String? state,
    String? country,
    String? postalCode,
  }) async {
    final Map<String, dynamic> data = {
      "admin_id": adminId,
      "rentalowner_id": rentalownerId,
      "rentalOwner_name": rentalOwnerName,
      "rentalOwner_companyName": rentalOwnerCompanyName,
      "rentalOwner_primaryEmail": rentalOwnerPrimaryEmail,
      "rentalOwner_phoneNumber": rentalOwnerPhoneNumber,
      "rentalOwner_homeNumber": rentalOwnerHomeNumber,
      "rentalOwner_businessNumber": rentalOwnerBusinessNumber,
      "street_address": streetAddress,
      "start_date": startDate,
      "end_date": endDate,
      "texpayer_id": texpayerId,
      "text_identityType": textIdentityType,
      "city": city,
      "state":state,
      "country": country,
      "postal_code": postalCode,
    };
    print(data);
    String apiUrl = "${Api_url}/api/rental_owner/rental_owner/$rentalownerId";
    print('rentalowners ${rentalownerId}');
    print(apiUrl);
    final http.Response response = await
    http.put(
       Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    print(jsonEncode(data));
    print(response.body);
    var responseData = json.decode(response.body);
    if (responseData["statusCode"] == 200) {
      Fluttertoast.showToast(msg: responseData["message"]);
      return json.decode(response.body);
    } else {
      Fluttertoast.showToast(msg: responseData["message"]);
      throw Exception('Failed to add RentalOwners ');
    }
  }

  Future<Map<String, dynamic>> DeleteRentalOwners({
    required String? rentalownerId
  }) async {
    final http.Response response = await http.delete(
      Uri.parse('$Api_url/api/rentals/rental-owners/$rentalownerId'),
      headers: <String, String>{
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

  Future<List<RentalOwner>> fetchRentalOwnerssummery(String rentalOwnerId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
   // adminId = prefs.getString("adminId");
   //  rentalOwnerId = "1718715476950"
    print(rentalOwnerId);
    print(rentalOwnerId);
    final response = await http.get(Uri.parse('$Api_url/api/rental_owner/rentalowner_details/${rentalOwnerId}'));
   // print(adminId);
    //print(response.body);
    //  print('$baseUrl/rental-owners/$adminId');
   // print(response.body);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)["data"];
      return jsonResponse.map((data) => RentalOwner.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load rental owners');
    }
  }

  //
  // Future<List<RentalOwnerSummey>> fetchRentalOwnersSummary(String rentalOwnerId) async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   final response = await http.get(Uri.parse('$Api_url/api/rental_owner/rentalowner_details/$rentalOwnerId'));
  //
  //   if (response.statusCode == 200) {
  //     List<dynamic> jsonResponse = json.decode(response.body);
  //     return jsonResponse.map((data) => RentalOwnerSummey.fromJson(data)).toList();
  //   } else {
  //     throw Exception('Failed to load rental owners');
  //   }
  // }

  // Future<RentalOwnerSummey> fetchRentalOwnerSummary(String rentalOwnerId) async {
  //   final response = await http.get(Uri.parse('$Api_url/api/rental_owner/rentalowner_details/$rentalOwnerId'));
  // print(response.body);
  // print(rentalOwnerId);
  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> jsonResponse = json.decode(response.body);
  //     return RentalOwnerSummey.fromJson(jsonResponse); // Assuming your model can handle a single object
  //   } else {
  //     throw Exception('Failed to load rental owner');
  //   }
  // }

}