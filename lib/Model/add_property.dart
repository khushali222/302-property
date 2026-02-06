// lib/models.dart
class RentalOwners {
  String? adminId;
  String? rentalownersid;
  String? firstName;
  String? companyName;
  String? primaryEmail;
  String? phoneNumber;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  List<ProcessorLists>? processorList;
  List<Map<String, String>>? processorid;

  RentalOwners({
    this.adminId,
    this.rentalownersid,
    this.firstName,
    this.companyName,
    this.primaryEmail,
    this.phoneNumber,
    this.processorList,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.processorid,
  });

  Map<String, dynamic> toJson() => {
        'admin_id': adminId,
        'rentalowner_id': rentalownersid,
        'rentalOwner_name': firstName,
        'rentalOwner_companyName': companyName,
        'rentalOwner_primaryEmail': primaryEmail,
        'rentalOwner_phoneNumber': phoneNumber,
        'city': city,
        'state': state,
        'country': country,
        'postal_code': postalCode,
        if (processorList != null) 'processor_list': processorList,
        if (processorid != null) 'processor_list': processorid,
      };
}

class InsuredValue {
  String? year;
  String? insuredValue;

  InsuredValue({this.year, this.insuredValue});

  Map<String, dynamic> toJson() => {
        'year': year,
        'insured_value': insuredValue,
      };
}

class Rental {
  String? rentalId;
  String? adminId;
  String? propertyId;
  String? address;
  String? city;
  String? state;
  String? country;
  String? postcode;
  String? staffMemberId;
  String? processor_id;
  String? placedInService;
  List<InsuredValue>? insuredValues;

  Rental(
      {this.adminId,
      this.rentalId,
      this.propertyId,
      this.address,
      this.city,
      this.state,
      this.country,
      this.postcode,
      this.staffMemberId,
      this.processor_id,
      this.placedInService,
      this.insuredValues});

  Map<String, dynamic> toJson() => {
        // rentalId: json['rental_id'] ?? "",
        ' rental_id': rentalId,
        'admin_id': adminId,
        'property_id': propertyId,
        'rental_adress': address,
        'rental_city': city,
        'rental_state': state,
        'rental_country': country,
        'rental_postcode': postcode,
        'staffmember_id': staffMemberId,
        if (placedInService != null && placedInService!.isNotEmpty)
          'placed_in_service': placedInService,
        if (insuredValues != null && insuredValues!.isNotEmpty)
          'insured_values': insuredValues!.map((iv) => iv.toJson()).toList(),
        // 'processor_id':processor_id
      };
}

class Unit {
  String? unit;
  String? address;
  String? sqft;
  String? bath;
  String? bed;
  String? Image;

  Unit({this.unit, this.address, this.sqft, this.bath, this.bed, this.Image});

  Map<String, dynamic> toJson() => {
        'rental_unit': unit,
        'rental_unit_adress': address,
        'rental_sqft': sqft,
        'rental_bath': bath,
        'rental_bed': bed,
        'rental_images': Image,
      };
}

class RentalRequest {
  RentalOwners? rentalOwner;
  Rental? rental;
  List<Unit>? units;
  String? notificationTime;

  RentalRequest({
    this.rentalOwner,
    this.rental,
    this.units,
    this.notificationTime,
  });

  Map<String, dynamic> toJson() => {
        'rentalOwner': rentalOwner!.toJson(),
        'rental': rental!.toJson(),
        'units': units!.map((unit) => unit.toJson()).toList(),
        'notificationTime': notificationTime,
      };
}

class ProcessorLists {
  String? processorId;
  String? sId;

  ProcessorLists({this.processorId, this.sId});

  factory ProcessorLists.fromJson(Map<String, dynamic> json) {
    return ProcessorLists(
      processorId: json['processor_id'],
      sId: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['processor_id'] = this.processorId;
    data['_id'] = this.sId;
    return data;
  }
}
