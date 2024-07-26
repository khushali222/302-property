class Cosigner {
  String? c_id;
  String? cosignerId;
  String? adminId;
  String? tenantId;
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
    this.c_id,
    this.cosignerId,
    this.adminId,
    this.tenantId,
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

  factory Cosigner.fromJson(Map<String, dynamic> json) {
    print('Consigner Data');
    json.forEach((key, value) {
      print('$key: $value');
    });
    return Cosigner(
      c_id: json['_id'],
      cosignerId: json['cosigner_id'],
      adminId: json['admin_id'],
      tenantId: json['tenant_id'],
      firstName: json['cosigner_firstName'],
      lastName: json['cosigner_lastName'],
      phoneNumber: json['cosigner_phoneNumber'].toString(),
      workNumber: json['cosigner_alternativeNumber'] ?? '',
      email: json['cosigner_email'],
      alterEmail: json['cosigner_alternativeEmail'] ?? '',
      streetAddress: json['cosigner_address'] ?? '',
      city: json['cosigner_city'] ?? '',
      country: json['cosigner_country'] ?? '',
      postalCode: json['cosigner_postalcode']?.toString() ?? '',
    );
  }
}
