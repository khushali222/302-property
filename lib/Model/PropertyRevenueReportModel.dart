class PropertyRevenueReportModel {
  int? statusCode;
  PropertyRevenueReportData? data;
  String? message;

  PropertyRevenueReportModel({
    this.statusCode,
    this.data,
    this.message,
  });

  PropertyRevenueReportModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    data = json['data'] != null
        ? PropertyRevenueReportData.fromJson(json['data'])
        : null;
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['statusCode'] = this.statusCode;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    data['message'] = this.message;
    return data;
  }
}

class PropertyRevenueReportData {
  List<PropertyRevenue>? properties;
  PropertyRevenueSummary? summary;

  PropertyRevenueReportData({
    this.properties,
    this.summary,
  });

  PropertyRevenueReportData.fromJson(Map<String, dynamic> json) {
    if (json['properties'] != null) {
      properties = <PropertyRevenue>[];
      json['properties'].forEach((v) {
        properties!.add(PropertyRevenue.fromJson(v));
      });
    }
    summary = json['summary'] != null
        ? PropertyRevenueSummary.fromJson(json['summary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (this.properties != null) {
      data['properties'] = this.properties!.map((v) => v.toJson()).toList();
    }
    if (this.summary != null) {
      data['summary'] = this.summary!.toJson();
    }
    return data;
  }
}

class PropertyRevenue {
  String? rentalId;
  String? rentalAddress;
  PeriodData? currentPeriod;
  PeriodData? previousPeriod;
  double? revenueChangePercentage;
  double? revenueChangeAmount;

  PropertyRevenue({
    this.rentalId,
    this.rentalAddress,
    this.currentPeriod,
    this.previousPeriod,
    this.revenueChangePercentage,
    this.revenueChangeAmount,
  });

  PropertyRevenue.fromJson(Map<String, dynamic> json) {
    rentalId = json['rental_id'];
    rentalAddress = json['rental_address'];
    currentPeriod = json['current_period'] != null
        ? PeriodData.fromJson(json['current_period'])
        : null;
    previousPeriod = json['previous_period'] != null
        ? PeriodData.fromJson(json['previous_period'])
        : null;
    revenueChangePercentage = json['revenue_change_percentage'] != null
        ? (json['revenue_change_percentage'] as num).toDouble()
        : null;
    revenueChangeAmount = json['revenue_change_amount'] != null
        ? (json['revenue_change_amount'] as num).toDouble()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['rental_id'] = this.rentalId;
    data['rental_address'] = this.rentalAddress;
    if (this.currentPeriod != null) {
      data['current_period'] = this.currentPeriod!.toJson();
    }
    if (this.previousPeriod != null) {
      data['previous_period'] = this.previousPeriod!.toJson();
    }
    data['revenue_change_percentage'] = this.revenueChangePercentage;
    data['revenue_change_amount'] = this.revenueChangeAmount;
    return data;
  }
}

class PeriodData {
  double? revenue;
  int? paymentCount;
  String? startDate;
  String? endDate;

  PeriodData({
    this.revenue,
    this.paymentCount,
    this.startDate,
    this.endDate,
  });

  PeriodData.fromJson(Map<String, dynamic> json) {
    revenue =
        json['revenue'] != null ? (json['revenue'] as num).toDouble() : null;
    paymentCount = json['payment_count'];
    startDate = json['start_date'];
    endDate = json['end_date'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['revenue'] = this.revenue;
    data['payment_count'] = this.paymentCount;
    data['start_date'] = this.startDate;
    data['end_date'] = this.endDate;
    return data;
  }
}

class PropertyRevenueSummary {
  double? totalCurrentRevenue;
  double? totalPreviousRevenue;
  double? totalRevenueChangePercentage;
  double? totalRevenueChangeAmount;
  PeriodData? currentPeriod;
  PeriodData? previousPeriod;

  PropertyRevenueSummary({
    this.totalCurrentRevenue,
    this.totalPreviousRevenue,
    this.totalRevenueChangePercentage,
    this.totalRevenueChangeAmount,
    this.currentPeriod,
    this.previousPeriod,
  });

  PropertyRevenueSummary.fromJson(Map<String, dynamic> json) {
    totalCurrentRevenue = json['total_current_revenue'] != null
        ? (json['total_current_revenue'] as num).toDouble()
        : null;
    totalPreviousRevenue = json['total_previous_revenue'] != null
        ? (json['total_previous_revenue'] as num).toDouble()
        : null;
    totalRevenueChangePercentage = json['total_revenue_change_percentage'] !=
            null
        ? (json['total_revenue_change_percentage'] as num).toDouble()
        : null;
    totalRevenueChangeAmount = json['total_revenue_change_amount'] != null
        ? (json['total_revenue_change_amount'] as num).toDouble()
        : null;
    currentPeriod = json['current_period'] != null
        ? PeriodData.fromJson(json['current_period'])
        : null;
    previousPeriod = json['previous_period'] != null
        ? PeriodData.fromJson(json['previous_period'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['total_current_revenue'] = this.totalCurrentRevenue;
    data['total_previous_revenue'] = this.totalPreviousRevenue;
    data['total_revenue_change_percentage'] = this.totalRevenueChangePercentage;
    data['total_revenue_change_amount'] = this.totalRevenueChangeAmount;
    if (this.currentPeriod != null) {
      data['current_period'] = this.currentPeriod!.toJson();
    }
    if (this.previousPeriod != null) {
      data['previous_period'] = this.previousPeriod!.toJson();
    }
    return data;
  }
}

