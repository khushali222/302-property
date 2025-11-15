import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/Rent_collection_model.dart';
import '../constant/constant.dart';

class RentColllectionReport {
  final String baseUrl = '$Api_url/api/rental_owner/rent-collection-report';

  Future<Rentcollection_model> FetchRentColllection(
      String adminId, String selectedmonth, String selectedyear,
      {String? chargetype}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final String endpoint = '/$adminId';
    String url = '$baseUrl$endpoint?month=$selectedmonth&year=$selectedyear';

    if (chargetype != null) {
      url = '$url&selectedChargeType=$chargetype';
    }
    print(url);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );
      print("report rent collection ${response.body}");

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        print("=== FULL API JSON RESPONSE ===");
        print(parsedJson);

        // Debug: Print summary data order from JSON
        if (parsedJson['summary'] != null) {
          print("=== SUMMARY ORDER FROM JSON ===");
          List summaryList = parsedJson['summary'];
          for (int i = 0; i < summaryList.length; i++) {
            print(
                "$i: ${summaryList[i]['rentalOwnerCompany']} - \$${summaryList[i]['totalPending']}");
          }
        }

        return Rentcollection_model.fromJson(parsedJson);
      } else {
        // Handle error response
        print('Failed to load report. Status code: ${response.statusCode}');
        throw Exception('Failed to load renters insurance');
      }
    } catch (error) {
      // Handle error during fetch
      print('Error fetching rent collection reportsd: $error');
      throw Exception('Failed to load rent collection');
    }
  }
}
