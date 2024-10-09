import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/DelinquentTenantsModel.dart';
import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/getAdminAddress.dart';
import 'package:three_zero_two_property/repository/DelinquentTenantsService.dart';
import 'package:three_zero_two_property/repository/GetAdminAddressPdf.dart';
import 'package:three_zero_two_property/repository/RentersInsuranceService.dart';
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
import '../../../../Model/rentalownerreport.dart';
import '../../../repository/rentalownerreport.dart';
import '../../../widgets/custom_drawer.dart';

class RentalOwnerReports extends StatefulWidget {
  const RentalOwnerReports({super.key});

  @override
  State<RentalOwnerReports> createState() => _RentalOwnerReportsState();
}

class _RentalOwnerReportsState extends State<RentalOwnerReports> {
  late Future<List<RentalOwnerReport>> _futureRentersInsurance;
  List<RentalOwnerReport> DelinquentTenantsModel = [];
  bool isLoading = true;
  String? errorMessage;
  int? expandedRowIndex;
  Map<int, int?> expandedTenantIndex = {};

  @override
  void initState() {
    super.initState();
    fetchRentalOwners();
    fetchReport();

  }

  fetchReport(){
    setState(() {
      daterange = "Today";
      fromDate.text = formatDate(
          DateTime.now().toString());
      toDate.text = formatDate(
          DateTime.now().toString());
    });
    DateTime time = DateTime.now();
    DateTime date =  DateFormat('yyyy-MM-dd').parse(time.toString());
    _futureRentersInsurance = fetchDelinquentTenantsData(formatDate(date.toString()),formatDate(date.toString()));
  }
  Future<List<RentalOwnerReport>> fetchDelinquentTenantsData(String fromDate, String toDate,{String? rentalownerid,String? charge}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');

      String? chargedata = chargeType == "All" ? null : chargeType;

      List<RentalOwnerReport> data = await RentalOwnerReportService()
          .fetchRentalOwnerReport(id!,reverseFormatDate(fromDate),reverseFormatDate(toDate),rentalownerid: selectedrenatalownerid,chargetype: chargedata);

      setState(() {
        DelinquentTenantsModel = data;
        isLoading = false;
        errorMessage = null; // Reset error message on successful data fetch
      });
      return data;
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Failed to load renters insurance data. Please try again later.';
      });
      return [];
    }
  }

  double grandtotal = 0.0;
  List<DelinquentTenantsData> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  String searchvalue = "";
  String? selectedValue;

  int totalrecords = 0;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [10, 25, 50, 100];

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
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
                : blueColor,
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

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(DelinquentTenantsData d)? getField) {
    return TableCell(
      child: GestureDetector(
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

  void _sort<T>(Comparable<T> Function(DelinquentTenantsData d) getField,
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    children: [
                      width < 400
                          ? const Text("Rental Owner",
                              style: TextStyle(color: Colors.white))
                          : const Text("Rental Owner",
                              style: TextStyle(color: Colors.white)),
                      // Text("Property", style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 3),
                      ascending1
                          ? const Padding(
                              padding: EdgeInsets.only(top: 7, left: 2),
                              child: FaIcon(
                                FontAwesomeIcons.sortUp,
                                size: 20,
                                color: Colors.white,
                              ),
                            )
                          : const Padding(
                              padding: EdgeInsets.only(bottom: 7, left: 2),
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
            ),
            // Expanded(
            //   child: GestureDetector(
            //     onTap: () {
            //       setState(() {
            //         if (sorting2) {
            //           sorting1 = false;
            //           sorting2 = sorting2;
            //           sorting3 = false;
            //           ascending2 = sorting2 ? !ascending2 : true;
            //           ascending1 = false;
            //           ascending3 = false;
            //         } else {
            //           sorting1 = false;
            //           sorting2 = !sorting2;
            //           sorting3 = false;
            //           ascending2 = sorting2 ? !ascending2 : true;
            //           ascending1 = false;
            //           ascending3 = false;
            //         }
            //         // Sorting logic here
            //       });
            //     },
            //     child: Row(
            //       children: [
            //         Text("Address", style: TextStyle(color: Colors.white)),
            //         SizedBox(width: 5),
            //         ascending2
            //             ? Padding(
            //                 padding: const EdgeInsets.only(top: 7, left: 2),
            //                 child: FaIcon(
            //                   FontAwesomeIcons.sortUp,
            //                   size: 20,
            //                   color: Colors.white,
            //                 ),
            //               )
            //             : Padding(
            //                 padding: const EdgeInsets.only(bottom: 7, left: 2),
            //                 child: FaIcon(
            //                   FontAwesomeIcons.sortDown,
            //                   size: 20,
            //                   color: Colors.white,
            //                 ),
            //               ),
            //       ],
            //     ),
            //   ),
            // ),
            // Expanded(
            //   child: GestureDetector(
            //     onTap: () {
            //       setState(() {
            //         if (sorting3) {
            //           sorting1 = false;
            //           sorting2 = false;
            //           sorting3 = sorting3;
            //           ascending3 = sorting3 ? !ascending3 : true;
            //           ascending2 = false;
            //           ascending1 = false;
            //         } else {
            //           sorting1 = false;
            //           sorting2 = false;
            //           sorting3 = !sorting3;
            //           ascending3 = sorting3 ? !ascending3 : true;
            //           ascending2 = false;
            //           ascending1 = false;
            //         }

            //         // Sorting logic here
            //       });
            //     },
            //     child: Row(
            //       children: [
            //         Text("Work", style: TextStyle(color: Colors.white)),
            //         SizedBox(width: 5),
            //         ascending3
            //             ? Padding(
            //                 padding: const EdgeInsets.only(top: 7, left: 2),
            //                 child: FaIcon(
            //                   FontAwesomeIcons.sortUp,
            //                   size: 20,
            //                   color: Colors.white,
            //                 ),
            //               )
            //             : Padding(
            //                 padding: const EdgeInsets.only(bottom: 7, left: 2),
            //                 child: FaIcon(
            //                   FontAwesomeIcons.sortDown,
            //                   size: 20,
            //                   color: Colors.white,
            //                 ),
            //               ),
            //       ],
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  PdfDelinquentTenantsData? globalDelinquentTenantsData;
  Future<PdfDelinquentTenantsData?> fetchDelinquentTenantsGrandTotal() async {
    print('Fetching delinquent tenants');

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString('token');

    try {
      final response = await http
          .get(Uri.parse('$Api_url/api/charge/delinquent/$adminId'), headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      });

      if (response.statusCode == 200) {
        final parsedJson = jsonDecode(response.body);
        if (parsedJson['grandtotal'] != null) {
          globalDelinquentTenantsData =
              PdfDelinquentTenantsData.fromJson(parsedJson['grandtotal']);
          return globalDelinquentTenantsData;
        } else {
          throw Exception('Grand total data is not available');
        }
      } else {
        throw Exception('Failed to load delinquent tenants');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  bool istenantDataLoading = false;
  bool customdate = false;
  Future<void> generateDelinquentTenantsPdf(
      List<RentalOwnerReport> delinquentTenantsData) async {
    final GetAddressAdminPdfService service = GetAddressAdminPdfService();
    profile? profileData;

    try {
      profileData = await service.fetchAdminAddress();
    } catch (e) {
      // Handle error
      print("Error fetching profile data: $e");
      return;
    }
    setState(() {
      istenantDataLoading = true;
    });
    await fetchDelinquentTenantsGrandTotal();
    setState(() {
      istenantDataLoading = false;
    });
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
                    'Rental Owner Reports',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Date : - ${fromDate.text}',
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
                  'Tenant',
                  'Date',
                  'Pmt Type',
                  'Txn ID',
                  'Reference',
                  'Crd Type',
                  'Crd No',
                  'Total',
                ],
                data: _generateTableData(delinquentTenantsData),
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
                      pw.Text('\$${grandtotal.toStringAsFixed(2)}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold))
                    ])),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  List<List<dynamic>> _generateTableData(
      List<RentalOwnerReport> rentalOwnerReports) {
    final List<List<dynamic>> tableData = [];
    double total = 0.0;

    for (var owner in rentalOwnerReports) {
      // Main row for the rental owner name
      tableData.add([
        pw.Text(owner.rentalOwnerName,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        ''
      ]);

      for (var property in owner.payments) {
        tableData.add([
          pw.Padding(
              child: pw.Text(
                '${property.rentalData.rentalAddress ?? 'N/A'}',
                style: pw.TextStyle(fontSize: 10),
              ),
              padding: pw.EdgeInsets.only(left: 15)), // Property Name
          '${property.tenantData.tenantFirstName ?? 'N/A'} ${property.tenantData.tenantLastName ?? 'N/A'}', // Tenant Name
          property.createdAt.toString(), // Payment Date
          property.paymentType ?? '', // Payment Type
          property.transactionId ?? '', // Transaction ID
          property.paymentId ?? '', // References
          property.ccType ?? '', // Card Type
          property.ccNumber ?? '', // Card Number
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              '\$${(property.totalAmount ?? 0.0).toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 10),
              // Total Amount formatted to 2 decimal places
              // Align text to the right
            ),
          ),
        ]);

        for (var payment in property.entry) {
          tableData.add([
            pw.Padding(
                child: pw.Text('${payment.account ?? 'N/A'}',
                    style: pw.TextStyle(fontSize: 10)),
                padding: pw.EdgeInsets.only(left: 15)), // Account Name
            '', // Account Amount
            '', '', '', '', '', '',
            pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    '\$${(payment.amount ?? 0.0).toStringAsFixed(2)}',
                    style: pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.right // Align text to the right
                    ))
          ]);
        }

        if (property.surcharge != 0.0) {
          tableData.add([
            pw.Padding(
                child: pw.Text(
                  'Surcharge',
                  style: pw.TextStyle(fontSize: 10),
                ),
                padding: pw.EdgeInsets.only(left: 15)),
            '', // Account Amount
            '', '', '', '', '', '',
            pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text(
                    '\$${(property.surcharge ?? 0.0).toStringAsFixed(2)}', // Surcharge formatted to 2 decimal places
                    style: pw.TextStyle(fontSize: 10),
                    textAlign: pw.TextAlign.right // Align text to the right
                    ))
          ]);
        }
      }

      // Subtotal row for the rental owner
      tableData.add([
        pw.Padding(
            child: pw.Text('Subtotal ${owner.rentalOwnerName ?? 'N/A'}',
                style:
                    pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            padding: pw.EdgeInsets.only(
                left: 15)), // Label for rental owner subtotal
        '', '', '', '', '', '', '',
        pw.Text(
            '\$${(owner.subTotal ?? 0.0).toStringAsFixed(2)}', // Subtotal formatted to 2 decimal places
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            textAlign: pw.TextAlign.right // Align text to the right
            )
      ]);

      total += owner.subTotal;
    }

    setState(() {
      grandtotal = total;
    });

    return tableData;
  }

  Future<void> generateRentalOwnerReportExcel(
      List<RentalOwnerReport> rentalOwnerReports) async {
    final syncXlsx.Workbook workbook = syncXlsx.Workbook();
    final syncXlsx.Worksheet sheet = workbook.worksheets[0];

    sheet.getRangeByName('A1:I1').columnWidth = 20;

    final List<String> headers = [
      'Property',
      'Tenant',
      'Date',
      'Pmt Type',
      'Txn ID',
      'Reference',
      'Crd Type',
      'Crd No',
      'Total',
    ];

    final syncXlsx.Style headerCellStyle =
        workbook.styles.add('headerCellStyle');
    headerCellStyle.bold = true;
    headerCellStyle.backColor = '#5A86D5';
    headerCellStyle.fontColor = '#FFFFFF';
    headerCellStyle.fontSize = 16;
    headerCellStyle.hAlign = syncXlsx.HAlignType.center;

    final syncXlsx.Style currencyCellStyle =
        workbook.styles.add('currencyCellStyle');
    currencyCellStyle.numberFormat = '\$#,##0.00'; // Currency format
    currencyCellStyle.hAlign = syncXlsx.HAlignType.right; // Right-align amounts

    final syncXlsx.Style boldAmountStyle =
        workbook.styles.add('boldAmountStyle');
    boldAmountStyle.bold = true;
    boldAmountStyle.numberFormat = '\$#,##0.00';
    boldAmountStyle.hAlign = syncXlsx.HAlignType.right;
    final syncXlsx.Style AmountTitleStyle =
        workbook.styles.add('AmountTitleStyle');
    boldAmountStyle.bold = true;
    boldAmountStyle.numberFormat = '\$#,##0.00';

    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(1, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle = headerCellStyle;
    }

    int rowIndex = 2;
    double grandTotal = 0.0;

    for (var owner in rentalOwnerReports) {
      final rentalOwnerCell = sheet.getRangeByIndex(rowIndex, 1);
      rentalOwnerCell.setText(owner.rentalOwnerName ?? '');
      rentalOwnerCell.cellStyle.bold = true;
      sheet.getRangeByName('A$rowIndex:I$rowIndex').merge();
      rowIndex++;

      for (var property in owner.payments) {
        sheet
            .getRangeByIndex(rowIndex, 1)
            .setText(property.rentalData.rentalAddress ?? 'N/A');
        sheet.getRangeByIndex(rowIndex, 2).setText(
            '${property.tenantData.tenantFirstName ?? 'N/A'} ${property.tenantData.tenantLastName ?? 'N/A'}');
        sheet
            .getRangeByIndex(rowIndex, 3)
            .setText(property.createdAt.toString());
        sheet.getRangeByIndex(rowIndex, 4).setText(property.paymentType ?? '');
        sheet
            .getRangeByIndex(rowIndex, 5)
            .setText(property.transactionId ?? '');
        sheet.getRangeByIndex(rowIndex, 6).setText(property.paymentId ?? '');
        sheet.getRangeByIndex(rowIndex, 7).setText(property.ccType ?? '');
        sheet.getRangeByIndex(rowIndex, 8).setText(property.ccNumber ?? '');
        sheet
            .getRangeByIndex(rowIndex, 9)
            .setNumber(property.totalAmount ?? 0.0);
        sheet.getRangeByIndex(rowIndex, 9).cellStyle = currencyCellStyle;
        rowIndex++;

        for (var payment in property.entry) {
          sheet.getRangeByIndex(rowIndex, 1).setText(payment.account ?? 'N/A');
          sheet.getRangeByIndex(rowIndex, 9).setNumber(payment.amount);
          sheet.getRangeByIndex(rowIndex, 9).cellStyle = currencyCellStyle;
          rowIndex++;
        }

        if (property.surcharge != 0.0) {
          sheet.getRangeByIndex(rowIndex, 1).setText('Surcharge');
          sheet.getRangeByIndex(rowIndex, 9).setNumber(property.surcharge);
          sheet.getRangeByIndex(rowIndex, 9).cellStyle = currencyCellStyle;
          rowIndex++;
        }
      }

      sheet
          .getRangeByIndex(rowIndex, 1)
          .setText('Subtotal - ${owner.rentalOwnerName}');
      sheet.getRangeByIndex(rowIndex, 1).cellStyle.bold = true;
      sheet.getRangeByIndex(rowIndex, 9).setNumber(owner.subTotal ?? 0.0);
      sheet.getRangeByIndex(rowIndex, 9).cellStyle = boldAmountStyle;
      sheet.getRangeByName('A$rowIndex:H$rowIndex').merge();
      rowIndex++;

      grandTotal += owner.subTotal ?? 0.0;
    }

    sheet.getRangeByIndex(rowIndex, 1).setText('Grand Total');
    sheet.getRangeByIndex(rowIndex, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(rowIndex, 9).setNumber(grandTotal);
    sheet.getRangeByIndex(rowIndex, 9).cellStyle = boldAmountStyle;
    sheet.getRangeByName('A$rowIndex:H$rowIndex').merge();

    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'RentalOwnerReport_$formattedDate.xlsx';

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

  Future<void> generateRentalOwnerReportCsv(
      List<RentalOwnerReport> rentalOwnerReports) async {
    // Define headers for CSV
    final List<String> headers = [
      'Property',
      'Tenant',
      'Date',
      'Pmt Type',
      'Txn ID',
      'Reference',
      'Crd Type',
      'Crd No',
      'Total',
    ];

    // Create a buffer to store CSV data
    final StringBuffer csvBuffer = StringBuffer();

    // Add headers to the CSV file
    csvBuffer.writeln(headers.join(','));

    double grandTotal = 0.0;

    // Iterate through each rental owner report
    for (var owner in rentalOwnerReports) {
      // Add rental owner name as a row
      csvBuffer.writeln('${owner.rentalOwnerName ?? ''}');

      // Iterate through each property for the current rental owner
      for (var property in owner.payments) {
        // Replace commas in the rental address with spaces
        final String sanitizedAddress =
            (property.rentalData.rentalAddress ?? 'N/A').replaceAll(',', ' ');

        // Add property and tenant details
        csvBuffer.writeln([
          sanitizedAddress,
          '${property.tenantData.tenantFirstName ?? 'N/A'} ${property.tenantData.tenantLastName ?? 'N/A'}',
          property.createdAt.toString(),
          property.paymentType ?? '',
          property.transactionId ?? '',
          property.paymentId ?? '',
          property.ccType ?? '',
          property.ccNumber ?? '',
          '\$${property.totalAmount?.toStringAsFixed(2) ?? '0.00'}'
        ].join(','));

        // Iterate through payment entries for the current property
        for (var payment in property.entry) {
          csvBuffer.writeln([
            payment.account ?? 'N/A',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '\$${payment.amount.toStringAsFixed(2)}'
          ].join(','));
        }

        // Add surcharge row if applicable
        if (property.surcharge != 0.0) {
          csvBuffer.writeln([
            'Surcharge',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '\$${property.surcharge.toStringAsFixed(2)}'
          ].join(','));
        }
      }

      // Add subtotal row for the current rental owner
      csvBuffer.writeln([
        'Subtotal - ${owner.rentalOwnerName}',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '\$${(owner.subTotal ?? 0.0).toStringAsFixed(2)}'
      ].join(','));

      // Accumulate grand total
      grandTotal += owner.subTotal ?? 0.0;
    }

    // Add grand total row at the end
    csvBuffer.writeln([
      'Grand Total',
      '',
      '',
      '',
      '',
      '',
      '',
      '',
      '\$${grandTotal.toStringAsFixed(2)}'
    ].join(','));

    // Convert buffer to list of bytes for CSV file
    final List<int> bytes = utf8.encode(csvBuffer.toString());

    // Define file name with current date and time
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'RentalOwnerReport_$formattedDate.csv';

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

    // Show success toast message
    Fluttertoast.showToast(
      msg: 'CSV file saved to $path',
    );
  }

  Future<void> generateDelinquentTenantsCsv(
      List<DelinquentTenantsData> delinquentTenantsData) async {
    setState(() {
      istenantDataLoading = true;
    });

    final globalDelinquentTenantsData =
        await fetchDelinquentTenantsGrandTotal();

    setState(() {
      istenantDataLoading = false;
    });
    List<List<dynamic>> rows = [
      [
        'Unit',
        'Tenant',
        'Total',
        '0-30 days',
        '31-60 days',
        '61-90 days',
        '91+ days'
      ]
    ];

    for (var item in delinquentTenantsData) {
      // Add main row with rental address
      rows.add([item.rentalAddress ?? '', '', '', '', '', '', '']);

      // Add tenant details in subsequent rows
      for (var tenant in item.tenants!) {
        rows.add([
          tenant.unitDetails ?? '',
          tenant.tenantName ?? '',
          tenant.pdfDelinquentTenantsData?.totalDaysAmount ?? '',
          tenant.pdfDelinquentTenantsData?.last30Days ?? '',
          tenant.pdfDelinquentTenantsData?.last31To60Days ?? '',
          tenant.pdfDelinquentTenantsData?.last61To90Days ?? '',
          tenant.pdfDelinquentTenantsData?.last91PlusDays ?? ''
        ]);
      }

      // Add total row for each property
      rows.add([
        'Total',
        '',
        item.alltotalamount?.totalDaysAmount ?? '',
        item.alltotalamount?.last30Days ?? '',
        item.alltotalamount?.last31To60Days ?? '',
        item.alltotalamount?.last61To90Days ?? '',
        item.alltotalamount?.last91PlusDays ?? ''
      ]);
    }

    // Add grand total row
    if (globalDelinquentTenantsData != null) {
      rows.add([
        'Grand Total of all Properties',
        '',
        globalDelinquentTenantsData!.totalDaysAmount ?? '',
        globalDelinquentTenantsData!.last30Days ?? '',
        globalDelinquentTenantsData!.last31To60Days ?? '',
        globalDelinquentTenantsData!.last61To90Days ?? '',
        globalDelinquentTenantsData!.last91PlusDays ?? ''
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);

    // Define file name with current date and time
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'DelinquentTenantsReport_$formattedDate.csv';

    // Define file path
    final Directory directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : Directory('/storage/emulated/0/Download');

    final path = '${directory.path}/$fileName';

    // Create directory if it doesn't exist (for Android)
    if (!await directory.exists() && !Platform.isIOS) {
      await directory.create(recursive: true);
    }


    // Write file to the path
    final File file = File(path);
    await file.writeAsString(csv);

    // Show success toast message
    Fluttertoast.showToast(
      msg: 'CSV file saved to $path',
    );
  }
  Future<void> _pickDate(BuildContext context) async {
    DateTime? _selectedDate ;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: blueColor,
            colorScheme: ColorScheme.light(
              primary: blueColor,
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

        fromDate.text = DateFormat('yyyy-MM-dd')
            .parse(picked.toString())
            .toString()
            .split(" ")[0];
        fromDate.text = formatDate(fromDate.text);
        _futureRentersInsurance = fetchDelinquentTenantsData(fromDate.text,toDate.text);
      });

      // Notify the FormField state of the change
    }
  }
  Future<void> _endDate(BuildContext context) async {
    DateTime? _selectedDate ;
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: blueColor,
            colorScheme: ColorScheme.light(
              primary: blueColor,
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

        toDate.text = DateFormat('yyyy-MM-dd')
            .parse(picked.toString())
            .toString()
            .split(" ")[0];
        toDate.text = formatDate(toDate.text);
        _futureRentersInsurance = fetchDelinquentTenantsData(fromDate.text,toDate.text);
      });

      // Notify the FormField state of the change
    }
  }
  List<Map<String,dynamic>> rentalowners = [];
  Future<void> fetchRentalOwners() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? staffid = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('${Api_url}/api/rentals/rental-owners/$id'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $staffid",
    });
    final jsonData = json.decode(response.body);
    print(jsonData);
    if (response.statusCode ==200) {
      setState(() {
       rentalowners =  (jsonDecode(response.body) as List).map((e) => e as Map<String, dynamic>)!.toList();
      });
      log(rentalowners.toString());
    } else {
      throw Exception('Failed to load data');
    }
  }
  TextEditingController fromDate = TextEditingController();
  TextEditingController toDate = TextEditingController();
  String? daterange;
  String? chargeType;
  String? selectedrenatalownerid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      drawer: CustomDrawer(
        currentpage: "Report",
        dropdown: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            titleBar(
              title: 'Rental Owner Report',
              width: MediaQuery.of(context).size.width * .91,
            ),
            if (MediaQuery.of(context).size.width > 500)
              const SizedBox(height: 16),
            if (MediaQuery.of(context).size.width < 500)
              FutureBuilder<List<RentalOwnerReport>>(
                future: _futureRentersInsurance,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          filters(),
                          SizedBox(height: 10,),
                          ColabShimmerLoadingWidget(),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          filters(),
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
                      ),
                    );
                  }

                  var data = snapshot.data!;



                  // Pagination logic
                  final totalPages = (data.length / itemsPerPage).ceil();
                  final currentPageData = data
                      .skip(currentPage * itemsPerPage)
                      .take(itemsPerPage)
                      .toList();

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 5),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 5,
                          ),
                          filters(data: data),
                          const SizedBox(height: 10),
                          _buildHeaders(),
                          const SizedBox(height: 20),
                          Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: blueColor


)),
                            child: Column(
                              children:
                                  currentPageData.asMap().entries.map((entry) {
                                int rowIndex = entry.key;
                                var item = entry.value;
                                bool isRowExpanded =
                                    expandedRowIndex == rowIndex;

                                return Container(
                                  // decoration: BoxDecoration(
                                  //   border: Border.all(color: blueColor),
                                  // ),
                                  decoration: BoxDecoration(
                                    color: rowIndex %2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                                    border: Border.all(color: blueColor


),
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
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (expandedRowIndex ==
                                                        rowIndex) {
                                                      expandedRowIndex = null;
                                                    } else {
                                                      expandedRowIndex =
                                                          rowIndex;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 5, right: 5),
                                                  padding: !isRowExpanded
                                                      ? const EdgeInsets.only(
                                                          bottom: 10)
                                                      : const EdgeInsets.only(
                                                          top: 10),
                                                  child: FaIcon(
                                                    isRowExpanded
                                                        ? FontAwesomeIcons
                                                            .sortUp
                                                        : FontAwesomeIcons
                                                            .sortDown,
                                                    size: 20,
                                                    color: isRowExpanded
                                                        ? Color.fromARGB(
                                                            255, 35, 67, 126)
                                                        : Color.fromRGBO(
                                                            21, 43, 83, 1),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  '${item.rentalOwnerName ?? '-'}',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isRowExpanded)
                                        Column(
                                          children: item.payments!
                                              .asMap()
                                              .entries
                                              .map((tenantEntry) {
                                            int tenantIndex = tenantEntry.key;
                                            var tenant = tenantEntry.value;
                                            bool isTenantExpanded =
                                                expandedTenantIndex[rowIndex] ==
                                                    tenantIndex;

                                            return Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          if (expandedTenantIndex[
                                                                  rowIndex] ==
                                                              tenantIndex) {
                                                            expandedTenantIndex[
                                                                    rowIndex] =
                                                                null;
                                                          } else {
                                                            expandedTenantIndex[
                                                                    rowIndex] =
                                                                tenantIndex;
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(
                                                            left: 5, right: 5),
                                                        padding: !isTenantExpanded
                                                            ? const EdgeInsets
                                                                .only(
                                                                bottom: 10)
                                                            : const EdgeInsets
                                                                .only(top: 10),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                          child: FaIcon(
                                                            isTenantExpanded
                                                                ? FontAwesomeIcons
                                                                    .sortUp
                                                                : FontAwesomeIcons
                                                                    .sortDown,
                                                            size: 20,
                                                            color: isTenantExpanded
                                                                ? Color
                                                                    .fromARGB(
                                                                        255,
                                                                        35,
                                                                        67,
                                                                        126)
                                                                : Color
                                                                    .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        83,
                                                                        1),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        child: Text(
                                                      "${tenant.rentalData.rentalAddress}",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: blueColor),
                                                    )),
                                                    Expanded(
                                                        child: Text(
                                                      "${formatDate(tenant.createdAt.toString())}",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: blueColor),
                                                    ))
                                                  ],
                                                ),
                                                if (isTenantExpanded)
                                                  Row(
                                                    children: [
                                                      SizedBox(
                                                        width: 20,
                                                      ),
                                                      Expanded(
                                                        child: Table(
                                                          columnWidths: {
                                                            // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                                            // 1: FlexColumnWidth(),
                                                            0: FlexColumnWidth(), // Distribute columns equally
                                                            1: FlexColumnWidth(),
                                                          },
                                                          children: [
                                                            _buildTableRow(
                                                                'Rental Owners Name:',
                                                                _getDisplayValue(item
                                                                    .rentalOwnerName),
                                                                'Property:',
                                                                _getDisplayValue(tenant
                                                                    .rentalData
                                                                    .rentalAddress)),
                                                            _buildTableRow(
                                                                'Tenant Name:',
                                                                _getDisplayValue(
                                                                    "${tenant.tenantData.tenantFirstName} ${tenant.tenantData.tenantLastName}"),
                                                                'Transaction Id',
                                                                _getDisplayValue(
                                                                    tenant
                                                                        .transactionId)),
                                                            _buildTableRow(
                                                                'Transaction Date:',
                                                                _getDisplayValue(
                                                                    formatDate(tenant
                                                                        .createdAt
                                                                        .toString())),
                                                                'Transaction Type:',
                                                                _getDisplayValue(
                                                                    tenant
                                                                        .paymentType)),
                                                            _buildTableRow(
                                                                'Payment Details:',
                                                                _getDisplayValue(
                                                                    "${tenant.ccType} ${tenant.ccNumber}"),
                                                                'Payment Amount:',
                                                                _getDisplayValue(
                                                                    "\$${tenant.totalAmount}")),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                if (item.payments.length - 1 !=
                                                    tenantIndex)
                                                  Divider(
                                                    thickness: 2,
                                                  )
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Material(
                                    elevation: 3,
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
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
                                          : blueColor,
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
                                          ? blueColor
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
                    ),
                  );
                },
              ),
            /* if (MediaQuery.of(context).size.width > 500)
              FutureBuilder<List<DelinquentTenantsData>>(
                future: _futureRentersInsurance,
                builder: (context, snapshot) {
                  if (isLoading) {
                    return ShimmerTabletTable();
                  } else if (snapshot.hasError) {
                    return Center(child: Text(errorMessage ?? 'Unknown error'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No data available'));
                  }

                  var data = snapshot.data!;

                  // Apply filtering based on selectedValue and searchValue
                  if (selectedValue == null && searchvalue.isEmpty) {
                    data = snapshot.data!;
                  } else if (selectedValue == "All") {
                    data = snapshot.data!;
                  } else if (searchvalue.isNotEmpty) {
                    data = snapshot.data!
                        .where((item) =>
                    item.rentalAddress!
                        .toLowerCase()
                        .contains(searchvalue.toLowerCase()) ||
                        item.tenants!.any((tenant) => tenant.tenantName!
                            .toLowerCase()
                            .contains(searchvalue.toLowerCase())))
                        .toList();
                  } else {
                    data = snapshot.data!
                        .where((item) => item.rentalAddress == selectedValue)
                        .toList();
                  }

                  // Pagination logic
                  final totalPages = (data.length / itemsPerPage).ceil();
                  final currentPageData = data
                      .skip(currentPage * itemsPerPage)
                      .take(itemsPerPage)
                      .toList();

                  return SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Material(
                                    elevation: 3,
                                    borderRadius: BorderRadius.circular(2),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      height:
                                      MediaQuery.of(context).size.width <
                                          500
                                          ? 48
                                          : 50,
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
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: blueColor,
                                  ),
                                  onPressed: () {},
                                  child: PopupMenuButton<String>(
                                    onSelected: (value) async {
                                      // Export logic
                                      if (value == 'PDF') {
                                        print('pdf');
                                        generateDelinquentTenantsPdf(data);
                                      } else if (value == 'XLSX') {
                                        print('XLSX');
                                        generateDelinquentTenantsExcel(data);
                                      } else if (value == 'CSV') {
                                        print('CSV');
                                        generateDelinquentTenantsCsv(data);
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
                                    child: const Row(
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
                          const SizedBox(height: 20),
                          _buildHeaders(),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: blueColor


)),
                            // decoration: BoxDecoration(
                            //     border: Border.all(color: blueColor)),
                            child: Column(
                              children:
                              currentPageData.asMap().entries.map((entry) {
                                int rowIndex = entry.key;
                                var item = entry.value;
                                bool isRowExpanded =
                                    expandedRowIndex == rowIndex;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: rowIndex %2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                                    border: Border.all(color: blueColor


),
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
                                              GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    if (expandedRowIndex ==
                                                        rowIndex) {
                                                      expandedRowIndex = null;
                                                    } else {
                                                      expandedRowIndex =
                                                          rowIndex;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 5),
                                                  padding: !isRowExpanded
                                                      ? const EdgeInsets.only(
                                                      bottom: 10)
                                                      : const EdgeInsets.only(
                                                      top: 10),
                                                  child: FaIcon(
                                                    isRowExpanded
                                                        ? FontAwesomeIcons
                                                        .sortUp
                                                        : FontAwesomeIcons
                                                        .sortDown,
                                                    size: 20,
                                                    color: isRowExpanded
                                                        ? Color.fromARGB(
                                                        255, 35, 67, 126)
                                                        : blueColor


,
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
                                                  '${item.rentalAddress ?? '-'}',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (isRowExpanded)
                                        Column(
                                          children: item.tenants!
                                              .asMap()
                                              .entries
                                              .map((tenantEntry) {
                                            int tenantIndex = tenantEntry.key;
                                            var tenant = tenantEntry.value;
                                            bool isTenantExpanded =
                                                expandedTenantIndex[rowIndex] ==
                                                    tenantIndex;

                                            return Column(
                                              children: <Widget>[
                                                Divider(
                                                  color: blueColor,
                                                ),
                                                ListTile(
                                                  contentPadding:
                                                  EdgeInsets.zero,
                                                  title: Padding(
                                                    padding:
                                                    const EdgeInsets.all(
                                                        2.0),
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
                                                              rowIndex] ==
                                                                  tenantIndex) {
                                                                expandedTenantIndex[
                                                                rowIndex] =
                                                                null;
                                                              } else {
                                                                expandedTenantIndex[
                                                                rowIndex] =
                                                                    tenantIndex;
                                                              }
                                                            });
                                                          },
                                                          child: Container(
                                                            margin:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 5),
                                                            padding: !isTenantExpanded
                                                                ? const EdgeInsets
                                                                .only(
                                                                bottom: 10)
                                                                : const EdgeInsets
                                                                .only(
                                                                top: 10),
                                                            child: Padding(
                                                              padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 24),
                                                              child: FaIcon(
                                                                isTenantExpanded
                                                                    ? FontAwesomeIcons
                                                                    .sortUp
                                                                    : FontAwesomeIcons
                                                                    .sortDown,
                                                                size: 20,
                                                                color: isTenantExpanded
                                                                    ? Color
                                                                    .fromARGB(
                                                                    255,
                                                                    35,
                                                                    67,
                                                                    126)
                                                                    : Color
                                                                    .fromRGBO(
                                                                    21,
                                                                    43,
                                                                    83,
                                                                    1),
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
                                                                        color: Colors
                                                                            .grey[
                                                                        600],
                                                                        fontWeight:
                                                                        FontWeight
                                                                            .w500,
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
                                                                        FontWeight
                                                                            .bold,
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
                                                  Container(
                                                    width: double.infinity,
                                                    // color: Colors.amber,
                                                    child: Padding(
                                                      padding:
                                                      const EdgeInsets.all(
                                                          16.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                        children: [
                                                          Column(
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              SingleChildScrollView(
                                                                scrollDirection:
                                                                Axis.horizontal,
                                                                child: Row(
                                                                  children: [
                                                                    SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .06),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        Text(
                                                                          'Total Amount',
                                                                          style:
                                                                          TextStyle(
                                                                            color:
                                                                            blueColor,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                            fontSize:
                                                                            16,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '${tenant.pdfDelinquentTenantsData!.totalDaysAmount ?? '-'}',
                                                                          style:
                                                                          TextStyle(
                                                                            color:
                                                                            Colors.grey[500],
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                            fontSize:
                                                                            16,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .04),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        Text(
                                                                          'Last 30 Days',
                                                                          style:
                                                                          TextStyle(
                                                                            color:
                                                                            blueColor,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                            fontSize:
                                                                            16,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '${tenant.pdfDelinquentTenantsData!.last30Days ?? '-'}',
                                                                          style:
                                                                          TextStyle(
                                                                            color:
                                                                            Colors.grey[500],
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                            fontSize:
                                                                            16,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .04),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        Text(
                                                                          'Last 31 to 60 days',
                                                                          style:
                                                                          TextStyle(
                                                                            color:
                                                                            blueColor,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                            fontSize:
                                                                            16,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '${tenant.pdfDelinquentTenantsData!.last31To60Days ?? '-'}',
                                                                          style:
                                                                          TextStyle(
                                                                            color:
                                                                            Colors.grey[500],
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                            fontSize:
                                                                            16,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .04),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        Text(
                                                                          'Last 61 to 90 Days',
                                                                          style:
                                                                          TextStyle(
                                                                            color:
                                                                            blueColor,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                            fontSize:
                                                                            16,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '${tenant.pdfDelinquentTenantsData!.last61To90Days ?? '-'}',
                                                                          style:
                                                                          TextStyle(
                                                                            color:
                                                                            Colors.grey[500],
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                            fontSize:
                                                                            16,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        width: MediaQuery.of(context).size.width *
                                                                            .04),
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      children: [
                                                                        Text(
                                                                          'Last 91+ Days',
                                                                          style:
                                                                          TextStyle(
                                                                            color:
                                                                            blueColor,
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                            fontSize:
                                                                            16,
                                                                          ),
                                                                        ),
                                                                        Text(
                                                                          '${tenant.pdfDelinquentTenantsData!.last91PlusDays ?? '-'}',
                                                                          style:
                                                                          TextStyle(
                                                                            color:
                                                                            Colors.grey[500],
                                                                            fontWeight:
                                                                            FontWeight.bold,
                                                                            fontSize:
                                                                            16,
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          }).toList(),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(width: 10),
                                  Material(
                                    elevation: 3,
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
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
                                          : blueColor,
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
                                          ? blueColor
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
                    ),
                  );
                },
              ),*/
          ],
        ),
      ),
    );
  }

  String _getDisplayValue(String? value) {
    // Return 'N/A' if the value is null or empty, otherwise return the value
    return (value == null || value.trim().isEmpty) ? 'N/A' : value;
  }

  TableRow _buildTableRow(String leftLabel, String leftValue, String rightLabel,
      String rightValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 4.0), // Space between label and value
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
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 4.0), // Space between label and value
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

  List<TableRow> _buildExpandableRows(
      int rowIndex, DelinquentTenantsData item) {
    return [
      TableRow(
        decoration: BoxDecoration(
          border: Border(
            left:  BorderSide(color: blueColor),
            right:  BorderSide(color: blueColor),
            top:  BorderSide(color: blueColor),
            bottom: item.tenants!.isEmpty
                ?  BorderSide(color: blueColor)
                : BorderSide.none,
          ),
        ),
        children: [
          _buildDataCell(item.rentalAddress ?? '-'),
          _buildDataCell(''),
          _buildDataCell(''),
          _buildDataCell(''),
          _buildDataCell(''),
        ],
      ),
      for (var tenantEntry in item.tenants!.asMap().entries)
        TableRow(
          decoration: BoxDecoration(
            border: Border(
              left:  BorderSide(color: blueColor),
              right:  BorderSide(color: blueColor),
              bottom: tenantEntry.key == item.tenants!.length - 1
                  ?  BorderSide(color: blueColor)
                  : BorderSide.none,
            ),
          ),
          children: [
            _buildDataCell('${item.tenants!.first.unitDetails ?? '-'}'),
            _buildDataCell('${tenantEntry.value.tenantName ?? '-'}'),
            _buildDataCell(
                '${tenantEntry.value.pdfDelinquentTenantsData!.last30Days ?? '-'}'),
            _buildDataCell(
                ' ${tenantEntry.value.pdfDelinquentTenantsData!.last30Days ?? '-'}\n'),
            _buildDataCell(
                ' ${tenantEntry.value.pdfDelinquentTenantsData!.last30Days ?? '-'}\n'),
          ],
        ),
    ];
  }
  filters({List<RentalOwnerReport>? data}){
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Padding (
          padding:
          const EdgeInsets.symmetric(horizontal: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  //width: 160,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedrenatalownerid,
                      padding:
                      EdgeInsets.symmetric(horizontal: 5),
                      hint: Text(
                        "Rental Owner",
                        style: TextStyle(fontSize: 14,color: Colors.black),
                      ),
                      items:  rentalowners.map((property) {
                        return DropdownMenuItem<String>(
                          value: property['rentalowner_id'],
                          child: Text(
                            property['rentalOwner_name']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedrenatalownerid = value;
                          _futureRentersInsurance = fetchDelinquentTenantsData(fromDate.text,toDate.text,rentalownerid: value);
                        });
                        // Handle the selected charge type
                        print(value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: daterange,
                      padding:
                      EdgeInsets.symmetric(horizontal: 5),
                      hint: Text(
                        "Date Range",
                        style: TextStyle(fontSize: 14,color: Colors.black),
                      ),
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'Today',
                          child: Text('Today'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'This Week',
                          child: Text('This Week'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'This Month',
                          child: Text('This Month'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'This Year',
                          child: Text('This Year'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Custom',
                          child: Text('Custom'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          daterange = value;
                          if (value == "Today") {
                            fromDate.text = formatDate(
                                DateTime.now().toString());
                            toDate.text = formatDate(
                                DateTime.now().toString());
                          } else if (value == "This Week") {
                            DateTime now = DateTime.now();
                            //  fromDate.text = formatDate(now.toString());

                            fromDate.text = formatDate(now
                                .subtract(Duration(
                                days: now.weekday - 1))
                                .toString());
                            toDate.text = formatDate(now
                                .add(Duration(
                                days: DateTime.daysPerWeek -
                                    now.weekday))
                                .toString());
                          } else if (value == "This Month") {
                            DateTime now = DateTime.now();
                            fromDate.text = formatDate(
                                DateTime(now.year, now.month, 1)
                                    .toString());
                            toDate.text = formatDate(DateTime(
                                now.year, now.month + 1, 0)
                                .toString());
                          } else if (value == "This Year") {
                            DateTime now = DateTime.now();
                            fromDate.text = formatDate(
                                DateTime(now.year, 1, 1)
                                    .toString());
                            toDate.text = formatDate(
                                DateTime(now.year, 12, 31)
                                    .toString());
                          } else if (value == "Custom") {
                            customdate = true;
                          }
                          if(value != "Custom" && customdate ==true){
                            customdate = false;
                            fromDate.text = "";
                            toDate.text = "";
                          }
                          if(value != "Custom") {
                            _futureRentersInsurance = fetchDelinquentTenantsData(fromDate.text,toDate.text);
                          }
                        });
                        // Handle the selected charge type
                        print(value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding (
          padding:
          const EdgeInsets.symmetric(horizontal: 0.0),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  // width: 110,
                  child: TextFormField(
                    controller: fromDate,
                    enabled: customdate,
                    onTap: () {
                      _pickDate(context);
                    },
                    readOnly: true,
                    style: TextStyle(fontSize: 14,color: Colors.black),
                    textInputAction: TextInputAction.next,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10), //Imp Line
                      isDense: true,

                      hintText: "From",

                      border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            width: 0.5,
                          )),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  // width: 110,
                  child: TextFormField(
                    controller: toDate,
                    enabled: customdate,
                    style: TextStyle(fontSize: 14,color: Colors.black),
                    onTap: () {
                      _endDate(context);
                    },
                    readOnly: true,
                    textInputAction: TextInputAction.next,
                    textAlignVertical: TextAlignVertical.center,
                    decoration: InputDecoration(
                      contentPadding:
                      const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10), //Imp Line
                      isDense: true,
                      hintText: "To",

                      border: OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(5),
                          borderSide: const BorderSide(
                            width: 0.5,
                          )),
                    ),
                  ),
                ),
              ),


              const SizedBox(width: 6),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Container(
                  height: 42,
                  // width: 170,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.grey)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: chargeType,
                      padding:
                      EdgeInsets.symmetric(horizontal: 5),
                      hint: Text(
                        "Charge type",
                        style: TextStyle(fontSize: 14,color: Colors.black),
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
                          value: 'Money Order',
                          child: Text('Money Order'),
                        ),
                        DropdownMenuItem<String>(
                          value: "Cashier's Check",
                          child: Text("Cashier's Check"),
                        ),
                        DropdownMenuItem<String>(
                          value: "All",
                          child: Text('All'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          chargeType = value;
                          _futureRentersInsurance = fetchDelinquentTenantsData(fromDate.text,toDate.text,charge: value);
                        });
                        // Handle the selected charge type
                        print(value);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
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
                        if (value == 'PDF' && data !=null ) {
                          print('pdf');
                          generateDelinquentTenantsPdf(data);
                        } else if (value == 'XLSX' && data !=null) {
                          print('XLSX');
                          generateRentalOwnerReportExcel(data);
                          //generateDelinquentTenantsExcel(data);
                        } else if (value == 'CSV' && data !=null) {
                          print('CSV');
                          generateRentalOwnerReportCsv(data);
                          //  generateDelinquentTenantsCsv(data);
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          istenantDataLoading
                              ? const Center(
                            child: SpinKitFadingCircle(
                              color: Colors.white,
                              size: 21.0,
                            ),
                          )
                              : Text('Export'),
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
      ],
    );
  }
}
