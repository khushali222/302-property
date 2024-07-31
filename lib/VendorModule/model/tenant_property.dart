class tenant_property {
  String? leaseId;
  String? startDate;
  String? endDate;
  String? rentalId;
  String? rentalAdress;

  tenant_property(
      {this.leaseId,
        this.startDate,
        this.endDate,
        this.rentalId,
        this.rentalAdress});

  tenant_property.fromJson(Map<String, dynamic> json) {
    print(json);
    leaseId = json['lease_id'];
    startDate = json['start_date'];
    endDate = json['end_date'];
    rentalId = json['rental_id'];
    rentalAdress = json['rental_adress'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lease_id'] = this.leaseId;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    data['rental_id'] = this.rentalId;
    data['rental_adress'] = this.rentalAdress;
    return data;
  }
}
