import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:three_zero_two_property/TenantsModule/screen/property/summery_page.dart';
import 'package:three_zero_two_property/provider/dateProvider.dart';

import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../constant/constant.dart';

import '../../model/lease_model.dart';
import '../../model/tenant_property.dart';

import '../../repository/lease_data.dart';
import '../../widgets/appbar.dart';
import '../../repository/tenant_repository.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/no_internet_view.dart';
import 'package:three_zero_two_property/provider/network_retry_state.dart';

class Lease_Table extends StatefulWidget {
  @override
  _Lease_TableState createState() => _Lease_TableState();
}

class _Lease_TableState extends State<Lease_Table>
    with NetworkRetryState {
  int totalrecords = 0;
  late Future<List<tenant_lease>> futurePropertyTypes;
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
  ]; // Options for items per page

  void sortData(List<tenant_lease> data) {
    // Sort by createdAt in descending order (newest first)
    data.sort((a, b) {
      try {
        DateTime dateA = _parseDate(a.createdAt!);
        DateTime dateB = _parseDate(b.createdAt!);
        return dateB.compareTo(dateA); // Descending order
      } catch (e) {
        // If parsing fails, keep original order
        return 0;
      }
    });
  }

  DateTime _parseDate(String dateString) {
    // Handle null or empty strings
    if (dateString.isEmpty) {
      return DateTime.now();
    }

    // Try to parse ISO format first (e.g., "2025-06-09 14:27:25")
    if (dateString.contains('-') && dateString.contains(':')) {
      return DateTime.parse(dateString);
    }

    // Try to parse JavaScript Date format (e.g., "Mon Mar 10 2025 16:33:25 GMT+0530")
    if (dateString.contains('GMT')) {
      // Remove timezone info and parse
      String cleanDate = dateString.split('GMT')[0].trim();
      return DateFormat("EEE MMM dd y HH:mm:ss").parse(cleanDate);
    }

    // Try to parse simple date format (e.g., "2025-01-22")
    if (dateString.contains('-') && !dateString.contains(':')) {
      return DateTime.parse(dateString);
    }

    // If all else fails, return current date
    return DateTime.now();
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

  /// Money cell for the lease-documents list, mirroring DocLeases.jsx:
  /// `value ? "$" + value : "N/A"`. JavaScript treats 0 as falsy, so a missing
  /// value AND a zero both read as "N/A" here. Scoped to this screen — every
  /// other screen still shows $0.00 for a genuine zero.
  String _moneyOrNA(dynamic value) {
    final double amount = value is num
        ? value.toDouble()
        : double.tryParse(
                value?.toString().replaceAll(RegExp(r'[^0-9.-]'), '') ?? '') ??
            0.0;
    return amount == 0 ? 'N/A' : formatMoney(amount);
  }

  // Change 1: Clean _buildHeaders() replacing the ListTile-based version
  Widget _detailRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: blueColor,
                fontSize: 13,
              ),
            ),
          ),
          Text(': ', style: TextStyle(color: blueColor, fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: grey, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFDBE0E5))),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              flex: 4,
              child: Text(
                width < 400 ? "        Lease" : "         Lease",
                style: TextStyle(color: blueColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                "   Lease Start",
                style: TextStyle(color: blueColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                " Lease End",
                style: TextStyle(color: blueColor, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;
  String searchvalue = "";
  ConnectivityResult? _connectivityResult;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  /// Required by [NetworkRetryState]: re-issue this screen's own load.
  /// These are the data calls `initState` makes; nothing that sets up
  /// controllers, filters or defaults is repeated, so a reload cannot
  /// reset what the user is looking at.
  @override
  Future<void> reloadData() async {
    if (!mounted) return;
    setState(() {
      futurePropertyTypes = TenantleaseRepository().fetchTenantleases();;
    });
  }

  @override
  void initState() {
    super.initState();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (!mounted) return;
      // The event is only a trigger: checkInternet() verifies
      // against the network before deciding, so a stale `none`
      // from the plugin cannot strand this screen offline.
      checkInternet();
    });
    checkInternet();

    futurePropertyTypes = TenantleaseRepository().fetchTenantleases();
  }

  void checkInternet() async {
    var connectiondata = await Connectivity().checkConnectivity();
    // connectivity_plus answers from a cached reachability result that
    // can stay `none` after the connection is back (reliably so on the
    // iOS simulator), which made this screen declare itself offline
    // while requests actually succeed. Confirm before believing it.
    if (connectiondata == ConnectivityResult.none &&
        await hasNetworkNow()) {
      connectiondata = ConnectivityResult.wifi;
    }
    if (!mounted) return;
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  String _formatDate(String dateString) {
    try {
      // Handle null or empty strings
      if (dateString.isEmpty) {
        return 'N/A';
      }

      // Try to parse ISO format first (e.g., "2025-06-09 14:27:25")
      if (dateString.contains('-') && dateString.contains(':')) {
        DateTime date = DateTime.parse(dateString);
        return DateFormat('yyyy-MM-dd').format(date);
      }

      // Try to parse JavaScript Date format (e.g., "Mon Mar 10 2025 16:33:25 GMT+0530")
      if (dateString.contains('GMT')) {
        // Remove timezone info and parse
        String cleanDate = dateString.split('GMT')[0].trim();
        DateTime date = DateFormat("EEE MMM dd y HH:mm:ss").parse(cleanDate);
        return DateFormat('yyyy-MM-dd').format(date);
      }

      // Try to parse simple date format (e.g., "2025-01-22")
      if (dateString.contains('-') && !dateString.contains(':')) {
        DateTime date = DateTime.parse(dateString);
        return DateFormat('yyyy-MM-dd').format(date);
      }

      // If all else fails, return the original string
      return dateString;
    } catch (e) {
      // If parsing fails, return the original string
      return dateString;
    }
  }

  void handleEdit(tenant_property property) async {
    /* // Handle edit action
    var check = await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Edit_property_type(
              property: property,
            )));
    if (check == true) {
      setState(() {});
    }*/
    // final result = await Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (context) => Edit_property_type(
    //               property: property,
    //             )));
    /* if (result == true) {
      setState(() {
        futurePropertyTypes = PropertyTypeRepository().fetchPropertyTypes();
      });
    }*/
  }

  void _showAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this property!",
      style: AlertStyle(
        backgroundColor: Colors.white,
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Cancel",
            style: TextStyle(
                color: blueColor, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          radius: BorderRadius.circular(8), // Rounded corners
          border: Border.all(
            color: blueColor, // Blue border
            width: 1.5,
          ),
        ),
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            /* var data = TenantPropertyRepository().DeletePropertyType(id: id);
            // Add your delete logic here
            setState(() {
              futurePropertyTypes =
                  PropertyTypeRepository().fetchPropertyTypes();
            });
            Navigator.pop(context);*/
          },
          color: Colors.red,
        )
      ],
    ).show();
  }

  List<tenant_lease> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<tenant_lease> get _pagedData {
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

  void _sort<T>(Comparable<T> Function(tenant_lease d) getField,
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

  void handleDelete(tenant_property property) {
    // _showAlert(context, property.propertyId!);
    // // Handle delete action
    // print('Delete ${property.sId}');
  }

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(tenant_lease d)? getField) {
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
      child: Container(
        height: 60,
        padding: const EdgeInsets.only(top: 20.0, left: 16),
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  Widget _buildActionsCell(tenant_property data) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 50,
          // color: Colors.blue,
          child: Row(
            children: [
              const SizedBox(
                width: 20,
              ),
              InkWell(
                onTap: () {
                  handleEdit(data);
                },
                child: const FaIcon(
                  FontAwesomeIcons.edit,
                  size: 30,
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              InkWell(
                onTap: () {
                  handleDelete(data);
                },
                child: const FaIcon(
                  FontAwesomeIcons.trashCan,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
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
                : Color.fromRGBO(
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

  final _scrollController = ScrollController();
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return Scaffold(
      key: key,
      appBar: widget_302.App_Bar(
        context: context,
        onDrawerIconPressed: () {
          key.currentState!.openDrawer();
        },
      ),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: 'Documents',
      ),
      body: !isOffline
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),

                  // Header Section with Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: titleBar(
                      width: double.infinity,
                      title: 'Leases',
                    ),
                  ),
                  SizedBox(height: 10),
                  // Change 2: Full-width flat search bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Color(0xFFDBE0E5)),
                      ),
                      child: TextField(
                        style: TextStyle(fontSize: 14),
                        onChanged: (value) {
                          setState(() {
                            searchvalue = value;
                            currentPage = 0; // reset to first page on search change
                          });
                        },
                        cursorColor: blueColor,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search here...",
                          hintStyle: TextStyle(color: Color(0xFF8A95A8), fontSize: 14),
                          prefixIcon: Icon(Icons.search, color: Color(0xFF8A95A8), size: 20),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 500)
                    SizedBox(height: 25),
                  if (MediaQuery.of(context).size.width < 500)
                    // Change 3: horizontal padding 10 -> 13
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13.0),
                      child: FutureBuilder<List<tenant_lease>>(
                        future: futurePropertyTypes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                              padding: EdgeInsets.only(top: 200),
                              child: Center(
                                  child: SpinKitFadingCircle(
                                color: Colors.black,
                                size: 40.0,
                              )),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Text('Error: ${snapshot.error}'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
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
                            var data = snapshot.data!;
                            if (selectedValue == null && searchvalue!.isEmpty) {
                              data = snapshot.data!;
                            } else if (selectedValue == "All") {
                              data = snapshot.data!;
                            } else if (searchvalue!.isNotEmpty) {
                              // rentalAdress is nullable; force-unwrapping it
                              // threw inside build for any lease saved without
                              // an address, breaking the list as soon as a
                              // character was typed.
                              data = snapshot.data!
                                  .where((property) =>
                                      (property.rentalAdress?.toLowerCase() ??
                                              '')
                                          .contains(searchvalue!.toLowerCase()))
                                  .toList();
                            }
                            // Change 4: No data found state with header + image
                            if (data.length == 0) {
                              return Column(
                                children: [
                                  SizedBox(height: 14),
                                  _buildHeaders(),
                                  SizedBox(height: 30),
                                  Image.asset("assets/images/no_data.jpg", height: 120, width: 120),
                                  SizedBox(height: 10),
                                  Text("No Data Available",
                                      style: TextStyle(fontWeight: FontWeight.bold, color: blueColor, fontSize: 15)),
                                  SizedBox(height: 20),
                                ],
                              );
                            }
                            sortData(data);
                            final totalPages =
                                (data.isEmpty ? 1 : (data.length / itemsPerPage).ceil());
                            final currentPageData = data
                                .skip(currentPage * itemsPerPage)
                                .take(itemsPerPage)
                                .toList();
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 20),
                                  _buildHeaders(),
                                  SizedBox(height: 10),
                                  Container(
                                    child: Column(
                                      children: currentPageData.isEmpty
                                          ? [kNoSearchResults(context)]
                                          : currentPageData
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key;
                                        bool isExpanded =
                                            expandedIndex == index;
                                        tenant_lease Propertytype = entry.value;
                                        String formattedDate = _formatDate(
                                            Propertytype.updatedAt!);
                                        // Change 5: Clean mobile data rows with IntrinsicHeight + dividers
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (expandedIndex == index) {
                                                expandedIndex = null;
                                              } else {
                                                expandedIndex = index;
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: double.infinity,
                                            margin: const EdgeInsets.only(bottom: 8),
                                            decoration: BoxDecoration(
                                              color: index % 2 != 0
                                                  ? Color(0xFFF4F8FF)
                                                  : Colors.white,
                                              border: Border.all(
                                                  color: Color(0xFFDBE0E5)),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Column(
                                              children: [
                                                ListTile(
                                                  contentPadding: EdgeInsets.zero,
                                                  title: Padding(
                                                    padding: const EdgeInsets.all(2.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        // expand/collapse icon
                                                        InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              if (expandedIndex == index) {
                                                                expandedIndex = null;
                                                              } else {
                                                                expandedIndex = index;
                                                              }
                                                            });
                                                          },
                                                          child: Container(
                                                            margin: EdgeInsets.only(left: 5),
                                                            padding: !isExpanded
                                                                ? EdgeInsets.only(bottom: 10)
                                                                : EdgeInsets.only(top: 10),
                                                            child: FaIcon(
                                                              isExpanded
                                                                  ? FontAwesomeIcons.sortUp
                                                                  : FontAwesomeIcons.sortDown,
                                                              size: 20,
                                                              color: blueColor,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 4,
                                                          child: Padding(
                                                            padding: const EdgeInsets.only(left: 8.0),
                                                            child: Text(
                                                              Propertytype.rentalAdress ?? 'N/A',
                                                              style: TextStyle(color: blueColor, fontWeight: FontWeight.w600, fontSize: 12),
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            Propertytype.startDate?.isNotEmpty == true
                                                                ? dateProvider.formatCurrentDate('${Propertytype.startDate}')
                                                                : 'N/A',
                                                            style: TextStyle(color: blueColor, fontWeight: FontWeight.bold, fontSize: 12),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            Propertytype.endDate?.isNotEmpty == true
                                                                ? dateProvider.formatCurrentDate('${Propertytype.endDate}')
                                                                : 'N/A',
                                                            style: TextStyle(color: blueColor, fontWeight: FontWeight.bold, fontSize: 12),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                if (isExpanded) ...[
                                                  Divider(height: 1, color: Color(0xFFDBE0E5)),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                    child: Column(
                                                      children: [
                                                        _detailRow('Rent Cycle', '${Propertytype.rentCycle ?? 'N/A'}'),
                                                        // WEB PARITY (DocLeases.jsx): this list shows "N/A" when a
                                                        // figure is missing OR zero — web builds each cell as
                                                        // `value ? "$" + value : "N/A"`, and JavaScript treats 0 as
                                                        // falsy. Only this lease-documents list behaves that way;
                                                        // other screens keep showing $0.00 for a genuine zero.
                                                        _detailRow('Rent',
                                                            _moneyOrNA(Propertytype.leaseAmount)),
                                                        _detailRow('Deposits Held', _moneyOrNA(Propertytype.deposite)),
                                                        _detailRow('Charges', _moneyOrNA(Propertytype.recurringCharge)),
                                                        _detailRow('Created At', Propertytype.createdAt?.isNotEmpty == true ? dateProvider.formatCurrentDate('${Propertytype.createdAt}') : 'N/A'),
                                                        _detailRow('Updated At', Propertytype.updatedAt?.isNotEmpty == true ? dateProvider.formatCurrentDate('$formattedDate') : 'N/A', isLast: true),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  // Change 6: Wrap pagination in if (data.length > itemsPerPage)
                                  if (data.length > itemsPerPage) ...[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            // Text('Rows per page:'),
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
                                                    onChanged: data.length >
                                                            itemsPerPageOptions
                                                                .first // Condition to check if dropdown should be enabled
                                                        ? (newValue) {
                                                            setState(() {
                                                              itemsPerPage =
                                                                  newValue!;
                                                              currentPage =
                                                                  0; // Reset to first page when items per page change
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
                                  ],
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  if (MediaQuery.of(context).size.width > 500)
                    FutureBuilder<List<tenant_lease>>(
                      future: futurePropertyTypes,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: SpinKitFadingCircle(
                              color: Colors.black,
                              size: 55.0,
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
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

                          // Apply search filter if needed
                          if (searchvalue.isNotEmpty) {
                            // rentalAdress is nullable; force-unwrapping it
                            // threw inside build for any lease saved without an
                            // address, breaking the list as soon as a character
                            // was typed.
                            _tableData = _tableData
                                .where((property) =>
                                    (property.rentalAdress?.toLowerCase() ?? '')
                                        .contains(searchvalue.toLowerCase()))
                                .toList();
                          }

                          // Sort by createdAt in descending order
                          sortData(_tableData);

                          totalrecords = _tableData.length;
                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                Container(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0, vertical: 5),
                                    child: Column(
                                      children: [
                                        SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Container(
                                            padding:
                                                const EdgeInsets.only(left: 20),
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
                                                        'Lease',
                                                        0,
                                                        (property) =>
                                                            property.rentalAdress ??
                                                                ''),

                                                    _buildHeader(
                                                        'Lease Start', 2, null),
                                                    _buildHeader(
                                                        'Lease End', 3, null),
                                                    _buildHeader(
                                                        'Rent Cycle', 4, null),
                                                    _buildHeader(
                                                        'Rent Start', 5, null),
                                                    _buildHeader(
                                                        'Rent', 6, null),

                                                    _buildHeader(
                                                        'Deposits Held',
                                                        7,
                                                        null),
                                                    _buildHeader(
                                                        'Charges', 8, null),
                                                    _buildHeader(
                                                        'Created At', 9, null),
                                                    _buildHeader('Last Updated',
                                                        10, null),

                                                    // _buildHeader('Actions', 4, null),
                                                  ],
                                                ),
                                                TableRow(
                                                  decoration: BoxDecoration(
                                                    border: Border.symmetric(
                                                        horizontal:
                                                            BorderSide.none),
                                                  ),
                                                  children: List.generate(
                                                      10,
                                                      (index) => TableCell(
                                                          child: Container(
                                                              height: 20))),
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
                                                        bottom: i ==
                                                                _pagedData
                                                                        .length -
                                                                    1
                                                            ? BorderSide(
                                                                color:
                                                                    blueColor)
                                                            : BorderSide.none,
                                                      ),
                                                    ),
                                                    children: [
                                                      _buildDataCell(
                                                          _pagedData[i]
                                                                  .rentalAdress ??
                                                              ''),

                                                      _buildDataCell(
                                                        _pagedData[i]
                                                            .startDate!,
                                                      ),
                                                      _buildDataCell(
                                                        _pagedData[i].endDate!,
                                                      ),
                                                      _buildDataCell(
                                                        _pagedData[i]
                                                            .rentCycle!,
                                                      ),
                                                      _buildDataCell(
                                                        _pagedData[i]
                                                            .rentDuedate!,
                                                      ),
                                                      _buildDataCell(
                                                        _pagedData[i]
                                                            .leaseAmount
                                                            .toString()!,
                                                      ),
                                                      _buildDataCell(
                                                        _pagedData[i]
                                                            .deposite
                                                            .toString(),
                                                      ),
                                                      _buildDataCell(
                                                        _pagedData[i]
                                                            .recurringCharge!
                                                            .toString(),
                                                      ),
                                                      _buildDataCell(
                                                        _formatDate(
                                                            _pagedData[i]
                                                                .createdAt!),
                                                      ),
                                                      _buildDataCell(
                                                        _formatDate(
                                                            _pagedData[i]
                                                                .updatedAt!),
                                                      ),
                                                      /* _buildActionsCell(_pagedData[i]),*/
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
            )
          : NoInternetView(onRetry: retryNow),
    );
  }
}
