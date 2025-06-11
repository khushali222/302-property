import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';

import '../../Model/Dashbord_table/lease_expiring_table.dart';

import '../../constant/constant.dart';

import '../../provider/dateProvider.dart';

import '../../repository/dashboard_table_repo/lease_expiring_table.dart';
import '../../widgets/CustomTableShimmer.dart';

class Dashboard_leaseExpiring extends StatefulWidget {
  @override
  _Dashboard_leaseExpiringState createState() =>
      _Dashboard_leaseExpiringState();
}

class _Dashboard_leaseExpiringState extends State<Dashboard_leaseExpiring> {
  int totalrecords = 0;
  Future<List<LeaseDataExpiring>>? futureleaseExpiring;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 5;
  List<int> itemsPerPageOptions = [
    5,
    10,
    25,
  ]; // Options for items per page

  // void sortData(List<LeaseDataExpiring> data) {
  //   if (sorting1) {
  //     data.sort((a, b) => ascending1
  //         ? a.propertyType!.compareTo(b.propertyType!)
  //         : b.propertyType!.compareTo(a.propertyType!));
  //   } else if (sorting2) {
  //     data.sort((a, b) => ascending2
  //         ? a.propertysubType!.compareTo(b.propertysubType!)
  //         : b.propertysubType!.compareTo(a.propertysubType!));
  //   } else if (sorting3) {
  //     data.sort((a, b) => ascending3
  //         ? a.createdAt!.compareTo(b.createdAt!)
  //         : b.createdAt!.compareTo(a.createdAt!));
  //   }
  // }

  int? expandedIndex;
  Set<int> expandedIndices = {};
  late bool isExpanded;
  bool sorting1 = false;
  bool sorting2 = false;
  bool sorting3 = false;
  bool ascending1 = false;
  bool ascending2 = false;
  bool ascending3 = false;
  Widget _buildHeaders(List<LeaseDataExpiring> policyList) {
    var width = MediaQuery.of(context).size.width;
    return Column(
      children: [
        // Title with border and rounded corners
        Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: blueColor, // Background color
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(13),
              topRight: Radius.circular(13),
            ),
          ),
          child: Center(
            child: Text(
              "Leases Expiring in the next 60 days",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
        if (policyList.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(0),
                right: Radius.circular(0),
              ),
              border: Border.all(color: Color.fromRGBO(152, 162, 179, .5)),
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
                              ? Text("  Rental\n Address",
                              style: TextStyle(
                                color: Color.fromRGBO(50, 75, 119, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ))
                              : Text("  Rental\n Address",
                              style: TextStyle(
                                color: Color.fromRGBO(50, 75, 119, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                          // Text("Property", style: TextStyle(color: Colors.white)),
                          SizedBox(width: 3),
                          // ascending1
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
                          Text("Tenant\n Name",
                              style: TextStyle(
                                color: Color.fromRGBO(50, 75, 119, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                          // SizedBox(width: 5),
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
                          Text("   Expiration\n      Date",
                              style: TextStyle(
                                color: Color.fromRGBO(50, 75, 119, 1),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(width: 5),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (policyList.isEmpty)
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade300, // Background color
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(13),
                bottomRight: Radius.circular(13),
              ),
            ),
            child: Center(
              child: Text(
                "No leases are expiring within 60 days.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  // Widget _buildHeaders() {
  //   var width = MediaQuery.of(context).size.width;
  //   return
  //     Container(
  //     decoration: BoxDecoration(
  //       color: blueColor,
  //       borderRadius: BorderRadius.only(
  //         topLeft: Radius.circular(13),
  //         topRight: Radius.circular(13),
  //       ),
  //     ),
  //     child: ListTile(
  //       contentPadding: EdgeInsets.zero,
  //       // leading: Container(
  //       //   child: Icon(
  //       //     Icons.expand_less,
  //       //     color: Colors.transparent,
  //       //   ),
  //       // ),
  //       title: Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         children: <Widget>[
  //           Container(
  //             child: Icon(
  //               Icons.expand_less,
  //               color: Colors.transparent,
  //             ),
  //           ),
  //           Expanded(
  //             child: InkWell(
  //               onTap: () {
  //                 setState(() {
  //                   if (sorting1 == true) {
  //                     sorting2 = false;
  //                     sorting3 = false;
  //                     ascending1 = sorting1 ? !ascending1 : true;
  //                     ascending2 = false;
  //                     ascending3 = false;
  //                   } else {
  //                     sorting1 = !sorting1;
  //                     sorting2 = false;
  //                     sorting3 = false;
  //                     ascending1 = sorting1 ? !ascending1 : true;
  //                     ascending2 = false;
  //                     ascending3 = false;
  //                   }
  //
  //                   // Sorting logic here
  //                 });
  //               },
  //               child: Row(
  //                 children: [
  //                   width < 400
  //                       ? Text("Tenant\n Name ",
  //                           style: TextStyle(color: Colors.white,fontSize: 13))
  //                       : Text("Tenant\n Name",
  //                           style: TextStyle(color: Colors.white,fontSize: 13)),
  //                   // Text("Property", style: TextStyle(color: Colors.white)),
  //                   SizedBox(width: 3),
  //                   // ascending1
  //                   //     ? Padding(
  //                   //         padding: const EdgeInsets.only(top: 7, left: 2),
  //                   //         child: FaIcon(
  //                   //           FontAwesomeIcons.sortUp,
  //                   //           size: 20,
  //                   //           color: Colors.white,
  //                   //         ),
  //                   //       )
  //                   //     : Padding(
  //                   //         padding: const EdgeInsets.only(bottom: 7, left: 2),
  //                   //         child: FaIcon(
  //                   //           FontAwesomeIcons.sortDown,
  //                   //           size: 20,
  //                   //           color: Colors.white,
  //                   //         ),
  //                   //       ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Expanded(
  //             child: InkWell(
  //               onTap: () {
  //                 setState(() {
  //                   if (sorting2) {
  //                     sorting1 = false;
  //                     sorting2 = sorting2;
  //                     sorting3 = false;
  //                     ascending2 = sorting2 ? !ascending2 : true;
  //                     ascending1 = false;
  //                     ascending3 = false;
  //                   } else {
  //                     sorting1 = false;
  //                     sorting2 = !sorting2;
  //                     sorting3 = false;
  //                     ascending2 = sorting2 ? !ascending2 : true;
  //                     ascending1 = false;
  //                     ascending3 = false;
  //                   }
  //                   // Sorting logic here
  //                 });
  //               },
  //               child: Row(
  //                 children: [
  //                   Text("  Rental\n Address", style: TextStyle(color: Colors.white,fontSize: 13)),
  //                   // SizedBox(width: 5),
  //                   // ascending2
  //                   //     ? Padding(
  //                   //         padding: const EdgeInsets.only(top: 7, left: 2),
  //                   //         child: FaIcon(
  //                   //           FontAwesomeIcons.sortUp,
  //                   //           size: 20,
  //                   //           color: Colors.white,
  //                   //         ),
  //                   //       )
  //                   //     : Padding(
  //                   //         padding: const EdgeInsets.only(bottom: 7, left: 2),
  //                   //         child: FaIcon(
  //                   //           FontAwesomeIcons.sortDown,
  //                   //           size: 20,
  //                   //           color: Colors.white,
  //                   //         ),
  //                   //       ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //           Expanded(
  //             child: InkWell(
  //               onTap: () {
  //                 setState(() {
  //                   if (sorting3) {
  //                     sorting1 = false;
  //                     sorting2 = false;
  //                     sorting3 = sorting3;
  //                     ascending3 = sorting3 ? !ascending3 : true;
  //                     ascending2 = false;
  //                     ascending1 = false;
  //                   } else {
  //                     sorting1 = false;
  //                     sorting2 = false;
  //                     sorting3 = !sorting3;
  //                     ascending3 = sorting3 ? !ascending3 : true;
  //                     ascending2 = false;
  //                     ascending1 = false;
  //                   }
  //
  //                   // Sorting logic here
  //                 });
  //               },
  //               child: Row(
  //                 children: [
  //                   Text("   Expiration\n      Date", style: TextStyle(color: Colors.white,fontSize: 13)),
  //                   SizedBox(width: 5),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String searchvalue = "";
  @override
  void initState() {
    super.initState();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
        if (_connectivityResult != ConnectivityResult.none)
          futureleaseExpiring =
              Lease_expiring_tableService().fetchLease_expiring();
      });
    });
    checkInternet();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });

    if (_connectivityResult != ConnectivityResult.none)
      futureleaseExpiring = Lease_expiring_tableService().fetchLease_expiring();
  }

  List<LeaseDataExpiring> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<LeaseDataExpiring> get _pagedData {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    return _tableData.sublist(startIndex,
        endIndex > _tableData.length ? _tableData.length : endIndex);
  }

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0; // Reset to the first page when changing rows per page
    });
  }

  void _sort<T>(Comparable<T> Function(LeaseDataExpiring d) getField,
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

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(LeaseDataExpiring d)? getField) {
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

  Widget _buildDataCell(String text) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 16),
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
            padding: EdgeInsets.symmetric(horizontal: 12.0),
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
                icon: Icon(
                  Icons.arrow_drop_down,
                  size: 40,
                ),
                style: TextStyle(color: Colors.black, fontSize: 17),
                dropdownColor: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
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
          style: TextStyle(fontSize: 18),
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

  TextStyle subTextStyle = TextStyle(
    fontSize: 14,
  );
  TextStyle cardTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  ConnectivityResult? _connectivityResult;
  final _scrollController = ScrollController();

  // Add this card widget for displaying each lease in a card with expandable details
  Widget leaseExpiringCard(
      LeaseDataExpiring data,
      bool isExpanded,
      VoidCallback onExpandTap,
      DateProvider dateProvider,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onExpandTap,
                child: Icon(
                  isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: blueColor,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.rentalAddress ?? 'N/A',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          if (isExpanded) ...[
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(
                  thickness: 2,
                ),
                const SizedBox(height: 4),
                // First row: Date & Response
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tenant: ',
                            style: subTextStyle.copyWith(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data.tenantName ?? "-",
                            style: subTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Expiration Date: ',
                            style: subTextStyle.copyWith(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            data.endDate != null ? data.endDate! : "-",
                            style: subTextStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Second row: Type & Description
              ],
            ),
            // Add more details here if needed
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    //final themeProvider = Provider.of<ThemeProvider>(context);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //SizedBox(height: 20),
          //Text("Renter's Insurance Policies Expiring Within 90 days",style: TextStyle(fontWeight: FontWeight.bold,color: blueColor),),
          if (MediaQuery.of(context).size.width < 500)
            Padding(
              padding: const EdgeInsets.all(0.0),
              child: FutureBuilder<List<LeaseDataExpiring>>(
                future: futureleaseExpiring,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ColabShimmerLoadingWidget();
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
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else {
                    var data = snapshot.data!;
                    if (selectedValue == null && searchvalue!.isEmpty) {
                      data = snapshot.data!;
                    } else if (selectedValue == "All") {
                      data = snapshot.data!;
                    } else if (searchvalue!.isNotEmpty) {
                      data = snapshot.data!
                          .where((property) => property.rentalAddress!
                          .toLowerCase()
                          .contains(searchvalue!.toLowerCase()))
                          .toList();
                    } else {
                      data = snapshot.data!
                          .where((property) =>
                      property.rentalAddress == selectedValue)
                          .toList();
                    }
                    final totalPages = (data.length / itemsPerPage).ceil();
                    final currentPageData = data.reversed
                        .skip(currentPage * itemsPerPage)
                        .take(itemsPerPage)
                        .toList();
                    return SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          // Title instead of headers
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 0.0),
                            child: Text(
                              'Leases Expiring in the next 60 days',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: blueColor,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Card-based expandable list
                          Column(
                            children:
                            currentPageData.asMap().entries.map((entry) {
                              int index = entry.key;
                              bool isExpanded = expandedIndex == index;
                              LeaseDataExpiring item = entry.value;
                              return leaseExpiringCard(
                                item,
                                isExpanded,
                                    () {
                                  setState(() {
                                    expandedIndex = isExpanded ? null : index;
                                  });
                                },
                                dateProvider,
                              );
                            }).toList(),
                          ),
                          if (data.length > 5) SizedBox(height: 20),
                          if (data.length > 5)
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
                                          border:
                                          Border.all(color: Colors.grey),
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
                                            onChanged: data.length >
                                                itemsPerPageOptions.first
                                                ? (newValue) {
                                              setState(() {
                                                itemsPerPage = newValue!;
                                                currentPage = 0;
                                              });
                                            }
                                                : null,
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
                    );
                  }
                },
              ),
            ),
          if (MediaQuery.of(context).size.width > 500)
            FutureBuilder<List<LeaseDataExpiring>>(
              future: futureleaseExpiring,
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
                } else {
                  _tableData = snapshot.data!;
                  if (selectedValue == null && searchvalue.isEmpty) {
                    _tableData = snapshot.data!;
                  } else if (selectedValue == "All") {
                    _tableData = snapshot.data!;
                  } else if (searchvalue.isNotEmpty) {
                    _tableData = snapshot.data!
                        .where((property) => property.rentalAddress!
                        .toLowerCase()
                        .contains(searchvalue.toLowerCase()))
                        .toList();
                  } else {
                    _tableData = snapshot.data!
                        .where((property) =>
                    property.rentalAddress == selectedValue)
                        .toList();
                  }
                  totalrecords = _tableData.length;
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24.0, vertical: 5),
                            child: Column(
                              children: [
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    width:
                                    MediaQuery.of(context).size.width * .91,
                                    child: Table(
                                      defaultColumnWidth:
                                      IntrinsicColumnWidth(),
                                      children: [
                                        TableRow(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              // color: blueColor
                                            ),
                                          ),
                                          children: [
                                            _buildHeader(
                                                'Main Type',
                                                0,
                                                    (property) =>
                                                property.tenantName!),
                                            _buildHeader(
                                                'Subtype',
                                                1,
                                                    (property) =>
                                                property.rentalAddress!),
                                            _buildHeader(
                                                'Created At',
                                                2,
                                                    (property) =>
                                                property.endDate!),
                                          ],
                                        ),
                                        TableRow(
                                          decoration: BoxDecoration(
                                            border: Border.symmetric(
                                                horizontal: BorderSide.none),
                                          ),
                                          children: List.generate(
                                              3,
                                                  (index) => TableCell(
                                                  child:
                                                  Container(height: 20))),
                                        ),
                                        for (var i = 0;
                                        i < _pagedData.length;
                                        i++)
                                          TableRow(
                                            decoration: BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                    color: blueColor),
                                                right: BorderSide(
                                                    color: blueColor),
                                                top: BorderSide(
                                                    color: blueColor),
                                                bottom:
                                                i == _pagedData.length - 1
                                                    ? BorderSide(
                                                    color: blueColor)
                                                    : BorderSide.none,
                                              ),
                                            ),
                                            children: [
                                              _buildDataCell(
                                                  _pagedData[i].tenantName!),
                                              _buildDataCell(
                                                  _pagedData[i].rentalAddress!),
                                              _buildDataCell(
                                                formatDate(
                                                    _pagedData[i].endDate!),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 25),
                                _buildPaginationControls(),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                      ],
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
