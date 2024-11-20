import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/DelinquentTenantsModel.dart';
import 'package:three_zero_two_property/Model/RentPastDueModel.dart';
import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:three_zero_two_property/provider/getAdminAddress.dart';
import 'package:three_zero_two_property/repository/DelinquentTenantsService.dart';
import 'package:three_zero_two_property/repository/GetAdminAddressPdf.dart';
import 'package:three_zero_two_property/repository/RentPastDue.dart';
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

import '../../../repository/rentalownerreport.dart';
import '../../../widgets/custom_drawer.dart';

class RentPastDueReports extends StatefulWidget {
  const RentPastDueReports({super.key});

  @override
  State<RentPastDueReports> createState() => _RentPastDueReportsState();
}

class _RentPastDueReportsState extends State<RentPastDueReports> {
  late Future<RentPastDue> futurePastRentDue;
  List<RentPastDue> DelinquentTenantsModel = [];
  bool isLoading = true;
  String? errorMessage;
  int? expandedRowIndex;
  Map<int, int?> expandedTenantIndex = {};
  ConnectivityResult? _connectivityResult;
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
    fetchRentalOwners();
    // fetchpdfrentalowner(); // this for pdf
    fetchReport();
    futurePastRentDue =
        AdminBalanceRepository().fetchAdminBalance(report: true);
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  fetchReport() async {
    setState(() {
      daterange = "Today";
      fromDate.text = formatDate(DateTime.now().toString());
      toDate.text = formatDate(DateTime.now().toString());
    });
    DateTime time = DateTime.now();
    DateTime date = DateFormat('yyyy-MM-dd').parse(time.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    futurePastRentDue = fetchRentPastDueData(report: true);
  }

  Future<RentPastDue> fetchRentPastDueData(
      {String? adminid, bool report = false}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');

      RentPastDue data =
          await AdminBalanceRepository().fetchAdminBalance(report: true);

      setState(() {
        //DelinquentTenantsModel = data;
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
      return RentPastDue();
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
            color: _currentPage == 0 ? Colors.grey : blueColor,
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
                : blueColor, // Change color based on availability
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
      RentPastDue? delinquentTenantsData) async {
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
                data: _generateTableData(
                    delinquentTenantsData as List<RentPastDue>),
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

  List<List<dynamic>> _generateTableData(List<RentPastDue> rentalOwnerReports) {
    final List<List<dynamic>> tableData = [];
    double total = 0.0;

    for (var owner in rentalOwnerReports) {
      // Main row for the rental owner name
      tableData.add([
        pw.Text(
            owner.currentDueRentCharges?.charges?.first.rentalData?.address ??
                "",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        pw.Text(
            owner.currentDueRentCharges?.charges?.first.rentalData?.address ??
                "",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
        pw.Text(
            owner.currentDueRentCharges?.charges?.first.rentalData?.address ??
                "",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
      ]);
    }

    setState(() {
      grandtotal = total;
    });

    return tableData;
  }

  // Future<void> generateRentalOwnerReportExcel(
  //     List<RentPastDue> rentalOwnerReports) async {
  //   final syncXlsx.Workbook workbook = syncXlsx.Workbook();
  //   final syncXlsx.Worksheet sheet = workbook.worksheets[0];
  //
  //   sheet.getRangeByName('A1:I1').columnWidth = 20;
  //
  //   final List<String> headers = [
  //     'Property',
  //     'Tenant',
  //     'Date',
  //     'Pmt Type',
  //     'Txn ID',
  //     'Reference',
  //     'Crd Type',
  //     'Crd No',
  //     'Total',
  //   ];
  //
  //   final syncXlsx.Style headerCellStyle =
  //   workbook.styles.add('headerCellStyle');
  //   headerCellStyle.bold = true;
  //   headerCellStyle.backColor = '#5A86D5';
  //   headerCellStyle.fontColor = '#FFFFFF';
  //   headerCellStyle.fontSize = 16;
  //   headerCellStyle.hAlign = syncXlsx.HAlignType.center;
  //
  //   final syncXlsx.Style currencyCellStyle =
  //   workbook.styles.add('currencyCellStyle');
  //   currencyCellStyle.numberFormat = '\$#,##0.00'; // Currency format
  //   currencyCellStyle.hAlign = syncXlsx.HAlignType.right; // Right-align amounts
  //
  //   final syncXlsx.Style boldAmountStyle =
  //   workbook.styles.add('boldAmountStyle');
  //   boldAmountStyle.bold = true;
  //   boldAmountStyle.numberFormat = '\$#,##0.00';
  //   boldAmountStyle.hAlign = syncXlsx.HAlignType.right;
  //   final syncXlsx.Style AmountTitleStyle =
  //   workbook.styles.add('AmountTitleStyle');
  //   boldAmountStyle.bold = true;
  //   boldAmountStyle.numberFormat = '\$#,##0.00';
  //
  //   for (int i = 0; i < headers.length; i++) {
  //     final cell = sheet.getRangeByIndex(1, i + 1);
  //     cell.setText(headers[i]);
  //     cell.cellStyle = headerCellStyle;
  //   }
  //
  //   int rowIndex = 2;
  //   double grandTotal = 0.0;
  //
  //   for (var owner in rentalOwnerReports) {
  //     final rentalOwnerCell = sheet.getRangeByIndex(rowIndex, 1);
  //     rentalOwnerCell.setText(owner.rentalOwnerName ?? '');
  //     rentalOwnerCell.cellStyle.bold = true;
  //     sheet.getRangeByName('A$rowIndex:I$rowIndex').merge();
  //     rowIndex++;
  //
  //     for (var property in owner.payments) {
  //       sheet
  //           .getRangeByIndex(rowIndex, 1)
  //           .setText(property.rentalData.rentalAddress ?? 'N/A');
  //       sheet.getRangeByIndex(rowIndex, 2).setText(
  //           '${property.tenantData.tenantFirstName ?? 'N/A'} ${property.tenantData.tenantLastName ?? 'N/A'}');
  //       sheet
  //           .getRangeByIndex(rowIndex, 3)
  //           .setText(property.createdAt.toString());
  //       sheet.getRangeByIndex(rowIndex, 4).setText(property.paymentType ?? '');
  //       sheet
  //           .getRangeByIndex(rowIndex, 5)
  //           .setText(property.transactionId ?? '');
  //       sheet.getRangeByIndex(rowIndex, 6).setText(property.paymentId ?? '');
  //       sheet.getRangeByIndex(rowIndex, 7).setText(property.ccType ?? '');
  //       sheet.getRangeByIndex(rowIndex, 8).setText(property.ccNumber ?? '');
  //       sheet
  //           .getRangeByIndex(rowIndex, 9)
  //           .setNumber(property.totalAmount ?? 0.0);
  //       sheet.getRangeByIndex(rowIndex, 9).cellStyle = currencyCellStyle;
  //       rowIndex++;
  //
  //       for (var payment in property.entry) {
  //         sheet.getRangeByIndex(rowIndex, 1).setText(payment.account ?? 'N/A');
  //         sheet.getRangeByIndex(rowIndex, 9).setNumber(payment.amount);
  //         sheet.getRangeByIndex(rowIndex, 9).cellStyle = currencyCellStyle;
  //         rowIndex++;
  //       }
  //
  //       // if (property.surcharge != 0.0) {
  //       //   sheet.getRangeByIndex(rowIndex, 1).setText('Surcharge');
  //       //   sheet.getRangeByIndex(rowIndex, 9).setNumber(property.surcharge);
  //       //   sheet.getRangeByIndex(rowIndex, 9).cellStyle = currencyCellStyle;
  //       //   rowIndex++;
  //       // }
  //     }
  //
  //     sheet
  //         .getRangeByIndex(rowIndex, 1)
  //         .setText('Subtotal - ${owner.rentalOwnerName}');
  //     sheet.getRangeByIndex(rowIndex, 1).cellStyle.bold = true;
  //     sheet.getRangeByIndex(rowIndex, 9).setNumber(owner.subTotal ?? 0.0);
  //     sheet.getRangeByIndex(rowIndex, 9).cellStyle = boldAmountStyle;
  //     sheet.getRangeByName('A$rowIndex:H$rowIndex').merge();
  //     rowIndex++;
  //
  //     grandTotal += owner.subTotal ?? 0.0;
  //   }
  //
  //   sheet.getRangeByIndex(rowIndex, 1).setText('Grand Total');
  //   sheet.getRangeByIndex(rowIndex, 1).cellStyle.bold = true;
  //   sheet.getRangeByIndex(rowIndex, 9).setNumber(grandTotal);
  //   sheet.getRangeByIndex(rowIndex, 9).cellStyle = boldAmountStyle;
  //   sheet.getRangeByName('A$rowIndex:H$rowIndex').merge();
  //
  //   final List<int> bytes = workbook.saveAsStream();
  //   workbook.dispose();
  //
  //   final DateTime now = DateTime.now();
  //   final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
  //   final String fileName = 'RentalOwnerReport_$formattedDate.xlsx';
  //
  //   final Directory directory = Platform.isIOS
  //       ? await getApplicationDocumentsDirectory()
  //       : Directory('/storage/emulated/0/Download');
  //
  //   final path = '${directory.path}/$fileName';
  //
  //   // Create directory if it doesn't exist (for Android)
  //   if (!await directory.exists() && !Platform.isIOS) {
  //     await directory.create(recursive: true);
  //   }
  //
  //   final File file = File(path);
  //   await file.writeAsBytes(bytes, flush: true);
  //   Fluttertoast.showToast(
  //     msg: 'Excel file saved to $path',
  //   );
  // }
  //
  // Future<void> generateRentalOwnerReportCsv(
  //     List<RentPastDue> rentalOwnerReports) async {
  //   // Define headers for CSV
  //   final List<String> headers = [
  //     'Property',
  //     'Tenant',
  //     'Date',
  //     'Pmt Type',
  //     'Txn ID',
  //     'Reference',
  //     'Crd Type',
  //     'Crd No',
  //     'Total',
  //   ];
  //
  //   // Create a buffer to store CSV data
  //   final StringBuffer csvBuffer = StringBuffer();
  //
  //   // Add headers to the CSV file
  //   csvBuffer.writeln(headers.join(','));
  //
  //   double grandTotal = 0.0;
  //
  //   // Iterate through each rental owner report
  //   for (var owner in rentalOwnerReports) {
  //     // Add rental owner name as a row
  //     csvBuffer.writeln('${owner.rentalOwnerName ?? ''}');
  //
  //     // Iterate through each property for the current rental owner
  //     for (var property in owner.payments) {
  //       // Replace commas in the rental address with spaces
  //       final String sanitizedAddress =
  //       (property.rentalData.rentalAddress ?? 'N/A').replaceAll(',', ' ');
  //
  //       // Add property and tenant details
  //       csvBuffer.writeln([
  //         sanitizedAddress,
  //         '${property.tenantData.tenantFirstName ?? 'N/A'} ${property.tenantData.tenantLastName ?? 'N/A'}',
  //         property.createdAt.toString(),
  //         property.paymentType ?? '',
  //         property.transactionId ?? '',
  //         property.paymentId ?? '',
  //         property.ccType ?? '',
  //         property.ccNumber ?? '',
  //         '\$${property.totalAmount?.toStringAsFixed(2) ?? '0.00'}'
  //       ].join(','));
  //
  //       // Iterate through payment entries for the current property
  //       for (var payment in property.entry) {
  //         csvBuffer.writeln([
  //           payment.account ?? 'N/A',
  //           '',
  //           '',
  //           '',
  //           '',
  //           '',
  //           '',
  //           '',
  //           '\$${payment.amount.toStringAsFixed(2)}'
  //         ].join(','));
  //       }
  //
  //       // Add surcharge row if applicable
  //       // if (property.surcharge != 0.0) {
  //       //   csvBuffer.writeln([
  //       //     'Surcharge',
  //       //     '',
  //       //     '',
  //       //     '',
  //       //     '',
  //       //     '',
  //       //     '',
  //       //     '',
  //       //     '\$${property.surcharge.toStringAsFixed(2)}'
  //       //   ].join(','));
  //       // }
  //     }
  //
  //     // Add subtotal row for the current rental owner
  //     csvBuffer.writeln([
  //       'Subtotal - ${owner.rentalOwnerName}',
  //       '',
  //       '',
  //       '',
  //       '',
  //       '',
  //       '',
  //       '',
  //       '\$${(owner.subTotal ?? 0.0).toStringAsFixed(2)}'
  //     ].join(','));
  //
  //     // Accumulate grand total
  //     grandTotal += owner.subTotal ?? 0.0;
  //   }
  //
  //   // Add grand total row at the end
  //   csvBuffer.writeln([
  //     'Grand Total',
  //     '',
  //     '',
  //     '',
  //     '',
  //     '',
  //     '',
  //     '',
  //     '\$${grandTotal.toStringAsFixed(2)}'
  //   ].join(','));
  //
  //   // Convert buffer to list of bytes for CSV file
  //   final List<int> bytes = utf8.encode(csvBuffer.toString());
  //
  //   // Define file name with current date and time
  //   final DateTime now = DateTime.now();
  //   final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
  //   final String fileName = 'RentalOwnerReport_$formattedDate.csv';
  //
  //   // Define file path
  //   final Directory directory = Platform.isIOS
  //       ? await getApplicationDocumentsDirectory()
  //       : Directory('/storage/emulated/0/Download');
  //
  //   final path = '${directory.path}/$fileName';
  //
  //   // Create directory if it doesn't exist (for Android)
  //   if (!await directory.exists() && !Platform.isIOS) {
  //     await directory.create(recursive: true);
  //   }
  //
  //   // Write CSV file to the path
  //   final File file = File(path);
  //   await file.writeAsBytes(bytes, flush: true);
  //
  //   // Show success toast message
  //   Fluttertoast.showToast(
  //     msg: 'CSV file saved to $path',
  //   );
  // }

  // Future<void> _pickDate(BuildContext context) async {
  //   DateTime? _selectedDate;
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //     builder: (BuildContext context, Widget? child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           primaryColor: blueColor,
  //           colorScheme: ColorScheme.light(
  //             primary: blueColor,
  //           ),
  //           buttonTheme: ButtonThemeData(
  //             textTheme: ButtonTextTheme.primary,
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _selectedDate = picked;
  //
  //       fromDate.text = DateFormat('yyyy-MM-dd')
  //           .parse(picked.toString())
  //           .toString()
  //           .split(" ")[0];
  //       fromDate.text = formatDate(fromDate.text);
  //       _futureRentersInsurance =
  //           fetchDelinquentTenantsData(fromDate.text, toDate.text);
  //     });
  //
  //     // Notify the FormField state of the change
  //   }
  // }
  //
  // Future<void> _endDate(BuildContext context) async {
  //   DateTime? _selectedDate;
  //   DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: _selectedDate ?? DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2101),
  //     builder: (BuildContext context, Widget? child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           primaryColor: blueColor,
  //           colorScheme: ColorScheme.light(
  //             primary: blueColor,
  //           ),
  //           buttonTheme: ButtonThemeData(
  //             textTheme: ButtonTextTheme.primary,
  //           ),
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null) {
  //     setState(() {
  //       _selectedDate = picked;
  //
  //       toDate.text = DateFormat('yyyy-MM-dd')
  //           .parse(picked.toString())
  //           .toString()
  //           .split(" ")[0];
  //       toDate.text = formatDate(toDate.text);
  //       _futureRentersInsurance =
  //           fetchDelinquentTenantsData(fromDate.text, toDate.text);
  //     });
  //
  //     // Notify the FormField state of the change
  //   }
  // }

  List<Map<String, dynamic>> rentalowners = [];
  Future<void> fetchRentalOwners() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http
        .get(Uri.parse('${Api_url}/api/rentals/rental-owners/$id'), headers: {
      "authorization": "CRM $token",
      "id": "CRM $id",
    });
    final jsonData = json.decode(response.body);
    print(jsonData);
    if (response.statusCode == 200) {
      setState(() {
        rentalowners = (jsonDecode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)!
            .toList();
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
  String? monthType;
  String? selectedrenatalownerid;
  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
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
                    title: 'Rental Owner Report',
                    width: MediaQuery.of(context).size.width * .91,
                  ),
                  if (MediaQuery.of(context).size.width > 500)
                    const SizedBox(height: 16),
                  if (MediaQuery.of(context).size.width < 500)
                    FutureBuilder<RentPastDue>(
                      future: futurePastRentDue,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else if (snapshot.hasData) {
                          print(
                              'snap data ${snapshot.data!.dueRentCharges!.charges!.length}');
                          var rentPastDue = snapshot.data!;


                          return SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 5),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  filters(data: rentPastDue),
                                  const SizedBox(height: 10),
//call the table here base on condition like if selected is charge and and monttype is All call the chrge table
                                  const SizedBox(height: 20),
                                  if (chargeType == 'Charges' &&
                                      monthType == 'All' || chargeType == 'Charges' && monthType == null)
                                    chargeTable(snapshot
                                        .data!.dueRentCharges!.charges!)
                                    // chargeTable(
                                    //     snapshot.data!.dueRentCharges!.charges!)
                                  else if (chargeType == 'Charges' &&
                                      monthType == 'Current Month')
                                    chargeTable(snapshot
                                        .data!.currentDueRentCharges!.charges!)
                                  else if (chargeType == 'Charges' &&
                                      monthType == 'Last Month')
                                    chargeTable(snapshot
                                        .data!.lastDueRentCharges!.charges!)
                                  else if(chargeType == "Payment" && monthType =="Current Month")
                                    paymentTable(snapshot.data!.currentPayments!.payments!)

                                      else if(chargeType == "Payment" && monthType =="Last Month")
                                          paymentTable(snapshot.data!.lastPayments!.payments!)
                                ],
                              ),
                            ),
                          );
                        } else {
                          return Text('No data available');
                        }
                      },
                    ),


                ],
              ),
            )
          : SizedBox(
              width: double.infinity,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/no_internet.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.fill,
                  ),
                  Text(
                    'No Internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
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
            left: BorderSide(color: blueColor),
            right: BorderSide(color: blueColor),
            top: BorderSide(color: blueColor),
            bottom: item.tenants!.isEmpty
                ? BorderSide(color: blueColor)
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
              left: BorderSide(color: blueColor),
              right: BorderSide(color: blueColor),
              bottom: tenantEntry.key == item.tenants!.length - 1
                  ? BorderSide(color: blueColor)
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

  chargeTable(List<Charge> chargedata) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5),
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            //filters(data: rentPastDue),
            const SizedBox(height: 10),
            _buildHeaders(),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Color.fromRGBO(152, 162, 179, .5))),
              child: Column(
                children: chargedata.asMap().entries.map((entry) {
                  int rowIndex = entry.key;
                  Charge item = entry.value;
                  bool isRowExpanded = expandedRowIndex == rowIndex;

                  print(item.rentalData.toString());
                  //show the charge data
                  //  Charge rental = entry.value;
                  //for the payment data
                  // Payment rental = entry.value;
                  return Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(color: blueColor),
                    // ),
                    decoration: BoxDecoration(
                      color: rowIndex % 2 != 0
                          ? Colors.white
                          : blueColor.withOpacity(0.09),
                      border:
                          Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
                    ),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
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
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    padding: !isRowExpanded
                                        ? const EdgeInsets.only(bottom: 10)
                                        : const EdgeInsets.only(top: 10),
                                    child: FaIcon(
                                      isRowExpanded
                                          ? FontAwesomeIcons.sortUp
                                          : FontAwesomeIcons.sortDown,
                                      size: 20,
                                      color:
                                          isRowExpanded ? blueColor : blueColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (expandedRowIndex == rowIndex) {
                                          expandedRowIndex = null;
                                        } else {
                                          expandedRowIndex = rowIndex;
                                        }
                                      });
                                    },
                                    child: Text(
                                      '${item.rentalData != null ? item.rentalData!.address:"N/A" ?? '-'} ',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                // SizedBox(
                                //     width:
                                //     MediaQuery.of(context)
                                //         .size
                                //         .width *
                                //         .3),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    '${ item.tenantData != null ?  item.tenantData!.tenantfirstName : "N/A" ?? '-'} ${ item.tenantData != null ?  item.tenantData!.tenantlastName : "N/A" ?? '-'}',
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    '${item.total.toString() ?? '-'}',
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

                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            /* Row(
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
                                  ),*/
          ],
        ),
      ),
    );
  }
  paymentTable(List<Payment> chargedata) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 5),
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            //filters(data: rentPastDue),
            const SizedBox(height: 10),
            _buildHeaders(),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                  border: Border.all(color: Color.fromRGBO(152, 162, 179, .5))),
              child: Column(
                children: chargedata.asMap().entries.map((entry) {
                  int rowIndex = entry.key;
                  Payment item = entry.value;
                  bool isRowExpanded = expandedRowIndex == rowIndex;

                  print(item.rentalData.toString());
                  //show the charge data
                  //  Charge rental = entry.value;
                  //for the payment data
                  // Payment rental = entry.value;
                  return Container(
                    // decoration: BoxDecoration(
                    //   border: Border.all(color: blueColor),
                    // ),
                    decoration: BoxDecoration(
                      color: rowIndex % 2 != 0
                          ? Colors.white
                          : blueColor.withOpacity(0.09),
                      border:
                      Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
                    ),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                GestureDetector(
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
                                    margin: const EdgeInsets.only(
                                        left: 5, right: 5),
                                    padding: !isRowExpanded
                                        ? const EdgeInsets.only(bottom: 10)
                                        : const EdgeInsets.only(top: 10),
                                    child: FaIcon(
                                      isRowExpanded
                                          ? FontAwesomeIcons.sortUp
                                          : FontAwesomeIcons.sortDown,
                                      size: 20,
                                      color:
                                      isRowExpanded ? blueColor : blueColor,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (expandedRowIndex == rowIndex) {
                                          expandedRowIndex = null;
                                        } else {
                                          expandedRowIndex = rowIndex;
                                        }
                                      });
                                    },
                                    child: Text(
                                      '${item.rentalData != null ? item.rentalData!.address:"N/A" ?? '-'} ',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                // SizedBox(
                                //     width:
                                //     MediaQuery.of(context)
                                //         .size
                                //         .width *
                                //         .3),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    '${ item.tenantData != null ?  item.tenantData!.tenantfirstName : "N/A" ?? '-'} ${ item.tenantData != null ?  item.tenantData!.tenantlastName : "N/A" ?? '-'}',
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    '${item.total.toString() ?? '-'}',
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

                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            /* Row(
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
                                  ),*/
          ],
        ),
      ),
    );
  }

  filters({RentPastDue? data}) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 0.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Expanded(
        //         child: Container(
        //           height: 42,
        //           //width: 160,
        //           decoration: BoxDecoration(
        //               borderRadius: BorderRadius.circular(5),
        //               border: Border.all(color: Colors.grey)),
        //           child: DropdownButtonHideUnderline(
        //             child: DropdownButton<String>(
        //               value: selectedrenatalownerid,
        //               padding: EdgeInsets.symmetric(horizontal: 5),
        //               hint: Text(
        //                 "Rental Owner",
        //                 style: TextStyle(fontSize: 14, color: Colors.black),
        //               ),
        //               items: rentalowners.map((property) {
        //                 return DropdownMenuItem<String>(
        //                   value: property['rentalowner_id'],
        //                   child: Container(
        //                     width: MediaQuery.of(context).size.width * .34,
        //                     child: Text(
        //                       property['rentalOwner_name']!,
        //                       style: const TextStyle(
        //                         fontSize: 14,
        //                         fontWeight: FontWeight.w400,
        //                         color: Colors.black87,
        //                       ),
        //                       overflow: TextOverflow.ellipsis,
        //                     ),
        //                   ),
        //                 );
        //               }).toList(),
        //               onChanged: (value) {
        //                 setState(() {
        //                   selectedrenatalownerid = value;
        //                   futurePastRentDue =
        //                       fetchRentPastDueData(report: true);
        //                 });
        //                 // Handle the selected charge type
        //                 print(value);
        //               },
        //             ),
        //           ),
        //         ),
        //       ),
        //       const SizedBox(width: 6),
        //       // Expanded(
        //       //   child: Container(
        //       //     height: 42,
        //       //     decoration: BoxDecoration(
        //       //         borderRadius: BorderRadius.circular(5),
        //       //         border: Border.all(color: Colors.grey)),
        //       //     child: DropdownButtonHideUnderline(
        //       //       child: DropdownButton<String>(
        //       //         value: daterange,
        //       //         padding: EdgeInsets.symmetric(horizontal: 5),
        //       //         hint: Text(
        //       //           "Date Range",
        //       //           style: TextStyle(fontSize: 14, color: Colors.black),
        //       //         ),
        //       //         items: const [
        //       //           DropdownMenuItem<String>(
        //       //             value: 'Today',
        //       //             child: Text('Today'),
        //       //           ),
        //       //           DropdownMenuItem<String>(
        //       //             value: 'This Week',
        //       //             child: Text('This Week'),
        //       //           ),
        //       //           DropdownMenuItem<String>(
        //       //             value: 'This Month',
        //       //             child: Text('This Month'),
        //       //           ),
        //       //           DropdownMenuItem<String>(
        //       //             value: 'This Year',
        //       //             child: Text('This Year'),
        //       //           ),
        //       //           DropdownMenuItem<String>(
        //       //             value: 'Custom',
        //       //             child: Text('Custom'),
        //       //           ),
        //       //         ],
        //       //         onChanged: (value) {
        //       //           setState(() async {
        //       //             daterange = value;
        //       //             if (value == "Today") {
        //       //               customdate = false;
        //       //               fromDate.text =
        //       //                   formatDate(DateTime.now().toString());
        //       //               toDate.text = formatDate(DateTime.now().toString());
        //       //             } else if (value == "This Week") {
        //       //               DateTime now = DateTime.now();
        //       //               //  fromDate.text = formatDate(now.toString());
        //       //               customdate = false;
        //       //               fromDate.text = formatDate(now
        //       //                   .subtract(Duration(days: now.weekday - 1))
        //       //                   .toString());
        //       //               toDate.text = formatDate(now
        //       //                   .add(Duration(
        //       //                   days: DateTime.daysPerWeek - now.weekday))
        //       //                   .toString());
        //       //             } else if (value == "This Month") {
        //       //               customdate = false;
        //       //               DateTime now = DateTime.now();
        //       //               fromDate.text = formatDate(
        //       //                   DateTime(now.year, now.month, 1).toString());
        //       //               toDate.text = formatDate(
        //       //                   DateTime(now.year, now.month + 1, 0)
        //       //                       .toString());
        //       //             } else if (value == "This Year") {
        //       //               customdate = false;
        //       //               DateTime now = DateTime.now();
        //       //               fromDate.text =
        //       //                   formatDate(DateTime(now.year, 1, 1).toString());
        //       //               toDate.text = formatDate(
        //       //                   DateTime(now.year, 12, 31).toString());
        //       //             } else if (value == "Custom") {
        //       //               customdate = true;
        //       //             }
        //       //             if (value != "Custom" && customdate == true) {
        //       //               customdate = false;
        //       //               fromDate.text = "";
        //       //               toDate.text = "";
        //       //             }
        //       //             if (value != "Custom") {
        //       //               SharedPreferences prefs = await SharedPreferences.getInstance();
        //       //               String? id = prefs.getString("adminId");
        //       //               String? token = prefs.getString('token');
        //       //               futurePastRentDue =
        //       //               fetchRentPastDueData(adminid:id ,report: true);
        //       //
        //       //             }
        //       //           });
        //       //           // Handle the selected charge type
        //       //           print(value);
        //       //         },
        //       //       ),
        //       //     ),
        //       //   ),
        //       // ),
        //       const SizedBox(width: 6),
        //     ],
        //   ),
        // ),
        // const SizedBox(height: 10),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 0.0),
        //   child: Row(
        //     //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //     children: [
        //       Expanded(
        //         child: Container(
        //           // width: 110,
        //           child: TextFormField(
        //             controller: fromDate,
        //             // enabled: customdate,
        //             onTap: customdate
        //                 ? () {
        //                     // _pickDate(context);
        //                   }
        //                 : null,
        //             readOnly: true,
        //             style: TextStyle(fontSize: 14, color: Colors.black),
        //             textInputAction: TextInputAction.next,
        //             textAlignVertical: TextAlignVertical.center,
        //             decoration: InputDecoration(
        //               contentPadding: const EdgeInsets.symmetric(
        //                   vertical: 10, horizontal: 10), //Imp Line
        //               isDense: true,
        //
        //               hintText: "From",
        //
        //               border: OutlineInputBorder(
        //                   borderRadius: BorderRadius.circular(5),
        //                   borderSide: const BorderSide(
        //                     width: 1,
        //                   )),
        //             ),
        //           ),
        //         ),
        //       ),
        //       SizedBox(width: 10),
        //       Expanded(
        //         child: Container(
        //           // width: 110,
        //           child: TextFormField(
        //             controller: toDate,
        //             // enabled: customdate,
        //             style: TextStyle(fontSize: 14, color: Colors.black),
        //             onTap: customdate
        //                 ? () {
        //                     // _endDate(context);
        //                   }
        //                 : null,
        //             readOnly: true,
        //             textInputAction: TextInputAction.next,
        //             textAlignVertical: TextAlignVertical.center,
        //             decoration: InputDecoration(
        //               contentPadding: const EdgeInsets.symmetric(
        //                   vertical: 10, horizontal: 10), //Imp Line
        //               isDense: true,
        //               hintText: "To",
        //
        //               border: OutlineInputBorder(
        //                   borderRadius: BorderRadius.circular(5),
        //                   borderSide: const BorderSide(
        //                     width: 0.5,
        //                   )),
        //             ),
        //           ),
        //         ),
        //       ),
        //       const SizedBox(width: 6),
        //     ],
        //   ),
        // ),
        // const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
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
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      hint: Text(
                        "Charge type",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'Charges',
                          child: Text('Charges'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Payment',
                          child: Text('Payment'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          chargeType = value;
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
                        if (value == 'PDF' && data != null) {
                          print('pdf');
                          generateDelinquentTenantsPdf(data);
                        } else if (value == 'XLSX' && data != null) {
                          print('XLSX');
                          //generateRentalOwnerReportExcel(data);
                          //generateDelinquentTenantsExcel(data);
                        } else if (value == 'CSV' && data != null) {
                          print('CSV');
                          //  generateRentalOwnerReportCsv(data);
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0.0),
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
                      value: monthType,
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      hint: Text(
                        "Select Month",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'All',
                          child: Text('All'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Current Month',
                          child: Text('Current Month'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'Last Month',
                          child: Text('Last Month'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          monthType = value;
                        });
                        // Handle the selected charge type
                        print(value);
                      },
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
}
