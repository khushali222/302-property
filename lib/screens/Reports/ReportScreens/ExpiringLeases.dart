import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';


import 'package:syncfusion_flutter_xlsio/xlsio.dart' as syncXlsx;
import 'package:three_zero_two_property/Model/ReportExpiringLease.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/ExpiringLeaseTable.dart';
import 'package:three_zero_two_property/widgets/CustomDateField.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';

class ExpiringLeases extends StatefulWidget {
  @override
  _ExpiringLeasesState createState() => _ExpiringLeasesState();
}

class _ExpiringLeasesState extends State<ExpiringLeases> {
  Future<List<ReportExpiringLeaseData>>? _futureReport;

  int totalrecords = 0;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [
    10,
    25,
    50,
    100,
  ];

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();

  void _fetchData() {
    if (_fromDateController.text.isNotEmpty &&
        _toDateController.text.isNotEmpty) {
      _futureReport = ExpiringLeaseTableService().fetchExpiringLeases(
        fromDate: _fromDateController.text,
        toDate: _toDateController.text,
      );
    } else {
      _futureReport = ExpiringLeaseTableService().fetchExpiringLeases();
    }
    setState(() {});
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final formatter = DateFormat('dd/MM/yy');
      return formatter.format(date);
    } catch (e) {
      return dateStr; // If the date is not valid, return the original string
    }
  }

  Future<void> generatePdf(List<ReportExpiringLeaseData> leaseData) async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(
      (await rootBundle.load('assets/images/applogo.png')).buffer.asUint8List(),
    );
    final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.all(30), // Adjust margin as needed
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(image, width: 50, height: 50),
                  pw.SizedBox(width: 50),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Expiring Lease',
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text('As of $currentDate'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('302 Properties, LLC'),
                      pw.Text('250 Corporate Blvd., Suite L'),
                      pw.Text('Newark, DE 19702'),
                      pw.Text('(302) 525-4302'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Table.fromTextArray(
                headers: [
                  'Property',
                  'Unit',
                  'Tenant',
                  'Rent',
                  'Non-rent',
                  'Lease Start',
                  'Lease End',
                  'Status',
                ],
                data: leaseData.map((lease) {
                  return [
                    lease.rentalAddress ?? '',
                    lease.rentalUnit ?? '',
                    lease.tenantNames ?? '',
                    lease.amount?.toString() ?? '',
                    lease.recurring?.toString() ?? '',
                    formatDate(lease.startDate ?? ''),
                    formatDate(lease.endDate ?? ''),
                    lease.status ?? '',
                  ];
                }).toList(),
                border: pw.TableBorder.all(
                  color: PdfColor.fromInt(0xFFBDBDBD), // Gray[400] color
                  width: 1,
                ),
                cellAlignment: pw.Alignment.centerLeft,
                headerDecoration: pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                cellStyle: pw.TextStyle(
                  fontSize: 10,
                ),
                cellHeight: 30,
                columnWidths: {
                  0: pw.FlexColumnWidth(1.5), // Property
                  1: pw.FlexColumnWidth(0.7), // Unit
                  2: pw.FixedColumnWidth(90), // Tenant (fixed width)
                  3: pw.FlexColumnWidth(1), // Rent
                  4: pw.FlexColumnWidth(1.1), // Non-rent
                  5: pw.FlexColumnWidth(1.2), // Lease Start
                  6: pw.FlexColumnWidth(1.2), // Lease End
                  7: pw.FlexColumnWidth(1), // Status
                },
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> generateExcel(List<ReportExpiringLeaseData> leaseData) async {
    // Create a new Excel document.
    final syncXlsx.Workbook workbook = syncXlsx.Workbook();
    final syncXlsx.Worksheet sheet = workbook.worksheets[0];

    // Adjusting column widths
    sheet.getRangeByName('A1:H1').columnWidth = 20;

    // Adding table headers
    final List<String> headers = [
      'Property',
      'Unit',
      'Tenant',
      'Rent',
      'Non-rent',
      'Lease Start',
      'Lease End',
      'Status',
    ];
    final syncXlsx.Style headerCellStyle =
        workbook.styles.add('headerCellStyle');
    headerCellStyle.bold = true;
    headerCellStyle.backColor = '#D3D3D3'; // Gray color for header
    headerCellStyle.hAlign =
        syncXlsx.HAlignType.center; // Center alignment for header

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(6, i + 1); // Start at row 6
      cell.setText(headers[i]);
      cell.cellStyle = headerCellStyle;
    }

    // Adding lease data starting from row 7
    for (int i = 0; i < leaseData.length; i++) {
      final lease = leaseData[i];
      sheet.getRangeByIndex(7 + i, 1).setText(lease.rentalAddress ?? '');
      sheet.getRangeByIndex(7 + i, 2).setText(lease.rentalUnit ?? '');
      sheet.getRangeByIndex(7 + i, 3).setText(lease.tenantNames ?? '');
      sheet
          .getRangeByIndex(7 + i, 4)
          .setNumber((lease.amount ?? 0.0).toDouble());
      sheet
          .getRangeByIndex(7 + i, 5)
          .setNumber((lease.recurring ?? 0).toDouble());

      // Parse dates
      DateTime? startDate = lease.startDate != null
          ? DateFormat('yyyy-MM-dd').parse(lease.startDate!)
          : null;
      DateTime? endDate = lease.endDate != null
          ? DateFormat('yyyy-MM-dd').parse(lease.endDate!)
          : null;

      sheet.getRangeByIndex(7 + i, 6).setDateTime(startDate ?? DateTime.now());
      sheet.getRangeByIndex(7 + i, 7).setDateTime(endDate ?? DateTime.now());
      sheet.getRangeByIndex(7 + i, 8).setText(lease.status ?? '');
    }

    // Save the document.
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // Generate a unique file name
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'ExpiringLeaseReport_$formattedDate.xlsx';

    // Get the directory to save the file.
    final directory = Directory('/storage/emulated/0/Download');
    final path = '${directory.path}/$fileName';

    // Ensure the directory exists
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Save the file.
    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    // Show a message with the file path.
    Fluttertoast.showToast(
      msg: 'Excel file saved to $path',
    );
  }

//Csv Generate method

  Future<void> requestPermissions() async {
    await Permission.storage.request();
  }

  Future<void> generateCsv(List<ReportExpiringLeaseData> leaseData) async {
    // Request storage permissions
    await requestPermissions();

    // Prepare CSV data
    List<List<dynamic>> rows = [
      [
        'Property',
        'Unit',
        'Tenant',
        'Rent',
        'Non-rent',
        'Lease Start',
        'Lease End',
        'Status'
      ]
    ];

    for (var lease in leaseData) {
      rows.add([
        lease.rentalAddress ?? '',
        lease.rentalUnit ?? '',
        lease.tenantNames ?? '',
        lease.amount ?? 0.0,
        lease.recurring ?? 0,
        lease.startDate ?? '',
        lease.endDate ?? '',
        lease.status ?? '',
      ]);
    }

    // Convert rows to CSV string
    String csv = const ListToCsvConverter().convert(rows);

    // Generate a unique file name
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'ExpiringLeaseReport_$formattedDate.csv';

    // Get the directory to save the file.
    final directory = Directory('/storage/emulated/0/Download');
    final path = '${directory.path}/$fileName';

    // Ensure the directory exists
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Save the file
    final File file = File(path);
    await file.writeAsString(csv, flush: true);

    // Show a message with the file path
    Fluttertoast.showToast(
      msg: 'CSV file saved to $path',
    );
  }

  void sortData(List<ReportExpiringLeaseData> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.rentalAddress!.compareTo(b.rentalAddress!)
          : b.rentalAddress!.compareTo(a.rentalAddress!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.tenantNames!.compareTo(b.tenantNames!)
          : b.tenantNames!.compareTo(a.tenantNames!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.status!.compareTo(b.status!)
          : b.status!.compareTo(a.status!));
    }
  }

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
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(13),
          topRight: Radius.circular(13),
        ),
      ),
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
              child: Icon(
                Icons.expand_less,
                color: Colors.transparent,
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting1 == true) {
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

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    width < 400
                        ? Text("Property",
                            style: TextStyle(color: Colors.white))
                        : Text("Property",
                            style: TextStyle(color: Colors.white)),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 3),
                    ascending1
                        ? Padding(
                            padding: const EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortDown,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                  ],
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
                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    Text("Tenant", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    ascending2
                        ? Padding(
                            padding: const EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: Colors.white,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortDown,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String searchvalue = "";
  String? selectedValue;

  List<ReportExpiringLeaseData> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<ReportExpiringLeaseData> get _pagedData {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    return _tableData.sublist(startIndex,
        endIndex > _tableData.length ? _tableData.length : endIndex);
  }

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(ReportExpiringLeaseData d)? getField) {
    return TableCell(
      child: InkWell(
        onTap: getField != null
            ? () {
                _sort(getField, columnIndex, !_sortAscending);
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Text(text,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18)),
              if (_sortColumnIndex == columnIndex)
                Icon(_sortAscending
                    ? Icons.arrow_drop_down_outlined
                    : Icons.arrow_drop_up_outlined),
            ],
          ),
        ),
      ),
    );
  }

  void _sort<T>(Comparable<T> Function(ReportExpiringLeaseData d) getField,
      int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _tableData.sort((a, b) {
        final aValue = getField(a);
        final bValue = getField(b);
        final result = aValue.compareTo(bValue as T);
        return _sortAscending ? result : -result;
      });
    });
  }

  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16, bottom: 20.0),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildPaginationControls() {
    int numorpages = 1;
    numorpages = (totalrecords / _rowsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Text('Rows per page: '),
        // SizedBox(width: 10),
        Material(
          elevation: 2,
          color: Colors.white,
          child: Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _rowsPerPage,
                items: [10, 25, 50, 100].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    _changeRowsPerPage(newValue);
                  }
                },
                icon: const Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                ),
                style: const TextStyle(color: Colors.black, fontSize: 17),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        IconButton(
          icon: FaIcon(
            FontAwesomeIcons.circleChevronLeft,
            size: 30,
            color: _currentPage == 0
                ? Colors.grey
                : const Color.fromRGBO(21, 43, 83, 1),
          ),
          onPressed: _currentPage == 0
              ? null
              : () {
                  setState(() {
                    _currentPage--;
                  });
                },
        ),
        Text(
          'Page ${_currentPage + 1} of $numorpages',
          style: const TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            size: 30,
            FontAwesomeIcons.circleChevronRight,
            color: (_currentPage + 1) * _rowsPerPage >= _tableData.length
                ? Colors.grey
                : const Color.fromRGBO(
                    21, 43, 83, 1), // Change color based on availability
          ),
          onPressed: (_currentPage + 1) * _rowsPerPage >= _tableData.length
              ? null
              : () {
                  setState(() {
                    _currentPage++;
                  });
                },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              const SizedBox(height: 40),
              buildListTile(
                context,
                const Icon(
                  CupertinoIcons.circle_grid_3x3,
                  color: Colors.white,
                ),
                "Dashboard",
                true,
              ),
              buildListTile(
                context,
                const Icon(
                  CupertinoIcons.home,
                  color: Colors.black,
                ),
                "Add Property Type",
                false,
              ),
              buildListTile(
                context,
                const Icon(
                  CupertinoIcons.person_add,
                  color: Colors.black,
                ),
                "Add Staff Member",
                false,
              ),
              buildDropdownListTile(
                context,
                const FaIcon(
                  FontAwesomeIcons.key,
                  size: 20,
                  color: Colors.black,
                ),
                "Rental",
                ["Properties", "RentalOwner", "Tenants"],
              ),
              buildDropdownListTile(
                context,
                const FaIcon(
                  FontAwesomeIcons.thumbsUp,
                  size: 20,
                  color: Colors.black,
                ),
                "Leasing",
                ["Rent Roll", "Applicants"],
              ),
              buildDropdownListTile(
                context,
                Image.asset("assets/icons/maintence.png",
                    height: 20, width: 20),
                "Maintenance",
                ["Vendor", "Work Order"],
              ),
              buildListTile(
                context,
                const FaIcon(
                  FontAwesomeIcons.letterboxd,
                  color: Colors.white,
                ),
                "Reports",
                true,
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          titleBar(
            title: 'Expiring Lease',
            width: MediaQuery.of(context).size.width * .91,
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromRGBO(21, 43, 83, 1),
                ),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: screenWidth > 500
                      ? Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('From',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: 5),
                                  CustomDateField(
                                      hintText: 'yyyy-mm-dd',
                                      controller: _fromDateController),
                                ],
                              ),
                            ),
                            SizedBox(width: 40),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('To',
                                      style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600)),
                                  SizedBox(height: 5),
                                  CustomDateField(
                                      hintText: 'yyyy-mm-dd',
                                      controller: _toDateController),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            Expanded(
                              child: Container(
                                // color: Colors.amber,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 18),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: blueColor),
                                        onPressed: _fetchData,
                                        child: Text('Show Leases'),
                                      ),
                                      SizedBox(width: 8),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: blueColor),
                                        onPressed: () {
                                          _fromDateController.clear();
                                          _toDateController.clear();
                                        },
                                        child: Text('Clear'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('From',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600)),
                                        SizedBox(height: 5),
                                        CustomDateField(
                                            hintText: 'dd-mm-yyyy',
                                            controller: _fromDateController),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 16,
                                ),
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('To',
                                            style: TextStyle(
                                                color: Colors.grey[600],
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600)),
                                        SizedBox(height: 5),
                                        CustomDateField(
                                            hintText: 'dd-mm-yyyy',
                                            controller: _toDateController),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: blueColor),
                                  onPressed: _fetchData,
                                  child: Text('Show Leases'),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: blueColor),
                                  onPressed: () {
                                    _fromDateController.clear();
                                    _toDateController.clear();
                                  },
                                  child: Text('Clear'),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
          // Expanded(
          //     flex: 0,
          //     child: Padding(
          //       padding: const EdgeInsets.only(left: 16.0, right: 16.0),
          //       child: Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Material(
          //             elevation: 3,
          //             borderRadius: BorderRadius.circular(2),
          //             child: Container(
          //               padding: const EdgeInsets.symmetric(horizontal: 10),
          //               // height: 40,
          //               height:
          //                   MediaQuery.of(context).size.width < 500 ? 40 : 50,
          //               width: MediaQuery.of(context).size.width < 500
          //                   ? MediaQuery.of(context).size.width * .45
          //                   : MediaQuery.of(context).size.width * .4,
          //               decoration: BoxDecoration(
          //                 color: Colors.white,
          //                 borderRadius: BorderRadius.circular(2),
          //                 border: Border.all(color: const Color(0xFF8A95A8)),
          //               ),
          //               child: TextField(
          //                 onChanged: (value) {
          //                   setState(() {
          //                     searchvalue = value;
          //                   });
          //                 },
          //                 decoration: const InputDecoration(
          //                   border: InputBorder.none,
          //                   hintText: "Search here...",
          //                   hintStyle: TextStyle(color: Color(0xFF8A95A8)),
          //                   // contentPadding: EdgeInsets.all(10),
          //                 ),
          //               ),
          //             ),
          //           ),
          //           ElevatedButton(
          //             style: ElevatedButton.styleFrom(
          //               backgroundColor: blueColor,
          //             ),
          //             onPressed: () {},
          //             child: PopupMenuButton<String>(
          //               onSelected: (value) async {
          //                 // Add your export logic here based on the selected value
          //                 if (value == 'PDF') {
          //                   if (_fromDateController.text.isNotEmpty &&
          //                       _toDateController.text.isNotEmpty) {
          //                     final data = await ExpiringLeaseTableService()
          //                         .fetchExpiringLeases(
          //                       fromDate: _fromDateController.text,
          //                       toDate: _toDateController.text,
          //                     );

          //                     await generatePdf(data);
          //                   } else {
          //                     final data = await ExpiringLeaseTableService()
          //                         .fetchExpiringLeases();

          //                     await generatePdf(data);
          //                   }

          //                   print('pdf');
          //                   // Export as PDF
          //                 } else if (value == 'XLSX') {
          //                   if (_fromDateController.text.isNotEmpty &&
          //                       _toDateController.text.isNotEmpty) {
          //                     final data = await ExpiringLeaseTableService()
          //                         .fetchExpiringLeases(
          //                       fromDate: _fromDateController.text,
          //                       toDate: _toDateController.text,
          //                     );

          //                     await generateExcel(data);
          //                   } else {
          //                     final data = await ExpiringLeaseTableService()
          //                         .fetchExpiringLeases();

          //                     await generateExcel(data);
          //                   }
          //                   print('XLSX');
          //                   // Export as XLSX
          //                 } else if (value == 'CSV') {
          //                   if (_fromDateController.text.isNotEmpty &&
          //                       _toDateController.text.isNotEmpty) {
          //                     final data = await ExpiringLeaseTableService()
          //                         .fetchExpiringLeases(
          //                       fromDate: _fromDateController.text,
          //                       toDate: _toDateController.text,
          //                     );

          //                     await generatePdf(data);
          //                   } else {
          //                     final data = await ExpiringLeaseTableService()
          //                         .fetchExpiringLeases();

          //                     await generatePdf(data);
          //                   }
          //                   print('CSV');
          //                   // Export as CSV
          //                 }
          //               },
          //               itemBuilder: (BuildContext context) =>
          //                   <PopupMenuEntry<String>>[
          //                 const PopupMenuItem<String>(
          //                   value: 'PDF',
          //                   child: Text('PDF'),
          //                 ),
          //                 const PopupMenuItem<String>(
          //                   value: 'XLSX',
          //                   child: Text('XLSX'),
          //                 ),
          //                 const PopupMenuItem<String>(
          //                   value: 'CSV',
          //                   child: Text('CSV'),
          //                 ),
          //               ],
          //               child: Row(
          //                 mainAxisSize: MainAxisSize.min,
          //                 children: [
          //                   Text('Export'),
          //                   Icon(Icons.arrow_drop_down),
          //                 ],
          //               ),
          //             ),
          //           )
          //         ],
          //       ),
          //     )),
          if (MediaQuery.of(context).size.width < 500)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                ),
                child: FutureBuilder<List<ReportExpiringLeaseData>>(
                  future: _futureReport,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ColabShimmerLoadingWidget(),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text('No data available'));
                    }

                    var data = snapshot.data!;

                    // Apply filtering based on selectedValue and searchvalue
                    if (selectedValue == null && searchvalue.isEmpty) {
                      data = snapshot.data!;
                    } else if (selectedValue == "All") {
                      data = snapshot.data!;
                    } else if (searchvalue.isNotEmpty) {
                      data = snapshot.data!
                          .where((lease) =>
                              lease.rentalAddress!
                                  .toLowerCase()
                                  .contains(searchvalue.toLowerCase()) ||
                              lease.tenantNames!
                                  .toLowerCase()
                                  .contains(searchvalue.toLowerCase()))
                          .toList();
                    } else {
                      data = snapshot.data!
                          .where(
                              (lease) => lease.rentalAddress == selectedValue)
                          .toList();
                    }

                    // Sort data if necessary
                    sortData(data);

                    // Pagination logic
                    final totalPages = (data.length / itemsPerPage).ceil();
                    final currentPageData = data
                        .skip(currentPage * itemsPerPage)
                        .take(itemsPerPage)
                        .toList();

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          Expanded(
                            flex: 0,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Material(
                                    elevation: 3,
                                    borderRadius: BorderRadius.circular(2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      // height: 40,
                                      height:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 40
                                              : 50,
                                      width: MediaQuery.of(context).size.width <
                                              500
                                          ? MediaQuery.of(context).size.width *
                                              .45
                                          : MediaQuery.of(context).size.width *
                                              .4,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(2),
                                        border: Border.all(
                                            color: const Color(0xFF8A95A8)),
                                      ),
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            searchvalue = value;
                                          });
                                        },
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Search here...",
                                          hintStyle: TextStyle(
                                              color: Color(0xFF8A95A8)),
                                          // contentPadding: EdgeInsets.all(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: blueColor,
                                    ),
                                    onPressed: () {},
                                    child: PopupMenuButton<String>(
                                      onSelected: (value) async {
                                        // Add your export logic here based on the selected value
                                        if (value == 'PDF') {
                                          if (_fromDateController
                                                  .text.isNotEmpty &&
                                              _toDateController
                                                  .text.isNotEmpty) {
                                            final data =
                                                await ExpiringLeaseTableService()
                                                    .fetchExpiringLeases(
                                              fromDate:
                                                  _fromDateController.text,
                                              toDate: _toDateController.text,
                                            );

                                            await generatePdf(data);
                                          } else {
                                            final data =
                                                await ExpiringLeaseTableService()
                                                    .fetchExpiringLeases();

                                            await generatePdf(data);
                                          }

                                          print('pdf');
                                          // Export as PDF
                                        } else if (value == 'XLSX') {
                                          if (_fromDateController
                                                  .text.isNotEmpty &&
                                              _toDateController
                                                  .text.isNotEmpty) {
                                            final data =
                                                await ExpiringLeaseTableService()
                                                    .fetchExpiringLeases(
                                              fromDate:
                                                  _fromDateController.text,
                                              toDate: _toDateController.text,
                                            );

                                            await generateExcel(data);
                                          } else {
                                            final data =
                                                await ExpiringLeaseTableService()
                                                    .fetchExpiringLeases();

                                            await generateExcel(data);
                                          }
                                          print('XLSX');
                                          // Export as XLSX
                                        } else if (value == 'CSV') {
                                          if (_fromDateController
                                                  .text.isNotEmpty &&
                                              _toDateController
                                                  .text.isNotEmpty) {
                                            final data =
                                                await ExpiringLeaseTableService()
                                                    .fetchExpiringLeases(
                                              fromDate:
                                                  _fromDateController.text,
                                              toDate: _toDateController.text,
                                            );

                                            await generateCsv(data);
                                          } else {
                                            final data =
                                                await ExpiringLeaseTableService()
                                                    .fetchExpiringLeases();

                                            await generateCsv(data);
                                          }
                                          print('CSV');
                                          // Export as CSV
                                        }
                                      },
                                      itemBuilder: (BuildContext context) =>
                                          <PopupMenuEntry<String>>[
                                        const PopupMenuItem<String>(
                                          value: 'PDF',
                                          child: Text('PDF'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'XLSX',
                                          child: Text('XLSX'),
                                        ),
                                        const PopupMenuItem<String>(
                                          value: 'CSV',
                                          child: Text('CSV'),
                                        ),
                                      ],
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Export'),
                                          Icon(Icons.arrow_drop_down),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          _buildHeaders(),
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: blueColor)),
                            child: Column(
                              children:
                                  currentPageData.asMap().entries.map((entry) {
                                int index = entry.key;
                                bool isExpanded = expandedIndex == index;
                                ReportExpiringLeaseData lease = entry.value;

                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: blueColor),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (expandedIndex ==
                                                        index) {
                                                      expandedIndex = null;
                                                    } else {
                                                      expandedIndex = index;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  margin:
                                                      EdgeInsets.only(left: 5),
                                                  padding: !isExpanded
                                                      ? EdgeInsets.only(
                                                          bottom: 10)
                                                      : EdgeInsets.only(
                                                          top: 10),
                                                  child: FaIcon(
                                                    isExpanded
                                                        ? FontAwesomeIcons
                                                            .sortUp
                                                        : FontAwesomeIcons
                                                            .sortDown,
                                                    size: 20,
                                                    color: Color.fromRGBO(
                                                        21, 43, 83, 1),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '   ${lease.rentalAddress}',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .04),
                                              Expanded(
                                                child: Text(
                                                  '${lease.tenantNames}',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ),
                                              // SizedBox(
                                              //     width: MediaQuery.of(context)
                                              //             .size
                                              //             .width *
                                              //         .08),
                                              // Expanded(
                                              //   child: Text(
                                              //     // '${widget.data.createdAt}',
                                              //     '${lease.status}',
                                              //     style: TextStyle(
                                              //       color: blueColor,
                                              //       fontWeight: FontWeight.bold,
                                              //       fontSize: 13,
                                              //     ),
                                              //   ),
                                              // ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .02),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isExpanded)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          margin: EdgeInsets.only(bottom: 20),
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    FaIcon(
                                                      isExpanded
                                                          ? FontAwesomeIcons
                                                              .sortUp
                                                          : FontAwesomeIcons
                                                              .sortDown,
                                                      size: 50,
                                                      color: Colors.transparent,
                                                    ),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: 'Rent ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${lease.amount}',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .grey), // Light and grey
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      'Non-Rent ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${lease.recurring}',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .grey), // Light and grey
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      'Lease Start :  ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      ' ${formatDate(lease.createdAt!)}',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .grey), // Light and grey
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      'Leasr End :  ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${formatDate(lease.endDate!)}',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .grey), // Light and grey
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
                                                          ),
                                                          Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      'STATUS ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${lease.status}',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: Colors
                                                                          .grey), // Light and grey
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Container(
                                                      width: 40,
                                                      child: Column(
                                                        children: [],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  SizedBox(width: 10),
                                  Material(
                                    elevation: 3,
                                    child: Container(
                                      height: 40,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<int>(
                                          value: itemsPerPage,
                                          items: itemsPerPageOptions
                                              .map((int value) {
                                            return DropdownMenuItem<int>(
                                              value: value,
                                              child: Text(value.toString()),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              itemsPerPage = newValue!;
                                              currentPage =
                                                  0; // Reset to first page when items per page change
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: FaIcon(
                                      FontAwesomeIcons.circleChevronLeft,
                                      color: currentPage == 0
                                          ? Colors.grey
                                          : Color.fromRGBO(21, 43, 83, 1),
                                    ),
                                    onPressed: currentPage == 0
                                        ? null
                                        : () {
                                            setState(() {
                                              currentPage--;
                                            });
                                          },
                                  ),
                                  Text(
                                      'Page ${currentPage + 1} of $totalPages'),
                                  IconButton(
                                    icon: FaIcon(
                                      FontAwesomeIcons.circleChevronRight,
                                      color: currentPage < totalPages - 1
                                          ? Color.fromRGBO(21, 43, 83, 1)
                                          : Colors.grey,
                                    ),
                                    onPressed: currentPage < totalPages - 1
                                        ? () {
                                            setState(() {
                                              currentPage++;
                                            });
                                          }
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          if (MediaQuery.of(context).size.width > 500)
            SizedBox(
              height: 8,
            ),
          if (MediaQuery.of(context).size.width > 500)
            Expanded(
                flex: 0,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Material(
                        elevation: 3,
                        borderRadius: BorderRadius.circular(2),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          // height: 40,
                          height:
                              MediaQuery.of(context).size.width < 500 ? 40 : 50,
                          width: MediaQuery.of(context).size.width < 500
                              ? MediaQuery.of(context).size.width * .45
                              : MediaQuery.of(context).size.width * .4,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(2),
                            border: Border.all(color: const Color(0xFF8A95A8)),
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                searchvalue = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: "Search here...",
                              hintStyle: TextStyle(color: Color(0xFF8A95A8)),
                              // contentPadding: EdgeInsets.all(10),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: blueColor,
                        ),
                        onPressed: () {},
                        child: PopupMenuButton<String>(
                          onSelected: (value) async {
                            // Add your export logic here based on the selected value
                            if (value == 'PDF') {
                              if (_fromDateController.text.isNotEmpty &&
                                  _toDateController.text.isNotEmpty) {
                                final data = await ExpiringLeaseTableService()
                                    .fetchExpiringLeases(
                                  fromDate: _fromDateController.text,
                                  toDate: _toDateController.text,
                                );

                                await generatePdf(data);
                              } else {
                                final data = await ExpiringLeaseTableService()
                                    .fetchExpiringLeases();

                                await generatePdf(data);
                              }

                              print('pdf');
                              // Export as PDF
                            } else if (value == 'XLSX') {
                              if (_fromDateController.text.isNotEmpty &&
                                  _toDateController.text.isNotEmpty) {
                                final data = await ExpiringLeaseTableService()
                                    .fetchExpiringLeases(
                                  fromDate: _fromDateController.text,
                                  toDate: _toDateController.text,
                                );

                                await generateExcel(data);
                              } else {
                                final data = await ExpiringLeaseTableService()
                                    .fetchExpiringLeases();

                                await generateExcel(data);
                              }
                              print('XLSX');
                              // Export as XLSX
                            } else if (value == 'CSV') {
                              if (_fromDateController.text.isNotEmpty &&
                                  _toDateController.text.isNotEmpty) {
                                final data = await ExpiringLeaseTableService()
                                    .fetchExpiringLeases(
                                  fromDate: _fromDateController.text,
                                  toDate: _toDateController.text,
                                );

                                await generateCsv(data);
                              } else {
                                final data = await ExpiringLeaseTableService()
                                    .fetchExpiringLeases();

                                await generateCsv(data);
                              }
                              print('CSV');
                              // Export as CSV
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'PDF',
                              child: Text('PDF'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'XLSX',
                              child: Text('XLSX'),
                            ),
                            const PopupMenuItem<String>(
                              value: 'CSV',
                              child: Text('CSV'),
                            ),
                          ],
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('Export'),
                              Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )),
          if (MediaQuery.of(context).size.width > 500)
            SizedBox(
              height: 18,
            ),
          if (MediaQuery.of(context).size.width > 500)
            FutureBuilder<List<ReportExpiringLeaseData>>(
              future: _futureReport,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ShimmerTabletTable();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No data available'));
                }

                var data = snapshot.data!;

                // Apply filtering based on selectedValue and searchvalue
                if (selectedValue == null && searchvalue.isEmpty) {
                  data = snapshot.data!;
                } else if (selectedValue == "All") {
                  data = snapshot.data!;
                } else if (searchvalue.isNotEmpty) {
                  data = snapshot.data!
                      .where((lease) =>
                          lease.rentalAddress!
                              .toLowerCase()
                              .contains(searchvalue.toLowerCase()) ||
                          lease.tenantNames!
                              .toLowerCase()
                              .contains(searchvalue.toLowerCase()))
                      .toList();
                } else {
                  data = snapshot.data!
                      .where((lease) => lease.rentalAddress == selectedValue)
                      .toList();
                }

                // Apply pagination
                final int itemsPerPage = 10;
                final int totalPages = (data.length / itemsPerPage).ceil();
                final int currentPage =
                    1; // Update this with your pagination logic
                final List<ReportExpiringLeaseData> pagedData = data
                    .skip((currentPage - 1) * itemsPerPage)
                    .take(itemsPerPage)
                    .toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    child: Column(
                      children: [
                        Table(
                          defaultColumnWidth: IntrinsicColumnWidth(),
                          columnWidths: {
                            0: FlexColumnWidth(),
                            1: FlexColumnWidth(),
                            2: FlexColumnWidth(),
                            3: FlexColumnWidth(),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(
                                border: Border.all(color: blueColor),
                              ),
                              children: [
                                _buildHeader('Rental Address', 0,
                                    (lease) => lease.rentalAddress!),
                                _buildHeader('Tenant Names', 1,
                                    (lease) => lease.tenantNames!),
                                _buildHeader('Lease Start', 2,
                                    (lease) => lease.createdAt!),
                                _buildHeader(
                                    'Rent', 3, (lease) => lease.createdAt!),
                                _buildHeader(
                                    'Lease End', 5, (lease) => lease.endDate!),
                              ],
                            ),
                            TableRow(
                              decoration: BoxDecoration(
                                border: Border.symmetric(
                                    horizontal: BorderSide.none),
                              ),
                              children: List.generate(
                                  5,
                                  (index) =>
                                      TableCell(child: Container(height: 20))),
                            ),
                            for (var i = 0; i < pagedData.length; i++)
                              TableRow(
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                        color: Color.fromRGBO(21, 43, 81, 1)),
                                    right: BorderSide(
                                        color: Color.fromRGBO(21, 43, 81, 1)),
                                    top: BorderSide(
                                        color: Color.fromRGBO(21, 43, 81, 1)),
                                    bottom: i == pagedData.length - 1
                                        ? BorderSide(
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1))
                                        : BorderSide.none,
                                  ),
                                ),
                                children: [
                                  _buildDataCell(pagedData[i].rentalAddress!),
                                  _buildDataCell(pagedData[i].tenantNames!),
                                  _buildDataCell(
                                      '\$${pagedData[i].amount.toString()}'),
                                  _buildDataCell(pagedData[i].createdAt!),
                                  _buildDataCell(pagedData[i].endDate!),
                                ],
                              ),
                          ],
                        ),
                        SizedBox(height: 25),
                        _buildPaginationControls(),
                        SizedBox(height: 25),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
