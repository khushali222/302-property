import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constant/constant.dart';
import '../model/rentalOwner.dart';

// Future<List<RentalOwner>> fetchRentalOwners1() async {
//   final rentalOwnersDataResponse = await http.get(Uri.parse('$Api_url/api/rentals/rental-owners/$adminId'));
//   final rentalOwnersSummeryResponse = await http.get(Uri.parse('$Api_url/api/rental_owner/rentalowner_details/${rentalOwnerId}'));
//
//   if (rentalOwnersDataResponse.statusCode == 200 && rentalOwnersSummeryResponse.statusCode == 200) {
//     List<dynamic> rentalOwnersDataJson = json.decode(rentalOwnersDataResponse.body);
//     List<dynamic> rentalOwnersSummeryJson = json.decode(rentalOwnersSummeryResponse.body)['data'];
//
//     List<RentalOwner> rentalOwners = rentalOwnersDataJson.map((json) => RentalOwner.fromJson(json)).toList();
//
//     for (var rentalOwnerJson in rentalOwnersSummeryJson) {
//       RentalOwner rentalOwner = RentalOwner.fromJson(rentalOwnerJson);
//       rentalOwners.add(rentalOwner);
//     }
//
//     return rentalOwners;
//   } else {
//     throw Exception('Failed to load rental owners');
//   }
// }
