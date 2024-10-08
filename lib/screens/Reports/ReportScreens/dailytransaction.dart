import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';

import '../../../Model/profile.dart';
import '../../../repository/GetAdminAddressPdf.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/Model/OpenWorkOrderReportModel.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/getAdminAddress.dart';
import 'package:three_zero_two_property/repository/GetAdminAddressPdf.dart';
import 'package:three_zero_two_property/repository/OpenWorkOrderReportService.dart';
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
import '../../../repository/daily_transaction_report.dart';
import '../../../widgets/CustomDateField.dart';
import '../../../widgets/custom_drawer.dart';
// Sample data model class

// Create a function to generate PDF

List<List<dynamic>> _generateTableData(
    List<Transaction> delinquentTenantsData) {
  final List<List<dynamic>> tableData = [];

  for (var item in delinquentTenantsData) {
    // Main row
    tableData.add([
      pw.Text(
        item.property ?? '',
        style: pw.TextStyle(
            fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
      ),
      pw.Text(
        item.tenantFirstName ?? '',
        style: pw.TextStyle(
            fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
      ),
      pw.Text(
        formatDate(item.createdAt.toString()) ?? '',
        style: pw.TextStyle(
            fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
      ),
      pw.Text(
        item.transactionId ?? '',
        style: pw.TextStyle(
            fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
      ),
      pw.Text(
        item.paymentType ?? '',
        style: pw.TextStyle(
            fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
      ),
      pw.Text(
        item.ccNumber ?? '',
        style: pw.TextStyle(
            fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
      ),
      pw.Align(
        alignment:
            pw.Alignment.centerRight, // Aligns the total amount to the right
        child: pw.Text(
          "\$${item.totalAmount.toString()}" ?? '',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
        ),
      ),
    ]);
// Subrow with concatenated data in a single row
    String subrowDescriptions = '';
    String subrowAmounts = '';

    for (var tenant in item.entries!) {
      subrowDescriptions +=
          '${tenant.description ?? ''}\n'; // Concatenate descriptions
      subrowAmounts +=
          '\$${tenant.amount?.toString() ?? '0'}\n'; // Concatenate amounts
    }

    // Remove trailing commas and spaces
    subrowDescriptions =
        subrowDescriptions.trim().replaceAll(RegExp(r',$'), '');
    subrowAmounts = subrowAmounts.trim().replaceAll(RegExp(r',$'), '');

    tableData.add([
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Text(
            subrowDescriptions,
            style: pw.TextStyle(fontSize: 10),
          ),
        ],
      ),
      '',
      '',
      '',
      '',
      '',
      pw.Align(
        alignment:
            pw.Alignment.centerRight, // Aligns the total amount to the right
        child: pw.Text(
          subrowAmounts,
          textAlign: pw.TextAlign.right,
          style: pw.TextStyle(fontSize: 10),
        ),
      ),
    ]);
    // Subrow with colspan (simulated by creating a container)
    /*  for (var tenant in item.entries!) {
      tableData.add([
        pw.Column(
          children: [
            pw.Container(
              //color: PdfColors.cyan,
              width: 320, // Adjust width to span multiple columns
              padding: pw.EdgeInsets.symmetric(vertical: 5,horizontal: 5),
              child: pw.Text(tenant.description ?? '',
                  style: pw.TextStyle(fontSize: 10)),
            ),
          ],
        ),
        '',
        '',
        '',
        '',
        '',
        "\$${tenant.amount.toString()}" ?? '',
      ]);
    }*/
  }

  return tableData;
}

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double grandTotals = 0;
  Future<void> generateWorkOrderPdf(List<Transaction> workOrderData) async {
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
        header: (pw.Context context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Image(image, width: 50, height: 50),
            pw.SizedBox(width: 10),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.Text(
                  'Daily Transactions',
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
                pw.SizedBox(height: 30)
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
              'Property',
              'Tenant',
              'Date',
              'Transaction ID',
              'Type',
              'Reference',
              'Total'
            ],
            data: _generateTableData(workOrderData),
            border: null,
            headerAlignment: pw.Alignment.centerLeft,
            // cellAlignment: pw.Alignment.center,
            headerDecoration: pw.BoxDecoration(
              color: PdfColors.blue400,
            ),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
            cellStyle: pw.TextStyle(
              fontSize: 10,
            ),
            cellHeight: 20,
            columnWidths: {
              0: pw.FlexColumnWidth(2), // Date
              1: pw.FlexColumnWidth(1.5), // Address
              2: pw.FlexColumnWidth(1), // Work
              3: pw.FlexColumnWidth(1.5), // Performed
              4: pw.FlexColumnWidth(1), // Performed
              5: pw.FlexColumnWidth(1.5), // Performed
              6: pw.FlexColumnWidth(.8), // Performed
            },
          ),
          pw.SizedBox(height: 50),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 20),
          pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Total :-  \$${grandTotals}",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)))
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<List<Transaction>> fetchTransactions(String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse(
          'https://saas.cloudrentalmanager.com/api/payment/todayspayment/1716391492591?selectedDate=$date'),
      headers: {
        'Content-Type': 'application/json',
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body)["data"];
      return parseTransactions(jsonData);
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  List<List<dynamic>> _generateTableData(
      List<Transaction> delinquentTenantsData) {
    final List<List<dynamic>> tableData = [];
    double grandTotal = 0;
    for (var item in delinquentTenantsData) {
      // Main row

      grandTotal += item.totalAmount ?? 0;

      tableData.add([
        pw.Text(
          item.property ?? '',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          "${item.tenantFirstName} ${item.tenantLastName}" ?? '',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          formatDate(item.createdAt.toString()) ?? '',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          item.transactionId ?? '',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          item.paymentType ?? '',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          "${item.cctype} ${item.ccNumber}" ?? '',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Align(
          alignment:
              pw.Alignment.centerRight, // Aligns the total amount to the right
          child: pw.Text(
            "\$${item.totalAmount.toString()}" ?? '',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ]);
// Subrow with concatenated data in a single row
      String subrowDescriptions = '';
      String subrowAmounts = '';

      for (var tenant in item.entries!) {
        subrowDescriptions +=
            '${tenant.description ?? ''}\n'; // Concatenate descriptions
        subrowAmounts +=
            '\$${tenant.amount?.toString() ?? '0'}\n'; // Concatenate amounts
      }

      // Remove trailing commas and spaces
      subrowDescriptions =
          subrowDescriptions.trim().replaceAll(RegExp(r',$'), '');
      subrowAmounts = subrowAmounts.trim().replaceAll(RegExp(r',$'), '');

      tableData.add([
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              subrowDescriptions,
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        '',
        '',
        '',
        '',
        '',
        pw.Align(
          alignment:
              pw.Alignment.centerRight, // Aligns the total amount to the right
          child: pw.Text(
            subrowAmounts,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 10),
          ),
        ),
      ]);
      // Subrow with colspan (simulated by creating a container)
      /*  for (var tenant in item.entries!) {
      tableData.add([
        pw.Column(
          children: [
            pw.Container(
              //color: PdfColors.cyan,
              width: 320, // Adjust width to span multiple columns
              padding: pw.EdgeInsets.symmetric(vertical: 5,horizontal: 5),
              child: pw.Text(tenant.description ?? '',
                  style: pw.TextStyle(fontSize: 10)),
            ),
          ],
        ),
        '',
        '',
        '',
        '',
        '',
        "\$${tenant.amount.toString()}" ?? '',
      ]);
    }*/
    }
    setState(() {
      grandTotals = grandTotal;
    });
    return tableData;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Generate PDFs')),
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              List<Transaction> transactions = [
                Transaction(
                  property: 'Address 1',
                  tenantFirstName: 'John',
                  tenantLastName: 'Doe',
                  createdAt: DateTime.now(),
                  transactionId: 'TX123456',
                  paymentType: 'Card',
                  ccNumber: '**** 1234',
                  cctype: "",
                  totalAmount: 1000,
                  entries: [
                    Entry(description: 'Rent Income', amount: 400),
                    Entry(description: 'Security Deposit', amount: 500),
                    Entry(description: 'Pre-payments', amount: 100),
                  ],
                ),
                Transaction(
                  property: 'Address 2',
                  tenantFirstName: 'Jane',
                  tenantLastName: 'Smith',
                  createdAt: DateTime.now(),
                  transactionId: 'TX654321',
                  paymentType: 'Cash',
                  ccNumber: '**** 4321',
                  totalAmount: 500,
                  cctype: "",
                  entries: [
                    Entry(description: 'Rent Income', amount: 250),
                    Entry(description: 'Security Deposit', amount: 250),
                  ],
                ),
                // Add more transactions as needed
              ];

              final transaction = await fetchTransactions('2024-09-04');

              generateWorkOrderPdf(transaction);
            },
            child: Text('Generate PDF'),
          ),
        ),
      ),
    );
  }
}

class DailyTransactions extends StatefulWidget {
  @override
  State<DailyTransactions> createState() => _DailyTransactionsState();
}

class _DailyTransactionsState extends State<DailyTransactions> {
  final _formKey = GlobalKey<FormState>();
  Future<List<Transaction>>? _futureReport;
  double grandTotals = 0;
  Future<List<Transaction>> fetchTransactions(String date) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${Api_url}/api/payment/todayspayment/$id?selectedDate=$date'),
      headers: {
        'Content-Type': 'application/json',
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    print(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(response.body)["data"];
      return parseTransactions(jsonData);
    } else {
      throw Exception('Failed to load transactions');
    }
  }

  List<List<dynamic>> _generateTableData(
      List<Transaction> delinquentTenantsData) {
    final List<List<dynamic>> tableData = [];
    double grandTotal = 0;
    for (var item in delinquentTenantsData) {
      // Main row

      grandTotal += item.totalAmount ?? 0;

      tableData.add([
        pw.Text(
          item.property ?? '',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          "${item.tenantFirstName} ${item.tenantLastName}" ?? '',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          formatDate(item.createdAt.toString()) ?? '',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          item.transactionId ?? '',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          item.paymentType ?? '',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          "${item.cctype} ${item.ccNumber}" ?? '',
          style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Align(
          alignment:
              pw.Alignment.centerRight, // Aligns the total amount to the right
          child: pw.Text(
            "\$${item.totalAmount.toString()}" ?? '',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
        ),
      ]);
// Subrow with concatenated data in a single row
      String subrowDescriptions = '';
      String subrowAmounts = '';

      for (var tenant in item.entries!) {
        subrowDescriptions +=
            '${tenant.description ?? ''}\n'; // Concatenate descriptions
        subrowAmounts +=
            '\$${tenant.amount?.toString() ?? '0'}\n'; // Concatenate amounts
      }
      // if (item.surcharge!.isNotEmpty &&
      //     item.surcharge != null &&
      //     item.surcharge != "0") {
      //   subrowDescriptions += "Surcharge \n";
      //   subrowAmounts += '\$${item.surcharge}\n';
      // }

      // Remove trailing commas and spaces
      subrowDescriptions =
          subrowDescriptions.trim().replaceAll(RegExp(r',$'), '');
      subrowAmounts = subrowAmounts.trim().replaceAll(RegExp(r',$'), '');

      tableData.add([
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Text(
              subrowDescriptions,
              style: pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        '',
        '',
        '',
        '',
        '',
        pw.Align(
          alignment:
              pw.Alignment.centerRight, // Aligns the total amount to the right
          child: pw.Text(
            subrowAmounts,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(fontSize: 10),
          ),
        ),
      ]);
      // Subrow with colspan (simulated by creating a container)
      /*  for (var tenant in item.entries!) {
      tableData.add([
        pw.Column(
          children: [
            pw.Container(
              //color: PdfColors.cyan,
              width: 320, // Adjust width to span multiple columns
              padding: pw.EdgeInsets.symmetric(vertical: 5,horizontal: 5),
              child: pw.Text(tenant.description ?? '',
                  style: pw.TextStyle(fontSize: 10)),
            ),
          ],
        ),
        '',
        '',
        '',
        '',
        '',
        "\$${tenant.amount.toString()}" ?? '',
      ]);
    }*/
    }
    setState(() {
      grandTotals = grandTotal;
    });
    return tableData;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchTrasactionsReport();
    DateTime today = DateTime.now();
    selectdate.text = DateFormat('yyyy-MM-dd').format(today);
    _futureReport =
        DailyTrasactionReport().fetchTransactions(selectdate.text!);
  }

  void _fetchTrasactionsReport() {
    setState(() {
      _futureReport = DailyTrasactionReport().fetchTransactions(
          formateDatechange(DateTime.now().subtract(Duration(days: 2))));
    });
  }

  String formateDatechange(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date).toString();
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

  List<WorkOrderReportData> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String searchvalue = "";
  String? selectedValue;

  List<WorkOrderReportData> get _pagedData {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    return _tableData.sublist(startIndex,
        endIndex > _tableData.length ? _tableData.length : endIndex);
  }

  Widget _buildPaginationControls() {
    int numorpages = (_tableData.length / _rowsPerPage).ceil();

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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

  DateTime? _selectedDate;
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
                        ? Text(
                            "Tenant\n Name",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          )
                        : Text("Tenant\nName",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center),
                    // Text("Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 3),
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
                    Text("Property", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    /*   ascending2
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
                    ),*/
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
                    Text(
                      "Transaction \nType",
                      style: TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(width: 5),
                    /*ascending3
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
                    ),*/
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
      Comparable<T> Function(WorkOrderReportData d)? getField) {
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

  void _sort<T>(Comparable<T> Function(WorkOrderReportData d) getField,
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

  void sortData(List<WorkOrderReportData> data) {
    if (sorting1) {
      data.sort((a, b) => ascending1
          ? a.workSubject!.compareTo(b.workSubject!)
          : b.workSubject!.compareTo(a.workSubject!));
    } else if (sorting2) {
      data.sort((a, b) => ascending2
          ? a.rentalAddress!.compareTo(b.rentalAddress!)
          : b.rentalAddress!.compareTo(a.rentalAddress!));
    } else if (sorting3) {
      data.sort((a, b) => ascending3
          ? a.status!.compareTo(b.status!)
          : b.status!.compareTo(a.status!));
    }
  }

  String formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final formatter = DateFormat('dd-MM-yyyy');
      return formatter.format(date);
    } catch (e) {
      return dateStr; // If the date is not valid, return the original string
    }
  }

  Future<void> generateWorkOrderPdf(List<Transaction> workOrderData) async {
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
    final currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
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
                    'Daily Transactions Report',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                      'Date :  ${selectdate.text.isNotEmpty ? selectdate.text : currentDate}'),
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
              'Property',
              'Tenant',
              'Date',
              'Transaction ID',
              'Type',
              'Reference',
              'Total'
            ],
            data: _generateTableData(workOrderData),
            border: null,
            headerAlignment: pw.Alignment.centerLeft,
            // cellAlignment: pw.Alignment.center,
            headerDecoration: pw.BoxDecoration(
              color: PdfColor.fromHex("#5A86D5"),
              //color:PdfColor.fromRYB(90, 134, 213,)
            ),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 12,
                color: PdfColors.white),
            cellStyle: pw.TextStyle(
              fontSize: 10,
            ),
            cellHeight: 20,
            columnWidths: {
              0: pw.FlexColumnWidth(2), // Date
              1: pw.FlexColumnWidth(1.5), // Address
              2: pw.FlexColumnWidth(1), // Work
              3: pw.FlexColumnWidth(1.5), // Performed
              4: pw.FlexColumnWidth(1), // Performed
              5: pw.FlexColumnWidth(1.5), // Performed
              6: pw.FlexColumnWidth(.8), // Performed
            },
          ),
          pw.SizedBox(height: 50),
          pw.Divider(),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 20),
          pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Text("Total :-  \$${grandTotals.toStringAsFixed(2)}",
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold)))
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  Future<void> generateWorkOrderExcel(List<Transaction> workOrderData) async {
    final syncXlsx.Workbook workbook = syncXlsx.Workbook();
    final syncXlsx.Worksheet sheet = workbook.worksheets[0];
    List<String> headerData = [];

    workOrderData.forEach((transaction) {
      transaction.entries.forEach((entry) {
        headerData.add(entry.description);
      });
    });
    List<String> uniqueList = [...(Set<String>.from(headerData))];
    sheet.getRangeByName('A1:ZZ1').columnWidth = 20;

    final List<String> headers = [
      'Date',
      'Tenant',
      'Property',
      'Payment Type',
      'Transaction Id',
      'Card Type',
      "Card No",
      ...uniqueList,
      // "Surcharge",
      "Total"
    ];
    print(headers);

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
        formattedDate = workOrder.createdAt != null
            ? DateFormat('yyyy-MM-dd').format(
                DateFormat('yyyy-MM-dd').parse(workOrder.createdAt.toString()))
            : 'Invalid Date';
      } catch (e) {
        formattedDate = 'Invalid Date';
      }

      sheet.getRangeByIndex(2 + i, 1).setText(formattedDate);
      sheet.getRangeByIndex(2 + i, 2).setText(
          "${workOrder.tenantFirstName} ${workOrder.tenantLastName}" ?? '');
      sheet.getRangeByIndex(2 + i, 3).setText(workOrder.property ?? '');
      sheet.getRangeByIndex(2 + i, 4).setText(workOrder.paymentType ?? '');
      sheet.getRangeByIndex(2 + i, 5).setText(workOrder.transactionId ?? '');
      sheet
          .getRangeByIndex(2 + i, 6)
          .setText(workOrder.cctype != "" ? workOrder.cctype ?? '' : "N/A");
      sheet.getRangeByIndex(2 + i, 7).setText(workOrder.ccNumber ?? '');
      // sheet
      //     .getRangeByIndex(2 + i, 8 + uniqueList.length)
      //     .setText(workOrder.surcharge.toString() ?? '');
      // sheet.getRangeByIndex(2 + i, 8 + uniqueList.length).cellStyle.hAlign =
      //     syncXlsx.HAlignType.right;
      sheet
          .getRangeByIndex(2 + i, 8 + uniqueList.length)
          .setText(workOrder.totalAmount.toString() ?? '');
      sheet.getRangeByIndex(2 + i, 8 + uniqueList.length).cellStyle.hAlign =
          syncXlsx.HAlignType.right;

      //  sheet.getRangeByIndex(2 + i, 8).setText(workOrder.ccNumber ?? '');
      for (int j = 0; j < uniqueList.length; j++) {
        final String header = uniqueList.elementAt(j);
        final List<Entry> value = workOrder.entries.length > 0
            ? workOrder.entries
                .where((entry) =>
                    entry.description != null && entry.description == header)
                .toList()
            : [];
        sheet.getRangeByIndex(2 + i, 9 + j).setText(value.length > 0
            ? value[0].amount.toString() ?? '0'
            : "0"); // Handle null values gracefully
        sheet.getRangeByIndex(2 + i, 9 + j).cellStyle.hAlign =
            syncXlsx.HAlignType.right;
      }
    }

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);

    final String fileName = selectdate.text.isNotEmpty
        ? 'DailyTransactionReport_${selectdate.text}.xlsx'
        : 'DailyTransactionReport_${formattedDate}.xlsx';

    final Directory directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : Directory('/storage/emulated/0/Download');

    final path = '${directory.path}/$fileName';

    // Create directory if it doesn't exist (for Android)
    if (!await directory.exists() && !Platform.isIOS) {
      await directory.create(recursive: true);
    }

    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    Fluttertoast.showToast(
      msg: 'Excel file saved to $path',
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color.fromRGBO(21, 43, 83, 1),
            colorScheme: ColorScheme.light(
              primary: Color.fromRGBO(21, 43, 83, 1),
            ),
            buttonTheme: ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        selectdate.text = DateFormat('yyyy-MM-dd')
            .parse(picked.toString())
            .toString()
            .split(" ")[0];

        _futureReport =
            DailyTrasactionReport().fetchTransactions(selectdate.text!);
        print(selectdate.text);
      });

      // Notify the FormField state of the change
    }
  }

  Future<void> generateWorkOrderCsv(List<Transaction> workOrderData) async {
    final List<List<String>> rows = []; // Stores data for CSV

    // Header row with standard and unique headers
    final List<String> headers = [
      'Date',
      'Tenant',
      'Property',
      'Payment Type',
      'Transaction Id',
      'Card Type',
      'Card No',
      ...workOrderData.fold<Set<String>>({},
          (Set<String> existingHeaders, Transaction transaction) {
        existingHeaders.addAll(
            transaction.entries.map((entry) => entry.description).toList());
        return existingHeaders;
      }).toList(),
      // 'Surcharge',
      'Total',
    ];
    rows.add(headers);

    // Data rows based on transactions
    for (final workOrder in workOrderData) {
      final List<String> row = []; // Stores data for a single row

      // Safe date parsing with default/fallback value
      String formattedDate;
      try {
        formattedDate = workOrder.createdAt != null
            ? DateFormat('yyyy-MM-dd').format(
                DateFormat('yyyy-MM-dd').parse(workOrder.createdAt.toString()))
            : 'Invalid Date';
      } catch (e) {
        formattedDate = 'Invalid Date';
      }

      row.add(formattedDate);
      row.add("${workOrder.tenantFirstName} ${workOrder.tenantLastName}" ?? '');
      row.add(workOrder.property ?? '');
      row.add(workOrder.paymentType ?? '');
      row.add(workOrder.transactionId ?? '');
      row.add(workOrder.cctype != "" ? workOrder.cctype ?? 'N/A' : 'N/A');
      row.add(workOrder.ccNumber ?? '');

      // Add values for unique headers
      for (final String header in workOrderData.fold<Set<String>>({},
          (Set<String> existingHeaders, Transaction transaction) {
        existingHeaders.addAll(
            transaction.entries.map((entry) => entry.description).toList());
        return existingHeaders;
      }).toList()) {
        final List<Entry> value = workOrder.entries.length > 0
            ? workOrder.entries
                .where((entry) =>
                    entry.description != null && entry.description == header)
                .toList()
            : [];
        row.add(value.length > 0
            ? value[0].amount.toString() ?? '0'
            : '0'); // Handle null values
      }

      // row.add(workOrder.surcharge.toString() ?? '');
      row.add(workOrder.totalAmount.toString() ?? '');

      rows.add(row);
    }

    // Create CSV string
    final String csvContent = const ListToCsvConverter().convert(rows);

    // Save CSV file
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'DailyTransactionReport_$formattedDate.csv';
    final Directory directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : Directory('/storage/emulated/0/Download');

    final path = '${directory.path}/$fileName';

    // Create directory if it doesn't exist (for Android)
    if (!await directory.exists() && !Platform.isIOS) {
      await directory.create(recursive: true);
    }


    final File file = File(path);
    await file.writeAsString(csvContent);

    Fluttertoast.showToast(
      msg: 'CSV file saved to $path',
    );
  }

  TextEditingController selectdate = TextEditingController();
  String? chargetype;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget_302.App_Bar(context: context),
      drawer: CustomDrawer(
        currentpage: "Reports",
        dropdown: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            titleBar(
              title: 'Daily Transaction',
              width: MediaQuery.of(context).size.width * .91,
            ),
            if (MediaQuery.of(context).size.width < 500)
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                ),
                child: FutureBuilder<List<Transaction>>(
                  future: _futureReport,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Column(
                        children: [
                          Expanded(
                            flex: 0,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 5.0,
                                right: 5.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                   width: MediaQuery.of(context).size.width * .3,
                                    child: TextFormField(
                                      controller: selectdate,
                                      onTap: () {
                                        _pickDate(context);
                                      },
                                      readOnly: true,
                                      textInputAction: TextInputAction.next,
                                      textAlignVertical:
                                      TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10), //Imp Line
                                        isDense: true,
                                        hintText: "Select Date",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            borderSide: const BorderSide(
                                              width: 0.5,
                                            )),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.grey)),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: chargetype,
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                        hint: Text(
                                          "Charge Type",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        items: const [
                                          DropdownMenuItem<String>(
                                            value: 'Card',
                                            child: Text('Card'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'ACH',
                                            child: Text('ACH'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'Check',
                                            child: Text('Check'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'All',
                                            child: Text('All'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            chargetype = value;
                                          });
                                          // Handle the selected charge type
                                          print(value);
                                        },
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 43,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blueColor,
                                      ),
                                      onPressed: () {},
                                      child: PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          // Add your export logic here based on the selected value
                                          if (value == 'PDF') {
                                            print('pdf');
                                           // generateWorkOrderPdf(data);
                                            // Export as PDF
                                          } else if (value == 'XLSX') {
                                            print('XLSX');
                                          //  generateWorkOrderExcel(data);
                                            // Export as XLSX
                                          } else if (value == 'CSV') {
                                            print('CSV');
                                         //   generateWorkOrderCsv(data);
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
                                          //mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Export'),
                                            Icon(Icons.arrow_drop_down),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ColabShimmerLoadingWidget(),
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Column(
                        children: [
                          Expanded(
                            flex: 0,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 5.0,
                                right: 5.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                   width: MediaQuery.of(context).size.width * .3,
                                    child: TextFormField(
                                      controller: selectdate,
                                      onTap: () {
                                        _pickDate(context);
                                      },
                                      readOnly: true,
                                      textInputAction: TextInputAction.next,
                                      textAlignVertical:
                                      TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        contentPadding:
                                        const EdgeInsets.symmetric(
                                            vertical: 10,
                                            horizontal: 10), //Imp Line
                                        isDense: true,
                                        hintText: "Select Datee",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(5),
                                            borderSide: const BorderSide(
                                              width: 0.5,
                                            )),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 43,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.grey)),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: chargetype,
                                        padding:
                                        EdgeInsets.symmetric(horizontal: 5),
                                        hint: Text(
                                          "Charge Type",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        items: const [
                                          DropdownMenuItem<String>(
                                            value: 'Card',
                                            child: Text('Card'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'ACH',
                                            child: Text('ACH'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'Check',
                                            child: Text('Check'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'All',
                                            child: Text('All'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            chargetype = value;
                                          });
                                          // Handle the selected charge type
                                          print(value);
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                   // width: 100,
                                    height: 43,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blueColor,
                                      ),
                                      onPressed: () {},
                                      child: PopupMenuButton<String>(
                                        onSelected: (value) async {
                                          // Add your export logic here based on the selected value
                                          if (value == 'PDF') {
                                            print('pdf');
                                          //  generateWorkOrderPdf(data);
                                            // Export as PDF
                                          } else if (value == 'XLSX') {
                                            print('XLSX');
                                          //  generateWorkOrderExcel(data);
                                            // Export as XLSX
                                          } else if (value == 'CSV') {
                                            print('CSV');
                                         //   generateWorkOrderCsv(data);
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
                                          //mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Export'),
                                            Icon(Icons.arrow_drop_down),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: MediaQuery.of(context).size.height * .5,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    "assets/images/no_data.jpg",
                                    height: 200,
                                    width: 200,
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "No Data Available",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blueColor,
                                        fontSize: 16),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    var data = snapshot.data!;
                    // Apply filtering based on selectedValue and searchvalue
                    if (chargetype == null || chargetype!.isEmpty) {
                      print("-----1");
                      data = snapshot.data!;
                    } else if (chargetype == "All") {
                      print("-----2");
                      data = snapshot.data!;
                    } else if (chargetype!.isNotEmpty) {
                      print("-----3");
                      data = snapshot.data!
                          .where((workOrder) =>
                              workOrder.paymentType!.toLowerCase() ==
                              chargetype!.toLowerCase())
                          .toList();
                    }

                    // Sort data if necessary
                    //  sortData(data);

                    // Pagination logic
                    final totalPages = (data.length / itemsPerPage).ceil();
                    final currentPageData = data
                        .skip(currentPage * itemsPerPage)
                        .take(itemsPerPage)
                        .toList();

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 8,
                          ),
                          Expanded(
                            flex: 0,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 5.0,
                                right: 5.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * .3,
                                    child: TextFormField(
                                      controller: selectdate,
                                      onTap: () {
                                        _pickDate(context);
                                      },
                                      textInputAction: TextInputAction.next,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 10,
                                                horizontal: 10), //Imp Line
                                        isDense: true,
                                        hintText: "Select Date",
                                        border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            borderSide: const BorderSide(
                                              width: 0.5,
                                            )),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 42,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        border: Border.all(color: Colors.grey)),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: chargetype,
                                        padding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        hint: Text(
                                          "Charge Type",
                                          style: TextStyle(fontSize: 14),
                                        ),
                                        items: const [
                                          DropdownMenuItem<String>(
                                            value: 'Card',
                                            child: Text('Card'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'ACH',
                                            child: Text('ACH'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'Check',
                                            child: Text('Check'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'All',
                                            child: Text('All'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            chargetype = value;
                                          });
                                          // Handle the selected charge type
                                          print(value);
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    //width: 100,
                                    height: 43,
                                    child: ElevatedButton(
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
                                          //mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('Export'),
                                            Icon(Icons.arrow_drop_down),
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          if (data.length > 0)
                            Column(
                              children: [
                                SizedBox(height: 10),
                                _buildHeaders(),
                                SizedBox(height: 10),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color.fromRGBO(
                                              152, 162, 179, .5))),
                                  // decoration: BoxDecoration(
                                  //     border: Border.all(color: blueColor)),
                                  child: Column(
                                    children: currentPageData
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      bool isExpanded = expandedIndex == index;
                                      Transaction workOrder = entry.value;

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: index % 2 != 0
                                              ? Colors.white
                                              : blueColor.withOpacity(0.09),
                                          border: Border.all(
                                              color: Color.fromRGBO(
                                                  152, 162, 179, .5)),
                                        ),
                                        // decoration: BoxDecoration(
                                        //   border: Border.all(color: blueColor),
                                        // ),
                                        child: Column(
                                          children: <Widget>[
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
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          if (expandedIndex ==
                                                              index) {
                                                            expandedIndex =
                                                                null;
                                                          } else {
                                                            expandedIndex =
                                                                index;
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            left: 5, right: 5),
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
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          setState(() {
                                                            if (expandedIndex ==
                                                                index) {
                                                              expandedIndex =
                                                              null;
                                                            } else {
                                                              expandedIndex =
                                                                  index;
                                                            }
                                                          });
                                                        },
                                                        child: Text(
                                                          '${workOrder.tenantFirstName} ${workOrder.tenantLastName}',
                                                          style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .04),
                                                    Expanded(
                                                      child: Text(
                                                        '${workOrder.property ?? '-'}',
                                                        style: TextStyle(
                                                          color: blueColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .04),
                                                    Expanded(
                                                      child: Text(
                                                        '${workOrder.paymentType ?? '-'}',
                                                        style: TextStyle(
                                                          color: blueColor,
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                        width: MediaQuery.of(
                                                                    context)
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
                                                margin:
                                                    EdgeInsets.only(bottom: 20),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          FaIcon(
                                                            isExpanded
                                                                ? FontAwesomeIcons
                                                                    .sortUp
                                                                : FontAwesomeIcons
                                                                    .sortDown,
                                                            size: 20,
                                                            color: Colors
                                                                .transparent,
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
                                                                            'Transaction Id:  ',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: blueColor), // Bold and black
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            '${workOrder.transactionId ?? '-'}',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w700,
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
                                                                        text:
                                                                            'Transaction Date: ',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: blueColor), // Bold and black
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            '${formatDate(workOrder.createdAt.toString())}',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w700,
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
                                                                        text:
                                                                            'Payment Details: ',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: blueColor), // Bold and black
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            '${workOrder.cctype} ${workOrder.ccNumber}',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color: grey), // Light and grey
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Total Amount: ',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            color: blueColor), // Bold and black
                                                                      ),
                                                                      TextSpan(
                                                                        text:
                                                                            '\$${workOrder.totalAmount}',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.w700,
                                                                            color: grey), // Light and grey
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              0.0,
                                                                          top:
                                                                              10),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      FaIcon(
                                                                        isExpanded
                                                                            ? FontAwesomeIcons.sortUp
                                                                            : FontAwesomeIcons.sortDown,
                                                                        size:
                                                                            20,
                                                                        color: Colors
                                                                            .transparent,
                                                                      ),
                                                                      const Expanded(
                                                                        flex: 4,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <Widget>[
                                                                            Text.rich(
                                                                              TextSpan(
                                                                                children: [
                                                                                  TextSpan(
                                                                                    text: 'Account : ',
                                                                                    style: TextStyle(
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Color.fromRGBO(21, 43, 83, 1),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const Expanded(
                                                                        flex: 2,
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <Widget>[
                                                                            Text.rich(
                                                                              TextSpan(
                                                                                children: [
                                                                                  TextSpan(
                                                                                    text: '  Amount : ',
                                                                                    style: TextStyle(
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Color.fromRGBO(21, 43, 83, 1),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                Column(
                                                                  children: workOrder
                                                                      .entries
                                                                      .map(
                                                                          (entry) {
                                                                    return Padding(
                                                                      padding: const EdgeInsets
                                                                          .only(
                                                                          left:
                                                                              00.0,
                                                                          bottom:
                                                                              10),
                                                                      child:
                                                                          Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.start,
                                                                        children: [
                                                                          FaIcon(
                                                                            isExpanded
                                                                                ? FontAwesomeIcons.sortUp
                                                                                : FontAwesomeIcons.sortDown,
                                                                            size:
                                                                                20,
                                                                            color:
                                                                                Colors.transparent,
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                4,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: <Widget>[
                                                                                Text.rich(
                                                                                  TextSpan(
                                                                                    children: [
                                                                                      TextSpan(
                                                                                        text: '${entry.description ?? "N/A"}',
                                                                                        style: TextStyle(
                                                                                          fontWeight: FontWeight.w700,
                                                                                          color: grey,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          SizedBox(
                                                                            width:
                                                                                15,
                                                                          ),
                                                                          Expanded(
                                                                            flex:
                                                                                2,
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: <Widget>[
                                                                                Text.rich(
                                                                                  TextSpan(
                                                                                    children: [
                                                                                      TextSpan(
                                                                                        text: ' \$ ${entry.amount ?? "N/A"}',
                                                                                        style: TextStyle(
                                                                                          fontWeight: FontWeight.w700,
                                                                                          color: grey,
                                                                                        ),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                                // Add additional fields if needed
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  }).toList(),
                                                                ),
                                                                SizedBox(
                                                                  height: 5,
                                                                ),
                                                                // if (workOrder
                                                                //         .paymentType ==
                                                                //     "Card")
                                                                //   Padding(
                                                                //     padding: const EdgeInsets
                                                                //         .only(
                                                                //         left:
                                                                //             0.0),
                                                                //     child: Row(
                                                                //       mainAxisAlignment:
                                                                //           MainAxisAlignment
                                                                //               .start,
                                                                //       children: [
                                                                //         FaIcon(
                                                                //           isExpanded
                                                                //               ? FontAwesomeIcons.sortUp
                                                                //               : FontAwesomeIcons.sortDown,
                                                                //           size:
                                                                //               20,
                                                                //           color:
                                                                //               Colors.transparent,
                                                                //         ),
                                                                //         Expanded(
                                                                //           flex:
                                                                //               4,
                                                                //           child:
                                                                //               Column(
                                                                //             crossAxisAlignment:
                                                                //                 CrossAxisAlignment.start,
                                                                //             children: <Widget>[
                                                                //               Text.rich(
                                                                //                 TextSpan(
                                                                //                   children: [
                                                                //                     TextSpan(
                                                                //                       text: 'Surcharge',
                                                                //                       style: TextStyle(
                                                                //                         fontWeight: FontWeight.w700,
                                                                //                         color: grey,
                                                                //                       ),
                                                                //                     ),
                                                                //                   ],
                                                                //                 ),
                                                                //               ),
                                                                //             ],
                                                                //           ),
                                                                //         ),
                                                                //         SizedBox(
                                                                //           width:
                                                                //               15,
                                                                //         ),
                                                                //         Expanded(
                                                                //           flex:
                                                                //               2,
                                                                //           child:
                                                                //               Column(
                                                                //             crossAxisAlignment:
                                                                //                 CrossAxisAlignment.start,
                                                                //             children: <Widget>[
                                                                //               Text.rich(
                                                                //                 TextSpan(
                                                                //                   children: [
                                                                //                     TextSpan(
                                                                //                       text: ' \$ ${workOrder.surcharge ?? "0"}',
                                                                //                       style: TextStyle(
                                                                //                         fontWeight: FontWeight.w700,
                                                                //                         color: grey,
                                                                //                       ),
                                                                //                     ),
                                                                //                   ],
                                                                //                 ),
                                                                //               ),
                                                                //               // Add additional fields if needed
                                                                //             ],
                                                                //           ),
                                                                //         ),
                                                                //       ],
                                                                //     ),
                                                                //   ),
                                                              ],
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
                                              border: Border.all(
                                                  color: Colors.grey),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<int>(
                                                value: itemsPerPage,
                                                items: itemsPerPageOptions
                                                    .map((int value) {
                                                  return DropdownMenuItem<int>(
                                                    value: value,
                                                    child:
                                                        Text(value.toString()),
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
                                          onPressed:
                                              currentPage < totalPages - 1
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
                          if (data.length == 0)
                            Container(
                              height: MediaQuery.of(context).size.height * .5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      "assets/images/no_data.jpg",
                                      height: 200,
                                      width: 200,
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "No Data Available",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: blueColor,
                                          fontSize: 16),
                                    )
                                  ],
                                ),
                              ),
                            )
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
                padding: const EdgeInsets.only(left: 21.0, right: 21.0),
                child: Expanded(
                    flex: 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
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
                                  ? 48
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
            /* if (MediaQuery.of(context).size.width > 500)
              FutureBuilder<List<WorkOrderReportData>>(
                future: _futureReport,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ShimmerTabletTable();
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height * .5,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset("assets/images/no_data.jpg",height: 200,width: 200,),
                            SizedBox(height: 10,),
                            Text("No Data Available",style: TextStyle(fontWeight: FontWeight.bold,color:blueColor,fontSize: 16),)
                          ],
                        ),
                      ),
                    );
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

                  // Update _tableData with the filtered data
                  _tableData = data;

                  // Get the paged data
                  final pagedData = _pagedData;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.95,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
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
                                      _buildDataCell(pagedData[i].date!),
                                      _buildDataCell(pagedData[i]
                                          .rentalAddress
                                          .toString()!),
                                      _buildDataCell(pagedData[i].workSubject!),
                                      _buildDataCell(
                                          pagedData[i].workPerformed!),
                                      _buildDataCell(pagedData[i].vendorNotes!),
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
              )*/
          ],
        ),
      ),
    );
  }
}
