import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:three_zero_two_property/Model/bid_request.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/bid_request.dart';
import 'package:three_zero_two_property/StaffModule/repository/bid_room_repository.dart';
import 'package:three_zero_two_property/StaffModule/widgets/custom_drawer.dart'
    as staff_drawer;
import 'package:three_zero_two_property/StaffModule/widgets/appbar.dart'
    as widget_302_staff;
import 'package:three_zero_two_property/widgets/appbar.dart' as widget_302;
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:three_zero_two_property/widgets/custom_drawer.dart';
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';
import 'package:three_zero_two_property/screens/BidRoom/create_bid_room.dart';

class BidRoomTable extends StatefulWidget {
  /// When true, uses staff drawer, staff app bar, and staff repository.
  final bool useStaffLayout;

  const BidRoomTable({super.key, this.useStaffLayout = false});

  @override
  State<BidRoomTable> createState() => _BidRoomTableState();
}

class _BidRoomTableState extends State<BidRoomTable> {
  late final dynamic _repository;
  List<BidRequest> _bidRequests = [];
  List<BidRequest> _filteredBidRequests = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedTradeType;
  List<String> _tradeTypes = ['All'];
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();
  ConnectivityResult? _connectivityResult;
  bool sorting1 = false;
  bool ascending1 = false;
  int? expandedIndex;
  String? expandedBidRequestId;
  Map<String, BidRequestDetail?> _bidRequestDetails = {};
  Map<String, bool> _loadingDetails = {};

  @override
  void initState() {
    super.initState();
    _repository = widget.useStaffLayout
        ? StaffBidRoomRepository()
        : BidRequestRepository();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
      });
    });
    checkInternet();
    _fetchBidRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  Future<void> _fetchBidRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _repository.fetchBidRequests(
        limit: 10000,
        page: 1,
      );

      if (mounted) {
        setState(() {
          _bidRequests = response.data ?? [];
          _extractTradeTypes();
          _applyFilters();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Error loading bid requests: $e');
      }
    }
  }

  void _extractTradeTypes() {
    Set<String> types = {'All'};
    for (var request in _bidRequests) {
      if (request.workCategory != null && request.workCategory!.isNotEmpty) {
        types.add(request.workCategory!);
      }
    }
    _tradeTypes = types.toList()..sort();
  }

  void _applyFilters() {
    _filteredBidRequests = _bidRequests.where((request) {
      // Search filter
      bool matchesSearch = true;
      if (_searchQuery.isNotEmpty) {
        final searchLower = _searchQuery.toLowerCase();
        matchesSearch = (request.rental?.rentalAddress ?? '')
                .toLowerCase()
                .contains(searchLower) ||
            (request.workCategory ?? '').toLowerCase().contains(searchLower) ||
            (request.description ?? '').toLowerCase().contains(searchLower) ||
            (request.unit?.rentalUnit ?? '')
                .toLowerCase()
                .contains(searchLower);
      }

      // Trade type filter
      bool matchesTradeType = true;
      if (_selectedTradeType != null && _selectedTradeType != 'All') {
        matchesTradeType = request.workCategory == _selectedTradeType;
      }

      return matchesSearch && matchesTradeType;
    }).toList();

    // Apply sorting
    if (sorting1) {
      _filteredBidRequests.sort((a, b) {
        String aTitle = _getBidRoomTitle(a);
        String bTitle = _getBidRoomTitle(b);
        return ascending1
            ? aTitle.toLowerCase().compareTo(bTitle.toLowerCase())
            : bTitle.toLowerCase().compareTo(aTitle.toLowerCase());
      });
    }
  }

  void sortData(List<BidRequest> data) {
    if (sorting1) {
      data.sort((a, b) {
        String aTitle = _getBidRoomTitle(a);
        String bTitle = _getBidRoomTitle(b);
        return ascending1
            ? aTitle.toLowerCase().compareTo(bTitle.toLowerCase())
            : bTitle.toLowerCase().compareTo(aTitle.toLowerCase());
      });
    }
  }

  String _getBidRoomTitle(BidRequest request) {
    String address = request.rental?.rentalAddress ?? 'N/A';
    return address;
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      DateTime date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _fetchBidRequestDetails(String bidRequestId) async {
    // Don't fetch if already loaded or currently loading
    if (_bidRequestDetails.containsKey(bidRequestId) ||
        _loadingDetails[bidRequestId] == true) {
      return;
    }

    setState(() {
      _loadingDetails[bidRequestId] = true;
    });

    try {
      final response = await _repository.fetchBidRequestDetails(
        bidRequestId: bidRequestId,
      );

      if (mounted) {
        setState(() {
          _bidRequestDetails[bidRequestId] = response.data;
          _loadingDetails[bidRequestId] = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingDetails[bidRequestId] = false;
        });
        Fluttertoast.showToast(msg: 'Error loading bid request details: $e');
      }
    }
  }

  List<BidRequest> get _pagedData {
    if (_filteredBidRequests.isEmpty) return [];

    int startIndex = _currentPage * _rowsPerPage;
    int endIndex = startIndex + _rowsPerPage;

    if (startIndex >= _filteredBidRequests.length) {
      _currentPage = (_filteredBidRequests.length / _rowsPerPage).floor() - 1;
      if (_currentPage < 0) _currentPage = 0;
      startIndex = _currentPage * _rowsPerPage;
      endIndex = startIndex + _rowsPerPage;
    }

    endIndex = endIndex > _filteredBidRequests.length
        ? _filteredBidRequests.length
        : endIndex;

    return _filteredBidRequests.sublist(startIndex, endIndex);
  }

  void _changeRowsPerPage(int selectedRowsPerPage) {
    setState(() {
      _rowsPerPage = selectedRowsPerPage;
      _currentPage = 0;
    });
  }

   Widget _buildHeaders() {
    var width = MediaQuery.of(context).size.width;
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDBE0E5))),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
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
              flex: 3,
              child: InkWell(
                 child: Row(
                  children: [
                    width < 400
                        ? Text("  #",
                            style: TextStyle(color: blueColor, fontSize: 14,fontWeight: FontWeight.bold))
                        : Text("  #",
                            style: TextStyle(color: blueColor, fontSize: 14,fontWeight: FontWeight.bold)),
                    
                   
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (sorting1 == true) {
                      ascending1 = !ascending1;
                    } else {
                      sorting1 = true;
                      ascending1 = false;
                    }
                    _applyFilters();
                  });
                },
                child: Row(
                  children: [
                  
                    Text("Bid Room",
                        style: TextStyle(color: blueColor, fontSize: 14,fontWeight: FontWeight.bold )),
                    const SizedBox(width: 5),
                    ascending1
                        ? Padding(
                            padding: const EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortUp,
                              size: 20,
                              color: blueColor,
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.sortDown,
                              size: 20,
                              color: blueColor,
                            ),
                          ),
                  ],
                ),
              ),
            ),
          
          ],
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.useStaffLayout
          ? widget_302_staff.widget_302_Staff.App_Bar(context: context)
          : widget_302.widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: widget.useStaffLayout
          ? staff_drawer.CustomDrawerStaff(
              currentpage: "Bid Room",
              dropdown: false,
            )
          : CustomDrawer(
              currentpage: "Bid Room",
              dropdown: false,
            ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Header Section with Title and Add Button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width > 500)
                          SizedBox(width: 13),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: titleBar(
                              width: double.infinity,
                              title: 'Bid Room',
                            ),
                          ),
                        ),
                        Flexible(
                          flex: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: GestureDetector(
                              onTap: () async {
                                final result = await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => CreateBidRoom(
                                        useStaffLayout: widget.useStaffLayout),
                                  ),
                                );
                                if (result == true) {
                                  setState(() {
                                    _fetchBidRequests();
                                  });
                                }
                              },
                              child: Container(
                                height:
                                    (MediaQuery.of(context).size.width < 768)
                                        ? 50
                                        : 60,
                                decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Center(
                                  child: Text(
                                    "+ Add",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (MediaQuery.of(context).size.width < 500)
                          SizedBox(width: 3),
                        if (MediaQuery.of(context).size.width > 500)
                          SizedBox(width: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Search and Filter section
                  Padding(
                    padding: const EdgeInsets.only(left: 11, right: 11),
                    child: Row(
                      children: [
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(width: 2),
                        if (MediaQuery.of(context).size.width > 500)
                          const SizedBox(width: 18),
                        Expanded(
                          child: Material(
                            elevation: 3,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              height: MediaQuery.of(context).size.width < 500
                                  ? 45
                                  : 50,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: const Color(0xFF8A95A8))),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: TextField(
                                      controller: _searchController,
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 12
                                              : 14),
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value;
                                          if (_currentPage != 0)
                                            _currentPage = 0;
                                          _applyFilters();
                                        });
                                      },
                                      cursorColor: blueColor,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Search here...",
                                        hintStyle: TextStyle(
                                            color: const Color(0xFF495160),
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 14
                                                : 18),
                                        contentPadding: (const EdgeInsets.only(
                                            left: 5, bottom: 12, top: 5)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(8),
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: const Row(
                                  children: [
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Trade Type',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF495160),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                items: _tradeTypes
                                    .map((String item) =>
                                        DropdownMenuItem<String>(
                                          value: item,
                                          child: Text(
                                            item,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ))
                                    .toList(),
                                value: _selectedTradeType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedTradeType = value;
                                    if (_currentPage != 0) _currentPage = 0;
                                    _applyFilters();
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height:
                                      MediaQuery.of(context).size.width < 500
                                          ? 45
                                          : 50,
                                  width: MediaQuery.of(context).size.width < 500
                                      ? MediaQuery.of(context).size.width * .37
                                      : MediaQuery.of(context).size.width * .4,
                                  padding: const EdgeInsets.only(
                                      left: 14, right: 14),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF8A95A8),
                                    ),
                                    color: Colors.white,
                                  ),
                                  elevation: 0,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  width: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  offset: const Offset(-20, 0),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility:
                                        MaterialStateProperty.all(true),
                                  ),
                                ),
                                menuItemStyleData: const MenuItemStyleData(
                                  height: 40,
                                  padding: EdgeInsets.only(left: 14, right: 14),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (MediaQuery.of(context).size.width < 500)
                          const SizedBox(width: 2),
                        if (MediaQuery.of(context).size.width > 500)
                          const SizedBox(width: 14),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (MediaQuery.of(context).size.width > 500)
                    const SizedBox(height: 25),
                  if (MediaQuery.of(context).size.width < 500)
                    Padding(
                      padding: EdgeInsets.all(
                          MediaQuery.of(context).size.width < 500 ? 11 : 28),
                      child: _isLoading
                          ? ColabShimmerLoadingWidget()
                          : _filteredBidRequests.isEmpty
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height * .5,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                )
                              : SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 2),
                                      _buildHeaders(),
                                      const SizedBox(height: 10),
                                      Container(
                                        child: Column(
                                          children: _pagedData
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            BidRequest request = entry.value;
                                            bool isExpanded =
                                                expandedIndex == index;

                                            // Find the correct index for expanded bid request by ID
                                            if (expandedBidRequestId != null) {
                                              int? foundIndex;
                                              for (int i = 0;
                                                  i < _pagedData.length;
                                                  i++) {
                                                if (_pagedData[i].id ==
                                                    expandedBidRequestId) {
                                                  foundIndex = i;
                                                  break;
                                                }
                                              }
                                              if (foundIndex != null &&
                                                  foundIndex != expandedIndex) {
                                                expandedIndex = foundIndex;
                                                isExpanded =
                                                    expandedIndex == index;
                                              } else if (foundIndex == null) {
                                                expandedIndex = null;
                                                expandedBidRequestId = null;
                                                isExpanded = false;
                                              }
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (expandedIndex == index) {
                                                    expandedIndex = null;
                                                    expandedBidRequestId = null;
                                                  } else {
                                                    expandedIndex = index;
                                                    expandedBidRequestId =
                                                        request.id;
                                                    // Fetch details when expanding
                                                    if (request.bidRequestId !=
                                                        null) {
                                                      _fetchBidRequestDetails(
                                                          request
                                                              .bidRequestId!);
                                                    }
                                                  }
                                                });
                                              },
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: index % 2 != 0
                                                      ? const Color(0xFFF4F8FF)
                                                      : Colors.white,
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xFFDBE0E5)),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8),
                                                      title: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                if (expandedIndex ==
                                                                    index) {
                                                                  expandedIndex =
                                                                      null;
                                                                  expandedBidRequestId =
                                                                      null;
                                                                } else {
                                                                  expandedIndex =
                                                                      index;
                                                                  expandedBidRequestId =
                                                                      request
                                                                          .id;
                                                                  // Fetch details when expanding
                                                                  if (request
                                                                          .bidRequestId !=
                                                                      null) {
                                                                    _fetchBidRequestDetails(
                                                                        request
                                                                            .bidRequestId!);
                                                                  }
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 5,
                                                                      right: 5),
                                                              padding: !isExpanded
                                                                  ? const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10)
                                                                  : const EdgeInsets
                                                                      .only(
                                                                      top: 10),
                                                              child: FaIcon(
                                                                isExpanded
                                                                    ? FontAwesomeIcons
                                                                        .sortUp
                                                                    : FontAwesomeIcons
                                                                        .sortDown,
                                                                size: 20,
                                                                color:
                                                                    blueColor,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            flex: 3,
                                                            child: Text(
                                                              "BR",
                                                              style: TextStyle(
                                                                  fontSize: 13,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color:
                                                                      blueColor),
                                                            ),
                                                          ),

                                                          Expanded(
                                                            flex: 3,
                                                            child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  if (expandedIndex ==
                                                                      index) {
                                                                    expandedIndex =
                                                                        null;
                                                                    expandedBidRequestId =
                                                                        null;
                                                                  } else {
                                                                    expandedIndex =
                                                                        index;
                                                                    expandedBidRequestId =
                                                                        request
                                                                            .id;
                                                                    // Fetch details when expanding
                                                                    if (request
                                                                            .bidRequestId !=
                                                                        null) {
                                                                      _fetchBidRequestDetails(
                                                                          request
                                                                              .bidRequestId!);
                                                                    }
                                                                  }
                                                                });
                                                              },
                                                              child: Text(
                                                                _getBidRoomTitle(
                                                                    request),
                                                              
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      blueColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                         SizedBox(width: 5),
                                                         
                                                          // Container(
                                                          //   height: 35,
                                                          //   width: 35,
                                                          //   padding: const EdgeInsets.all(5),
                                                          //   decoration: BoxDecoration(
                                                          //     borderRadius: BorderRadius.circular(8),
                                                          //     color: request.status == "Open"
                                                          //         ? Colors.greenAccent.shade100
                                                          //         : Colors.redAccent.withOpacity(0.3),
                                                          //   ),
                                                          //   child: Center(
                                                          //     child: Icon(
                                                          //       request.status == "Open"
                                                          //           ? Icons.check_circle
                                                          //           : Icons.lock_rounded,
                                                          //       color: request.status == "Open"
                                                          //           ? Colors.green
                                                          //           : Colors.red,
                                                          //       size: 18,
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (isExpanded)
                                                      Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          border: Border(
                                                            top: BorderSide(
                                                              color: Color(
                                                                  0xFFDBE0E5),
                                                              width: 1,
                                                            ),
                                                          ),
                                                        ),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    FaIcon(
                                                                      isExpanded
                                                                          ? FontAwesomeIcons
                                                                              .sortUp
                                                                          : FontAwesomeIcons
                                                                              .sortDown,
                                                                      size: 20,
                                                                      color: Colors
                                                                          .transparent,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Table(
                                                                        columnWidths: {
                                                                          0: const FlexColumnWidth(),
                                                                          1: const FlexColumnWidth(),
                                                                        },
                                                                        children: [
                                                                          _buildTableRow(
                                                                            'Category:',
                                                                            request.workCategory ??
                                                                                'N/A',
                                                                            'Created Date:',
                                                                            _formatDate(request.createdAt),
                                                                          ),
                                                                          _buildTableRow(
                                                                            'Due Date:',
                                                                            _formatDate(request.dueDate),
                                                                            'Status:',
                                                                            request.status ??
                                                                                'N/A',
                                                                          ),
                                                                          _buildTableRow(
                                                                            'Submissions:',
                                                                            '${request.submissionCount ?? 0}',
                                                                            'Created By:',
                                                                            request.createdByName ??
                                                                                'N/A',
                                                                          ),
                                                                          _buildTableRow(
                                                                            'Description:',
                                                                            request.description ??
                                                                                'N/A',
                                                                            'Unit:',
                                                                            request.unit?.rentalUnit ??
                                                                                'N/A',
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                // Submissions section
                                                                if (request
                                                                        .bidRequestId !=
                                                                    null)
                                                                  _buildSubmissionsSection(
                                                                      request
                                                                          .bidRequestId!),
                                                                const SizedBox(
                                                                    height: 10),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    const SizedBox(
                                                                        width:
                                                                            12),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        // TODO: Delete bid room
                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                'Delete Bid Room feature coming soon');
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            35,
                                                                        width:
                                                                            35,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                          color: Colors
                                                                              .red
                                                                              .shade50,
                                                                        ),
                                                                        child:
                                                                            const Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            FaIcon(
                                                                              FontAwesomeIcons.trashCan,
                                                                              size: 15,
                                                                              color: Colors.red,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        final result = await Navigator.of(context).push(
                                                                          MaterialPageRoute(
                                                                            builder: (context) => CreateBidRoom(
                                                                              useStaffLayout: widget.useStaffLayout,
                                                                              existingBidRequest: request,
                                                                            ),
                                                                          ),
                                                                        );
                                                                        if (result == true) {
                                                                          setState(() => _fetchBidRequests());
                                                                        }
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            35,
                                                                        width:
                                                                            35,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                          color: Colors
                                                                              .green
                                                                              .shade50,
                                                                        ),
                                                                        child:
                                                                            const Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            FaIcon(
                                                                              FontAwesomeIcons.edit,
                                                                              size: 15,
                                                                              color: Colors.green,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        // TODO: View bid room details
                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                'View Bid Room feature coming soon');
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            35,
                                                                        width:
                                                                            35,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                        ),
                                                                        child:
                                                                            const Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            FaIcon(
                                                                              FontAwesomeIcons.eye,
                                                                              size: 15,
                                                                              color: Colors.black87,
                                                                            ),
                                                                          ],
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
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                  if (MediaQuery.of(context).size.width > 500)
                    Padding(
                      padding: const EdgeInsets.only(left: 11, right: 11),
                      child: _isLoading
                          ? ColabShimmerLoadingWidget()
                          : _filteredBidRequests.isEmpty
                              ? Container(
                                  height:
                                      MediaQuery.of(context).size.height * .5,
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
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
                                )
                              : SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 2),
                                      _buildHeaders(),
                                      const SizedBox(height: 10),
                                      Container(
                                        child: Column(
                                          children: _pagedData
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            BidRequest request = entry.value;
                                            bool isExpanded =
                                                expandedIndex == index;

                                            // Find the correct index for expanded bid request by ID
                                            if (expandedBidRequestId != null) {
                                              int? foundIndex;
                                              for (int i = 0;
                                                  i < _pagedData.length;
                                                  i++) {
                                                if (_pagedData[i].id ==
                                                    expandedBidRequestId) {
                                                  foundIndex = i;
                                                  break;
                                                }
                                              }
                                              if (foundIndex != null &&
                                                  foundIndex != expandedIndex) {
                                                expandedIndex = foundIndex;
                                                isExpanded =
                                                    expandedIndex == index;
                                              } else if (foundIndex == null) {
                                                expandedIndex = null;
                                                expandedBidRequestId = null;
                                                isExpanded = false;
                                              }
                                            }

                                            return GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  if (expandedIndex == index) {
                                                    expandedIndex = null;
                                                    expandedBidRequestId = null;
                                                  } else {
                                                    expandedIndex = index;
                                                    expandedBidRequestId =
                                                        request.id;
                                                    // Fetch details when expanding
                                                    if (request.bidRequestId !=
                                                        null) {
                                                      _fetchBidRequestDetails(
                                                          request
                                                              .bidRequestId!);
                                                    }
                                                  }
                                                });
                                              },
                                              child: Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: index % 2 != 0
                                                      ? const Color(0xFFF4F8FF)
                                                      : Colors.white,
                                                  border: Border.all(
                                                      color: const Color(
                                                          0xFFDBE0E5)),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: Column(
                                                  children: [
                                                    ListTile(
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16),
                                                      title: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          InkWell(
                                                            onTap: () {
                                                              setState(() {
                                                                if (expandedIndex ==
                                                                    index) {
                                                                  expandedIndex =
                                                                      null;
                                                                  expandedBidRequestId =
                                                                      null;
                                                                } else {
                                                                  expandedIndex =
                                                                      index;
                                                                  expandedBidRequestId =
                                                                      request
                                                                          .id;
                                                                  // Fetch details when expanding
                                                                  if (request
                                                                          .bidRequestId !=
                                                                      null) {
                                                                    _fetchBidRequestDetails(
                                                                        request
                                                                            .bidRequestId!);
                                                                  }
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 5,
                                                                      right: 5),
                                                              padding: !isExpanded
                                                                  ? const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10)
                                                                  : const EdgeInsets
                                                                      .only(
                                                                      top: 10),
                                                              child: FaIcon(
                                                                isExpanded
                                                                    ? FontAwesomeIcons
                                                                        .sortUp
                                                                    : FontAwesomeIcons
                                                                        .sortDown,
                                                                size: 20,
                                                                color:
                                                                    blueColor,
                                                              ),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  if (expandedIndex ==
                                                                      index) {
                                                                    expandedIndex =
                                                                        null;
                                                                    expandedBidRequestId =
                                                                        null;
                                                                  } else {
                                                                    expandedIndex =
                                                                        index;
                                                                    expandedBidRequestId =
                                                                        request
                                                                            .id;
                                                                    // Fetch details when expanding
                                                                    if (request
                                                                            .bidRequestId !=
                                                                        null) {
                                                                      _fetchBidRequestDetails(
                                                                          request
                                                                              .bidRequestId!);
                                                                    }
                                                                  }
                                                                });
                                                              },
                                                              child: Text(
                                                                _getBidRoomTitle(
                                                                    request),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  color:
                                                                      blueColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 13,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          // Status icon (padlock or other status)
                                                          Container(
                                                            height: 35,
                                                            width: 35,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(5),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                              color: request
                                                                          .status ==
                                                                      "Open"
                                                                  ? Colors
                                                                      .greenAccent
                                                                      .shade100
                                                                  : Colors
                                                                      .redAccent
                                                                      .withOpacity(
                                                                          0.3),
                                                            ),
                                                            child: Center(
                                                              child: Icon(
                                                                request.status ==
                                                                        "Open"
                                                                    ? Icons
                                                                        .check_circle
                                                                    : Icons
                                                                        .lock_rounded,
                                                                color: request.status ==
                                                                        "Open"
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red,
                                                                size: 18,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    if (isExpanded)
                                                      Container(
                                                        decoration:
                                                            const BoxDecoration(
                                                          border: Border(
                                                            top: BorderSide(
                                                              color: Color(
                                                                  0xFFDBE0E5),
                                                              width: 1,
                                                            ),
                                                          ),
                                                        ),
                                                        child:
                                                            SingleChildScrollView(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(16.0),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    FaIcon(
                                                                      isExpanded
                                                                          ? FontAwesomeIcons
                                                                              .sortUp
                                                                          : FontAwesomeIcons
                                                                              .sortDown,
                                                                      size: 20,
                                                                      color: Colors
                                                                          .transparent,
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Table(
                                                                        columnWidths: {
                                                                          0: const FlexColumnWidth(),
                                                                          1: const FlexColumnWidth(),
                                                                        },
                                                                        children: [
                                                                          _buildTableRow(
                                                                            'Category:',
                                                                            request.workCategory ??
                                                                                'N/A',
                                                                            'Created Date:',
                                                                            _formatDate(request.createdAt),
                                                                          ),
                                                                          _buildTableRow(
                                                                            'Due Date:',
                                                                            _formatDate(request.dueDate),
                                                                            'Status:',
                                                                            request.status ??
                                                                                'N/A',
                                                                          ),
                                                                          _buildTableRow(
                                                                            'Submissions:',
                                                                            '${request.submissionCount ?? 0}',
                                                                            '',
                                                                            '',
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                                // Submissions section
                                                                if (request
                                                                        .bidRequestId !=
                                                                    null)
                                                                  _buildSubmissionsSection(
                                                                      request
                                                                          .bidRequestId!),
                                                                const SizedBox(
                                                                    height: 10),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                  children: [
                                                                    const SizedBox(
                                                                        width:
                                                                            12),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        // TODO: Delete bid room
                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                'Delete Bid Room feature coming soon');
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            35,
                                                                        width:
                                                                            35,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                          color: Colors
                                                                              .red
                                                                              .shade50,
                                                                        ),
                                                                        child:
                                                                            const Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            FaIcon(
                                                                              FontAwesomeIcons.trashCan,
                                                                              size: 15,
                                                                              color: Colors.red,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        final result = await Navigator.of(context).push(
                                                                          MaterialPageRoute(
                                                                            builder: (context) => CreateBidRoom(
                                                                              useStaffLayout: widget.useStaffLayout,
                                                                              existingBidRequest: request,
                                                                            ),
                                                                          ),
                                                                        );
                                                                        if (result == true) {
                                                                          setState(() => _fetchBidRequests());
                                                                        }
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            35,
                                                                        width:
                                                                            35,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                          color: Colors
                                                                              .green
                                                                              .shade50,
                                                                        ),
                                                                        child:
                                                                            const Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            FaIcon(
                                                                              FontAwesomeIcons.edit,
                                                                              size: 15,
                                                                              color: Colors.green,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    const SizedBox(
                                                                        width:
                                                                            5),
                                                                    GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        // TODO: View bid room details
                                                                        Fluttertoast.showToast(
                                                                            msg:
                                                                                'View Bid Room feature coming soon');
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        height:
                                                                            35,
                                                                        width:
                                                                            35,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(8),
                                                                          color: Colors
                                                                              .grey
                                                                              .shade200,
                                                                        ),
                                                                        child:
                                                                            const Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.center,
                                                                          children: [
                                                                            FaIcon(
                                                                              FontAwesomeIcons.eye,
                                                                              size: 15,
                                                                              color: Colors.black87,
                                                                            ),
                                                                          ],
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
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                    ),
                  // Pagination
                  // if (!_isLoading && _filteredBidRequests.isNotEmpty)
                  //   Padding(
                  //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  //     child: Row(
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         DropdownButtonHideUnderline(
                  //           child: DropdownButton2<int>(
                  //             value: _rowsPerPage,
                  //             items: [10, 25, 50, 100].map((value) {
                  //               return DropdownMenuItem<int>(
                  //                 value: value,
                  //                 child: Text('$value'),
                  //               );
                  //             }).toList(),
                  //             onChanged: (value) {
                  //               if (value != null) {
                  //                 _changeRowsPerPage(value);
                  //               }
                  //             },
                  //             buttonStyleData: ButtonStyleData(
                  //               height: 40,
                  //               padding: EdgeInsets.symmetric(horizontal: 16),
                  //             ),
                  //           ),
                  //         ),
                  //         Row(
                  //           children: [
                  //             IconButton(
                  //               icon: Icon(Icons.chevron_left),
                  //               onPressed: _currentPage > 0
                  //                   ? () {
                  //                       setState(() {
                  //                         _currentPage--;
                  //                       });
                  //                     }
                  //                   : null,
                  //             ),
                  //             Text(
                  //               'Page ${_currentPage + 1} of ${(_filteredBidRequests.length / _rowsPerPage).ceil()}',
                  //               style: TextStyle(fontWeight: FontWeight.w500),
                  //             ),
                  //             IconButton(
                  //               icon: Icon(Icons.chevron_right),
                  //               onPressed: (_currentPage + 1) <
                  //                       (_filteredBidRequests.length /
                  //                               _rowsPerPage)
                  //                           .ceil()
                  //                   ? () {
                  //                       setState(() {
                  //                         _currentPage++;
                  //                       });
                  //                     }
                  //                   : null,
                  //             ),
                  //           ],
                  //         ),
                  //       ],
                  //     ),
                  //   ),
                  // const SizedBox(height: 20),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset("assets/images/no_internet.json"),
                  const SizedBox(height: 20),
                  Text(
                    "No Internet Connection",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                        fontSize: 18),
                  )
                ],
              ),
            ),
    );
  }

  TableRow _buildTableRow(String leftLabel, String leftValue, String rightLabel,
      String rightValue) {
    return TableRow(
      children: [
        TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leftLabel.isNotEmpty)
                  Text(
                    leftLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                if (leftLabel.isNotEmpty) const SizedBox(height: 4.0),
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
                if (rightLabel.isNotEmpty)
                  Text(
                    rightLabel,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                if (rightLabel.isNotEmpty) const SizedBox(height: 4.0),
                if (rightValue.isNotEmpty)
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

  Widget _buildSubmissionsSection(String bidRequestId) {
    final detail = _bidRequestDetails[bidRequestId];
    final isLoading = _loadingDetails[bidRequestId] == true;

    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Center(
          child: SpinKitFadingCircle(color: blueColor, size: 25),
        ),
      );
    }

    if (detail == null ||
        detail.submissions == null ||
        detail.submissions!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          'No submissions available',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Bid Room Submissions (${detail.submissions!.length})',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: blueColor,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        ...detail.submissions!.map((submission) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VENDOR NAME',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            submission.vendorName ?? 'N/A',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: blueColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'TOTAL PRICE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency(submission.totalPrice),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SUBMITTED AT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDateTime(submission.submittedAt),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'STATUS',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              submission.status ?? 'N/A',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Show price breakdown
                      Fluttertoast.showToast(
                          msg: 'View Breakdown feature coming soon');
                    },
                    icon: FaIcon(
                      FontAwesomeIcons.eye,
                      size: 14,
                    ),
                    label: Text('View Breakdown'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: blueColor,
                      elevation: 0,
                      side: BorderSide(color: blueColor),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
