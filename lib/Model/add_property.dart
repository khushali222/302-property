// lib/models.dart
class RentalOwners {
  String? adminId;
  String? firstName;
  String? lastName;
  String? companyName;
  String? primaryEmail;
  String? phoneNumber;
  String? city;
  String? state;
  String? country;
  String? postalCode;

  RentalOwners({
     this.adminId,
     this.firstName,
     this.lastName,
     this.companyName,
     this.primaryEmail,
     this.phoneNumber,
     this.city,
     this.state,
     this.country,
     this.postalCode,
  });

  Map<String, dynamic> toJson() => {
    'admin_id': adminId,
    'rentalOwner_firstName': firstName,
    'rentalOwner_lastName': lastName,
    'rentalOwner_companyName': companyName,
    'rentalOwner_primaryEmail': primaryEmail,
    'rentalOwner_phoneNumber': phoneNumber,
    'city': city,
    'state': state,
    'country': country,
    'postal_code': postalCode,
  };
}

class Rental {
  String? adminId;
  String? propertyId;
  String? address;
  String? city;
  String? state;
  String? country;
  String? postcode;
  String? staffMemberId;

  Rental({
     this.adminId,
     this.propertyId,
     this.address,
     this.city,
     this.state,
     this.country,
     this.postcode,
     this.staffMemberId,
  });

  Map<String, dynamic> toJson() => {
    'admin_id': adminId,
    'property_id': propertyId,
    'rental_adress': address,
    'rental_city': city,
    'rental_state': state,
    'rental_country': country,
    'rental_postcode': postcode,
    'staffmember_id': staffMemberId,
  };
}

class Unit {
  String? unit;
  String? address;
  String? sqft;
  String? bath;
  String? bed;
  String? Image;

  Unit({
     this.unit,
     this.address,
     this.sqft,
     this.bath,
     this.bed,
     this.Image
  });

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

  RentalRequest({
     this.rentalOwner,
     this.rental,
     this.units,
  });

  Map<String, dynamic> toJson() => {
    'rentalOwner': rentalOwner!.toJson(),
    'rental': rental!.toJson(),
    'units': units!.map((unit) => unit.toJson()).toList(),
  };
}
