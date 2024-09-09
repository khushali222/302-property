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
// Sample data model class
class Transaction {
  final String property;
  final String tenantFirstName;
  final String tenantLastName;
  final DateTime createdAt;
  final String transactionId;
  final String paymentType;
  final String ccNumber;
  final String cctype;

   var totalAmount;
  final List<Entry> entries;

  Transaction({
    required this.property,
    required this.tenantFirstName,
    required this.tenantLastName,
    required this.createdAt,
    required this.transactionId,
    required this.paymentType,
    required this.ccNumber,
    required this.totalAmount,
    required this.cctype,
    required this.entries,
  });
}

class Entry {
  final String description;
   var amount;

  Entry({
    required this.description,
    required this.amount,
  });
}
List<Transaction> parseTransactions(List<dynamic> jsonData) {
  return jsonData.map((json) {
    return Transaction(
      property: json['unit_data'] != null ? json['unit_data']['rental_unit'] : 'N/A',
      tenantFirstName: json['tenant_data'] != null ? json['tenant_data']['tenant_firstName'] : 'N/A',
      tenantLastName: json['tenant_data'] != null ? json['tenant_data']['tenant_lastName'] : 'N/A',
      createdAt: DateTime.parse(json['createdAt']),
      transactionId: json['transaction_id'] ?? "N/A",
      paymentType: json['payment_type'],
      ccNumber: json['cc_number'] ?? 'N/A',
      totalAmount: json['total_amount'],
      cctype: json['cc_type']??"",
      entries: (json['entry'] as List<dynamic>).map((entry) {
        return Entry(
          description: entry['account'],
          amount: entry['amount'],
        );
      }).toList(),
    );
  }).toList();
}
// Create a function to generate PDF


List<List<dynamic>> _generateTableData(List<Transaction> delinquentTenantsData) {
  final List<List<dynamic>> tableData = [];

  for (var item in delinquentTenantsData) {
    // Main row
    tableData.add([
      pw.Text(
        item.property ?? '',
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
      ),
      pw.Text(
        item.tenantFirstName ?? '',
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
      ),
      pw.Text(
        formatDate(item.createdAt.toString()) ?? '',
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
      ),
      pw.Text(
        item.transactionId ?? '',
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
      ),
      pw.Text(
        item.paymentType ?? '',
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
      ),
      pw.Text(
        item.ccNumber ?? '',
        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
      ),
      pw.Align(
        alignment: pw.Alignment.centerRight, // Aligns the total amount to the right
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
      subrowDescriptions += '${tenant.description ?? ''}\n'; // Concatenate descriptions
      subrowAmounts += '\$${tenant.amount?.toString() ?? '0'}\n'; // Concatenate amounts
    }

    // Remove trailing commas and spaces
    subrowDescriptions = subrowDescriptions.trim().replaceAll(RegExp(r',$'), '');
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
        alignment: pw.Alignment.centerRight, // Aligns the total amount to the right
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
  Future<void> generateWorkOrderPdf(
      List<Transaction> workOrderData) async {
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
            data:  _generateTableData(workOrderData),
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
              child: pw.Text("Total :-  \$${grandTotals}",style: pw.TextStyle(
                fontSize: 20,
                fontWeight: pw.FontWeight.bold

              ))
          )

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
      Uri.parse('https://saas.cloudrentalmanager.com/api/payment/todayspayment/1716391492591?selectedDate=$date'),
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
  List<List<dynamic>> _generateTableData(List<Transaction> delinquentTenantsData) {
    final List<List<dynamic>> tableData = [];
    double grandTotal = 0;
    for (var item in delinquentTenantsData) {
      // Main row

        grandTotal += item.totalAmount ?? 0;


      tableData.add([
        pw.Text(
          item.property ?? '',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          "${item.tenantFirstName} ${item.tenantLastName}" ?? '',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          formatDate(item.createdAt.toString()) ?? '',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          item.transactionId ?? '',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          item.paymentType ?? '',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Text(
          "${item.cctype} ${item.ccNumber}" ?? '',
          style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold), // Bold style applied
        ),
        pw.Align(
          alignment: pw.Alignment.centerRight, // Aligns the total amount to the right
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
        subrowDescriptions += '${tenant.description ?? ''}\n'; // Concatenate descriptions
        subrowAmounts += '\$${tenant.amount?.toString() ?? '0'}\n'; // Concatenate amounts
      }

      // Remove trailing commas and spaces
      subrowDescriptions = subrowDescriptions.trim().replaceAll(RegExp(r',$'), '');
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
          alignment: pw.Alignment.centerRight, // Aligns the total amount to the right
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
            onPressed: () async{
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
