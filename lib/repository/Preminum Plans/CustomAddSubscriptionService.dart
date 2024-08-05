import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/Preminum%20Plans/customAddSubscriptionModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';

class CustomAddSubscriptionService {
  Future<CustomAddSubscriptionResponse?> postCustomAddSubscription(
      customAddSubscriptionModel subscription) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };

    final body = jsonEncode(subscription.toJson());

    try {
      final response = await http.post(
        Uri.parse('$Api_url/api/nmipayment/custom-add-subscription'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body)['data'];
        print('custom subsciption status code ${response.statusCode}');
        print('custom subsciption ${response.body}');
        String subscriptionId = jsonResponse['transactionid'];
        print(jsonResponse['transactionid']);
        print('in reponsesubscriptionId $subscriptionId');
        String responseCode = jsonResponse['response_code'];

        return CustomAddSubscriptionResponse(
            subscriptionId: subscriptionId, responseCode: responseCode);
      } else {
        print('Failed to submit subscription details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during POST request: $e');
      return null;
    }
  }
}
