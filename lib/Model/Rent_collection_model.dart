class Rentcollection_model {
  int? statusCode;
  String? reportMonth;
  List<Leases>? leases;
  List<Summary>? summary;
  TotalSummary? totalSummary;
  List<DeadBeats>? deadBeats;
  String? message;
  DeadBeatsSummary? deadBeatsSummary;

  Rentcollection_model({
    this.statusCode,
    this.reportMonth,
    this.leases,
    this.summary,
    this.totalSummary,
    this.deadBeats,
    this.message,
    this.deadBeatsSummary,
  });

  Rentcollection_model.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    reportMonth = json['reportMonth'];
    if (json['leases'] != null) {
      leases = <Leases>[];
      json['leases'].forEach((v) {
        leases!.add(Leases.fromJson(v));
      });
    }
    if (json['summary'] != null) {
      summary = <Summary>[];
      json['summary'].forEach((v) {
        summary!.add(Summary.fromJson(v));
      });
    }
    totalSummary = json['totalSummary'] != null
        ? TotalSummary.fromJson(json['totalSummary'])
        : null;
    if (json['deadBeats'] != null) {
      deadBeats = <DeadBeats>[];
      json['deadBeats'].forEach((v) {
        deadBeats!.add(DeadBeats.fromJson(v));
      });
    }
    message = json['message'];
    deadBeatsSummary = json['deadBeatsSummary'] != null
        ? DeadBeatsSummary.fromJson(json['deadBeatsSummary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['statusCode'] = statusCode;
    data['reportMonth'] = reportMonth;
    if (leases != null) {
      data['leases'] = leases!.map((v) => v.toJson()).toList();
    }
    if (summary != null) {
      data['summary'] = summary!.map((v) => v.toJson()).toList();
    }
    if (totalSummary != null) {
      data['totalSummary'] = totalSummary!.toJson();
    }
    if (deadBeats != null) {
      data['deadBeats'] = deadBeats!.map((v) => v.toJson()).toList();
    }
    data['message'] = message;
    if (deadBeatsSummary != null) {
      data['deadBeatsSummary'] = deadBeatsSummary!.toJson();
    }
    return data;
  }
}

class Leases {
  LeaseData? leaseData;
  List<RecurringCards>? recurringCards;
  RentalData? rentalData;
  RentalOwnerData? rentalOwnerData;
  List<Notes>? notes;
  RentSummary? rentSummary;

  Leases({
    this.leaseData,
    this.recurringCards,
    this.rentalData,
    this.rentalOwnerData,
    this.notes,
    this.rentSummary,
  });

  Leases.fromJson(Map<String, dynamic> json) {
    leaseData = json['leaseData'] != null
        ? LeaseData.fromJson(json['leaseData'])
        : null;
    if (json['recurringCards'] != null) {
      recurringCards = <RecurringCards>[];
      json['recurringCards'].forEach((v) {
        recurringCards!.add(RecurringCards.fromJson(v));
      });
    }
    rentalData = json['rentalData'] != null
        ? RentalData.fromJson(json['rentalData'])
        : null;
    rentalOwnerData = json['rentalOwnerData'] != null
        ? RentalOwnerData.fromJson(json['rentalOwnerData'])
        : null;
    if (json['notes'] != null) {
      notes = <Notes>[];
      json['notes'].forEach((v) {
        notes!.add(Notes.fromJson(v));
      });
    }
    rentSummary = json['rentSummary'] != null
        ? RentSummary.fromJson(json['rentSummary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (leaseData != null) {
      data['leaseData'] = leaseData!.toJson();
    }
    if (recurringCards != null) {
      data['recurringCards'] = recurringCards!.map((v) => v.toJson()).toList();
    }
    if (rentalData != null) {
      data['rentalData'] = rentalData!.toJson();
    }
    if (rentalOwnerData != null) {
      data['rentalOwnerData'] = rentalOwnerData!.toJson();
    }
    if (notes != null) {
      data['notes'] = notes!.map((v) => v.toJson()).toList();
    }
    if (rentSummary != null) {
      data['rentSummary'] = rentSummary!.toJson();
    }
    return data;
  }
}

class LeaseData {
  String? leaseId;
  String? startDate;
  double? leaseAmount;
  double? balance;

  LeaseData({this.leaseId, this.startDate, this.leaseAmount, this.balance});

  LeaseData.fromJson(Map<String, dynamic> json) {
    leaseId = json['lease_id'];
    startDate = json['start_date'];
    leaseAmount = json['lease_amount'] != null
        ? (json['lease_amount'] as num).toDouble()
        : null;
    balance =
        json['balance'] != null ? (json['balance'] as num).toDouble() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['lease_id'] = leaseId;
    data['start_date'] = startDate;
    data['lease_amount'] = leaseAmount;
    data['balance'] = balance;
    return data;
  }
}

class RecurringCards {
  String? tenantId;
  String? tenantName;
  String? date;
  double? amount;

  RecurringCards({this.tenantId, this.tenantName, this.date, this.amount});

  RecurringCards.fromJson(Map<String, dynamic> json) {
    tenantId = json['tenant_id'];
    tenantName = json['tenant_name'];
    date = json['date'];
    amount = json['amount'] != null ? (json['amount'] as num).toDouble() : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['tenant_id'] = tenantId;
    data['tenant_name'] = tenantName;
    data['date'] = date;
    data['amount'] = amount;
    return data;
  }
}

class RentalData {
  String? rentalId;
  String? rentalAdress;
  String? rentalCity;
  String? rentalState;
  String? rentalPostcode;

  RentalData({
    this.rentalId,
    this.rentalAdress,
    this.rentalCity,
    this.rentalState,
    this.rentalPostcode,
  });

  RentalData.fromJson(Map<String, dynamic> json) {
    rentalId = json['rental_id'];
    rentalAdress = json['rental_adress'];
    rentalCity = json['rental_city'];
    rentalState = json['rental_state'];
    rentalPostcode = json['rental_postcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['rental_id'] = rentalId;
    data['rental_adress'] = rentalAdress;
    data['rental_city'] = rentalCity;
    data['rental_state'] = rentalState;
    data['rental_postcode'] = rentalPostcode;
    return data;
  }
}

class RentalOwnerData {
  String? rentalownerId;
  String? rentalOwnerName;
  String? rentalOwnerCompanyName;

  RentalOwnerData({
    this.rentalownerId,
    this.rentalOwnerName,
    this.rentalOwnerCompanyName,
  });

  RentalOwnerData.fromJson(Map<String, dynamic> json) {
    rentalownerId = json['rentalowner_id'];
    rentalOwnerName = json['rentalOwner_name'];
    rentalOwnerCompanyName = json['rentalOwner_companyName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['rentalowner_id'] = rentalownerId;
    data['rentalOwner_name'] = rentalOwnerName;
    data['rentalOwner_companyName'] = rentalOwnerCompanyName;
    return data;
  }
}

class Notes {
  String? date;
  String? content;

  Notes({this.date, this.content});

  Notes.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['date'] = date;
    data['content'] = content;
    return data;
  }
}

class RentSummary {
  double? totalRentApplied;
  double? totalRentPaid;
  double? totalPending;

  RentSummary({
    this.totalRentApplied,
    this.totalRentPaid,
    this.totalPending,
  });

  RentSummary.fromJson(Map<String, dynamic> json) {
    totalRentApplied = json['totalRentApplied'] != null
        ? (json['totalRentApplied'] as num).toDouble()
        : null;
    totalRentPaid = json['totalRentPaid'] != null
        ? (json['totalRentPaid'] as num).toDouble()
        : null;
    totalPending = json['totalPending'] != null
        ? (json['totalPending'] as num).toDouble()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['totalRentApplied'] = totalRentApplied;
    data['totalRentPaid'] = totalRentPaid;
    data['totalPending'] = totalPending;
    return data;
  }
}

class Summary {
  String? rentalOwnerName;
  String? rentalOwnerCompany;
  double? totalCharged;
  double? totalPending;
  String? collectedPercentage;

  Summary({
    this.rentalOwnerName,
    this.rentalOwnerCompany,
    this.totalCharged,
    this.totalPending,
    this.collectedPercentage,
  });

  Summary.fromJson(Map<String, dynamic> json) {
    rentalOwnerName = json['rentalOwnerName'];
    rentalOwnerCompany = json['rentalOwnerCompany'];
    totalCharged = json['totalCharged'] != null
        ? (json['totalCharged'] as num).toDouble()
        : null;
    totalPending = json['totalPending'] != null
        ? (json['totalPending'] as num).toDouble()
        : null;
    collectedPercentage = json['collectedPercentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['rentalOwnerName'] = rentalOwnerName;
    data['rentalOwnerCompany'] = rentalOwnerCompany;
    data['totalCharged'] = totalCharged;
    data['totalPending'] = totalPending;
    data['collectedPercentage'] = collectedPercentage;
    return data;
  }
}

class TotalSummary {
  double? totalCharged;
  double? totalPending;
  String? averageCollectedPercentage;

  TotalSummary({
    this.totalCharged,
    this.totalPending,
    this.averageCollectedPercentage,
  });

  TotalSummary.fromJson(Map<String, dynamic> json) {
    totalCharged = json['totalCharged'] != null
        ? (json['totalCharged'] as num).toDouble()
        : null;
    totalPending = json['totalPending'] != null
        ? (json['totalPending'] as num).toDouble()
        : null;
    averageCollectedPercentage = json['averageCollectedPercentage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['totalCharged'] = totalCharged;
    data['totalPending'] = totalPending;
    data['averageCollectedPercentage'] = averageCollectedPercentage;
    return data;
  }
}

class DeadBeats {
  LeaseData? leaseData;
  List<RecurringCards>? recurringCards;
  RentalData? rentalData;
  RentalOwnerData? rentalOwnerData;
  List<Notes>? notes;
  RentSummary? rentSummary;

  DeadBeats({
    this.leaseData,
    this.recurringCards,
    this.rentalData,
    this.rentalOwnerData,
    this.notes,
    this.rentSummary,
  });

  DeadBeats.fromJson(Map<String, dynamic> json) {
    leaseData = json['leaseData'] != null
        ? LeaseData.fromJson(json['leaseData'])
        : null;
    if (json['recurringCards'] != null) {
      recurringCards = <RecurringCards>[];
      json['recurringCards'].forEach((v) {
        recurringCards!.add(RecurringCards.fromJson(v));
      });
    }
    rentalData = json['rentalData'] != null
        ? RentalData.fromJson(json['rentalData'])
        : null;
    rentalOwnerData = json['rentalOwnerData'] != null
        ? RentalOwnerData.fromJson(json['rentalOwnerData'])
        : null;
    if (json['notes'] != null) {
      notes = <Notes>[];
      json['notes'].forEach((v) {
        notes!.add(Notes.fromJson(v));
      });
    }
    rentSummary = json['rentSummary'] != null
        ? RentSummary.fromJson(json['rentSummary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (leaseData != null) {
      data['leaseData'] = leaseData!.toJson();
    }
    if (recurringCards != null) {
      data['recurringCards'] = recurringCards!.map((v) => v.toJson()).toList();
    }
    if (rentalData != null) {
      data['rentalData'] = rentalData!.toJson();
    }
    if (rentalOwnerData != null) {
      data['rentalOwnerData'] = rentalOwnerData!.toJson();
    }
    if (notes != null) {
      data['notes'] = notes!.map((v) => v.toJson()).toList();
    }
    if (rentSummary != null) {
      data['rentSummary'] = rentSummary!.toJson();
    }
    return data;
  }
}

class DeadBeatsSummary {
  int? totalDeadBeats;
  double? totalBalance;

  DeadBeatsSummary({this.totalDeadBeats, this.totalBalance});

  DeadBeatsSummary.fromJson(Map<String, dynamic> json) {
    totalDeadBeats = json['totalDeadBeats'];
    totalBalance = json['totalBalance'] != null
        ? (json['totalBalance'] as num).toDouble()
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['totalDeadBeats'] = totalDeadBeats;
    data['totalBalance'] = totalBalance;
    return data;
  }
}
