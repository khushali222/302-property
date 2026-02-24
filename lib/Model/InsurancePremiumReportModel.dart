class InsurancePremiumReportModel {
  final bool success;
  final List<String> years;
  final List<InsurancePremiumRow> rows;

  InsurancePremiumReportModel({
    required this.success,
    required this.years,
    required this.rows,
  });

  factory InsurancePremiumReportModel.fromJson(Map<String, dynamic> json) {
    return InsurancePremiumReportModel(
      success: json['success'] ?? false,
      years: json['years'] != null
          ? List<String>.from(json['years'])
          : [],
      rows: json['rows'] != null
          ? (json['rows'] as List)
              .map((item) => InsurancePremiumRow.fromJson(item))
              .toList()
          : [],
    );
  }
}

class InsurancePremiumRow {
  final String rentalId;
  final String address;
  final Map<String, dynamic> yearValues; // Dynamic year keys with values

  InsurancePremiumRow({
    required this.rentalId,
    required this.address,
    required this.yearValues,
  });

  factory InsurancePremiumRow.fromJson(Map<String, dynamic> json) {
    // Extract rental_id and address
    final rentalId = json['rental_id'] ?? '';
    final address = json['address'] ?? '';

    // Extract all year keys and their values (excluding rental_id and address)
    final yearValues = <String, dynamic>{};
    json.forEach((key, value) {
      if (key != 'rental_id' && key != 'address') {
        yearValues[key] = value;
      }
    });

    return InsurancePremiumRow(
      rentalId: rentalId,
      address: address,
      yearValues: yearValues,
    );
  }

  // Get value for a specific year
  dynamic getValueForYear(String year) {
    return yearValues[year];
  }
}
