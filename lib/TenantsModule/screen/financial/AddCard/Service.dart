import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'CardModel.dart';

class AddCardService {
  // final String apiUrl =
  //     'http://192.168.1.11:4000/api/nmipayment/create-customer-vault';

  Future<CardResponse?> postCardDetails(CardModel card) async {
    print('entry');
    SharedPreferences prefs = await SharedPreferences.getInstance();
  //  String? id = prefs.getString("adminId");
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };

    final body = jsonEncode(card.toJson());
    if (kDebugMode) print('🟧 [TENANT ADD-CARD] 1) create-customer-vault REQUEST: $body');

    try {
      final response = await apiPost(
        Uri.parse('$Api_url/api/nmipayment/create-customer-vault'),
        headers: headers,
        body: body,
      );
      if (kDebugMode) print(
          '🟧 [TENANT ADD-CARD] 1) create-customer-vault RESPONSE ${response.statusCode}: ${response.body}');
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
    if (kDebugMode) print('🟧 [TENANT ADD-CARD] 1b) create-customer-billing REQUEST: $body');

    try {
      final response = await apiPost(
        Uri.parse('$Api_url/api/nmipayment/create-customer-billing'),
        headers: headers,
        body: body,
      );

      if (kDebugMode) print(
          '🟧 [TENANT ADD-CARD] 1b) create-customer-billing RESPONSE ${response.statusCode}: ${response.body}');

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
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };

    final body = jsonEncode(addCard.toJson());
    if (kDebugMode) print('🟧 [TENANT ADD-CARD] 2) addCreditCard REQUEST: $body');
    try {
      final response = await apiPost(
        Uri.parse('$Api_url/api/creditcard/addCreditCard'),
        headers: headers,
        body: body,
      );

      if (kDebugMode) print(
          '🟧 [TENANT ADD-CARD] 2) addCreditCard RESPONSE ${response.statusCode}: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle success scenario here
        if (kDebugMode) print(
            '✅ [TENANT ADD-CARD] SUCCESS — card saved (status ${response.statusCode})');
      } else {
        // Handle error scenario here
        if (kDebugMode) print('❌ [TENANT ADD-CARD] FAILED addCreditCard: ${response.statusCode}');
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

  Future<void> deletefromdatabaseCard(String billingId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
  //  String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };

    try {
      final response = await apiDelete(
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
  Future<int> deleteOneCardDelete(String customerVaultId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
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
  Future<void> deleteOneCardfromdatabase(String customerVaultId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? id = prefs.getString("tenant_id");
    String? token = prefs.getString('token');

    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $id',
    };

    try {
      final response = await apiDelete(
        Uri.parse('$Api_url/api/creditcard/deleteCardVault/$customerVaultId'),
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

  /// PCI tokenization — fetch the Collect.js public key for [adminId].
  Future<String?> getTokenizationKeyByAdmin(String adminId) async {
    try {
      final response = await apiGet(
        Uri.parse('$Api_url/api/tenant/nmi_public_key_by_admin/$adminId'),
      );
      if (response.statusCode == 200) {
        final key = jsonDecode(response.body)['publicKey'];
        if (key is String && key.isNotEmpty) return key;
      }
    } catch (e) {
      if (kDebugMode) print('getTokenizationKeyByAdmin error: $e');
    }
    return null;
  }

  /// PCI tokenization — save a card using the Collect.js payment_token.
  /// Raw PAN is never sent; only the token + non-sensitive metadata.
  Future<TokenizedSaveResult> saveTokenizedCard({
    required String paymentToken,
    String? ccBin,
    String? ccExp,
    required String firstName,
    String? lastName,
    required String email,
    required String phone,
    String? address1,
    String? city,
    String? state,
    String? zip,
    String? country,
    String? company,
    required String adminId,
    required String tenantId,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? headerId = prefs.getString('tenant_id'); // tenant sends its OWN id
    String? token = prefs.getString('token');
    final headers = {
      'Content-Type': 'application/json',
      'authorization': 'CRM $token',
      'id': 'CRM $headerId',
    };
    final body = jsonEncode({
      'payment_token': paymentToken,
      'cc_bin': ccBin,
      'cc_exp': ccExp, // web parity (AddCardForm.jsx); server ignores it, token carries expiry
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'address1': address1,
      'city': city,
      'state': state,
      'zip': zip,
      'country': country,
      'company': company,
      'admin_id': adminId,
      'tenant_id': tenantId,
    });
    try {
      final response = await apiPost(
        Uri.parse('$Api_url/api/nmipayment/tenant/add-tenant-payment'),
        headers: headers,
        body: body,
      );
      if (kDebugMode) {
        print('🟧 [TENANT ADD-CARD] add-tenant-payment RESPONSE '
            '${response.statusCode}');
      }
      Map<String, dynamic>? json;
      try {
        json = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}
      if (response.statusCode == 200) {
        return TokenizedSaveResult(
            success: true, message: json?['data']?.toString());
      }
      // Failure (403/500): message lives at data.error (data may also be a
      // plain string on some branches).
      final data = json?['data'];
      return TokenizedSaveResult(
        success: false,
        message: ((data is Map ? data['error'] : null) ??
                json?['error'] ??
                (data is String ? data : null) ??
                'Failed to add card.')
            .toString(),
      );
    } catch (e) {
      if (kDebugMode) print('saveTokenizedCard error: $e');
      return TokenizedSaveResult(
          success: false, message: 'Network error. Please try again.');
    }
  }
}

class TokenizedSaveResult {
  final bool success;
  final String? message;
  TokenizedSaveResult({required this.success, this.message});
}

class CardResponse {
  final String customerVaultId;
  final String responseCode;

  CardResponse({required this.customerVaultId, required this.responseCode});
}
