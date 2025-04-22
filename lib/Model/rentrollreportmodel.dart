class rentrollreportmodel {
  List<RentalOwners>? rentalOwners;
  List<Rentals>? rentals;
  GrandTotal? grandTotal;
  BedBathSummaryData? bedBathSummary;
  PropertySummaryData? propertySummary;

  rentrollreportmodel(
      {this.rentalOwners,
        this.rentals,
        this.grandTotal,
        this.bedBathSummary,
        this.propertySummary});

  rentrollreportmodel.fromJson(Map<String, dynamic> json) {
    if (json['rentalOwners'] != null) {
      rentalOwners = <RentalOwners>[];
      json['rentalOwners'].forEach((v) {
        rentalOwners!.add(new RentalOwners.fromJson(v));
      });
    }
    if (json['rentals'] != null) {
      rentals = <Rentals>[];
      json['rentals'].forEach((v) {
        rentals!.add(new Rentals.fromJson(v));
      });
    }
    grandTotal = json['grandTotal'] != null
        ? new GrandTotal.fromJson(json['grandTotal'])
        : null;
    bedBathSummary = json['BedBathSummary'] != null
        ? new BedBathSummaryData.fromJson(json['BedBathSummary'])
        : null;
    propertySummary = json['PropertySummary'] != null
        ? new PropertySummaryData.fromJson(json['PropertySummary'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rentalOwners != null) {
      data['rentalOwners'] = this.rentalOwners!.map((v) => v.toJson()).toList();
    }
    if (this.rentals != null) {
      data['rentals'] = this.rentals!.map((v) => v.toJson()).toList();
    }
    if (this.grandTotal != null) {
      data['grandTotal'] = this.grandTotal!.toJson();
    }
    if (this.bedBathSummary != null) {
      data['BedBathSummary'] = this.bedBathSummary!.toJson();
    }
    if (this.propertySummary != null) {
      data['PropertySummary'] = this.propertySummary!.toJson();
    }
    return data;
  }
}

class RentalOwners {
  String? sId;
  String? rentalownerId;
  String? adminId;
  String? rentalOwnerName;
  String? rentalOwnerCompanyName;
  String? rentalOwnerPrimaryEmail;
  String? rentalOwnerPhoneNumber;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  String? createdAt;
  String? updatedAt;
  bool? isDelete;
  List<ProcessorList>? processorList;
  int? iV;
  String? rentalOwnerBusinessNumber;
  String? rentalOwnerHomeNumber;
  String? endDate;
  String? startDate;
  String? streetAddress;
  String? texpayerId;
  String? textIdentityType;
  String? rentalOwnerAlternateEmail;

  RentalOwners(
      {this.sId,
        this.rentalownerId,
        this.adminId,
        this.rentalOwnerName,
        this.rentalOwnerCompanyName,
        this.rentalOwnerPrimaryEmail,
        this.rentalOwnerPhoneNumber,
        this.city,
        this.state,
        this.country,
        this.postalCode,
        this.createdAt,
        this.updatedAt,
        this.isDelete,
        this.processorList,
        this.iV,
        this.rentalOwnerBusinessNumber,
        this.rentalOwnerHomeNumber,
        this.endDate,
        this.startDate,
        this.streetAddress,
        this.texpayerId,
        this.textIdentityType,
        this.rentalOwnerAlternateEmail});

  RentalOwners.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    rentalownerId = json['rentalowner_id'];
    adminId = json['admin_id'];
    rentalOwnerName = json['rentalOwner_name'];
    rentalOwnerCompanyName = json['rentalOwner_companyName'];
    rentalOwnerPrimaryEmail = json['rentalOwner_primaryEmail'];
    rentalOwnerPhoneNumber = json['rentalOwner_phoneNumber'];
    city = json['city'];
    state = json['state'];
    country = json['country'];
    postalCode = json['postal_code'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    isDelete = json['is_delete'];
    if (json['processor_list'] != null) {
      processorList = <ProcessorList>[];
      json['processor_list'].forEach((v) {
        processorList!.add(new ProcessorList.fromJson(v));
      });
    }
    iV = json['__v'];
    rentalOwnerBusinessNumber = json['rentalOwner_businessNumber'];
    rentalOwnerHomeNumber = json['rentalOwner_homeNumber'];
    endDate = json['end_date'];
    startDate = json['start_date'];
    streetAddress = json['street_address'];
    texpayerId = json['texpayer_id'];
    textIdentityType = json['text_identityType'];
    rentalOwnerAlternateEmail = json['rentalOwner_alternateEmail'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['rentalowner_id'] = this.rentalownerId;
    data['admin_id'] = this.adminId;
    data['rentalOwner_name'] = this.rentalOwnerName;
    data['rentalOwner_companyName'] = this.rentalOwnerCompanyName;
    data['rentalOwner_primaryEmail'] = this.rentalOwnerPrimaryEmail;
    data['rentalOwner_phoneNumber'] = this.rentalOwnerPhoneNumber;
    data['city'] = this.city;
    data['state'] = this.state;
    data['country'] = this.country;
    data['postal_code'] = this.postalCode;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['is_delete'] = this.isDelete;
    if (this.processorList != null) {
      data['processor_list'] =
          this.processorList!.map((v) => v.toJson()).toList();
    }
    data['__v'] = this.iV;
    data['rentalOwner_businessNumber'] = this.rentalOwnerBusinessNumber;
    data['rentalOwner_homeNumber'] = this.rentalOwnerHomeNumber;
    data['end_date'] = this.endDate;
    data['start_date'] = this.startDate;
    data['street_address'] = this.streetAddress;
    data['texpayer_id'] = this.texpayerId;
    data['text_identityType'] = this.textIdentityType;
    data['rentalOwner_alternateEmail'] = this.rentalOwnerAlternateEmail;
    return data;
  }
}

class ProcessorList {
  String? processorId;
  String? sId;

  ProcessorList({this.processorId, this.sId});

  ProcessorList.fromJson(Map<String, dynamic> json) {
    processorId = json['processor_id'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['processor_id'] = this.processorId;
    data['_id'] = this.sId;
    return data;
  }

}
class Rentals {
  String? rentalAddress;
  String? rentalId;
  List<ActiveLeases>? activeLeases;
  Totals? totals;

  Rentals({this.rentalAddress, this.rentalId, this.activeLeases, this.totals});

  Rentals.fromJson(Map<String, dynamic> json) {
    rentalAddress = json['rentalAddress'];
    rentalId = json['rental_id'];
    if (json['activeLeases'] != null) {
      activeLeases = <ActiveLeases>[];
      json['activeLeases'].forEach((v) {
        activeLeases!.add(new ActiveLeases.fromJson(v));
      });
    }
    totals =
    json['totals'] != null ? new Totals.fromJson(json['totals']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['rentalAddress'] = this.rentalAddress;
    data['rental_id'] = this.rentalId;
    if (this.activeLeases != null) {
      data['activeLeases'] = this.activeLeases!.map((v) => v.toJson()).toList();
    }
    if (this.totals != null) {
      data['totals'] = this.totals!.toJson();
    }
    return data;
  }
}

class ActiveLeases {
  String? leaseId;
  List<Tenants>? tenants;
  String? leaseStart;
  String? leaseEnd;
  Unit? unit;
  String? rentCycle;
  double? rentAmount;
  double? chargeAmount;
  double? creditAmount;
  double? chargeTotal;
  double? depositHeld;
  double? prepayments;
  double? balanceDue;

  ActiveLeases({
    this.leaseId,
    this.tenants,
    this.leaseStart,
    this.leaseEnd,
    this.unit,
    this.rentCycle,
    this.rentAmount,
    this.chargeAmount,
    this.creditAmount,
    this.chargeTotal,
    this.depositHeld,
    this.prepayments,
    this.balanceDue,
  });

  ActiveLeases.fromJson(Map<String, dynamic> json) {
    leaseId = json['lease_id'];
    if (json['tenants'] != null) {
      tenants = <Tenants>[];
      json['tenants'].forEach((v) {
        tenants!.add(Tenants.fromJson(v));
      });
    }
    leaseStart = json['lease_start'];
    leaseEnd = json['lease_end'];
    unit = json['unit'] != null ? Unit.fromJson(json['unit']) : null;
    rentCycle = json['rent_cycle'];
    rentAmount = (json['rent_amount'] as num?)?.toDouble();
    chargeAmount = (json['charge_amount'] as num?)?.toDouble();
    creditAmount = (json['credit_amount'] as num?)?.toDouble();
    chargeTotal = (json['charge_total'] as num?)?.toDouble();
    depositHeld = (json['deposit_held'] as num?)?.toDouble();
    prepayments = (json['prepayments'] as num?)?.toDouble();
    balanceDue = (json['balance_due'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lease_id'] = leaseId;
    if (tenants != null) {
      data['tenants'] = tenants!.map((v) => v.toJson()).toList();
    }
    data['lease_start'] = leaseStart;
    data['lease_end'] = leaseEnd;
    if (unit != null) {
      data['unit'] = unit!.toJson();
    }
    data['rent_cycle'] = rentCycle;
    data['rent_amount'] = rentAmount;
    data['charge_amount'] = chargeAmount;
    data['credit_amount'] = creditAmount;
    data['charge_total'] = chargeTotal;
    data['deposit_held'] = depositHeld;
    data['prepayments'] = prepayments;
    data['balance_due'] = balanceDue;
    return data;
  }
}

class Tenants {
  String? sId;
  String? tenantId;
  String? tenantFirstName;
  String? tenantLastName;

  Tenants({this.sId, this.tenantId, this.tenantFirstName, this.tenantLastName});

  Tenants.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    tenantId = json['tenant_id'];
    tenantFirstName = json['tenant_firstName'];
    tenantLastName = json['tenant_lastName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['tenant_id'] = this.tenantId;
    data['tenant_firstName'] = this.tenantFirstName;
    data['tenant_lastName'] = this.tenantLastName;
    return data;
  }
}

class Unit {
  String? unitId;
  String? rentalUnit;
  String? address;
  String? bedBath;
  String? sqft;

  Unit({this.unitId, this.rentalUnit, this.address, this.bedBath, this.sqft});

  Unit.fromJson(Map<String, dynamic> json) {
    unitId = json['unit_id'];
    rentalUnit = json['rental_unit'];
    address = json['address'];
    bedBath = json['bed_bath'];
    sqft = json['sqft'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['unit_id'] = this.unitId;
    data['rental_unit'] = this.rentalUnit;
    data['address'] = this.address;
    data['bed_bath'] = this.bedBath;
    data['sqft'] = this.sqft;
    return data;
  }
}

class Totals {
  double? totalRent;
  double? totalCharges;
  double? totalCredits;
  double? totalAmount;
  double? totalDeposits;
  double? totalBalanceDue;
  double? totalPrepayments;

  Totals({
    this.totalRent,
    this.totalCharges,
    this.totalCredits,
    this.totalAmount,
    this.totalDeposits,
    this.totalBalanceDue,
    this.totalPrepayments,
  });

  Totals.fromJson(Map<String, dynamic> json) {
    totalRent = (json['totalRent'] as num?)?.toDouble();
    totalCharges = (json['totalCharges'] as num?)?.toDouble();
    totalCredits = (json['totalCredits'] as num?)?.toDouble();
    totalAmount = (json['totalAmount'] as num?)?.toDouble();
    totalDeposits = (json['totalDeposits'] as num?)?.toDouble();
    totalBalanceDue = (json['totalBalanceDue'] as num?)?.toDouble();
    totalPrepayments = (json['totalPrepayments'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRent': totalRent,
      'totalCharges': totalCharges,
      'totalCredits': totalCredits,
      'totalAmount': totalAmount,
      'totalDeposits': totalDeposits,
      'totalBalanceDue': totalBalanceDue,
      'totalPrepayments': totalPrepayments,
    };
  }
}

class GrandTotal {
  double? totalRent;
  double? totalCharges;
  double? totalCredits;
  double? totalDeposits;
  double? totalPrepayments;
  double? totalBalanceDue;

  GrandTotal({
    this.totalRent,
    this.totalCharges,
    this.totalCredits,
    this.totalDeposits,
    this.totalPrepayments,
    this.totalBalanceDue,
  });

  GrandTotal.fromJson(Map<String, dynamic> json) {
    totalRent = (json['totalRent'] as num?)?.toDouble();
    totalCharges = (json['totalCharges'] as num?)?.toDouble();
    totalCredits = (json['totalCredits'] as num?)?.toDouble();
    totalDeposits = (json['totalDeposits'] as num?)?.toDouble();
    totalPrepayments = (json['totalPrepayments'] as num?)?.toDouble();
    totalBalanceDue = (json['totalBalanceDue'] as num?)?.toDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRent': totalRent,
      'totalCharges': totalCharges,
      'totalCredits': totalCredits,
      'totalDeposits': totalDeposits,
      'totalPrepayments': totalPrepayments,
      'totalBalanceDue': totalBalanceDue,
    };
  }
}

class TotalsAndAveragesBedBath {
  double? totalUnits;
  double? totalOccupiedUnits;
  double? totalVacantUnits;
  double? totalSqFt;
  String? totalMarketRent;
  String? avgSqFt;
  String? avgMarketRent;
  String? avgMarketRentPerSqFt;
  String? avgOccupancyRate;

  TotalsAndAveragesBedBath({
    this.totalUnits,
    this.totalOccupiedUnits,
    this.totalVacantUnits,
    this.totalSqFt,
    this.totalMarketRent,
    this.avgSqFt,
    this.avgMarketRent,
    this.avgMarketRentPerSqFt,
    this.avgOccupancyRate,
  });

  TotalsAndAveragesBedBath.fromJson(Map<String, dynamic> json) {
    totalUnits = (json['totalUnits'] as num?)?.toDouble();
    totalOccupiedUnits = (json['totalOccupiedUnits'] as num?)?.toDouble();
    totalVacantUnits = (json['totalVacantUnits'] as num?)?.toDouble();
    totalSqFt = (json['totalSqFt'] as num?)?.toDouble();
    totalMarketRent = json['totalMarketRent'];
    avgSqFt = json['avgSqFt'];
    avgMarketRent = json['avgMarketRent'];
    avgMarketRentPerSqFt = json['avgMarketRentPerSqFt'];
    avgOccupancyRate = json['avgOccupancyRate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUnits': totalUnits,
      'totalOccupiedUnits': totalOccupiedUnits,
      'totalVacantUnits': totalVacantUnits,
      'totalSqFt': totalSqFt,
      'totalMarketRent': totalMarketRent,
      'avgSqFt': avgSqFt,
      'avgMarketRent': avgMarketRent,
      'avgMarketRentPerSqFt': avgMarketRentPerSqFt,
      'avgOccupancyRate': avgOccupancyRate,
    };
  }
}


class BedBathSummaryData {
  List<BedBathSummaryItem>? bedBathSummary;
  TotalsAndAveragesBedBath? totalsAndAveragesBedBath;

  BedBathSummaryData({this.bedBathSummary, this.totalsAndAveragesBedBath});

  BedBathSummaryData.fromJson(Map<String, dynamic> json) {
    if (json['bedBathSummary'] != null) {
      bedBathSummary = <BedBathSummaryItem>[];
      json['bedBathSummary'].forEach((v) {
        bedBathSummary!.add(BedBathSummaryItem.fromJson(v));
      });
    }
    totalsAndAveragesBedBath = json['totalsAndAveragesBedBath'] != null
        ? TotalsAndAveragesBedBath.fromJson(json['totalsAndAveragesBedBath'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (bedBathSummary != null) {
      data['bedBathSummary'] =
          bedBathSummary!.map((v) => v.toJson()).toList();
    }
    if (totalsAndAveragesBedBath != null) {
      data['totalsAndAveragesBedBath'] = totalsAndAveragesBedBath!.toJson();
    }
    return data;
  }
}


// ... [Keep all other classes the same until PropertySummary]

class PropertySummaryData {
  List<PropertySummaryItem>? propertySummary;
  TotalsAndAveragesBedBath? totalsAndAveragesProperty;

  PropertySummaryData({this.propertySummary, this.totalsAndAveragesProperty});

  PropertySummaryData.fromJson(Map<String, dynamic> json) {
    if (json['propertySummary'] != null) {
      propertySummary = <PropertySummaryItem>[];
      json['propertySummary'].forEach((v) {
        propertySummary!.add(PropertySummaryItem.fromJson(v));
      });
    }
    totalsAndAveragesProperty = json['totalsAndAveragesProperty'] != null
        ? TotalsAndAveragesBedBath.fromJson(json['totalsAndAveragesProperty'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (propertySummary != null) {
      data['propertySummary'] =
          propertySummary!.map((v) => v.toJson()).toList();
    }
    if (totalsAndAveragesProperty != null) {
      data['totalsAndAveragesProperty'] = totalsAndAveragesProperty!.toJson();
    }
    return data;
  }
}
class BedBathSummaryItem {
  String? bedBath;
  double? units;
  double? totalSqFt;
  String? avgSqFt;
  String? totalRent;
  String? avgRent;
  String? avgRentPerSqFt;
  double? occupiedUnits;
  double? vacantUnits;
  String? occupancyRate;

  BedBathSummaryItem({
    this.bedBath,
    this.units,
    this.totalSqFt,
    this.avgSqFt,
    this.totalRent,
    this.avgRent,
    this.avgRentPerSqFt,
    this.occupiedUnits,
    this.vacantUnits,
    this.occupancyRate,
  });

  BedBathSummaryItem.fromJson(Map<String, dynamic> json) {
    bedBath = json['bedBath'];
    units = (json['units'] as num?)?.toDouble();
    totalSqFt = (json['totalSqFt'] as num?)?.toDouble();
    avgSqFt = json['avgSqFt'];
    totalRent = json['totalRent'];
    avgRent = json['avgRent'];
    avgRentPerSqFt = json['avgRentPerSqFt'];
    occupiedUnits = (json['occupiedUnits'] as num?)?.toDouble();
    vacantUnits = (json['vacantUnits'] as num?)?.toDouble();
    occupancyRate = json['occupancyRate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'bedBath': bedBath,
      'units': units,
      'totalSqFt': totalSqFt,
      'avgSqFt': avgSqFt,
      'totalRent': totalRent,
      'avgRent': avgRent,
      'avgRentPerSqFt': avgRentPerSqFt,
      'occupiedUnits': occupiedUnits,
      'vacantUnits': vacantUnits,
      'occupancyRate': occupancyRate,
    };
  }
}

class PropertySummaryItem {
  String? property;
  double? units;
  double? totalSqFt;
  String? avgSqFt;
  String? totalRent;
  String? avgRent;
  String? avgRentPerSqFt;
  double? occupiedUnits;
  double? vacantUnits;
  String? occupancyRate;

  PropertySummaryItem({
    this.property,
    this.units,
    this.totalSqFt,
    this.avgSqFt,
    this.totalRent,
    this.avgRent,
    this.avgRentPerSqFt,
    this.occupiedUnits,
    this.vacantUnits,
    this.occupancyRate,
  });

  PropertySummaryItem.fromJson(Map<String, dynamic> json) {
    property = json['property'];
    units = (json['units'] as num?)?.toDouble();
    totalSqFt = (json['totalSqFt'] as num?)?.toDouble();
    avgSqFt = json['avgSqFt'];
    totalRent = json['totalRent'];
    avgRent = json['avgRent'];
    avgRentPerSqFt = json['avgRentPerSqFt'];
    occupiedUnits = (json['occupiedUnits'] as num?)?.toDouble();
    vacantUnits = (json['vacantUnits'] as num?)?.toDouble();
    occupancyRate = json['occupancyRate'];
  }

  Map<String, dynamic> toJson() {
    return {
      'property': property,
      'units': units,
      'totalSqFt': totalSqFt,
      'avgSqFt': avgSqFt,
      'totalRent': totalRent,
      'avgRent': avgRent,
      'avgRentPerSqFt': avgRentPerSqFt,
      'occupiedUnits': occupiedUnits,
      'vacantUnits': vacantUnits,
      'occupancyRate': occupancyRate,
    };
  }
}
