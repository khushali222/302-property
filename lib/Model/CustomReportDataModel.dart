class CustomReportDataModel {
  final int statusCode;
  final String? message;
  final List<Map<String, dynamic>> data;
  final int count;

  CustomReportDataModel({
    required this.statusCode,
    this.message,
    required this.data,
    required this.count,
  });

  factory CustomReportDataModel.fromJson(Map<String, dynamic> json) {
    List<Map<String, dynamic>> list = [];
    if (json['data'] != null && json['data'] is List) {
      list = (json['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    }
    return CustomReportDataModel(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] as String?,
      data: list,
      count: json['count'] ?? 0,
    );
  }
}
