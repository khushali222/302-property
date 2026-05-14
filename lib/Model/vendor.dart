class Vendor {
  String? adminId;
  String? vendorId;
  String? vendorName;
  String? vendorPhoneNumber;
  String? vendorEmail;
  String? vendorPassword;
  String? trade;


  Vendor({
    this.adminId,
    this.vendorId,

    this.vendorName,
    this.vendorPhoneNumber,
    this.vendorEmail,
    this.vendorPassword,
    this.trade,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      adminId: json['admin_id'],
      vendorId: json['vendor_id'],
      vendorName: json['vendor_name'],
      vendorPhoneNumber: json['vendor_phoneNumber'].toString(),
      vendorEmail: json['vendor_email'],
      vendorPassword: json['vendor_password'],
      trade: json['trade'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admin_id': adminId,
      'vendor_name': vendorName,
      'vendor_phoneNumber': vendorPhoneNumber,
      'vendor_email': vendorEmail,
      'vendor_password': vendorPassword,
      if (trade != null && trade!.isNotEmpty) 'trade': trade,
    };
  }
}
