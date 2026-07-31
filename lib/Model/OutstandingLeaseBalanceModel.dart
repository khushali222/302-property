class OutstandingLeaseBalanceModel {
  bool? success;
  List<OutstandingLeaseBalanceData>? data;
  OutstandingLeaseBalanceTotals? totals;
  int? count;
  OutstandingLeaseBalancePagination? pagination;
  int? statusCode;
  String? message;

  OutstandingLeaseBalanceModel({
    this.success,
    this.data,
    this.totals,
    this.count,
    this.pagination,
    this.statusCode,
    this.message,
  });

  OutstandingLeaseBalanceModel.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
    });

    success = json['success'];

    if (json['data'] != null) {
      data = <OutstandingLeaseBalanceData>[];
      json['data'].forEach((v) {
        data!.add(OutstandingLeaseBalanceData.fromJson(v));
      });
    }

    totals = json['totals'] != null
        ? OutstandingLeaseBalanceTotals.fromJson(json['totals'])
        : null;

    count = json['count'];

    pagination = json['pagination'] != null
        ? OutstandingLeaseBalancePagination.fromJson(json['pagination'])
        : null;

    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['success'] = this.success;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    if (this.totals != null) {
      data['totals'] = this.totals!.toJson();
    }
    data['count'] = this.count;
    if (this.pagination != null) {
      data['pagination'] = this.pagination!.toJson();
    }
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

class OutstandingLeaseBalanceData {
  String? id;
  String? leaseId;
  String? rentalId;
  String? unitId;
  double? leaseAmount;
  String? tenantNames;
  double? totalCharges;
  double? totalPayments;
  double? outstandingBalance;
  String? propertyAddress;
  List<AccountBreakdown>? accountBreakdown;
  double? balance030;
  double? balance3160;
  double? balance6190;
  double? balance90Plus;

  OutstandingLeaseBalanceData({
    this.id,
    this.leaseId,
    this.rentalId,
    this.unitId,
    this.leaseAmount,
    this.tenantNames,
    this.totalCharges,
    this.totalPayments,
    this.outstandingBalance,
    this.propertyAddress,
    this.accountBreakdown,
    this.balance030,
    this.balance3160,
    this.balance6190,
    this.balance90Plus,
  });

  OutstandingLeaseBalanceData.fromJson(Map<String, dynamic> json) {
    json.forEach((key, value) {
    });

    id = json['_id'];
    leaseId = json['lease_id'];
    rentalId = json['rental_id'];
    unitId = json['unit_id'];
    leaseAmount = json['lease_amount'] != null
        ? (json['lease_amount'] as num).toDouble()
        : null;
    tenantNames = json['tenant_names'];
    totalCharges = json['total_charges'] != null
        ? (json['total_charges'] as num).toDouble()
        : null;
    totalPayments = json['total_payments'] != null
        ? (json['total_payments'] as num).toDouble()
        : null;
    outstandingBalance = json['outstanding_balance'] != null
        ? (json['outstanding_balance'] as num).toDouble()
        : null;
    propertyAddress = json['property_address'];

    if (json['account_breakdown'] != null) {
      accountBreakdown = <AccountBreakdown>[];
      json['account_breakdown'].forEach((v) {
        accountBreakdown!.add(AccountBreakdown.fromJson(v));
      });
    }

    balance030 = json['balance_0_30'] != null
        ? (json['balance_0_30'] as num).toDouble()
        : null;
    balance3160 = json['balance_31_60'] != null
        ? (json['balance_31_60'] as num).toDouble()
        : null;
    balance6190 = json['balance_61_90'] != null
        ? (json['balance_61_90'] as num).toDouble()
        : null;
    balance90Plus = json['balance_90_plus'] != null
        ? (json['balance_90_plus'] as num).toDouble()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = this.id;
    data['lease_id'] = this.leaseId;
    data['rental_id'] = this.rentalId;
    data['unit_id'] = this.unitId;
    data['lease_amount'] = this.leaseAmount;
    data['tenant_names'] = this.tenantNames;
    data['total_charges'] = this.totalCharges;
    data['total_payments'] = this.totalPayments;
    data['outstanding_balance'] = this.outstandingBalance;
    data['property_address'] = this.propertyAddress;
    if (this.accountBreakdown != null) {
      data['account_breakdown'] =
          this.accountBreakdown!.map((v) => v.toJson()).toList();
    }
    data['balance_0_30'] = this.balance030;
    data['balance_31_60'] = this.balance3160;
    data['balance_61_90'] = this.balance6190;
    data['balance_90_plus'] = this.balance90Plus;
    return data;
  }
}

class AccountBreakdown {
  String? accountName;
  double? amount;
  BalanceBuckets? buckets;

  AccountBreakdown({
    this.accountName,
    this.amount,
    this.buckets,
  });

  AccountBreakdown.fromJson(Map<String, dynamic> json) {
    accountName = json['account_name'];
    amount = json['amount'] != null ? (json['amount'] as num).toDouble() : null;
    buckets = json['buckets'] != null
        ? BalanceBuckets.fromJson(json['buckets'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['account_name'] = this.accountName;
    data['amount'] = this.amount;
    if (this.buckets != null) {
      data['buckets'] = this.buckets!.toJson();
    }
    return data;
  }
}

class BalanceBuckets {
  double? bucket030;
  double? bucket3160;
  double? bucket6190;
  double? bucket90Plus;

  BalanceBuckets({
    this.bucket030,
    this.bucket3160,
    this.bucket6190,
    this.bucket90Plus,
  });

  BalanceBuckets.fromJson(Map<String, dynamic> json) {
    bucket030 = json['0-30'] != null ? (json['0-30'] as num).toDouble() : null;
    bucket3160 =
        json['31-60'] != null ? (json['31-60'] as num).toDouble() : null;
    bucket6190 =
        json['61-90'] != null ? (json['61-90'] as num).toDouble() : null;
    bucket90Plus = json['90+'] != null ? (json['90+'] as num).toDouble() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['0-30'] = this.bucket030;
    data['31-60'] = this.bucket3160;
    data['61-90'] = this.bucket6190;
    data['90+'] = this.bucket90Plus;
    return data;
  }
}

class OutstandingLeaseBalanceTotals {
  double? outstandingBalance;
  double? balance030;
  double? balance3160;
  double? balance6190;
  double? balance90Plus;

  OutstandingLeaseBalanceTotals({
    this.outstandingBalance,
    this.balance030,
    this.balance3160,
    this.balance6190,
    this.balance90Plus,
  });

  OutstandingLeaseBalanceTotals.fromJson(Map<String, dynamic> json) {
    outstandingBalance = json['outstanding_balance'] != null
        ? (json['outstanding_balance'] as num).toDouble()
        : null;
    balance030 = json['balance_0_30'] != null
        ? (json['balance_0_30'] as num).toDouble()
        : null;
    balance3160 = json['balance_31_60'] != null
        ? (json['balance_31_60'] as num).toDouble()
        : null;
    balance6190 = json['balance_61_90'] != null
        ? (json['balance_61_90'] as num).toDouble()
        : null;
    balance90Plus = json['balance_90_plus'] != null
        ? (json['balance_90_plus'] as num).toDouble()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['outstanding_balance'] = this.outstandingBalance;
    data['balance_0_30'] = this.balance030;
    data['balance_31_60'] = this.balance3160;
    data['balance_61_90'] = this.balance6190;
    data['balance_90_plus'] = this.balance90Plus;
    return data;
  }
}

class OutstandingLeaseBalancePagination {
  int? currentPage;
  int? totalPages;
  int? totalCount;
  int? limit;

  OutstandingLeaseBalancePagination({
    this.currentPage,
    this.totalPages,
    this.totalCount,
    this.limit,
  });

  OutstandingLeaseBalancePagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    totalPages = json['total_pages'];
    totalCount = json['total_count'];
    limit = json['limit'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['current_page'] = this.currentPage;
    data['total_pages'] = this.totalPages;
    data['total_count'] = this.totalCount;
    data['limit'] = this.limit;
    return data;
  }
}
