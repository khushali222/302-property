import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:csv/csv.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:three_zero_two_property/StaffModule/repository/rentrollreportrepo.dart';
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

import '../../../widgets/custom_drawer.dart';
import 'package:http/http.dart' as http;

class RentersInsurances extends StatefulWidget {
  @override
  State<RentersInsurances> createState() => _RentersInsurancesState();
}

class _RentersInsurancesState extends State<RentersInsurances> {
  late Future<rentrollreportmodel> _futureRentersInsurance;
  rentrollreportmodel? rentersInsuranceModel;
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
    _futureRentersInsurance = fetchRentersInsuranceData();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  Future<rentrollreportmodel> fetchRentersInsuranceData({String? id}) async {
    RentRollReportService service = RentRollReportService();
    try {
      rentrollreportmodel data =
          await service.fetchRentRollreport(rentalOwnerId: id);
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
                child: const Row(
                  children: [
                    Text("Lease Start", style: TextStyle(color: Colors.white)),
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
                child: const Row(
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

  pw.Widget leftAlignedText(String text, {bool isBold = false}) {
    return pw.Align(
      alignment: pw.Alignment.centerLeft,
      child: pw.Text(
        text,
        style: isBold
            ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)
            : const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  pw.Widget rightAlignedText(String text, {bool isBold = false}) {
    return pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text(
        text,
        style: isBold
            ? pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)
            : const pw.TextStyle(fontSize: 10),
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
                          ? Text("   $h1",
                              style: const TextStyle(color: Colors.white))
                          : Text("   $h1",
                              style: const TextStyle(color: Colors.white)),
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
                    Text("  $h2", style: const TextStyle(color: Colors.white)),
                    const SizedBox(width: 5),
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

  List<Map<String, dynamic>> rentalowners = [];
  Future<void> fetchRentalOwners() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminid = prefs.getString("adminId");
    String? id = prefs.getString("staff_id");
    String? token = prefs.getString('token');
    final response = await http.get(
        Uri.parse('${Api_url}/api/rentals/rental-owners/$adminid'),
        headers: {
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

        // Sort rental owners alphabetically by name (excluding "All" option)
        rentalowners.sort((a, b) {
          String nameA = a['rentalOwner_name']?.toString() ?? '';
          String nameB = b['rentalOwner_name']?.toString() ?? '';
          return nameA.toLowerCase().compareTo(nameB.toLowerCase());
        });

        // Insert "All" option at the beginning after sorting
        rentalowners.insert(0, {
          "rentalowner_id": "all",
          "rentalOwner_name": "All",
        });
      });
      // log(rentalowners.toString());
    } else {
      throw Exception('Failed to load data');
    }
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

    final headers = [
      {'title': 'Unit', 'flex': 1},
      {'title': 'Tenants', 'flex': 2},
      {'title': 'Lease Start', 'flex': 1},
      {'title': 'Lease End', 'flex': 1},
      {'title': 'Bed/Bath', 'flex': 1},
      {'title': 'Rent Cycle', 'flex': 1},
      {'title': 'Rent Start', 'flex': 1},
      {'title': 'Rent', 'flex': 1},
      {'title': 'Charges', 'flex': 1},
      {'title': 'Credits', 'flex': 1},
      {'title': 'Total', 'flex': 1},
      {'title': 'Deposits', 'flex': 1},
      {'title': 'Prepayments', 'flex': 1},
      {'title': 'Balance', 'flex': 1},
    ];

    // Table Data
    final tableData = data.bedBathSummary!.bedBathSummary?.map((item) {
          return [
            leftAlignedText(item.bedBath ?? ''),
            rightAlignedText(item.units?.toStringAsFixed(0) ?? '0'),
            rightAlignedText(item.vacantUnits?.toStringAsFixed(0) ?? '0'),
            rightAlignedText(item.occupiedUnits?.toStringAsFixed(0) ?? '0'),
            rightAlignedText("${item.occupancyRate}%" ?? '0.00%'),
            rightAlignedText(item.totalSqFt?.toStringAsFixed(0) ?? '0'),
            rightAlignedText(item.avgSqFt ?? '0.00'),
            rightAlignedText(item.totalRent ?? '0.00'),
            rightAlignedText(item.avgRent ?? '0.00'),
            rightAlignedText(item.avgRentPerSqFt ?? '0.00'),
          ];
        }).toList() ??
        [];

    // Add Totals and Averages
    final totalRow = [
      leftAlignedText('Totals and Averages', isBold: true),
      rightAlignedText(
          data.bedBathSummary!.totalsAndAveragesBedBath?.totalUnits
                  ?.toStringAsFixed(0) ??
              '0',
          isBold: true),
      rightAlignedText(
          data.bedBathSummary!.totalsAndAveragesBedBath?.totalVacantUnits
                  ?.toStringAsFixed(0) ??
              '0',
          isBold: true),
      rightAlignedText(
          data.bedBathSummary!.totalsAndAveragesBedBath?.totalOccupiedUnits
                  ?.toStringAsFixed(0) ??
              '0',
          isBold: true),
      rightAlignedText(
          "${data.bedBathSummary!.totalsAndAveragesBedBath?.avgOccupancyRate}%" ??
              '0.00%',
          isBold: true),
      rightAlignedText(
          data.bedBathSummary!.totalsAndAveragesBedBath?.totalSqFt
                  ?.toStringAsFixed(0) ??
              '0',
          isBold: true),
      rightAlignedText(
          data.bedBathSummary!.totalsAndAveragesBedBath?.avgSqFt ?? '0.00',
          isBold: true),
      rightAlignedText(
          data.bedBathSummary!.totalsAndAveragesBedBath?.totalMarketRent ??
              '0.00',
          isBold: true),
      rightAlignedText(
          data.bedBathSummary!.totalsAndAveragesBedBath?.avgMarketRent ??
              '0.00',
          isBold: true),
      rightAlignedText(
          data.bedBathSummary!.totalsAndAveragesBedBath?.avgMarketRentPerSqFt ??
              '0.00',
          isBold: true),
    ];

    final tablePropertyData =
        data.propertySummary!.propertySummary?.map((item) {
              return [
                leftAlignedText(item.property ?? ''),
                rightAlignedText(item.units?.toStringAsFixed(0) ?? '0'),
                rightAlignedText(item.vacantUnits?.toStringAsFixed(0) ?? '0'),
                rightAlignedText(item.occupiedUnits?.toStringAsFixed(0) ?? '0'),
                rightAlignedText("${item.occupancyRate}%" ?? '0.00%'),
                rightAlignedText(item.totalSqFt?.toStringAsFixed(0) ?? '0'),
                rightAlignedText(item.avgSqFt ?? '0.00'),
                rightAlignedText(item.totalRent ?? '0.00'),
                rightAlignedText(item.avgRent ?? '0.00'),
                rightAlignedText(item.avgRentPerSqFt ?? '0.00'),
              ];
            }).toList() ??
            [];

    // Add Totals and Averages
    final totalPropertyRow = [
      leftAlignedText('Totals and Averages', isBold: true),
      rightAlignedText(
          data.propertySummary!.totalsAndAveragesProperty?.totalUnits
                  ?.toStringAsFixed(0) ??
              '0',
          isBold: true),
      rightAlignedText(
          data.propertySummary!.totalsAndAveragesProperty?.totalVacantUnits
                  ?.toStringAsFixed(0) ??
              '0',
          isBold: true),
      rightAlignedText(
          data.propertySummary!.totalsAndAveragesProperty?.totalOccupiedUnits
                  ?.toStringAsFixed(0) ??
              '0',
          isBold: true),
      rightAlignedText(
          "${data.propertySummary!.totalsAndAveragesProperty?.avgOccupancyRate}%" ??
              '0.00%',
          isBold: true),
      rightAlignedText(
          data.propertySummary!.totalsAndAveragesProperty?.totalSqFt
                  ?.toStringAsFixed(0) ??
              '0',
          isBold: true),
      rightAlignedText(
          data.propertySummary!.totalsAndAveragesProperty?.avgSqFt ?? '0.00',
          isBold: true),
      rightAlignedText(
          data.propertySummary!.totalsAndAveragesProperty?.totalMarketRent ??
              '0.00',
          isBold: true),
      rightAlignedText(
          data.propertySummary!.totalsAndAveragesProperty?.avgMarketRent ??
              '0.00',
          isBold: true),
      rightAlignedText(
          data.propertySummary!.totalsAndAveragesProperty
                  ?.avgMarketRentPerSqFt ??
              '0.00',
          isBold: true),
    ];

    var rentalOwer;
    if (selectedOwner == "all" || selectedOwner == null) {
      rentalOwer = "All";
    } else {
      var Ower = rentalowners
          .firstWhere((test) => test["rentalowner_id"] == selectedOwner);
      rentalOwer = Ower["rentalOwner_name"];
    }
    tableData.add(totalRow);
    tablePropertyData.add(totalPropertyRow);
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Header
            pw.Header(
              level: 0,
              padding: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Image(image, width: 40, height: 40),
                  pw.Column(
                    children: [
                      pw.Text(
                        'Rent Roll Report',
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold),
                      ),
                      pw.SizedBox(height: 5),
                      pw.Text(
                          'As of $currentDate-$rentalOwer Current Leases, All Units',
                          style: const pw.TextStyle(fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(profileData?.companyName ?? 'N/A',
                          style: pw.TextStyle(
                              fontSize: 9, fontWeight: pw.FontWeight.bold)),
                      pw.Text(profileData?.companyAddress ?? 'N/A',
                          style: const pw.TextStyle(fontSize: 8)),
                      pw.Text(
                        '${profileData?.companyCity ?? ''}, ${profileData?.companyState ?? ''}, ${profileData?.companyCountry ?? ''}',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(profileData?.companyPostalCode ?? '',
                          style: const pw.TextStyle(fontSize: 8)),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 8),

            // Table Header
            pw.Table.fromTextArray(
                headerStyle: headerStyle,
                cellStyle: cellStyle,
                headerDecoration: headerDecoration,
                headerAlignments: {
                  for (int i = 0; i < headers.length; i++)
                    i: headers[i]['title']
                            .toString()
                            .toLowerCase()
                            .contains('tenant')
                        ? pw.Alignment.centerLeft
                        : pw.Alignment.center,
                },
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  for (int i = 0; i < headers.length; i++)
                    i: pw.FlexColumnWidth(
                        double.parse(headers[i]['flex'].toString())),
                },
                headers: headers
                    .map((header) => header['title'].toString())
                    .toList(),
                data: [],
                border: null),

            pw.SizedBox(height: 4),

            // Data
            ...data.rentals!.expand((rental) {
              final List<List<pw.Widget>> leaseRows =
                  rental.activeLeases!.map((leasedata) {
                return [
                  pw.Text(leasedata.unit?.rentalUnit ?? '',
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.Align(
                      alignment: pw.Alignment.centerLeft,
                      child: pw.Text(
                        leasedata.tenants!
                            .map((t) =>
                                "${t.tenantFirstName ?? ''} ${t.tenantLastName ?? ''}")
                            .join(", "),
                        style: const pw.TextStyle(fontSize: 7),
                      )),
                  pw.Text(leasedata.leaseStart ?? '',
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.Text(leasedata.leaseEnd ?? '',
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.Text(leasedata.unit?.bedBath ?? '---',
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.Text(leasedata.rentCycle ?? '',
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.Text(leasedata.leaseStart ?? '',
                      style: const pw.TextStyle(fontSize: 7)),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      formatCurrency(leasedata.rentAmount),
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      formatCurrency(leasedata.chargeAmount),
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      '\$${leasedata.creditAmount?.toStringAsFixed(2) ?? '0.00'}',
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      formatCurrency(leasedata.chargeTotal),
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      formatCurrency(leasedata.depositHeld),
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      formatCurrency(leasedata.prepayments),
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text(
                      formatCurrency(leasedata.balanceDue),
                      style: const pw.TextStyle(fontSize: 7),
                    ),
                  ),
                ];
              }).toList();

              // Render the final table
              final pw.Widget leaseTable = pw.Table.fromTextArray(
                //  headers: tableHeaders,
                data: leaseRows,
                // headerStyle: headerStyle,
                cellStyle: cellStyle,
                // headerDecoration: headerDecoration,
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  for (int i = 0; i < headers.length; i++)
                    i: pw.FlexColumnWidth(
                        double.parse(headers[i]['flex'].toString())),
                },
                border: null, // Optional: add border if needed
              );

              return [
                if (rental.activeLeases!.length > 0) pw.SizedBox(height: 6),
                if (rental.activeLeases!.length > 0)
                  pw.Text(rental.rentalAddress ?? 'Property',
                      style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold, fontSize: 9)),
                if (rental.activeLeases!.length > 0) pw.SizedBox(height: 3),
                ...rental.activeLeases!.map((leasedata) {
                  return pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                          vertical: 2, horizontal: 0),
                      child: leaseTable);
                }),
                if (rental.totals != null && rental.activeLeases!.length > 0)
                  pw.SizedBox(height: 4),
                if (rental.totals != null && rental.activeLeases!.length > 0)
                  pw.Table.fromTextArray(
                    cellAlignment: pw.Alignment.centerLeft,
                    headerDecoration:
                        const pw.BoxDecoration(), // No header style
                    headerHeight: 0, // Hide header row
                    border: null,
                    data: [
                      [
                        pw.Align(
                            alignment: pw.Alignment.centerLeft,
                            child: pw.Text(
                              "Total for ${rental.rentalAddress}",
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.left,
                            )),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              formatCurrency(rental.totals!.totalRent),
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right,
                            )),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              formatCurrency(rental.totals!.totalCharges),
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right,
                            )),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              formatCurrency(rental.totals!.totalCredits),
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right,
                            )),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              formatCurrency(rental.totals!.totalAmount),
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right,
                            )),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              formatCurrency(rental.totals!.totalDeposits),
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right,
                            )),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              formatCurrency(rental.totals!.totalPrepayments),
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right,
                            )),
                        pw.Align(
                            alignment: pw.Alignment.centerRight,
                            child: pw.Text(
                              formatCurrency(rental.totals!.totalBalanceDue),
                              style: pw.TextStyle(
                                  fontSize: 8, fontWeight: pw.FontWeight.bold),
                              textAlign: pw.TextAlign.right,
                            )),
                      ],
                    ],
                    cellStyle: pw.TextStyle(
                        fontSize: 7, fontWeight: pw.FontWeight.bold),
                    columnWidths: {
                      0: const pw.FlexColumnWidth(8),
                      1: const pw.FlexColumnWidth(1),
                      2: const pw.FlexColumnWidth(1),
                      3: const pw.FlexColumnWidth(1),
                      4: const pw.FlexColumnWidth(1),
                      5: const pw.FlexColumnWidth(1),
                      6: const pw.FlexColumnWidth(1),
                      7: const pw.FlexColumnWidth(1),
                    },
                  ),
              ];
            }).toList(),

            ////------------Grand Total..
            pw.SizedBox(height: 100),
            pw.Container(child: pw.Text("  Grand Totals")),
            pw.Container(
              width: 250,
              child: pw.Table.fromTextArray(
                  headerStyle: headerStyle,
                  cellStyle: const pw.TextStyle(fontSize: 10),
                  headerDecoration: headerDecoration,
                  headerAlignments: {
                    for (int i = 0; i < headers.length; i++)
                      i: headers[i]['title']
                              .toString()
                              .toLowerCase()
                              .contains('tenant')
                          ? pw.Alignment.centerLeft
                          : pw.Alignment.center,
                  },
                  cellAlignment: pw.Alignment.centerLeft,
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2), // Date
                    1: const pw.FlexColumnWidth(1.5), // Address
                  },
                  headers: ["", "Amount"],
                  data: [
                    [
                      pw.Text("Market Rent",
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          '\$${'0.00'}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                    [
                      pw.Text("Rent", style: const pw.TextStyle(fontSize: 10)),
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          '\$${data.grandTotal!.totalRent!.toStringAsFixed(2) ?? '0.00'}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                    [
                      pw.Text("Recurring Charges",
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          '\$${data.grandTotal!.totalCharges!.toStringAsFixed(2) ?? "0.0"}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                    [
                      pw.Text("Recurring Credits",
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          '\$${data.grandTotal!.totalCredits!.toStringAsFixed(2) ?? "0.0"}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                    [
                      pw.Text("Deposit Held",
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          '\$${data.grandTotal!.totalCharges!.toStringAsFixed(2) ?? "0.0"}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                    [
                      pw.Text("Balance Due",
                          style: const pw.TextStyle(fontSize: 10)),
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text(
                          '\$${data.grandTotal!.totalBalanceDue!.toStringAsFixed(2) ?? "0.0"}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                  border: null),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                "Summery by Bed/Bath",
                "Occupancy",
                "Square Feet",
                "Market Rent"
              ],
              data: [],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.black,
              ),
              // headerDecoration: headerDecoration,
              cellAlignment: pw.Alignment.centerLeft,
              border: null,
              cellStyle: const pw.TextStyle(fontSize: 10),
              columnWidths: {
                0: const pw.FixedColumnWidth(120),
                1: const pw.FixedColumnWidth(170),
                2: const pw.FixedColumnWidth(220),
                3: const pw.FixedColumnWidth(210),
              },
            ),
            pw.Table.fromTextArray(
              headers: [
                'Bed/Bath',
                'No. of Units',
                'Vacant',
                'Occupied',
                '% Occupied',
                'Total',
                'Avg',
                'Total',
                'Avg',
                'Avg/Sq.Ft.',
              ],
              data: tableData,
              headerStyle: const pw.TextStyle(
                //fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.white,
              ),
              headerDecoration: headerDecoration,
              cellAlignment: pw.Alignment.centerLeft,
              border: null,
              cellStyle: const pw.TextStyle(fontSize: 10),
              columnWidths: {
                0: const pw.FixedColumnWidth(120),
                1: const pw.FixedColumnWidth(40),
                2: const pw.FixedColumnWidth(30),
                3: const pw.FixedColumnWidth(40),
                4: const pw.FixedColumnWidth(50),
                5: const pw.FixedColumnWidth(30),
                6: const pw.FixedColumnWidth(30),
                7: const pw.FixedColumnWidth(30),
                8: const pw.FixedColumnWidth(30),
                9: const pw.FixedColumnWidth(50),
              },
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: [
                "Summery by Property",
                "Occupancy",
                "Square Feet",
                "Market Rent"
              ],
              data: [],
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
                color: PdfColors.black,
              ),
              // headerDecoration: headerDecoration,
              cellAlignment: pw.Alignment.centerLeft,
              border: null,
              cellStyle: const pw.TextStyle(fontSize: 10),
              columnWidths: {
                0: const pw.FixedColumnWidth(120),
                1: const pw.FixedColumnWidth(170),
                2: const pw.FixedColumnWidth(220),
                3: const pw.FixedColumnWidth(210),
              },
            ),
            pw.Table.fromTextArray(
              headers: [
                'Property',
                'No. of Units',
                'Vacant',
                'Occupied',
                '% Occupied',
                'Total',
                'Avg',
                'Total',
                'Avg',
                'Avg/Sq.Ft.',
              ],
              data: tablePropertyData,
              headerStyle: headerStyle,
              headerDecoration: headerDecoration,
              cellAlignment: pw.Alignment.centerLeft,
              border: null,
              cellStyle: const pw.TextStyle(fontSize: 10),
              columnWidths: {
                0: const pw.FixedColumnWidth(120),
                1: const pw.FixedColumnWidth(60),
                2: const pw.FixedColumnWidth(50),
                3: const pw.FixedColumnWidth(60),
                4: const pw.FixedColumnWidth(80),
                5: const pw.FixedColumnWidth(70),
                6: const pw.FixedColumnWidth(70),
                7: const pw.FixedColumnWidth(70),
                8: const pw.FixedColumnWidth(70),
                9: const pw.FixedColumnWidth(70),
              },
            )
          ];
        },
      ),
    );
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> generateRentersInsuranceExcel(rentrollreportmodel data) async {
    // Create a new Excel workbook
    final syncXlsx.Workbook workbook = syncXlsx.Workbook();
    final syncXlsx.Worksheet sheet = workbook.worksheets[0];
    sheet.name = 'Rent Roll Report';

    // Set the current date
    final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    // Add header information

    // Add column headers
    final headers = [
      'Unit',
      'Tenants',
      'Lease Start',
      'Lease End',
      'Bed/Bath',
      'Rent Cycle',
      'Rent Start',
      'Rent',
      'Charges',
      'Credits',
      'Total',
      'Deposits',
      'Prepayments',
      'Balance'
    ];

    for (int i = 0; i < headers.length; i++) {
      sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      sheet.getRangeByIndex(1, i + 1).cellStyle.bold = true;
      sheet.getRangeByIndex(1, i + 1).cellStyle.backColor = '#1E88E5';
      sheet.getRangeByIndex(1, i + 1).cellStyle.fontColor = '#FFFFFF';
      sheet.getRangeByIndex(1, i + 1).cellStyle.hAlign = headers[i] == 'Tenants'
          ? syncXlsx.HAlignType.left
          : syncXlsx.HAlignType.center;
    }

    // Add rental data
    int rowIndex = 2; // Starting after headers
    for (var rental in data.rentals!) {
      if (rental.activeLeases!.length == 0) {
        continue;
      }
      // Add property address as a header
      sheet
          .getRangeByIndex(rowIndex, 1)
          .setText(rental.rentalAddress ?? 'Property');
      sheet.getRangeByIndex(rowIndex, 1, rowIndex, headers.length).merge();
      sheet.getRangeByIndex(rowIndex, 1).cellStyle.bold = true;
      sheet.getRangeByIndex(rowIndex, 1).cellStyle.fontSize = 12;
      rowIndex++;

      for (var lease in rental.activeLeases!) {
        sheet
            .getRangeByIndex(rowIndex, 1)
            .setText(lease.unit?.rentalUnit ?? '');
        sheet.getRangeByIndex(rowIndex, 2).setText(lease.tenants!
            .map((t) => "${t.tenantFirstName ?? ''} ${t.tenantLastName ?? ''}")
            .join(", "));
        sheet.getRangeByIndex(rowIndex, 3).setText(lease.leaseStart ?? '');
        sheet.getRangeByIndex(rowIndex, 4).setText(lease.leaseEnd ?? '');
        sheet
            .getRangeByIndex(rowIndex, 5)
            .setText(lease.unit?.bedBath ?? '---');
        sheet.getRangeByIndex(rowIndex, 6).setText(lease.rentCycle ?? '');
        sheet.getRangeByIndex(rowIndex, 7).setText(lease.leaseStart ?? '');
        sheet.getRangeByIndex(rowIndex, 8).setNumber(lease.rentAmount ?? 0.0);
        sheet.getRangeByIndex(rowIndex, 9).setNumber(lease.chargeAmount ?? 0.0);
        sheet
            .getRangeByIndex(rowIndex, 10)
            .setNumber(lease.creditAmount ?? 0.0);
        sheet.getRangeByIndex(rowIndex, 11).setNumber(lease.chargeTotal ?? 0.0);
        sheet.getRangeByIndex(rowIndex, 12).setNumber(lease.depositHeld ?? 0.0);
        sheet.getRangeByIndex(rowIndex, 13).setNumber(lease.prepayments ?? 0.0);
        sheet.getRangeByIndex(rowIndex, 14).setNumber(lease.balanceDue ?? 0.0);

        // Format numbers with 2 decimal places
        for (int col = 8; col <= 14; col++) {
          sheet.getRangeByIndex(rowIndex, col).numberFormat = '\$#,##0.00';
        }

        rowIndex++;
      }

      // Add property totals
      if (rental.totals != null) {
        sheet
            .getRangeByIndex(rowIndex, 1)
            .setText("Total for ${rental.rentalAddress}");
        sheet
            .getRangeByIndex(rowIndex, 8)
            .setNumber(rental.totals!.totalRent ?? 0.0);
        sheet
            .getRangeByIndex(rowIndex, 9)
            .setNumber(rental.totals!.totalCharges ?? 0.0);
        sheet
            .getRangeByIndex(rowIndex, 10)
            .setNumber(rental.totals!.totalCredits ?? 0.0);
        sheet
            .getRangeByIndex(rowIndex, 11)
            .setNumber(rental.totals!.totalAmount ?? 0.0);
        sheet
            .getRangeByIndex(rowIndex, 12)
            .setNumber(rental.totals!.totalDeposits ?? 0.0);
        sheet
            .getRangeByIndex(rowIndex, 13)
            .setNumber(rental.totals!.totalPrepayments ?? 0.0);
        sheet
            .getRangeByIndex(rowIndex, 14)
            .setNumber(rental.totals!.totalBalanceDue ?? 0.0);

        // Style for totals row
        for (int col = 1; col <= 14; col++) {
          sheet.getRangeByIndex(rowIndex, col).cellStyle.bold = true;
          if (col >= 8) {
            sheet.getRangeByIndex(rowIndex, col).numberFormat = '\$#,##0.00';
          }
        }
        rowIndex++;
      }
      rowIndex++; // Add extra space between properties
    }

    // Add grand totals section
    sheet.getRangeByIndex(rowIndex, 1).setText('Grand Totals');
    sheet.getRangeByIndex(rowIndex, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(rowIndex, 1).cellStyle.fontSize = 12;
    rowIndex++;

    sheet.getRangeByIndex(rowIndex, 1, rowIndex, 3).setText("");
    sheet.getRangeByIndex(rowIndex, 1, rowIndex, 3).cellStyle.bold = true;
    sheet.getRangeByIndex(rowIndex, 1, rowIndex, 3).cellStyle.backColor =
        '#1E88E5';
    sheet.getRangeByIndex(rowIndex, 1, rowIndex, 3).cellStyle.fontColor =
        '#FFFFFF';
    sheet.getRangeByIndex(rowIndex, 1, rowIndex, 3).cellStyle.hAlign =
        syncXlsx.HAlignType.center;
    sheet.getRangeByIndex(rowIndex, 4).setText("Amount");
    sheet.getRangeByIndex(rowIndex, 4).cellStyle.bold = true;
    sheet.getRangeByIndex(rowIndex, 4).cellStyle.backColor = '#1E88E5';
    sheet.getRangeByIndex(rowIndex, 4).cellStyle.fontColor = '#FFFFFF';
    sheet.getRangeByIndex(rowIndex, 4).cellStyle.hAlign =
        syncXlsx.HAlignType.center;
    rowIndex++;

    sheet.getRangeByIndex(rowIndex, 1).setText('Market Rent');
    sheet.getRangeByIndex(rowIndex, 4).setNumber(0.0);
    sheet.getRangeByIndex(rowIndex, 4).numberFormat = '\$#,##0.00';
    rowIndex++;

    sheet.getRangeByIndex(rowIndex, 1).setText('Rent');
    sheet
        .getRangeByIndex(rowIndex, 4)
        .setNumber(data.grandTotal!.totalRent ?? 0.0);
    sheet.getRangeByIndex(rowIndex, 4).numberFormat = '\$#,##0.00';
    rowIndex++;

    sheet.getRangeByIndex(rowIndex, 1).setText('Recurring Charges');
    sheet
        .getRangeByIndex(rowIndex, 4)
        .setNumber(data.grandTotal!.totalCharges ?? 0.0);
    sheet.getRangeByIndex(rowIndex, 4).numberFormat = '\$#,##0.00';
    rowIndex++;

    sheet.getRangeByIndex(rowIndex, 1).setText('Recurring Credits');
    sheet
        .getRangeByIndex(rowIndex, 4)
        .setNumber(data.grandTotal!.totalCredits ?? 0.0);
    sheet.getRangeByIndex(rowIndex, 4).numberFormat = '\$#,##0.00';
    rowIndex++;

    sheet.getRangeByIndex(rowIndex, 1).setText('Deposit Held');
    sheet
        .getRangeByIndex(rowIndex, 4)
        .setNumber(data.grandTotal!.totalDeposits ?? 0.0);
    sheet.getRangeByIndex(rowIndex, 4).numberFormat = '\$#,##0.00';
    rowIndex++;

    sheet.getRangeByIndex(rowIndex, 1).setText('Balance Due');
    sheet
        .getRangeByIndex(rowIndex, 4)
        .setNumber(data.grandTotal!.totalBalanceDue ?? 0.0);
    sheet.getRangeByIndex(rowIndex, 4).numberFormat = '\$#,##0.00';
    rowIndex += 2;

    // Add Bed/Bath Summary
    sheet.getRangeByIndex(rowIndex, 1).setText('Summary by Bed/Bath');
    sheet.getRangeByIndex(rowIndex, 1, rowIndex, 10).merge();
    sheet.getRangeByIndex(rowIndex, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(rowIndex, 1).cellStyle.fontSize = 12;
    rowIndex++;

    final bedBathHeaders = [
      'Bed/Bath',
      'No. of Units',
      'Vacant',
      'Occupied',
      '% Occupied',
      'Total Sq.Ft.',
      'Avg Sq.Ft.',
      'Total Rent',
      'Avg Rent',
      'Avg/Sq.Ft.'
    ];

    for (int i = 0; i < bedBathHeaders.length; i++) {
      sheet.getRangeByIndex(rowIndex, i + 1).setText(bedBathHeaders[i]);
      sheet.getRangeByIndex(rowIndex, i + 1).cellStyle.bold = true;
      sheet.getRangeByIndex(rowIndex, i + 1).cellStyle.backColor = '#1E88E5';
      sheet.getRangeByIndex(rowIndex, i + 1).cellStyle.fontColor = '#FFFFFF';
      sheet.getRangeByIndex(rowIndex, i + 1).cellStyle.hAlign =
          syncXlsx.HAlignType.center;
    }
    rowIndex++;

    // Add bed/bath data
    for (var item in data.bedBathSummary!.bedBathSummary ?? []) {
      sheet.getRangeByIndex(rowIndex, 1).setText(item.bedBath ?? '');
      sheet
          .getRangeByIndex(rowIndex, 2)
          .setNumber(item.units?.toDouble() ?? 0.0);
      sheet
          .getRangeByIndex(rowIndex, 3)
          .setNumber(item.vacantUnits?.toDouble() ?? 0.0);
      sheet
          .getRangeByIndex(rowIndex, 4)
          .setNumber(item.occupiedUnits?.toDouble() ?? 0.0);
      sheet
          .getRangeByIndex(rowIndex, 5)
          .setText("${item.occupancyRate}%" ?? '0.00%');
      sheet
          .getRangeByIndex(rowIndex, 6)
          .setNumber(item.totalSqFt?.toDouble() ?? 0.0);
      sheet.getRangeByIndex(rowIndex, 7).setText(item.avgSqFt ?? '0.00');
      sheet.getRangeByIndex(rowIndex, 8).setText(item.totalRent ?? '0.00');
      sheet.getRangeByIndex(rowIndex, 9).setText(item.avgRent ?? '0.00');
      sheet
          .getRangeByIndex(rowIndex, 10)
          .setText(item.avgRentPerSqFt ?? '0.00');
      rowIndex++;
    }

    // Add bed/bath totals
    sheet.getRangeByIndex(rowIndex, 1).setText('Totals and Averages');
    sheet.getRangeByIndex(rowIndex, 2).setNumber(
        data.bedBathSummary!.totalsAndAveragesBedBath?.totalUnits?.toDouble() ??
            0.0);
    sheet.getRangeByIndex(rowIndex, 3).setNumber(data
            .bedBathSummary!.totalsAndAveragesBedBath?.totalVacantUnits
            ?.toDouble() ??
        0.0);
    sheet.getRangeByIndex(rowIndex, 4).setNumber(data
            .bedBathSummary!.totalsAndAveragesBedBath?.totalOccupiedUnits
            ?.toDouble() ??
        0.0);
    sheet.getRangeByIndex(rowIndex, 5).setText(
        "${data.bedBathSummary!.totalsAndAveragesBedBath?.avgOccupancyRate}%" ??
            '0.00%');
    sheet.getRangeByIndex(rowIndex, 6).setNumber(
        data.bedBathSummary!.totalsAndAveragesBedBath?.totalSqFt?.toDouble() ??
            0.0);
    sheet.getRangeByIndex(rowIndex, 7).setText(
        data.bedBathSummary!.totalsAndAveragesBedBath?.avgSqFt ?? '0.00');
    sheet.getRangeByIndex(rowIndex, 8).setText(
        data.bedBathSummary!.totalsAndAveragesBedBath?.totalMarketRent ??
            '0.00');
    sheet.getRangeByIndex(rowIndex, 9).setText(
        data.bedBathSummary!.totalsAndAveragesBedBath?.avgMarketRent ?? '0.00');
    sheet.getRangeByIndex(rowIndex, 10).setText(
        data.bedBathSummary!.totalsAndAveragesBedBath?.avgMarketRentPerSqFt ??
            '0.00');

    // Style for totals row
    for (int col = 1; col <= 10; col++) {
      sheet.getRangeByIndex(rowIndex, col).cellStyle.bold = true;
    }
    rowIndex += 2;

    // Add Property Summary
    sheet.getRangeByIndex(rowIndex, 1).setText('Summary by Property');
    sheet.getRangeByIndex(rowIndex, 1, rowIndex, 10).merge();
    sheet.getRangeByIndex(rowIndex, 1).cellStyle.bold = true;
    sheet.getRangeByIndex(rowIndex, 1).cellStyle.fontSize = 12;
    rowIndex++;

    for (int i = 0; i < bedBathHeaders.length; i++) {
      sheet.getRangeByIndex(rowIndex, i + 1).setText(bedBathHeaders[i]);
      sheet.getRangeByIndex(rowIndex, i + 1).cellStyle.bold = true;
      sheet.getRangeByIndex(rowIndex, i + 1).cellStyle.backColor = '#1E88E5';
      sheet.getRangeByIndex(rowIndex, i + 1).cellStyle.fontColor = '#FFFFFF';
      sheet.getRangeByIndex(rowIndex, i + 1).cellStyle.hAlign =
          syncXlsx.HAlignType.center;
    }
    rowIndex++;

    // Add property data
    for (var item in data.propertySummary!.propertySummary ?? []) {
      sheet.getRangeByIndex(rowIndex, 1).setText(item.property ?? '');
      sheet
          .getRangeByIndex(rowIndex, 2)
          .setNumber(item.units?.toDouble() ?? 0.0);
      sheet
          .getRangeByIndex(rowIndex, 3)
          .setNumber(item.vacantUnits?.toDouble() ?? 0.0);
      sheet
          .getRangeByIndex(rowIndex, 4)
          .setNumber(item.occupiedUnits?.toDouble() ?? 0.0);
      sheet
          .getRangeByIndex(rowIndex, 5)
          .setText("${item.occupancyRate}%" ?? '0.00%');
      sheet
          .getRangeByIndex(rowIndex, 6)
          .setNumber(item.totalSqFt?.toDouble() ?? 0.0);
      sheet.getRangeByIndex(rowIndex, 7).setText(item.avgSqFt ?? '0.00');
      sheet.getRangeByIndex(rowIndex, 8).setText(item.totalRent ?? '0.00');
      sheet.getRangeByIndex(rowIndex, 9).setText(item.avgRent ?? '0.00');
      sheet
          .getRangeByIndex(rowIndex, 10)
          .setText(item.avgRentPerSqFt ?? '0.00');
      rowIndex++;
    }

    // Add property totals
    sheet.getRangeByIndex(rowIndex, 1).setText('Totals and Averages');
    sheet.getRangeByIndex(rowIndex, 2).setNumber(data
            .propertySummary!.totalsAndAveragesProperty?.totalUnits
            ?.toDouble() ??
        0.0);
    sheet.getRangeByIndex(rowIndex, 3).setNumber(data
            .propertySummary!.totalsAndAveragesProperty?.totalVacantUnits
            ?.toDouble() ??
        0.0);
    sheet.getRangeByIndex(rowIndex, 4).setNumber(data
            .propertySummary!.totalsAndAveragesProperty?.totalOccupiedUnits
            ?.toDouble() ??
        0.0);
    sheet.getRangeByIndex(rowIndex, 5).setText(
        "${data.propertySummary!.totalsAndAveragesProperty?.avgOccupancyRate}%" ??
            '0.00%');
    sheet.getRangeByIndex(rowIndex, 6).setNumber(data
            .propertySummary!.totalsAndAveragesProperty?.totalSqFt
            ?.toDouble() ??
        0.0);
    sheet.getRangeByIndex(rowIndex, 7).setText(
        data.propertySummary!.totalsAndAveragesProperty?.avgSqFt ?? '0.00');
    sheet.getRangeByIndex(rowIndex, 8).setText(
        data.propertySummary!.totalsAndAveragesProperty?.totalMarketRent ??
            '0.00');
    sheet.getRangeByIndex(rowIndex, 9).setText(
        data.propertySummary!.totalsAndAveragesProperty?.avgMarketRent ??
            '0.00');
    sheet.getRangeByIndex(rowIndex, 10).setText(
        data.propertySummary!.totalsAndAveragesProperty?.avgMarketRentPerSqFt ??
            '0.00');

    // Style for totals row
    for (int col = 1; col <= 10; col++) {
      sheet.getRangeByIndex(rowIndex, col).cellStyle.bold = true;
    }

    // Set column widths

    // Save the file
    final List<int> bytes = workbook.saveAsStream();
    workbook.dispose();

    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'Daily_transaction_report_$formattedDate.xlsx';

    final Directory directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : Directory('/storage/emulated/0/Pictures');

    final path = '${directory.path}/$fileName';

    // Create directory if it doesn't exist (for Android)
    if (!await directory.exists() && !Platform.isIOS) {
      await directory.create(recursive: true);
    }

    final File file = File(path);
    await file.writeAsBytes(bytes, flush: true);
    Share.shareXFiles([XFile(path)]);
    Fluttertoast.showToast(
      msg: 'Excel file saved to $path',
    );
  }

  Future<void> generateRentersInsuranceCSV(rentrollreportmodel data) async {
    final StringBuffer csvBuffer = StringBuffer();
    final currentDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());

    // Add headers
    final headers = [
      'Unit',
      'Tenants',
      'Lease Start',
      'Lease End',
      'Bed/Bath',
      'Rent Cycle',
      'Rent Start',
      'Rent',
      'Charges',
      'Credits',
      'Total',
      'Deposits',
      'Prepayments',
      'Balance'
    ];
    csvBuffer.writeln(headers.map((h) => '"$h"').join(','));

    // Add rental data
    for (var rental in data.rentals!) {
      if (rental.activeLeases!.isEmpty) {
        continue;
      }

      // Add property address as a header
      csvBuffer.writeln('"${rental.rentalAddress ?? 'Property'}",,,,,,,,,,,,');

      for (var lease in rental.activeLeases!) {
        final row = [
          lease.unit?.rentalUnit ?? '',
          lease.tenants!
              .map(
                  (t) => "${t.tenantFirstName ?? ''} ${t.tenantLastName ?? ''}")
              .join(", "),
          lease.leaseStart ?? '',
          lease.leaseEnd ?? '',
          lease.unit?.bedBath ?? '---',
          lease.rentCycle ?? '',
          lease.leaseStart ?? '',
          lease.rentAmount?.toStringAsFixed(2) ?? '0.00',
          lease.chargeAmount?.toStringAsFixed(2) ?? '0.00',
          lease.creditAmount?.toStringAsFixed(2) ?? '0.00',
          lease.chargeTotal?.toStringAsFixed(2) ?? '0.00',
          lease.depositHeld?.toStringAsFixed(2) ?? '0.00',
          lease.prepayments?.toStringAsFixed(2) ?? '0.00',
          lease.balanceDue?.toStringAsFixed(2) ?? '0.00',
        ];
        csvBuffer.writeln(row
            .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
            .join(','));
      }

      // Add property totals
      if (rental.totals != null) {
        final totalRow = [
          "Total for ${rental.rentalAddress}",
          '',
          '',
          '',
          '',
          '',
          '',
          rental.totals!.totalRent?.toStringAsFixed(2) ?? '0.00',
          rental.totals!.totalCharges?.toStringAsFixed(2) ?? '0.00',
          rental.totals!.totalCredits?.toStringAsFixed(2) ?? '0.00',
          rental.totals!.totalAmount?.toStringAsFixed(2) ?? '0.00',
          rental.totals!.totalDeposits?.toStringAsFixed(2) ?? '0.00',
          rental.totals!.totalPrepayments?.toStringAsFixed(2) ?? '0.00',
          rental.totals!.totalBalanceDue?.toStringAsFixed(2) ?? '0.00',
        ];
        csvBuffer.writeln(totalRow
            .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
            .join(','));
      }
      csvBuffer.writeln(); // Add extra line between properties
    }

    // Add grand totals section
    csvBuffer.writeln('"Grand Totals",,,,,,,,,,,,');
    csvBuffer.writeln('"","","","Amount"');

    final grandTotals = [
      ['Market Rent', '0.00'],
      ['Rent', data.grandTotal!.totalRent?.toStringAsFixed(2) ?? '0.00'],
      [
        'Recurring Charges',
        data.grandTotal!.totalCharges?.toStringAsFixed(2) ?? '0.00'
      ],
      [
        'Recurring Credits',
        data.grandTotal!.totalCredits?.toStringAsFixed(2) ?? '0.00'
      ],
      [
        'Deposit Held',
        data.grandTotal!.totalDeposits?.toStringAsFixed(2) ?? '0.00'
      ],
      [
        'Balance Due',
        data.grandTotal!.totalBalanceDue?.toStringAsFixed(2) ?? '0.00'
      ],
    ];

    for (var total in grandTotals) {
      csvBuffer.writeln('"${total[0]}","","","${total[1]}"');
    }
    csvBuffer.writeln(); // Add extra line

    // Add Bed/Bath Summary
    csvBuffer.writeln('"Summary by Bed/Bath",,,,,,,,,,');
    final bedBathHeaders = [
      'Bed/Bath',
      'No. of Units',
      'Vacant',
      'Occupied',
      '% Occupied',
      'Total Sq.Ft.',
      'Avg Sq.Ft.',
      'Total Rent',
      'Avg Rent',
      'Avg/Sq.Ft.'
    ];
    csvBuffer.writeln(bedBathHeaders.map((h) => '"$h"').join(','));

    // Add bed/bath data
    for (var item in data.bedBathSummary!.bedBathSummary ?? []) {
      final row = [
        item.bedBath ?? '',
        item.units?.toStringAsFixed(0) ?? '0',
        item.vacantUnits?.toStringAsFixed(0) ?? '0',
        item.occupiedUnits?.toStringAsFixed(0) ?? '0',
        "${item.occupancyRate}%" ?? '0.00%',
        item.totalSqFt?.toStringAsFixed(0) ?? '0',
        item.avgSqFt ?? '0.00',
        item.totalRent ?? '0.00',
        item.avgRent ?? '0.00',
        item.avgRentPerSqFt ?? '0.00',
      ];
      csvBuffer.writeln(row
          .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
          .join(','));
    }

    // Add bed/bath totals
    final bedBathTotals = [
      'Totals and Averages',
      data.bedBathSummary!.totalsAndAveragesBedBath?.totalUnits
              ?.toStringAsFixed(0) ??
          '0',
      data.bedBathSummary!.totalsAndAveragesBedBath?.totalVacantUnits
              ?.toStringAsFixed(0) ??
          '0',
      data.bedBathSummary!.totalsAndAveragesBedBath?.totalOccupiedUnits
              ?.toStringAsFixed(0) ??
          '0',
      "${data.bedBathSummary!.totalsAndAveragesBedBath?.avgOccupancyRate}%" ??
          '0.00%',
      data.bedBathSummary!.totalsAndAveragesBedBath?.totalSqFt
              ?.toStringAsFixed(0) ??
          '0',
      data.bedBathSummary!.totalsAndAveragesBedBath?.avgSqFt ?? '0.00',
      data.bedBathSummary!.totalsAndAveragesBedBath?.totalMarketRent ?? '0.00',
      data.bedBathSummary!.totalsAndAveragesBedBath?.avgMarketRent ?? '0.00',
      data.bedBathSummary!.totalsAndAveragesBedBath?.avgMarketRentPerSqFt ??
          '0.00',
    ];
    csvBuffer.writeln(bedBathTotals
        .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
        .join(','));
    csvBuffer.writeln(); // Add extra line

    // Add Property Summary
    csvBuffer.writeln('"Summary by Property",,,,,,,,,,');
    csvBuffer.writeln(bedBathHeaders.map((h) => '"$h"').join(','));

    // Add property data
    for (var item in data.propertySummary!.propertySummary ?? []) {
      final row = [
        item.property ?? '',
        item.units?.toStringAsFixed(0) ?? '0',
        item.vacantUnits?.toStringAsFixed(0) ?? '0',
        item.occupiedUnits?.toStringAsFixed(0) ?? '0',
        "${item.occupancyRate}%" ?? '0.00%',
        item.totalSqFt?.toStringAsFixed(0) ?? '0',
        item.avgSqFt ?? '0.00',
        item.totalRent ?? '0.00',
        item.avgRent ?? '0.00',
        item.avgRentPerSqFt ?? '0.00',
      ];
      csvBuffer.writeln(row
          .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
          .join(','));
    }

    // Add property totals
    final propertyTotals = [
      'Totals and Averages',
      data.propertySummary!.totalsAndAveragesProperty?.totalUnits
              ?.toStringAsFixed(0) ??
          '0',
      data.propertySummary!.totalsAndAveragesProperty?.totalVacantUnits
              ?.toStringAsFixed(0) ??
          '0',
      data.propertySummary!.totalsAndAveragesProperty?.totalOccupiedUnits
              ?.toStringAsFixed(0) ??
          '0',
      "${data.propertySummary!.totalsAndAveragesProperty?.avgOccupancyRate}%" ??
          '0.00%',
      data.propertySummary!.totalsAndAveragesProperty?.totalSqFt
              ?.toStringAsFixed(0) ??
          '0',
      data.propertySummary!.totalsAndAveragesProperty?.avgSqFt ?? '0.00',
      data.propertySummary!.totalsAndAveragesProperty?.totalMarketRent ??
          '0.00',
      data.propertySummary!.totalsAndAveragesProperty?.avgMarketRent ?? '0.00',
      data.propertySummary!.totalsAndAveragesProperty?.avgMarketRentPerSqFt ??
          '0.00',
    ];
    csvBuffer.writeln(propertyTotals
        .map((cell) => '"${cell.toString().replaceAll('"', '""')}"')
        .join(','));

    // Save the file
    final DateTime now = DateTime.now();
    final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
    final String fileName = 'Daily_transaction_report_$formattedDate.csv';

    final Directory directory = Platform.isIOS
        ? await getApplicationDocumentsDirectory()
        : Directory('/storage/emulated/0/Pictures');

    final path = '${directory.path}/$fileName';

    // Create directory if it doesn't exist (for Android)
    if (!await directory.exists() && !Platform.isIOS) {
      await directory.create(recursive: true);
    }

    final File file = File(path);
    await file.writeAsString(csvBuffer.toString(), flush: true);
    Share.shareXFiles([XFile(path)]);
    Fluttertoast.showToast(
      msg: 'CSV file saved to $path',
    );
  }

  final cellStyle = const pw.TextStyle(fontSize: 7);

  final headerStyle = pw.TextStyle(
    fontWeight: pw.FontWeight.bold,
    fontSize: 9,
    color: PdfColors.white,
  );

  final headerDecoration = pw.BoxDecoration(
    color: PdfColor.fromHex("#5A86D5"), // a nice blue shade
    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
  );

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
      drawer: CustomDrawerStaff(
        currentpage: "Reports",
        dropdown: false,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Padding(
                      padding: EdgeInsets.only(left: MediaQuery.of(context).size.width > 500? 12 : 0,right:  MediaQuery.of(context).size.width > 500? 12 : 0),
                      child: titleBar(
                        width: double.infinity,
                        title: "Rent Roll Report",
                      ),
                    ),
                  ),
                  // if (MediaQuery.of(context).size.width > 500)
                  //   const SizedBox(height: 16),
                  // if (MediaQuery.of(context).size.width < 500)
                    FutureBuilder<rentrollreportmodel>(
                      future: _futureRentersInsurance,
                      builder: (context, snapshot) {
                        if (isLoading) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ColabShimmerLoadingWidget(),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.rentals!.isEmpty) {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    // Dropdown for Rental Owners
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: Material(
                                          elevation: 3,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: DropdownButton2<String>(
                                            isExpanded: true,
                                            hint: const Row(
                                              children: [
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Select Rental Owners',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            items: rentalowners
                                                .map((owner) =>
                                                    DropdownMenuItem<String>(
                                                      value: owner[
                                                          'rentalowner_id'],
                                                      child: Text(
                                                        owner[
                                                            'rentalOwner_name']!,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ))
                                                .toList(),
                                            value: selectedOwner,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedOwner = value;
                                              });
                                            },
                                            buttonStyleData: ButtonStyleData(
                                              height: 45,
                                              width: double.infinity,
                                              padding: const EdgeInsets.only(
                                                  left: 14, right: 14),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFF8A95A8),
                                                ),
                                                color: Colors.white,
                                              ),
                                              elevation: 0,
                                            ),
                                            dropdownStyleData:
                                                DropdownStyleData(
                                              maxHeight: 250,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              offset: const Offset(-20, 0),
                                              scrollbarTheme:
                                                  ScrollbarThemeData(
                                                radius:
                                                    const Radius.circular(40),
                                                thickness:
                                                    MaterialStateProperty.all(
                                                        6),
                                                thumbVisibility:
                                                    MaterialStateProperty.all(
                                                        true),
                                              ),
                                            ),
                                            menuItemStyleData:
                                                const MenuItemStyleData(
                                              height: 50,
                                              padding: EdgeInsets.only(
                                                  left: 14, right: 14),
                                            ),
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
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(0),
                                        color: Colors.white,
                                      ),
                                      child: IconButton(
                                        icon: const FaIcon(
                                            FontAwesomeIcons.circlePlay),
                                        onPressed: () {
                                          setState(() {
                                            _futureRentersInsurance =
                                                fetchRentersInsuranceData(
                                                    id: selectedOwner);
                                          });
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
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(0),
                                        color: Colors.white,
                                      ),
                                      child: PopupMenuButton<String>(
                                        offset: const Offset(5, 50),
                                        onSelected: handleDownload,
                                        icon: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FaIcon(FontAwesomeIcons
                                                .download), // Your download icon
                                            SizedBox(
                                                width:
                                                    5), // Adds spacing between the icons
                                            Icon(Icons
                                                .arrow_drop_down), // The dropdown arrow icon
                                          ],
                                        ),
                                        tooltip: "Download",
                                        itemBuilder: (BuildContext context) {
                                          return downloadOptions
                                              .map((String option) {
                                            return PopupMenuItem<String>(
                                              value: option,
                                              onTap: () async {
                                                if (snapshot.hasData)
                                                  generateRentersInsuranceExcel(
                                                      snapshot.data!);
                                              },
                                              child:
                                                  Text("Download as $option"),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
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
                                      const SizedBox(height: 10),
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

                        var data = snapshot.data!.rentals!;

                        // Pagination logic
                        final totalPages = (data.length / itemsPerPage).ceil();
                        final currentPageData = data
                            .skip(currentPage * itemsPerPage)
                            .take(itemsPerPage)
                            .toList();

                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              // Search & Export Section
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                child: Row(
                                  children: [
                                    // Dropdown for Rental Owners
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: Material(
                                          elevation: 3,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          child: DropdownButton2<String>(
                                            isExpanded: true,
                                            hint: const Row(
                                              children: [
                                                SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Select Rental Owners',
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            items: rentalowners
                                                .map((owner) =>
                                                    DropdownMenuItem<String>(
                                                      value: owner[
                                                          'rentalowner_id'],
                                                      child: Text(
                                                        owner[
                                                            'rentalOwner_name']!,
                                                        style: const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ))
                                                .toList(),
                                            value: selectedOwner,
                                            onChanged: (value) {
                                              setState(() {
                                                selectedOwner = value;
                                              });
                                            },
                                            buttonStyleData: ButtonStyleData(
                                              height: 45,
                                              width: double.infinity,
                                              padding: const EdgeInsets.only(
                                                  left: 14, right: 14),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color:
                                                      const Color(0xFF8A95A8),
                                                ),
                                                color: Colors.white,
                                              ),
                                              elevation: 0,
                                            ),
                                            dropdownStyleData:
                                                DropdownStyleData(
                                              maxHeight: 250,
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(14),
                                              ),
                                              offset: const Offset(-20, 0),
                                              scrollbarTheme:
                                                  ScrollbarThemeData(
                                                radius:
                                                    const Radius.circular(40),
                                                thickness:
                                                    MaterialStateProperty.all(
                                                        6),
                                                thumbVisibility:
                                                    MaterialStateProperty.all(
                                                        true),
                                              ),
                                            ),
                                            menuItemStyleData:
                                                const MenuItemStyleData(
                                              height: 50,
                                              padding: EdgeInsets.only(
                                                  left: 14, right: 14),
                                            ),
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
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(0),
                                        color: Colors.white,
                                      ),
                                      child: IconButton(
                                        icon: const FaIcon(
                                            FontAwesomeIcons.circlePlay),
                                        onPressed: () {
                                          setState(() {
                                            _futureRentersInsurance =
                                                fetchRentersInsuranceData(
                                                    id: selectedOwner);
                                          });
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
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(0),
                                        color: Colors.white,
                                      ),
                                      child: PopupMenuButton<String>(
                                        offset: const Offset(5, 50),
                                        onSelected: handleDownload,
                                        icon: const Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            FaIcon(FontAwesomeIcons
                                                .download), // Your download icon
                                            SizedBox(
                                                width:
                                                    5), // Adds spacing between the icons
                                            Icon(Icons
                                                .arrow_drop_down), // The dropdown arrow icon
                                          ],
                                        ),
                                        tooltip: "Download",
                                        itemBuilder: (BuildContext context) {
                                          return downloadOptions
                                              .map((String option) {
                                            return PopupMenuItem<String>(
                                              value: option,
                                              onTap: () async {
                                                if (option == "PDF")
                                                  generaterentersInsurancePdf(
                                                      snapshot.data!);
                                                if (option == "Excel")
                                                  generateRentersInsuranceExcel(
                                                      snapshot.data!);
                                                if (option == "CSV")
                                                  generateRentersInsuranceCSV(
                                                      snapshot.data!);
                                              },
                                              child:
                                                  Text("Download as $option"),
                                            );
                                          }).toList();
                                        },
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 15),
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
                              if (_selectedIndex == 0)
                                DetailScreen(currentPageData),
                              if (_selectedIndex == 1)
                                SummeryScreen(snapshot.data!),

                              // Pagination controls for Details tab
                              if (_selectedIndex == 0 &&
                                  data.length > itemsPerPage)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(width: 10),
                                          Material(
                                            elevation: 3,
                                            child: Container(
                                              height: 40,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 12.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Colors.grey),
                                              ),
                                              child:
                                                  DropdownButtonHideUnderline(
                                                child: DropdownButton<int>(
                                                  value: itemsPerPage,
                                                  items: itemsPerPageOptions
                                                      .map((int value) {
                                                    return DropdownMenuItem<
                                                        int>(
                                                      value: value,
                                                      child: Text(
                                                          value.toString()),
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
                                              FontAwesomeIcons
                                                  .circleChevronLeft,
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
                                              FontAwesomeIcons
                                                  .circleChevronRight,
                                              color:
                                                  currentPage < totalPages - 1
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
                                  ),
                                )
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
                  const Text(
                    'No Internet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Check your internet connection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
    );
  }

  int _selectedIndex = 0;
  DetailScreen(List<Rentals> currentPageData) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeaders(),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: const Color.fromRGBO(152, 162, 179, .5)),
              ),
              child: Column(
                children: currentPageData.asMap().entries.map((entry) {
                  int rowIndex = entry.key;
                  var item = entry.value;
                  bool isRowExpanded = expandedRowIndex == rowIndex;

                  return Container(
                    decoration: BoxDecoration(
                      color: rowIndex % 2 != 0
                          ? Colors.white
                          : blueColor.withOpacity(0.09),
                      border: Border.all(
                          color: const Color.fromRGBO(152, 162, 179, .5)),
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
                                        nestedExpandedIndex =
                                            null; // reset inner when switching rows
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
                                const SizedBox(width: 8),
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
                                const SizedBox(width: 8),
                              ],
                            ),
                          ),
                        ),

                        // Outer expanded section
                        if (isRowExpanded)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 0),
                            decoration: BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Colors.grey.shade400)),
                            ),
                            child: Column(
                              children: item.activeLeases
                                      ?.asMap()
                                      .entries
                                      .map((leaseEntry) {
                                    int leaseIndex = leaseEntry.key;
                                    ActiveLeases lease = leaseEntry.value;
                                    bool isLeaseExpanded =
                                        expandedLeaseIndex == leaseIndex;
                                    bool isLeaseIndexExpanded =
                                        expandedLeaseTotalIndex == leaseIndex;

                                    return Column(
                                      children: [
                                        Container(
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 0),
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            onTap: () {
                                              setState(() {
                                                if (expandedLeaseIndex ==
                                                    leaseIndex) {
                                                  expandedLeaseIndex = null;
                                                } else {
                                                  expandedLeaseIndex =
                                                      leaseIndex;
                                                }
                                              });
                                            },
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      if (expandedLeaseIndex ==
                                                          leaseIndex) {
                                                        expandedLeaseIndex =
                                                            null;
                                                      } else {
                                                        expandedLeaseIndex =
                                                            leaseIndex;
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 5),
                                                    padding: !isLeaseExpanded
                                                        ? const EdgeInsets.only(
                                                            bottom: 10)
                                                        : const EdgeInsets.only(
                                                            top: 10),
                                                    child: FaIcon(
                                                      isLeaseExpanded
                                                          ? FontAwesomeIcons
                                                              .sortUp
                                                          : FontAwesomeIcons
                                                              .sortDown,
                                                      size: 20,
                                                      color: blueColor,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Expanded(
                                                    child: Text(
                                                  "${lease.unit?.rentalUnit ?? '-'}",
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                )),
                                                Expanded(
                                                    child: Text(
                                                  "${lease.leaseStart ?? '-'}",
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                )),
                                                Expanded(
                                                    child: Text(
                                                  "${lease.leaseEnd ?? '-'}",
                                                  style: TextStyle(
                                                    color: blueColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                )),
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
                                                    0: const FlexColumnWidth(), // Distribute columns equally
                                                    1: const FlexColumnWidth(),
                                                    2: const FlexColumnWidth(),
                                                  },
                                                  children: [
                                                    buildTableRows(
                                                      'Rent start',
                                                      getDisplayValue(
                                                          "${lease.leaseStart}"),
                                                      'Rent Cycle',
                                                      getDisplayValue(
                                                          lease.rentCycle),
                                                      'Credits',
                                                      getDisplayValue(
                                                          "\$${lease.creditAmount!.toStringAsFixed(2)}"),
                                                    ),
                                                    buildTableRows(
                                                      'Bed/Bath',
                                                      getDisplayValue(
                                                          "${lease.unit!.bedBath}"),
                                                      'Prepayments',
                                                      getDisplayValue(
                                                          formatCurrency(lease
                                                              .prepayments)),
                                                      'Charges',
                                                      getDisplayValue(
                                                          formatCurrency(lease
                                                              .chargeAmount)),
                                                    ),
                                                    buildTableRows(
                                                      'Total',
                                                      getDisplayValue(
                                                          formatCurrency(lease
                                                              .chargeTotal)),
                                                      'Balance Due',
                                                      getDisplayValue(
                                                          formatCurrency(lease
                                                              .balanceDue)),
                                                      'Rent',
                                                      getDisplayValue(
                                                          formatCurrency(lease
                                                              .rentAmount)),
                                                    ),
                                                    buildTableRows(
                                                      'Deposit Held',
                                                      getDisplayValue(
                                                          formatCurrency(lease
                                                              .depositHeld)),
                                                      'Tenants',
                                                      getDisplayValue(lease
                                                          .tenants!
                                                          .map((tenant) =>
                                                              "${tenant.tenantFirstName ?? ''} ${tenant.tenantLastName ?? ''}"
                                                                  .trim())
                                                          .join(", ")),
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
                                              border: Border(
                                                  top: BorderSide(
                                                      color: Colors
                                                          .grey.shade500))),
                                          child: ListTile(
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
                                                        if (expandedLeaseTotalIndex ==
                                                            leaseIndex) {
                                                          expandedLeaseTotalIndex =
                                                              null;
                                                        } else {
                                                          expandedLeaseTotalIndex =
                                                              leaseIndex;
                                                        }
                                                      });
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      padding:
                                                          !isLeaseIndexExpanded
                                                              ? const EdgeInsets
                                                                  .only(
                                                                  bottom: 10)
                                                              : const EdgeInsets
                                                                  .only(
                                                                  top: 10),
                                                      child: FaIcon(
                                                        isLeaseIndexExpanded
                                                            ? FontAwesomeIcons
                                                                .sortUp
                                                            : FontAwesomeIcons
                                                                .sortDown,
                                                        size: 20,
                                                        color: blueColor,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Total For ${item.rentalAddress ?? '-'}',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
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
                                                    0: const FlexColumnWidth(), // Distribute columns equally
                                                    1: const FlexColumnWidth(),
                                                    2: const FlexColumnWidth(),
                                                  },
                                                  children: [
                                                    buildTableRows(
                                                      'Credits',
                                                      getDisplayValue(
                                                          "\$${item.totals!.totalCredits!.toStringAsFixed(2)}"),
                                                      'Prepayments',
                                                      getDisplayValue(
                                                          "\$${item.totals!.totalPrepayments!.toStringAsFixed(2)}"),
                                                      'Charges',
                                                      getDisplayValue(
                                                          "\$${item.totals!.totalCharges!.toStringAsFixed(2)}"),
                                                    ),
                                                    buildTableRows(
                                                      'Total',
                                                      getDisplayValue(
                                                          "\$${item.totals!.totalAmount!.toStringAsFixed(2)}"),
                                                      'Balance Due',
                                                      getDisplayValue(
                                                          "\$${item.totals!.totalBalanceDue!.toStringAsFixed(2)}"),
                                                      'Rent',
                                                      getDisplayValue(
                                                          "\$${item.totals!.totalRent!.toStringAsFixed(2)}"),
                                                    ),
                                                    buildTableRows(
                                                      'Deposit Held',
                                                      getDisplayValue(
                                                          "\$${item.totals!.totalDeposits!.toStringAsFixed(2)}"),
                                                      '',
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

  SummeryScreen(rentrollreportmodel data) {
    final totals = data.grandTotal;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          height: 10,
        ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
              _buildSummaryRow(
                  "Rent", "\$${totals!.totalRent!.toStringAsFixed(2)}"),
              _buildSummaryRow("Recurring Charges",
                  "\$${totals!.totalCharges!.toStringAsFixed(2)}"),
              _buildSummaryRow("Recurring Credits",
                  "\$${totals!.totalCredits!.toStringAsFixed(2)}"),
              _buildSummaryRow("Deposits Held",
                  "\$${totals!.totalDeposits!.toStringAsFixed(2)}"),
              _buildSummaryRow("Balance Due",
                  "\$${totals!.totalBalanceDue!.toStringAsFixed(2)}"),
            ],
          ),
        ),
        Summerybybedbath(data.bedBathSummary!),
        Summerybyproperty(data.propertySummary!)
      ],
    );
  }

  bool isRowExpanded = false;
  bool isRowPropertyExpanded = false;
  int? expandedRowbedbathIndex;
  int? expandedRowPropertyIndex;
  Summerybybedbath(BedBathSummaryData data) {
    final currentPageData = data.bedBathSummary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
              !isdisplaysummeryBedbath
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          isdisplaysummeryBedbath = !isdisplaysummeryBedbath;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: FaIcon(FontAwesomeIcons.squareCaretDown),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          isdisplaysummeryBedbath = !isdisplaysummeryBedbath;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: FaIcon(FontAwesomeIcons.squareCaretUp),
                      ),
                    )
            ],
          ),
        ),
        if (isdisplaysummeryBedbath)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildHeadersforsummery("Bed/Bath", "No.Of Units"),
          ),
        if (isdisplaysummeryBedbath)
          const SizedBox(
            height: 20,
          ),
        if (isdisplaysummeryBedbath)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              border:
                  Border.all(color: const Color.fromRGBO(152, 162, 179, .5)),
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
                        color: rowIndex % 2 != 0
                            ? Colors.white
                            : blueColor.withOpacity(0.09),
                        border: Border.all(
                            color: const Color.fromRGBO(152, 162, 179, .5)),
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
                                        if (expandedRowbedbathIndex ==
                                            rowIndex) {
                                          expandedRowbedbathIndex = null;
                                        } else {
                                          expandedRowbedbathIndex = rowIndex;
                                          nestedExpandedIndex =
                                              null; // reset inner when switching rows
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
                                  const SizedBox(width: 8),
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
                                  const SizedBox(width: 8),
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
                          if (isRowExpanded)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 0),
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
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 0),
                                  child: Divider(
                                    thickness: 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Table(
                                          columnWidths: {
                                            // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                            // 1: FlexColumnWidth(),
                                            0: const FlexColumnWidth(), // Distribute columns equally
                                            1: const FlexColumnWidth(),
                                            2: const FlexColumnWidth(),
                                          },
                                          children: [
                                            buildTableRows(
                                              'Vacant',
                                              getDisplayValue(
                                                  "${item.vacantUnits}"),
                                              'Occupied',
                                              getDisplayValue(
                                                  "${item.occupiedUnits}"),
                                              '%Occupied',
                                              getDisplayValue(
                                                  "${item.occupancyRate}"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 0),
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
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 0),
                                  child: Divider(
                                    thickness: 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Table(
                                          columnWidths: {
                                            // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                            // 1: FlexColumnWidth(),
                                            0: const FlexColumnWidth(), // Distribute columns equally
                                            1: const FlexColumnWidth(),
                                            2: const FlexColumnWidth(),
                                          },
                                          children: [
                                            buildTableRows(
                                              'Total',
                                              getDisplayValue(
                                                  "${item.totalRent}"),
                                              'Average',
                                              getDisplayValue(
                                                  "${item.avgRent}"),
                                              'Avg./Sq.Ft.',
                                              getDisplayValue(
                                                  "${item.avgRentPerSqFt}"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 0),
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
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 0),
                                  child: Divider(
                                    thickness: 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Table(
                                          columnWidths: {
                                            // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                            // 1: FlexColumnWidth(),
                                            0: const FlexColumnWidth(), // Distribute columns equally
                                            1: const FlexColumnWidth(),
                                            2: const FlexColumnWidth(),
                                          },
                                          children: [
                                            buildTableRows(
                                              'Total',
                                              getDisplayValue(
                                                  "${item.totalSqFt}"),
                                              'Average',
                                              getDisplayValue(
                                                  "${item.avgSqFt}"),
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
                    color: currentPageData.length % 2 != 0
                        ? Colors.white
                        : blueColor.withOpacity(0.09),
                    border: Border.all(
                        color: const Color.fromRGBO(152, 162, 179, .5)),
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
                                    if (expandedRowbedbathIndex ==
                                        currentPageData.length + 1) {
                                      expandedRowbedbathIndex = null;
                                      isRowExpanded = true;
                                    } else {
                                      expandedRowbedbathIndex =
                                          currentPageData.length + 1;
                                      isRowExpanded = false;
                                      nestedExpandedIndex =
                                          null; // reset inner when switching rows
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
                              const SizedBox(width: 8),
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
                              const SizedBox(width: 8),
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
                      if (isRowExpanded)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 0),
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
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0),
                              child: Divider(
                                thickness: 2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Table(
                                      columnWidths: {
                                        // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                        // 1: FlexColumnWidth(),
                                        0: const FlexColumnWidth(), // Distribute columns equally
                                        1: const FlexColumnWidth(),
                                        2: const FlexColumnWidth(),
                                      },
                                      children: [
                                        buildTableRows(
                                          'Vacant',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesBedBath!.totalVacantUnits}"),
                                          'Occupied',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesBedBath!.totalOccupiedUnits}"),
                                          '%Occupied',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesBedBath!.avgOccupancyRate}"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 0),
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
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0),
                              child: Divider(
                                thickness: 2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Table(
                                      columnWidths: {
                                        // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                        // 1: FlexColumnWidth(),
                                        0: const FlexColumnWidth(), // Distribute columns equally
                                        1: const FlexColumnWidth(),
                                        2: const FlexColumnWidth(),
                                      },
                                      children: [
                                        buildTableRows(
                                          'Total',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesBedBath!.totalMarketRent}"),
                                          'Average',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesBedBath!.avgMarketRent}"),
                                          'Avg./Sq.Ft.',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesBedBath!.avgMarketRentPerSqFt}"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 0),
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
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0),
                              child: Divider(
                                thickness: 2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Table(
                                      columnWidths: {
                                        // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                        // 1: FlexColumnWidth(),
                                        0: const FlexColumnWidth(), // Distribute columns equally
                                        1: const FlexColumnWidth(),
                                        2: const FlexColumnWidth(),
                                      },
                                      children: [
                                        buildTableRows(
                                          'Total',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesBedBath!.totalSqFt}"),
                                          'Average',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesBedBath!.avgSqFt}"),
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

  Summerybyproperty(PropertySummaryData data) {
    final currentPageData = data.propertySummary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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
              !isdisplaysummeryProperty
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          isdisplaysummeryProperty = !isdisplaysummeryProperty;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: FaIcon(
                          FontAwesomeIcons.squareCaretDown,
                        ),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          isdisplaysummeryProperty = !isdisplaysummeryProperty;
                        });
                      },
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: FaIcon(FontAwesomeIcons.squareCaretUp),
                      ),
                    )
            ],
          ),
        ),
        if (isdisplaysummeryProperty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildHeadersforsummery("Property", "No.Of Units"),
          ),
        if (isdisplaysummeryProperty)
          const SizedBox(
            height: 20,
          ),
        if (isdisplaysummeryProperty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              border:
                  Border.all(color: const Color.fromRGBO(152, 162, 179, .5)),
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
                        color: rowIndex % 2 != 0
                            ? Colors.white
                            : blueColor.withOpacity(0.09),
                        border: Border.all(
                            color: const Color.fromRGBO(152, 162, 179, .5)),
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
                                        if (expandedRowPropertyIndex ==
                                            rowIndex) {
                                          expandedRowPropertyIndex = null;
                                        } else {
                                          expandedRowPropertyIndex = rowIndex;
                                          nestedExpandedIndex =
                                              null; // reset inner when switching rows
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
                                  const SizedBox(width: 8),
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
                                  const SizedBox(width: 8),
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
                          if (isRowExpanded)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 0),
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
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 0),
                                  child: Divider(
                                    thickness: 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Table(
                                          columnWidths: {
                                            // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                            // 1: FlexColumnWidth(),
                                            0: const FlexColumnWidth(), // Distribute columns equally
                                            1: const FlexColumnWidth(),
                                            2: const FlexColumnWidth(),
                                          },
                                          children: [
                                            buildTableRows(
                                              'Vacant',
                                              getDisplayValue(
                                                  "${item.vacantUnits}"),
                                              'Occupied',
                                              getDisplayValue(
                                                  "${item.occupiedUnits}"),
                                              '%Occupied',
                                              getDisplayValue(
                                                  "${item.occupancyRate}"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 0),
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
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 0),
                                  child: Divider(
                                    thickness: 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Table(
                                          columnWidths: {
                                            // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                            // 1: FlexColumnWidth(),
                                            0: const FlexColumnWidth(), // Distribute columns equally
                                            1: const FlexColumnWidth(),
                                            2: const FlexColumnWidth(),
                                          },
                                          children: [
                                            buildTableRows(
                                              'Total',
                                              getDisplayValue(
                                                  "${item.totalRent}"),
                                              'Average',
                                              getDisplayValue(
                                                  "${item.avgRent}"),
                                              'Avg./Sq.Ft.',
                                              getDisplayValue(
                                                  "${item.avgRentPerSqFt}"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 0),
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
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 0),
                                  child: Divider(
                                    thickness: 2,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0, vertical: 0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Table(
                                          columnWidths: {
                                            // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                            // 1: FlexColumnWidth(),
                                            0: const FlexColumnWidth(), // Distribute columns equally
                                            1: const FlexColumnWidth(),
                                            2: const FlexColumnWidth(),
                                          },
                                          children: [
                                            buildTableRows(
                                              'Total',
                                              getDisplayValue(
                                                  "${item.totalSqFt}"),
                                              'Average',
                                              getDisplayValue(
                                                  "${item.avgSqFt}"),
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
                    color: currentPageData.length % 2 != 0
                        ? Colors.white
                        : blueColor.withOpacity(0.09),
                    border: Border.all(
                        color: const Color.fromRGBO(152, 162, 179, .5)),
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
                                    if (expandedRowPropertyIndex ==
                                        currentPageData.length) {
                                      expandedRowPropertyIndex = null;
                                      isRowPropertyExpanded = true;
                                    } else {
                                      expandedRowPropertyIndex =
                                          currentPageData.length;
                                      isRowPropertyExpanded = false;
                                      nestedExpandedIndex =
                                          null; // reset inner when switching rows
                                    }
                                  });

                                  print(
                                      "isRowPropertyExpanded $isRowPropertyExpanded");
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
                              const SizedBox(width: 8),
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
                              const SizedBox(width: 8),
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
                      if (isRowPropertyExpanded)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 0),
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
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0),
                              child: Divider(
                                thickness: 2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Table(
                                      columnWidths: {
                                        // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                        // 1: FlexColumnWidth(),
                                        0: const FlexColumnWidth(), // Distribute columns equally
                                        1: const FlexColumnWidth(),
                                        2: const FlexColumnWidth(),
                                      },
                                      children: [
                                        buildTableRows(
                                          'Vacant',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesProperty!.totalVacantUnits}"),
                                          'Occupied',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesProperty!.totalOccupiedUnits}"),
                                          '%Occupied',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesProperty!.avgOccupancyRate}"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 0),
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
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0),
                              child: Divider(
                                thickness: 2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Table(
                                      columnWidths: {
                                        // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                        // 1: FlexColumnWidth(),
                                        0: const FlexColumnWidth(), // Distribute columns equally
                                        1: const FlexColumnWidth(),
                                        2: const FlexColumnWidth(),
                                      },
                                      children: [
                                        buildTableRows(
                                          'Total',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesProperty!.totalMarketRent}"),
                                          'Average',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesProperty!.avgMarketRent}"),
                                          'Avg./Sq.Ft.',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesProperty!.avgMarketRentPerSqFt}"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 0),
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
                            const Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 0),
                              child: Divider(
                                thickness: 2,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Table(
                                      columnWidths: {
                                        // 0: FixedColumnWidth(150.0), // Adjust width as needed
                                        // 1: FlexColumnWidth(),
                                        0: const FlexColumnWidth(), // Distribute columns equally
                                        1: const FlexColumnWidth(),
                                        2: const FlexColumnWidth(),
                                      },
                                      children: [
                                        buildTableRows(
                                          'Total',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesProperty!.totalSqFt}"),
                                          'Average',
                                          getDisplayValue(
                                              "${data.totalsAndAveragesProperty!.avgSqFt}"),
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
        const SizedBox(
          height: 30,
        )
      ],
    );
  }

  Widget _buildSummaryRow(String title, String amount) {
    return Column(
      children: [
        const Divider(
          height: 3,
          color: Colors.black,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 14, color: blueColor)),
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
      String leftLabel,
      String leftValue,
      String centerLabel,
      String centerValue,
      String rightLabel,
      String rightValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leftLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                const SizedBox(height: 4.0), // Space between label and value
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  centerLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                const SizedBox(height: 4.0), // Space between label and value
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
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style:
                      TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                ),
                const SizedBox(height: 4.0), // Space between label and value
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
