import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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

class DelinquentTenants extends StatefulWidget {
  @override
  State<DelinquentTenants> createState() => _DelinquentTenantsState();
}

class _DelinquentTenantsState extends State<DelinquentTenants> {
  late Future<List<DelinquentTenantsData>> _futureRentersInsurance;
  List<DelinquentTenantsData> DelinquentTenantsModel = [];
  bool isLoading = true;
  String? errorMessage;
  int? expandedRowIndex;
  Map<int, int?> expandedTenantIndex = {};

  @override
  void initState() {
    super.initState();
    _futureRentersInsurance = fetchDelinquentTenantsData();
  }

  Future<List<DelinquentTenantsData>> fetchDelinquentTenantsData() async {
    try {
      List<DelinquentTenantsData> data =
          await DelinquentTenantsSerivce().fetchDelinquentTenants();
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

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(DelinquentTenantsData d)? getField) {
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
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: Row(
                    children: [
                      width < 400
                          ? const Text("Leases",
                              style: TextStyle(color: Colors.white))
                          : const Text("Leases",
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
            //   child: InkWell(
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
            //   child: InkWell(
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

  Future<void> generateDelinquentTenantsPdf(
      List<DelinquentTenantsData> delinquentTenantsData) async {
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
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(image, width: 50, height: 50),
                  pw.SizedBox(width: 50),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Delinquent Tenants',
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
            ),
            pw.Table.fromTextArray(
              headers: [
                'Unit',
                'Tenant',
                'Total',
                '0-30 days',
                '31-60 days',
                '61-90 days',
                '91+ days',
              ],
              data: _generateTableData(delinquentTenantsData),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellStyle: pw.TextStyle(fontSize: 10),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  List<List<String>> _generateTableData(
      List<DelinquentTenantsData> delinquentTenantsData) {
    final List<List<String>> tableData = [];

    for (var item in delinquentTenantsData) {
      tableData.add([
        item.rentalAddress ?? '',
        '',
        '',
        '',
        '',
        '',
        '',
      ]);
      for (var tenant in item.tenants!) {
        tableData.add([
          '${tenant.unitDetails}',
          tenant.tenantName ?? '',
          '\$${tenant.pdfDelinquentTenantsData!.totalDaysAmount}',
          '\$${tenant.pdfDelinquentTenantsData!.last30Days}',
          '\$${tenant.pdfDelinquentTenantsData!.last31To60Days}',
          '\$${tenant.pdfDelinquentTenantsData!.last61To90Days}',
          '\$${tenant.pdfDelinquentTenantsData!.last91PlusDays}',
        ]);
      }
      tableData.add([
        'Total ',
        '',
        '\$${item.alltotalamount!.totalDaysAmount}',
        '\$${item.alltotalamount!.last30Days}',
        '\$${item.alltotalamount!.last31To60Days}',
        '\$${item.alltotalamount!.last61To90Days}',
        '\$${item.alltotalamount!.last91PlusDays}',
      ]);
    }
    tableData.add([
      'Grand Total of all Properties',
      '',
      '\$${globalDelinquentTenantsData!.totalDaysAmount}',
      '\$${globalDelinquentTenantsData!.last30Days}',
      '\$${globalDelinquentTenantsData!.last31To60Days}',
      '\$${globalDelinquentTenantsData!.last61To90Days}',
      '\$${globalDelinquentTenantsData!.last91PlusDays}',
    ]);

    return tableData;
  }

  Future<void> generateDelinquentTenantsExcel(
      List<DelinquentTenantsData> delinquentTenantsData) async {
    // Fetch grand total data
    setState(() {
      istenantDataLoading = true;
    });

    final globalDelinquentTenantsData =
        await fetchDelinquentTenantsGrandTotal();

    setState(() {
      istenantDataLoading = false;
    });

    // Create a new workbook
    final syncXlsx.Workbook workbook = syncXlsx.Workbook();
    final syncXlsx.Worksheet sheet = workbook.worksheets[0];

    // Set column widths
    sheet.getRangeByName('A1:G1').columnWidth = 25;

    // Define headers
    final List<String> headers = [
      'Unit',
      'Tenant',
      'Total',
      '0-30 days',
      '31-60 days',
      '61-90 days',
      '91+ days',
    ];

    // Style for headers
    final syncXlsx.Style headerCellStyle =
        workbook.styles.add('headerCellStyle');
    headerCellStyle.bold = true;
    headerCellStyle.backColor = '#D3D3D3';
    headerCellStyle.hAlign = syncXlsx.HAlignType.center;

    // Add headers to the first row
    for (int i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(1, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle = headerCellStyle;
    }

    int rowIndex = 2; // Start from the second row
    for (var item in delinquentTenantsData) {
      // Add main row with rental address
      sheet.getRangeByIndex(rowIndex, 1).setText(item.rentalAddress ?? '');
      for (int col = 2; col <= 7; col++) {
        sheet.getRangeByIndex(rowIndex, col).setText('');
      }

      rowIndex++; // Move to the next row for tenant details

      // Add tenant details in subsequent rows
      for (var tenant in item.tenants!) {
        sheet.getRangeByIndex(rowIndex, 1).setText(tenant.unitDetails ?? '');
        sheet.getRangeByIndex(rowIndex, 2).setText(tenant.tenantName ?? '');
        sheet
            .getRangeByIndex(rowIndex, 3)
            .setText('\$${tenant.pdfDelinquentTenantsData!.totalDaysAmount}');
        sheet
            .getRangeByIndex(rowIndex, 4)
            .setText('\$${tenant.pdfDelinquentTenantsData!.last30Days}');
        sheet
            .getRangeByIndex(rowIndex, 5)
            .setText('\$${tenant.pdfDelinquentTenantsData!.last31To60Days}');
        sheet
            .getRangeByIndex(rowIndex, 6)
            .setText('\$${tenant.pdfDelinquentTenantsData!.last61To90Days}');
        sheet
            .getRangeByIndex(rowIndex, 7)
            .setText('\$${tenant.pdfDelinquentTenantsData!.last91PlusDays}');
        rowIndex++; // Move to the next row
      }

      // Add totals row
      sheet.getRangeByIndex(rowIndex, 1).setText('Total');
      sheet.getRangeByIndex(rowIndex, 2).setText('');
      sheet
          .getRangeByIndex(rowIndex, 3)
          .setText('\$${item.alltotalamount!.totalDaysAmount}');
      sheet
          .getRangeByIndex(rowIndex, 4)
          .setText('\$${item.alltotalamount!.last30Days}');
      sheet
          .getRangeByIndex(rowIndex, 5)
          .setText('\$${item.alltotalamount!.last31To60Days}');
      sheet
          .getRangeByIndex(rowIndex, 6)
          .setText('\$${item.alltotalamount!.last61To90Days}');
      sheet
          .getRangeByIndex(rowIndex, 7)
          .setText('\$${item.alltotalamount!.last91PlusDays}');
      rowIndex++; // Move to the next row
    }

    // Add grand total row
    sheet.getRangeByIndex(rowIndex, 1).setText('Grand Total of all Properties');
    sheet.getRangeByIndex(rowIndex, 2).setText('');
    sheet
        .getRangeByIndex(rowIndex, 3)
        .setText('\$${globalDelinquentTenantsData!.totalDaysAmount}');
    sheet
        .getRangeByIndex(rowIndex, 4)
        .setText('\$${globalDelinquentTenantsData!.last30Days}');
    sheet
        .getRangeByIndex(rowIndex, 5)
        .setText('\$${globalDelinquentTenantsData!.last31To60Days}');
    sheet
        .getRangeByIndex(rowIndex, 6)
        .setText('\$${globalDelinquentTenantsData!.last61To90Days}');
    sheet
        .getRangeByIndex(rowIndex, 7)
        .setText('\$${globalDelinquentTenantsData!.last91PlusDays}');

    // Save workbook as a byte stream
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    // Define file name with current date and time
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'DelinquentTenantsReport_$formattedDate.xlsx';

    // Define file path
    final directory = Directory('/storage/emulated/0/Download');
    final path = '${directory.path}/$fileName';

    // Create directory if it doesn't exist
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    // Write file to the path
    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);

    // Show success toast message
    Fluttertoast.showToast(
      msg: 'Excel file saved to $path',
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
    final directory = Directory('/storage/emulated/0/Download');
    final path = '${directory.path}/$fileName';

    // Create directory if it doesn't exist
    if (!await directory.exists()) {
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

  @override
  Widget build(BuildContext context) {
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
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.home,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  const Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"]),
              buildDropdownListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"]),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"]),
              buildListTile(
                  context,
                  const FaIcon(
                    FontAwesomeIcons.folderOpen,
                    color: Colors.white,
                  ),
                  "Reports",
                  true),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            titleBar(
              title: 'Delinquent Tenants',
              width: MediaQuery.of(context).size.width * .91,
            ),
            if (MediaQuery.of(context).size.width > 500)
              const SizedBox(height: 16),
            if (MediaQuery.of(context).size.width < 500)
              FutureBuilder<List<DelinquentTenantsData>>(
                future: _futureRentersInsurance,
                builder: (context, snapshot) {
                  if (isLoading) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ColabShimmerLoadingWidget(),
                    );
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
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildHeaders(),
                          const SizedBox(height: 20),
                          Container(
                            decoration: BoxDecoration(
                                border: Border.all(color: blueColor)),
                            child: Column(
                              children:
                                  currentPageData.asMap().entries.map((entry) {
                                int rowIndex = entry.key;
                                var item = entry.value;
                                bool isRowExpanded =
                                    expandedRowIndex == rowIndex;

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
                                                        : Color.fromRGBO(
                                                            21, 43, 83, 1),
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
                                                        InkWell(
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
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 36.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            0),
                                                                child:
                                                                    Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Total Amount',
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
                                                                      TextSpan(
                                                                        text:
                                                                            ' :  \$${tenant.pdfDelinquentTenantsData!.totalDaysAmount ?? '-'}',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.grey[500],
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            0),
                                                                child:
                                                                    Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Last 30 Days',
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
                                                                      TextSpan(
                                                                        text:
                                                                            ' :  \$${tenant.pdfDelinquentTenantsData!.last30Days ?? '-'}',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.grey[500],
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            0),
                                                                child:
                                                                    Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Last 31 to 60 days',
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
                                                                      TextSpan(
                                                                        text:
                                                                            ' :  \$${tenant.pdfDelinquentTenantsData!.last31To60Days ?? '-'}',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.grey[500],
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            0),
                                                                child:
                                                                    Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Last 61 to 90 Days',
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
                                                                      TextSpan(
                                                                        text:
                                                                            ' :  \$${tenant.pdfDelinquentTenantsData!.last61To90Days ?? '-'}',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.grey[500],
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 10,
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            0),
                                                                child:
                                                                    Text.rich(
                                                                  TextSpan(
                                                                    children: [
                                                                      TextSpan(
                                                                        text:
                                                                            'Last 91+ Days',
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
                                                                      TextSpan(
                                                                        text:
                                                                            ' :  \$${tenant.pdfDelinquentTenantsData!.last91PlusDays ?? '-'}',
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Colors.grey[500],
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          fontSize:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  height: 8),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
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
                                          : const Color.fromRGBO(21, 43, 83, 1),
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
                                          ? const Color.fromRGBO(21, 43, 83, 1)
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
            if (MediaQuery.of(context).size.width > 500)
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
                                border: Border.all(color: blueColor)),
                            child: Column(
                              children:
                                  currentPageData.asMap().entries.map((entry) {
                                int rowIndex = entry.key;
                                var item = entry.value;
                                bool isRowExpanded =
                                    expandedRowIndex == rowIndex;

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
                                                        : Color.fromRGBO(
                                                            21, 43, 83, 1),
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
                                                        InkWell(
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
                                          : const Color.fromRGBO(21, 43, 83, 1),
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
                                          ? const Color.fromRGBO(21, 43, 83, 1)
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
          ],
        ),
      ),
    );
  }

  List<TableRow> _buildExpandableRows(
      int rowIndex, DelinquentTenantsData item) {
    return [
      TableRow(
        decoration: BoxDecoration(
          border: Border(
            left: const BorderSide(color: Color.fromRGBO(21, 43, 81, 1)),
            right: const BorderSide(color: Color.fromRGBO(21, 43, 81, 1)),
            top: const BorderSide(color: Color.fromRGBO(21, 43, 81, 1)),
            bottom: item.tenants!.isEmpty
                ? const BorderSide(color: Color.fromRGBO(21, 43, 81, 1))
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
              left: const BorderSide(color: Color.fromRGBO(21, 43, 81, 1)),
              right: const BorderSide(color: Color.fromRGBO(21, 43, 81, 1)),
              bottom: tenantEntry.key == item.tenants!.length - 1
                  ? const BorderSide(color: Color.fromRGBO(21, 43, 81, 1))
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
}
