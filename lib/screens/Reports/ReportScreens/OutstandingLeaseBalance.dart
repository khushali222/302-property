import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/OutstandingLeaseBalanceModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/OutstandingLeaseBalanceService.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import 'package:intl/intl.dart';
import '../../../widgets/custom_drawer.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as syncXlsx;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:three_zero_two_property/repository/GetAdminAddressPdf.dart';
import 'package:three_zero_two_property/Model/profile.dart';
import 'package:flutter/services.dart' show rootBundle;

class OutstandingLeaseBalance extends StatefulWidget {
  @override
  State<OutstandingLeaseBalance> createState() =>
      _OutstandingLeaseBalanceState();
}

class _OutstandingLeaseBalanceState extends State<OutstandingLeaseBalance> {
  late Future<OutstandingLeaseBalanceModel> _futureOutstandingLeaseBalance;
  OutstandingLeaseBalanceModel? outstandingLeaseBalanceModel;
  bool isLoading = true;
  String? errorMessage;
  int? expandedRowIndex;
  ConnectivityResult? _connectivityResult;

  // Pagination and filtering
  int _currentPage = 1;
  int _limit = 10;
  String _statusFilter = 'all';
  String? _rentalOwnerFilter;
  String _sortBy = 'property_address';
  String _sortOrder = 'asc';
  String _searchValue = "";

  // Rental owners list
  List<Map<String, dynamic>> _rentalOwners = [];
  List<String> selectedRentalOwnerIds = [];

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
    _futureOutstandingLeaseBalance = fetchOutstandingLeaseBalanceData();
    _fetchRentalOwners();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  Future<OutstandingLeaseBalanceModel>
      fetchOutstandingLeaseBalanceData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("adminId");

      if (adminId == null) {
        setState(() {
          isLoading = false;
          errorMessage = 'Admin ID not found. Please login again.';
        });
        return OutstandingLeaseBalanceModel(
          success: false,
          message: 'Admin ID not found. Please login again.',
        );
      }

      OutstandingLeaseBalanceModel data =
          await OutstandingLeaseBalanceService().fetchOutstandingLeaseBalance(
        adminId: adminId,
        statusFilter: _statusFilter,
        rentalOwnerFilter: _rentalOwnerFilter,
        page: _currentPage,
        limit: _limit,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      setState(() {
        outstandingLeaseBalanceModel = data;
        isLoading = false;
        errorMessage = data.success == false ? data.message : null;
      });
      return data;
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Failed to load outstanding lease balance data. Please try again later.';
      });
      return OutstandingLeaseBalanceModel(
        success: false,
        message:
            'Failed to load outstanding lease balance data. Please try again later.',
      );
    }
  }

  void _refreshData() {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    _futureOutstandingLeaseBalance = fetchOutstandingLeaseBalanceData();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
      isLoading = true;
    });
    _futureOutstandingLeaseBalance = fetchOutstandingLeaseBalanceData();
  }

  void _onSort(String column) {
    setState(() {
      if (_sortBy == column) {
        _sortOrder = _sortOrder == 'asc' ? 'desc' : 'asc';
      } else {
        _sortBy = column;
        _sortOrder = 'asc';
      }
      isLoading = true;
    });
    _futureOutstandingLeaseBalance = fetchOutstandingLeaseBalanceData();
  }

  void _onSearch(String value) {
    setState(() {
      _searchValue = value;
      _currentPage = 1; // Reset to first page when searching
      isLoading = true;
    });
    _futureOutstandingLeaseBalance = fetchOutstandingLeaseBalanceData();
  }

  List<OutstandingLeaseBalanceData> _getFilteredData() {
    if (outstandingLeaseBalanceModel?.data == null) return [];

    if (_searchValue.isEmpty) {
      return outstandingLeaseBalanceModel!.data!;
    }

    return outstandingLeaseBalanceModel!.data!.where((item) {
      return item.tenantNames
                  ?.toLowerCase()
                  .contains(_searchValue.toLowerCase()) ==
              true ||
          item.propertyAddress
                  ?.toLowerCase()
                  .contains(_searchValue.toLowerCase()) ==
              true ||
          item.leaseId?.toLowerCase().contains(_searchValue.toLowerCase()) ==
              true;
    }).toList();
  }

  Future<void> _fetchRentalOwners() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("adminId");
      String? token = prefs.getString('token');
      final response = await http.get(
        Uri.parse('$Api_url/api/rentals/rental-owners/$id'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _rentalOwners = (jsonDecode(response.body) as List)
              .map((e) => e as Map<String, dynamic>)
              .toList();

          // Sort rental owners alphabetically by name
          _rentalOwners.sort((a, b) {
            String nameA = a['rentalOwner_name']?.toString() ?? '';
            String nameB = b['rentalOwner_name']?.toString() ?? '';
            return nameA.toLowerCase().compareTo(nameB.toLowerCase());
          });

          // Insert "All" option at the beginning
          _rentalOwners.insert(0, {
            "rentalowner_id": "all",
            "rentalOwner_name": "All",
          });

          // Select all rental owners by default (excluding "All" option)
          if (selectedRentalOwnerIds.isEmpty) {
            selectedRentalOwnerIds = _rentalOwners
                .where((o) => o['rentalowner_id']?.toString() != 'all')
                .map((o) => o['rentalowner_id']?.toString() ?? '')
                .where((id) => id.isNotEmpty)
                .toList();

            // Set the filter to all owners (but don't fetch data yet - wait for Run button)
            if (selectedRentalOwnerIds.isNotEmpty) {
              _rentalOwnerFilter = selectedRentalOwnerIds.join(',');
            }
          }
        });
      }
    } catch (e) {
      print('Error fetching rental owners: $e');
    }
  }

  Widget _buildMultiSelectRentalOwner() {
    // Filter out "All" option for the dropdown
    List<Map<String, dynamic>> rentalOwnersList = _rentalOwners
        .where((o) => o['rentalowner_id']?.toString() != 'all')
        .toList();

    // Check if all owners are selected
    bool allSelected = rentalOwnersList.isNotEmpty &&
        rentalOwnersList.every((owner) => selectedRentalOwnerIds
            .contains(owner['rentalowner_id']?.toString()));

    return DropdownButtonHideUnderline(
      child: Material(
        elevation: 3,
        borderRadius: BorderRadius.circular(8),
        child: DropdownButton2<String>(
          isExpanded: true,
          hint: Row(
            children: [
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  selectedRentalOwnerIds.isEmpty
                      ? "Select Rental Owners"
                      : allSelected
                          ? "All"
                          : rentalOwnersList
                              .where((owner) => selectedRentalOwnerIds.contains(
                                  owner['rentalowner_id']?.toString()))
                              .map((owner) =>
                                  owner['rentalOwner_name']?.toString() ?? '')
                              .join(', '),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          items: [
            // "All" option at the top
            DropdownMenuItem<String>(
              value: 'all',
              child: StatefulBuilder(
                builder: (context, setState) {
                  return CheckboxListTile(
                    value: allSelected,
                    title: Text(
                      'All',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black87,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (bool? checked) {
                      setState(() {
                        // Visual update
                      });
                      // Update the outer state (without fetching data)
                      this.setState(() {
                        if (checked == true) {
                          // Select all rental owners
                          selectedRentalOwnerIds = rentalOwnersList
                              .map((owner) =>
                                  owner['rentalowner_id']?.toString() ?? '')
                              .where((id) => id.isNotEmpty)
                              .toList();
                        } else {
                          // Deselect all
                          selectedRentalOwnerIds = [];
                        }
                        // Convert to comma-separated string for API (but don't fetch yet)
                        if (selectedRentalOwnerIds.isEmpty) {
                          _rentalOwnerFilter = null;
                        } else {
                          _rentalOwnerFilter = selectedRentalOwnerIds.join(',');
                        }
                        // Don't fetch data here - wait for Run button
                      });
                    },
                  );
                },
              ),
            ),
            // Individual rental owners
            ...rentalOwnersList.map((owner) {
              return DropdownMenuItem<String>(
                value: owner['rentalowner_id']?.toString(),
                child: StatefulBuilder(
                  builder: (context, setState) {
                    bool isSelected = selectedRentalOwnerIds
                        .contains(owner['rentalowner_id']?.toString());
                    return CheckboxListTile(
                      value: isSelected,
                      title: Text(
                        owner['rentalOwner_name']!,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black87,
                        ),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (bool? checked) {
                        setState(() {
                          if (checked == true) {
                            selectedRentalOwnerIds
                                .add(owner['rentalowner_id']?.toString() ?? '');
                          } else {
                            selectedRentalOwnerIds
                                .remove(owner['rentalowner_id']?.toString());
                          }
                        });
                        // Update the outer state (without fetching data)
                        this.setState(() {
                          // Convert to comma-separated string for API (but don't fetch yet)
                          if (selectedRentalOwnerIds.isEmpty) {
                            _rentalOwnerFilter = null;
                          } else {
                            _rentalOwnerFilter =
                                selectedRentalOwnerIds.join(',');
                          }
                          // Don't fetch data here - wait for Run button
                        });
                      },
                    );
                  },
                ),
              );
            }),
          ],
          value:
              null, // Since we're using multi-select, we don't set a single value
          onChanged: (_) {}, // Keep the existing functionality
          buttonStyleData: ButtonStyleData(
            height: 50,
            width: double.infinity,
            padding: const EdgeInsets.only(left: 14, right: 14),
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
            maxHeight: 250,
            width: MediaQuery.of(context).size.width * 0.8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
            ),
            offset: const Offset(-20, 0),
            scrollbarTheme: ScrollbarThemeData(
              radius: const Radius.circular(40),
              thickness: MaterialStateProperty.all(6),
              thumbVisibility: MaterialStateProperty.all(true),
            ),
          ),
          menuItemStyleData: const MenuItemStyleData(
            height: 50,
            padding: EdgeInsets.only(left: 14, right: 14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Reports",
        dropdown: false,
      ),
      appBar: widget_302.App_Bar(context: context),
      body: _connectivityResult == ConnectivityResult.none
          ? _buildNoInternetWidget()
          : SingleChildScrollView(
              child: Column(
                children: [
                  titleBar(
                    title: 'Outstanding Lease Balance Report',
                    width: MediaQuery.of(context).size.width * .98,
                  ),
                  // Filters Section - Always visible
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: _buildFiltersSection(),
                  ),
                  _buildReportContent(),
                ],
              ),
            ),
    );
  }

  Widget _buildNoInternetWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/no_internet.json',
            width: 200,
            height: 200,
          ),
          Text(
            'No Internet Connection',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Please check your internet connection and try again',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              checkInternet();
              _refreshData();
            },
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    return FutureBuilder<OutstandingLeaseBalanceModel>(
      future: _futureOutstandingLeaseBalance,
      builder: (context, snapshot) {
        if (isLoading) {
          return _buildLoadingWidget();
        }

        if (errorMessage != null) {
          return _buildErrorWidget();
        }

        if (outstandingLeaseBalanceModel?.data == null ||
            outstandingLeaseBalanceModel!.data!.isEmpty) {
          return _buildNoDataWidget();
        }

        return _buildDataTable();
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitFadingCircle(
            color: blueColor,
            size: 50.0,
          ),
          SizedBox(height: 20),
          Text(
            'Loading Outstanding Lease Balance Data...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          SizedBox(height: 16),
          Text(
            'Error Loading Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            errorMessage ?? 'An unknown error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _refreshData,
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Lottie.asset(
          //   'assets/Nodata.png',
          //   width: 200,
          //   height: 200,
          // ),
          Text(
            'No Outstanding Lease Balance Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 10),
          Text(
            'There are no outstanding lease balances to display',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status Filter
          Text(
            'Status Filter',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _statusFilter,
                isExpanded: true,
                padding: EdgeInsets.symmetric(horizontal: 16),
                items: [
                  DropdownMenuItem(
                    value: 'all',
                    child: Text('All Leases'),
                  ),
                  DropdownMenuItem(
                    value: 'active',
                    child: Text('Active'),
                  ),
                  // dropdown item for Future and past
                  DropdownMenuItem(
                    value: 'future',
                    child: Text('Future'),
                  ),
                  DropdownMenuItem(
                    value: 'past',
                    child: Text('Past'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _statusFilter = value ?? 'all';
                  });
                },
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ),
          SizedBox(height: 10),

          // Rental Owner Filter
          Text(
            'Rental Owner',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 10),
          _buildMultiSelectRentalOwner(),

          SizedBox(height: 20),

          // Run and Export Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentPage = 1;
                      isLoading = true;
                    });
                    _futureOutstandingLeaseBalance =
                        fetchOutstandingLeaseBalanceData();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Run',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blueColor,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {},
                  child: PopupMenuButton<String>(
                    onSelected: (value) async {
                      final filteredData = _getFilteredData();
                      if (filteredData.isEmpty) {
                        Fluttertoast.showToast(
                          msg: 'No data to export',
                          toastLength: Toast.LENGTH_SHORT,
                        );
                        return;
                      }
                      if (value == 'PDF') {
                        await _generatePdf(filteredData);
                      } else if (value == 'XLSX') {
                        await _generateExcel(filteredData);
                      } else if (value == 'CSV') {
                        await _generateCsv(filteredData);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'PDF',
                        child: Text('PDF'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'XLSX',
                        child: Text('XLSX'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'CSV',
                        child: Text('CSV'),
                      ),
                    ],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Export',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 5),
                        Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    final filteredData = _getFilteredData();

    return Column(
      children: [
        SizedBox(height: 20),

        // Summary Cards
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: _buildSummaryCards(),
        ),

        // Data Table
        Column(
          children: [
            // Table Header
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      'Lease',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: blueColor,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '0-30 Days',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: blueColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),

            // Data Rows
            ...filteredData.map((item) => _buildLeaseCard(item)).toList(),
          ],
        ),
        SizedBox(height: 20),
        // Pagination
        _buildPagination(),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildReportHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Outstanding Lease Balance Report',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          // Row(
          //   children: [
          //     // Filter button
          //     IconButton(
          //       onPressed: () {
          //         // TODO: Implement filter functionality
          //       },
          //       icon: Icon(
          //         Icons.more_vert,
          //         color: Colors.grey[600],
          //       ),
          //       tooltip: 'Report Filters',
          //     ),
          //     // Download button
          //     IconButton(
          //       onPressed: () {
          //         // TODO: Implement download functionality
          //       },
          //       icon: Icon(
          //         Icons.download,
          //         color: Colors.grey[600],
          //       ),
          //       tooltip: 'Download Report',
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText:
                    'Search by tenant name, property address, or lease ID',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: _onSearch,
            ),
          ),
          SizedBox(width: 16),
          DropdownButton<String>(
            value: _statusFilter,
            items: [
              DropdownMenuItem(value: 'all', child: Text('All Status')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
            ],
            onChanged: (value) {
              setState(() {
                _statusFilter = value ?? 'all';
                _currentPage = 1;
                isLoading = true;
              });
              _futureOutstandingLeaseBalance =
                  fetchOutstandingLeaseBalanceData();
            },
          ),
          SizedBox(width: 16),
          IconButton(
            onPressed: _refreshData,
            icon: Icon(Icons.refresh),
            tooltip: 'Refresh Data',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    if (outstandingLeaseBalanceModel?.totals == null) return SizedBox.shrink();

    final totals = outstandingLeaseBalanceModel!.totals!;

    return Container(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              //padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Outstanding Balance',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '\$${NumberFormat('#,##0.00').format(totals.outstandingBalance ?? 0)}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaseCard(OutstandingLeaseBalanceData item) {
    final isExpanded =
        expandedRowIndex == outstandingLeaseBalanceModel!.data!.indexOf(item);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Main row
          InkWell(
            onTap: () {
              setState(() {
                expandedRowIndex = isExpanded
                    ? null
                    : outstandingLeaseBalanceModel!.data!.indexOf(item);
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Lease info
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.propertyAddress ?? ''} ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          item.tenantNames ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 0-30 Days amount
                  Expanded(
                    child: Text(
                      '\$${NumberFormat('#,##0.00').format(item.balance030 ?? 0)}',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF3A4A57)),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded details
          if (isExpanded)
            Container(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Column(
                children: [
                  _buildDetailRow('31-60 Days', item.balance3160),
                  _buildDetailRow('61-90 Days', item.balance6190),
                  _buildDetailRow('90+ Days', item.balance90Plus),
                  SizedBox(height: 8),
                  Container(
                    height: 1,
                    color: Colors.grey[300],
                  ),
                  SizedBox(height: 8),
                  _buildDetailRow('Balance', item.outstandingBalance,
                      isTotal: true),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, double? amount, {bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: isTotal ? Colors.grey[800] : Colors.grey[600],
            ),
          ),
          Text(
            '\$${NumberFormat('#,##0.00').format(amount ?? 0)}',
            style: TextStyle(
              fontSize: isTotal ? 15 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              color: Color(0xFF3A4A57),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    if (outstandingLeaseBalanceModel?.pagination == null)
      return SizedBox.shrink();

    final pagination = outstandingLeaseBalanceModel!.pagination!;
    final totalPages = pagination.totalPages ?? 1;
    final currentPage = pagination.currentPage ?? 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Material(
          elevation: 2,
          color: Colors.white,
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _limit,
                items: [10, 25, 50, 100].map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _limit = newValue;
                      _currentPage = 1; // Reset to first page
                      isLoading = true;
                    });
                    _futureOutstandingLeaseBalance =
                        fetchOutstandingLeaseBalanceData();
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
            // size: 30,
            color: currentPage == 1 ? Colors.grey : blueColor,
          ),
          onPressed: currentPage == 1
              ? null
              : () {
                  _onPageChanged(currentPage - 1);
                },
        ),
        Text(
          'Page $currentPage of $totalPages',
          //   style: const TextStyle(fontSize: 18),
        ),
        IconButton(
          icon: FaIcon(
            // size: 30,
            FontAwesomeIcons.circleChevronRight,
            color: currentPage >= totalPages ? Colors.grey : blueColor,
          ),
          onPressed: currentPage >= totalPages
              ? null
              : () {
                  _onPageChanged(currentPage + 1);
                },
        ),
      ],
    );
  }

  // Export Methods
  Future<void> _generatePdf(List<OutstandingLeaseBalanceData> data) async {
    try {
      GetAddressAdminPdfService service = GetAddressAdminPdfService();
      profile? profileData;

      try {
        profileData = await service.fetchAdminAddress();
      } catch (e) {
        print("Error fetching profile data: $e");
        Fluttertoast.showToast(
          msg: 'Error fetching profile data',
          toastLength: Toast.LENGTH_SHORT,
        );
        return;
      }

      // Load logo
      final image = pw.MemoryImage(
        (await rootBundle.load('assets/images/applogo.png'))
            .buffer
            .asUint8List(),
      );

      // Format date and time
      final DateTime now = DateTime.now();
      final String formattedDateTime =
          DateFormat('dd/MMM/yyyy HH:mm:ss').format(now);

      final pdf = pw.Document();

      // Calculate grand totals
      double grandTotal030 = 0.0;
      double grandTotal3160 = 0.0;
      double grandTotal6190 = 0.0;
      double grandTotal90Plus = 0.0;
      double grandTotalBalance = 0.0;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          header: (pw.Context context) {
            return pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Logo in top-left
                pw.Image(image, width: 40, height: 40),
                // Title and Date in center
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'Outstanding Lease Balance Report',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      'Date: $formattedDateTime',
                      style: pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                // Company name and page number in top-right
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
                      '${context.pageNumber}',
                      style: pw.TextStyle(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
          build: (pw.Context context) {
            // Build table data with main entries and sub-items
            final List<List<dynamic>> tableData = [];

            for (var item in data) {
              // Main lease entry - bold, with all columns
              tableData.add([
                pw.Text(
                  '${item.propertyAddress ?? 'N/A'} | ${item.tenantNames ?? 'N/A'}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                '\$${NumberFormat('#,##0.00').format(item.balance030 ?? 0)}',
                '\$${NumberFormat('#,##0.00').format(item.balance3160 ?? 0)}',
                '\$${NumberFormat('#,##0.00').format(item.balance6190 ?? 0)}',
                '\$${NumberFormat('#,##0.00').format(item.balance90Plus ?? 0)}',
                '\$${NumberFormat('#,##0.00').format(item.outstandingBalance ?? 0)}',
              ]);

              // Add grand totals from main entry
              grandTotal030 += item.balance030 ?? 0.0;
              grandTotal3160 += item.balance3160 ?? 0.0;
              grandTotal6190 += item.balance6190 ?? 0.0;
              grandTotal90Plus += item.balance90Plus ?? 0.0;
              grandTotalBalance += item.outstandingBalance ?? 0.0;

              // Sub-items (account breakdown) - indented, only Balance column
              if (item.accountBreakdown != null &&
                  item.accountBreakdown!.isNotEmpty) {
                for (var account in item.accountBreakdown!) {
                  tableData.add([
                    pw.Text(
                      '  ${account.accountName ?? 'N/A'}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.normal,
                      ),
                    ),
                    '', // 0-30 days empty for sub-items
                    '', // 31-60 days empty for sub-items
                    '', // 61-90 days empty for sub-items
                    '', // 90+ days empty for sub-items
                    '\$${NumberFormat('#,##0.00').format(account.amount ?? 0)}',
                  ]);
                }
              }
            }

            // Add grand total row
            final grandTotalRow = [
              pw.Text(
                'Grand Total',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              '\$${NumberFormat('#,##0.00').format(grandTotal030)}',
              '\$${NumberFormat('#,##0.00').format(grandTotal3160)}',
              '\$${NumberFormat('#,##0.00').format(grandTotal6190)}',
              '\$${NumberFormat('#,##0.00').format(grandTotal90Plus)}',
              '\$${NumberFormat('#,##0.00').format(grandTotalBalance)}',
            ];

            return [
              // Table header with custom styling
              pw.Table(
                columnWidths: {
                  0: pw.FlexColumnWidth(3), // Lease column
                  1: pw.FlexColumnWidth(1.2), // 0-30 days
                  2: pw.FlexColumnWidth(1.2), // 31-60 days
                  3: pw.FlexColumnWidth(1.2), // 61-90 days
                  4: pw.FlexColumnWidth(1.2), // 90+ days
                  5: pw.FlexColumnWidth(1.5), // Balance
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex("#5A86D5"),
                    ),
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Lease',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '0-30 days',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '31-60 days',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '61-90 days',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          '90+ days',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Balance',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Data rows
                  ...tableData.map((row) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: row[0],
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            row[1].toString(),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            row[2].toString(),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            row[3].toString(),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            row[4].toString(),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(6),
                          child: pw.Text(
                            row[5].toString(),
                            textAlign: pw.TextAlign.right,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  // Grand Total row
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          'Grand Total',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          grandTotalRow[1].toString(),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          grandTotalRow[2].toString(),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          grandTotalRow[3].toString(),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          grandTotalRow[4].toString(),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: pw.EdgeInsets.all(6),
                        child: pw.Text(
                          grandTotalRow[5].toString(),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ];
          },
        ),
      );

      await Printing.layoutPdf(
        format: PdfPageFormat.a4.landscape,
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print('Error generating PDF: $e');
      Fluttertoast.showToast(
        msg: 'Error generating PDF',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _generateExcel(List<OutstandingLeaseBalanceData> data) async {
    try {
      final syncXlsx.Workbook workbook = syncXlsx.Workbook();
      final syncXlsx.Worksheet sheet = workbook.worksheets[0];

      // Headers
      sheet.getRangeByIndex(1, 1).setText('Lease');
      sheet.getRangeByIndex(1, 2).setText('0-30 Days');
      sheet.getRangeByIndex(1, 3).setText('31-60 Days');
      sheet.getRangeByIndex(1, 4).setText('61-90 Days');
      sheet.getRangeByIndex(1, 5).setText('90+ Days');
      sheet.getRangeByIndex(1, 6).setText('Balance');

      // Style headers
      final syncXlsx.Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.backColor = '#5A86D5';
      headerStyle.fontColor = '#FFFFFF';
      headerStyle.bold = true;
      sheet.getRangeByIndex(1, 1, 1, 6).cellStyle = headerStyle;

      int rowIndex = 2;
      double grandTotal = 0.0;

      for (var item in data) {
        sheet.getRangeByIndex(rowIndex, 1).setText(
            '${item.propertyAddress ?? 'N/A'}\n${item.tenantNames ?? 'N/A'}');
        sheet.getRangeByIndex(rowIndex, 2).setNumber(item.balance030 ?? 0);
        sheet.getRangeByIndex(rowIndex, 3).setNumber(item.balance3160 ?? 0);
        sheet.getRangeByIndex(rowIndex, 4).setNumber(item.balance6190 ?? 0);
        sheet.getRangeByIndex(rowIndex, 5).setNumber(item.balance90Plus ?? 0);
        sheet
            .getRangeByIndex(rowIndex, 6)
            .setNumber(item.outstandingBalance ?? 0);
        grandTotal += item.outstandingBalance ?? 0.0;
        rowIndex++;
      }

      // Grand Total
      sheet.getRangeByIndex(rowIndex, 1).setText('Grand Total');
      sheet.getRangeByIndex(rowIndex, 1).cellStyle.bold = true;
      sheet.getRangeByIndex(rowIndex, 6).setNumber(grandTotal);
      sheet.getRangeByIndex(rowIndex, 6).cellStyle.bold = true;

      // Auto-fit columns
      sheet.autoFitColumn(1);
      sheet.autoFitColumn(2);
      sheet.autoFitColumn(3);
      sheet.autoFitColumn(4);
      sheet.autoFitColumn(5);
      sheet.autoFitColumn(6);

      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
      final String fileName = 'OutstandingLeaseBalance_$formattedDate.xlsx';

      final Directory directory = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : Directory('/storage/emulated/0/Download');

      final path = '${directory.path}/$fileName';

      if (!await directory.exists() && !Platform.isIOS) {
        await directory.create(recursive: true);
      }

      final File file = File(path);
      await file.writeAsBytes(bytes, flush: true);
      Share.shareXFiles([XFile(path)]);
      Fluttertoast.showToast(
        msg: 'Excel file saved to $path',
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      print('Error generating Excel: $e');
      Fluttertoast.showToast(
        msg: 'Error generating Excel',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<void> _generateCsv(List<OutstandingLeaseBalanceData> data) async {
    try {
      final List<String> headers = [
        'Property Address',
        'Tenant Names',
        '0-30 Days',
        '31-60 Days',
        '61-90 Days',
        '90+ Days',
        'Outstanding Balance',
      ];

      final StringBuffer csvBuffer = StringBuffer();
      csvBuffer.writeln(headers.join(','));

      double grandTotal = 0.0;

      for (var item in data) {
        final String sanitizedAddress =
            (item.propertyAddress ?? 'N/A').replaceAll(',', ' ');
        final String sanitizedTenants =
            (item.tenantNames ?? 'N/A').replaceAll(',', ' ');

        csvBuffer.writeln([
          sanitizedAddress,
          sanitizedTenants,
          NumberFormat('#,##0.00').format(item.balance030 ?? 0),
          NumberFormat('#,##0.00').format(item.balance3160 ?? 0),
          NumberFormat('#,##0.00').format(item.balance6190 ?? 0),
          NumberFormat('#,##0.00').format(item.balance90Plus ?? 0),
          NumberFormat('#,##0.00').format(item.outstandingBalance ?? 0),
        ].join(','));

        grandTotal += item.outstandingBalance ?? 0.0;
      }

      // Add grand total
      csvBuffer.writeln([
        'Grand Total',
        '',
        '',
        '',
        '',
        '',
        NumberFormat('#,##0.00').format(grandTotal),
      ].join(','));

      final DateTime now = DateTime.now();
      final String formattedDate = DateFormat('yyyyMMddHHmmss').format(now);
      final String fileName = 'OutstandingLeaseBalance_$formattedDate.csv';

      final Directory directory = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : Directory('/storage/emulated/0/Download');

      final path = '${directory.path}/$fileName';

      if (!await directory.exists() && !Platform.isIOS) {
        await directory.create(recursive: true);
      }

      final File file = File(path);
      await file.writeAsString(csvBuffer.toString(), flush: true);
      Share.shareXFiles([XFile(path)]);
      Fluttertoast.showToast(
        msg: 'CSV file saved to $path',
        toastLength: Toast.LENGTH_SHORT,
      );
    } catch (e) {
      print('Error generating CSV: $e');
      Fluttertoast.showToast(
        msg: 'Error generating CSV',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }
}
