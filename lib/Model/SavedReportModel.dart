class SavedReportModel {
  final int statusCode;
  final String? message;
  final List<SavedReport> data;
  final int count;

  SavedReportModel({
    required this.statusCode,
    this.message,
    required this.data,
    required this.count,
  });

  factory SavedReportModel.fromJson(Map<String, dynamic> json) {
    List<SavedReport> list = [];
    if (json['data'] != null && json['data'] is List) {
      list = (json['data'] as List)
          .map((e) => SavedReport.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return SavedReportModel(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] as String?,
      data: list,
      count: json['count'] ?? 0,
    );
  }
}

class SavedReport {
  final String id;
  final String reportId;
  final String adminId;
  final String name;
  final String description;
  final List<String> selectedColumns;
  final String dateRange;
  final String? selectedStartDate;
  final String? selectedEndDate;
  final bool includeHistory;
  final bool isDelete;
  final String? createdAt;
  final String? updatedAt;
  final Map<String, dynamic>? dynamicFieldConfigs;

  SavedReport({
    required this.id,
    required this.reportId,
    required this.adminId,
    required this.name,
    required this.description,
    required this.selectedColumns,
    required this.dateRange,
    this.selectedStartDate,
    this.selectedEndDate,
    required this.includeHistory,
    required this.isDelete,
    this.createdAt,
    this.updatedAt,
    this.dynamicFieldConfigs,
  });

  factory SavedReport.fromJson(Map<String, dynamic> json) {
    List<String> cols = [];
    if (json['selectedColumns'] != null && json['selectedColumns'] is List) {
      cols = (json['selectedColumns'] as List).map((e) => e.toString()).toList();
    }
    Map<String, dynamic>? dynamicFieldConfigs;
    if (json['dynamicFieldConfigs'] != null && json['dynamicFieldConfigs'] is Map) {
      dynamicFieldConfigs = Map<String, dynamic>.from(json['dynamicFieldConfigs'] as Map);
    }
    return SavedReport(
      id: json['_id']?.toString() ?? '',
      reportId: json['report_id']?.toString() ?? '',
      adminId: json['admin_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      selectedColumns: cols,
      dateRange: json['dateRange']?.toString() ?? '',
      selectedStartDate: json['selectedStartDate']?.toString(),
      selectedEndDate: json['selectedEndDate']?.toString(),
      includeHistory: json['includeHistory'] == true,
      isDelete: json['is_delete'] == true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
      dynamicFieldConfigs: dynamicFieldConfigs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'selectedColumns': selectedColumns,
      'dateRange': dateRange,
      'selectedStartDate': selectedStartDate,
      'selectedEndDate': selectedEndDate,
      'includeHistory': includeHistory,
    };
  }
}

/// Response for GET /api/reports/saved/:reportId (single report)
class SavedReportSingleModel {
  final int statusCode;
  final String? message;
  final SavedReport? data;

  SavedReportSingleModel({
    required this.statusCode,
    this.message,
    this.data,
  });

  factory SavedReportSingleModel.fromJson(Map<String, dynamic> json) {
    SavedReport? report;
    if (json['data'] != null && json['data'] is Map) {
      report = SavedReport.fromJson(
        json['data'] as Map<String, dynamic>,
      );
    }
    return SavedReportSingleModel(
      statusCode: json['statusCode'] ?? 0,
      message: json['message'] as String?,
      data: report,
    );
  }
}
