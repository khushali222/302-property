import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import 'CardModel.dart';

class AddCardService {
  /// When true, API `id` header uses `staff_id` (Staff module); bodies still use `adminId`.
  final bool useStaffIdHeader;

  AddCardService({this.useStaffIdHeader = false});

  String _crmHeaderId(SharedPreferences prefs) {
    if (useStaffIdHeader) {
      return prefs.getString('staff_id') ?? prefs.getString('adminId') ?? '';
    }
    return prefs.getString('adminId') ?? '';
  }

  Future<CardResponse?> postCardDetails(CardModel card) async {
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = _crmHeaderId(prefs);
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };

    final body = jsonEncode(card.toJson());

    try {
      final response = await apiPost(
        Uri.parse('$Api_url/api/nmipayment/create-customer-vault'),
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
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
    String? id = _crmHeaderId(prefs);
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };
    final body = jsonEncode(card.toJson());

    try {
      final response = await apiPost(
        Uri.parse('$Api_url/api/nmipayment/create-customer-billing'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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
    String? id = _crmHeaderId(prefs);
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };
    final body = jsonEncode(addCard.toJson());

    try {
      final response = await apiPost(
        Uri.parse('$Api_url/api/creditcard/addCreditCard'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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

//if there is the only card there so fire this api

  Future<int> deleteOneCardDelete(String customerVaultId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final headerId = _crmHeaderId(prefs);

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $headerId',
    };
    final body = {
      'customer_vault_id': customerVaultId,
      'admin_id': adminId,
    };

    try {
      final response = await apiPost(
        Uri.parse('$Api_url/api/nmipayment/delete-customer-vault'),
        headers: headers,
        body: json.encode(body), // Encode the body to JSON
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
      print('Exception during POST request in only one card: $e');
    }
    return 0;
  }

//if there is the only card there so fire this api from the our database
  Future<void> deleteOneCardfromdatabase(String customerVaultId,String? tenant_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final headerId = _crmHeaderId(prefs);

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $headerId',
    };

    try {
      final response = await apiDelete(
        Uri.parse('$Api_url/api/creditcard/deleteCardVault/$customerVaultId'),
        headers: headers,
          body: jsonEncode({
            "tenant_id":tenant_id
          })
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

  Future<int> deleteCard(cardModelFordelete model) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = _crmHeaderId(prefs);
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };
    final body = jsonEncode(model.toJson());

    try {
      final response = await apiPost(
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

  Future<void> deletefromdatabaseCard(String billingId,String? tenant_id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = _crmHeaderId(prefs);
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };
    print(tenant_id);
    try {
      final response = await apiDelete(
        Uri.parse('$Api_url/api/creditcard/deleteCreditCard/$billingId'),
        headers: headers,
        body: jsonEncode({
          "tenant_id":tenant_id
        })
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
