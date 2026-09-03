
import 'package:three_zero_two_property/constant/constant.dart';

class ExpiringRentersInsuranceResponse {
  final int? statusCode;
  final List<ExpiringRentersInsuranceData>? data;
  final Metadata? metadata;
  final String? message;

  ExpiringRentersInsuranceResponse({
    this.statusCode,
    this.data,
    this.metadata,
    this.message,
  });

  factory ExpiringRentersInsuranceResponse.fromJson(Map<String, dynamic> json) {
    return ExpiringRentersInsuranceResponse(
      statusCode: asIntN(json['statusCode']),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) =>
              ExpiringRentersInsuranceData.fromJson(e as Map<String, dynamic>))
          .toList(),
      metadata:
          json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'data': data?.map((e) => e.toJson()).toList(),
      'metadata': metadata?.toJson(),
      'message': message,
    };
  }
}

class ExpiringRentersInsuranceData {
  final String? id;
  final String? insuranceCompany;
  final String? policyId;
  final String? expirationDate;
  final double?
      liabilityCoverage; // Changed from int? to double? to handle both int and double
  final String? rentersInsuranceId;
  final String? leaseId;
  final String? tenantId;
  final String? tenantName;
  final String? rentalAddress;

  // Additional fields that might be present in the actual API response
  final String? response;
  final double? totalAmount; // Handle total_amount that can be int or double
  final String? responseText;
  final String? rentalUnit;
  final TenantInfo? tenant;
  final String? paymentType;
  final String? date;
  final String? timestamp;
  final String? state;

  ExpiringRentersInsuranceData({
    this.id,
    this.insuranceCompany,
    this.policyId,
    this.expirationDate,
    this.liabilityCoverage,
    this.rentersInsuranceId,
    this.leaseId,
    this.tenantId,
    this.tenantName,
    this.rentalAddress,
    this.response,
    this.totalAmount,
    this.responseText,
    this.rentalUnit,
    this.tenant,
    this.paymentType,
    this.date,
    this.timestamp,
    this.state,
  });

  factory ExpiringRentersInsuranceData.fromJson(Map<String, dynamic> json) {
    return ExpiringRentersInsuranceData(
      id: json['_id'] as String?,
      insuranceCompany: json['insurance_company'] as String?,
      policyId: json['policy_id'] as String?,
      expirationDate: json['expiration_date'] ?? "",
      liabilityCoverage:
          _parseNumericField(json['liability_coverage']), // Use helper function
      rentersInsuranceId: json['renters_insurance_id'] as String?,
      leaseId: json['lease_id'] as String?,
      tenantId: json['tenant_id'] as String?,
      tenantName: json['tenant_name'] as String?,
      rentalAddress: json['rental_address'] as String?,
      response: json['response'] as String?,
      totalAmount:
          _parseNumericField(json['total_amount']), // Use helper function
      responseText: json['responseText'] as String?,
      rentalUnit: json['rental_unit'] as String?,
      tenant:
          json['tenant'] != null ? TenantInfo.fromJson(json['tenant']) : null,
      paymentType: json['payment_type'] as String?,
      date: json['date'] as String?,
      timestamp: json['timestamp'] as String?,
      state: json['state'] as String?,
    );
  }

  // Helper function to safely parse numeric fields that can be int or double
  static double? _parseNumericField(dynamic value) {
    if (value == null) return null;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'insurance_company': insuranceCompany,
      'policy_id': policyId,
      'expiration_date': expirationDate,
      'liability_coverage': liabilityCoverage,
      'renters_insurance_id': rentersInsuranceId,
      'lease_id': leaseId,
      'tenant_id': tenantId,
      'tenant_name': tenantName,
      'rental_address': rentalAddress,
      'response': response,
      'total_amount': totalAmount,
      'responseText': responseText,
      'rental_unit': rentalUnit,
      'tenant': tenant?.toJson(),
      'payment_type': paymentType,
      'date': date,
      'timestamp': timestamp,
      'state': state,
    };
  }
}

class TenantInfo {
  final String? tenantId;
  final String? tenantName;

  TenantInfo({
    this.tenantId,
    this.tenantName,
  });

  factory TenantInfo.fromJson(Map<String, dynamic> json) {
    return TenantInfo(
      tenantId: json['tenant_id'] as String?,
      tenantName: json['tenant_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenant_id': tenantId,
      'tenant_name': tenantName,
    };
  }
}

class Metadata {
  final int? total;
  final int? page;

  Metadata({
    this.total,
    this.page,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      total: _parseIntField(json['total']), // Use helper function
      page: _parseIntField(json['page']), // Use helper function
    );
  }

  // Helper function to safely parse int fields
  static int? _parseIntField(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
    };
  }
}
