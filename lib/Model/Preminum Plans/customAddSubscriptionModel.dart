class customAddSubscriptionModel {
  String? adminId;
  String? planId;
  String? ccnumber;
  String? ccexp;
  String? firstName;
  String? lastName;
  String? address;
  String? email;
  String? city;
  String? state;
  String? zip;

  customAddSubscriptionModel(
      {this.adminId,
      this.planId,
      this.ccnumber,
      this.ccexp,
      this.firstName,
      this.lastName,
      this.address,
      this.email,
      this.city,
      this.state,
      this.zip});

  customAddSubscriptionModel.fromJson(Map<String, dynamic> json) {
    adminId = json['admin_id'];
    planId = json['planId'];
    ccnumber = json['ccnumber'];
    ccexp = json['ccexp'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    address = json['address'];
    email = json['email'];
    city = json['city'];
    state = json['state'];
    zip = json['zip'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['admin_id'] = this.adminId;
    data['planId'] = this.planId;
    data['ccnumber'] = this.ccnumber;
    data['ccexp'] = this.ccexp;
    data['first_name'] = this.firstName;
    data['last_name'] = this.lastName;
    data['address'] = this.address;
    data['email'] = this.email;
    data['city'] = this.city;
    data['state'] = this.state;
    data['zip'] = this.zip;
    return data;
  }
}

class CustomAddSubscriptionResponse {
  String? subscriptionId;
  String? responseCode;

  CustomAddSubscriptionResponse({this.subscriptionId, this.responseCode});

  CustomAddSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    subscriptionId = json['transactionid'];
    responseCode = json['response_code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subscription_id'] = this.subscriptionId;
    data['response_code'] = this.responseCode;
    return data;
  }
}
