import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/bid_request.dart';
import 'package:three_zero_two_property/VendorModule/repository/vendor_bid_repo.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/VendorModule/widgets/appbar.dart'
    as vendor_appbar;
import 'package:three_zero_two_property/widgets/titleBar.dart';
// import 'package:three_zero_two_property/widgets/custom_drawer.dart'; // Depending on if we use the same drawer
import 'package:three_zero_two_property/widgets/CustomTableShimmer.dart';

class VendorBidRoomTable extends StatefulWidget {
  const VendorBidRoomTable({super.key});

  @override
  State<VendorBidRoomTable> createState() => _VendorBidRoomTableState();
}

class _VendorBidRoomTableState extends State<VendorBidRoomTable> {
  final VendorBidRepository _repository = VendorBidRepository();
  List<BidRequest> _bidRequests = [];
  List<BidRequest> _filteredBidRequests = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedStatus;
  List<String> _statuses = ['All'];
  int _currentPage = 0;
  int _rowsPerPage = 10;
  final TextEditingController _searchController = TextEditingController();
  ConnectivityResult? _connectivityResult;
  bool sorting1 = false;
  bool ascending1 = false;
  int? expandedIndex;
  String? expandedBidRequestId;

  // We can add detail fetching if needed, similar to the admin side.
  // Map<String, BidRequestDetail?> _bidRequestDetails = {};
  // Map<String, bool> _loadingDetails = {};

  @override
  void initState() {
    super.initState();
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? vendorId = prefs.getString('vendor_id');

      if (vendorId == null) {
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(msg: 'Vendor ID not found');
        return;
      }

      final response = await _repository.fetchVendorBidRequests(
        vendorId: vendorId,
        limit: 10000,
        page: 1,
      );

      if (mounted) {
        setState(() {
          _bidRequests = response.data ?? [];
          _extractStatuses();
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

  void _extractStatuses() {
    Set<String> types = {'All'};
    for (var request in _bidRequests) {
      if (request.status != null && request.status!.isNotEmpty) {
        types.add(request.status!);
      }
    }
    _statuses = types.toList()..sort();
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

      // Status filter
      bool matchesStatus = true;
      if (_selectedStatus != null && _selectedStatus != 'All') {
        matchesStatus = request.status == _selectedStatus;
      }

      return matchesSearch && matchesStatus;
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

  String _getBidRoomTitle(BidRequest request) {
    // Sorting by description or address as per requirement.
    // Screenshot shows "Bid Room" column has "test" (description).
    return request.description ?? '';
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

  Widget _buildHeaders() {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDBE0E5))),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            SizedBox(
              width: 30, // Fixed width for #
              child: Text(
                "#",
                style: TextStyle(
                  color: blueColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(
              flex: 4, // Increased flex for Description
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                        child: Text("Bid Room",
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14))),
                    const SizedBox(width: 3),
                    ascending1
                        ? Padding(
                            padding: EdgeInsets.only(top: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.caretUp,
                              size: 16,
                              color: blueColor,
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.only(bottom: 7, left: 2),
                            child: FaIcon(
                              FontAwesomeIcons.caretDown,
                              size: 16,
                              color: blueColor,
                            ),
                          )
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3, // Increased flex for Status
              child: Text(
                "Status",
                style: TextStyle(
                    color: blueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
            SizedBox(
              width: 50,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  "Action",
                  style: TextStyle(
                      color: blueColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
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
      appBar: vendor_appbar.widget_302.App_Bar(
        context: context,
        onDrawerIconPressed: () {},
      ),
      backgroundColor: Colors.white,
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Title Bar
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal:
                          MediaQuery.of(context).size.width > 500 ? 13 : 16.0,
                    ),
                    child: titleBar(
                      width: double.infinity,
                      title: 'Bid Room',
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Search and Filter Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFDBE0E5),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF495160),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _searchQuery = value;
                                  if (_currentPage != 0) _currentPage = 0;
                                  _applyFilters();
                                });
                              },
                              cursorColor: blueColor,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search here...",
                                hintStyle: const TextStyle(
                                  color: Color(0xFF8A95A8),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: Color(0xFF8A95A8),
                                  size: 20,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 0,
                                  vertical: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFDBE0E5),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                hint: const Padding(
                                  padding: EdgeInsets.only(left: 16),
                                  child: Text(
                                    'Select Status',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF8A95A8),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                items: _statuses
                                    .map((String item) =>
                                        DropdownMenuItem<String>(
                                          value: item,
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 0),
                                            child: Text(
                                              item,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF495160),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ))
                                    .toList(),
                                value: _selectedStatus,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedStatus = value;
                                    if (_currentPage != 0) _currentPage = 0;
                                    _applyFilters();
                                  });
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  padding: const EdgeInsets.only(
                                    left: 0,
                                    right: 0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.transparent,
                                  ),
                                  elevation: 0,
                                ),
                                iconStyleData: IconStyleData(
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Color(0xFF8A95A8),
                                    size: 24,
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 200,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  _isLoading
                      ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: ColabShimmerLoadingWidget(),
                      )
                      : _filteredBidRequests.isEmpty
                          ? Container(
                              height: 300,
                              child: Center(
                                child: Text(
                                  "No Data Available",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: blueColor,
                                      fontSize: 16),
                                ),
                              ),
                            )
                          : Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                children: [
                                  _buildHeaders(),
                                  const SizedBox(height: 10),
                                  Column(
                                    children:
                                        _pagedData.asMap().entries.map((entry) {
                                      int index = entry.key;
                                      BidRequest request = entry.value;
                                      bool isExpanded = expandedIndex == index;

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
                                        child: AnimatedContainer(
                                          duration: Duration(milliseconds: 300),
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: const Color(0xFFDBE0E5)),
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
                                                  children: <Widget>[
                                                    InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          if (expandedIndex ==
                                                              index) {
                                                            expandedIndex =
                                                                null;
                                                          } else {
                                                            expandedIndex =
                                                                index;
                                                          }
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            right: 8),
                                                        padding: !isExpanded
                                                            ? EdgeInsets.only(
                                                                bottom: 10)
                                                            : EdgeInsets.only(
                                                                top: 10),
                                                        child: FaIcon(
                                                          isExpanded
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
                                                      width:
                                                          30, // Fixed width match header
                                                      child: Text(
                                                        "BR",
                                                        style: TextStyle(
                                                            fontSize: 13,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        request.description ??
                                                            "N/A",
                                                        style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                        request.status ?? "N/A",
                                                        style: TextStyle(
                                                            color: Colors
                                                                .green, // Color based on status?
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 50,
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerRight,
                                                        child: Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: const Color(
                                                                0xFF0F1B31),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 8),
                                                          child: Icon(
                                                              FontAwesomeIcons
                                                                  .chevronRight,
                                                              color:
                                                                  Colors.white,
                                                              size: 12),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (isExpanded)
                                                Container(
                                                  padding: EdgeInsets.all(16),
                                                  decoration: BoxDecoration(
                                                    border: Border(
                                                        top: BorderSide(
                                                            color: Color(
                                                                0xFFDBE0E5))),
                                                    color: Colors.white,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text("Details",
                                                          style: TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 16)),
                                                      SizedBox(height: 10),
                                                      _buildDetailRow(
                                                          "Description",
                                                          request.description ??
                                                              "N/A"),
                                                      _buildDetailRow(
                                                          "Category",
                                                          request.workCategory ??
                                                              "N/A"),
                                                      _buildDetailRow(
                                                          "Due Date",
                                                          _formatDate(
                                                              request.dueDate)),
                                                      _buildDetailRow(
                                                          "Full Address",
                                                          request.rental
                                                                  ?.rentalAddress ??
                                                              "N/A"),
                                                      _buildDetailRow(
                                                          "Unit",
                                                          request.unit
                                                                  ?.rentalUnit ??
                                                              "N/A"),
                                                      _buildDetailRow(
                                                          "Created On",
                                                          _formatDateTime(
                                                              request
                                                                  .createdAt)),
                                                    ],
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                ],
              ),
            )
          : Center(child: Text("No Internet Connection")),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 120,
              child: Text(label,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey[700]))),
          Expanded(child: Text(value, style: TextStyle(color: Colors.black))),
        ],
      ),
    );
  }
}
