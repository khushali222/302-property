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
       // rentersInsuranceModel = data;
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

  bool isdisplaysummeryBedbath = false;
  bool isdisplaysummeryProperty = false;
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
 // int? expandedRowIndex;
  int? nestedExpandedIndex;
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
                          ? const Text("   Unit",
                          style: TextStyle(color: Colors.white))
                          : const Text("   Unit",
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
                    Text("Lease Start",
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
                    Text("Lease End", style: TextStyle(color: Colors.white)),
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
  Widget _buildHeadersforsummery(String h1, String h2) {
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
              flex: 4,
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
                          ?  Text("   $h1",
                          style: TextStyle(color: Colors.white))
                          :  Text("   $h1",
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
              flex: 3,
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
                    Text("  $h2",
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

          ],
        ),
      ),
    );
  }
  Future<void> generaterentersInsurancePdf(rentrollreportmodel data) async {
    final GetAddressAdminPdfService service = GetAddressAdminPdfService();
    profile? profileData;

    try {
      profileData = await service.fetchAdminAddress();
    } catch (e) {
      print("Error fetching profile data: $e");
      return;
    }

    final pdf = pw.Document();
    final image = pw.MemoryImage(
      (await rootBundle.load('assets/images/applogo.png')).buffer.asUint8List(),
    );
    final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    // Column headers with flex configuration
    final headers = [
      {'title': 'Unit', 'flex': 1},
      {'title': 'Tenants', 'flex': 1},
      {'title': 'Lease Start', 'flex': 1},
      {'title': 'Lease End', 'flex': 1},
      {'title': 'Bed/Bath', 'flex': 1},
      {'title': 'Rent Cycle', 'flex': 1},
      {'title': 'Rent', 'flex': 1},
      {'title': 'Charges', 'flex': 1},
      {'title': 'Credits', 'flex': 1},
      {'title': 'Total', 'flex': 1},
      {'title': 'Deposits', 'flex': 1},
      {'title': 'Prepayments', 'flex': 1},
      {'title': 'Balance', 'flex': 1},
    ];

    // Dummy property data
    final List<Map<String, dynamic>> dummyProperties = [
      {
        'name': 'Property 1',
        'rows': [
          [
            'Unit A1', 'John Doe', '01/01/2024', '12/31/2024', '2/1', 'Monthly',
            '1200', '100', '0', '1300', '1200', '0', '100'
          ],
          [
            'Unit A2', 'Jane Smith', '02/01/2024', '01/31/2025', '1/1', 'Monthly',
            '1100', '50', '0', '1150', '1100', '0', '50'
          ],
        ],
        'totals': ['Total for Property 1', '2300', '150', '0', '2450', '2300', '0', '150'],
      },
      {
        'name': 'Property 2',
        'rows': [
          [
            'Unit B1', 'Alice + Bob', '03/01/2024', '02/28/2025', '3/2', 'Monthly',
            '1800', '200', '50', '1950', '1800', '0', '150'
          ],
        ],
        'totals': ['Total for Property 2', '1800', '200', '50', '1950', '1800', '0', '150'],
      },
    ];

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(30),
        build: (pw.Context context) {
          return [
            // Header section
            pw.Header(
              level: 0,
              padding: pw.EdgeInsets.only(bottom: 10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(image, width: 50, height: 50),
                  pw.SizedBox(width: 50),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        'Renters Insurance',
                        style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text('As of $currentDate'),
                    ],
                  ),
                  pw.SizedBox(width: 50),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(profileData?.companyName ?? 'N/A', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                      pw.Text(profileData?.companyAddress ?? 'N/A', style: pw.TextStyle(fontSize: 10)),
                      pw.Text(
                        '${profileData?.companyCity ?? 'N/A'}, ${profileData?.companyState ?? 'N/A'}, ${profileData?.companyCountry ?? 'N/A'}',
                        style: pw.TextStyle(fontSize: 10),
                      ),
                      pw.Text(profileData?.companyPostalCode ?? 'N/A', style: pw.TextStyle(fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),

            // Table Header (once)
            // pw.Table(
            //   border: pw.TableBorder(bottom: pw.BorderSide()),
            //   children: [
            //     pw.TableRow(
            //       children: headers.map((header) {
            //         return pw.Expanded(
            //           flex: header['flex'] as int,
            //           child: pw.Text(
            //             "${header['title']!}",
            //             style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            //           ),
            //         );
            //       }).toList(),
            //     ),
            //   ],
            // ),
            //
            // // Properties with data rows
            // ...dummyProperties.expand((property) {
            //   final String name = property['name'];
            //   final List<List<String>> rows = List<List<String>>.from(property['rows']);
            //   final List<String> totals = List<String>.from(property['totals']);
            //
            //   return [
            //     pw.SizedBox(height: 10),
            //     pw.Text(name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            //
            //     // Data rows
            //     pw.Table(
            //       // border: pw.TableBorder.all(),
            //       children: data.rentals!.expand((row) {
            //         return row.activeLeases!.asMap().entries.map((entry) {
            //           var index = entry.key;
            //           var leasedata = entry.value;
            //
            //           return pw.TableRow(
            //             children: [
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.unit?.rentalUnit ?? '', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(
            //                   leasedata.tenants!
            //                       .map((tenant) => "${tenant.tenantFirstName ?? ''} ${tenant.tenantLastName ?? ''}".trim())
            //                       .join(", "),
            //                   style: pw.TextStyle(fontSize: 12),
            //                 ),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.leaseStart ?? '', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.leaseEnd ?? '', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.unit?.bedBath?.toString() ?? '--------', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.rentCycle?.toString() ?? '', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.leaseStart ?? '', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.rentAmount?.toString() ?? '', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.chargeAmount?.toString() ?? '', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.creditAmount?.toString() ?? '', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.chargeTotal?.toString() ?? '', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.depositHeld?.toString() ?? '', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.prepayments?.toString() ?? '', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //               pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(leasedata.balanceDue?.toString() ?? '', style: pw.TextStyle(fontSize: 12)),
            //               ),
            //             ],
            //           );
            //         }).toList();
            //       }).toList(),
            //     ),
            //
            //
            //
            //
            //     // Summary row
            //     pw.Table(
            //       children: [
            //         pw.TableRow(
            //           children: [
            //             pw.Expanded(
            //               flex: 7,
            //               child: pw.Text(
            //                 totals[0],
            //                 style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            //               ),
            //             ),
            //             ...totals.sublist(1).map((cell) {
            //               return pw.Expanded(
            //                 flex: 1,
            //                 child: pw.Text(
            //                   cell,
            //                   style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            //                 ),
            //               );
            //             }).toList(),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ];
            // }).toList(),

            
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }



  // String formateDates(String date){
  //   return DateFormat("yyyy-MM-dd").format(DateTime.parse(date)).toString();
  // }

  pw.Widget _propertyTable(String address, List<String> values) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(address, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          context: null,
          headers: ['Tenants', 'Lease Start', 'Lease End', 'Bed', 'Bath', 'Rent Cycle', 'Rent Start', 'Rent', 'Charges', 'Credits', 'Total', 'Deposits', 'Prepayments', 'Balance'],
          data: [values],
        ),
      ],
    );
  }

  pw.Widget _summaryTable() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Grand Totals', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          context: null,
          headers: ['Market Rent', 'Rent', 'Recurring Charges', 'Recurring Credits', 'Deposits Held', 'Balance Due'],
          data: [['\$0.00', '\$300.00', '\$10.00', '\$0.00', '\$0.00', '(\$130.00)']],
        ),
      ],
    );
  }

  pw.Widget _bedBathSummaryTable() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Summary by Bed/Bath', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          context: null,
          headers: ['Bed/Bath', 'No. of Units', 'Vacant', 'Occupied', '% Occupied', 'Sq Ft Total', 'Avg Sq Ft', 'Market Rent Total', 'Avg Rent'],
          data: [['-/-', '3', '0', '3', '100%', '263', '87.67', '\$0.00', '\$0.00']],
        ),
      ],
    );
  }

  pw.Widget _propertySummaryTable() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Summary by Property', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.Table.fromTextArray(
          context: null,
          headers: ['Property', 'No. of Units', 'Vacant', 'Occupied', '% Occupied', 'Sq Ft Total', 'Avg Sq Ft', 'Market Rent Total', 'Avg Rent'],
          data: [
            ['2596 Watson Street', '1', '0', '1', '100%', '10', '10.00', '\$0.00', '\$0.00'],
            ['813 Howard Street', '1', '0', '1', '100%', '152', '152.00', '\$0.00', '\$0.00'],
            ['Office Address', '1', '0', '1', '100%', '101', '101.00', '\$0.00', '\$0.00'],
            ['Totals and Averages', '3', '0', '3', '100%', '263', '87.67', '\$0.00', '\$0.00'],
          ],
        ),
      ],
    );
  }

  // List<List<String>> _generateTableData(
  //     rentrollreportmodel rentersInsurance) {
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
              title: 'Rent Roll Report',
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
                    return Center(child: Text(errorMessage ?? 'Unknown error'));
                  } else if (!snapshot.hasData || snapshot.data!.rentals!.isEmpty) {
                    return Container(
                      height: MediaQuery.of(context).size.height * .5,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              "assets/images/no_data.jpg",
                              height: 200,
                              width: 200,
                            ),
                            SizedBox(height: 10),
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

                  var data = snapshot.data!.rentals!;
                  final currentPageData = data;

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Search & Export Section
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              // Dropdown for Rental Owners
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      hint: const Text("Select Rental Owners"),
                                      value: selectedOwner,
                                      items: rentalOwners
                                          .map((owner) => DropdownMenuItem<String>(
                                        value: owner,
                                        child: Text(owner),
                                      ))
                                          .toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          selectedOwner = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),

                              // Run Report Button
                              Container(
                                height: 45,
                                width: 45,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(0),
                                  color: Colors.white,
                                ),
                                child: IconButton(
                                  icon: FaIcon(FontAwesomeIcons.circlePlay),
                                  onPressed: () {
                                    print("Run Report");
                                  },
                                  tooltip: "Run Report",
                                ),
                              ),
                              //const SizedBox(width: 8),

                              // Download Button with Dropdown
                              Container(
                                height: 45,
                                width: 75,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(0),
                                  color: Colors.white,
                                ),
                                child: PopupMenuButton<String>(
                                  offset: Offset(5, 50),
                                  onSelected: handleDownload,
                                  icon: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      FaIcon(FontAwesomeIcons.download), // Your download icon
                                      SizedBox(width: 5), // Adds spacing between the icons
                                      Icon(Icons.arrow_drop_down), // The dropdown arrow icon
                                    ],
                                  ),
                                  tooltip: "Download",
                                  itemBuilder: (BuildContext context) {
                                    return downloadOptions.map((String option) {
                                      return PopupMenuItem<String>(
                                        value: option,
                                        onTap: ()async{
                                          generaterentersInsurancePdf(snapshot.data!);
                                        },
                                        child: Text("Download as $option"),
                                      );
                                    }).toList();
                                  },
                                ),
                              )

                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [
                              _buildTabButton("Details", 0),
                              _buildTabButton("Summary", 1),
                            ],
                          ),
                        ),
                        if(_selectedIndex == 0)
                        DetailScreen(currentPageData),
                        if(_selectedIndex == 1)
                          SummeryScreen(snapshot.data!)
                        // Custom Tab Bar

                      ],
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
  int _selectedIndex =0;
  DetailScreen(List<Rentals> currentPageData){
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            _buildHeaders(),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
              ),
              child: Column(
                children: currentPageData.asMap().entries.map((entry) {
                  int rowIndex = entry.key;
                  var item = entry.value;
                  bool isRowExpanded = expandedRowIndex == rowIndex;

                  return Container(
                    decoration: BoxDecoration(
                      color: rowIndex % 2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                      border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
                    ),
                    child: Column(
                      children: <Widget>[
                        // Row header
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (expandedRowIndex == rowIndex) {
                                        expandedRowIndex = null;
                                      } else {
                                        expandedRowIndex = rowIndex;
                                        nestedExpandedIndex = null; // reset inner when switching rows
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
                                SizedBox(width: 8),
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
                                SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),

                        // Outer expanded section
                        if (isRowExpanded)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            decoration: BoxDecoration(

                              border: Border(top: BorderSide(color: Colors.grey.shade400)),
                            ),
                            child: Column(
                              children: item.activeLeases?.asMap().entries.map((leaseEntry) {
                                int leaseIndex = leaseEntry.key;
                                ActiveLeases lease = leaseEntry.value;
                                bool isLeaseExpanded = expandedLeaseIndex == leaseIndex;
                                bool isLeaseIndexExpanded = expandedLeaseTotalIndex == leaseIndex;

                                return Column(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.symmetric(vertical: 0),

                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        onTap: () {
                                          setState(() {
                                            if (expandedLeaseIndex == leaseIndex) {
                                              expandedLeaseIndex = null;
                                            } else {
                                              expandedLeaseIndex = leaseIndex;
                                            }
                                          });
                                        },
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  if (expandedLeaseIndex == leaseIndex) {
                                                    expandedLeaseIndex = null;
                                                  } else {
                                                    expandedLeaseIndex = leaseIndex;
                                                  }
                                                });
                                              },
                                              child: Container(
                                                margin: const EdgeInsets.only(left: 5),
                                                padding: !isLeaseExpanded
                                                    ? const EdgeInsets.only(bottom: 10)
                                                    : const EdgeInsets.only(top: 10),
                                                child: FaIcon(
                                                  isLeaseExpanded
                                                      ? FontAwesomeIcons.sortUp
                                                      : FontAwesomeIcons.sortDown,
                                                  size: 20,
                                                  color: blueColor,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(child: Text("${lease.unit?.rentalUnit ?? '-'}",  style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),)),
                                            Expanded(child: Text("${lease.leaseStart ?? '-'}",  style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),)),
                                            Expanded(child: Text("${lease.leaseEnd ?? '-'}",  style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),)),
                                          ],
                                        ),

                                      ),
                                    ),
                                    if (isLeaseExpanded)
                                      Row(
                                        children: [

                                          Expanded(
                                            child: Table(
                                              columnWidths: {
                                                // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                                // 1: FlexColumnWidth(),
                                                0: FlexColumnWidth(), // Distribute columns equally
                                                1: FlexColumnWidth(),
                                                2: FlexColumnWidth(),
                                              },
                                              children: [

                                                buildTableRows(
                                                  'Rent start',
                                                  getDisplayValue("${lease.leaseStart
                                                  }"
                                                  ),'Rent Cycle',
                                                  getDisplayValue(lease.rentCycle),
                                                  'Credits',
                                                  getDisplayValue("\$${lease.creditAmount!.toStringAsFixed(2)}"),
                                                ),
                                                buildTableRows(
                                                  'Bed/Bath',
                                                  getDisplayValue("${lease.unit!.bedBath
                                                  }"
                                                  ),'Prepayments',
                                                  getDisplayValue("\$${lease.prepayments!.toStringAsFixed(2)}"),
                                                  'Charges',
                                                  getDisplayValue("\$${lease.chargeAmount!.toStringAsFixed(2)}"),
                                                ),

                                                buildTableRows(
                                                  'Total',
                                                  getDisplayValue("\$${lease.chargeTotal!.toStringAsFixed(2)
                                                  }"
                                                  ),'Balance Due',
                                                  getDisplayValue("\$${lease.balanceDue!.toStringAsFixed(2)
                                                  }"),
                                                  'Rent',
                                                  getDisplayValue("\$${lease.rentAmount!.toStringAsFixed(2)
                                                  }"),
                                                ),
                                                buildTableRows(
                                                  'Deposit Held',
                                                  getDisplayValue("\$${lease.depositHeld!.toStringAsFixed(2)}"),
                                                  'Tenants',
                                                  getDisplayValue(
                                                      lease.tenants!
                                                          .map((tenant) => "${tenant.tenantFirstName ?? ''} ${tenant.tenantLastName ?? ''}".trim())
                                                          .join(", ")
                                                  ),
                                                  '',
                                                  "",
                                                )

                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    Container(
                                      decoration: BoxDecoration(
                                          border: Border(top: BorderSide(color:Colors.grey.shade500))
                                      ),
                                      child: ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (expandedLeaseTotalIndex == leaseIndex) {
                                                      expandedLeaseTotalIndex = null;
                                                    } else {
                                                      expandedLeaseTotalIndex = leaseIndex;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(left: 5),
                                                  padding: !isLeaseIndexExpanded
                                                      ? const EdgeInsets.only(bottom: 10)
                                                      : const EdgeInsets.only(top: 10),
                                                  child: FaIcon(
                                                    isLeaseIndexExpanded
                                                        ? FontAwesomeIcons.sortUp
                                                        : FontAwesomeIcons.sortDown,
                                                    size: 20,
                                                    color: blueColor,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  'Total For ${item.rentalAddress ?? '-'}',
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 8),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    if (isLeaseIndexExpanded)
                                      Row(
                                        children: [

                                          Expanded(
                                            child: Table(
                                              columnWidths: {
                                                // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                                // 1: FlexColumnWidth(),
                                                0: FlexColumnWidth(), // Distribute columns equally
                                                1: FlexColumnWidth(),
                                                2: FlexColumnWidth(),
                                              },
                                              children: [

                                                buildTableRows(
                                                  'Credits',
                                                  getDisplayValue("\$${item.totals!.totalCredits!.toStringAsFixed(2)
                                                  }"
                                                  ),'Prepayments',
                                                  getDisplayValue("\$${item.totals!.totalPrepayments!.toStringAsFixed(2)
                                                  }"
                                                  ),
                                                  'Charges',
                                                  getDisplayValue("\$${item.totals!.totalCharges!.toStringAsFixed(2)}"),
                                                ),
                                                buildTableRows(
                                                  'Total',
                                                  getDisplayValue("\$${item.totals!.totalAmount!.toStringAsFixed(2)
                                                  }"
                                                  ),'Balance Due',
                                                  getDisplayValue("\$${item.totals!.totalBalanceDue!.toStringAsFixed(2)
                                                  }"
                                                  ),
                                                  'Rent',
                                                  getDisplayValue("\$${item.totals!.totalRent!.toStringAsFixed(2)}"),
                                                ),

                                                buildTableRows(
                                                  'Deposit Held',
                                                  getDisplayValue("\$${item.totals!.totalDeposits!.toStringAsFixed(2)
                                                  }"
                                                  ),'',
                                                  "",
                                                  '',
                                                  "",
                                                ),


                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                );
                              }).toList() ??
                                  [const Text("No Active Leases")],
                            ),
                          )
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

          ],
        ),
      ),
    );
  }
  SummeryScreen(rentrollreportmodel data){
    final totals = data.grandTotal;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10,),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
               Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Text(
                  "Grand totals",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),

              _buildSummaryRow("Market Rent", "\$0.00"),
              _buildSummaryRow("Rent", "\$${totals!.totalRent!.toStringAsFixed(2)}"),
              _buildSummaryRow("Recurring Charges", "\$${totals!.totalCharges!.toStringAsFixed(2)}"),
              _buildSummaryRow("Recurring Credits", "\$${totals!.totalCredits!.toStringAsFixed(2)}"),
              _buildSummaryRow("Deposits Held", "\$${totals!.totalDeposits!.toStringAsFixed(2)}"),
              _buildSummaryRow("Balance Due", "\$${totals!.totalBalanceDue!.toStringAsFixed(2)}"),
            ],
          ),
        ),
        Summerybybedbath(data.bedBathSummary!),
        Summerybyproperty(data.propertySummary!)
      ],
    );
  }
  bool isRowExpanded = false ;
  bool isRowPropertyExpanded = false ;
  int? expandedRowbedbathIndex ;
  int? expandedRowPropertyIndex ;
  Summerybybedbath(BedBathSummaryData data){

    final currentPageData = data.bedBathSummary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Summery by Bed/Bath",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: blueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              !isdisplaysummeryBedbath?
              GestureDetector(
                onTap: (){
                  setState(() {
                    isdisplaysummeryBedbath = !isdisplaysummeryBedbath;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: FaIcon(FontAwesomeIcons.squareCaretDown),
                ),
              ) : GestureDetector(
                onTap: (){
                  setState(() {
                    isdisplaysummeryBedbath = !isdisplaysummeryBedbath;
                  });

                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: FaIcon(FontAwesomeIcons.squareCaretUp),
                ),
              )
            ],
          ),
        ),
        if(isdisplaysummeryBedbath)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildHeadersforsummery("Bed/Bath","No.Of Units"),
        ),
        if(isdisplaysummeryBedbath)
        SizedBox(height: 20,),
        if(isdisplaysummeryBedbath)
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
          ),
          child: Column(
            children: [

              Column(
                children: currentPageData!.asMap().entries.map((entry) {
                  int rowIndex = entry.key;
                  var item = entry.value;
                  bool isRowExpanded = expandedRowbedbathIndex == rowIndex;

                  return Container(
                    decoration: BoxDecoration(
                      color: rowIndex % 2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                      border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
                    ),
                    child: Column(
                      children: <Widget>[
                        // Row header
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (expandedRowbedbathIndex == rowIndex) {
                                        expandedRowbedbathIndex = null;
                                      } else {
                                        expandedRowbedbathIndex = rowIndex;
                                        nestedExpandedIndex = null; // reset inner when switching rows
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
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    '${item.bedBath ?? '-'}',
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${item.units!.toStringAsFixed(0) ?? '-'}',
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
                        if(isRowExpanded)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                                child: Text(
                                  "Occupancy",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                                child: Divider(thickness: 2,),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                                child: Row(
                                  children: [

                                    Expanded(
                                      child: Table(
                                        columnWidths: {
                                          // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                          // 1: FlexColumnWidth(),
                                          0: FlexColumnWidth(), // Distribute columns equally
                                          1: FlexColumnWidth(),
                                          2: FlexColumnWidth(),
                                        },
                                        children: [

                                          buildTableRows(
                                            'Vacant',
                                            getDisplayValue("${item.vacantUnits
                                            }"
                                            ),'Occupied',
                                            getDisplayValue("${item.occupiedUnits}"),
                                            '%Occupied',
                                            getDisplayValue("${item.occupancyRate}"),
                                          ),


                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                                child: Text(
                                  "Market Rent",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                                child: Divider(thickness: 2,),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                                child: Row(
                                  children: [

                                    Expanded(
                                      child: Table(
                                        columnWidths: {
                                          // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                          // 1: FlexColumnWidth(),
                                          0: FlexColumnWidth(), // Distribute columns equally
                                          1: FlexColumnWidth(),
                                          2: FlexColumnWidth(),
                                        },
                                        children: [

                                          buildTableRows(
                                            'Total',
                                            getDisplayValue("${item.totalRent
                                            }"
                                            ),'Average',
                                            getDisplayValue("${item.avgRent}"),
                                            'Avg./Sq.Ft.',
                                            getDisplayValue("${item.avgRentPerSqFt}"),
                                          ),


                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                                child: Text(
                                  "Square Feet",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                                child: Divider(thickness: 2,),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                                child: Row(
                                  children: [

                                    Expanded(
                                      child: Table(
                                        columnWidths: {
                                          // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                          // 1: FlexColumnWidth(),
                                          0: FlexColumnWidth(), // Distribute columns equally
                                          1: FlexColumnWidth(),
                                          2: FlexColumnWidth(),
                                        },
                                        children: [

                                          buildTableRows(
                                            'Total',
                                            getDisplayValue("${item.totalSqFt
                                            }"
                                            ),'Average',
                                            getDisplayValue("${item.avgSqFt}"),
                                            '',
                                            '',
                                          ),


                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        // Outer expanded section

                      ],
                    ),
                  );
                }).toList(),
              ),
              Container(
                decoration: BoxDecoration(
                  color: currentPageData.length % 2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                  border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
                ),
                child: Column(
                  children: <Widget>[
                    // Row header
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (expandedRowbedbathIndex == currentPageData.length+1) {
                                    expandedRowbedbathIndex = null;
                                    isRowExpanded = true;
                                  } else {
                                    expandedRowbedbathIndex = currentPageData.length+1;
                                    isRowExpanded = false;
                                    nestedExpandedIndex = null; // reset inner when switching rows
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
                            SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Total and Averages',
                                style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${data.totalsAndAveragesBedBath!.totalUnits ?? '-'}',
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
                    if(isRowExpanded)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                            child: Text(
                              "Occupancy",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                            child: Divider(thickness: 2,),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                            child: Row(
                              children: [

                                Expanded(
                                  child: Table(
                                    columnWidths: {
                                      // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                      // 1: FlexColumnWidth(),
                                      0: FlexColumnWidth(), // Distribute columns equally
                                      1: FlexColumnWidth(),
                                      2: FlexColumnWidth(),
                                    },
                                    children: [

                                      buildTableRows(
                                        'Vacant',
                                        getDisplayValue("${data.totalsAndAveragesBedBath!.totalVacantUnits
                                        }"
                                        ),'Occupied',
                                        getDisplayValue("${data.totalsAndAveragesBedBath!.totalOccupiedUnits}"),
                                        '%Occupied',
                                        getDisplayValue("${data.totalsAndAveragesBedBath!.avgOccupancyRate}"),
                                      ),


                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                            child: Text(
                              "Market Rent",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                            child: Divider(thickness: 2,),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                            child: Row(
                              children: [

                                Expanded(
                                  child: Table(
                                    columnWidths: {
                                      // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                      // 1: FlexColumnWidth(),
                                      0: FlexColumnWidth(), // Distribute columns equally
                                      1: FlexColumnWidth(),
                                      2: FlexColumnWidth(),
                                    },
                                    children: [

                                      buildTableRows(
                                        'Total',
                                        getDisplayValue("${data.totalsAndAveragesBedBath!.totalMarketRent
                                        }"
                                        ),'Average',
                                        getDisplayValue("${data.totalsAndAveragesBedBath!.avgMarketRent}"),
                                        'Avg./Sq.Ft.',
                                        getDisplayValue("${data.totalsAndAveragesBedBath!.avgMarketRentPerSqFt}"),
                                      ),


                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                            child: Text(
                              "Square Feet",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                            child: Divider(thickness: 2,),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                            child: Row(
                              children: [

                                Expanded(
                                  child: Table(
                                    columnWidths: {
                                      // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                      // 1: FlexColumnWidth(),
                                      0: FlexColumnWidth(), // Distribute columns equally
                                      1: FlexColumnWidth(),
                                      2: FlexColumnWidth(),
                                    },
                                    children: [

                                      buildTableRows(
                                        'Total',
                                        getDisplayValue("${data.totalsAndAveragesBedBath!.totalSqFt
                                        }"
                                        ),'Average',
                                        getDisplayValue("${data.totalsAndAveragesBedBath!.avgSqFt}"),
                                        '',
                                        '',
                                      ),


                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    // Outer expanded section

                  ],
                ),
              ),
            ],
          ),
        ),

      ],
    );
  }

  Summerybyproperty(PropertySummaryData data){

    final currentPageData = data.propertySummary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Summery by Property",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: blueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              !isdisplaysummeryProperty?
              GestureDetector(
                onTap: (){
                  setState(() {
                    isdisplaysummeryProperty = !isdisplaysummeryProperty;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: FaIcon(FontAwesomeIcons.squareCaretDown,),
                ),
              ) : GestureDetector(
                onTap: (){
                  setState(() {
                    isdisplaysummeryProperty = !isdisplaysummeryProperty;
                  });

                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: FaIcon(FontAwesomeIcons.squareCaretUp),
                ),
              )
            ],
          ),
        ),
        if(isdisplaysummeryProperty)
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: _buildHeadersforsummery("Property","No.Of Units"),
        ),
        if(isdisplaysummeryProperty)
        SizedBox(height: 20,),
        if(isdisplaysummeryProperty)
        Container(
          margin: EdgeInsets.symmetric(horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
          ),
          child: Column(
            children: [
              Column(
                children: currentPageData!.asMap().entries.map((entry) {
                  int rowIndex = entry.key;
                  var item = entry.value;
                  bool isRowExpanded = expandedRowPropertyIndex == rowIndex;

                  return Container(
                    decoration: BoxDecoration(
                      color: rowIndex % 2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                      border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
                    ),
                    child: Column(
                      children: <Widget>[
                        // Row header
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      if (expandedRowPropertyIndex == rowIndex) {
                                        expandedRowPropertyIndex = null;
                                      } else {
                                        expandedRowPropertyIndex = rowIndex;
                                        nestedExpandedIndex = null; // reset inner when switching rows
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
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    '${item.property ?? '-'}',
                                    style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '${item.units!.toStringAsFixed(0) ?? '-'}',
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
                        if(isRowExpanded)
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                                child: Text(
                                  "Occupancy",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                                child: Divider(thickness: 2,),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                                child: Row(
                                  children: [

                                    Expanded(
                                      child: Table(
                                        columnWidths: {
                                          // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                          // 1: FlexColumnWidth(),
                                          0: FlexColumnWidth(), // Distribute columns equally
                                          1: FlexColumnWidth(),
                                          2: FlexColumnWidth(),
                                        },
                                        children: [

                                          buildTableRows(
                                            'Vacant',
                                            getDisplayValue("${item.vacantUnits
                                            }"
                                            ),'Occupied',
                                            getDisplayValue("${item.occupiedUnits}"),
                                            '%Occupied',
                                            getDisplayValue("${item.occupancyRate}"),
                                          ),


                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                                child: Text(
                                  "Market Rent",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                                child: Divider(thickness: 2,),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                                child: Row(
                                  children: [

                                    Expanded(
                                      child: Table(
                                        columnWidths: {
                                          // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                          // 1: FlexColumnWidth(),
                                          0: FlexColumnWidth(), // Distribute columns equally
                                          1: FlexColumnWidth(),
                                          2: FlexColumnWidth(),
                                        },
                                        children: [

                                          buildTableRows(
                                            'Total',
                                            getDisplayValue("${item.totalRent
                                            }"
                                            ),'Average',
                                            getDisplayValue("${item.avgRent}"),
                                            'Avg./Sq.Ft.',
                                            getDisplayValue("${item.avgRentPerSqFt}"),
                                          ),


                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                                child: Text(
                                  "Square Feet",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                                child: Divider(thickness: 2,),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                                child: Row(
                                  children: [

                                    Expanded(
                                      child: Table(
                                        columnWidths: {
                                          // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                          // 1: FlexColumnWidth(),
                                          0: FlexColumnWidth(), // Distribute columns equally
                                          1: FlexColumnWidth(),
                                          2: FlexColumnWidth(),
                                        },
                                        children: [

                                          buildTableRows(
                                            'Total',
                                            getDisplayValue("${item.totalSqFt
                                            }"
                                            ),'Average',
                                            getDisplayValue("${item.avgSqFt}"),
                                            '',
                                            '',
                                          ),


                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        // Outer expanded section

                      ],
                    ),
                  );
                }).toList(),
              ),
              Container(
                decoration: BoxDecoration(
                  color: currentPageData.length % 2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                  border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
                ),
                child: Column(
                  children: <Widget>[
                    // Row header
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                setState(() {
                                  if (expandedRowPropertyIndex == currentPageData.length) {
                                    expandedRowPropertyIndex = null;
                                    isRowPropertyExpanded = true;
                                  } else {
                                    expandedRowPropertyIndex = currentPageData.length;
                                    isRowPropertyExpanded = false;
                                    nestedExpandedIndex = null; // reset inner when switching rows
                                  }
                                });

                                print("isRowPropertyExpanded $isRowPropertyExpanded");
                              },
                              child: Container(
                                margin: const EdgeInsets.only(left: 5),
                                padding: !isRowPropertyExpanded
                                    ? const EdgeInsets.only(bottom: 10)
                                    : const EdgeInsets.only(top: 10),
                                child: FaIcon(
                                  isRowPropertyExpanded
                                      ? FontAwesomeIcons.sortUp
                                      : FontAwesomeIcons.sortDown,
                                  size: 20,
                                  color: blueColor,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              flex: 4,
                              child: Text(
                                'Total and Averages',
                                style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${data.totalsAndAveragesProperty!.totalUnits ?? '-'}',
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
                    if(isRowPropertyExpanded)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                            child: Text(
                              "Occupancy",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                            child: Divider(thickness: 2,),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                            child: Row(
                              children: [

                                Expanded(
                                  child: Table(
                                    columnWidths: {
                                      // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                      // 1: FlexColumnWidth(),
                                      0: FlexColumnWidth(), // Distribute columns equally
                                      1: FlexColumnWidth(),
                                      2: FlexColumnWidth(),
                                    },
                                    children: [

                                      buildTableRows(
                                        'Vacant',
                                        getDisplayValue("${data.totalsAndAveragesProperty!.totalVacantUnits
                                        }"
                                        ),'Occupied',
                                        getDisplayValue("${data.totalsAndAveragesProperty!.totalOccupiedUnits}"),
                                        '%Occupied',
                                        getDisplayValue("${data.totalsAndAveragesProperty!.avgOccupancyRate}"),
                                      ),


                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                            child: Text(
                              "Market Rent",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                            child: Divider(thickness: 2,),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                            child: Row(
                              children: [

                                Expanded(
                                  child: Table(
                                    columnWidths: {
                                      // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                      // 1: FlexColumnWidth(),
                                      0: FlexColumnWidth(), // Distribute columns equally
                                      1: FlexColumnWidth(),
                                      2: FlexColumnWidth(),
                                    },
                                    children: [

                                      buildTableRows(
                                        'Total',
                                        getDisplayValue("${data.totalsAndAveragesProperty!.totalMarketRent
                                        }"
                                        ),'Average',
                                        getDisplayValue("${data.totalsAndAveragesProperty!.avgMarketRent}"),
                                        'Avg./Sq.Ft.',
                                        getDisplayValue("${data.totalsAndAveragesProperty!.avgMarketRentPerSqFt}"),
                                      ),


                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                            child: Text(
                              "Square Feet",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 0),
                            child: Divider(thickness: 2,),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                            child: Row(
                              children: [

                                Expanded(
                                  child: Table(
                                    columnWidths: {
                                      // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                      // 1: FlexColumnWidth(),
                                      0: FlexColumnWidth(), // Distribute columns equally
                                      1: FlexColumnWidth(),
                                      2: FlexColumnWidth(),
                                    },
                                    children: [

                                      buildTableRows(
                                        'Total',
                                        getDisplayValue("${data.totalsAndAveragesProperty!.totalSqFt
                                        }"
                                        ),'Average',
                                        getDisplayValue("${data.totalsAndAveragesProperty!.avgSqFt}"),
                                        '',
                                        '',
                                      ),


                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    // Outer expanded section

                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 30,)
      ],
    );
  }
  Widget _buildSummaryRow(String title, String amount) {
    return Column(
      children: [
        const Divider(height: 3,color: Colors.black,),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style:  TextStyle(fontSize: 14,color: blueColor)),
              Text(amount, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),

      ],
    );
  }
  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
        //    _tabController.index = index;
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? blueColor : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  TableRow buildTableRows(
      String leftLabel, String leftValue, String centerLabel, String centerValue,String rightLabel, String rightValue) {
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
                  style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
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
                  centerLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                SizedBox(height: 4.0), // Space between label and value
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
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
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
