class CardModel {
  String? firstName;
  String? lastName;
  String? ccnumber;
  String? ccexp;
  String? address1;
  String? address2;
  String? city;
  String? state;
  String? zip;
  String? country;
  String? company;
  String? phone;
  String? email;
  String? adminId;
  String? billingId;
  String? customervaultid;

  CardModel(
      {this.firstName,
      this.lastName,
      this.ccnumber,
      this.ccexp,
      this.address1,
      this.address2,
      this.city,
      this.state,
      this.zip,
      this.country,
      this.company,
      this.phone,
      this.email,
      this.adminId,
      this.billingId,
      this.customervaultid});

  CardModel.fromJson(Map<String, dynamic> json) {
    firstName = json['first_name'];
    lastName = json['last_name'];
    ccnumber = json['ccnumber'];
    ccexp = json['ccexp'];
    address1 = json['address1'];
    address2 = json['address2'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
    country = json['country'];
    company = json['company'];
    phone = json['phone'];
    email = json['email'];
    adminId = json['admin_id'];
    billingId = json['billing_id'];
    customervaultid = json['customer_vault_id'];
  }

  Map<String, dynamic> toJson() {
    print('tojson ${firstName}');
    print('tojson ${lastName}');
    print('tojson ${ccexp}');
    print('tojson ${ccnumber}');
    print('tojson ${address1}');
    print('tojson ${city}');
    print('tojson ${state}');
    print('tojson ${zip}');
    print('tojson ${country}');
    print('tojson ${company}');
    print('tojson ${phone}');
    print('tojson ${email}');
    print('tojson ${adminId}');
    print('tojson ${billingId}');

    print(firstName);
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['ccnumber'] = this.ccnumber;
    data['ccexp'] = this.ccexp;
    data['address1'] = this.address1;
    data['address2'] = this.address2;
    data['city'] = this.city;
    data['state'] = this.state;
    data['zip'] = this.zip;
    data['country'] = this.country;
    data['company'] = this.company;
    data['phone'] = this.phone;
    data['email'] = this.email;
    data['admin_id'] = this.adminId;
    data['billing_id'] = this.billingId;
    data['customer_vault_id'] = this.customervaultid;
    return data;
  }
}

class AddCreditCard {
  String? tenantId;
  String? customerVaultId;
  String? responseCode;
  String? billingId;

  AddCreditCard(
      {this.tenantId, this.customerVaultId, this.responseCode, this.billingId});

  AddCreditCard.fromJson(Map<String, dynamic> json) {
    tenantId = json['tenant_id'];
    customerVaultId = json['customer_vault_id'];
    responseCode = json['response_code'];
    billingId = json['billing_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['tenant_id'] = this.tenantId;
    data['customer_vault_id'] = this.customerVaultId;
    data['response_code'] = this.responseCode;
    data['billing_id'] = this.billingId;
    return data;
  }
}
class BillingData {
  String? firstName;
  String? cardType;
  String? lastName;
  String? ccNumber;
  String? ccExp;
  String? ccType;
  String? ccBin;
  String? customerVaultId;
  String? binResult; // Add a field to store the bin result
  String? billingId;
  String? address_1;
  String? company;
  String? email;



  BillingData(
      {this.cardType,
        this.firstName,
        this.lastName,
        this.ccNumber,
        this.ccExp,
        this.ccType,
        this.ccBin,
        this.customerVaultId,
        this.binResult,
        this.email,
        this.address_1,
        this.company,// Initialize the bin result
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
    String? companyName;
    if (json["company"] is String) {
      companyName = json["company"] as String?;
    } else if (json["company"] is Map) {
      // Handle the case when last_name is a Map, set it to null or extract specific value
      companyName =
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
        billingId: json["@attributes"]["id"].toString(),
        email: json["email"].runtimeType == Map ? null : json["email"],
        address_1: json["address_1"].runtimeType == Map ? null : json["address_1"],
        company: companyName

    );

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

