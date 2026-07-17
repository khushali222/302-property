import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/Preminum%20Plans/GetCardDetailModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'dart:convert';

class GetCardDetailService {
  Future<Map<String, dynamic>> fetchSubscriptionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? staffId = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await apiGet(
      Uri.parse('$Api_url/api/nmi-keys/nmi-keys/$adminId'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $staffId", // staff's own id (web parity)
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to load subscription data');
    }
  }

  Future<List<CardData>?> fetchCardDetail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("staff_id");
    String? token = prefs.getString('token');

    final url = Uri.parse('$Api_url/api/plans/plans');
    final response = await apiGet(
      url,
      headers: {
        "authorization": "CRM $token",
        "id": "CRM ${prefs.getString('staff_id') ?? adminId}", // staff's own id (web parity)
      },
    );

    if (response.statusCode == 200) {
      // print(response.body);
      final parsedJson = jsonDecode(response.body);
      print(parsedJson);
      final cardDetails = CardsDetailModel.fromJson(parsedJson);
      print(cardDetails);
      return cardDetails.data ?? [];
    } else {
      print('Failed to fetch vendors: ${response.body}');
      return [];
    }
  }
}
