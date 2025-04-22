import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csv/csv.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:three_zero_two_property/provider/getAdminAddress.dart';
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
import '../../../../Model/rentrollreportmodel.dart';
import '../../../../repository/rentrollreportrepo.dart';
import '../../../widgets/custom_drawer.dart';

class RentersInsurances extends StatefulWidget {
  @override
  State<RentersInsurances> createState() => _RentersInsurancesState();
}

class _RentersInsurancesState extends State<RentersInsurances> {
  late Future<rentrollreportmodel> _futureRentersInsurance;
  rentrollreportmodel? rentersInsuranceModel ;
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
    _futureRentersInsurance = fetchRentersInsuranceData();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  Future<rentrollreportmodel> fetchRentersInsuranceData() async {
    RentRollReportService service = RentRollReportService();
    try {
      rentrollreportmodel data = await service.fetchRentRollreport();
      setState(() {
        rentersInsuranceModel = data;
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
        throw Exception('Failed to load renters insurance');
    }
  }

  List<rentrollreportmodel> _tableData = [];
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
      Comparable<T> Function(rentrollreportmodel d)? getField) {
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

  void _sort<T>(Comparable<T> Function(rentrollreportmodel d) getField,
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
                  padding: const EdgeInsets.only(left: 0),
                  child: Row(
                    children: [
                      width < 400
                          ? const Text("   Tenant",
                          style: TextStyle(color: Colors.white))
                          : const Text("   Tenant",
                          style: TextStyle(color: Colors.white)),
                      // Text("Property", style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 3),
                      // ascending1
                      //     ? const Padding(
                      //         padding: EdgeInsets.only(top: 7, left: 2),
                      //         child: FaIcon(
                      //           FontAwesomeIcons.sortUp,
                      //           size: 20,
                      //           color: Colors.white,
                      //         ),
                      //       )
                      //     : const Padding(
                      //         padding: EdgeInsets.only(bottom: 7, left: 2),
                      //         child: FaIcon(
                      //           FontAwesomeIcons.sortDown,
                      //           size: 20,
                      //           color: Colors.white,
                      //         ),
                      //       ),
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
                    // Sorting logic here
                  });
                },
                child: Row(
                  children: [
                    Text("Insurance\n Provider",
                        style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    // ascending2
                    //     ? Padding(
                    //         padding: const EdgeInsets.only(top: 7, left: 2),
                    //         child: FaIcon(
                    //           FontAwesomeIcons.sortUp,
                    //           size: 20,
                    //           color: Colors.white,
                    //         ),
                    //       )
                    //     : Padding(
                    //         padding: const EdgeInsets.only(bottom: 7, left: 2),
                    //         child: FaIcon(
                    //           FontAwesomeIcons.sortDown,
                    //           size: 20,
                    //           color: Colors.white,
                    //         ),
                    //       ),
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
                    Text("     Policy Id", style: TextStyle(color: Colors.white)),
                    SizedBox(width: 5),
                    // ascending3
                    //     ? Padding(
                    //         padding: const EdgeInsets.only(top: 7, left: 2),
                    //         child: FaIcon(
                    //           FontAwesomeIcons.sortUp,
                    //           size: 20,
                    //           color: Colors.white,
                    //         ),
                    //       )
                    //     : Padding(
                    //         padding: const EdgeInsets.only(bottom: 7, left: 2),
                    //         child: FaIcon(
                    //           FontAwesomeIcons.sortDown,
                    //           size: 20,
                    //           color: Colors.white,
                    //         ),
                    //       ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> generaterentersInsurancePdf(
  //     List<rentrollreportmodel> rentersInsurance) async {
  //   final GetAddressAdminPdfService service = GetAddressAdminPdfService();
  //   profile? profileData;
  //
  //   try {
  //     profileData = await service.fetchAdminAddress();
  //   } catch (e) {
  //     // Handle error
  //     print("Error fetching profile data: $e");
  //     return;
  //   }
  //
  //   final pdf = pw.Document();
  //   final image = pw.MemoryImage(
  //     (await rootBundle.load('assets/images/applogo.png')).buffer.asUint8List(),
  //   );
  //   final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
  //
  //   pdf.addPage(
  //     pw.MultiPage(
  //       margin: const pw.EdgeInsets.all(30),
  //       build: (pw.Context context) {
  //         return [
  //           pw.Header(
  //             level: 0,
  //             padding: pw.EdgeInsets.only(bottom: 10),
  //             child: pw.Row(
  //               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //               children: [
  //                 pw.Image(image, width: 50, height: 50),
  //                 pw.SizedBox(width: 50),
  //                 pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                   children: [
  //                     pw.Text(
  //                       'Renters Insurance',
  //                       style: pw.TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: pw.FontWeight.bold,
  //                       ),
  //                     ),
  //                     pw.SizedBox(height: 10),
  //                     pw.Text('As of $currentDate'),
  //                   ],
  //                 ),
  //                 pw.SizedBox(width: 50),
  //                 pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.end,
  //                   children: [
  //                     pw.Text(
  //                       profileData?.companyName?.isNotEmpty == true
  //                           ? profileData!.companyName!
  //                           : 'N/A',
  //                       style: pw.TextStyle(
  //                         fontSize: 10,
  //                         fontWeight: pw.FontWeight.bold,
  //                       ),
  //                     ),
  //                     pw.Text(
  //                       profileData?.companyAddress?.isNotEmpty == true
  //                           ? profileData!.companyAddress!
  //                           : 'N/A',
  //                       style: pw.TextStyle(
  //                         fontSize: 10,
  //                         fontWeight: pw.FontWeight.bold,
  //                       ),
  //                     ),
  //                     pw.Text(
  //                       '${profileData?.companyCity?.isNotEmpty == true ? profileData!.companyCity! : 'N/A'}, '
  //                           '${profileData?.companyState?.isNotEmpty == true ? profileData!.companyState! : 'N/A'}, '
  //                           '${profileData?.companyCountry?.isNotEmpty == true ? profileData!.companyCountry! : 'N/A'}',
  //                       style: pw.TextStyle(
  //                         fontSize: 10,
  //                         fontWeight: pw.FontWeight.bold,
  //                       ),
  //                     ),
  //                     pw.Text(
  //                       profileData?.companyPostalCode?.isNotEmpty == true
  //                           ? profileData!.companyPostalCode!
  //                           : 'N/A',
  //                       style: pw.TextStyle(
  //                         fontSize: 10,
  //                         fontWeight: pw.FontWeight.bold,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //           pw.Table.fromTextArray(
  //             headers: [
  //               'Unit',
  //               'Tenant Name',
  //               'Insurance Provider',
  //               'Policy ID',
  //               'Liability Coverage',
  //               'Effective Date',
  //               'Expiration Date',
  //             ],
  //             data: _generateTableData(rentersInsurance),
  //             headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //             headerDecoration: pw.BoxDecoration(
  //               color: PdfColors.grey300,
  //               border: pw.TableBorder.all(color: PdfColor.fromHex('#152B53')),
  //             ),
  //             cellStyle: pw.TextStyle(fontSize: 10),
  //             cellAlignment: pw.Alignment.centerLeft,
  //             border: pw.TableBorder.all(color: PdfColor.fromHex('#152B53')),
  //             columnWidths: {
  //               0: const pw.FixedColumnWidth(80), // Unit
  //               1: const pw.FixedColumnWidth(80), // Tenant Name
  //               2: const pw.FixedColumnWidth(80), // Insurance Provider
  //               3: const pw.FixedColumnWidth(80), // Policy ID
  //               4: const pw.FixedColumnWidth(80), // Liability Coverage
  //               5: const pw.FixedColumnWidth(80), // Effective Date
  //               6: const pw.FixedColumnWidth(80), // Expiration Date
  //             },
  //           ),
  //         ];
  //       },
  //     ),
  //   );
  //
  //   await Printing.layoutPdf(
  //     onLayout: (PdfPageFormat format) async => pdf.save(),
  //   );
  // }
  // String formateDates(String date){
  //   return DateFormat("yyyy-MM-dd").format(DateTime.parse(date)).toString();
  // }
  // List<List<String>> _generateTableData(
  //     List<rentrollreportmodel> rentersInsurance) {
  //   final List<List<String>> tableData = [];
  //
  //   for (var item in rentersInsurance) {
  //     tableData.add([
  //       item.unitDetails ?? '',
  //       item.tenantName ?? '',
  //       item.rentersInsurance!.insuranceCompany ?? '',
  //       item.rentersInsurance!.policyId ?? '',
  //       "\$${item.rentersInsurance!.liabilityCoverage.toString()}" ?? '',
  //       formateDates(item.rentersInsurance!.effectiveDate!) ?? '',
  //       formateDates(item.rentersInsurance!.expirationDate!)?? '',
  //     ]);
  //
  //     // for (var tenant in item.tenants!) {
  //     //   tableData.add([
  //     //     '',
  //     //     tenant.tenantName ?? '',
  //     //     tenant.tenantInsurance?.provider ?? '',
  //     //     tenant.tenantInsurance?.policyId ?? '',
  //     //     tenant.tenantInsurance!.liabilityCoverage.toString() ?? '',
  //     //     tenant.tenantInsurance?.effectiveDate ?? '',
  //     //     tenant.tenantInsurance?.expirationDate ?? '',
  //     //   ]);
  //     // }
  //   }
  //
  //
  //   return tableData;
  // }

  // Future<void> generaterentersInsurancePdf(
  //     List<rentrollreportmodel> rentersInsurance) async {
  //   final pdf = pw.Document();
  //   final image = pw.MemoryImage(
  //     (await rootBundle.load('assets/images/applogo.png')).buffer.asUint8List(),
  //   );
  //   final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

  //   pdf.addPage(
  //     pw.Page(
  //       margin: const pw.EdgeInsets.all(30),
  //       build: (pw.Context context) {
  //         return pw.Column(
  //           crossAxisAlignment: pw.CrossAxisAlignment.start,
  //           children: [
  //             pw.Row(
  //               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //               children: [
  //                 pw.Image(image, width: 50, height: 50),
  //                 pw.SizedBox(width: 50),
  //                 pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                   children: [
  //                     pw.Text(
  //                       'Completed Work Orders',
  //                       style: pw.TextStyle(
  //                         fontSize: 18,
  //                         fontWeight: pw.FontWeight.bold,
  //                       ),
  //                     ),
  //                     pw.SizedBox(height: 10),
  //                     pw.Text('As of $currentDate'),
  //                   ],
  //                 ),
  //                 pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.end,
  //                   children: [
  //                     pw.Text('302 Properties, LLC'),
  //                     pw.Text('250 Corporate Blvd., Suite L'),
  //                     pw.Text('Newark, DE 19702'),
  //                     pw.Text('(302) 525-4302'),
  //                   ],
  //                 ),
  //               ],
  //             ),
  //             pw.SizedBox(height: 20),
  //             pw.Table(
  //               // border: pw.TableBorder.all(color: PdfColors.grey),
  //               columnWidths: {
  //                 0: const pw.FlexColumnWidth(2),
  //                 1: const pw.FlexColumnWidth(2),
  //                 2: const pw.FlexColumnWidth(2),
  //                 3: const pw.FlexColumnWidth(2),
  //                 4: const pw.FlexColumnWidth(2),
  //                 5: const pw.FlexColumnWidth(2),
  //                 6: const pw.FlexColumnWidth(2),
  //               },
  //               children: [
  //                 pw.TableRow(
  //                   decoration: pw.BoxDecoration(
  //                     border: pw.TableBorder.all(
  //                       color: PdfColor.fromHex('#152B53'),
  //                     ),
  //                     color: PdfColors.grey300,
  //                   ),
  //                   children: [
  //                     pw.Padding(
  //                       padding: const pw.EdgeInsets.all(8.0),
  //                       child: pw.Text('Unit',
  //                           style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold, fontSize: 12)),
  //                     ),
  //                     pw.Padding(
  //                       padding: const pw.EdgeInsets.all(8.0),
  //                       child: pw.Text('Tenant Name',
  //                           style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold, fontSize: 12)),
  //                     ),
  //                     pw.Padding(
  //                       padding: const pw.EdgeInsets.all(8.0),
  //                       child: pw.Text('Insurance Provider',
  //                           style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold, fontSize: 12)),
  //                     ),
  //                     pw.Padding(
  //                       padding: const pw.EdgeInsets.all(8.0),
  //                       child: pw.Text('Policy ID',
  //                           style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold, fontSize: 12)),
  //                     ),
  //                     pw.Padding(
  //                       padding: const pw.EdgeInsets.all(8.0),
  //                       child: pw.Text('Liability Coverage',
  //                           style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold, fontSize: 12)),
  //                     ),
  //                     pw.Padding(
  //                       padding: const pw.EdgeInsets.all(8.0),
  //                       child: pw.Text('Effective Date',
  //                           style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold, fontSize: 12)),
  //                     ),
  //                     pw.Padding(
  //                       padding: const pw.EdgeInsets.all(8.0),
  //                       child: pw.Text('Expiration Date',
  //                           style: pw.TextStyle(
  //                               fontWeight: pw.FontWeight.bold, fontSize: 12)),
  //                     ),
  //                   ],
  //                 ),
  //                 for (var item in rentersInsurance) ...[
  //                   pw.TableRow(
  //                     decoration: pw.BoxDecoration(
  //                       border: pw.TableBorder.all(
  //                         color: PdfColor.fromHex('#152B53'),
  //                       ),
  //                       color: PdfColors.grey100,
  //                     ),
  //                     children: [
  //                       pw.Padding(
  //                         padding: const pw.EdgeInsets.all(8.0),
  //                         child: pw.Text(item.rentalAddress ?? '',
  //                             style: const pw.TextStyle(fontSize: 10)),
  //                       ),
  //                       pw.Padding(
  //                         padding: const pw.EdgeInsets.all(8.0),
  //                         child: pw.Text('',
  //                             style: const pw.TextStyle(fontSize: 10)),
  //                       ),
  //                     ],
  //                   ),
  //                   for (var tenant in item.tenants!)
  //                     pw.TableRow(
  //                       decoration: pw.BoxDecoration(
  //                         border: pw.TableBorder.all(
  //                           color: PdfColor.fromHex('#152B53'),
  //                         ),
  //                       ),
  //                       children: [
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.all(8.0),
  //                           child: pw.Text('',
  //                               style: const pw.TextStyle(fontSize: 10)),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.all(8.0),
  //                           child: pw.Text(tenant.tenantName ?? '',
  //                               style: const pw.TextStyle(fontSize: 10)),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.all(8.0),
  //                           child: pw.Text(
  //                               tenant.tenantInsurance!.provider.toString() ??
  //                                   '',
  //                               style: const pw.TextStyle(fontSize: 10)),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.all(8.0),
  //                           child: pw.Text(
  //                               tenant.tenantInsurance!.policyId.toString() ??
  //                                   '',
  //                               style: const pw.TextStyle(fontSize: 10)),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.all(8.0),
  //                           child: pw.Text(
  //                               tenant.tenantInsurance!.liabilityCoverage
  //                                       .toString() ??
  //                                   '',
  //                               style: const pw.TextStyle(fontSize: 10)),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.all(8.0),
  //                           child: pw.Text(
  //                               tenant.tenantInsurance!.effectiveDate
  //                                       .toString() ??
  //                                   '',
  //                               style: const pw.TextStyle(fontSize: 10)),
  //                         ),
  //                         pw.Padding(
  //                           padding: const pw.EdgeInsets.all(8.0),
  //                           child: pw.Text(
  //                               tenant.tenantInsurance!.expirationDate
  //                                       .toString() ??
  //                                   '',
  //                               style: const pw.TextStyle(fontSize: 10)),
  //                         ),
  //                       ],
  //                     ),
  //                 ],
  //               ],
  //             ),
  //           ],
  //         );
  //       },
  //     ),
  //   );

  //   await Printing.layoutPdf(
  //     onLayout: (PdfPageFormat format) async => pdf.save(),
  //   );
  // }

  // Future<void> generateRentersInsuranceExcel(
  //     List<rentrollreportmodel> rentersInsurance) async {
  //   final syncXlsx.Workbook workbook = syncXlsx.Workbook();
  //   final syncXlsx.Worksheet sheet = workbook.worksheets[0];
  //
  //   // Set column widths
  //   sheet.getRangeByName('A1:G1').columnWidth = 30;
  //
  //   // Define headers
  //   final List<String> headers = [
  //     'Unit',
  //     'Tenant Name',
  //     'Insurance Provider',
  //     'Policy ID',
  //     'Liability Coverage',
  //     'Effective Date',
  //     'Expiration Date',
  //   ];
  //
  //   // Style for headers
  //   final syncXlsx.Style headerCellStyle =
  //   workbook.styles.add('headerCellStyle');
  //   headerCellStyle.bold = true;
  //   headerCellStyle.backColor = '#D3D3D3';
  //   headerCellStyle.hAlign = syncXlsx.HAlignType.left;
  //
  //   // Add headers to the first row
  //   for (int i = 0; i < headers.length; i++) {
  //     final cell = sheet.getRangeByIndex(1, i + 1);
  //     cell.setText(headers[i]);
  //     cell.cellStyle = headerCellStyle;
  //   }
  //
  //   int rowIndex = 2; // Start from the second row
  //   // for (var item in rentersInsurance) {
  //   //   // Add main row with rental address
  //   //   sheet.getRangeByIndex(rowIndex, 1).setText(item.unitDetails ?? '');
  //   //   for (int col = 2; col <= 7; col++) {
  //   //     sheet.getRangeByIndex(rowIndex, col).setText('');
  //   //   }
  //   //
  //   //   rowIndex++; // Move to the next row for tenant details
  //   //
  //   //   // Add tenant details in subsequent rows
  //   //   // for (var tenant in item.tenants!) {
  //   //   //   sheet
  //   //   //       .getRangeByIndex(rowIndex, 1)
  //   //   //       .setText(item.tenants!.first.unitDetails ?? '');
  //   //   //   sheet.getRangeByIndex(rowIndex, 2).setText(tenant.tenantName ?? '');
  //   //   //   sheet
  //   //   //       .getRangeByIndex(rowIndex, 3)
  //   //   //       .setText(tenant.tenantInsurance?.provider ?? '');
  //   //   //   sheet
  //   //   //       .getRangeByIndex(rowIndex, 4)
  //   //   //       .setText(tenant.tenantInsurance?.policyId ?? '');
  //   //   //   sheet.getRangeByIndex(rowIndex, 5).setText(
  //   //   //       tenant.tenantInsurance!.liabilityCoverage.toString() ?? '');
  //   //   //   sheet
  //   //   //       .getRangeByIndex(rowIndex, 6)
  //   //   //       .setText(tenant.tenantInsurance?.effectiveDate ?? '');
  //   //   //   sheet
  //   //   //       .getRangeByIndex(rowIndex, 7)
  //   //   //       .setText(tenant.tenantInsurance?.expirationDate ?? '');
  //   //   //   rowIndex++; // Move to the next row
  //   //   // }
  //   // }
  //
  //   // Save workbook as a byte stream
  //   for (var item in rentersInsurance) {
  //     if (item.rentersInsurance != null) {
  //       sheet.getRangeByIndex(rowIndex, 1).setText(item.unitDetails ?? '');
  //       sheet.getRangeByIndex(rowIndex, 2).setText(item.tenantName ?? '');
  //       sheet
  //           .getRangeByIndex(rowIndex, 3)
  //           .setText(item.rentersInsurance!.insuranceCompany ?? '');
  //       sheet
  //           .getRangeByIndex(rowIndex, 4)
  //           .setText(item.rentersInsurance!.policyId ?? '');
  //       sheet.getRangeByIndex(rowIndex, 5).setText(
  //           item.rentersInsurance!.liabilityCoverage != null
  //               ? "\$${item.rentersInsurance!.liabilityCoverage}"
  //               : '');
  //       sheet
  //           .getRangeByIndex(rowIndex, 6)
  //           .setText(formateDates(item.rentersInsurance!.effectiveDate.toString()) ?? '');
  //       sheet
  //           .getRangeByIndex(rowIndex, 7)
  //           .setText(formateDates(item.rentersInsurance!.expirationDate.toString()) ?? '');
  //       rowIndex++; // Move to the next row
  //     }
  //   }
  //   final List<int> bytes = workbook.saveAsStream();
  //   workbook.dispose();
  //
  //   // Define file name with current date and time
  //   final DateTime now = DateTime.now();
  //   final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
  //   final String fileName = 'RentersInsuranceReport_$formattedDate.xlsx';
  //   final Directory directory = Platform.isIOS
  //       ? await getApplicationDocumentsDirectory()
  //       : Directory ('/storage/emulated/0/Download');
  //
  //   // Create directory if it doesn't exist (for Android)
  //   if (!await directory.exists() && !Platform.isIOS) {
  //     await directory.create(recursive: true);
  //   }
  //   final path = '${directory.path}/$fileName';
  //   final File file = File(path);
  //   await file.writeAsBytes(bytes, flush: true);
  //   Share.shareXFiles([XFile(path)]);
  //
  //   // Show success toast message
  //   Fluttertoast.showToast(
  //     msg: 'Excel file saved to $path',
  //   );
  // }
  //
  // Future<void> generateRentersInsuranceCsv(
  //     List<rentrollreportmodel> rentersInsurance) async {
  //   final StringBuffer csvBuffer = StringBuffer();
  //   List<List<dynamic>> rows = [
  //     [
  //       'Unit',
  //       'Tenant Name',
  //       'Insurance Provider',
  //       'Policy ID',
  //       'Liability Coverage',
  //       'Effective Date',
  //       'Expiration Date'
  //     ]
  //   ];
  //
  //   for (var item in rentersInsurance) {
  //     // Add main row with rental address
  //     rows.add([
  //       item.unitDetails ?? '',
  //       item.tenantName ?? '',
  //       item.rentersInsurance!.insuranceCompany ?? '',
  //       item.rentersInsurance!.policyId ?? '',
  //       "\$${item.rentersInsurance!.liabilityCoverage.toString()}" ?? '',
  //       formateDates(item.rentersInsurance!.effectiveDate!) ?? '',
  //       formateDates(item.rentersInsurance!.expirationDate!) ?? '',
  //     ]);
  //
  //     // Add tenant details in subsequent rows
  //     // for (var tenant in item.tenants!) {
  //     //   rows.add([
  //     //     '',
  //     //     tenant.tenantName ?? '',
  //     //     tenant.tenantInsurance?.provider ?? '',
  //     //     tenant.tenantInsurance?.policyId ?? '',
  //     //     tenant.tenantInsurance?.liabilityCoverage ?? '',
  //     //     tenant.tenantInsurance?.effectiveDate ?? '',
  //     //     tenant.tenantInsurance?.expirationDate ?? ''
  //     //   ]);
  //     // }
  //   }
  //
  //   String csv = const ListToCsvConverter().convert(rows);
  //   final List<int> bytes = utf8.encode(csvBuffer.toString());
  //   // Define file name with current date and time
  //   final DateTime now = DateTime.now();
  //   final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
  //   final String fileName = 'RentersInsuranceReport_$formattedDate.csv';
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
  //   Share.shareXFiles([XFile(path)]);
  //
  //   // Show success toast message
  //   Fluttertoast.showToast(
  //     msg: 'CSV file saved to $path',
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget_302.App_Bar(context: context),
      drawer: CustomDrawer(
        currentpage: "Reports",
        dropdown: false,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            titleBar(
              title: 'Renters Insurance',
              width: MediaQuery.of(context).size.width * .91,
            ),
            if (MediaQuery.of(context).size.width > 500)
              const SizedBox(height: 16),
            if (MediaQuery.of(context).size.width < 500)
              FutureBuilder<rentrollreportmodel>(
                future: _futureRentersInsurance,
                builder: (context, snapshot) {
                  if (isLoading) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ColabShimmerLoadingWidget(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(errorMessage ?? 'Unknown error'));
                  } else if (!snapshot.hasData ||
                      snapshot.data!.rentalOwners!.isEmpty) {
                    return Container(
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
                    );
                  }

                  var data = snapshot.data!.rentals;

                  // Apply filtering based on selectedValue and searchValue
                  // if (selectedValue == null && searchvalue.isEmpty) {
                  //   data = snapshot.data!;
                  // } else if (selectedValue == "All") {
                  //   data = snapshot.data!;
                  // } else if (searchvalue.isNotEmpty) {
                  //   data = snapshot.data!
                  //       .where((item) =>
                  //   item.rentalAddress!
                  //       .toLowerCase()
                  //       .contains(searchvalue.toLowerCase()) ||
                  //       item.tenantName!
                  //           .toLowerCase()
                  //           .contains(searchvalue.toLowerCase()))
                  //       .toList();
                  // } else {
                  //   data = snapshot.data!
                  //       .where(
                  //           (item) => item.rentalAddress == selectedValue)
                  //       .toList();
                  // }

                  // Pagination logic
                  final totalPages = (data!.length / itemsPerPage).ceil();
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Material(
                                    elevation: 3,
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      height: MediaQuery.of(context)
                                          .size
                                          .width <
                                          500
                                          ? 48
                                          : 50,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        border: Border.all(
                                            color:
                                            const Color(0xFF8A95A8)),
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
                                      // if (value == 'PDF') {
                                      //   print('pdf');
                                      //   generaterentersInsurancePdf(data);
                                      // } else if (value == 'XLSX') {
                                      //   print('XLSX');
                                      //   generateRentersInsuranceExcel(
                                      //       data);
                                      // } else if (value == 'CSV') {
                                      //   print('CSV');
                                      //   generateRentersInsuranceCsv(data);
                                      // }
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

                        ],
                      ),
                    ),
                  );
                },
              ),


            //   FutureBuilder<List<RentersInsuranceData>>(
            //     future: _futureRentersInsurance,
            //     builder: (context, snapshot) {
            //       if (isLoading) {
            //         return Center(
            //           child: SpinKitFadingCircle(
            //             color: Colors.black,
            //             size: 40.0,
            //           ),
            //         );
            //       } else if (snapshot.hasError) {
            //         return Center(child: Text(errorMessage ?? 'Unknown error'));
            //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //        return Container(
            //             height: MediaQuery.of(context).size.height * .5,
            //             child: Center(
            //               child: Column(
            //                 mainAxisAlignment: MainAxisAlignment.center,
            //                 crossAxisAlignment: CrossAxisAlignment.center,
            //                 children: [
            //                   Image.asset("assets/images/no_data.jpg",height: 200,width: 200,),
            //                   SizedBox(height: 10,),
            //                   Text("No Data Available",style: TextStyle(fontWeight: FontWeight.bold,color:blueColor,fontSize: 16),)
            //                 ],
            //               ),
            //             ),
            //           );
            //       }

            //       var data = snapshot.data!;
            //       return SingleChildScrollView(
            //         scrollDirection: Axis.horizontal,
            //         child: SizedBox(
            //           width: MediaQuery.of(context).size.width * 0.95,
            //           child: Padding(
            //             padding: const EdgeInsets.all(16.0),
            //             child: Column(
            //               children: [
            //                 Table(
            //                   defaultColumnWidth: IntrinsicColumnWidth(),
            //                   columnWidths: const {
            //                     0: FlexColumnWidth(),
            //                     1: FlexColumnWidth(),
            //                     2: FlexColumnWidth(),
            //                     3: FlexColumnWidth(),
            //                   },
            //                   children: [
            //                     TableRow(
            //                       decoration: BoxDecoration(
            //                         border: Border.all(color: blueColor),
            //                       ),
            //                       children: [
            //                         _buildHeader('Unit', 0,
            //                             (item) => item.rentalAddress!),
            //                         _buildHeader('Ten.. Name', 1,
            //                             (tenant) => tenant.rentalAddress!),
            //                         _buildHeader(
            //                             'Provider',
            //                             2,
            //                             (tenant) =>
            //                                 tenant.rentalAddress ?? '-'),
            //                         _buildHeader('Policy Id', 3,
            //                             (item) => item.rentalAddress!),
            //                         _buildHeader('Liability Coverage', 3,
            //                             (item) => item.rentalAddress!),
            //                       ],
            //                     ),
            //                     TableRow(
            //                       decoration: BoxDecoration(
            //                         border: Border.symmetric(
            //                             horizontal: BorderSide.none),
            //                       ),
            //                       children: List.generate(
            //                           5,
            //                           (index) => TableCell(
            //                               child: Container(height: 20))),
            //                     ),
            //                     for (var entry in data.asMap().entries)
            //                       ..._buildExpandableRows(
            //                           entry.key, entry.value),
            //                   ],
            //                 ),
            //                 SizedBox(height: 25),
            //                 _buildPaginationControls(),
            //                 SizedBox(height: 25),
            //               ],
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   )
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

// List<TableRow> _buildExpandableRows(int rowIndex, RentersInsuranceData item) {
//   return [
//     TableRow(
//       decoration: BoxDecoration(
//         border: Border(
//           left: BorderSide(color: blueColor),
//           right: BorderSide(color: blueColor),
//           top: BorderSide(color: blueColor),
//           bottom: item.tenants!.isEmpty
//               ? BorderSide(color: blueColor)
//               : BorderSide.none,
//         ),
//       ),
//       children: [
//         _buildDataCell(item.rentalAddress ?? '-'),
//         _buildDataCell(''),
//         _buildDataCell(''),
//         _buildDataCell(''),
//         _buildDataCell(''),
//       ],
//     ),
//     for (var tenantEntry in item.tenants!.asMap().entries)
//       TableRow(
//         decoration: BoxDecoration(
//           border: Border(
//             left: BorderSide(color: blueColor),
//             right: BorderSide(color: blueColor),
//             bottom: tenantEntry.key == item.tenants!.length - 1
//                 ? BorderSide(color: blueColor)
//                 : BorderSide.none,
//           ),
//         ),
//         children: [
//           _buildDataCell('${item.tenants!.first.unitDetails ?? '-'}'),
//           _buildDataCell('${tenantEntry.value.tenantName ?? '-'}'),
//           _buildDataCell(
//               '${tenantEntry.value.tenantInsurance?.provider ?? '-'}'),
//           _buildDataCell(
//               ' ${tenantEntry.value.tenantInsurance?.policyId ?? '-'}\n'),
//           _buildDataCell(
//               ' ${tenantEntry.value.tenantInsurance?.liabilityCoverage ?? '-'}\n'),
//         ],
//       ),
//   ];
// }
}
