class Cosigner {
  String? c_id;
  String firstName;
  String lastName;
  String phoneNumber;
  String workNumber;
  String email;
  String alterEmail;
  String streetAddress;
  String city;
  String country;
  String postalCode;

  Cosigner({
    this.c_id ,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    this.workNumber = '',
    required this.email,
    this.alterEmail = '',
    required this.streetAddress,
    required this.city,
    required this.country,
    required this.postalCode,
  });
}