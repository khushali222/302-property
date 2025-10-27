import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as syncXlsx;
import 'package:fluttertoast/fluttertoast.dart';
import '../../../../Model/Home_System_Report_model.dart';
import '../../../../Model/rentrollreportmodel.dart';
import '../../../repository/home_system_report_repository.dart';
import '../../../widgets/custom_drawer.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class HomeSystemReportScreen extends StatefulWidget {
  @override
  State<HomeSystemReportScreen> createState() => _HomeSystemReportScreenState();
}

class _HomeSystemReportScreenState extends State<HomeSystemReportScreen> {
  // Change from late Future to nullable Future
  Future<Home_system_report>? _futureRentersInsurance;
  rentrollreportmodel? rentersInsuranceModel;
  bool isLoading = true;
  String? errorMessage;
  int? expandedRowIndex;
  Map<int, int?> expandedTenantIndex = {};
  ConnectivityResult? _connectivityResult;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });
    _loadProperties();
    checkInternet();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        await Permission.storage.request();
      }
    }
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  Future<Home_system_report> fetchRentersInsuranceData({String? id}) async {
    print("calling rental id call ... 1 ");
    if (id == null || id.isEmpty) {
      throw Exception('Rental ID is required');
    }

    Home_system_reportService service = Home_system_reportService();
    try {
      Home_system_report data = await service.fetchHomeSystemData(id);
      setState(() {
        isLoading = false;
        errorMessage = null;
      });
      return data;
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Failed to load home system data. Please try again later.';
      });
      throw Exception('Failed to load home system data');
    }
  }

  String searchvalue = "";
  String? selectedValue;

  int totalrecords = 0;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [10, 25, 50, 100];

  // int? expandedRowIndex;
  int? nestedExpandedIndex;

  int? expandedLeaseIndex;
  int? expandedLeaseTotalIndex;
  int? expandedIndex;
  Set<int> expandedIndices = {};
  late bool isExpanded;
  bool sorting1 = false;
  bool sorting2 = false;
  bool sorting3 = false;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;

  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
        color: blueColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
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
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting1) {
                      sorting2 = false;
                      sorting3 = false;
                      ascending1 = sorting1 ? !ascending1 : true;
                      ascending2 = false;
                      ascending3 = false;
                    } else {
                      sorting1 = !sorting1;
                      sorting2 = false;
                      sorting3 = false;
                      ascending1 = sorting1 ? !ascending1 : true;
                      ascending2 = false;
                      ascending3 = false;
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    children: [
                      width < 400
                          ? const Text("    Unit\n    Details",
                              style: TextStyle(color: Colors.white))
                          : const Text("    Unit\n    Details",
                              style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 3),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting2) {
                      sorting1 = false;
                      sorting2 = sorting2;
                      sorting3 = false;
                      ascending2 = sorting2 ? !ascending2 : true;
                      ascending1 = false;
                      ascending3 = false;
                    } else {
                      sorting1 = false;
                      sorting2 = !sorting2;
                      sorting3 = false;
                      ascending2 = sorting2 ? !ascending2 : true;
                      ascending1 = false;
                      ascending3 = false;
                    }
                  });
                },
                child: const Row(
                  children: [
                    Text("       Appliance\n       Status",
                        style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  pw.Widget leftAlignedText(String text, {bool isBold = false}) {
    return pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: isBold
            ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)
            : const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  pw.Widget rightAlignedText(String text, {bool isBold = false}) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        text,
        style: isBold
            ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)
            : const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  Future<void> generaterentersInsurancePdf(Home_system_report data) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(
      (await rootBundle.load('assets/images/applogo.png')).buffer.asUint8List(),
    );
    final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    // First Page - Details
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Header with logo and title
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(image, width: 40, height: 40),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Home System Report',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'As of $currentDate',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Text(
                    'Markdueltd',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Details',
              style: pw.TextStyle(
                fontSize: 14,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            // Details Table
            pw.Table(
              border: pw.TableBorder.symmetric(
                outside: const pw.BorderSide(color: PdfColors.grey300),
              ),
              children: [
                // Table Header
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex("#4B88E8"),
                  ),
                  children: [
                    _buildDetailHeader('Home System Name'),
                    _buildDetailHeader('Description'),
                    _buildDetailHeader('Category'),
                    _buildDetailHeader('Type'),
                    _buildDetailHeader('Brand'),
                    _buildDetailHeader('Model'),
                    _buildDetailHeader('Serial Number'),
                    _buildDetailHeader('Installed Date'),
                    _buildDetailHeader('Warranty Expiry'),
                    _buildDetailHeader('Last Maintenance'),
                    _buildDetailHeader('Status'),
                  ],
                ),
                // Units and their appliances
                ...data.units!.expand((unit) {
                  // Add unit header row
                  var rows = [
                    pw.TableRow(
                      children: [
                        _buildDetailCell(
                          'Unit: ${unit.unitNumber} - ${unit.unitAddress}',
                          isBold: true,
                          color: PdfColors.black,
                        ),
                        _buildDetailCell(''),
                        _buildDetailCell(''),
                        _buildDetailCell(''),
                        _buildDetailCell(''),
                        _buildDetailCell(''),
                        _buildDetailCell(''),
                        _buildDetailCell(''),
                        _buildDetailCell(''),
                        _buildDetailCell(''),
                        _buildDetailCell(''),
                      ],
                    ),
                  ];

                  // Add appliance data or no appliances message
                  if (unit.appliances == null || unit.appliances!.isEmpty) {
                    rows.add(pw.TableRow(
                      children: [
                        _buildDetailCell('No appliances found in this unit',
                            isItalic: true),
                        _buildDetailCell('-'),
                        _buildDetailCell('-'),
                        _buildDetailCell('-'),
                        _buildDetailCell('-'),
                        _buildDetailCell('-'),
                        _buildDetailCell('-'),
                        _buildDetailCell('-'),
                        _buildDetailCell('-'),
                        _buildDetailCell('-'),
                        _buildDetailCell('-'),
                      ],
                    ));
                  } else {
                    rows.addAll(
                      unit.appliances!.map((appliance) => pw.TableRow(
                            children: [
                              _buildDetailCell(appliance.applianceName ?? '-'),
                              _buildDetailCell(
                                  appliance.applianceDescription ?? '-'),
                              _buildDetailCell(appliance.category ?? '-'),
                              _buildDetailCell(appliance.type ?? '-'),
                              _buildDetailCell(appliance.brand ?? '-'),
                              _buildDetailCell(appliance.model ?? '-'),
                              _buildDetailCell(appliance.serialNumber ?? '-'),
                              _buildDetailCell(appliance.installedDate ?? '-'),
                              _buildDetailCell(appliance.warrantyExpiry ?? '-'),
                              _buildDetailCell(
                                  appliance.lastMaintenanceDate ?? '-'),
                              _buildDetailCell(appliance.status ?? '-',
                                  color: appliance.status?.toLowerCase() ==
                                          'working'
                                      ? PdfColors.green
                                      : PdfColors.red),
                            ],
                          )),
                    );
                  }

                  return rows;
                }),
              ],
            ),
          ];
        },
      ),
    );

    // Second Page - Summary
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(image, width: 40, height: 40),
                  pw.Column(
                    children: [
                      pw.Text(
                        'Home Systems Report',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                        'As of $currentDate',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text(
              'Summary',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 10),
            // Header for the summary table
            pw.Container(
              color: PdfColor.fromHex("#4B88E8"),
              padding:
                  const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 10),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Date',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Performed By',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(
                      'Work Subject',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ...data.units!
                .map((unit) => pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.all(10),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(
                                'Unit: ${unit.unitNumber} - ${unit.unitAddress}',
                                style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(height: 5),
                              if (unit.appliances == null ||
                                  unit.appliances!.isEmpty) ...[
                                pw.Container(
                                  padding: const pw.EdgeInsets.all(8),
                                  decoration: pw.BoxDecoration(
                                    border:
                                        pw.Border.all(color: PdfColors.grey300),
                                    borderRadius: const pw.BorderRadius.all(
                                        pw.Radius.circular(4)),
                                  ),
                                  child: pw.Row(
                                    children: [
                                      pw.Text(
                                        'No appliances found in this unit',
                                        style: pw.TextStyle(
                                          fontSize: 10,
                                          fontStyle: pw.FontStyle.italic,
                                          color: PdfColors.grey700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (unit.appliances != null)
                                ...unit.appliances!.map((appliance) {
                                  return pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Text(
                                        appliance.applianceName ?? '',
                                        style: pw.TextStyle(
                                          fontSize: 11,
                                          fontWeight: pw.FontWeight.bold,
                                        ),
                                      ),
                                      pw.SizedBox(height: 5),
                                      // Maintenance History
                                      if (appliance
                                              .maintenanceHistory?.isNotEmpty ==
                                          true) ...[
                                        pw.Container(
                                          color: PdfColor.fromHex("#F5F5F5"),
                                          padding: const pw.EdgeInsets.all(8),
                                          child: pw.Column(
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(
                                                'Maintenance History',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                ),
                                              ),
                                              pw.SizedBox(height: 5),
                                              ...appliance.maintenanceHistory!
                                                  .map((history) => pw.Row(
                                                        children: [
                                                          pw.Expanded(
                                                            flex: 2,
                                                            child: pw.Text(
                                                                history.timestamp ??
                                                                    'N/A',
                                                                style: const pw
                                                                    .TextStyle(
                                                                    fontSize:
                                                                        9)),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 2,
                                                            child: pw.Text(
                                                                history.adminName ??
                                                                    history
                                                                        .staffmemberName ??
                                                                    'N/A',
                                                                style: const pw
                                                                    .TextStyle(
                                                                    fontSize:
                                                                        9)),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 3,
                                                            child: pw.Text(
                                                                history.workSubject ??
                                                                    'N/A',
                                                                style: const pw
                                                                    .TextStyle(
                                                                    fontSize:
                                                                        9)),
                                                          ),
                                                        ],
                                                      ))
                                                  .toList(),
                                            ],
                                          ),
                                        ),
                                      ],
                                      // Notes Section
                                      if (appliance.notes?.isNotEmpty ==
                                          true) ...[
                                        pw.SizedBox(height: 5),
                                        pw.Container(
                                          color: PdfColor.fromHex("#F5F5F5"),
                                          padding: const pw.EdgeInsets.all(8),
                                          child: pw.Column(
                                            crossAxisAlignment:
                                                pw.CrossAxisAlignment.start,
                                            children: [
                                              pw.Text(
                                                'Notes',
                                                style: pw.TextStyle(
                                                  fontSize: 10,
                                                  fontWeight:
                                                      pw.FontWeight.bold,
                                                ),
                                              ),
                                              pw.SizedBox(height: 5),
                                              ...appliance.notes!
                                                  .map((note) => pw.Row(
                                                        children: [
                                                          pw.Expanded(
                                                            flex: 2,
                                                            child: pw.Text(
                                                                note.timestamp ??
                                                                    'N/A',
                                                                style: const pw
                                                                    .TextStyle(
                                                                    fontSize:
                                                                        9)),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 2,
                                                            child: pw.Text(
                                                                note.adminName ??
                                                                    note
                                                                        .staffmemberName ??
                                                                    'N/A',
                                                                style: const pw
                                                                    .TextStyle(
                                                                    fontSize:
                                                                        9)),
                                                          ),
                                                          pw.Expanded(
                                                            flex: 3,
                                                            child: pw.Text(
                                                                note.note ??
                                                                    'N/A',
                                                                style: const pw
                                                                    .TextStyle(
                                                                    fontSize:
                                                                        9)),
                                                          ),
                                                        ],
                                                      ))
                                                  .toList(),
                                            ],
                                          ),
                                        ),
                                      ],
                                      pw.SizedBox(height: 10),
                                    ],
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ],
                    ))
                .toList(),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

// Helper method for detail table headers
  pw.Widget _buildDetailHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 9,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

// Helper method for detail table cells
  pw.Widget _buildDetailCell(String text,
      {PdfColor? color, bool isBold = false, bool isItalic = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 8,
          color: color,
          fontWeight: isBold ? pw.FontWeight.bold : null,
          fontStyle: isItalic ? pw.FontStyle.italic : null,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  Future<void> generateRentersInsuranceExcel(Home_system_report data) async {
    final syncXlsx.Workbook workbook = syncXlsx.Workbook();

    // Details Sheet
    final syncXlsx.Worksheet detailsSheet = workbook.worksheets[0];
    detailsSheet.name = 'Details';

    // Headers for Details
    final detailHeaders = [
      'Home System Name',
      'Description',
      'Category',
      'Type',
      'Brand',
      'Model',
      'Serial Number',
      'Installed Date',
      'Warranty Expiry',
      'Last Maintenance',
      'Status'
    ];

    // Add headers with styling
    for (int i = 0; i < detailHeaders.length; i++) {
      detailsSheet.getRangeByIndex(1, i + 1).setText(detailHeaders[i]);
      detailsSheet.getRangeByIndex(1, i + 1).cellStyle.bold = true;
      detailsSheet.getRangeByIndex(1, i + 1).cellStyle.backColor = '#4B88E8';
      detailsSheet.getRangeByIndex(1, i + 1).cellStyle.fontColor = '#FFFFFF';
      // Add thin border to header cells
      detailsSheet.getRangeByIndex(1, i + 1).cellStyle.borders.all.lineStyle =
          syncXlsx.LineStyle.thin;
      detailsSheet.getRangeByIndex(1, i + 1).cellStyle.borders.all.color =
          '#4B88E8';
    }

    // Add data to Details sheet
    int detailRow = 2;
    for (var unit in data.units!) {
      // Add unit header with merged cells
      var unitRange = detailsSheet.getRangeByIndex(
          detailRow, 1, detailRow, detailHeaders.length);
      unitRange.merge();
      detailsSheet
          .getRangeByIndex(detailRow, 1)
          .setText('Unit: ${unit.unitNumber} - ${unit.unitAddress}');
      detailsSheet.getRangeByIndex(detailRow, 1).cellStyle.bold = true;
      detailsSheet.getRangeByIndex(detailRow, 1).cellStyle.backColor =
          '#F5F5F5';
      detailRow++;

      if (unit.appliances == null || unit.appliances!.isEmpty) {
        // Add row for unit with no appliances
        var noApplianceRange = detailsSheet.getRangeByIndex(
            detailRow, 1, detailRow, detailHeaders.length);
        noApplianceRange.merge();
        detailsSheet
            .getRangeByIndex(detailRow, 1)
            .setText('No appliances found in this unit');
        detailsSheet.getRangeByIndex(detailRow, 1).cellStyle.italic = true;
        detailsSheet.getRangeByIndex(detailRow, 1).cellStyle.hAlign =
            syncXlsx.HAlignType.center;
        detailsSheet.getRangeByIndex(detailRow, 1).cellStyle.fontColor =
            '#666666';
        detailRow++;
      } else {
        for (var appliance in unit.appliances!) {
          detailsSheet
              .getRangeByIndex(detailRow, 1)
              .setText(appliance.applianceName ?? '-');
          detailsSheet
              .getRangeByIndex(detailRow, 2)
              .setText(appliance.applianceDescription ?? '-');
          detailsSheet
              .getRangeByIndex(detailRow, 3)
              .setText(appliance.category ?? '-');
          detailsSheet
              .getRangeByIndex(detailRow, 4)
              .setText(appliance.type ?? '-');
          detailsSheet
              .getRangeByIndex(detailRow, 5)
              .setText(appliance.brand ?? '-');
          detailsSheet
              .getRangeByIndex(detailRow, 6)
              .setText(appliance.model ?? '-');
          detailsSheet
              .getRangeByIndex(detailRow, 7)
              .setText(appliance.serialNumber ?? '-');
          detailsSheet
              .getRangeByIndex(detailRow, 8)
              .setText(appliance.installedDate ?? '-');
          detailsSheet
              .getRangeByIndex(detailRow, 9)
              .setText(appliance.warrantyExpiry ?? '-');
          detailsSheet
              .getRangeByIndex(detailRow, 10)
              .setText(appliance.lastMaintenanceDate ?? '-');
          detailsSheet
              .getRangeByIndex(detailRow, 11)
              .setText(appliance.status ?? '-');

          // Color the status cell
          if (appliance.status?.toLowerCase() == 'working') {
            detailsSheet.getRangeByIndex(detailRow, 11).cellStyle.fontColor =
                '#008000'; // Green
          } else {
            detailsSheet.getRangeByIndex(detailRow, 11).cellStyle.fontColor =
                '#FF0000'; // Red
          }

          detailRow++;
        }
      }
    }

    // Auto-fit columns in Details sheet
    for (int i = 1; i <= detailHeaders.length; i++) {
      detailsSheet.autoFitColumn(i);
    }

    // Summary Sheet
    final syncXlsx.Worksheet summarySheet = workbook.worksheets.add();
    summarySheet.name = 'Summary';

    // Headers for Summary
    final summaryHeaders = ['Date', 'Performed By', 'Work Subject'];
    for (int i = 0; i < summaryHeaders.length; i++) {
      summarySheet.getRangeByIndex(1, i + 1).setText(summaryHeaders[i]);
      summarySheet.getRangeByIndex(1, i + 1).cellStyle.bold = true;
      summarySheet.getRangeByIndex(1, i + 1).cellStyle.backColor = '#4B88E8';
      summarySheet.getRangeByIndex(1, i + 1).cellStyle.fontColor = '#FFFFFF';
    }

    int summaryRow = 2;
    for (var unit in data.units!) {
      // Add unit header
      summarySheet
          .getRangeByIndex(summaryRow, 1)
          .setText('Unit: ${unit.unitNumber} - for test');
      summarySheet.getRangeByIndex(summaryRow, 1).cellStyle.bold = true;
      summaryRow++;

      if (unit.appliances != null) {
        for (var appliance in unit.appliances!) {
          // Add appliance name
          summarySheet
              .getRangeByIndex(summaryRow, 1)
              .setText(appliance.applianceName ?? '-');
          summarySheet.getRangeByIndex(summaryRow, 1).cellStyle.bold = true;
          summaryRow++;

          // Add Maintenance History header
          if (appliance.maintenanceHistory?.isNotEmpty == true) {
            summarySheet
                .getRangeByIndex(summaryRow, 1)
                .setText('Maintenance History');
            summarySheet.getRangeByIndex(summaryRow, 1).cellStyle.bold = true;
            summarySheet.getRangeByIndex(summaryRow, 1).cellStyle.backColor =
                '#F5F5F5';
            summaryRow++;

            for (var history in appliance.maintenanceHistory!) {
              summarySheet
                  .getRangeByIndex(summaryRow, 1)
                  .setText(history.timestamp ?? 'N/A');
              summarySheet.getRangeByIndex(summaryRow, 2).setText(
                  history.adminName ?? history.staffmemberName ?? 'N/A');
              summarySheet
                  .getRangeByIndex(summaryRow, 3)
                  .setText(history.workSubject ?? 'N/A');
              summaryRow++;
            }
          }

          // Add Notes header
          if (appliance.notes?.isNotEmpty == true) {
            summarySheet.getRangeByIndex(summaryRow, 1).setText('Notes');
            summarySheet.getRangeByIndex(summaryRow, 1).cellStyle.bold = true;
            summarySheet.getRangeByIndex(summaryRow, 1).cellStyle.backColor =
                '#F5F5F5';
            summaryRow++;

            for (var note in appliance.notes!) {
              summarySheet
                  .getRangeByIndex(summaryRow, 1)
                  .setText(note.timestamp ?? 'N/A');
              summarySheet
                  .getRangeByIndex(summaryRow, 2)
                  .setText(note.adminName ?? note.staffmemberName ?? 'N/A');
              summarySheet
                  .getRangeByIndex(summaryRow, 3)
                  .setText(note.note ?? 'N/A');
              summaryRow++;
            }
          }

          summaryRow++; // Add space between appliances
        }
      }
      summaryRow++; // Add space between units
    }

    // Auto-fit columns in Summary sheet
    for (int i = 1; i <= summaryHeaders.length; i++) {
      summarySheet.autoFitColumn(i);
    }

    // Save the file
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'Home_Systems_Report_$formattedDate.xlsx';

    final Directory directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : Directory('/storage/emulated/0/Pictures');

    final path = '${directory.path}/$fileName';

    // Create directory if it doesn't exist (for Android)
    if (!await directory.exists() && !Platform.isIOS) {
      await directory.create(recursive: true);
    }

    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    Share.shareXFiles([XFile(path)]);
    Fluttertoast.showToast(
      msg: 'Excel file saved to $path',
    );
  }

  Future<void> generateRentersInsuranceCSV(Home_system_report data) async {
    final StringBuffer csvBuffer = StringBuffer();
    final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    // Details Section
    csvBuffer.writeln('Home Systems Report - Details');
    csvBuffer.writeln('As of $currentDate');
    csvBuffer.writeln();

    // Details Headers
    final detailHeaders = [
      'Home System Name',
      'Description',
      'Category',
      'Type',
      'Brand',
      'Model',
      'Serial Number',
      'Installed Date',
      'Warranty Expiry',
      'Last Maintenance',
      'Status'
    ];
    csvBuffer.writeln(detailHeaders.map((h) => '"$h"').join(','));

    // Details Data
    for (var unit in data.units!) {
      // Add unit header (centered across columns)
      final unitHeader = '"Unit: ${unit.unitNumber} - ${unit.unitAddress}"';
      csvBuffer.writeln(unitHeader +
          ',' +
          List.filled(detailHeaders.length - 1, '""').join(','));

      if (unit.appliances == null || unit.appliances!.isEmpty) {
        // Add row for no appliances (centered message)
        final noAppliancesMessage = '"No appliances found in this unit"';
        csvBuffer.writeln(noAppliancesMessage +
            ',' +
            List.filled(detailHeaders.length - 1, '""').join(','));
      } else {
        for (var appliance in unit.appliances!) {
          final row = [
            appliance.applianceName ?? '-',
            appliance.applianceDescription ?? '-',
            appliance.category ?? '-',
            appliance.type ?? '-',
            appliance.brand ?? '-',
            appliance.model ?? '-',
            appliance.serialNumber ?? '-',
            appliance.installedDate ?? '-',
            appliance.warrantyExpiry ?? '-',
            appliance.lastMaintenanceDate ?? '-',
            appliance.status ?? '-'
          ];
          csvBuffer.writeln(row
              .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
              .join(','));
        }
      }
    }

    // Summary Section
    csvBuffer.writeln();
    csvBuffer.writeln();
    csvBuffer.writeln('Home Systems Report - Summary');
    csvBuffer.writeln('As of $currentDate');
    csvBuffer.writeln();

    for (var unit in data.units!) {
      csvBuffer.writeln('"Unit: ${unit.unitNumber} - for test"');

      if (unit.appliances != null) {
        for (var appliance in unit.appliances!) {
          csvBuffer.writeln('"${appliance.applianceName ?? '-'}"');

          // Maintenance History
          if (appliance.maintenanceHistory?.isNotEmpty == true) {
            csvBuffer.writeln('"Maintenance History"');
            csvBuffer.writeln('"Date","Performed By","Work Subject"');
            for (var history in appliance.maintenanceHistory!) {
              final row = [
                history.timestamp ?? 'N/A',
                history.adminName ?? history.staffmemberName ?? 'N/A',
                history.workSubject ?? 'N/A'
              ];
              csvBuffer.writeln(row
                  .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
                  .join(','));
            }
            csvBuffer.writeln();
          }

          // Notes
          if (appliance.notes?.isNotEmpty == true) {
            csvBuffer.writeln('"Notes"');
            csvBuffer.writeln('"Date","Performed By","Note"');
            for (var note in appliance.notes!) {
              final row = [
                note.timestamp ?? 'N/A',
                note.adminName ?? note.staffmemberName ?? 'N/A',
                note.note ?? 'N/A'
              ];
              csvBuffer.writeln(row
                  .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
                  .join(','));
            }
            csvBuffer.writeln();
          }
        }
      }
      csvBuffer.writeln();
    }

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'Home_Systems_Report_$formattedDate.csv';

    final Directory directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : Directory('/storage/emulated/0/Pictures');

    final path = '${directory.path}/$fileName';

    // Create directory if it doesn't exist (for Android)
    if (!await directory.exists() && !Platform.isIOS) {
      await directory.create(recursive: true);
    }

    final File file = File(path);
    await file.writeAsString(csvBuffer.toString(), flush: true);
    Share.shareXFiles([XFile(path)]);
    Fluttertoast.showToast(
      msg: 'CSV file saved to $path',
    );
  }

  final cellStyle = const pw.TextStyle(fontSize: 7);

  final headerStyle = pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    fontSize: 9,
    color: PdfColors.white,
  );

  final headerDecoration = pw.BoxDecoration(
    color: PdfColor.fromHex("#5A86D5"), // a nice blue shade
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
  );

  String? selectedOwner;
  final List<String> rentalOwners = [
    'All Owners',
    'Owner 1',
    'Owner 2',
    'Owner 3',
  ];

  final List<String> downloadOptions = ['PDF', 'Excel', 'CSV'];

  void handleDownload(String format) {
    // Replace with your download logic
    print("Downloading as $format");
  }

  String? _selectedPropertyId;
  Map<String, String> properties = {}; // Mapping of rental_id to rental_address
  Map<String, String> units = {};
  String? _selectedProperty;
  String renderId = '';
  bool _isLoading = false;
  bool _isExporting = false;

  Future<void> _loadProperties() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await http
          .get(Uri.parse('${Api_url}/api/rentals/rentals/$adminid'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      });
      print('${Api_url}/api/rentals/rentals/$adminid');
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body)['data'];
        Map<String, String> addresses = {};
        jsonResponse.forEach((data) {
          addresses[data['rental_id'].toString()] =
              data['rental_adress'].toString();
        });

        setState(() {
          properties = addresses;
          _isLoading = false;
        });
        print("Available properties: $properties"); // Debug print
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print("Error loading properties: $e"); // Debug print
    }
  }

  int _selectedTabIndex = 0;

  // Rename the method to avoid duplication
  Widget _buildTabButtonItem(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? blueColor : Colors.white,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : blueColor,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          _buildTabButtonItem("Details", 0),
          _buildTabButtonItem("Summary", 1),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget_302.App_Bar(context: context),
      drawer: CustomDrawerStaff(
        currentpage: "Reports",
        dropdown: false,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  titleBar(
                    title: 'Home System Report',
                    width: MediaQuery.of(context).size.width * .91,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildActionButtons(), // Add action buttons
                      _buildTabBar(),
                      FutureBuilder<Home_system_report>(
                        future: _futureRentersInsurance,
                        builder: (context, snapshot) {
                          if (_futureRentersInsurance == null) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/no_data.jpg",
                                    height: 200,
                                    width: 200,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Please select a property",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          if (isLoading) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: SpinKitFadingCircle(
                                    color: Colors.black, size: 45),
                              ),
                            );
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(
                                errorMessage ?? 'An error occurred',
                                style: const TextStyle(color: Colors.red),
                              ),
                            );
                          }

                          if (!snapshot.hasData ||
                              snapshot.data?.units?.isEmpty == true) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/no_data.jpg",
                                    height: 200,
                                    width: 200,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "No Data Available",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                          return _selectedTabIndex == 0
                              ? _buildDataTable(snapshot.data!)
                              : _buildSummaryView(snapshot.data!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(
              child: Text("No Internet Connection"),
            ),
    );
  }

  bool isRowExpanded = false;
  bool isRowPropertyExpanded = false;

  TableRow buildTableRows(
      String leftLabel,
      String leftValue,
      String centerLabel,
      String centerValue,
      String rightLabel,
      String rightValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                const SizedBox(height: 4.0), // Space between label and value
                Text(
                  leftValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  centerLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                const SizedBox(height: 4.0), // Space between label and value
                Text(
                  centerValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                const SizedBox(height: 4.0), // Space between label and value
                Text(
                  rightValue,
                  style: TextStyle(color: grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryView(Home_system_report data) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.units?.length ?? 0,
      itemBuilder: (context, unitIndex) {
        final unit = data.units![unitIndex];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Unit: ${unit.unitNumber} - ${unit.unitAddress}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                ),
              ),
            ),
            if (unit.appliances == null || unit.appliances!.isEmpty)
              Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline,
                          color: Colors.grey[600], size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'No appliances found in this unit',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (unit.appliances != null)
              ...unit.appliances!.map((appliance) {
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: blueColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: blueColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          appliance.applianceName ?? 'Unnamed Appliance',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: blueColor,
                          ),
                        ),
                      ),
                      // Maintenance History Section
                      if (appliance.maintenanceHistory?.isNotEmpty == true) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            'Maintenance History',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: blueColor,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: appliance.maintenanceHistory!.length,
                            separatorBuilder: (context, index) => Divider(
                              color: Colors.grey[300],
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final history =
                                  appliance.maintenanceHistory![index];
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "DATE : ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: blueColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n${_formatDate(history.timestamp ?? 'N/A')}",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "PERFORMED BY : ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: blueColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n${history.adminName ?? history.staffmemberName ?? 'N/A'}",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if (history.workSubject?.isNotEmpty == true)
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "WORK SUBJECT : ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: blueColor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "\n${history.workSubject}",
                                              style: const TextStyle(
                                                color: Colors.black,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ] else
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'No maintenance history available for this appliance.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      // Notes Section
                      if (appliance.notes?.isNotEmpty == true) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Text(
                            'Notes',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: blueColor,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: appliance.notes!.length,
                            separatorBuilder: (context, index) => Divider(
                              color: Colors.grey[300],
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final note = appliance.notes![index];
                              return Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "DATE: ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: blueColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n${_formatDate(note.timestamp ?? 'N/A')}",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "ADDED BY : ",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: blueColor,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      "\n${note.adminName ?? note.staffmemberName ?? 'N/A'}",
                                                  style: const TextStyle(
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: "NOTE : ",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: blueColor,
                                            ),
                                          ),
                                          TextSpan(
                                            text: "\n${note.note ?? ''}",
                                            style: const TextStyle(
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              }).toList(),
          ],
        );
      },
    );
  }

  String _formatDate(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty || timestamp == 'N/A') {
      return 'N/A';
    }

    try {
      final date = DateTime.tryParse(timestamp);
      if (date == null) return 'N/A';
      return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildDataTable(Home_system_report data) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeaders(),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromRGBO(152, 162, 179, .5)),
              ),
              child: Column(
                children: data.units?.asMap().entries.map((entry) {
                      int rowIndex = entry.key;
                      var unit = entry.value;
                      bool isRowExpanded = expandedRowIndex == rowIndex;

                      return Container(
                        decoration: BoxDecoration(
                          color: rowIndex % 2 != 0
                              ? Colors.white
                              : blueColor.withOpacity(0.09),
                          border: Border.all(
                              color: const Color.fromRGBO(152, 162, 179, .5)),
                        ),
                        child: Column(
                          children: [
                            // Main row showing unit info
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Row(
                                children: [
                                  // Expand/Collapse icon
                                  InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (expandedRowIndex == rowIndex) {
                                          expandedRowIndex = null;
                                        } else {
                                          expandedRowIndex = rowIndex;
                                        }
                                      });
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(left: 5),
                                      padding: !isRowExpanded
                                          ? const EdgeInsets.only(bottom: 10)
                                          : const EdgeInsets.only(top: 10),
                                      child: FaIcon(
                                        isRowExpanded
                                            ? FontAwesomeIcons.sortUp
                                            : FontAwesomeIcons.sortDown,
                                        size: 20,
                                        color: blueColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Unit info
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        'Unit: ${unit.unitNumber} - ${unit.unitAddress}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: blueColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Expanded section showing appliances
                            if (isRowExpanded)
                              if (unit.appliances == null ||
                                  unit.appliances!.isEmpty)
                                Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border:
                                        Border.all(color: Colors.grey[300]!),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.info_outline,
                                          color: Colors.grey[600], size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'No appliances found in this unit',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                ...unit.appliances!
                                    .asMap()
                                    .entries
                                    .map((applianceEntry) {
                                  int applianceIndex = applianceEntry.key;
                                  var appliance = applianceEntry.value;
                                  bool isApplianceExpanded =
                                      expandedTenantIndex[rowIndex] ==
                                          applianceIndex;

                                  return Container(
                                    margin: const EdgeInsets.only(left: 2),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade200),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        // Appliance header row
                                        ListTile(
                                          title: Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (expandedTenantIndex[
                                                            rowIndex] ==
                                                        applianceIndex) {
                                                      expandedTenantIndex[
                                                          rowIndex] = null;
                                                    } else {
                                                      expandedTenantIndex[
                                                              rowIndex] =
                                                          applianceIndex;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding: !isApplianceExpanded
                                                      ? const EdgeInsets.only(
                                                          bottom: 10)
                                                      : const EdgeInsets.only(
                                                          top: 10),
                                                  child: FaIcon(
                                                    isApplianceExpanded
                                                        ? FontAwesomeIcons
                                                            .sortUp
                                                        : FontAwesomeIcons
                                                            .sortDown,
                                                    size: 16,
                                                    color: blueColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  appliance.applianceName ??
                                                      '-',
                                                  style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: appliance.status ==
                                                            'Working'
                                                        ? Colors.green
                                                            .withOpacity(0.1)
                                                        : Colors.red
                                                            .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: Text(
                                                    appliance.status ?? '-',
                                                    style: TextStyle(
                                                      color: appliance.status ==
                                                              'Working'
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Expanded appliance details
                                        if (isApplianceExpanded)
                                          Container(
                                            padding: const EdgeInsets.all(20),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: Colors.grey[200]!),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: "Type : ",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    blueColor,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  "\n${appliance.type ?? '-'}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: "Brand : ",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    blueColor,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  "\n${appliance.brand ?? '-'}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: "Model : ",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      blueColor),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  "\n${appliance.model ?? '-'}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: "Serial : ",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    blueColor,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  "\n${appliance.serialNumber ?? '-'}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  "Installed : ",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    blueColor,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  "\n${appliance.installedDate ?? '-'}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  "Warranty : ",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    blueColor,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  "\n${appliance.warrantyExpiry ?? '-'}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  "Last Maintenance : ",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    blueColor,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  "\n${appliance.lastMaintenanceDate ?? '-'}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  "Category : ",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    blueColor,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  "\n${appliance.category ?? '-'}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: RichText(
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text:
                                                                  "Description : ",
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color:
                                                                    blueColor,
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text:
                                                                  "\n${appliance.applianceDescription ?? '-'}",
                                                              style:
                                                                  const TextStyle(
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                // if (appliance.maintenanceNotes
                                                //         ?.isNotEmpty ==
                                                //     true) ...[
                                                //   SizedBox(height: 8),
                                                //   Text(
                                                //       "Notes: ${appliance.maintenanceNotes}"),
                                                // ],
                                                // if (appliance
                                                //         .filters?.isNotEmpty ==
                                                //     true) ...[
                                                //   SizedBox(height: 8),
                                                //   Text("Filters:",
                                                //       style: TextStyle(
                                                //           fontWeight:
                                                //               FontWeight.bold)),
                                                //   ...appliance.filters!
                                                //       .map((filter) => Padding(
                                                //             padding:
                                                //                 const EdgeInsets
                                                //                     .only(
                                                //                     left: 16.0,
                                                //                     top: 4),
                                                //             child: Text(
                                                //                 "${filter.filterName} (${filter.filterSize})"),
                                                //           )),
                                                // ],
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ],
                        ),
                      );
                    }).toList() ??
                    [],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      child: Row(
        children: [
          // Property Dropdown - takes most of the space
          Expanded(
            //  flex: 4,
            child: FormField<String>(
              validator: (value) {
                if (_selectedPropertyId == null) {
                  return 'Please select an option';
                }
                return null;
              },
              builder: (FormFieldState<String> state) {
                return DropdownButtonHideUnderline(
                  child: DropdownButtonFormField2<String>(
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    isExpanded: true,
                    hint: const Text(
                      'Select Property',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFb0b6c3),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    items: properties.keys.map((rentalId) {
                      return DropdownMenuItem<String>(
                        value: rentalId,
                        child: Text(
                          properties[rentalId]!,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    value: _selectedPropertyId,
                    onChanged: (value) {
                      setState(() {
                        _selectedPropertyId = value;
                        _selectedProperty = properties[value];
                      });
                      state.didChange(value);
                    },
                    buttonStyleData: ButtonStyleData(
                      height: 45,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                      elevation: 2,
                    ),
                    iconStyleData: const IconStyleData(
                      icon: Icon(Icons.arrow_drop_down),
                      iconSize: 24,
                      iconEnabledColor: Color(0xFFb0b6c3),
                      iconDisabledColor: Colors.grey,
                    ),
                    dropdownStyleData: DropdownStyleData(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: Colors.white,
                      ),
                      scrollbarTheme: ScrollbarThemeData(
                        radius: const Radius.circular(6),
                        thickness: MaterialStateProperty.all(6),
                        thumbVisibility: MaterialStateProperty.all(true),
                      ),
                    ),
                    menuItemStyleData: const MenuItemStyleData(
                      height: 40,
                      padding: EdgeInsets.symmetric(horizontal: 14),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          // Run and Export buttons container
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Run Button
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    if (_selectedPropertyId != null) {
                      setState(() {
                        isLoading = true;
                        _futureRentersInsurance =
                            fetchRentersInsuranceData(id: _selectedPropertyId!);
                      });
                    } else {
                      Fluttertoast.showToast(
                        msg: "Please select a property first",
                        toastLength: Toast.LENGTH_SHORT,
                      );
                    }
                  },
                  icon: const FaIcon(FontAwesomeIcons.circlePlay, size: 20),
                ),
              ),
              const SizedBox(width: 10),
              // Export Button
              Container(
                height: 45,
                width: 75,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(0),
                  color: Colors.white,
                ),
                child: PopupMenuButton<String>(
                  offset: const Offset(5, 50),
                  onSelected: handleDownload,
                  icon: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.download), // Download icon
                      SizedBox(width: 5),
                      Icon(Icons.arrow_drop_down), // Dropdown arrow icon
                    ],
                  ),
                  tooltip: "Download",
                  itemBuilder: (BuildContext context) {
                    return downloadOptions.map((String option) {
                      return PopupMenuItem<String>(
                        value: option,
                        onTap: () async {
                          if (_futureRentersInsurance == null) {
                            Fluttertoast.showToast(
                              msg: "Please run the report first",
                              toastLength: Toast.LENGTH_SHORT,
                            );
                            return;
                          }
                          final data = await _futureRentersInsurance;
                          if (option == "PDF") {
                            generaterentersInsurancePdf(data!);
                          } else if (option == "Excel") {
                            generateRentersInsuranceExcel(data!);
                          } else if (option == "CSV") {
                            generateRentersInsuranceCSV(data!);
                          }
                        },
                        child: Text("Download as $option"),
                      );
                    }).toList();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
