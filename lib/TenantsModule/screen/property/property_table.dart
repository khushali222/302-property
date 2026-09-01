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
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';

import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../../constant/constant.dart';

import '../../../provider/dateProvider.dart';
import '../../model/tenant_property.dart';

import '../../widgets/appbar.dart';
import '../../repository/tenant_repository.dart';
import '../../widgets/custom_drawer.dart';
import '../../widgets/drawer_tiles.dart';
import 'package:three_zero_two_property/widgets/no_internet_view.dart';
import 'package:three_zero_two_property/provider/network_retry_state.dart';

class PropertyTable extends StatefulWidget {
  @override
  _PropertyTableState createState() => _PropertyTableState();
}

class _PropertyTableState extends State<PropertyTable>
    with NetworkRetryState {
  int totalrecords = 0;
  late Future<List<tenant_property>> futurePropertyTypes;
  int rowsPerPage = 5;
  int sortColumnIndex = 0;
  bool sortAscending = true;
  int currentPage = 0;
  int itemsPerPage = 10;
  List<int> itemsPerPageOptions = [10, 25, 50, 100];

  void sortData(List<tenant_property> data) {}

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
    return Container(
      decoration: BoxDecoration(
          color: Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFDBE0E5))),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Text('Rental Address',
                  style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
          Container(width: 1, height: 40, color: Color(0xFFDBE0E5)),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text('Start Date',
                  style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
          Container(width: 1, height: 40, color: Color(0xFFDBE0E5)),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Text('End Date',
                  style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  final List<String> items = ['Residential', "Commercial", "All"];
  String? selectedValue;

  ConnectivityResult? _connectivityResult;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
  String searchvalue = "";

  /// Required by [NetworkRetryState]: re-issue this screen's own load.
  /// These are the data calls `initState` makes; nothing that sets up
  /// controllers, filters or defaults is repeated, so a reload cannot
  /// reset what the user is looking at.
  @override
  Future<void> reloadData() async {
    if (!mounted) return;
    setState(() {
      futurePropertyTypes = TenantPropertyRepository().fetchTenantProperties();;
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
    futurePropertyTypes = TenantPropertyRepository().fetchTenantProperties();
  }

  void checkInternet() async {
    var connectiondata = await Connectivity().checkConnectivity();
    // connectivity_plus can report a stale `none` after the
    // connection is back; confirm before believing it.
    if (connectiondata == ConnectivityResult.none &&
        await hasNetworkNow()) {
      connectiondata = ConnectivityResult.wifi;
    }
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  void handleEdit(tenant_property property) async {}

  void _showAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this property!",
      style: AlertStyle(backgroundColor: Colors.white),
      buttons: [
        DialogButton(
          child: Text("Cancel",
              style: TextStyle(
                  color: blueColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.pop(context),
          color: Colors.white,
          radius: BorderRadius.circular(8),
          border: Border.all(color: blueColor, width: 1.5),
        ),
        DialogButton(
          child: Text("Delete",
              style: TextStyle(color: Colors.white, fontSize: 18)),
          onPressed: () async {},
          color: Colors.red,
        )
      ],
    ).show();
  }

  List<tenant_property> _tableData = [];
  int _rowsPerPage = 10;
  int _currentPage = 0;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  List<tenant_property> get _pagedData {
    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;
    return _tableData.sublist(
        startIndex, endIndex > _tableData.length ? _tableData.length : endIndex);
  }

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0;
    });
  }

  void _sort<T>(Comparable<T> Function(tenant_property d) getField,
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

  void handleDelete(tenant_property property) {}

  Widget _buildHeader<T>(String text, int columnIndex,
      Comparable<T> Function(tenant_property d)? getField) {
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

  Widget _buildDataCell(String text, tenant_property Propertytype) {
    return TableCell(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => summery_page(
                    lease_id: Propertytype.leaseId,
                  )));
        },
        child: Container(
          height: 60,
          padding: const EdgeInsets.only(top: 20.0, left: 16),
          child: Text(text, style: const TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildActionsCell(tenant_property data) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Container(
          height: 50,
          child: Row(
            children: [
              const SizedBox(width: 20),
              InkWell(
                onTap: () {
                  handleEdit(data);
                },
                child: const FaIcon(FontAwesomeIcons.edit, size: 30),
              ),
              const SizedBox(width: 15),
              InkWell(
                onTap: () {
                  handleDelete(data);
                },
                child: const FaIcon(FontAwesomeIcons.trashCan, size: 30),
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
                icon: Icon(Icons.arrow_drop_down, size: 40),
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
                : Color.fromRGBO(21, 43, 83, 1),
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
      drawer: CustomDrawer(currentpage: 'Property'),
      body: !isOffline
          ? SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 8.0),
                    child: titleBar(width: double.infinity, title: 'Property'),
                  ),
                  SizedBox(height: 10),
                  // Search bar
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
                          hintStyle: TextStyle(
                            color: Color(0xFF8A95A8),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Color(0xFF8A95A8),
                            size: 20,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ),
                  if (MediaQuery.of(context).size.width > 500) SizedBox(height: 25),
                  // Mobile list
                  if (MediaQuery.of(context).size.width < 500)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 13.0),
                      child: FutureBuilder<List<tenant_property>>(
                        future: futurePropertyTypes,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              margin: const EdgeInsets.only(top: 20.0),
                              child: ColabShimmerLoadingWidget(),
                            );
                          } else if (snapshot.hasError) {
                            return Center(child: Text(friendlyErrorMessage(snapshot.error), textAlign: TextAlign.center));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Container(
                              height: MediaQuery.of(context).size.height * .5,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Image.asset("assets/images/no_data.jpg",
                                        height: 200, width: 200),
                                    SizedBox(height: 10),
                                    Text("No Data Available",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: blueColor,
                                            fontSize: 16)),
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
                                  .where((property) => (property.rentalAdress ?? '')
                                      .toLowerCase()
                                      .contains(searchvalue!.toLowerCase()))
                                  .toList();
                            }
                            if (data.length == 0) {
                              return Column(
                                children: [
                                  SizedBox(height: 14),
                                  _buildHeaders(),
                                  SizedBox(height: 30),
                                  Image.asset(
                                    "assets/images/no_data.jpg",
                                    height: 120,
                                    width: 120,
                                  ),
                                  SizedBox(height: 10),
                                  Text(
                                    "No Data Available",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                ],
                              );
                            }
                            sortData(data);
                            final totalPages = (data.isEmpty ? 1 : (data.length / itemsPerPage).ceil());
                            final currentPageData = data
                                .skip(currentPage * itemsPerPage)
                                .take(itemsPerPage)
                                .toList();
                            return SingleChildScrollView(
                              child: Column(
                                children: [
                                  SizedBox(height: 14),
                                  _buildHeaders(),
                                  SizedBox(height: 8),
                                  Column(
                                    children: currentPageData.isEmpty
                                        ? [kNoSearchResults(context)]
                                        : currentPageData.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      tenant_property Propertytype = entry.value;
                                      return GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(MaterialPageRoute(
                                              builder: (context) => summery_page(
                                                    lease_id: Propertytype.leaseId,
                                                  )));
                                        },
                                        child: Container(
                                          width: double.infinity,
                                          margin: const EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            color: index % 2 != 0
                                                ? Color(0xFFF4F8FF)
                                                : Colors.white,
                                            border: Border.all(color: Color(0xFFDBE0E5)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: IntrinsicHeight(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.stretch,
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 10, vertical: 12),
                                                    child: Text(
                                                      Propertytype.rentalAdress ?? 'N/A',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 1,
                                                  color: Color(0xFFDBE0E5),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 12),
                                                    child: Text(
                                                      Propertytype.startDate?.isNotEmpty == true
                                                          ? dateProvider.formatCurrentDate(
                                                              '${Propertytype.startDate}')
                                                          : 'N/A',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 1,
                                                  color: Color(0xFFDBE0E5),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Padding(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 8, vertical: 12),
                                                    child: Text(
                                                      Propertytype.endDate?.isNotEmpty == true
                                                          ? dateProvider.formatCurrentDate(
                                                              '${Propertytype.endDate}')
                                                          : 'N/A',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                  if (data.length > itemsPerPage) ...[
                                  SizedBox(height: 20),
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
                                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                                              decoration: BoxDecoration(
                                                border: Border.all(color: Colors.grey),
                                              ),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton<int>(
                                                  value: itemsPerPage,
                                                  items: itemsPerPageOptions.map((int value) {
                                                    return DropdownMenuItem<int>(
                                                      value: value,
                                                      child: Text(value.toString()),
                                                    );
                                                  }).toList(),
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      itemsPerPage = newValue!;
                                                      currentPage = 0;
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
                                              color: currentPage == 0 ? Colors.grey : blueColor,
                                            ),
                                            onPressed: currentPage == 0
                                                ? null
                                                : () {
                                                    setState(() {
                                                      currentPage--;
                                                    });
                                                  },
                                          ),
                                          Text('Page ${currentPage + 1} of $totalPages'),
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
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  // Tablet/desktop table
                  if (MediaQuery.of(context).size.width > 500)
                    FutureBuilder<List<tenant_property>>(
                      future: futurePropertyTypes,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(
                            child: SpinKitFadingCircle(color: Colors.black, size: 55.0),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Container(
                            height: MediaQuery.of(context).size.height * .5,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset("assets/images/no_data.jpg",
                                      height: 200, width: 200),
                                  SizedBox(height: 10),
                                  Text("No Data Available",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: blueColor,
                                          fontSize: 16)),
                                ],
                              ),
                            ),
                          );
                        } else {
                          _tableData = snapshot.data!;
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
                                            padding: const EdgeInsets.only(left: 2),
                                            width: MediaQuery.of(context).size.width * .91,
                                            child: Column(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF4F8FF),
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: Color(0xFFDBE0E5)),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: 16, vertical: 20),
                                                          child: Text('Rental Address',
                                                              style: TextStyle(
                                                                  color: blueColor,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 15)),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: 16, vertical: 20),
                                                          child: Text('Start Date',
                                                              style: TextStyle(
                                                                  color: blueColor,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 15)),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: 16, vertical: 20),
                                                          child: Text('End Date',
                                                              style: TextStyle(
                                                                  color: blueColor,
                                                                  fontWeight: FontWeight.bold,
                                                                  fontSize: 15)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 10),
                                                for (var i = 0; i < _pagedData.length; i++)
                                                  Column(
                                                    children: [
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          color: i % 2 != 0
                                                              ? Color(0xFFF4F8FF)
                                                              : Colors.white,
                                                          border: Border.all(
                                                              color: Color(0xFFDBE0E5)),
                                                          borderRadius:
                                                              BorderRadius.circular(10),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal: 16,
                                                                    vertical: 20),
                                                                child: InkWell(
                                                                  onTap: () {
                                                                    Navigator.of(context).push(
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                summery_page(
                                                                                  lease_id: _pagedData[i].leaseId,
                                                                                )));
                                                                  },
                                                                  child: Text(
                                                                    _pagedData[i].rentalAdress!,
                                                                    style: TextStyle(
                                                                        color: blueColor,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        fontSize: 13),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal: 16,
                                                                    vertical: 20),
                                                                child: Text(
                                                                  _pagedData[i].startDate ?? 'N/A',
                                                                  style: TextStyle(
                                                                      color: Colors.grey[700],
                                                                      fontSize: 12),
                                                                ),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Container(
                                                                padding: EdgeInsets.symmetric(
                                                                    horizontal: 16,
                                                                    vertical: 20),
                                                                child: Text(
                                                                  _pagedData[i].endDate ?? 'N/A',
                                                                  style: TextStyle(
                                                                      color: Colors.grey[700],
                                                                      fontSize: 12),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      if (i < _pagedData.length - 1)
                                                        SizedBox(height: 10),
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

void main() => runApp(MaterialApp(home: PropertyTable()));
