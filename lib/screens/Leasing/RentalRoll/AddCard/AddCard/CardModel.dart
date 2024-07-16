class BillingData {
  String? firstName;
  String? cardType;
  String? lastName;
  String? ccNumber;
  String? ccExp;
  String? ccType;
  String? email;
  String? ccBin;
  String? customerVaultId;
  String? binResult; // Add a field to store the bin result
  String? billingId;

  BillingData(
      {this.email,
      this.cardType,
      this.firstName,
      this.lastName,
      this.ccNumber,
      this.ccExp,
      this.ccType,
      this.ccBin,
      this.customerVaultId,
      this.binResult, // Initialize the bin result
      this.billingId});

  factory BillingData.fromJson(Map<String, dynamic> json) {
    print(json);
    if (json["@attributes"] != []) {
      print(json["@attributes"]["id"]);
    }
    // print("]from json ${json["billing_id"]}");

    String? lastName;
    if (json["last_name"] is String) {
      lastName = json["last_name"] as String?;
    } else if (json["last_name"] is Map) {
      // Handle the case when last_name is a Map, set it to null or extract specific value
      lastName =
          null; // Or json["last_name"]["some_field"] if you need a specific value
    }
    String? email;
    if (json["make"] is String) {
      lastName = json["last_name"] as String?;
    } else if (json["last_name"] is Map) {
      // Handle the case when last_name is a Map, set it to null or extract specific value
      lastName =
          null; // Or json["last_name"]["some_field"] if you need a specific value
    }

    String? firstName;
    if (json["first_name"] is String) {
      firstName = json["first_name"] as String?;
    } else if (json["first_name"] is Map) {
      // Handle the case when last_name is a Map, set it to null or extract specific value
      firstName =
          null; // Or json["last_name"]["some_field"] if you need a specific value
    }
    String? ccType;
    if (json["cc_type"] is String) {
      ccType = json["cc_type"] as String?;
    } else if (json["cc_type"] is Map) {
      // Handle the case when last_name is a Map, set it to null or extract specific value
      ccType =
          null; // Or json["last_name"]["some_field"] if you need a specific value
    }
    String? ccNumber;
    if (json["cc_number"] is String) {
      ccNumber = json["cc_number"] as String?;
    } else if (json["cc_number"] is Map) {
      // Handle the case when last_name is a Map, set it to null or extract specific value
      ccNumber =
          null; // Or json["last_name"]["some_field"] if you need a specific value
    }
    String? ccExp;
    if (json["cc_exp"] is String) {
      ccExp = json["cc_exp"] as String?;
    } else if (json["cc_exp"] is Map) {
      // Handle the case when last_name is a Map, set it to null or extract specific value
      ccExp =
          null; // Or json["last_name"]["some_field"] if you need a specific value
    }
    String? ccBin;
    if (json["cc_bin"] is String) {
      ccBin = json["cc_bin"] as String?;
    } else if (json["cc_bin"] is Map) {
      // Handle the case when last_name is a Map, set it to null or extract specific value
      ccBin =
          null; // Or json["last_name"]["some_field"] if you need a specific value
    }

    String? customerVaultId;

    if (json["customer_vault_id"] is String) {
      customerVaultId = json["customer_vault_id"] as String?;
    } else if (json["customer_vault_id"] is Map) {
      // Handle the case when last_name is a Map, set it to null or extract specific value
      customerVaultId =
          null; // Or json["last_name"]["some_field"] if you need a specific value
    }

    String? billingId;
    print(json["billing_id"].runtimeType);
    if (json["billing_id"] is int) {
      billingId = json["billing_id"].toString();
      print("assign json ${billingId}");
    } else if (json["billing_id"] is Map) {
      // Handle the case when last_name is a Map, set it to null or extract specific value
      billingId =
          null; // Or json["last_name"]["some_field"] if you need a specific value
      print('billing_id is ${json["billing_id"]}');
    }

    return BillingData(
        firstName: firstName,
        lastName: lastName,
        ccNumber: ccNumber,
        ccExp: ccExp,
        ccType: ccType,
        ccBin: ccBin,
        customerVaultId: customerVaultId,
        billingId: json["@attributes"]["id"].toString());
  }
}

class CustomerData {
  final List<BillingData> billing;

  CustomerData({required this.billing});

  factory CustomerData.fromJson(Map<String, dynamic> json) {
    // print('json: $json');
    final billingJson = json['billing'];
    List<BillingData> billingList = [];

    if (billingJson is List) {
      print('billingJson is List');
      billingList = billingJson.map((item) {
        // print('Processing item: $item');
        return BillingData.fromJson(item as Map<String, dynamic>);
      }).toList();
    } else if (billingJson is Map) {
      // print('billingJson is Map');
      billingList
          .add(BillingData.fromJson(billingJson as Map<String, dynamic>));
    } else {
      print('billingJson is neither List nor Map');
    }

    return CustomerData(billing: billingList);
  }
}

class cardModelFordelete {
  String? adminId;
  String? customerVaultId;
  String? billingId;

  cardModelFordelete({this.adminId, this.customerVaultId, this.billingId});
  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'customer_vault_id': customerVaultId,
      'billing_id': billingId,
    };
  }
}
