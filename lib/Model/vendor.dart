class Vendor {
  String? adminId;
  String? vendorId;
  String? vendorName;
  String? vendorPhoneNumber;
  String? vendorEmail;
  String? vendorPassword;
  String? trade;

  /// Web parity: "This vendor receives 1099 forms" on Add/Edit Vendor.
  /// Server schema defaults it to false, so a vendor created without it was
  /// silently never flagged for 1099 tax reporting.
  bool? is1099;

  /// Web parity: "Tax ID (EIN/SSN)", shown on Add/Edit Vendor only when the
  /// 1099 box is ticked. Present for Admin AND Staff, because both roles land
  /// on the same web component (/staff/staffaddvendor routes to AddVendor.jsx;
  /// StaffAddVendor.jsx is dead code).
  ///
  /// WRITING it is open to both roles; READING the stored value back is not —
  /// the server hides tax_id from the normal vendor response and returns 403
  /// to any role other than admin/super_admin (Vendor.js: "Only administrators
  /// may access tax ID information"). So only the Admin edit form shows the
  /// masked current value; Staff sees an empty field, exactly as on web.
  ///
  /// The value handed back on edit is MASKED, so only send this when the user
  /// has actually typed a new one — otherwise the mask would overwrite the
  /// real number.
  String? taxId;

  Vendor({
    this.adminId,
    this.vendorId,

    this.vendorName,
    this.vendorPhoneNumber,
    this.vendorEmail,
    this.vendorPassword,
    this.trade,
    this.is1099,
    this.taxId,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      adminId: json['admin_id'],
      vendorId: json['vendor_id'],
      vendorName: json['vendor_name'],
      vendorPhoneNumber: json['vendor_phoneNumber']?.toString(),
      vendorEmail: json['vendor_email'],
      vendorPassword: json['vendor_password'],
      trade: json['trade'],
      is1099: json['is_1099'] is bool ? json['is_1099'] : null,
      taxId: json['tax_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'admin_id': adminId,
      'vendor_name': vendorName,
      'vendor_phoneNumber': vendorPhoneNumber,
      'vendor_email': vendorEmail,
      'vendor_password': vendorPassword,
      'trade': trade,
      'is_1099': is1099 ?? false,
    };
    // Only include tax_id when there is a real value to save. Web does the
    // same (`if (!taxIdEdited || !trimmedValues.tax_id) delete
    // trimmedValues.tax_id`) so an untouched edit form cannot write the
    // masked placeholder back over the stored number.
    final tid = taxId?.trim() ?? '';
    if (tid.isNotEmpty) {
      map['tax_id'] = tid;
    }
    return map;
  }
}
