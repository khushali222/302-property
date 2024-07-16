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
