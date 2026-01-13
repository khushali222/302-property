import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/screens/Rental/mortgage/mortgage_summery.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:three_zero_two_property/widgets/custom_drawer.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../../provider/dateProvider.dart';
import '../../../../../widgets/file_viewer.dart';
import 'Add_property_Tax.dart';

class Property_tax_Table extends StatefulWidget {
  final String propertyId;
  final bool showAppBar;
  final bool showDrawer;
  final bool showAddButton;

  const Property_tax_Table({
    Key? key,
    required this.propertyId,
    this.showAppBar = false,
    this.showDrawer = false,
    this.showAddButton = true,
  }) : super(key: key);

  @override
  State<Property_tax_Table> createState() => _Property_tax_TableState();
}

class _Property_tax_TableState extends State<Property_tax_Table> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _taxes = [];
  List<Map<String, dynamic>> _filteredtax = [];
  bool _isLoading = false;
  int? expandedIndex;
  String searchValue = "";
  int currentPage = 0;
  int itemsPerPage = 10;
  String selectedStatus = "All";
  final List<String> statusOptions = [
    "All",
    "Active",
    "Paid Off",
    "Defaulted",
    "Refinanced"
  ];

  List<int> itemsPerPageOptions = [10, 25, 50, 100];

  @override
  void initState() {
    super.initState();
    _loadMortgages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMortgages() async {
    print('=== LOADING TAXES ===');
    setState(() {
      _isLoading = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? id = prefs.getString('adminId');
      String? satffid = prefs.getString("staff_id");

      // Use property-specific API endpoint
      print('Loading tax for property ID: ${widget.propertyId}');
      print('API URL: ${Api_url}/api/taxes/${widget.propertyId}');
      final response = await http.get(
        Uri.parse('${Api_url}/api/taxes/${widget.propertyId}'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'CRM $token',
          'id': 'CRM $satffid',
        },
      ).timeout(const Duration(seconds: 30));

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          print('Successfully loaded ${data['data'].length} taxes');
          setState(() {
            _taxes = List<Map<String, dynamic>>.from(data['data']);
            _filteredtax = List.from(_taxes);
          });
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No tax found for this property.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else if (response.statusCode == 401) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Authentication required. Please login again.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        // Load fallback data for development/testing
        _loadFallbackMortgages();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load tax : ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        // Load fallback data for development/testing
        _loadFallbackMortgages();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading tax : ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      // Load fallback data for development/testing
      _loadFallbackMortgages();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _loadFallbackMortgages() {
    // Fallback tax data for development/testing when API is not accessible
    setState(() {
      _taxes = [
        {
          '_id': '85d15d7a-77dc-401b-9d48-cd88d5f1abf3',
          'properties': [widget.propertyId],
          'tax_year': '2024',
          'tax_amount': 2500.00,
          'status': 'Paid',
          'due_date': '2024-12-31T00:00:00.000Z',
          'paid_date': '2024-12-15T00:00:00.000Z',
        },
        {
          '_id': '1bf93e3c-da0c-42ce-b3d2-5f03c41c0bea',
          'properties': [widget.propertyId],
          'tax_year': '2023',
          'tax_amount': 2300.00,
          'status': 'Overdue',
          'due_date': '2023-12-31T00:00:00.000Z',
          'paid_date': null, // This will show as N/A
        },
        {
          '_id': '2cf93e3c-da0c-42ce-b3d2-5f03c41c0bea',
          'properties': [widget.propertyId],
          'tax_year': '2025',
          'tax_amount': 2700.00,
          'status': 'Pending',
          'due_date': '2025-12-31T00:00:00.000Z',
          'paid_date': '', // This will also show as N/A
        },
      ];
      _filteredtax = List.from(_taxes);
    });
  }

  void _openAddMortgageForm() {
    print('=== OPENING ADD TAX FORM ===');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Add_property_Tax(
          propertyId: widget.propertyId,
        ),
      ),
    ).then((_) {
      print('=== RETURNED FROM ADD TAX FORM ===');
      print('Refreshing tax list...');
      // Refresh the mortgage list when returning from the form
      _loadMortgages();
    });
  }

  void _deleteMortgage(String id) {
    _showDeleteAlert(context, id);
  }

  void _showDeleteAlert(BuildContext context, String id) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Are you sure?",
      desc: "Once deleted, you will not be able to recover this tax record!",
      style: AlertStyle(
        backgroundColor: Colors.white,
        //  overlayColor: Colors.black.withOpacity(.8)
      ),
      buttons: [
        DialogButton(
          child: Text(
            "Delete",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () async {
            print('Deleting tax record with ID: $id');

            // Call API to delete the tax record
            await _deleteTaxRecord(id);

            Navigator.pop(context);
          },
          color: blueColor,
        ),
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
      ],
    ).show();
  }

  Future<void> _deleteTaxRecord(String id) async {
    try {
      setState(() {
        _isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminId = prefs.getString('adminId');
      String? satffid = prefs.getString("staff_id");

      print('=== DELETING TAX RECORD ===');
      print('Tax ID: $id');
      print('Admin ID: $adminId');

      final response = await http.delete(
        Uri.parse('${Api_url}/api/taxes/$id'),
        headers: {
          'Content-Type': 'application/json',
          'authorization': 'CRM $token',
          'id': 'CRM $satffid',
        },
      ).timeout(const Duration(seconds: 30));

      print('Delete Response Status: ${response.statusCode}');
      print('Delete Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          // Remove from local lists
          setState(() {
            _taxes.removeWhere((tax) => tax['_id'] == id);
            _filteredtax.removeWhere((tax) => tax['_id'] == id);
          });

          Fluttertoast.showToast(
            msg: "Tax record deleted successfully",
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        } else {
          Fluttertoast.showToast(
            msg: data['message'] ?? 'Failed to delete tax record',
            backgroundColor: Colors.red,
            textColor: Colors.white,
          );
        }
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to delete tax record',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      print('Error deleting tax record: $e');
      Fluttertoast.showToast(
        msg: 'Error deleting tax record: ${e.toString()}',
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _editMortgage(Map<String, dynamic> tax) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Add_property_Tax(
          taxId: tax['_id'],
          taxData: tax,
          propertyId: widget.propertyId,
        ),
      ),
    ).then((_) {
      // Refresh the mortgage list when returning from the form
      _loadMortgages();
    });
  }

  void _viewMortgage(Map<String, dynamic> mortgage) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MortgageSummary(mortgageData: mortgage)),
    );
  }

  void _viewReceipt(Map<String, dynamic> tax) {
    final receipt = tax['receipt'];
    print('=== VIEW RECEIPT DEBUG ===');
    print('Tax data: $tax');
    print('Receipt field: $receipt');
    print('Receipt type: ${receipt.runtimeType}');

    if (receipt == null || receipt.toString().trim().isEmpty) {
      print('No receipt available');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No receipt available for this tax record'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print('Calling FileViewer.showReceiptDialog with: ${receipt.toString()}');
    // Show receipt in dialog
    FileViewer.showReceiptDialog(
      context,
      receipt.toString(),
    );
  }

  String _formatCurrency(dynamic amount) {
    if (amount == null) return '\$0';
    final numValue = amount is String ? double.tryParse(amount) ?? 0 : amount;
    return '\$${numValue.toStringAsFixed(2)}';
  }

  Widget _buildHeaders() {
    return Container(
      decoration: BoxDecoration(
          color: const Color(0xFFF4F8FF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFDBE0E5))),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width:
                    20, // Space for icon (5 left + 5 right + 20 icon + 5 padding)
              ),
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    "Year",
                    style: TextStyle(
                        color: const Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Container(
                  margin: EdgeInsets.only(left: 50, right: 5),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    "Status",
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        color: const Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(
      String leftLabel, String leftValue, String rightLabel, String rightValue,
      {VoidCallback? onRightTap, bool isRightClickable = false}) {
    return TableRow(
      children: [
        TableCell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                leftLabel,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
              ),
              const SizedBox(height: 2.0),
              Text(
                leftValue,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        TableCell(
          child: Padding(
            padding: const EdgeInsets.only(
                left: 8.0, top: 4.0, bottom: 4.0, right: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rightLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)),
                ),
                const SizedBox(height: 2.0),
                isRightClickable && onRightTap != null
                    ? GestureDetector(
                        onTap: onRightTap,
                        child: Text(
                          rightValue,
                          style: TextStyle(
                            color: rightValue == 'Tap to view'
                                ? blueColor
                                : Colors.grey,
                            decoration: rightValue == 'Tap to view'
                                ? TextDecoration.underline
                                : null,
                            fontWeight: rightValue == 'Tap to view'
                                ? FontWeight.w500
                                : FontWeight.normal,
                          ),
                        ),
                      )
                    : Text(
                        rightValue,
                        style: const TextStyle(color: Colors.grey),
                      ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getDisplayValue(String? value) {
    return (value == null || value.trim().isEmpty) ? '' : value;
  }

  String _formatDateSafely(String? dateValue) {
    if (dateValue == null || dateValue.trim().isEmpty || dateValue == 'null') {
      return 'N/A';
    }

    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    try {
      String formattedDate = dateProvider.formatCurrentDate(dateValue);

      // If the formatted date is the same as the original (meaning parsing failed),
      // try to parse it as ISO 8601 format manually
      if (formattedDate == dateValue && dateValue.contains('T')) {
        try {
          // Extract just the date part from ISO 8601 format (before 'T')
          String dateOnly = dateValue.split('T')[0];
          DateTime parsedDate = DateTime.parse(dateOnly);
          return DateFormat(dateProvider.dateFormat).format(parsedDate);
        } catch (e) {
          return 'N/A';
        }
      }

      return formattedDate;
    } catch (e) {
      return 'N/A';
    }
  }

  Widget _buildContent() {
    final totalPages = (_filteredtax.length / itemsPerPage).ceil();
    final currentPageData = _filteredtax
        .skip(currentPage * itemsPerPage)
        .take(itemsPerPage)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          // Header Section with Title and Add Button
          if (widget.showAddButton)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                children: [
                  Text(
                    "Tax Information",
                    style: TextStyle(
                        color: blueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: _openAddMortgageForm,
                    child: Container(
                      height: (MediaQuery.of(context).size.width < 500)
                          ? 50
                          : MediaQuery.of(context).size.width * 0.063,
                      width: (MediaQuery.of(context).size.width < 500)
                          ? MediaQuery.of(context).size.width * 0.23
                          : MediaQuery.of(context).size.width * 0.2,
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
                            fontSize: MediaQuery.of(context).size.width < 500
                                ? 16
                                : 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),

          // Content Section
          _isLoading
              ? SizedBox(
                  height: 200,
                  child: Center(
                    child: SpinKitFadingCircle(
                      color: Colors.black,
                      size: 45,
                    ),
                  ),
                )
              : _filteredtax.isEmpty
                  ? SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tax found for this property',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try adjusting your search or add a new tax',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: _buildHeaders(),
                        ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Container(
                            child: Column(
                              children:
                                  currentPageData.asMap().entries.map((entry) {
                                int index = entry.key;
                                bool isExpanded = expandedIndex == index;
                                Map<String, dynamic> tax = entry.value;

                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  decoration: BoxDecoration(
                                    color: index % 2 != 0
                                        ? const Color(0xFFF4F8FF)
                                        : Colors.white,
                                    border: Border.all(
                                        color: const Color(0xFFDBE0E5)),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      ListTile(
                                        contentPadding: EdgeInsets.zero,
                                        title: Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (expandedIndex ==
                                                        index) {
                                                      expandedIndex = null;
                                                    } else {
                                                      expandedIndex = index;
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 5, right: 5),
                                                  padding: !isExpanded
                                                      ? const EdgeInsets.only(
                                                          bottom: 10)
                                                      : const EdgeInsets.only(
                                                          top: 10),
                                                  child: FaIcon(
                                                    isExpanded
                                                        ? FontAwesomeIcons
                                                            .sortUp
                                                        : FontAwesomeIcons
                                                            .sortDown,
                                                    size: 20,
                                                    color:
                                                        const Color(0xFF1E3A8A),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 3,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 8.0),
                                                  child: InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        if (expandedIndex ==
                                                            index) {
                                                          expandedIndex = null;
                                                        } else {
                                                          expandedIndex = index;
                                                        }
                                                      });
                                                    },
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                '${tax['tax_year'] ?? 'N/A'}',
                                                            style: TextStyle(
                                                              color: blueColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      left: 50, right: 5),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 6),
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(
                                                            tax['status'])
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: _getStatusColor(
                                                          tax['status']),
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      (tax['status'] ??
                                                              'unknown')
                                                          .toString()
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: _getStatusColor(
                                                            tax['status']),
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.02),
                                            ],
                                          ),
                                        ),
                                      ),
                                      // ListTile(
                                      //   contentPadding: EdgeInsets.zero,
                                      //   title: Padding(
                                      //     padding: const EdgeInsets.all(2.0),
                                      //     child: Row(
                                      //       mainAxisAlignment:
                                      //           MainAxisAlignment.start,
                                      //       crossAxisAlignment:
                                      //           CrossAxisAlignment.center,
                                      //       children: <Widget>[
                                      //         InkWell(
                                      //           onTap: () {
                                      //             setState(() {
                                      //               if (expandedIndex == index) {
                                      //                 expandedIndex = null;
                                      //               } else {
                                      //                 expandedIndex = index;
                                      //               }
                                      //             });
                                      //           },
                                      //           child: Container(
                                      //             margin: const EdgeInsets.only(
                                      //                 left: 5, right: 5),
                                      //             padding: !isExpanded
                                      //                 ? const EdgeInsets.only(
                                      //                     bottom: 10)
                                      //                 : const EdgeInsets.only(
                                      //                     top: 10),
                                      //             child: FaIcon(
                                      //               isExpanded
                                      //                   ? FontAwesomeIcons.sortUp
                                      //                   : FontAwesomeIcons
                                      //                       .sortDown,
                                      //               size: 20,
                                      //               color:
                                      //                   const Color(0xFF1E3A8A),
                                      //             ),
                                      //           ),
                                      //         ),
                                      //         Flexible(
                                      //           flex: 3,
                                      //           child: Padding(
                                      //             padding: const EdgeInsets.only(
                                      //                 left: 8.0),
                                      //             child: InkWell(
                                      //               onTap: () {
                                      //                 setState(() {
                                      //                   if (expandedIndex ==
                                      //                       index) {
                                      //                     expandedIndex = null;
                                      //                   } else {
                                      //                     expandedIndex = index;
                                      //                   }
                                      //                 });
                                      //               },
                                      //               child: Text.rich(
                                      //                 TextSpan(
                                      //                   children: [
                                      //                     TextSpan(
                                      //                       text:
                                      //                           '${mortgage['bank_name'] ?? 'N/A'}',
                                      //                       style: TextStyle(
                                      //                         color: blueColor,
                                      //                         fontWeight:
                                      //                             FontWeight.bold,
                                      //                         fontSize: 13,
                                      //                       ),
                                      //                     ),
                                      //                   ],
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //           ),
                                      //         ),
                                      //         Flexible(
                                      //           flex: 2,
                                      //           child: Container(
                                      //             margin: EdgeInsets.only(
                                      //                 left: 50, right: 5),
                                      //             padding:
                                      //                 const EdgeInsets.symmetric(
                                      //                     horizontal: 8,
                                      //                     vertical: 6),
                                      //             decoration: BoxDecoration(
                                      //               color: _getStatusColor(
                                      //                       mortgage['status'])
                                      //                   .withOpacity(0.1),
                                      //               borderRadius:
                                      //                   BorderRadius.circular(12),
                                      //               border: Border.all(
                                      //                 color: _getStatusColor(
                                      //                     mortgage['status']),
                                      //                 width: 1,
                                      //               ),
                                      //             ),
                                      //             child: Center(
                                      //               child: Text(
                                      //                 (mortgage['status'] ??
                                      //                         'unknown')
                                      //                     .toString()
                                      //                     .toUpperCase(),
                                      //                 style: TextStyle(
                                      //                   color: _getStatusColor(
                                      //                       mortgage['status']),
                                      //                   fontWeight:
                                      //                       FontWeight.w600,
                                      //                   fontSize: 10,
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //           ),
                                      //         ),
                                      //       ],
                                      //     ),
                                      //   ),
                                      // ),
                                      if (isExpanded)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 2.0),
                                          margin:
                                              const EdgeInsets.only(bottom: 2),
                                          child: SingleChildScrollView(
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
                                                      size: 40,
                                                      color: Colors.transparent,
                                                    ),
                                                    Flexible(
                                                      child: Table(
                                                        columnWidths: const {
                                                          0: FlexColumnWidth(),
                                                          1: FlexColumnWidth(),
                                                        },
                                                        children: [
                                                          _buildTableRow(
                                                            'Amount:',
                                                            _getDisplayValue(
                                                                _formatCurrency(
                                                                    tax['tax_amount'])),
                                                            'Due Date',
                                                            _formatDateSafely(
                                                                tax['due_date']),
                                                          ),
                                                          _buildTableRow(
                                                            'Paid Date',
                                                            _formatDateSafely(
                                                                tax['paid_date']),
                                                            'Receipt',
                                                            tax['receipt'] !=
                                                                        null &&
                                                                    tax['receipt']
                                                                        .toString()
                                                                        .trim()
                                                                        .isNotEmpty
                                                                ? 'Tap to view'
                                                                : 'No receipt',
                                                            onRightTap: tax['receipt'] !=
                                                                        null &&
                                                                    tax['receipt']
                                                                        .toString()
                                                                        .trim()
                                                                        .isNotEmpty
                                                                ? () =>
                                                                    _viewReceipt(
                                                                        tax)
                                                                : null,
                                                            isRightClickable: tax[
                                                                        'receipt'] !=
                                                                    null &&
                                                                tax['receipt']
                                                                    .toString()
                                                                    .trim()
                                                                    .isNotEmpty,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _deleteMortgage(
                                                              tax['_id']),
                                                      child: Container(
                                                        height: 35,
                                                        width: 35,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: Colors
                                                              .red.shade50,
                                                        ),
                                                        child: const Row(
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
                                                              size: 15,
                                                              color: Colors.red,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 5),
                                                    GestureDetector(
                                                      onTap: () =>
                                                          _editMortgage(tax),
                                                      child: Container(
                                                        height: 35,
                                                        width: 35,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                          color: Colors
                                                              .green.shade50,
                                                        ),
                                                        child: const Row(
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
                                                              size: 15,
                                                              color:
                                                                  Colors.green,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 15),
                                                  ],
                                                ),
                                                const SizedBox(height: 15),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Pagination Controls
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Row(
                                children: [
                                  Material(
                                    elevation: 3,
                                    child: Container(
                                      height: 40,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12.0),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
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
                                          onChanged: _filteredtax.length >
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
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: FaIcon(
                                      FontAwesomeIcons.circleChevronLeft,
                                      color: currentPage == 0
                                          ? Colors.grey
                                          : const Color(0xFF1E3A8A),
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
                                          ? const Color(0xFF1E3A8A)
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
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showAppBar) {
      return Scaffold(
        appBar: widget_302.App_Bar(context: context),
        backgroundColor: Colors.white,
        drawer: widget.showDrawer
            ? CustomDrawer(
                currentpage: "Properties",
                dropdown: true,
              )
            : null,
        body: _buildContent(),
      );
    } else {
      return _buildContent();
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toLowerCase().trim()) {
      case 'paid':
        return Colors.green;
      case 'cancelled':
        return Colors.deepPurple.shade400;
      case 'overdue':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        print(
            'Unknown status: "$status"'); // Debug print to see what status values you're getting
        return Colors.grey;
    }
  }
}
