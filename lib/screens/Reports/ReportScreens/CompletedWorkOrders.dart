import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/Model/CompletedWorkOrdersModel.dart';
import 'package:three_zero_two_property/Model/profile.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/getAdminAddress.dart';
import 'package:three_zero_two_property/repository/CompletedWorkData.dart';
import 'package:three_zero_two_property/repository/GetAdminAddressPdf.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';

import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as syncXlsx;
import 'package:fluttertoast/fluttertoast.dart';

import 'dart:io';
import '../../../widgets/custom_drawer.dart';
class CompletedWorkOrders extends StatefulWidget {
  @override
  State<CompletedWorkOrders> createState() => _CompletedWorkOrdersState();
}

class _CompletedWorkOrdersState extends State<CompletedWorkOrders> {
  final _formKey = GlobalKey<FormState>();
  Future<List<CompletedWorkData>>? _futureReport;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCompletedWorkOrders();
  }

  void _fetchCompletedWorkOrders() {
    setState(() {
      _futureReport = CompletedWorkOrderService().fetchCompletedWorkOrders();
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

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  List<CompletedWorkData> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String searchvalue = "";
  String? selectedValue;

  List<CompletedWorkData> get _pagedData {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    return _tableData.sublist(startIndex,
        endIndex > _tableData.length ? _tableData.length : endIndex);
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
                        ? Text("Date", style: TextStyle(color: Colors.white))
                        : Text("Date", style: TextStyle(color: Colors.white)),
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
                    Text("Address", style: TextStyle(color: Colors.white)),
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
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting3) {
                      sorting1 = false;
                      sorting2 = false;
                      sorting3 = sorting3;
                      ascending3 = sorting3 ? !ascending3 : true;
                      ascending2 = false;
                      ascending1 = false;
                    } else {
                      sorting1 = false;
                      sorting2 = false;
                      sorting3 = !sorting3;
                      ascending3 = sorting3 ? !ascending3 : true;
                      ascending2 = false;
                      ascending1 = false;
                    }

                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    Text("Work", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    ascending3
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

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(CompletedWorkData d)? getField) {
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

  void _sort<T>(Comparable<T> Function(CompletedWorkData d) getField,
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

  void sortData(List<CompletedWorkData> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.workSubject!.compareTo(b.workSubject!)
          : b.workSubject!.compareTo(a.workSubject!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.priority!.compareTo(b.priority!)
          : b.priority!.compareTo(a.priority!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.status!.compareTo(b.status!)
          : b.status!.compareTo(a.status!));
    }
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

  Future<void> generateWorkOrderPdf(
      List<CompletedWorkData> workOrderData) async {
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
        margin: const pw.EdgeInsets.all(30),
        header: (pw.Context context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Image(image, width: 50, height: 50),
            pw.SizedBox(width: 50),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'Completed Work Orders',
                  style: pw.TextStyle(
                    fontSize: 18,
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
              ],
            ),
          ],
        ),
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
        build: (pw.Context context) => [
          pw.Table.fromTextArray(
            headers: [
              'Date',
              'Address',
              'Work',
              'Performed',
            ],
            data: workOrderData.map((workOrder) {
              return [
                formatDate(workOrder.date ?? ''),
                workOrder.rentalAddress ?? '',
                workOrder.workSubject ?? '',
                workOrder.workPerformed ?? '',
              ];
            }).toList(),
            border: pw.TableBorder.all(
              color: PdfColor.fromInt(0xFFBDBDBD),
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
              0: pw.FlexColumnWidth(1.2), // Date
              1: pw.FlexColumnWidth(1.5), // Address
              2: pw.FlexColumnWidth(1.5), // Work
              3: pw.FlexColumnWidth(1.5), // Performed
            },
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> generateWorkOrderExcel(
      List<CompletedWorkData> workOrderData) async {
    final syncXlsx.Workbook workbook = syncXlsx.Workbook();
    final syncXlsx.Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1:D1').columnWidth = 20;

    final List<String> headers = [
      'Date',
      'Address',
      'Work',
      'Performed',
    ];

    final syncXlsx.Style headerCellStyle =
        workbook.styles.add('headerCellStyle');
    headerCellStyle.bold = true;
    headerCellStyle.backColor = '#D3D3D3';
    headerCellStyle.hAlign = syncXlsx.HAlignType.center;

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(1, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle = headerCellStyle;
    }

    for (int i = 0; i < workOrderData.length; i++) {
      final workOrder = workOrderData[i];

      // Safe date parsing with default/fallback value
      String formattedDate;
      try {
        formattedDate = workOrder.date != null
            ? DateFormat('yyyy-MM-dd')
                .format(DateFormat('yyyy-MM-dd').parse(workOrder.date!))
            : 'Invalid Date';
      } catch (e) {
        formattedDate = 'Invalid Date';
      }

      sheet.getRangeByIndex(2 + i, 1).setText(formattedDate);
      sheet.getRangeByIndex(2 + i, 2).setText(workOrder.rentalAddress ?? '');
      sheet.getRangeByIndex(2 + i, 3).setText(workOrder.workSubject ?? '');
      sheet.getRangeByIndex(2 + i, 4).setText(workOrder.workPerformed ?? '');
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'CompletedWorkOrderReport_$formattedDate.xlsx';

    final directory = Directory('/storage/emulated/0/Download');
    final path = '${directory.path}/$fileName';

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    Fluttertoast.showToast(
      msg: 'Excel file saved to $path',
    );
  }

  Future<void> generateWorkOrderCsv(
      List<CompletedWorkData> workOrderData) async {
    List<List<dynamic>> rows = [
      ['Date', 'Address', 'Work', 'Performed']
    ];

    for (var workOrder in workOrderData) {
      rows.add([
        workOrder.date ?? '',
        workOrder.rentalAddress ?? '',
        workOrder.workSubject ?? '',
        workOrder.workPerformed ?? '',
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'CompletedWorkOrderReport_$formattedDate.csv';

    final directory = Directory('/storage/emulated/0/Download');
    final path = '${directory.path}/$fileName';

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    final File file = File(path);
    await file.writeAsString(csv);

    Fluttertoast.showToast(
      msg: 'CSV file saved to $path',
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      drawer:CustomDrawer(currentpage: "Reports",dropdown: false,),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            titleBar(
              title: 'Completed Work Orders',
              width: MediaQuery.of(context).size.width * .91,
            ),
            if (MediaQuery.of(context).size.width < 500)
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                ),
                child: FutureBuilder<List<CompletedWorkData>>(
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
                          .where((workOrder) =>
                              workOrder.workSubject!
                                  .toLowerCase()
                                  .contains(searchvalue.toLowerCase()) ||
                              workOrder.rentalAddress!
                                  .toLowerCase()
                                  .contains(searchvalue.toLowerCase()))
                          .toList();
                    } else {
                      data = snapshot.data!
                          .where((workOrder) =>
                              workOrder.workSubject == selectedValue)
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Material(
                                    elevation: 3,
                                    borderRadius: BorderRadius.circular(2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 0),
                                      // height: 40,
                                      height:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 48
                                              : 50,
                                      width: MediaQuery.of(context).size.width <
                                              500
                                          ? MediaQuery.of(context).size.width *
                                              .50
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
                                          print('pdf');
                                          generateWorkOrderPdf(data);
                                          // Export as PDF
                                        } else if (value == 'XLSX') {
                                          print('XLSX');
                                          generateWorkOrderExcel(data);
                                          // Export as XLSX
                                        } else if (value == 'CSV') {
                                          print('CSV');
                                          generateWorkOrderCsv(data);
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
                          SizedBox(height: 10),
                          _buildHeaders(),
                          SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: Color.fromRGBO(152, 162, 179, .5))),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: blueColor)),
                            child: Column(
                              children:
                                  currentPageData.asMap().entries.map((entry) {
                                int index = entry.key;
                                bool isExpanded = expandedIndex == index;
                                CompletedWorkData workOrder = entry.value;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: index %2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                                    border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
                                  ),
                                  // decoration: BoxDecoration(
                                  //   border: Border.all(color: blueColor),
                                  // ),
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
                                                  '   ${workOrder.date!.isEmpty ? '-- - - -- ----' : workOrder.date} ',
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
                                                  '${workOrder.rentalAddress ?? '-'}',
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
                                                  '${workOrder.workSubject}',
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
                                                                  text:
                                                                      'Description ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${workOrder.workPerformed}',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: grey), // Light and grey
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
                                                                  text: 'Note',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      color:
                                                                          blueColor), // Bold and black
                                                                ),
                                                                TextSpan(
                                                                  text:
                                                                      '${workOrder.vendorNotes}',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w700,
                                                                      color: grey), // Light and grey
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 5,
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
            if (MediaQuery.of(context).size.width > 500)
              const SizedBox(height: 16),
            if (MediaQuery.of(context).size.width > 500)
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Expanded(
                    flex: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 21.0, right: 21.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(2),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              // height: 40,
                              height: MediaQuery.of(context).size.width < 500
                                  ? 40
                                  : 50,
                              width: MediaQuery.of(context).size.width < 500
                                  ? MediaQuery.of(context).size.width * .45
                                  : MediaQuery.of(context).size.width * .4,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                border:
                                    Border.all(color: const Color(0xFF8A95A8)),
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
                                  hintStyle:
                                      TextStyle(color: Color(0xFF8A95A8)),
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
                                  print('pdf');
                                  // Export as PDF
                                } else if (value == 'XLSX') {
                                  print('XLSX');
                                  // Export as XLSX
                                } else if (value == 'CSV') {
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
              ),
            if (MediaQuery.of(context).size.width > 500)
              const SizedBox(height: 16),
            if (MediaQuery.of(context).size.width > 500)
              FutureBuilder<List<CompletedWorkData>>(
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
                        .where((workOrder) =>
                            workOrder.workSubject!
                                .toLowerCase()
                                .contains(searchvalue.toLowerCase()) ||
                            workOrder.rentalAddress!
                                .toLowerCase()
                                .contains(searchvalue.toLowerCase()))
                        .toList();
                  } else {
                    data = snapshot.data!
                        .where((workOrder) =>
                            workOrder.workSubject == selectedValue)
                        .toList();
                  }

                  // Apply pagination
                  final int itemsPerPage = 10;
                  final int totalPages = (data.length / itemsPerPage).ceil();
                  final int currentPage =
                      1; // Update this with your pagination logic
                  final List<CompletedWorkData> pagedData = data
                      .skip((currentPage - 1) * itemsPerPage)
                      .take(itemsPerPage)
                      .toList();

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            Table(
                              defaultColumnWidth: IntrinsicColumnWidth(),
                              columnWidths: {
                                0: FlexColumnWidth(),
                                1: FlexColumnWidth(),
                                2: FlexColumnWidth(),
                                3: FlexColumnWidth(),
                                4: FlexColumnWidth(),
                              },
                              children: [
                                TableRow(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: blueColor),
                                  ),
                                  children: [
                                    _buildHeader('Date', 0,
                                        (workOrder) => workOrder.date!),
                                    _buildHeader(
                                        'Address',
                                        1,
                                        (workOrder) =>
                                            workOrder.rentalAddress!),
                                    _buildHeader('Work', 2,
                                        (workOrder) => workOrder.workSubject!),
                                    _buildHeader(
                                        'Description',
                                        3,
                                        (workOrder) =>
                                            workOrder.workPerformed!),
                                    _buildHeader('Note', 5,
                                        (workOrder) => workOrder.vendorNotes!),
                                  ],
                                ),
                                TableRow(
                                  decoration: BoxDecoration(
                                    border: Border.symmetric(
                                        horizontal: BorderSide.none),
                                  ),
                                  children: List.generate(
                                      5,
                                      (index) => TableCell(
                                          child: Container(height: 20))),
                                ),
                                for (var i = 0; i < pagedData.length; i++)
                                  TableRow(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1)),
                                        right: BorderSide(
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1)),
                                        top: BorderSide(
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1)),
                                        bottom: i == pagedData.length - 1
                                            ? BorderSide(
                                                color: Color.fromRGBO(
                                                    21, 43, 81, 1))
                                            : BorderSide.none,
                                      ),
                                    ),
                                    children: [
                                      _buildDataCell(pagedData[i].date!.isEmpty
                                          ? 'N/A'
                                          : pagedData[i].date!),
                                      _buildDataCell(
                                          pagedData[i].rentalAddress!.isEmpty
                                              ? 'N/A'
                                              : pagedData[i].rentalAddress!),
                                      _buildDataCell(
                                          pagedData[i].workSubject!.isEmpty
                                              ? 'N/A'
                                              : pagedData[i].workPerformed!),
                                      _buildDataCell(
                                          pagedData[i].workPerformed!.isEmpty
                                              ? 'N/A'
                                              : pagedData[i].workPerformed!),
                                      _buildDataCell(
                                          (pagedData[i].vendorNotes == null ||
                                                  pagedData[i]
                                                      .vendorNotes!
                                                      .isEmpty)
                                              ? 'N/A'
                                              : pagedData[i].vendorNotes!),
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
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
