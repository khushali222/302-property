import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/ReopenWorkOrderModel.dart';
import 'package:three_zero_two_property/repository/ReopenWorkOrderRepo.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as syncXlsx;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:three_zero_two_property/widgets/custom_drawer.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ReopenWorkorder extends StatefulWidget {
  const ReopenWorkorder({super.key});

  @override
  State<ReopenWorkorder> createState() => _ReopenWorkorderState();
}

class _ReopenWorkorderState extends State<ReopenWorkorder> {
  List<ReopenWorkOrderData> reopenWorkOrders = [];
  bool isLoading = true;
  String? errorMessage;
  int? expandedRowIndex;
  ConnectivityResult? _connectivityResult;
  String? selectedPriority;
  String? selectedCategory;
  String? selectedStatus;
  String? selectedStaffMember;
  List<String> priorityList = ['All', 'High', 'Normal', 'Low'];
  List<String> categoryList = [
    'All',
    'Roof',
    'Electrical',
    'Plumbing',
    'HVAC',
    'General'
  ];
  List<String> statusList = [
    'All',
    'On Hold',
    'In Progress',
    'Completed',
    'Cancelled'
  ];
  List<String> staffMemberList = ['All'];
  String? selectedRentalAddress;
  List<String> rentalAddressList = ['All'];
  String searchvalue = "";
  int currentPage = 1;
  int itemsPerPage = 10;
  int totalPages = 1;
  String? selectedAdminId;
  bool isDataLoading = false;

  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        print(result);
        _connectivityResult = result;
      });
    });

    checkInternet();
    fetchReport();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  void fetchReport() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("adminId");

      if (adminId == null) {
        setState(() {
          errorMessage = "Admin ID not found";
          isLoading = false;
        });
        return;
      }

      selectedAdminId = adminId;
      ReopenWorkOrderRepository repository = ReopenWorkOrderRepository();
      ReopenWorkOrderResponse response =
          await repository.fetchReopenWorkOrders(adminId);

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          reopenWorkOrders = response.data!;
          isLoading = false;

          // Populate filter lists
          staffMemberList = ['All'];
          rentalAddressList = ['All'];

          for (var order in reopenWorkOrders) {
            if (order.staffmemberName != null &&
                !staffMemberList.contains(order.staffmemberName)) {
              staffMemberList.add(order.staffmemberName!);
            }
            if (order.rentalAddress != null &&
                !rentalAddressList.contains(order.rentalAddress)) {
              rentalAddressList.add(order.rentalAddress!);
            }
          }

          totalPages = (reopenWorkOrders.length / itemsPerPage).ceil();
        });
      } else {
        setState(() {
          errorMessage = response.message ?? "Failed to fetch data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  List<ReopenWorkOrderData> get filteredData {
    List<ReopenWorkOrderData> filtered = reopenWorkOrders;

    // Search filter
    if (searchvalue.isNotEmpty) {
      String searchTerm = searchvalue.toLowerCase();
      filtered = filtered
          .where((order) =>
              order.ticketNumber?.toLowerCase().contains(searchTerm) == true ||
              order.workSubject?.toLowerCase().contains(searchTerm) == true ||
              order.rentalAddress?.toLowerCase().contains(searchTerm) == true ||
              order.staffmemberName?.toLowerCase().contains(searchTerm) == true)
          .toList();
    }

    // Priority filter
    if (selectedPriority != null && selectedPriority != 'All') {
      filtered = filtered
          .where((order) => order.priority == selectedPriority)
          .toList();
    }

    // Category filter
    if (selectedCategory != null && selectedCategory != 'All') {
      filtered = filtered
          .where((order) => order.workCategory == selectedCategory)
          .toList();
    }

    // Status filter
    if (selectedStatus != null && selectedStatus != 'All') {
      filtered =
          filtered.where((order) => order.status == selectedStatus).toList();
    }

    // Staff member filter
    if (selectedStaffMember != null && selectedStaffMember != 'All') {
      filtered = filtered
          .where((order) => order.staffmemberName == selectedStaffMember)
          .toList();
    }

    // Rental address filter
    if (selectedRentalAddress != null && selectedRentalAddress != 'All') {
      filtered = filtered
          .where((order) => order.rentalAddress == selectedRentalAddress)
          .toList();
    }

    return filtered;
  }

  List<ReopenWorkOrderData> get currentPageData {
    List<ReopenWorkOrderData> filtered = filteredData;
    int startIndex = (currentPage - 1) * itemsPerPage;
    int endIndex = (startIndex + itemsPerPage).clamp(0, filtered.length);
    return filtered.sublist(startIndex, endIndex);
  }

  Widget _buildHeaders() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text("Date",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[800])),
          ),
          Expanded(
            flex: 3,
            child: Text("Address",
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.grey[800])),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(ReopenWorkOrderData order, int index) {
    bool isExpanded = expandedRowIndex == index;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                if (expandedRowIndex == index) {
                  expandedRowIndex = null;
                } else {
                  expandedRowIndex = index;
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Date with expand icon
                  Row(
                    children: [
                      Text(
                        order.date ?? 'N/A',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                    ],
                  ),
                  // Address
                  // address is larger in length so we need to wrap it
                  Expanded(
                    child: Text(
                      "${order.rentalAddress}" ?? 'N/A',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey[800],
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 12),
                  // Two column layout for main details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                                'Work', order.workSubject ?? 'No work subject'),
                            SizedBox(height: 12),
                            _buildDetailRow('Notes',
                                order.vendorNotes ?? 'No vendor notes'),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow('Description',
                                order.workPerformed ?? 'No work performed yet'),
                          ],
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

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.normal,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget filters({List<ReopenWorkOrderData>? data}) {
    return Column(
      children: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Search Bar
              Expanded(
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: MediaQuery.of(context).size.width < 500 ? 45 : 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF8A95A8)),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchvalue = value;
                          currentPage = 1;
                        });
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search here...",
                        hintStyle: TextStyle(color: Color(0xFF8A95A8)),
                        contentPadding: EdgeInsets.all(11),
                        suffixIcon:
                            Icon(Icons.search, color: Color(0xFF8A95A8)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              // Export Button
              Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: MediaQuery.of(context).size.width < 500 ? 45 : 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF8A95A8)),
                  ),
                  child: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'PDF' && data != null) {
                        _exportToPDF();
                      } else if (value == 'XLSX' && data != null) {
                        _exportToExcel();
                      } else if (value == 'CSV' && data != null) {
                        _shareReport();
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                          value: 'PDF', child: Text('PDF')),
                      const PopupMenuItem<String>(
                          value: 'XLSX', child: Text('XLSX')),
                      const PopupMenuItem<String>(
                          value: 'CSV', child: Text('CSV')),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download,
                              color: Colors.grey[600], size: 20),
                          SizedBox(width: 8),
                          Icon(Icons.keyboard_arrow_down,
                              color: Colors.grey[600], size: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPagination() {
    int totalFilteredItems = filteredData.length;
    int totalPages = (totalFilteredItems / itemsPerPage).ceil();

    if (totalPages <= 1) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
              'Showing ${((currentPage - 1) * itemsPerPage) + 1} to ${(currentPage * itemsPerPage).clamp(0, totalFilteredItems)} of $totalFilteredItems items'),
          Row(
            children: [
              IconButton(
                onPressed: currentPage > 1
                    ? () {
                        setState(() {
                          currentPage--;
                        });
                      }
                    : null,
                icon: FaIcon(
                  FontAwesomeIcons.circleChevronLeft,
                  size: 30,
                  color: currentPage > 1 ? blueColor : Colors.grey,
                ),
              ),
              Text('Page $currentPage of $totalPages',
                  style: TextStyle(fontSize: 18)),
              IconButton(
                onPressed: currentPage < totalPages
                    ? () {
                        setState(() {
                          currentPage++;
                        });
                      }
                    : null,
                icon: FaIcon(
                  FontAwesomeIcons.circleChevronRight,
                  size: 30,
                  color: currentPage < totalPages ? blueColor : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _exportToPDF() async {
    try {
      setState(() {
        isDataLoading = true;
      });

      final pdf = pw.Document();

      // Add logo
      final image = await rootBundle.load('assets/images/newlogo.png');
      final imageBytes = image.buffer.asUint8List();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          header: (pw.Context context) => pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Image(pw.MemoryImage(imageBytes), width: 50, height: 50),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Reopen Work Order Report',
                      style: pw.TextStyle(
                          fontSize: 18, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                      'Generated on: ${DateFormat('yyyy-MMM-dd').format(DateTime.now())}',
                      style: pw.TextStyle(fontSize: 12)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('keybrainstech', style: pw.TextStyle(fontSize: 12)),
                  pw.Text('gg', style: pw.TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          build: (pw.Context context) {
            return [
              pw.SizedBox(height: 20),
              pw.Table(
                border: null,
                columnWidths: {
                  0: pw.FlexColumnWidth(1.2), // #
                  1: pw.FlexColumnWidth(1.5), // Subject
                  2: pw.FlexColumnWidth(1.0), // Category
                  3: pw.FlexColumnWidth(1.0), // Priority
                  4: pw.FlexColumnWidth(2.0), // Property
                  5: pw.FlexColumnWidth(1.5), // Assigned To
                  6: pw.FlexColumnWidth(1.2), // Due Date
                  7: pw.FlexColumnWidth(1.2), // Reopen Date
                  8: pw.FlexColumnWidth(1.2), // Created Date
                },
                children: [
                  // Header row with blue background
                  pw.TableRow(
                    decoration:
                        pw.BoxDecoration(color: PdfColor.fromHex("#5A86D5")),
                    children: [
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('#',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Subject',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Category',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Priority',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Property',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Assigned To',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Due Date',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Reopen Date',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white))),
                      pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text('Created Date',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  color: PdfColors.white))),
                    ],
                  ),
                  // Data rows
                  ...filteredData.map((order) => pw.TableRow(
                        children: [
                          pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(order.ticketNumber ?? 'N/A',
                                  style: pw.TextStyle(fontSize: 10))),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(order.workSubject ?? 'N/A',
                                  style: pw.TextStyle(fontSize: 10))),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(order.workCategory ?? 'N/A',
                                  style: pw.TextStyle(fontSize: 10))),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(order.priority ?? 'N/A',
                                  style: pw.TextStyle(fontSize: 10))),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(order.rentalAddress ?? 'N/A',
                                  style: pw.TextStyle(fontSize: 10))),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(order.staffmemberName ?? 'N/A',
                                  style: pw.TextStyle(fontSize: 10))),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(order.date ?? 'N/A',
                                  style: pw.TextStyle(fontSize: 10))),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(order.reopenDate ?? 'N/A',
                                  style: pw.TextStyle(fontSize: 10))),
                          pw.Padding(
                              padding: pw.EdgeInsets.all(8),
                              child: pw.Text(order.createdAt ?? 'N/A',
                                  style: pw.TextStyle(fontSize: 10))),
                        ],
                      )),
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );

      setState(() {
        isDataLoading = false;
      });

      Fluttertoast.showToast(msg: 'PDF exported successfully');
    } catch (e) {
      setState(() {
        isDataLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error exporting PDF: $e');
    }
  }

  void _exportToExcel() async {
    try {
      setState(() {
        isDataLoading = true;
      });

      final workbook = syncXlsx.Workbook();
      final worksheet = workbook.worksheets[0];
      worksheet.name = 'Reopen Work Orders';

      // Add headers
      List<String> headers = [
        'Ticket #',
        'Subject',
        'Category',
        'Priority',
        'Status',
        'Address',
        'Staff',
        'Date',
        'Reopen Date',
        'Work Performed',
        'Vendor Notes'
      ];
      for (int i = 0; i < headers.length; i++) {
        worksheet.getRangeByIndex(1, i + 1).setText(headers[i]);
        worksheet.getRangeByIndex(1, i + 1).cellStyle.bold = true;
      }

      // Add data
      for (int i = 0; i < filteredData.length; i++) {
        var order = filteredData[i];
        worksheet.getRangeByIndex(i + 2, 1).setText(order.ticketNumber ?? '');
        worksheet.getRangeByIndex(i + 2, 2).setText(order.workSubject ?? '');
        worksheet.getRangeByIndex(i + 2, 3).setText(order.workCategory ?? '');
        worksheet.getRangeByIndex(i + 2, 4).setText(order.priority ?? '');
        worksheet.getRangeByIndex(i + 2, 5).setText(order.status ?? '');
        worksheet.getRangeByIndex(i + 2, 6).setText(order.rentalAddress ?? '');
        worksheet
            .getRangeByIndex(i + 2, 7)
            .setText(order.staffmemberName ?? '');
        worksheet.getRangeByIndex(i + 2, 8).setText(order.date ?? '');
        worksheet.getRangeByIndex(i + 2, 9).setText(order.reopenDate ?? '');
        worksheet.getRangeByIndex(i + 2, 10).setText(order.workPerformed ?? '');
        worksheet.getRangeByIndex(i + 2, 11).setText(order.vendorNotes ?? '');
      }

      // Auto-fit columns
      for (int i = 1; i <= headers.length; i++) {
        worksheet.autoFitColumn(i);
      }

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final directory = await getApplicationDocumentsDirectory();
      final file = File(
          '${directory.path}/reopen_work_orders_${DateTime.now().millisecondsSinceEpoch}.xlsx');
      await file.writeAsBytes(bytes);

      setState(() {
        isDataLoading = false;
      });

      Fluttertoast.showToast(msg: 'Excel file exported to: ${file.path}');
    } catch (e) {
      setState(() {
        isDataLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error exporting Excel: $e');
    }
  }

  void _shareReport() async {
    try {
      setState(() {
        isDataLoading = true;
      });

      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/reopen_work_orders_report.txt');

      String reportContent = 'REOPEN WORK ORDERS REPORT\n';
      reportContent +=
          'Generated on: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}\n\n';

      for (var order in filteredData) {
        reportContent += 'Ticket: ${order.ticketNumber}\n';
        reportContent += 'Subject: ${order.workSubject}\n';
        reportContent += 'Category: ${order.workCategory}\n';
        reportContent += 'Priority: ${order.priority}\n';
        reportContent += 'Status: ${order.status}\n';
        reportContent += 'Address: ${order.rentalAddress}\n';
        reportContent += 'Staff: ${order.staffmemberName}\n';
        reportContent += 'Date: ${order.date}\n';
        reportContent += 'Reopen Date: ${order.reopenDate}\n';
        reportContent += 'Work Performed: ${order.workPerformed}\n';
        reportContent += 'Vendor Notes: ${order.vendorNotes}\n';
        reportContent += '---\n\n';
      }

      await file.writeAsString(reportContent);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Reopen Work Orders Report');

      setState(() {
        isDataLoading = false;
      });
    } catch (e) {
      setState(() {
        isDataLoading = false;
      });
      Fluttertoast.showToast(msg: 'Error sharing report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      drawer: CustomDrawer(
        currentpage: "Report",
        dropdown: false,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  titleBar(
                    title: 'Reopen Work Orders Report',
                    width: MediaQuery.of(context).size.width * .91,
                  ),
                  const SizedBox(height: 16),
                  if (isLoading)
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: 50),
                          SpinKitFadingCircle(color: Colors.blue),
                          SizedBox(height: 16),
                          Text('Loading reopen work orders...'),
                        ],
                      ),
                    )
                  else if (errorMessage != null)
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: 50),
                          Icon(Icons.error, size: 64, color: Colors.red),
                          SizedBox(height: 16),
                          Text(errorMessage!,
                              style: TextStyle(color: Colors.red)),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: fetchReport,
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (reopenWorkOrders.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          SizedBox(height: 50),
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No reopen work orders found'),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 5),
                      child: Column(
                        children: [
                          SizedBox(height: 5),
                          filters(data: filteredData),
                          const SizedBox(height: 10),
                          _buildHeaders(),
                          const SizedBox(height: 10),
                          Column(
                            children:
                                currentPageData.asMap().entries.map((entry) {
                              int rowIndex = entry.key;
                              var order = entry.value;
                              return _buildDataRow(order, rowIndex);
                            }).toList(),
                          ),
                          _buildPagination(),
                        ],
                      ),
                    ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset('assets/no_internet.json',
                      width: 200, height: 200),
                  SizedBox(height: 20),
                  Text('No Internet Connection',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 10),
                  Text('Please check your internet connection and try again'),
                ],
              ),
            ),
    );
  }
}
