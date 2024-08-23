import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import '';
import 'CardModel.dart';

class AddCardService {
  // final String apiUrl =
  //     'http://192.168.1.11:4000/api/nmipayment/create-customer-vault';

  Future<CardResponse?> postCardDetails(CardModel card) async {
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };

    final body = jsonEncode(card.toJson());

    try {
      final response = await http.post(
        Uri.parse('$Api_url/api/nmipayment/create-customer-vault'),
        headers: headers,
        body: body,
      );
      print(response.body);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body)['data'];
        String customvaultId = jsonResponse['customer_vault_id'];
        String responseCode = jsonResponse['response_code'];

        return CardResponse(
            customerVaultId: customvaultId, responseCode: responseCode);
      } else {
        print('Failed to submit card details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during POST request: $e');
      return null;
    }
  }

  Future<CardResponse?> postCardWithVaultId(CardModel card) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };
    print(headers);

    final body = jsonEncode(card.toJson());

    try {
      final response = await http.post(
        Uri.parse('$Api_url/api/nmipayment/create-customer-billing'),
        headers: headers,
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body)['data'];
        String customvaultId = jsonResponse['customer_vault_id'];
        String responseCode = jsonResponse['response_code'];

        return CardResponse(
            customerVaultId: customvaultId, responseCode: responseCode);
      } else {
        print('Failed to submit card details: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Exception during POST request: $e');
      // Handle exception scenario here
    }
  }

  Future<void> postAddCreditCard(AddCreditCard addCard) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };

    final body = jsonEncode(addCard.toJson());

    try {
      final response = await http.post(
        Uri.parse('$Api_url/api/creditcard/addCreditCard'),
        headers: headers,
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle success scenario here
        print('Add credit card submitted successfully');
      } else {
        // Handle error scenario here
        print('Failed to submit add credit card: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exception scenario here
      print('Exception during POST request: $e');
    }
  }

  Future<int> deleteCard(cardModelFordelete model) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };
    final body = jsonEncode(model.toJson());

    try {
      final response = await http.post(
        Uri.parse('$Api_url/api/nmipayment/delete-customer-billing'),
        headers: headers,
        body: body,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('Delete credit card successfully from nmi');
        // Handle success scenario here
        return response.statusCode;
      } else {
        return response.statusCode;
        // Handle error scenario here
      }
    } catch (e) {
      // Handle exception scenario here
      print('Exception during POST request: $e');
    }
    return 0;
  }

  Future<void> deletefromdatabaseCard(String billingId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };

    try {
      final response = await http.delete(
        Uri.parse('$Api_url/api/creditcard/deleteCreditCard/$billingId'),
        headers: headers,
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Handle success scenario here
        print('Delete credit card successfully from database');
      } else {
        // Handle error scenario here
        print('Failed to submit add credit card: ${response.statusCode}');
      }
    } catch (e) {
      // Handle exception scenario here
      print('Exception during POST request: $e');
    }
  }
}

class CardResponse {
  final String customerVaultId;
  final String responseCode;

  CardResponse({required this.customerVaultId, required this.responseCode});
}
