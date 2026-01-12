import 'dart:convert';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:three_zero_two_property/StaffModule/widgets/staff_report_header.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/Recurring_Payments_Configuration_model.dart';
import 'package:three_zero_two_property/repository/Recurring_Payments_Configuration_repo.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

import '../../../repository/GetAdminAddressPdf.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as syncXlsx;
import 'package:fluttertoast/fluttertoast.dart';

class Recurring_Payments_Configuration_Report extends StatefulWidget {
  const Recurring_Payments_Configuration_Report({super.key});

  @override
  State<Recurring_Payments_Configuration_Report> createState() =>
      _Recurring_Payments_Configuration_ReportState();
}

class _Recurring_Payments_Configuration_ReportState
    extends State<Recurring_Payments_Configuration_Report> {
  Recurring_Payments_Configuration? recurringPaymentsConfiguration;
  bool isLoading = true;
  String? errorMessage;
  String? expandedRowIndex;
  Map<String, String?> expandedTenantIndex = {};
  @override
  void initState() {
    super.initState();
    fetchRecurringPaymentConfiguration();
  }

  Future<void> fetchRecurringPaymentConfiguration() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("adminId");
      String? token = prefs.getString('token');
      String? id = prefs.getString("staff_id");
      final response = await http.get(
        Uri.parse(
            '$Api_url/api/recurring-cards/recurring-payment-configuration/$adminId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        setState(() {
          recurringPaymentsConfiguration =
              Recurring_Payments_Configuration.fromJson(parsedJson);
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load recurring payments configuration');
      }
    } catch (e) {
      print(e);
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load data. Please try again later.';
      });
    }
  }

  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      // decoration: BoxDecoration(
      //   color: blueColor,
      //   borderRadius: const BorderRadius.only(
      //     topLeft: Radius.circular(8),
      //     topRight: Radius.circular(8),
      //   ),
      // ),
      decoration: BoxDecoration(
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDBE0E5))),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        // leading: Container(
        //   child: Icon(
        //     Icons.expand_less,
        //     color: Colors.transparent,
        //   ),
        // ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              child: const Icon(
                Icons.expand_less,
                color: Colors.transparent,
              ),
            ),
            Expanded(
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    children: [
                      width < 400
                          ? Text("Property",
                              style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15))
                          : Text("Property",
                              style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                      // Text("Property", style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 3),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    children: [
                      width < 400
                          ? Text("Lease End Date",
                              style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15))
                          : Text("Lease End Date",
                              style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                      // Text("Property", style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 3),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Set<int> expandedIndices = {};
  int totalDisplayData = 0;
  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Scaffold(
        appBar: widget_302_Staff.App_Bar(context: context),
        drawer: CustomDrawerStaff(
          currentpage: "Reports",
          dropdown: false,
        ),
        body: isLoading
            ? Center(
                child: SpinKitFadingCircle(
                color: Colors.black,
                size: 40.0,
              ))
            : errorMessage != null
                ? Center(
                    child: Text(errorMessage!,
                        style: const TextStyle(color: Colors.red)))
                : recurringPaymentsConfiguration == null ||
                        recurringPaymentsConfiguration!.data!.isEmpty
                    ? const Center(child: Text("No Data Available"))
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            StaffReportHeader(
                              title: "Recurring Payments Configuration",
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width > 500
                                      ? 25
                                      : 16,
                                  right: MediaQuery.of(context).size.width > 500
                                      ? 25
                                      : 16),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 45
                                              : 50,
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .5
                                              : MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .4,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            border:
                                                Border.all(color: Colors.grey),
                                          ),
                                          child: TextField(
                                            onChanged: (value) {
                                              setState(() {
                                                // searchvalue = value;
                                              });
                                            },
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText: "Search here...",
                                              hintStyle: TextStyle(
                                                  color: Color(0xFF8A95A8)),
                                              contentPadding:
                                                  EdgeInsets.all(11),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: SizedBox(
                                      //  width: 100,
                                      height: 42,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: blueColor,
                                        ),
                                        onPressed: () {},
                                        child: PopupMenuButton<String>(
                                          onSelected: (value) async {
                                            // Export logic
                                            if (value == 'PDF') {
                                              print('pdf');
                                              generateAccountTotalReportPdf();
                                            } else if (value == 'XLSX') {
                                              print('pdf');
                                              generateRecurringPaymentExcel(
                                                  recurringPaymentsConfiguration!
                                                      .data!);
                                            } else if (value == 'CSV') {
                                              generateRecurringPaymentCsv(
                                                  recurringPaymentsConfiguration!
                                                      .data!);
                                            }
                                          },
                                          itemBuilder: (BuildContext context) =>
                                              <PopupMenuEntry<String>>[
                                            const PopupMenuItem<String>(
                                                value: 'PDF',
                                                child: Text('PDF')),
                                            const PopupMenuItem<String>(
                                                value: 'XLSX',
                                                child: Text('XLSX')),
                                            const PopupMenuItem<String>(
                                                value: 'CSV',
                                                child: Text('CSV')),
                                          ],
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text('Export'),
                                              Icon(Icons.arrow_drop_down),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width > 500
                                      ? 25
                                      : 23,
                                  right: MediaQuery.of(context).size.width > 500
                                      ? 25
                                      : 23),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Grand Total",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: greyColor),
                                  ),
                                  Text(
                                    "\$${recurringPaymentsConfiguration!.grandTotal}",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: greyColor),
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width > 500
                                      ? 25
                                      : 16,
                                  right: MediaQuery.of(context).size.width > 500
                                      ? 25
                                      : 16),
                              child: _buildHeaders(),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  left: MediaQuery.of(context).size.width > 500
                                      ? 25
                                      : 16,
                                  right: MediaQuery.of(context).size.width > 500
                                      ? 25
                                      : 16),
                              child: Column(
                                children: recurringPaymentsConfiguration!.data!
                                    .asMap()
                                    .entries
                                    .map((leaseData) {
                                  int rowIndex = leaseData.key;
                                  var leasesData = leaseData.value;

                                  return Column(
                                      children: leasesData!.leases!
                                          .asMap()
                                          .entries
                                          .map((lease) {
                                    int LeaserowIndex = lease.key;
                                    var payment = lease.value;

                                    bool isRowExpanded = expandedRowIndex ==
                                        "${rowIndex}${LeaserowIndex}";
                                    totalDisplayData++;
                                    return Container(
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      decoration: BoxDecoration(
                                        color: totalDisplayData % 2 != 0
                                            ? const Color(0xFFF4F8FF)
                                            : Colors.white,
                                        border: Border.all(
                                            color: const Color(0xFFDBE0E5)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Column(
                                        children: [
                                          ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            title: Padding(
                                              padding:
                                                  const EdgeInsets.all(2.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: <Widget>[
                                                  GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        if (expandedRowIndex ==
                                                            "${rowIndex}${LeaserowIndex}") {
                                                          expandedRowIndex =
                                                              null;
                                                        } else {
                                                          expandedRowIndex =
                                                              "${rowIndex}${LeaserowIndex}";
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 5,
                                                              right: 5),
                                                      padding: !isRowExpanded
                                                          ? const EdgeInsets
                                                              .only(bottom: 10)
                                                          : const EdgeInsets
                                                              .only(top: 10),
                                                      child: FaIcon(
                                                        isRowExpanded
                                                            ? FontAwesomeIcons
                                                                .sortUp
                                                            : FontAwesomeIcons
                                                                .sortDown,
                                                        size: 20,
                                                        color: isRowExpanded
                                                            ? blueColor
                                                            : blueColor,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          if (expandedRowIndex ==
                                                              "${rowIndex}${LeaserowIndex}") {
                                                            expandedRowIndex =
                                                                null;
                                                          } else {
                                                            expandedRowIndex =
                                                                "${rowIndex}${LeaserowIndex}";
                                                          }
                                                        });
                                                      },
                                                      child: Text(
                                                        '${payment.rentalAdress ?? '-'}',
                                                        style: TextStyle(
                                                          color: blueColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Text(
                                                      '  ${payment.endDate != null ? dateProvider.formatCurrentDate(payment.endDate!) : '-'}',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 5,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (isRowExpanded)
                                            Column(
                                              children: payment.tenants!
                                                  .where((recurruing) =>
                                                      recurruing
                                                          .recurrings!.length >
                                                      0)
                                                  .toList()!
                                                  .asMap()
                                                  .entries
                                                  .map((tenantEntry) {
                                                int tenantIndex =
                                                    tenantEntry.key;
                                                var tenant = tenantEntry.value;
                                                bool isTenantExpanded =
                                                    expandedTenantIndex[
                                                            "${rowIndex}${LeaserowIndex}"] ==
                                                        tenantIndex.toString();
                                                return Column(
                                                  children: [
                                                    Divider(
                                                      color: blueColor,
                                                      thickness: 1,
                                                    ),
                                                    ListTile(
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                      title: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2.0),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: <Widget>[
                                                            GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  if (expandedTenantIndex[
                                                                          "${rowIndex}${LeaserowIndex}"] ==
                                                                      tenantIndex
                                                                          .toString()) {
                                                                    expandedTenantIndex[
                                                                            "${rowIndex}${LeaserowIndex}"] =
                                                                        null;
                                                                  } else {
                                                                    expandedTenantIndex[
                                                                            "${rowIndex}${LeaserowIndex}"] =
                                                                        tenantIndex
                                                                            .toString();
                                                                  }
                                                                });
                                                              },
                                                              child: Container(
                                                                margin:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            5),
                                                                padding: !isTenantExpanded
                                                                    ? const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            10)
                                                                    : const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            10),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              24),
                                                                  child: FaIcon(
                                                                    isTenantExpanded
                                                                        ? FontAwesomeIcons
                                                                            .sortUp
                                                                        : FontAwesomeIcons
                                                                            .sortDown,
                                                                    size: 20,
                                                                    color:
                                                                        blueColor,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                                width: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width *
                                                                    .02),
                                                            Expanded(
                                                              child: RichText(
                                                                  text: TextSpan(
                                                                      children: [
                                                                    TextSpan(
                                                                      text:
                                                                          'Tenant ${tenantIndex + 1} ',
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            grey,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          ': ${tenant.tenantName ?? '-'}',
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            blueColor,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize:
                                                                            14,
                                                                      ),
                                                                    ),
                                                                  ])),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    if (isTenantExpanded)
                                                      Column(
                                                        children: tenant
                                                            .recurrings!
                                                            .asMap()
                                                            .entries
                                                            .map((entry) {
                                                          var recurring =
                                                              entry.value;
                                                          return Column(
                                                            children: [
                                                              Divider(
                                                                color:
                                                                    blueColor,
                                                              ),
                                                              ListTile(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                title: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          2.0),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: <Widget>[
                                                                      Expanded(
                                                                          flex:
                                                                              1,
                                                                          child:
                                                                              Text("")),
                                                                      Expanded(
                                                                          flex:
                                                                              2,
                                                                          child:
                                                                              Text(
                                                                            "Date: ${recurring.date != null ? dateProvider.formatCurrentDate(DateTime.fromMillisecondsSinceEpoch(recurring.date! * 1000).toString()) : ""}",
                                                                            style:
                                                                                TextStyle(fontSize: 14, color: blueColor),
                                                                          )),
                                                                      Expanded(
                                                                          flex:
                                                                              5,
                                                                          child:
                                                                              Text(
                                                                            "    ${recurring.account}",
                                                                            style:
                                                                                TextStyle(fontSize: 14, color: blueColor),
                                                                          )),
                                                                      Expanded(
                                                                          flex:
                                                                              3,
                                                                          child:
                                                                              Text(
                                                                            "\$${recurring.amount}",
                                                                            style:
                                                                                TextStyle(fontSize: 14, color: blueColor),
                                                                          )),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        }).toList(),
                                                      ),
                                                  ],
                                                );
                                              }).toList(),
                                            ),
                                        ],
                                      ),
                                    );
                                  }).toList());
                                }).toList(),
                              ),
                            )
                          ],
                        ),
                      ));
  }

  Future<void> generateAccountTotalReportPdf() async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final GetAddressAdminPdfService service = GetAddressAdminPdfService();
    profile? profileData;

    try {
      profileData = await service.fetchAdminAddress();
    } catch (e) {
      // Handle error
      print("Error fetching profile data: $e");
      return;
    }

    final pdf = pw.Document();
    final image = pw.MemoryImage(
      (await rootBundle.load('assets/images/applogo.png')).buffer.asUint8List(),
    );
    final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: pw.TextStyle(color: PdfColors.grey),
            ),
          );
        },
        header: (pw.Context context) => pw.Column(children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(image, width: 50, height: 50),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Text(
                    'Recurring Payments Configuration',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Date : - ${dateProvider.formatCurrentDate(DateTime.now().toString())}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    profileData?.companyName?.isNotEmpty == true
                        ? profileData!.companyName!
                        : 'N/A',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    profileData?.companyAddress?.isNotEmpty == true
                        ? profileData!.companyAddress!
                        : 'N/A',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '${profileData?.companyCity?.isNotEmpty == true ? profileData!.companyCity! : 'N/A'}, '
                    '${profileData?.companyState?.isNotEmpty == true ? profileData!.companyState! : 'N/A'}, '
                    '${profileData?.companyCountry?.isNotEmpty == true ? profileData!.companyCountry! : 'N/A'}',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    profileData?.companyPostalCode?.isNotEmpty == true
                        ? profileData!.companyPostalCode!
                        : 'N/A',
                    style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  //  pw.SizedBox(height: 30)
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20)
        ]),
        build: (pw.Context context) {
          return [
            pw.Table.fromTextArray(
                headers: [
                  'Property',
                  'Lease End Date',
                  'Tenant',
                  'Day of month of payment',
                  'Account',
                  'Amount'
                ],
                data: _generateTableData(
                    recurringPaymentsConfiguration!.data!, dateProvider),
                headerStyle: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex("#5A86D5"),
                  //color:PdfColor.fromRYB(90, 134, 213,)
                ),
                cellStyle: pw.TextStyle(fontSize: 10),
                cellAlignment: pw.Alignment.centerLeft,
                headerAlignment: pw.Alignment.centerLeft,
                border: null),
            pw.Divider(thickness: 3),
            pw.Padding(
                padding: pw.EdgeInsets.symmetric(horizontal: 5),
                child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('Grand Total',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                          '\$${recurringPaymentsConfiguration!.grandTotal!.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                    ])),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      format: PdfPageFormat.a4.landscape,
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  List<List<dynamic>> _generateTableData(
      List<Data> recurringPayment, DateProvider dateProvider) {
    final List<List<dynamic>> tableData = [];

    for (int i = 0; i < recurringPayment.length; i++) {
      var rental = recurringPayment[i];

      for (int j = 0; j < (rental.leases?.length ?? 0); j++) {
        var lease = rental.leases![j];
        int tenantCount = 0;
        bool isFirstTenant = false;
        for (int k = 0; k < (lease.tenants?.length ?? 0); k++) {
          var tenant = lease.tenants![k];

          // If the tenant has recurring payments, add the first recurring row with full details
          if (tenant.recurrings != null && tenant.recurrings!.isNotEmpty) {
            // For the first tenant in a lease, display the full address and end date
            isFirstTenant = tenantCount == 0;
            tenantCount = 1;
            print("${lease.rentalAdress} ${k}");
            tableData.add([
              isFirstTenant
                  ? pw.Text(
                      "${lease.rentalAdress ?? ''} ${lease.rentalUnit ?? ''}",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10))
                  : pw.Text(''),
              isFirstTenant
                  ? pw.Text(
                      lease.endDate != null
                          ? dateProvider.formatCurrentDate(lease.endDate!)
                          : "",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10))
                  : pw.Text(''),
              pw.Text(tenant.tenantName ?? "",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.Text(
                  tenant.recurrings![0].date != null
                      ? dateProvider.formatCurrentDate(
                          DateTime.fromMillisecondsSinceEpoch(
                                  tenant.recurrings![0].date! * 1000)
                              .toString())
                      : "",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.Text(tenant.recurrings![0].account ?? "",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 10)),
              pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text(
                      "\$${tenant.recurrings![0].amount?.toString()}" ?? "0",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10))),
            ]);

            // Add remaining recurring payments for the tenant without repeating address, end date, or tenant name
            for (int m = 1; m < tenant.recurrings!.length; m++) {
              var recurring = tenant.recurrings![m];

              tableData.add([
                "", // Empty property column (avoid repeating address)
                "", // Empty lease end date column
                "", // Empty tenant column
                pw.Text(
                    recurring.date != null
                        ? dateProvider.formatCurrentDate(
                            DateTime.fromMillisecondsSinceEpoch(
                                    recurring.date! * 1000)
                                .toString())
                        : "",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Text(recurring.account ?? "",
                    style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.Align(
                  alignment: pw.Alignment.centerRight,
                  child: pw.Text("\$${recurring.amount?.toString()}" ?? "0",
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 10)),
                )
              ]);
            }
          }
        }
      }
    }

    return tableData;
  }

  Future<void> generateRecurringPaymentExcel(
      List<Data> recurringPayment) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    final syncXlsx.Workbook workbook = syncXlsx.Workbook();
    final syncXlsx.Worksheet sheet = workbook.worksheets[0];

    // Set column widths for better readability
    sheet.getRangeByName('A1:F1').columnWidth = 20;

    // Define headers
    final List<String> headers = [
      'Property',
      'Lease End Date',
      'Tenant',
      'Day of month of payment',
      'Account',
      'Amount'
    ];

    // Header cell style
    final syncXlsx.Style headerCellStyle =
        workbook.styles.add('headerCellStyle');
    headerCellStyle.bold = true;
    headerCellStyle.backColor = '#5A86D5';
    headerCellStyle.fontColor = '#FFFFFF';
    headerCellStyle.fontSize = 12;
    headerCellStyle.hAlign = syncXlsx.HAlignType.center;

    // Currency cell style
    final syncXlsx.Style currencyCellStyle =
        workbook.styles.add('currencyCellStyle');
    currencyCellStyle.numberFormat = '\$#,##0.00'; // Currency format
    currencyCellStyle.hAlign = syncXlsx.HAlignType.right; // Right-align amounts

    // Set headers
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(1, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle = headerCellStyle;
    }

    int rowIndex = 2;

    for (int i = 0; i < recurringPayment.length; i++) {
      var rental = recurringPayment[i];

      for (int j = 0; j < (rental.leases?.length ?? 0); j++) {
        var lease = rental.leases![j];
        int tenantCount = 0;
        bool isFirstTenant = false;
        for (int k = 0; k < (lease.tenants?.length ?? 0); k++) {
          var tenant = lease.tenants![k];

          // If the tenant has recurring payments, add the first recurring row with full details
          if (tenant.recurrings != null && tenant.recurrings!.isNotEmpty) {
            isFirstTenant = tenantCount == 0;
            tenantCount = 1;

            // Add the first recurring payment (with rental address, lease end date, and tenant name)
            sheet.getRangeByIndex(rowIndex, 1).setText(isFirstTenant
                ? "${lease.rentalAdress ?? ''} ${lease.rentalUnit ?? ''}"
                : '');
            sheet.getRangeByIndex(rowIndex, 2).setText(isFirstTenant
                ? (lease.endDate != null
                    ? dateProvider.formatCurrentDate(lease.endDate!)
                    : '')
                : '');
            sheet.getRangeByIndex(rowIndex, 3).setText(tenant.tenantName ?? '');
            sheet.getRangeByIndex(rowIndex, 4).setText(
                  tenant.recurrings![0].date != null
                      ? dateProvider.formatCurrentDate(
                          DateTime.fromMillisecondsSinceEpoch(
                                  tenant.recurrings![0].date! * 1000)
                              .toString())
                      : "",
                );
            sheet
                .getRangeByIndex(rowIndex, 5)
                .setText(tenant.recurrings![0].account ?? "");
            sheet
                .getRangeByIndex(rowIndex, 6)
                .setNumber(tenant.recurrings![0].amount ?? 0.0);
            sheet.getRangeByIndex(rowIndex, 6).cellStyle = currencyCellStyle;

            rowIndex++;

            // Add remaining recurring payments without repeating the address, end date, or tenant name
            for (int m = 1; m < tenant.recurrings!.length; m++) {
              var recurring = tenant.recurrings![m];

              sheet.getRangeByIndex(rowIndex, 1).setText('');
              sheet.getRangeByIndex(rowIndex, 2).setText('');
              sheet.getRangeByIndex(rowIndex, 3).setText('');
              sheet.getRangeByIndex(rowIndex, 4).setText(
                    recurring.date != null
                        ? dateProvider.formatCurrentDate(
                            DateTime.fromMillisecondsSinceEpoch(
                                    recurring.date! * 1000)
                                .toString())
                        : "",
                  );
              sheet
                  .getRangeByIndex(rowIndex, 5)
                  .setText(recurring.account ?? "");
              sheet
                  .getRangeByIndex(rowIndex, 6)
                  .setNumber(recurring.amount ?? 0.0);
              sheet.getRangeByIndex(rowIndex, 6).cellStyle = currencyCellStyle;
              rowIndex++;
            }
          } else {
            // If no recurring payments, just add tenant details without recurring columns
            sheet.getRangeByIndex(rowIndex, 1).setText(k == 0
                ? "${lease.rentalAdress ?? ''} ${lease.rentalUnit ?? ''}"
                : '');
            sheet.getRangeByIndex(rowIndex, 2).setText(k == 0
                ? (lease.endDate != null
                    ? dateProvider.formatCurrentDate(lease.endDate!)
                    : '')
                : '');
            sheet.getRangeByIndex(rowIndex, 3).setText(tenant.tenantName ?? '');
            sheet.getRangeByIndex(rowIndex, 4).setText('');
            sheet.getRangeByIndex(rowIndex, 5).setText('');
            sheet.getRangeByIndex(rowIndex, 6).setText('');
            rowIndex++;
          }
        }
      }
    }
    sheet.getRangeByIndex(rowIndex, 1).setText('Grand Total');
    sheet
        .getRangeByName('A$rowIndex:E$rowIndex')
        .merge(); // Merge first 5 cells
    sheet.getRangeByIndex(rowIndex, 1).cellStyle.bold = true;
    //sheet.getRangeByIndex(rowIndex, 1).hAlign = syncXlsx.HAlignType.center; // Center align text

// Set Grand Total amount
    sheet
        .getRangeByIndex(rowIndex, 6)
        .setText("\$${recurringPaymentsConfiguration!.grandTotal}");
    sheet.getRangeByIndex(rowIndex, 6).cellStyle = currencyCellStyle;
    // sheet.getRangeByIndex(rowIndex, 6).cellStyle = boldAmountStyle; // Apply bold amount style
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'Recurring_Payment_Report_$formattedDate.xlsx';

    final Directory directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : Directory('/storage/emulated/0/Download');

    if (!await directory.exists() && !Platform.isIOS) {
      await directory.create(recursive: true);
    }

    final path = '${directory.path}/$fileName';
    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    Share.shareXFiles([XFile(path)]);
    Fluttertoast.showToast(msg: 'Excel file saved to $path');
  }

  Future<void> generateRecurringPaymentCsv(List<Data> recurringPayment) async {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    // Define headers for CSV
    final List<String> headers = [
      'Property',
      'Lease End Date',
      'Tenant',
      'Day of month of payment',
      'Account',
      'Amount'
    ];

    // Create a buffer to store CSV data
    final StringBuffer csvBuffer = StringBuffer();

    // Add headers to the CSV file
    csvBuffer.writeln(headers.join(','));

    double grandTotal = 0.0;

    // Iterate through each rental property
    for (var rental in recurringPayment) {
      for (var lease in rental.leases ?? []) {
        int tenantCount = 0;

        for (var tenant in lease.tenants ?? []) {
          bool isFirstTenant = tenantCount == 0;
          tenantCount = 1;

          // If the tenant has recurring payments, add the first recurring row with full details
          if (tenant.recurrings != null && tenant.recurrings!.isNotEmpty) {
            csvBuffer.writeln([
              isFirstTenant
                  ? "${lease.rentalAdress ?? ''} ${lease.rentalUnit ?? ''}"
                  : '',
              isFirstTenant
                  ? (lease.endDate != null
                      ? dateProvider.formatCurrentDate(lease.endDate!)
                      : '')
                  : '',
              tenant.tenantName ?? '',
              tenant.recurrings![0].date != null
                  ? dateProvider.formatCurrentDate(
                      DateTime.fromMillisecondsSinceEpoch(
                              tenant.recurrings![0].date! * 1000)
                          .toString())
                  : "",
              tenant.recurrings![0].account ?? "",
              "\$${tenant.recurrings![0].amount}" ?? 0.0
            ].map((e) => '"$e"').join(
                ',')); // Wrap each value in quotes to handle special characters

            grandTotal += tenant.recurrings![0].amount ?? 0.0;

            // Add remaining recurring payments without repeating address, lease date, or tenant name
            for (int m = 1; m < tenant.recurrings!.length; m++) {
              var recurring = tenant.recurrings![m];

              csvBuffer.writeln([
                '',
                '',
                '',
                recurring.date != null
                    ? dateProvider.formatCurrentDate(
                        DateTime.fromMillisecondsSinceEpoch(
                                recurring.date! * 1000)
                            .toString())
                    : "",
                recurring.account ?? "",
                "\$${recurring.amount}" ?? 0.0
              ].map((e) => '"$e"').join(','));

              grandTotal += recurring.amount ?? 0.0;
            }
          } else {
            // If no recurring payments, just add tenant details without recurring columns
            csvBuffer.writeln([
              isFirstTenant
                  ? "${lease.rentalAdress ?? ''} ${lease.rentalUnit ?? ''}"
                  : '',
              isFirstTenant
                  ? (lease.endDate != null
                      ? dateProvider.formatCurrentDate(lease.endDate!)
                      : '')
                  : '',
              tenant.tenantName ?? '',
              '',
              '',
              ''
            ].map((e) => '"$e"').join(','));
          }
        }
      }
    }

    // Add Grand Total row
    csvBuffer.writeln([
      'Grand Total',
      '',
      '',
      '',
      '',
      "\$${grandTotal.toStringAsFixed(2)}"
    ].map((e) => '"$e"').join(','));

    // Convert buffer to list of bytes for CSV file
    final List<int> bytes = utf8.encode(csvBuffer.toString());

    // Define file name with current date and time
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'Recurring_Payment_Report_$formattedDate.csv';

    // Define file path
    final Directory directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : Directory('/storage/emulated/0/Download');

    final path = '${directory.path}/$fileName';

    // Create directory if it doesn't exist (for Android)
    if (!await directory.exists() && !Platform.isIOS) {
      await directory.create(recursive: true);
    }

    // Write CSV file to the path
    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    Share.shareXFiles([XFile(path)]);

    // Show success toast message
    Fluttertoast.showToast(
      msg: 'CSV file saved to $path',
    );
  }
}
