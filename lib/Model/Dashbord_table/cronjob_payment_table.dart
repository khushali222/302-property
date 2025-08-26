class LeaseResponse {
  final int? statusCode;
  final List<LeaseDatacronjob>? data;
  final Metadata? metadata;

  LeaseResponse({
    this.statusCode,
    this.data,
    this.metadata,
  });

  factory LeaseResponse.fromJson(Map<String, dynamic> json) {
    return LeaseResponse(
      statusCode: json['statusCode'],
      data: (json['data'] as List?)
          ?.map((e) => LeaseDatacronjob.fromJson(e))
          .toList(),
      metadata:
          json['metadata'] != null ? Metadata.fromJson(json['metadata']) : null,
    );
  }
}

class LeaseDatacronjob {
  final String? id;
  final String? leaseId;
  final String? rentalAddress;
  final String? rentalUnit;
  final String? paymenttype;
  final String? state;
  final Tenant? tenant;
  final double? totalAmount;
  final String? response;
  final String? responseText;
  final String? status;
  final String? date;

  LeaseDatacronjob({
    this.id,
    this.leaseId,
    this.rentalAddress,
    this.rentalUnit,
    this.paymenttype,
    this.state,
    this.tenant,
    this.totalAmount,
    this.response,
    this.responseText,
    this.status,
    this.date,
  });

  factory LeaseDatacronjob.fromJson(Map<String, dynamic> json) {
    return LeaseDatacronjob(
      id: json['_id'],
      leaseId: json['lease_id'],
      rentalAddress: json['rental_address'],
      rentalUnit: json['rental_unit'],
      paymenttype: json['payment_type'],
      state: json['state'],
      tenant: json['tenant'] != null ? Tenant.fromJson(json['tenant']) : null,
      totalAmount: json['total_amount'] != null
          ? double.tryParse(json['total_amount'].toString()) ?? 0.0
          : null,
      response: json['response'],
      responseText: json['responseText'],
      status: json['status'],
      date: json['date'],
    );
  }
}

class Tenant {
  final String? tenantId;
  final String? tenantName;

  Tenant({
    this.tenantId,
    this.tenantName,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      tenantId: json['tenant_id'],
      tenantName: json['tenant_name'],
    );
  }
}

class Metadata {
  final int? total;
  final int? page;
  final int? limit;

  Metadata({
    this.total,
    this.page,
    this.limit,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
    );
  }
}
