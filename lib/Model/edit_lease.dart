import 'package:three_zero_two_property/Model/unit.dart';
import 'package:three_zero_two_property/model/tenants.dart';

import '../repository/unit_data.dart';
import 'RentalOwnersData.dart';

import 'lease.dart';

class LeaseDetails {
  final EditLease lease;
  final List<Tenant>? tenant;
  final RentalOwnerData rental;
  final unit_lease unitData;
  final List<ChargeData> rentCharges;
  final List<ChargeData> securityCharges;

  LeaseDetails({
    required this.lease,
    required this.tenant,
    required this.rental,
    required this.unitData,
    required this.rentCharges,
    required this.securityCharges,
  });

  factory LeaseDetails.fromJson(Map<String, dynamic> json) {
    return LeaseDetails(
      lease: EditLease.fromJson(json['leases']),
      tenant: json['tenant'] != null
          ? (json['tenant'] as List)
          .map((tenant) => Tenant.fromJson(tenant))
          .toList()
          : null,
      rental: RentalOwnerData.fromJson(json['rental']),
      unitData: unit_lease.fromJson(json['unit_data']),
      rentCharges: (json['rent_charge_data'] as List)
          .map((charge) => ChargeData.fromJson(charge))
          .toList(),
      securityCharges: (json['security_charge_data'] as List)
          .map((charge) => ChargeData.fromJson(charge))
          .toList(),
    );
  }
}

class EditLease {
  final String id;
  final String leaseId;
  final List<String> tenantId;
  final String adminId;
  final String rentalId;
  final String unitId;
  final String leaseType;
  final String startDate;
  final String endDate;
  final double leaseAmount;
  final List<dynamic> uploadedFile;
  final List<Entry> entry;
  final String createdAt;
  final String updatedAt;
  final bool isDelete;
  final List<dynamic> moveoutTenant;
  final int v;

  EditLease({
    required this.id,
    required this.leaseId,
    required this.tenantId,
    required this.adminId,
    required this.rentalId,
    required this.unitId,
    required this.leaseType,
    required this.startDate,
    required this.endDate,
    required this.leaseAmount,
    required this.uploadedFile,
    required this.entry,
    required this.createdAt,
    required this.updatedAt,
    required this.isDelete,
    required this.moveoutTenant,
    required this.v,
  });

  factory EditLease.fromJson(Map<String, dynamic> json) {
    return EditLease(
      id: json['_id'],
      leaseId: json['lease_id'],
      tenantId: List<String>.from(json['tenant_id']),
      adminId: json['admin_id'],
      rentalId: json['rental_id'],
      unitId: json['unit_id'],
      leaseType: json['lease_type'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      leaseAmount: json['lease_amount'].toDouble(),
      uploadedFile: List<dynamic>.from(json['uploaded_file']),
      entry: (json['entry'] as List)
          .map((entry) => Entry.fromJson(entry))
          .toList(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      isDelete: json['is_delete'],
      moveoutTenant: List<dynamic>.from(json['moveout_tenant']),
      v: json['__v'],
    );
  }
}

// class Entry {
//   final String entryId;
//   final String date;
//   final String chargeType;
//   final String account;
//   final String? rentCycle;
//   final double amount;
//   final String id;
//
//   Entry({
//     required this.entryId,
//     required this.date,
//     required this.chargeType,
//     required this.account,
//     this.rentCycle,
//     required this.amount,
//     required this.id,
//   });
//
//   factory Entry.fromJson(Map<String, dynamic> json) {
//     return Entry(
//       entryId: json['entry_id'],
//       date: json['date'],
//       chargeType: json['charge_type'],
//       account: json['account'],
//       rentCycle: json['rent_cycle'],
//       amount: json['amount'].toDouble(),
//       id: json['_id'],
//     );
//   }
// }
