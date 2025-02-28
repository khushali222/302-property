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
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:share_plus/share_plus.dart';
import 'package:three_zero_two_property/Model/RentarsInsuranceModel.dart';
import 'package:three_zero_two_property/Model/lease_renter_insurance.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';
import 'package:three_zero_two_property/provider/getAdminAddress.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/Renters%20Insurance/RentersInsuranceAdd.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/Renters%20Insurance/ViewRentersDetails.dart';

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

import '../../../../repository/lease_rental_insurance_repo.dart';
import '../../../../widgets/custom_drawer.dart';
import '../Send_email.dart';
import 'Edit_Renters_insurance.dart';

class Renters_Insurance_table extends StatefulWidget {
  final String leaseId;
  final String tenantId;
  final String? status;
  final String? rentalAddress;
  final String? rentalUnit;
  Renters_Insurance_table(
      {required this.leaseId,
      required this.status,
      required this.tenantId,
      this.rentalAddress,
      this.rentalUnit});
  @override
  State<Renters_Insurance_table> createState() =>
      _Renters_Insurance_tableState();
}

class _Renters_Insurance_tableState extends State<Renters_Insurance_table> {
  late Future<List<lease_renter_insurance>> _futureRentersInsurance;
  List<lease_renter_insurance> rentersInsuranceModel = [];
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

  Future<List<lease_renter_insurance>> fetchRentersInsuranceData() async {
    RentersInsuranceService service = RentersInsuranceService();
    try {
      List<lease_renter_insurance> data =
          await service.fetchRentersInsurance(widget.leaseId);
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
      return [];
    }
  }

  List<RentersInsuranceData> _tableData = [];
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
      Comparable<T> Function(RentersInsuranceData d)? getField) {
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

  void _sort<T>(Comparable<T> Function(RentersInsuranceData d) getField,
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
                          ? const Text("  Insurance\n  Company",
                              style: TextStyle(color: Colors.white ,fontSize: 15))
                          : const Text("  Insurance\n  Company",
                              style: TextStyle(color: Colors.white,fontSize: 15)),
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
                    Text("     Expiration\n        Date",
                        style: TextStyle(color: Colors.white,fontSize: 15)),
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
                    Text("      Effective\n         Date",
                        style: TextStyle(color: Colors.white,fontSize: 15)),
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

  String formateDates(String date) {
    return DateFormat("yyyy-MM-dd").format(DateTime.parse(date)).toString();
  }

  void _showDeleteAlert(BuildContext context, String id) {
    TextEditingController reason = TextEditingController();
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "you want to delete the insurance? This action cannot be undone.",
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            await RentersInsuranceService()
                .deleteInsurance(renters_insurance_id: id);
            setState(() {
              _futureRentersInsurance = RentersInsuranceService()
                  .fetchRentersInsurance(widget.leaseId);
            });
            Navigator.pop(context);
          },
          color: blueColor,
        ),
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.grey,
        ),
      ],
    ).show();
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return _connectivityResult != ConnectivityResult.none
        ? Container(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Spacer(),
                      GestureDetector(
                        onTap: () async {
                          // Provider.of<SelectedTenantsProvider>(context,
                          //     listen: false)
                          //     .clearTenant();
                          // Provider.of<SelectedCosignersProvider>(context,
                          //     listen: false)
                          //     .clearCosigner();
                          // Provider.of<SelectedApplicantProvider>(context,
                          //     listen: false)
                          //     .clearApplicant();
                          final result = await Navigator.of(context)
                              .push(MaterialPageRoute(
                                  builder: (context) => LeaseAddRentersInsurance(
                                        tenantid: widget.tenantId,
                                        leaseId: widget.leaseId,
                                      )));
                          if (result == true) {
                            setState(() {
                              _futureRentersInsurance =
                                  RentersInsuranceService()
                                      .fetchRentersInsurance(widget.leaseId);
                              //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                            });
                          }
                        },
                        child: Container(
                          height: (MediaQuery.of(context).size.width < 500)
                              ? 35
                              : MediaQuery.of(context).size.width * 0.063,
                          width: (MediaQuery.of(context).size.width < 500)
                              ? MediaQuery.of(context).size.width * 0.35
                              : MediaQuery.of(context).size.width * 0.2,
                          decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              "+ Add New Policy",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 14
                                        : 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 7,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Spacer(),
                      GestureDetector(
                        onTap: () async {
                          // Provider.of<SelectedTenantsProvider>(context,
                          //     listen: false)
                          //     .clearTenant();
                          // Provider.of<SelectedCosignersProvider>(context,
                          //     listen: false)
                          //     .clearCosigner();
                          // Provider.of<SelectedApplicantProvider>(context,
                          //     listen: false)
                          //     .clearApplicant();
                          final result = await Navigator.of(context)
                              .push(MaterialPageRoute(
                              builder: (context) => EmailTemplateScreen(
                                // leaseId: widget.leaseId,
                              )));
                          if (result == true) {
                            setState(() {
                              _futureRentersInsurance =
                                  RentersInsuranceService()
                                      .fetchRentersInsurance(widget.leaseId);
                              //  futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
                            });
                          }
                        },
                        child: Container(
                          height: (MediaQuery.of(context).size.width < 500)
                              ? 35
                              : MediaQuery.of(context).size.width * 0.063,
                          width: (MediaQuery.of(context).size.width < 500)
                              ? MediaQuery.of(context).size.width * 0.35
                              : MediaQuery.of(context).size.width * 0.2,
                          decoration: BoxDecoration(
                            color: blueColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Center(
                            child: Text(
                              "+ Send Mail",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width < 500
                                    ? 14
                                    : 22,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 7,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (MediaQuery.of(context).size.width < 500)
                  const SizedBox(height: 10),
                  if (MediaQuery.of(context).size.width > 500)
                    const SizedBox(height: 16),
                  if (MediaQuery.of(context).size.width < 500)
                    FutureBuilder<List<lease_renter_insurance>>(
                      future: _futureRentersInsurance,
                      builder: (context, snapshot) {
                        if (isLoading) {
                          return Padding(
                            padding: const EdgeInsets.all(7.0),
                            child: ColabShimmerLoadingWidget(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text(errorMessage ?? 'Unknown error'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Container(
                            height: MediaQuery.of(context).size.height * .45,
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

                        var data = snapshot.data!;

                        // Apply filtering based on selectedValue and searchValue
                        if (selectedValue == null && searchvalue.isEmpty) {
                          data = snapshot.data!;
                        } else if (selectedValue == "All") {
                          data = snapshot.data!;
                        } else if (searchvalue.isNotEmpty) {
                          data = snapshot.data!
                              .where((item) => item.insuranceCompany!
                                  .toLowerCase()
                                  .contains(searchvalue.toLowerCase()))
                              .toList();
                        } else {
                          data = snapshot.data!
                              .where((item) =>
                                  item.insuranceCompany == selectedValue)
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
                            padding: const EdgeInsets.all(7.0),
                            child: Column(
                              children: [
                                _buildHeaders(),
                                const SizedBox(height: 20),
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
                                      int rowIndex = entry.key;
                                      var item = entry.value;
                                      bool isRowExpanded =
                                          expandedRowIndex == rowIndex;

                                      return Container(
                                        decoration: BoxDecoration(
                                          color: rowIndex % 2 != 0
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
                                                          if (expandedRowIndex ==
                                                              rowIndex) {
                                                            expandedRowIndex =
                                                                null;
                                                          } else {
                                                            expandedRowIndex =
                                                                rowIndex;
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(left: 5),
                                                        padding: !isRowExpanded
                                                            ? const EdgeInsets
                                                                .only(
                                                                bottom: 10)
                                                            : const EdgeInsets
                                                                .only(top: 10),
                                                        child: FaIcon(
                                                          isRowExpanded
                                                              ? FontAwesomeIcons
                                                                  .sortUp
                                                              : FontAwesomeIcons
                                                                  .sortDown,
                                                          size: 20,
                                                          color: blueColor,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex:
                                                      4, // Larger size for the first field
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 8.0),
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              if (expandedRowIndex ==
                                                                  rowIndex) {
                                                                expandedRowIndex =
                                                                    null;
                                                              } else {
                                                                expandedRowIndex =
                                                                    rowIndex;
                                                              }
                                                            });
                                                          },
                                                          child: Text.rich(
                                                            TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text:
                                                                      '${item.insuranceCompany ?? '-'}',
                                                                  style:
                                                                      TextStyle(
                                                                    color:
                                                                        blueColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 10),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        item.expirationDate
                                                                    ?.isNotEmpty ==
                                                                true
                                                            ? dateProvider
                                                                .formatCurrentDate(
                                                                    '${item?.expirationDate?.split('T').first}')
                                                            : 'N/A',
                                                        style: TextStyle(
                                                          color: blueColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 25),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                          item.effectiveDate?.isNotEmpty ==
                                                              true
                                                              ? dateProvider
                                                              .formatCurrentDate('${item?.effectiveDate?.split('T').first}')
                                                              : 'N/A',
                                                        style: TextStyle(
                                                          color: blueColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            if (isRowExpanded)
                                              Container(
                                                padding: EdgeInsets.only(
                                                    left: 2, right: 2),
                                                margin:
                                                    EdgeInsets.only(bottom: 2),
                                                child: SingleChildScrollView(
                                                  child: Container(
                                                    //color: Colors.blue,
                                                    child: Column(
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            FaIcon(
                                                              isRowExpanded
                                                                  ? FontAwesomeIcons
                                                                      .sortUp
                                                                  : FontAwesomeIcons
                                                                      .sortDown,
                                                              size: 50,
                                                              color: Colors
                                                                  .transparent,
                                                            ),
                                                            Expanded(
                                                              child: Text.rich(
                                                                TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          'Tenants : ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              blueColor), // Bold and black
                                                                    ),
                                                                    TextSpan(
                                                                      // text: formatDate(
                                                                      //     '${Propertytype.updatedAt}'),
                                                                      text: item.tenantDetails != null && item.tenantDetails!.isNotEmpty
                                                                          ? item.tenantDetails!
                                                                          .map((tenant) =>
                                                                      '${tenant.tenantFirstName ?? '-'} ${tenant.tenantLastName ?? '-'}')
                                                                          .join(', ')
                                                                          : 'N/A' ,
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              grey), // Light and grey
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            /* Container(
                                                            width: 40,
                                                            child: Column(
                                                              children: [
                                                                IconButton(
                                                                  icon: FaIcon(
                                                                    FontAwesomeIcons
                                                                        .edit,
                                                                    size: 20,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        83,
                                                                        1),
                                                                  ),
                                                                  onPressed:
                                                                      () async {
                                                                    // handleEdit(Propertytype);

                                                                    // var check = await Navigator.push(
                                                                    //     context,
                                                                    //     MaterialPageRoute(
                                                                    //         builder: (context) => Edit_property_type(
                                                                    //           property: Propertytype,
                                                                    //         )));
                                                                    // if (check ==
                                                                    //     true) {
                                                                    //   setState(
                                                                    //           () {});
                                                                    // }
                                                                  },
                                                                ),
                                                                IconButton(
                                                                  icon: FaIcon(
                                                                    FontAwesomeIcons
                                                                        .trashCan,
                                                                    size: 20,
                                                                    color: Color
                                                                        .fromRGBO(
                                                                        21,
                                                                        43,
                                                                        83,
                                                                        1),
                                                                  ),
                                                                  onPressed: () {
                                                                    //handleDelete(Propertytype);
                                                                    // _showAlert(
                                                                    //     context,
                                                                    //     Propertytype
                                                                    //         .propertyId!);
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),*/
                                                          ],
                                                        ),

                                                        SizedBox(
                                                          height: 15,
                                                        ),
                                                        Row(
                                                          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  GestureDetector(
                                                                onTap:
                                                                    () async {
                                                                  var check = await Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) =>
                                                                          EditRentersInsurance(tenantid: widget.tenantId, leaseId: widget.leaseId, renters_insurance_id:  item.rentersInsuranceId ?? "",)));
                                                                  if (check ==
                                                                      true) {
                                                                    setState(
                                                                            () {
                                                                              _futureRentersInsurance = RentersInsuranceService()
                                                                                  .fetchRentersInsurance(widget.leaseId);
                                                                        });
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                              .grey[
                                                                          350]), // color:Colors.grey[100],
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      FaIcon(
                                                                        FontAwesomeIcons
                                                                            .edit,
                                                                        size:
                                                                            15,
                                                                        color:
                                                                            blueColor,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        "Edit",
                                                                        style: TextStyle(
                                                                            color:
                                                                                blueColor,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  _showDeleteAlert(
                                                                      context,
                                                                      item.rentersInsuranceId ??
                                                                          "");
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                              .grey[
                                                                          350]),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      FaIcon(
                                                                        FontAwesomeIcons
                                                                            .trashCan,
                                                                        size:
                                                                            15,
                                                                        color:
                                                                            blueColor,
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Text(
                                                                        "Delete",
                                                                        style: TextStyle(
                                                                            color:
                                                                                blueColor,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 5,
                                                            ),
                                                            Expanded(
                                                              child:
                                                                  GestureDetector(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => ViewRentersDetails(tenantid: widget.tenantId, leaseId: widget.leaseId, renters_insurance_id:  item.rentersInsuranceId ?? "",)));
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 40,
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                              .grey[
                                                                          350]),
                                                                  child: Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .center,
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .center,
                                                                    children: [
                                                                      SizedBox(
                                                                        width:
                                                                            5,
                                                                      ),
                                                                      Image
                                                                          .asset(
                                                                        'assets/icons/view.png',
                                                                        color:
                                                                            blueColor,
                                                                      ),
                                                                      // FaIcon(
                                                                      //   FontAwesomeIcons.trashCan,
                                                                      //   size: 15,
                                                                      //   color:blueColor,
                                                                      // ),
                                                                      SizedBox(
                                                                        width:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        "View Details",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                11,
                                                                            color:
                                                                                blueColor,
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
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
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                  if (MediaQuery.of(context).size.width > 500)
                    FutureBuilder<List<lease_renter_insurance>>(
                      future: _futureRentersInsurance,
                      builder: (context, snapshot) {
                        if (isLoading) {
                          return ShimmerTabletTable();
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text(errorMessage ?? 'Unknown error'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
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
                              .where((item) => item.insuranceCompany!
                                  .toLowerCase()
                                  .contains(searchvalue.toLowerCase()))
                              .toList();
                        } else {
                          data = snapshot.data!
                              .where((item) =>
                                  item.insuranceCompany == selectedValue)
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
                                _buildHeaders(),
                                const SizedBox(height: 20),
                                Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(color: blueColor)),
                                  child: Column(
                                    children: currentPageData
                                        .asMap()
                                        .entries
                                        .map((entry) {
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
                                                          if (expandedRowIndex ==
                                                              rowIndex) {
                                                            expandedRowIndex =
                                                                null;
                                                          } else {
                                                            expandedRowIndex =
                                                                rowIndex;
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .only(left: 5),
                                                        padding: !isRowExpanded
                                                            ? const EdgeInsets
                                                                .only(
                                                                bottom: 10)
                                                            : const EdgeInsets
                                                                .only(top: 10),
                                                        child: FaIcon(
                                                          isRowExpanded
                                                              ? FontAwesomeIcons
                                                                  .sortUp
                                                              : FontAwesomeIcons
                                                                  .sortDown,
                                                          size: 20,
                                                          color: blueColor,
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
                                                        '${item.insuranceCompany ?? '-'}',
                                                        style: TextStyle(
                                                          color: blueColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // if (isRowExpanded)
                                            //   Column(
                                            //     children: item.tenants!
                                            //         .asMap()
                                            //         .entries
                                            //         .map((tenantEntry) {
                                            //       int tenantIndex =
                                            //           tenantEntry.key;
                                            //       var tenant =
                                            //           tenantEntry.value;
                                            //       bool isTenantExpanded =
                                            //           expandedTenantIndex[
                                            //                   rowIndex] ==
                                            //               tenantIndex;
                                            //
                                            //       return Column(
                                            //         children: <Widget>[
                                            //           Divider(
                                            //             color: blueColor,
                                            //           ),
                                            //           ListTile(
                                            //             contentPadding:
                                            //                 EdgeInsets.zero,
                                            //             title: Padding(
                                            //               padding:
                                            //                   const EdgeInsets
                                            //                       .all(2.0),
                                            //               child: Row(
                                            //                 mainAxisAlignment:
                                            //                     MainAxisAlignment
                                            //                         .start,
                                            //                 crossAxisAlignment:
                                            //                     CrossAxisAlignment
                                            //                         .center,
                                            //                 children: <Widget>[
                                            //                   InkWell(
                                            //                     onTap: () {
                                            //                       setState(() {
                                            //                         if (expandedTenantIndex[
                                            //                                 rowIndex] ==
                                            //                             tenantIndex) {
                                            //                           expandedTenantIndex[
                                            //                                   rowIndex] =
                                            //                               null;
                                            //                         } else {
                                            //                           expandedTenantIndex[
                                            //                                   rowIndex] =
                                            //                               tenantIndex;
                                            //                         }
                                            //                       });
                                            //                     },
                                            //                     child:
                                            //                         Container(
                                            //                       margin:
                                            //                           const EdgeInsets
                                            //                               .only(
                                            //                               left:
                                            //                                   5),
                                            //                       padding: !isTenantExpanded
                                            //                           ? const EdgeInsets
                                            //                               .only(
                                            //                               bottom:
                                            //                                   10)
                                            //                           : const EdgeInsets
                                            //                               .only(
                                            //                               top:
                                            //                                   10),
                                            //                       child:
                                            //                           Padding(
                                            //                         padding: const EdgeInsets
                                            //                             .only(
                                            //                             left:
                                            //                                 24),
                                            //                         child:
                                            //                             FaIcon(
                                            //                           isTenantExpanded
                                            //                               ? FontAwesomeIcons
                                            //                                   .sortUp
                                            //                               : FontAwesomeIcons
                                            //                                   .sortDown,
                                            //                           size: 20,
                                            //                           color:
                                            //                               blueColor,
                                            //                         ),
                                            //                       ),
                                            //                     ),
                                            //                   ),
                                            //                   SizedBox(
                                            //                       width: MediaQuery.of(
                                            //                                   context)
                                            //                               .size
                                            //                               .width *
                                            //                           .02),
                                            //                   Expanded(
                                            //                     child: Text(
                                            //                       'Tenant ${tenantIndex + 1} : ${tenant.tenantName ?? '-'}',
                                            //                       style:
                                            //                           TextStyle(
                                            //                         color:
                                            //                             blueColor,
                                            //                         fontWeight:
                                            //                             FontWeight
                                            //                                 .bold,
                                            //                         fontSize:
                                            //                             16,
                                            //                       ),
                                            //                     ),
                                            //                   ),
                                            //                 ],
                                            //               ),
                                            //             ),
                                            //           ),
                                            //           if (isTenantExpanded)
                                            //             Container(
                                            //               width:
                                            //                   double.infinity,
                                            //               // color: Colors.amber,
                                            //               child: Padding(
                                            //                 padding:
                                            //                     const EdgeInsets
                                            //                         .all(16.0),
                                            //                 child: Column(
                                            //                   crossAxisAlignment:
                                            //                       CrossAxisAlignment
                                            //                           .start,
                                            //                   children: [
                                            //                     Column(
                                            //                       crossAxisAlignment:
                                            //                           CrossAxisAlignment
                                            //                               .start,
                                            //                       children: [
                                            //                         Row(
                                            //                           children: [
                                            //                             SizedBox(
                                            //                                 width:
                                            //                                     MediaQuery.of(context).size.width * .01),
                                            //                             Column(
                                            //                               crossAxisAlignment:
                                            //                                   CrossAxisAlignment.start,
                                            //                               children: [
                                            //                                 Text(
                                            //                                   'Insurance Provider',
                                            //                                   style: TextStyle(
                                            //                                     color: blueColor,
                                            //                                     fontWeight: FontWeight.bold,
                                            //                                     fontSize: 16,
                                            //                                   ),
                                            //                                 ),
                                            //                                 Text(
                                            //                                   '${tenant.tenantInsurance?.policyId ?? '-'}',
                                            //                                   style: TextStyle(
                                            //                                     color: Colors.grey[500],
                                            //                                     fontWeight: FontWeight.bold,
                                            //                                     fontSize: 16,
                                            //                                   ),
                                            //                                 ),
                                            //                               ],
                                            //                             ),
                                            //                             SizedBox(
                                            //                                 width:
                                            //                                     MediaQuery.of(context).size.width * .04),
                                            //                             Column(
                                            //                               crossAxisAlignment:
                                            //                                   CrossAxisAlignment.start,
                                            //                               children: [
                                            //                                 Text(
                                            //                                   'Policy',
                                            //                                   style: TextStyle(
                                            //                                     color: blueColor,
                                            //                                     fontWeight: FontWeight.bold,
                                            //                                     fontSize: 16,
                                            //                                   ),
                                            //                                 ),
                                            //                                 Text(
                                            //                                   '${tenant.tenantInsurance?.policyId ?? '-'}',
                                            //                                   style: TextStyle(
                                            //                                     color: Colors.grey[500],
                                            //                                     fontWeight: FontWeight.bold,
                                            //                                     fontSize: 16,
                                            //                                   ),
                                            //                                 ),
                                            //                               ],
                                            //                             ),
                                            //                             SizedBox(
                                            //                                 width:
                                            //                                     MediaQuery.of(context).size.width * .04),
                                            //                             Column(
                                            //                               crossAxisAlignment:
                                            //                                   CrossAxisAlignment.start,
                                            //                               children: [
                                            //                                 Text(
                                            //                                   'Liability Coverage',
                                            //                                   style: TextStyle(
                                            //                                     color: blueColor,
                                            //                                     fontWeight: FontWeight.bold,
                                            //                                     fontSize: 16,
                                            //                                   ),
                                            //                                 ),
                                            //                                 Text(
                                            //                                   '${tenant.tenantInsurance?.liabilityCoverage ?? '-'}',
                                            //                                   style: TextStyle(
                                            //                                     color: Colors.grey[500],
                                            //                                     fontWeight: FontWeight.bold,
                                            //                                     fontSize: 16,
                                            //                                   ),
                                            //                                 ),
                                            //                               ],
                                            //                             ),
                                            //                             SizedBox(
                                            //                                 width:
                                            //                                     MediaQuery.of(context).size.width * .04),
                                            //                             Column(
                                            //                               crossAxisAlignment:
                                            //                                   CrossAxisAlignment.start,
                                            //                               children: [
                                            //                                 Text(
                                            //                                   'Effective Date',
                                            //                                   style: TextStyle(
                                            //                                     color: blueColor,
                                            //                                     fontWeight: FontWeight.bold,
                                            //                                     fontSize: 16,
                                            //                                   ),
                                            //                                 ),
                                            //                                 Text(
                                            //                                   '${tenant.tenantInsurance?.effectiveDate ?? '-'}',
                                            //                                   style: TextStyle(
                                            //                                     color: Colors.grey[500],
                                            //                                     fontWeight: FontWeight.bold,
                                            //                                     fontSize: 16,
                                            //                                   ),
                                            //                                 ),
                                            //                               ],
                                            //                             ),
                                            //                             SizedBox(
                                            //                                 width:
                                            //                                     MediaQuery.of(context).size.width * .04),
                                            //                             Column(
                                            //                               crossAxisAlignment:
                                            //                                   CrossAxisAlignment.start,
                                            //                               children: [
                                            //                                 Text(
                                            //                                   'Expiration Date',
                                            //                                   style: TextStyle(
                                            //                                     color: blueColor,
                                            //                                     fontWeight: FontWeight.bold,
                                            //                                     fontSize: 16,
                                            //                                   ),
                                            //                                 ),
                                            //                                 Text(
                                            //                                   '${tenant.tenantInsurance?.expirationDate ?? '-'}',
                                            //                                   style: TextStyle(
                                            //                                     color: Colors.grey[500],
                                            //                                     fontWeight: FontWeight.bold,
                                            //                                     fontSize: 16,
                                            //                                   ),
                                            //                                 ),
                                            //                               ],
                                            //                             ),
                                            //                           ],
                                            //                         ),
                                            //                         const SizedBox(
                                            //                           height:
                                            //                               10,
                                            //                         ),
                                            //                       ],
                                            //                     ),
                                            //                   ],
                                            //                 ),
                                            //               ),
                                            //             ),
                                            //         ],
                                            //       );
                                            //     }).toList(),
                                            //   ),
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
                                ),
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
