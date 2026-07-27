import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/Renters_Insurnce/Edit_insurnce.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:three_zero_two_property/enums/history_type.dart';
import 'package:three_zero_two_property/widgets/custom_history_table.dart';
import 'package:three_zero_two_property/widgets/insurance_document_viewer.dart';

import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../../model/LeaseSummary.dart';
import '../../../../repository/lease.dart';
import '../../../../repository/lease_rental_insurance_repo.dart';
import '../../../../widgets/custom_drawer.dart';

class ViewRentersDetails extends StatefulWidget {
  final String tenantid;
  final String leaseId;
  final String renters_insurance_id;
  // Web parity: deleted policies need ?include_deleted=1 on the detail fetch.
  final bool includeDeleted;
  const ViewRentersDetails(
      {required this.tenantid,
      required this.leaseId,
      required this.renters_insurance_id,
      this.includeDeleted = false});

  @override
  State<ViewRentersDetails> createState() => _ViewRentersDetailsState();
}

class _ViewRentersDetailsState extends State<ViewRentersDetails> {
  late Future<RentersEdit> _futureRentersDetails;

  // ─────────────────── Redesign palette ───────────────────
  static const Color _pageBg = Color(0xFFF4F6F9);
  static const Color _muted = Color(0xFF6B7A90);
  static const Color _innerBg = Color(0xFFF8FAFC);

  @override
  void initState() {
    super.initState();

    _futureRentersDetails = RentersInsuranceService().fetchRentersDetails(
        widget.renters_insurance_id,
        includeDeleted: widget.includeDeleted);
  }

  GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: _pageBg,
      drawer: CustomDrawer(
        currentpage: "Leases",
        dropdown: true,
      ),
      body: Column(
        children: [
          _buildHeaderBar(),
          Expanded(
            child: FutureBuilder<RentersEdit>(
              future: _futureRentersDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: SpinKitFadingCircle(
                      color: blueColor,
                      size: 50.0,
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData) {
                  return const Center(child: Text("No data found"));
                }

                final RentersEdit rentersData = snapshot.data!;

                // ── Formatted values (logic unchanged from before) ──
                final company = rentersData.insuranceCompany?.isNotEmpty == true
                    ? rentersData.insuranceCompany!
                    : 'N/A';
                final phone = (rentersData.insuranceCompanyPhoneNumber != null &&
                        rentersData.insuranceCompanyPhoneNumber!.isNotEmpty)
                    ? formatPhoneNumber(rentersData.insuranceCompanyPhoneNumber!)
                    : 'N/A';
                final policyId = (rentersData.policyId != null &&
                        rentersData.policyId!.isNotEmpty)
                    ? rentersData.policyId!
                    : 'N/A';
                final effective = rentersData.effectiveDate?.isNotEmpty == true
                    ? dateProvider.formatCurrentDate(
                        '${rentersData.effectiveDate?.split('T').first}')
                    : 'N/A';
                final expiration = rentersData.expirationDate?.isNotEmpty == true
                    ? dateProvider.formatCurrentDate(
                        '${rentersData.expirationDate?.split('T').first}')
                    : 'N/A';
                final liability = (rentersData.liabilityCoverage != null &&
                        rentersData.liabilityCoverage! > 0)
                    ? '\$${rentersData.liabilityCoverage!.toStringAsFixed(2)}'
                    : 'N/A';
                final hasDoc =
                    rentersData.insurancePolicyDocument?.isNotEmpty == true;
                final tenants = rentersData.tenantDetails ?? [];

                return ListView(
                  padding: const EdgeInsets.only(top: 8, bottom: 24),
                  children: [
                    // ── Insurance Information ──
                    _sectionCard(
                      title: 'Insurance Information',
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _innerBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _stackedField('Insurance Company', company),
                              _stackedField('Company Phone Number', phone),
                              _stackedField('Policy ID', policyId),
                              _stackedField('Effective Date', effective),
                              _stackedField('Expiration Date', expiration),
                              _stackedField('Liability Coverage', liability,
                                  last: true),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ── Tenant Details ──
                    _sectionCard(
                      title: 'Tenant Details',
                      children: [
                        if (tenants.isEmpty)
                          _emptyBox('No Tenants Available')
                        else
                          ...tenants.map(
                            (t) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _tenantTile(t),
                            ),
                          ),
                      ],
                    ),

                    // ── Documents ──
                    _sectionCard(
                      title: 'Documents',
                      children: [
                        if (!hasDoc)
                          _emptyBox('No document uploaded')
                        else ...[
                          _documentTile(
                              rentersData.insurancePolicyDocument ?? ''),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _viewButton(() {
                                  viewInsuranceDocument(context,
                                      rentersData.insurancePolicyDocument);
                                }),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _downloadButton(() {
                                  downloadInsuranceDocument(context,
                                      rentersData.insurancePolicyDocument);
                                }),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),

                    // ── History (real audit history via shared CustomHistoryTable) ──
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: CustomHistoryTable(
                        historyType: HistoryType.rentersInsurance,
                        entityId: widget.renters_insurance_id,
                        title: 'History',
                        blueColor: blueColor,
                        itemsPerPage: 10,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────── UI helpers ───────────────────────────

  Widget _buildHeaderBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.maybePop(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(Icons.arrow_back_ios_new, size: 16, color: blueColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "Renter's Insurance Details",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: blueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _stackedField(String label, String value, {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: _muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tenantTile(TenantDetails t) {
    final first = (t.tenantFirstName ?? '').trim();
    final last = (t.tenantLastName ?? '').trim();
    final name = '$first $last'.trim();
    final initials =
        ((first.isNotEmpty ? first[0] : '') + (last.isNotEmpty ? last[0] : ''))
            .toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _innerBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: blueColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              initials.isEmpty ? '-' : initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '-' : name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.mail_outline, size: 14, color: _muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        t.tenantEmail?.isNotEmpty == true
                            ? t.tenantEmail!
                            : '-',
                        style: const TextStyle(
                          fontSize: 14,
                          color: _muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _documentTile(String fileName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _innerBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Icon(Icons.insert_drive_file_outlined,
                size: 22, color: blueColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName.isEmpty ? 'N/A' : fileName,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Insurance policy document',
                  style: TextStyle(fontSize: 13, color: _muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _viewButton(VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(Icons.visibility_outlined, size: 18, color: blueColor),
      label: Text(
        'View',
        style: TextStyle(
            color: blueColor, fontWeight: FontWeight.bold, fontSize: 15),
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _downloadButton(VoidCallback onTap) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.download, size: 18, color: Colors.white),
      label: const Text(
        'Download',
        style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: blueColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _emptyBox(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _innerBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: _muted,
        ),
      ),
    );
  }

}
