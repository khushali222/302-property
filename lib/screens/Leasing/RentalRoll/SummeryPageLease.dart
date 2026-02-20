import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/Document_Rental/Add_DocumentRental.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/Recurringpayment.dart';

import 'package:three_zero_two_property/screens/Leasing/RentalRoll/RenewLease.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/Renters%20Insurance/Renters_Insurance_table.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import 'package:three_zero_two_property/Model/tenants.dart';

import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/repository/lease.dart';

import 'package:three_zero_two_property/screens/Leasing/RentalRoll/newModel.dart';
// import 'package:three_zero_two_property/repository/properties_summery.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../../Model/RentalOwnersData.dart';
import '../../../../model/lease.dart';
import '../../../../repository/Rental_ownersData.dart';
import '../../../../repository/properties_summery.dart';
import '../../../../widgets/drawer_tiles.dart';
import '../../../model/LeaseLedgerModel.dart';
import '../../../model/LeaseSummary.dart';
import '../../../model/LeaseChargesModel.dart';
import '../../../provider/dateProvider.dart';
import '../../../widgets/CustomTableShimmer.dart';
import '../../Communications/Send E-mail/send_mail.dart';
import '../../Rental/Properties/moveout/repository.dart';
import '../Scheduled_Payments/Scheduled_Payments_table.dart';
import '../scheduled_charges/ScheduledCharge.dart';
import 'Commnunication/communication.dart';
import 'Document_Rental/Document_rental_table.dart';
import 'Evict_tenant.dart';
import 'Financial.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../widgets/custom_history_table.dart';
import '../../../enums/history_type.dart';

import 'Move_out_lease/Moveout_lease.dart';
import 'Notes/Notes_table.dart';
import 'edit_lease.dart';
import 'make_payment.dart';

class SummeryPageLease extends StatefulWidget {
  bool? isredirectpayment;
  String leaseId;
  String? enddate;
  SummeryPageLease(
      {super.key,
      required this.leaseId,
      this.isredirectpayment = false,
      this.enddate});
  @override
  State<SummeryPageLease> createState() => _SummeryPageLeaseState();
}

class _SummeryPageLeaseState extends State<SummeryPageLease>
    with SingleTickerProviderStateMixin {
  TextEditingController startdateController = TextEditingController();
  TextEditingController enddateController = TextEditingController();
  List formDataRecurringList = [];
  late Future<LeaseSummary> futureLeaseSummary;
  late Future<List<LeaseTenant>> futureLeasetenant;
  late Future<LeaseLedger?> _leaseLedgerFuture;
  late Future<LeaseCharges?> _leaseChargesFuture;
  late Future<List<Map<String, dynamic>>> _lateFeesFuture;
  late Future<List<Map<String, dynamic>>> _leaseHistoryFuture;
  TabController? _tabController;
  ConnectivityResult? _connectivityResult;

  // Pagination variables for Lease History
  int _currentPage = 1;
  int _itemsPerPage = 10;
  List<Map<String, dynamic>> _allLeaseHistory = [];
  int? leaseHistoryExpandedIndex; // Separate variable for lease history table
  //String moveOutDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  String? moveOutDate;

  @override
  void initState() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      setState(() {
        _connectivityResult = result;
      });
    });
    checkInternet();
    // TODO: implement initState
    futureLeaseSummary = LeaseRepository.fetchLeaseSummary(widget.leaseId);
    futureLeasetenant = LeaseRepository.fetchLeaseTenants(widget.leaseId);
    _leaseLedgerFuture =
        LeaseRepository().fetchLeaseLedger(leaseId: widget.leaseId);
    _leaseChargesFuture = LeaseRepository().fetchLeaseCharges(widget.leaseId);
    _lateFeesFuture = fetchLateFees();
    _leaseHistoryFuture = fetchLeaseHistory();
    _tabController = TabController(length: 3, vsync: this);
    // moveOutDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // moveOutDate = widget.enddate!;
    // Initialize moveOutDate with the end date or current date
    //  moveOutDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.enddate!));

    print(' get moved out ${widget.enddate}');
    if (widget.isredirectpayment != null && widget.isredirectpayment!) {
      _tabController!.animateTo(1);
      _selectedIndex = 1;
    }
    fetchLeaseTenants();
    super.initState();
  }

  void checkInternet() async {
    var connectiondata;
    connectiondata = await Connectivity().checkConnectivity();
    setState(() {
      _connectivityResult = connectiondata;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  List<LeaseTenant> leaseTenants = [];

  void fetchLeaseTenants() async {
    try {
      List<LeaseTenant> tenants =
          await LeaseRepository.fetchLeaseTenants(widget.leaseId);
      setState(() {
        leaseTenants = tenants;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching tenants: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to fetch late fees from Financial table data
  Future<List<Map<String, dynamic>>> fetchLateFees() async {
    try {
      // Get lease ledger data (same data used in Financial table)
      final leaseLedger = await _leaseLedgerFuture;

      if (leaseLedger == null || leaseLedger.data == null) {
        return [];
      }

      List<Map<String, dynamic>> lateFees = [];

      // Filter for Charge type entries
      final chargeEntries =
          leaseLedger.data!.where((data) => data.type == "Charge").toList();

      // Filter for late fee income entries from charge entries
      for (var chargeData in chargeEntries) {
        if (chargeData.entry != null && chargeData.entry!.isNotEmpty) {
          for (var entry in chargeData.entry!) {
            // Filter for late fee income entries - check chargeType == "Late Fee Income"
            if (entry.chargeType == 'Late Fee Income') {
              lateFees.add({
                'date': entry.date ?? '',
                'amount': entry.amount ?? 0.0,
                'entry_id': entry.entryId ?? '',
              });
            }
          }
        }
      }

      print('Late Fee Income Count from Financial table: ${lateFees.length}');
      return lateFees;
    } catch (e) {
      print('Error fetching late fees: $e');
      throw Exception('Error fetching late fees: $e');
    }
  }

  // Function to fetch lease history from API
  Future<List<Map<String, dynamic>>> fetchLeaseHistory() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');
      String? adminId = prefs.getString("adminId");

      final url =
          Uri.parse('$Api_url/api/leases/lease_history/${widget.leaseId}');

      final response = await http.get(
        url,
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $adminId",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        List<Map<String, dynamic>> leaseHistory = [];

        // Handle different response structures
        if (jsonData['data'] != null) {
          List<dynamic> data =
              jsonData['data'] is List ? jsonData['data'] : [jsonData['data']];

          for (var entry in data) {
            leaseHistory.add({
              'date': entry['date'] ??
                  entry['createdAt'] ??
                  entry['updatedAt'] ??
                  '',
              'type': entry['type'] ?? entry['category'] ?? 'N/A',
              'action': entry['action'] ??
                  entry['type'] ??
                  entry['category'] ??
                  'N/A',
              'description': entry['description'] ?? entry['notes'] ?? '',
              'amount': (entry['amount'] ?? 0).toDouble(),
              'entry_id': entry['id'] ?? entry['entry_id'] ?? '',
              'performed_by': entry['performed_by'] ??
                  entry['updated_by'] ??
                  entry['updated_by_user'] ??
                  entry['updated_by_name'] ??
                  entry['user_name'] ??
                  entry['created_by'] ??
                  entry['created_by_user'] ??
                  entry['created_by_name'] ??
                  '',
            });
          }
        }

        // Store all data for pagination
        setState(() {
          _allLeaseHistory = leaseHistory;
          _currentPage = 1; // Reset to first page when data is fetched
        });

        return leaseHistory;
      } else {
        throw Exception('Failed to load lease history: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching lease history: $e');
      throw Exception('Error fetching lease history: $e');
    }
  }

  // Get paginated lease history data
  List<Map<String, dynamic>> getPaginatedLeaseHistory() {
    final startIndex = (_currentPage - 1) * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return _allLeaseHistory.length > startIndex
        ? _allLeaseHistory.sublist(
            startIndex,
            endIndex > _allLeaseHistory.length
                ? _allLeaseHistory.length
                : endIndex)
        : [];
  }

  // Get total pages
  int getTotalPages() {
    return (_allLeaseHistory.length / _itemsPerPage).ceil();
  }

  // Format date and time with AM/PM
  String _formatDateTimeWithAMPM(String dateTimeString) {
    if (dateTimeString.isEmpty) return '';

    try {
      // List of possible date formats
      List<String> dateFormats = [
        'yyyy-MM-dd HH:mm:ss',
        'yyyy-MM-dd HH:mm',
        'yyyy-MM-dd h:mm:ss a',
        'yyyy-MM-dd h:mm a',
        'yyyy-MM-dd',
        'yyyy-M-d HH:mm:ss',
        'yyyy-M-d HH:mm',
        'MM/dd/yyyy HH:mm:ss',
        'MM/dd/yyyy HH:mm',
        'MM/dd/yyyy h:mm:ss a',
        'MM/dd/yyyy h:mm a',
        'MM/dd/yyyy',
        'dd-MM-yyyy HH:mm:ss',
        'dd-MM-yyyy HH:mm',
        'dd-MM-yyyy h:mm:ss a',
        'dd-MM-yyyy h:mm a',
        'dd-MM-yyyy',
        'M/d/yyyy, h:mm:ss a',
        'M/d/yyyy, h:mm a',
        'yyyy-MM-ddTHH:mm:ss',
        'yyyy-MM-ddTHH:mm:ssZ',
        'yyyy-MM-ddTHH:mm:ss.SSSZ',
      ];

      DateTime? parsedDate;

      // Try to parse with different formats
      for (String format in dateFormats) {
        try {
          parsedDate = DateFormat(format).parse(dateTimeString);
          break;
        } catch (e) {
          continue;
        }
      }

      if (parsedDate == null) {
        // If parsing fails, return original string
        return dateTimeString;
      }

      // Format with date and time to match web format exactly
      // Web format: YYYY-MM-DD HH:mm:ss (24-hour format, zero-padded, with seconds)
      // Example: "2026-01-06 08:00:03"

      // Handle verbose JavaScript date format FIRST
      // Format: "Mon Dec 08 2025 08:00:03 GMT+0000 (Coordinated Universal Time)"
      if (dateTimeString.contains('GMT') && dateTimeString.contains('(')) {
        try {
          String datePart = dateTimeString.split('(')[0].trim();
          try {
            final verboseFormat = DateFormat("EEE MMM dd yyyy HH:mm:ss 'GMT'Z");
            parsedDate = verboseFormat.parse(datePart);
          } catch (e) {
            // Alternative: Extract components manually
            final altPattern = RegExp(
                r'(\w{3})\s+(\w{3})\s+(\d{1,2})\s+(\d{4})\s+(\d{2}:\d{2}:\d{2})');
            final match = altPattern.firstMatch(dateTimeString);
            if (match != null) {
              final month = match.group(2)!;
              final day = match.group(3)!;
              final year = match.group(4)!;
              final time = match.group(5)!;
              final altFormat = DateFormat("MMM dd yyyy HH:mm:ss");
              parsedDate = altFormat.parse("$month $day $year $time");
            }
          }
        } catch (e) {
          print('Failed to parse verbose date format: $e');
        }
      }

      // If parsedDate is still null, try to parse common formats
      if (parsedDate == null) {
        // If already in YYYY-MM-DD HH:mm:ss format, return as-is (matches web format)
        if (RegExp(r'^\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2}$')
            .hasMatch(dateTimeString)) {
          return dateTimeString;
        }
        // Try to parse with common formats
        try {
          parsedDate = DateTime.parse(dateTimeString);
        } catch (e) {
          // Try DateFormat parsing
          List<String> dateFormats = [
            'yyyy-MM-dd HH:mm:ss',
            'yyyy-MM-dd HH:mm',
            'yyyy-MM-dd',
            'MM/dd/yyyy HH:mm:ss',
            'MM/dd/yyyy HH:mm',
            'MM/dd/yyyy',
          ];
          for (String format in dateFormats) {
            try {
              parsedDate = DateFormat(format).parse(dateTimeString);
              break;
            } catch (e) {
              continue;
            }
          }
        }
      }

      // If still null, return original string
      if (parsedDate == null) {
        return dateTimeString;
      }

      // Format to match web: YYYY-MM-DD HH:mm:ss (always 24-hour format, zero-padded, with seconds)
      String formattedDateTime =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);

      return formattedDateTime;
    } catch (e) {
      print('Error formatting date: $e');
      return dateTimeString;
    }
  }

  final TextEditingController startDateController = TextEditingController();
  DateTime? _startDate;
  final TextEditingController endDateController = TextEditingController();
  List<String> tabTitles = [
    "Summary",
    "Financial",
    "Tenant",
    "Communication",
    "Renter's Insurance",
    "Lease",
    "Notes"
    //"Documents", // You can add more tabs here
    // "New Tab", ...
  ];
  bool isLoading = false;
  bool isMovedOut = false;
  int _selectedIndex = 0;
  String? _selectedLeaseType;
  final List<String> leaseTypeitems = [
    'Fixed',
    'Fixed w/rollover',
    'At-will(month to month)',
  ];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Leases",
        dropdown: true,
      ),
      body: _connectivityResult != ConnectivityResult.none
          ? SingleChildScrollView(
              child: FutureBuilder<LeaseSummary>(
                  future: futureLeaseSummary,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 300),
                        child: SpinKitSpinningLines(
                          color: blueColor,
                          size: 55.0,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return const Center(child: Text('No data found.'));
                    } else {
                      var lease = snapshot.data!;
                      return Column(
                        children: <Widget>[
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              if (MediaQuery.of(context).size.width < 500)
                                const SizedBox(
                                  width: 18,
                                ),
                              if (MediaQuery.of(context).size.width > 500)
                                const SizedBox(
                                  width: 25,
                                ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width > 500
                                    ? 200
                                    : 250,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 1),
                                  child: Text(
                                    '${snapshot.data?.data?.rentalAddress}',
                                    maxLines: 5, // Set maximum number of lines
                                    overflow: TextOverflow
                                        .ellipsis, // Handle overflow with ellipsis
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 13
                                                : 18,
                                        color: blueColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),

                              // Container(
                              //   width: 30,
                              //   height: 30,
                              //   decoration: BoxDecoration(
                              //     color: Color(0xFFe9e9e9),
                              //     borderRadius: BorderRadius.circular(5),
                              //   ),
                              //   child: PopupMenuButton(
                              //     onSelected: (value) async {
                              //       if (value == 'Edit') {
                              //         final result = await Navigator.of(context)
                              //             .push(MaterialPageRoute(
                              //                 builder: (context) => Edit_lease(
                              //                       leaseId: snapshot
                              //                           .data!.data!.leaseId!,
                              //                     )));
                              //       }
                              //       if (value == 'Send Mail') {
                              //         final result = await Navigator.of(context)
                              //             .push(MaterialPageRoute(
                              //                 builder: (context) => send_email(
                              //                       lease: snapshot
                              //                           .data!.data!.tenantId!,
                              //                       leaseID: snapshot
                              //                           .data!.data!.leaseId!,
                              //                     )));
                              //       }
                              //     },
                              //     // horizontal three dot icon
                              //     icon: Icon(Icons.more_horiz),
                              //     itemBuilder: (context) => [
                              //       PopupMenuItem(
                              //         value: 'Edit',
                              //         child: Text('Edit'),
                              //       ),
                              //       PopupMenuItem(
                              //         value: 'Send Mail',
                              //         child: Text('Send Mail'),
                              //       ),
                              //     ],
                              //   ),
                              // )
                              // Text('${snapshot.data!.data!.rentalAddress}',
                              //     style: TextStyle(
                              //         color: blueColor,
                              //         fontWeight: FontWeight.bold,
                              //       fontSize:   MediaQuery.of(context).size.width < 500 ? 15 :18)),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Row(
                              children: [
                                Text(
                                  '${determineStatus(snapshot.data?.data?.startDate, snapshot.data?.data?.endDate)} ${snapshot.data?.data?.renewLeases != null && snapshot.data!.data!.renewLeases!.isNotEmpty ? " - Renewed" : ""}',
                                  style: TextStyle(
                                    color: _getStatusColor(determineStatus(
                                        snapshot.data?.data?.startDate,
                                        snapshot.data?.data?.endDate)),
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        MediaQuery.of(context).size.width < 500
                                            ? 13
                                            : 16,
                                  ),
                                ),
                                const Spacer(),
                                PopupMenuButton<String>(
                                  offset: const Offset(5, 40),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  color: Colors.white,
                                  elevation: 8,
                                  onSelected: (String value) async {
                                    if (value == 'edit') {
                                      // Provider.of<SelectedTenantsProvider>(context,
                                      //     listen: false)
                                      //     .clearTenant();
                                      // Provider.of<SelectedCosignersProvider>(context,
                                      //     listen: false)
                                      //     .clearCosigner();
                                      // Provider.of<SelectedApplicantProvider>(context,
                                      //     listen: false)
                                      //     .clearApplicant();
                                      final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Edit_lease(
                                                    //lease: lease,
                                                    leaseId: snapshot
                                                        .data!.data!.leaseId!,
                                                  )));
                                    } else if (value == 'send_mail') {
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
                                              builder: (context) => send_email(
                                                    lease: snapshot
                                                        .data!.data!.tenantId!,
                                                    leaseID: snapshot
                                                        .data!.data!.leaseId!,
                                                  )));
                                    }
                                  },
                                  itemBuilder: (BuildContext context) => [
                                    PopupMenuItem<String>(
                                      value: 'edit',
                                      height: 40,
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    PopupMenuItem<String>(
                                      value: 'send_mail',
                                      height: 40,
                                      child: const Text(
                                        'Send Mail',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                  child:
                                      // transform the icon to 90 degree to the below container

                                      Container(
                                    height: 30,
                                    width: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.24),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Transform.rotate(
                                      angle: 3.14 / 2,
                                      child: Icon(
                                        Icons.more_vert,
                                        color: blueColor,
                                        size: 23,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            height: 60,
                            margin: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 0),
                            child:

                                // Dropdown Tab Selector
                                Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              // remove the dropdown default border which have underline
                              child: DropdownButton2<String>(
                                isExpanded: true,
                                underline: const SizedBox(),
                                hint: Text(
                                  'Select',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                value: tabTitles[_selectedIndex],
                                selectedItemBuilder: (BuildContext context) {
                                  return tabTitles.map((String item) {
                                    int index = tabTitles.indexOf(item);
                                    IconData iconData;
                                    String iconPath = 'assets/icons/$item.png';
                                    switch (index) {
                                      case 0: // Summary
                                        iconData = Icons.menu;
                                        iconPath = 'assets/icons/summery.png';
                                        break;
                                      case 1: // Financial
                                        iconData = Icons.attach_money;
                                        iconPath = 'assets/icons/financial.png';
                                        break;
                                      case 2: // Tenant
                                        iconData = Icons.people;
                                        iconPath = 'assets/icons/tenants.png';
                                        break;
                                      case 3: // Communication
                                        iconData = Icons.chat_bubble_outline;
                                        iconPath =
                                            'assets/icons/communication.png';
                                        break;
                                      case 4: // Renter's Insurance
                                        iconData = Icons.shield;
                                        iconPath = 'assets/icons/renter.png';
                                        break;
                                      case 5: // Documents
                                        iconData = Icons.description;
                                        iconPath = 'assets/icons/document.png';
                                        break;
                                      case 6: // Notes
                                        iconData = Icons.note;
                                        iconPath = 'assets/icons/note.png';
                                        break;
                                      default:
                                        iconData = Icons.circle;
                                        iconPath = 'assets/icons/summary.png';
                                    }

                                    return Container(
                                      alignment: Alignment.centerLeft,
                                      child: Row(
                                        children: [
                                          Image.asset(iconPath,
                                              width: 20, height: 20),
                                          const SizedBox(width: 12),
                                          Text(
                                            item,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                              color: blueColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList();
                                },
                                items: tabTitles.asMap().entries.map((entry) {
                                  int index = entry.key;
                                  String item = entry.value;
                                  // icon data to image which have store in the assets/icons
                                  String iconPath = 'assets/icons/$item.png';
                                  IconData iconData;
                                  switch (index) {
                                    case 0: // Summary
                                      iconData = Icons.menu;
                                      iconPath = 'assets/icons/summery.png';
                                      break;
                                    case 1: // Financial
                                      iconData = Icons.attach_money;
                                      iconPath = 'assets/icons/financial.png';
                                      break;
                                    case 2: // Tenant
                                      iconData = Icons.people;
                                      iconPath = 'assets/icons/tenants.png';
                                      break;
                                    case 3: // Communication
                                      iconData = Icons.chat_bubble_outline;
                                      iconPath =
                                          'assets/icons/communication.png';
                                      break;
                                    case 4: // Renter's Insurance
                                      iconData = Icons.shield;
                                      iconPath = 'assets/icons/renter.png';
                                      break;
                                    case 5: // Documents
                                      iconData = Icons.description;
                                      iconPath = 'assets/icons/document.png';
                                      break;
                                    case 6: // Notes
                                      iconData = Icons.note;
                                      iconPath = 'assets/icons/note.png';
                                      break;
                                    default:
                                      iconData = Icons.circle;
                                      iconPath = 'assets/icons/summary.png';
                                  }

                                  return DropdownMenuItem<String>(
                                    value: item,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        // color: Colors.green.withOpacity(0.1),
                                        border: index < tabTitles.length - 1
                                            ? Border(
                                                bottom: BorderSide(
                                                  color: blueColor
                                                      .withOpacity(0.2),
                                                  width: 0.5,
                                                ),
                                              )
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          Image.asset(iconPath,
                                              width: 20, height: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              item,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: blueColor,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            size: 25,
                                            color: blueColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? value) {
                                  if (value != null) {
                                    setState(() {
                                      _selectedIndex = tabTitles.indexOf(value);
                                    });
                                  }
                                },
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey.shade500!,
                                      width: 1,
                                    ),
                                    color: Colors.white,
                                  ),
                                ),
                                iconStyleData: IconStyleData(
                                  icon: const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: Colors.grey,
                                  ),
                                  iconSize: 24,
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 380,
                                  //padding: const EdgeInsets.symmetric(horizontal: 5),
                                  //  offset: const Offset(0, -5),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey.shade500!,
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(10, 10),
                                      ),
                                    ],
                                  ),
                                  scrollbarTheme: ScrollbarThemeData(
                                    radius: const Radius.circular(40),
                                    thickness: MaterialStateProperty.all(6),
                                    thumbVisibility:
                                        MaterialStateProperty.all(true),
                                  ),
                                ),
                                menuItemStyleData: MenuItemStyleData(
                                  height: 50,
                                  padding: EdgeInsets.zero,
                                  overlayColor: MaterialStateProperty.all(
                                      Colors.grey[100]),
                                ),
                              ),
                            ),
                          ),
                          _buildTabContent(snapshot.data!, context),
                          /*  Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              SummaryPage(),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: FinancialTable(
                                  rentalUnit: snapshot.data!.data?.rentalUnit,
                                  rentalAddress:
                                      snapshot.data!.data?.rentalAddress,
                                  leaseId: widget.leaseId,
                                  status:
                                      '${determineStatus(snapshot.data!.data?.startDate, snapshot.data!.data?.endDate).toString()}',
                                  tenantId: ' ${snapshot.data!.data?.tenantId}',
                                ),
                              ),
                              Tenant(context),
                            ],
                          ),
                        ),*/
                        ],
                      );
                    }
                  }),
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

  Widget _buildTabContent(LeaseSummary snapshot, BuildContext context) {
    switch (_selectedIndex) {
      case 0:
        return SummaryPage();
      case 1:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: FinancialTable(
            rentalUnit: snapshot.data?.rentalUnit,
            rentalAddress: snapshot.data?.rentalAddress,
            leaseId: widget.leaseId,
            status: determineStatus(
                    snapshot.data?.startDate, snapshot.data?.endDate)
                .toString(),
            tenantId: ' ${snapshot.data?.tenantId}',
          ),
        );
      case 2:
        return Tenant(context);
      case 5:
        return DocumentRentalTable(
          leaseId: widget.leaseId,
        );
      case 6:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: NotesTable(
            leaseid: widget.leaseId,
          ),
        );
      case 4:
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Renters_Insurance_table(
            leaseId: widget.leaseId,
            status: determineStatus(
                    snapshot.data?.startDate, snapshot.data?.endDate)
                .toString(),
            tenantId: ' ${snapshot.data?.tenantId}',
          ),
        );
      case 3:
        return Padding(
            padding: const EdgeInsets.all(8.0),
            child: lease_communication(lease_id: widget.leaseId));
      default:
        return Container(); // Fallback for safety
    }
  }

  int? expandedIndex;
  int?
      recurringChargeExpandedIndex; // Separate variable for recurring charge table
  int?
      renewableHistoryExpandedIndex; // Separate variable for renewable history table
  bool isExpanded = false;

  String determineStatus(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return 'Unknown';

    DateTime start = formatDates(startDate);
    DateTime end = formatDates(endDate);
    DateTime today = DateTime.now();

    if (today.isBefore(start)) {
      return 'Future';
    } else if (today.isAfter(end)) {
      return 'Expired';
    } else {
      return 'Active';
    }
  }

  String determineStatusrenew(
      String? startDate, String? endDate, bool? isRenewed) {
    if (startDate == null ||
        endDate == null ||
        startDate.isEmpty ||
        endDate.isEmpty) {
      return 'Unknown';
    }
    if (isRenewed == null) {
      isRenewed = false;
    }

    DateTime start;
    DateTime end;
    try {
      start = formatDates(startDate);
      end = formatDates(endDate);
    } catch (e) {
      return 'Unknown';
    }
    DateTime today = DateTime.now();

    if (isRenewed) {
      // Renewed lease logic
      if (today.isBefore(start)) {
        return 'Future'; // Lease starts in the future
      } else if (today.isAfter(end)) {
        return 'Expired'; // Lease is expired
      } else {
        return 'Active'; // Lease is currently active
      }
    } else {
      // Non-renewed lease logic
      if (today.isBefore(start)) {
        return 'Future'; // Lease starts in the future
      } else if (today.isAfter(end)) {
        return 'Not Renewed'; // Lease expired and not renewed
      } else {
        return 'Not Renewed'; // Lease is ongoing but not renewed
      }
    }
  }

  DateTime formatDates(String dateTime) {
    List<String> dateFormats = [
      'yyyy-MM-dd',
      'yyyy-M-d',
      'dd-MM-yyyy',
      'd-M-yyyy',
      'M/d/yyyy',
      'MM/dd/yyyy',
      'M/d/yyyy, h:mm:ss a',
      'M/d/yyyy, h:mm a'
    ];

    DateTime? parsedDate;

    for (String format in dateFormats) {
      try {
        parsedDate = DateFormat(format).parse(dateTime);
        break;
      } catch (e) {
        continue;
      }
    }

    // If no format worked, return current date as fallback
    return parsedDate ?? DateTime.now();
  }

  Color _getStatusColor(String status) {
    if (status == 'Active') {
      return Colors.green; // Green color for 'Active'
    } else if (status == 'Expired') {
      return Colors.grey; // Grey color for 'Expired'
    } else {
      return const Color(0xFF8A95A8); // Default color for other statuses
    }
  }

  SummaryPage() {
    final dateProvider = Provider.of<DateProvider>(context);
    // final prefs = await SharedPreferences.getInstance();
    var width = MediaQuery.of(context).size.width;
    return FutureBuilder<LeaseSummary>(
      future: futureLeaseSummary,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SpinKitFadingCircle(
            color: blueColor,
            size: 40.0,
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No data found.'));
        } else {
          final leasesummery = snapshot.data!;

          // prefs.setDouble('rent', leasesummery.data!.amount.toString());
          //prefs.setString('dueDate', leasesummery.data?.date ?? '');

          return Column(
            children: [
              const SizedBox(
                height: 00,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, right: 15),
                child: Material(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade500),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 15, right: 15, top: 15, bottom: 20),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const SizedBox(width: 8),
                              Text(
                                "Tenant Details",
                                style: TextStyle(
                                  color: blueColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const Spacer(),
                              Container(
                                decoration: const BoxDecoration(
                                  color: Color.fromRGBO(235, 245, 255,
                                      1), // Background color of the circle
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(
                                    5), // Padding around the icon
                                child: Icon(
                                  Icons.home_outlined, // Home Icon
                                  color: Colors.grey.shade600, // Icon color
                                  size: 24, // Icon size
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// Unit
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Unit",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width -
                                              100,
                                          child: Text(
                                            '${snapshot.data!.data!.rentalAddress}  -  ${snapshot.data!.data!.rentalUnit ?? "N/A"}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey.shade600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                /// Rental Owner & Tenants
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    /// Rental Owner
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Rental Owner",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${snapshot.data!.data!.rentalOwnerName ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.grey.shade600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),

                                    const SizedBox(width: 30),

                                    /// Tenants
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Tenants",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      snapshot.data!.data!.tenantData!
                                          .map((tenant) =>
                                              '${tenant.tenantFirstName ?? ''} ${tenant.tenantLastName ?? ''}')
                                          .join(', '),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.grey.shade600,
                                      ),
                                      softWrap: true,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (determineStatus(snapshot.data?.data?.startDate,
                      snapshot.data?.data?.endDate) ==
                  'Active')
                Padding(
                  padding: const EdgeInsets.only(
                      left: 0.0, right: 0.0, bottom: 10.0),
                  child: FutureBuilder<List<dynamic>>(
                    future:
                        Future.wait([_leaseLedgerFuture, _leaseChargesFuture]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container();
                        //   SpinKitFadingCircle(
                        //   color: blueColor,
                        //   size: 40.0,
                        // );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.length < 2) {
                        return const Center(child: Text('No data found'));
                      } else {
                        final leaseLedger = snapshot.data![0] as LeaseLedger?;
                        final leaseCharges = snapshot.data![1] as LeaseCharges?;

                        //final data = leaseLedger.data!.toList();
                        return SingleChildScrollView(
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: Material(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade500),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15,
                                          right: 15,
                                          top: 15,
                                          bottom: 20),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.attach_money,
                                                color: blueColor,
                                                size: 24,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                "Balance Overview",
                                                style: TextStyle(
                                                  color: blueColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 0.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                const SizedBox(height: 15),

                                                // Total Balance
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        "Total Balance",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${formatCurrency(leaseLedger?.data != null && leaseLedger!.data!.length > 0 ? leaseLedger.data!.first.balance : 0.0)}',
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 12),

                                                // Monthly Rent
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        "Monthly Rent",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${formatCurrency(leasesummery.data?.amount?.toDouble())}',
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 12),

                                                // Security Deposit
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        "Security Deposit",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${formatCurrency(leaseCharges?.data?.securityDeposits?.totalAmount ?? 0.0)}',
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 12),

                                                // Late Payments
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        "Late Payments (Last 12 Months)",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${leaseCharges?.data?.lateRentPayments?.totalEntries ?? 0}',
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                                const SizedBox(height: 12),

                                                // Divider
                                                Container(
                                                  height: 1,
                                                  color: Colors.grey[300],
                                                  margin: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                ),

                                                const SizedBox(height: 12),

                                                // Due Date
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      const Text(
                                                        "Due Date",
                                                        style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      Text(
                                                        "${dateProvider.formatCurrentDate(leasesummery.data!.date!)}",
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: Colors.orange,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 20),
                                                // Row(
                                                // mainAxisAlignment: MainAxisAlignment.start,
                                                //   crossAxisAlignment: CrossAxisAlignment.start,
                                                //   children: [
                                                //     Expanded(
                                                //       flex:3,
                                                //
                                                //       child: GestureDetector(
                                                //         onTap: () async {
                                                //           final value = await Navigator
                                                //               .push(
                                                //               context,
                                                //               MaterialPageRoute(
                                                //                   builder:
                                                //                       (context) =>
                                                //                       MakePayment(
                                                //                         leaseId: widget.leaseId,
                                                //                         tenantId: ' ${leasesummery.data?.tenantId}',
                                                //                       )));
                                                //           if (value == true) {
                                                //             setState(() {
                                                //               _leaseLedgerFuture =
                                                //                   LeaseRepository()
                                                //                       .fetchLeaseLedger(
                                                //                       leaseId:
                                                //                       widget.leaseId);
                                                //             });
                                                //           }
                                                //         },
                                                //         child: Container(
                                                //           height: 52,
                                                //             padding: EdgeInsets.all(2),
                                                //             decoration: BoxDecoration(
                                                //                 color: blueColor,
                                                //                 border: Border.all(
                                                //                     width: 1,
                                                //                     color: blueColor),
                                                //                 borderRadius:
                                                //                 BorderRadius.circular(
                                                //                     5.0)),
                                                //             child: Center(
                                                //               child: Text(
                                                //                 'Make Payment',
                                                //                 style: TextStyle(
                                                //                     fontSize: MediaQuery.of(
                                                //                         context)
                                                //                         .size
                                                //                         .width <
                                                //                         500
                                                //                         ? 14
                                                //                         : 18,
                                                //                     color: Colors.white,
                                                //                     fontWeight:
                                                //                     FontWeight
                                                //                         .bold),
                                                //               ),
                                                //             )),
                                                //       ),
                                                //     ),
                                                //     SizedBox(width: 10),
                                                //     Expanded(
                                                //       flex:4,
                                                //       child: GestureDetector(
                                                //         onTap: () {
                                                //           setState(() {
                                                //
                                                //             // if (_tabController !=
                                                //             //     null) {
                                                //             //   _tabController!
                                                //             //       .animateTo(1);
                                                //             // }
                                                //             Navigator.of(context).push(
                                                //                 MaterialPageRoute(
                                                //                     builder:
                                                //                         (context) =>
                                                //                         RecurringPayment(
                                                //                           leaseData: leasesummery.data!,
                                                //                         )));
                                                //           });
                                                //         },
                                                //         child: Container(
                                                //           padding: EdgeInsets.symmetric(horizontal: 6),
                                                //             height: MediaQuery.of(context)
                                                //                 .size
                                                //                 .width <
                                                //                 500
                                                //                 ? 55
                                                //                 : 45,
                                                //             decoration: BoxDecoration(
                                                //                 color: Colors.white,
                                                //                 border: Border.all(
                                                //                     width: 1,
                                                //                     color: Colors.grey),
                                                //                 borderRadius:
                                                //                 BorderRadius.circular(
                                                //                     5.0)),
                                                //             child: Row(
                                                //
                                                //               children: [
                                                //                 if (leaseTenants
                                                //                     .any((tenant) =>
                                                //                 tenant
                                                //                     .recurring ==
                                                //                     false))
                                                //                   SizedBox(
                                                //                     width: 12,
                                                //                   ),
                                                //                 Expanded(
                                                //                   child: Text(
                                                //                     'Configure Recurring Payment',
                                                //                     style: TextStyle(
                                                //                         fontSize:
                                                //                         MediaQuery.of(context).size.width <
                                                //                             500
                                                //                             ? 13
                                                //                             : 18,
                                                //                         color:
                                                //                         blueColor,
                                                //                         fontWeight:
                                                //                         FontWeight
                                                //                             .bold),
                                                //                   ),
                                                //                 ),
                                                //                 if (leaseTenants.any(
                                                //                         (tenant) => tenant
                                                //                         .recurring!))
                                                //                   Icon(
                                                //                       CupertinoIcons
                                                //                           .check_mark_circled_solid,
                                                //                       color: Colors
                                                //                           .green),
                                                //               ],
                                                //             )),
                                                //       ),
                                                //     ),
                                                //
                                                //     // Expanded(
                                                //     //   child: Container(
                                                //     //       height: MediaQuery.of(context)
                                                //     //           .size
                                                //     //           .width <
                                                //     //           500
                                                //     //           ? 45
                                                //     //           : 45,
                                                //     //       decoration: BoxDecoration(
                                                //     //           color: Colors.white,
                                                //     //           border: Border.all(
                                                //     //               width: 1,
                                                //     //               color: blueColor
                                                //     //
                                                //     //
                                                //     //           ),
                                                //     //           borderRadius:
                                                //     //           BorderRadius.circular(
                                                //     //               5.0)),
                                                //     //       child: ElevatedButton(
                                                //     //           style: ElevatedButton.styleFrom(
                                                //     //               shape: RoundedRectangleBorder(
                                                //     //                   borderRadius:
                                                //     //                   BorderRadius.circular(5.0)),
                                                //     //               elevation: 0,
                                                //     //               backgroundColor: Colors.white),
                                                //     //           onPressed: () async {
                                                //     //             final value =
                                                //     //             await Navigator.push(
                                                //     //                 context,
                                                //     //                 MaterialPageRoute(
                                                //     //                     builder:
                                                //     //                         (context) =>
                                                //     //                         RecurringPayment(leaseId: widget.leaseId,)
                                                //     //                 ));
                                                //     //             // if (value == true) {
                                                //     //             //   setState(() {
                                                //     //             //     _leaseLedgerFuture =
                                                //     //             //         LeaseRepository()
                                                //     //             //             .fetchLeaseLedger(
                                                //     //             //             widget
                                                //     //             //                 .leaseId);
                                                //     //             //   });
                                                //     //             // }
                                                //     //           },
                                                //     //           child: Text(
                                                //     //             'Configure Recurring Payment',
                                                //     //             style: TextStyle(
                                                //     //                 fontSize: MediaQuery.of(
                                                //     //                     context)
                                                //     //                     .size
                                                //     //                     .width <
                                                //     //                     500
                                                //     //                     ? 14
                                                //     //                     : 18,
                                                //     //                 color: blueColor
                                                //     //
                                                //     //
                                                //     //             ),
                                                //     //           ))),
                                                //     // ),
                                                //   ],
                                                // ),
                                                // SizedBox(height: 10,),
                                                // Row(
                                                //   children: [
                                                //     Row(
                                                //       mainAxisAlignment: MainAxisAlignment.start,
                                                //       children: [
                                                //
                                                //         GestureDetector(
                                                //           onTap: () {
                                                //             setState(() {
                                                //
                                                //               // if (_tabController !=
                                                //               //     null) {
                                                //               //   _tabController!
                                                //               //       .animateTo(1);
                                                //               // }
                                                //               Navigator.of(context).push(
                                                //                   MaterialPageRoute(
                                                //                       builder:
                                                //                           (context) =>
                                                //                           ScheduledChargeTable(leaseID: widget.leaseId,)));
                                                //             });
                                                //           },
                                                //           child: Container(
                                                //               padding: EdgeInsets.symmetric(horizontal: 6),
                                                //               height: MediaQuery.of(context)
                                                //                   .size
                                                //                   .width <
                                                //                   500
                                                //                   ? 55
                                                //                   : 45,
                                                //               decoration: BoxDecoration(
                                                //                   color: Colors.white,
                                                //                   border: Border.all(
                                                //                       width: 1,
                                                //                       color: Colors.grey),
                                                //                   borderRadius:
                                                //                   BorderRadius.circular(
                                                //                       5.0)),
                                                //               child: Row(
                                                //
                                                //                 children: [
                                                //                   if (leaseTenants
                                                //                       .any((tenant) =>
                                                //                   tenant
                                                //                       .recurring ==
                                                //                       false))
                                                //                     SizedBox(
                                                //                       width: 12,
                                                //                     ),
                                                //                   Text(
                                                //                     'Scheduled Charges',
                                                //                     style: TextStyle(
                                                //                         fontSize:
                                                //                         MediaQuery.of(context).size.width <
                                                //                             500
                                                //                             ? 13
                                                //                             : 18,
                                                //                         color:
                                                //                         blueColor,
                                                //                         fontWeight:
                                                //                         FontWeight
                                                //                             .bold),
                                                //                   ),
                                                //
                                                //                 ],
                                                //               )),
                                                //         ),
                                                //         GestureDetector(
                                                //           onTap: () {
                                                //             // Navigator.of(context).push(
                                                //             //     MaterialPageRoute(
                                                //             //         builder: (context) =>
                                                //             //             Scheduled_Payments_table(leaseId: widget.leaseId)
                                                //             //     )
                                                //             // );
                                                //           },
                                                //           child: Container(
                                                //             padding: EdgeInsets.symmetric(horizontal: 6),
                                                //             height: MediaQuery.of(context).size.width < 500 ? 55 : 45,
                                                //             decoration: BoxDecoration(
                                                //                 color: Colors.white,
                                                //                 border: Border.all(
                                                //                     width: 1,
                                                //                     color: Colors.grey
                                                //                 ),
                                                //                 borderRadius: BorderRadius.circular(5.0)
                                                //             ),
                                                //             child: Row(
                                                //               children: [
                                                //                 Text(
                                                //                   'Scheduled Payments',
                                                //                   style: TextStyle(
                                                //                       fontSize: MediaQuery.of(context).size.width < 500 ? 14 : 16,
                                                //                       color: blueColor
                                                //                   ),
                                                //                 ),
                                                //               ],
                                                //             ),
                                                //           ),
                                                //         ),
                                                //
                                                //       ],
                                                //     )
                                                //   ],
                                                // )
                                                // Quick Actions Title
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 15, right: 15),
                                child: Material(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.grey.shade500),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 15,
                                          right: 15,
                                          top: 15,
                                          bottom: 20),
                                      child: Column(
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(width: 10),
                                              Text(
                                                "Quick Actions",
                                                style: TextStyle(
                                                  color: blueColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),

                                          // Make Payment Button
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MakePayment(
                                                      leaseId: widget.leaseId,
                                                      tenantId:
                                                          '${leasesummery.data?.tenantId}',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.grey[300]!),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.add,
                                                        color: Colors.grey[700],
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Make Payment',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 12),

                                          // Configure Recurring Button
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        RecurringPayment(
                                                      leaseData:
                                                          leasesummery.data!,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.grey[300]!),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.refresh,
                                                        color: Colors.grey[700],
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          'Configure Autopay',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors
                                                                .grey[700],
                                                          ),
                                                        ),
                                                      ),
                                                      Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                        size: 18,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 12),

                                          // Scheduled Charges Button
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ScheduledChargeTable(
                                                      leaseID: widget.leaseId,
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.grey[300]!),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.calendar_today,
                                                        color: Colors.grey[700],
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Scheduled Charges',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          const SizedBox(height: 12),

                                          // Scheduled Payments Button
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: GestureDetector(
                                              onTap: () {
                                                // Add your navigation here
                                              },
                                              child: Container(
                                                height: 40,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors.grey[300]!),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.attach_money,
                                                        color: Colors.grey[700],
                                                        size: 20,
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                        'Scheduled Payments',
                                                        style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              Colors.grey[700],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              // Padding(
                              //   padding:
                              //       const EdgeInsets.only(left: 15, right: 15),
                              //   child: Material(
                              //     borderRadius: BorderRadius.circular(10),
                              //     child: Container(
                              //       decoration: BoxDecoration(
                              //         color: Colors.white,
                              //         borderRadius: BorderRadius.circular(10),
                              //         border: Border.all(color: blueColor),
                              //       ),
                              //       child: Padding(
                              //         padding: const EdgeInsets.only(
                              //             left: 25,
                              //             right: 25,
                              //             top: 20,
                              //             bottom: 30),
                              //         child: Column(
                              //           children: [
                              //             Table(
                              //               children: [
                              //                 TableRow(children: [
                              //                   TableCell(
                              //                       child: Padding(
                              //                     padding: const EdgeInsets.all(
                              //                         12.0),
                              //                     child: Text(
                              //                       'Balance',
                              //                       style: TextStyle(
                              //                           color: const Color(
                              //                               0xFF8A95A8),
                              //                           fontWeight:
                              //                               FontWeight.bold,
                              //                           fontSize: 16),
                              //                     ),
                              //                   )),
                              //                   TableCell(
                              //                       child: Padding(
                              //                     padding:
                              //                         const EdgeInsets.only(
                              //                             top: 12),
                              //                     child: Text(
                              //                       '\$ ${leaseLedger.data!.length > 0 ? leaseLedger.data?.first.balance!.toStringAsFixed(2) : 0.0}',
                              //                       style: TextStyle(
                              //                           fontSize: 15,
                              //                           fontWeight:
                              //                               FontWeight.bold,
                              //                           color: blueColor),
                              //                     ),
                              //                   )),
                              //                 ]),
                              //                 TableRow(children: [
                              //                   TableCell(
                              //                       child: Padding(
                              //                     padding: const EdgeInsets.all(
                              //                         12.0),
                              //                     child: Text(
                              //                       'Rent',
                              //                       style: TextStyle(
                              //                           color: const Color(
                              //                               0xFF8A95A8),
                              //                           fontWeight:
                              //                               FontWeight.bold,
                              //                           fontSize: 16),
                              //                     ),
                              //                   )),
                              //                   TableCell(
                              //                       child: Padding(
                              //                     padding:
                              //                         const EdgeInsets.only(
                              //                             top: 12),
                              //                     child: Text(
                              //                       '\$ ${leasesummery.data?.amount}',
                              //                       style: TextStyle(
                              //                           fontSize: 15,
                              //                           fontWeight:
                              //                               FontWeight.bold,
                              //                           color: blueColor),
                              //                     ),
                              //                   )),
                              //                 ]),
                              //                 TableRow(children: [
                              //                   TableCell(
                              //                       child: Padding(
                              //                     padding: const EdgeInsets.all(
                              //                         12.0),
                              //                     child: Text(
                              //                       'Due date',
                              //                       style: TextStyle(
                              //                           color: const Color(
                              //                               0xFF8A95A8),
                              //                           fontWeight:
                              //                               FontWeight.bold,
                              //                           fontSize: 16),
                              //                     ),
                              //                   )),
                              //                   TableCell(
                              //                       child: Padding(
                              //                     padding:
                              //                         const EdgeInsets.only(
                              //                             top: 12),
                              //                     child: Text(
                              //                       '${dateProvider.formatCurrentDate(leasesummery.data!.date!)}',
                              //                       style: TextStyle(
                              //                           fontSize: 15,
                              //                           fontWeight:
                              //                               FontWeight.bold,
                              //                           color: blueColor),
                              //                     ),
                              //                   )),
                              //                 ]),
                              //               ],
                              //             ),
                              //             SizedBox(
                              //               height: 15,
                              //             ),
                              //             Row(
                              //               children: [
                              //                 Container(
                              //                     height: MediaQuery.of(context)
                              //                                 .size
                              //                                 .width <
                              //                             500
                              //                         ? 75
                              //                         : 45,
                              //                     decoration: BoxDecoration(
                              //                         color: Colors.white,
                              //                         border: Border.all(
                              //                             width: 1,
                              //                             color: blueColor),
                              //                         borderRadius:
                              //                             BorderRadius.circular(
                              //                                 5.0)),
                              //                     child: ElevatedButton(
                              //                         style: ElevatedButton.styleFrom(
                              //                             shape: RoundedRectangleBorder(
                              //                                 borderRadius:
                              //                                     BorderRadius
                              //                                         .circular(
                              //                                             5.0)),
                              //                             elevation: 0,
                              //                             backgroundColor:
                              //                                 Colors.white),
                              //                         onPressed: () async {
                              //                           final value = await Navigator
                              //                               .push(
                              //                                   context,
                              //                                   MaterialPageRoute(
                              //                                       builder:
                              //                                           (context) =>
                              //                                               MakePayment(
                              //                                                 leaseId: widget.leaseId,
                              //                                                 tenantId: ' ${leasesummery.data?.tenantId}',
                              //                                               )));
                              //                           if (value == true) {
                              //                             setState(() {
                              //                               _leaseLedgerFuture =
                              //                                   LeaseRepository()
                              //                                       .fetchLeaseLedger(
                              //                                           leaseId:
                              //                                               widget.leaseId);
                              //                             });
                              //                           }
                              //                         },
                              //                         child: Text(
                              //                           'Make Payment',
                              //                           style: TextStyle(
                              //                               fontSize: MediaQuery.of(
                              //                                               context)
                              //                                           .size
                              //                                           .width <
                              //                                       500
                              //                                   ? 15
                              //                                   : 18,
                              //                               color: blueColor,
                              //                               fontWeight:
                              //                                   FontWeight
                              //                                       .bold),
                              //                         ))),
                              //                 SizedBox(width: 15),
                              //                 Expanded(
                              //                   child: Container(
                              //                       height: MediaQuery.of(context)
                              //                                   .size
                              //                                   .width <
                              //                               500
                              //                           ? 75
                              //                           : 45,
                              //                       decoration: BoxDecoration(
                              //                           color: Colors.white,
                              //                           border: Border.all(
                              //                               width: 1,
                              //                               color: blueColor),
                              //                           borderRadius:
                              //                               BorderRadius.circular(
                              //                                   5.0)),
                              //                       child: ElevatedButton(
                              //                           style: ElevatedButton.styleFrom(
                              //                               shape: RoundedRectangleBorder(
                              //                                   borderRadius:
                              //                                       BorderRadius
                              //                                           .circular(
                              //                                               5.0)),
                              //                               elevation: 0,
                              //                               backgroundColor:
                              //                                   Colors.white),
                              //                           onPressed: () {
                              //                             setState(() {
                              //
                              //                               // if (_tabController !=
                              //                               //     null) {
                              //                               //   _tabController!
                              //                               //       .animateTo(1);
                              //                               // }
                              //                               Navigator.of(context).push(
                              //                                   MaterialPageRoute(
                              //                                       builder:
                              //                                           (context) =>
                              //                                               RecurringPayment(
                              //                                                 leaseData: leasesummery.data!,
                              //                                               )));
                              //                             });
                              //                           },
                              //                           child: Row(
                              //                             children: [
                              //                               if (leaseTenants
                              //                                   .any((tenant) =>
                              //                                       tenant
                              //                                           .recurring ==
                              //                                       false))
                              //                                 SizedBox(
                              //                                   width: 12,
                              //                                 ),
                              //                               Expanded(
                              //                                 child: Text(
                              //                                   'Configure Recurring Payment',
                              //                                   style: TextStyle(
                              //                                       fontSize:
                              //                                           MediaQuery.of(context).size.width <
                              //                                                   500
                              //                                               ? 13
                              //                                               : 18,
                              //                                       color:
                              //                                           blueColor,
                              //                                       fontWeight:
                              //                                           FontWeight
                              //                                               .bold),
                              //                                 ),
                              //                               ),
                              //                               if (leaseTenants.any(
                              //                                   (tenant) => tenant
                              //                                       .recurring!))
                              //                                 Icon(
                              //                                     CupertinoIcons
                              //                                         .check_mark_circled_solid,
                              //                                     color: Colors
                              //                                         .green),
                              //                             ],
                              //                           ))),
                              //                 ),
                              //
                              //                 // Expanded(
                              //                 //   child: Container(
                              //                 //       height: MediaQuery.of(context)
                              //                 //           .size
                              //                 //           .width <
                              //                 //           500
                              //                 //           ? 45
                              //                 //           : 45,
                              //                 //       decoration: BoxDecoration(
                              //                 //           color: Colors.white,
                              //                 //           border: Border.all(
                              //                 //               width: 1,
                              //                 //               color: blueColor
                              //                 //
                              //                 //
                              //                 //           ),
                              //                 //           borderRadius:
                              //                 //           BorderRadius.circular(
                              //                 //               5.0)),
                              //                 //       child: ElevatedButton(
                              //                 //           style: ElevatedButton.styleFrom(
                              //                 //               shape: RoundedRectangleBorder(
                              //                 //                   borderRadius:
                              //                 //                   BorderRadius.circular(5.0)),
                              //                 //               elevation: 0,
                              //                 //               backgroundColor: Colors.white),
                              //                 //           onPressed: () async {
                              //                 //             final value =
                              //                 //             await Navigator.push(
                              //                 //                 context,
                              //                 //                 MaterialPageRoute(
                              //                 //                     builder:
                              //                 //                         (context) =>
                              //                 //                         RecurringPayment(leaseId: widget.leaseId,)
                              //                 //                 ));
                              //                 //             // if (value == true) {
                              //                 //             //   setState(() {
                              //                 //             //     _leaseLedgerFuture =
                              //                 //             //         LeaseRepository()
                              //                 //             //             .fetchLeaseLedger(
                              //                 //             //             widget
                              //                 //             //                 .leaseId);
                              //                 //             //   });
                              //                 //             // }
                              //                 //           },
                              //                 //           child: Text(
                              //                 //             'Configure Recurring Payment',
                              //                 //             style: TextStyle(
                              //                 //                 fontSize: MediaQuery.of(
                              //                 //                     context)
                              //                 //                     .size
                              //                 //                     .width <
                              //                 //                     500
                              //                 //                     ? 14
                              //                 //                     : 18,
                              //                 //                 color: blueColor
                              //                 //
                              //                 //
                              //                 //             ),
                              //                 //           ))),
                              //                 // ),
                              //               ],
                              //             ),
                              //           ],
                              //         ),
                              //       ),
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 15, right: 15, top: 8, bottom: 25),
                child: Material(
                  //elevation: 6,
                  //borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      // border: Border.all(
                      //     color:blueColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 2, right: 2, top: 5, bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (MediaQuery.of(context).size.width < 500)
                            Row(
                              children: [
                                const SizedBox(
                                  width: 2,
                                ),
                                Text(
                                  "Lease Details",
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                // Show Expanded only when renew button is visible, otherwise use Spacer to push evict to end
                                if (leasesummery.data!.is_renewing ?? true)
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Evict_tenant(
                                                      leaseId: widget.leaseId,
                                                      lease: leasesummery,
                                                      startdate: leasesummery
                                                          .data!.startDate,
                                                      enddate: leasesummery
                                                          .data!.endDate,
                                                      leasetype: leasesummery
                                                          .data!.leaseType,
                                                      rentamount: leasesummery
                                                          .data!.amount
                                                          .toString(),
                                                    )));
                                      },
                                      child: Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 35
                                              : 45,
                                          decoration: BoxDecoration(
                                              color: blueColor,
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          child: Center(
                                            child: Text(
                                              'Evict Tenants',
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14
                                                          : 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          )),
                                    ),
                                  )
                                else ...[
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Evict_tenant(
                                                    leaseId: widget.leaseId,
                                                    lease: leasesummery,
                                                    startdate: leasesummery
                                                        .data!.startDate,
                                                    enddate: leasesummery
                                                        .data!.endDate,
                                                    leasetype: leasesummery
                                                        .data!.leaseType,
                                                    rentamount: leasesummery
                                                        .data!.amount
                                                        .toString(),
                                                  )));
                                    },
                                    child: Container(
                                        height:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 35
                                                : 45,
                                        width:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 120
                                                : 165,
                                        decoration: BoxDecoration(
                                            color: blueColor,
                                            borderRadius:
                                                BorderRadius.circular(5.0)),
                                        child: Center(
                                          child: Text(
                                            'Evict Tenants',
                                            style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 14
                                                    : 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white),
                                          ),
                                        )),
                                  ),
                                ],
                                if (leasesummery.data!.is_renewing ?? true) ...[
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Renewlease(
                                                      leaseId: widget.leaseId,
                                                      lease: leasesummery,
                                                      startdate: leasesummery
                                                          .data!.startDate,
                                                      enddate: leasesummery
                                                          .data!.endDate,
                                                      leasetype: leasesummery
                                                          .data!.leaseType,
                                                      rentamount: leasesummery
                                                          .data!.amount
                                                          .toString(),
                                                    )));
                                      },
                                      child: Container(
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 35
                                              : 45,
                                          decoration: BoxDecoration(
                                              color: blueColor,
                                              borderRadius:
                                                  BorderRadius.circular(5.0)),
                                          child: Center(
                                            child: Text(
                                              'Renew Lease',
                                              style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                                  .size
                                                                  .width <
                                                              500
                                                          ? 14
                                                          : 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          )),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          if (MediaQuery.of(context).size.width < 500)
                            const SizedBox(
                              height: 10,
                            ),
                          if (MediaQuery.of(context).size.width < 500)
                            Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFF4F8FF),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: const Color(0xFFDBE0E5))),
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 3,
                                          child: InkWell(
                                            onTap: () {},
                                            child: Row(
                                              children: [
                                                width < 400
                                                    ? Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 20.0),
                                                        child: Text(
                                                          "Property",
                                                          style: TextStyle(
                                                              color: blueColor,
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      )
                                                    : Text("     Property",
                                                        style: TextStyle(
                                                            color: blueColor,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                        textAlign:
                                                            TextAlign.center),
                                                // Text("Property", style: TextStyle(color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: InkWell(
                                            onTap: () {},
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 0.0),
                                                  child: Text("Status",
                                                      style: TextStyle(
                                                          color: blueColor,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 14)),
                                                ),
                                                SizedBox(width: 5),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: InkWell(
                                            onTap: () {},
                                            child: Row(
                                              children: [
                                                Text(
                                                  "Type",
                                                  style: TextStyle(
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14),
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(width: 5),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                StatefulBuilder(
                                  builder: (context, setRowState) {
                                    return Container(
                                      // decoration: BoxDecoration(
                                      //     // color: index %2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                                      //     border: Border.all(
                                      //         color: const Color.fromRGBO(
                                      //             152, 162, 179, .5))),
                                      // // decoration: BoxDecoration(
                                      // //   border: Border.all(color: blueColor),
                                      // // ),
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: const Color(0xFFDBE0E5)),
                                        borderRadius: BorderRadius.circular(10),
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
                                                      setRowState(() {
                                                        isExpanded =
                                                            !isExpanded;
                                                      });
                                                    },
                                                    child: Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              left: 5),
                                                      padding: !isExpanded
                                                          ? const EdgeInsets
                                                              .only(bottom: 10)
                                                          : const EdgeInsets
                                                              .only(top: 10),
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
                                                  Expanded(
                                                    flex: 5,
                                                    child: InkWell(
                                                      onTap: () {
                                                        // Handle navigation or other actions if needed
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 5.0),
                                                        child: Text(
                                                          '${snapshot.data!.data!.rentalAddress}',
                                                          style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .06,
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate)}',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .06,
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      '${snapshot.data!.data!.leaseType}',
                                                      style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            .02,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          if (isExpanded)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 20),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        FaIcon(
                                                          isExpanded
                                                              ? FontAwesomeIcons
                                                                  .sortUp
                                                              : FontAwesomeIcons
                                                                  .sortDown,
                                                          size: 50,
                                                          color: Colors
                                                              .transparent,
                                                        ),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: <Widget>[
                                                              Text.rich(
                                                                TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          'Start - End   ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              blueColor),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          '${dateProvider.formatCurrentDate('${snapshot.data!.data!.startDate}')} to ${dateProvider.formatCurrentDate('${snapshot.data!.data!.endDate}')}',
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                height: 4,
                                                              ),
                                                              Text.rich(
                                                                TextSpan(
                                                                  children: [
                                                                    TextSpan(
                                                                      text:
                                                                          'Rent : ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          color:
                                                                              blueColor),
                                                                    ),
                                                                    TextSpan(
                                                                      text:
                                                                          '${formatCurrency(snapshot.data!.data!.amount?.toDouble() ?? 0.0)}',
                                                                      style: const TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              Colors.grey),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          if (MediaQuery.of(context).size.width > 500)
                            Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                ),
                                Text(
                                  "Lease Details",
                                  style: TextStyle(
                                      color: blueColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20),
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (MediaQuery.of(context).size.width > 500)
                            Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Expanded(
                                  child: Container(
                                    child: DataTable(
                                      dataRowHeight: 50,
                                      headingRowHeight: 50,
                                      border: TableBorder.all(
                                        width: 1,
                                        color: blueColor,
                                      ),
                                      columns: [
                                        const DataColumn(
                                          label: Text('Status'),
                                        ),
                                        const DataColumn(
                                          label: Text('Start - End'),
                                        ),
                                        const DataColumn(
                                          label: Text('Property'),
                                        ),
                                        const DataColumn(
                                          label: Text('Type'),
                                        ),
                                        const DataColumn(
                                          label: Text('Rent'),
                                        ),
                                      ],
                                      rows: [
                                        DataRow(cells: <DataCell>[
                                          DataCell(Text(
                                              '${determineStatus(snapshot.data!.data!.startDate, snapshot.data!.data!.endDate)}')),
                                          DataCell(Text(
                                              ' ${snapshot.data!.data!.startDate} to ${snapshot.data!.data!.endDate}')),
                                          DataCell(Text(
                                              '${snapshot.data!.data!.rentalAddress}')),
                                          DataCell(Text(
                                              '${snapshot.data!.data!.leaseType}')),
                                          DataCell(Text(
                                              '${formatCurrency(snapshot.data!.data!.amount?.toDouble() ?? 0.0)}')),
                                        ]),
                                        // Add more rows as needed
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (MediaQuery.of(context).size.width < 500)
                            if (leasesummery.data?.entry != null &&
                                leasesummery.data!.entry!.length > 0)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        "Recuring Charges",
                                        style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    // decoration: BoxDecoration(
                                    //
                                    //   color: blueColor,
                                    //   borderRadius: const BorderRadius.only(
                                    //     topLeft: Radius.circular(13),
                                    //     topRight: Radius.circular(13),
                                    //   ),
                                    //
                                    // ),
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF4F8FF),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFDBE0E5))),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 3,
                                            child: InkWell(
                                              onTap: () {},
                                              child: Row(
                                                children: [
                                                  width < 400
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20.0),
                                                          child: Text(
                                                            "Date",
                                                            style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        )
                                                      : Text("     Date",
                                                          style: TextStyle(
                                                              color: blueColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14),
                                                          textAlign:
                                                              TextAlign.center),
                                                  // Text("Property", style: TextStyle(color: Colors.white)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: InkWell(
                                              onTap: () {},
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 0.0),
                                                    child: Text("Acount",
                                                        style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14)),
                                                  ),
                                                  SizedBox(width: 5),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: InkWell(
                                              onTap: () {},
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Amount",
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(width: 5),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // decoration: BoxDecoration(
                                    //     // color: index %2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                                    //     border: Border.all(
                                    //         color: const Color.fromRGBO(
                                    //             152, 162, 179, .5))),
                                    // decoration: BoxDecoration(
                                    //   border: Border.all(color: blueColor),
                                    // ),
                                    child: Column(
                                      children: snapshot.data!.data!.entry!
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key;
                                        RecurringEntry lease = entry.value;
                                        //return CustomExpansionTile(data: Propertytype, index: index);
                                        return StatefulBuilder(
                                          builder: (context, setRowState) {
                                            bool isExpandedLocal =
                                                recurringChargeExpandedIndex ==
                                                    index;
                                            return Container(
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
                                                children: <Widget>[
                                                  ListTile(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          InkWell(
                                                            onTap: () {
                                                              setRowState(() {
                                                                if (recurringChargeExpandedIndex ==
                                                                    index) {
                                                                  recurringChargeExpandedIndex =
                                                                      null;
                                                                } else {
                                                                  recurringChargeExpandedIndex =
                                                                      index;
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 5),
                                                              padding: !isExpandedLocal
                                                                  ? const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10)
                                                                  : const EdgeInsets
                                                                      .only(
                                                                      top: 10),
                                                              child: FaIcon(
                                                                isExpandedLocal
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
                                                            flex: 4,
                                                            child: InkWell(
                                                              onTap: () {
                                                                setRowState(() {
                                                                  if (recurringChargeExpandedIndex ==
                                                                      index) {
                                                                    recurringChargeExpandedIndex =
                                                                        null;
                                                                  } else {
                                                                    recurringChargeExpandedIndex =
                                                                        index;
                                                                  }
                                                                });
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            5.0),
                                                                child: Text(
                                                                  '${dateProvider.formatCurrentDate(lease.date!)}',
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
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .08,
                                                          ),
                                                          Expanded(
                                                            flex: 4,
                                                            child: Text(
                                                              '${lease.account}',
                                                              style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .03,
                                                          ),
                                                          Expanded(
                                                            flex: 4,
                                                            child: Text(
                                                              '${formatCurrency(lease.amount?.toDouble() ?? 0.0)}',
                                                              style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .02,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (isExpandedLocal)
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                FaIcon(
                                                                  isExpandedLocal
                                                                      ? FontAwesomeIcons
                                                                          .sortUp
                                                                      : FontAwesomeIcons
                                                                          .sortDown,
                                                                  size: 50,
                                                                  color: Colors
                                                                      .transparent,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <Widget>[
                                                                      Text.rich(
                                                                        TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: 'Memo :- ',
                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${lease.memo}',
                                                                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  //SizedBox(height: 13,),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (MediaQuery.of(context).size.width < 500)
                            if (leasesummery.data?.renewLeases != null &&
                                leasesummery.data!.renewLeases!.length > 0)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      const SizedBox(
                                        width: 2,
                                      ),
                                      Text(
                                        "Renewable History",
                                        style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: const Color(0xFFF4F8FF),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: const Color(0xFFDBE0E5))),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      title: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: <Widget>[
                                          Expanded(
                                            flex: 3,
                                            child: InkWell(
                                              onTap: () {},
                                              child: Row(
                                                children: [
                                                  width < 400
                                                      ? Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20.0),
                                                          child: Text(
                                                            "Property",
                                                            style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14),
                                                            textAlign: TextAlign
                                                                .center,
                                                          ),
                                                        )
                                                      : Text("     Property",
                                                          style: TextStyle(
                                                              color: blueColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 14),
                                                          textAlign:
                                                              TextAlign.center),
                                                  // Text("Property", style: TextStyle(color: Colors.white)),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: InkWell(
                                              onTap: () {},
                                              child: Row(
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 0.0),
                                                    child: Text("Status",
                                                        style: TextStyle(
                                                            color: blueColor,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 14)),
                                                  ),
                                                  SizedBox(width: 5),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: InkWell(
                                              onTap: () {},
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Type",
                                                    style: TextStyle(
                                                        color: blueColor,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  SizedBox(width: 5),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    // decoration: BoxDecoration(
                                    //     // color: index %2 != 0 ? Colors.white : blueColor.withOpacity(0.09),
                                    //     border: Border.all(
                                    //         color: const Color.fromRGBO(
                                    //             152, 162, 179, .5))),
                                    // decoration: BoxDecoration(
                                    //   border: Border.all(color: blueColor),
                                    // ),
                                    child: Column(
                                      children: snapshot
                                          .data!.data!.renewLeases!
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key;
                                        RenewLeases lease = entry.value;
                                        //return CustomExpansionTile(data: Propertytype, index: index);
                                        return StatefulBuilder(
                                          builder: (context, setRowState) {
                                            bool isExpandedLocal =
                                                renewableHistoryExpandedIndex ==
                                                    index;
                                            return Container(
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

                                              // decoration: BoxDecoration(
                                              //   border: Border.all(color: blueColor),
                                              // ),
                                              child: Column(
                                                children: <Widget>[
                                                  ListTile(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    title: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        children: <Widget>[
                                                          InkWell(
                                                            onTap: () {
                                                              setRowState(() {
                                                                if (renewableHistoryExpandedIndex ==
                                                                    index) {
                                                                  renewableHistoryExpandedIndex =
                                                                      null;
                                                                } else {
                                                                  renewableHistoryExpandedIndex =
                                                                      index;
                                                                }
                                                              });
                                                            },
                                                            child: Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 5),
                                                              padding: !isExpandedLocal
                                                                  ? const EdgeInsets
                                                                      .only(
                                                                      bottom:
                                                                          10)
                                                                  : const EdgeInsets
                                                                      .only(
                                                                      top: 10),
                                                              child: FaIcon(
                                                                isExpandedLocal
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
                                                            flex: 5,
                                                            child: InkWell(
                                                              onTap: () {
                                                                setRowState(() {
                                                                  if (renewableHistoryExpandedIndex ==
                                                                      index) {
                                                                    renewableHistoryExpandedIndex =
                                                                        null;
                                                                  } else {
                                                                    renewableHistoryExpandedIndex =
                                                                        index;
                                                                  }
                                                                });
                                                              },
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            5.0),
                                                                child: Text(
                                                                  '${snapshot.data!.data!.rentalAddress}',
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
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .06,
                                                          ),
                                                          Expanded(
                                                            flex: 4,
                                                            child: Text(
                                                              '${determineStatusrenew(lease.startDate ?? "", lease.endDate ?? "", lease.isrenewed ?? false)}',
                                                              style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .01,
                                                          ),
                                                          Expanded(
                                                            flex: 4,
                                                            child: Text(
                                                              '${lease.leaseType}',
                                                              style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 12,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .02,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  if (isExpandedLocal)
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              bottom: 20),
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                FaIcon(
                                                                  isExpandedLocal
                                                                      ? FontAwesomeIcons
                                                                          .sortUp
                                                                      : FontAwesomeIcons
                                                                          .sortDown,
                                                                  size: 50,
                                                                  color: Colors
                                                                      .transparent,
                                                                ),
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: <Widget>[
                                                                      Text.rich(
                                                                        TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: 'Start - End   ',
                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${dateProvider.formatCurrentDate('${lease.startDate}')} to ${dateProvider.formatCurrentDate('${lease.endDate}')}',
                                                                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                      const SizedBox(
                                                                        height:
                                                                            4,
                                                                      ),
                                                                      Text.rich(
                                                                        TextSpan(
                                                                          children: [
                                                                            TextSpan(
                                                                              text: 'Amount : ',
                                                                              style: TextStyle(fontWeight: FontWeight.bold, color: blueColor),
                                                                            ),
                                                                            TextSpan(
                                                                              text: '${formatCurrency(lease.amount ?? 0.0)}',
                                                                              style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.grey),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  //SizedBox(height: 13,),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                          SizedBox(
                            height: 10,
                          ),
                          // Late Fees Table
                          FutureBuilder<List<Map<String, dynamic>>>(
                            future: _lateFeesFuture,
                            builder: (context, lateFeeSnapshot) {
                              if (lateFeeSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  height: 50,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              } else if (lateFeeSnapshot.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    'Error loading late fees: ${lateFeeSnapshot.error}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              } else if (!lateFeeSnapshot.hasData ||
                                  lateFeeSnapshot.data!.isEmpty) {
                                return const SizedBox.shrink();
                              } else {
                                final lateFees = lateFeeSnapshot.data!;
                                return RepaintBoundary(
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 2,
                                          ),
                                          Text(
                                            "Late Fees",
                                            style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16),
                                          ),
                                          Spacer(),
                                          Text(
                                            "Late Fee Count : ${lateFees.length}",
                                            style: TextStyle(
                                                color: blueColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                            color: const Color(0xFFF4F8FF),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color:
                                                    const Color(0xFFDBE0E5))),
                                        child: ListTile(
                                          contentPadding: EdgeInsets.zero,
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 3,
                                                child: InkWell(
                                                  onTap: () {},
                                                  child: Row(
                                                    children: [
                                                      width < 400
                                                          ? Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      left:
                                                                          20.0),
                                                              child: Text(
                                                                "Date",
                                                                style: TextStyle(
                                                                    color:
                                                                        blueColor,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        14),
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                              ),
                                                            )
                                                          : Text("     Date",
                                                              style: TextStyle(
                                                                  color:
                                                                      blueColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 14),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: InkWell(
                                                  onTap: () {},
                                                  child: Row(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 0.0),
                                                        child: Text("Amount",
                                                            style: TextStyle(
                                                                color:
                                                                    blueColor,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14)),
                                                      ),
                                                      SizedBox(width: 5),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Column(
                                          children: lateFees
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                            int index = entry.key;
                                            Map<String, dynamic> lateFee =
                                                entry.value;
                                            return Container(
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
                                              child: ListTile(
                                                contentPadding: EdgeInsets.zero,
                                                title: Padding(
                                                  padding:
                                                      const EdgeInsets.all(2.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: <Widget>[
                                                      Expanded(
                                                        flex: 3,
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 20.0),
                                                          child: Text(
                                                            lateFee['date'] !=
                                                                        null &&
                                                                    lateFee['date']
                                                                        .toString()
                                                                        .isNotEmpty
                                                                ? dateProvider
                                                                    .formatCurrentDate(
                                                                        lateFee['date']
                                                                            .toString())
                                                                : '',
                                                            style: TextStyle(
                                                              color: blueColor,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 13,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                          formatCurrency(lateFee[
                                                                  'amount'] ??
                                                              0.0),
                                                          style: TextStyle(
                                                            color:
                                                                Colors.orange,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 13,
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
                                      ),
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // Lease History Table - OLD CODE
                          // CustomHistoryTable commented out - using old implementation
                          Builder(
                            builder: (context) {
                              print(
                                  '🔵 Lease Summary - Rendering CustomHistoryTable');
                              print('🔵 Lease ID: ${widget.leaseId}');
                              return CustomHistoryTable(
                                historyType: HistoryType.lease,
                                entityId: widget.leaseId,
                                title: 'Lease History',
                                blueColor: blueColor,
                                itemsPerPage: 10,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Tenant(context) {
    final dateProvider = Provider.of<DateProvider>(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isTablet = constraints.maxWidth > 600;
        return FutureBuilder<List<LeaseTenant>>(
          future: futureLeasetenant,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SpinKitFadingCircle(
                color: blueColor,
                size: 40.0,
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Center(child: Text('No data found.'));
            } else {
              final leasetenant = snapshot.data!;

              return isTablet
                  ? SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 35,
                          right: 35,
                          top: 30,
                        ),
                        child: Wrap(
                          alignment: WrapAlignment.start,
                          spacing: MediaQuery.of(context).size.width * 0.03,
                          runSpacing: MediaQuery.of(context).size.width * 0.035,
                          children: List.generate(
                            snapshot.data!.length,
                            (index) => Material(
                              elevation: 3,
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 245,
                                width: MediaQuery.of(context).size.width * .44,
                                decoration: BoxDecoration(
                                  color:
                                      Colors.white, // Change as per your need
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: blueColor,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const SizedBox(width: 15),
                                          Container(
                                            height: 35,
                                            width: 35,
                                            decoration: BoxDecoration(
                                              color: blueColor,
                                              border:
                                                  Border.all(color: blueColor),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: const Center(
                                              child: FaIcon(
                                                FontAwesomeIcons.user,
                                                size: 17,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 20),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const SizedBox(width: 2),
                                                  Container(
                                                    width: 130,
                                                    child: Text(
                                                      '${snapshot.data![index].tenantFirstName} ${snapshot.data![index].tenantLastName}',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: blueColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  //const SizedBox(width: 2),
                                                  // Text(
                                                  //   snapshot.data!.data!.rentalAddress!,
                                                  //   style: const TextStyle(
                                                  //     fontSize: 15,
                                                  //     color: Color(0xFF8A95A8),
                                                  //   ),
                                                  // ),
                                                  SizedBox(
                                                    width: 140,
                                                    child: Text(
                                                      '${snapshot.data![index].rentalAddress}',
                                                      maxLines:
                                                          4, // Set maximum number of lines
                                                      overflow: TextOverflow
                                                          .ellipsis, // Handle overflow with ellipsis
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: blueColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          InkWell(
                                            onTap: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  bool isChecked =
                                                      false; // Moved isChecked inside the StatefulBuilder
                                                  return StatefulBuilder(
                                                    builder: (BuildContext
                                                            context,
                                                        StateSetter setState) {
                                                      return Dialog(
                                                        backgroundColor:
                                                            Colors.white,
                                                        surfaceTintColor:
                                                            Colors.white,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0)),
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 16,
                                                                  right: 16,
                                                                  top: 10,
                                                                  bottom: 10),
                                                          child: Container(
                                                              // width: MediaQuery.of(context).size.width - 10,
                                                              width: 900,
                                                              child: buildMoveout(
                                                                  snapshot.data![
                                                                      index])),
                                                        ),
                                                      );
                                                    },
                                                  );
                                                },
                                              );
                                            },
                                            child: Row(
                                              children: [
                                                FaIcon(
                                                  FontAwesomeIcons
                                                      .rightFromBracket,
                                                  size: 17,
                                                  color: blueColor,
                                                ),
                                                const SizedBox(width: 5),
                                                Text(
                                                  "Move out",
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: blueColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 15),
                                      Row(
                                        children: [
                                          const SizedBox(width: 65),
                                          Text(
                                            '${dateProvider.formatCurrentDate('${snapshot.data![index].startDate}')} to',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: blueColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          const SizedBox(width: 65),
                                          Text(
                                            '${dateProvider.formatCurrentDate('${snapshot.data![index].endDate}')}',
                                            style: TextStyle(
                                              fontSize: 15,
                                              color: blueColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const SizedBox(width: 65),
                                          FaIcon(
                                            FontAwesomeIcons.phone,
                                            size: 18,
                                            color: blueColor,
                                          ),
                                          const SizedBox(width: 5),
                                          Text(
                                            formatPhoneNumber(
                                                '${snapshot.data![index].tenantPhoneNumber}'),
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: blueColor,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          const SizedBox(width: 65),
                                          FaIcon(
                                            FontAwesomeIcons.solidEnvelope,
                                            size: 18,
                                            color: blueColor,
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: Text(
                                              '${snapshot.data![index].tenantEmail}',
                                              style: TextStyle(
                                                fontSize: 15,
                                                color: blueColor,
                                                fontWeight: FontWeight.w500,
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
                          ),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          Wrap(
                            alignment: WrapAlignment.start,
                            spacing: MediaQuery.of(context).size.width * 0.03,
                            runSpacing:
                                MediaQuery.of(context).size.width * 0.02,
                            children:
                                List.generate(snapshot.data!.length, (index) {
                              DateTime currentDate = DateTime.now();
                              DateTime moveoutDate;
                              bool? ismove = false;
                              if (snapshot.data![index].moveoutDate! != "") {
                                moveoutDate = DateFormat('yyyy-MM-dd')
                                    .parse(snapshot.data![index].moveoutDate!);
                                ismove =
                                    moveoutDate.difference(currentDate).inDays <
                                        1;
                              }

                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 20,
                                  right: 20,
                                  top: 20,
                                ),
                                child: Material(
                                  elevation: 3,
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    //height: 240,
                                    //  width: MediaQuery.of(context).size.width * .44,
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .white, // Change as per your need
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: blueColor,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: [
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              const SizedBox(width: 10),
                                              Container(
                                                height: 35,
                                                width: 35,
                                                decoration: BoxDecoration(
                                                  color: blueColor,
                                                  border: Border.all(
                                                      color: blueColor),
                                                  borderRadius:
                                                      BorderRadius.circular(5),
                                                ),
                                                child: const Center(
                                                  child: FaIcon(
                                                    FontAwesomeIcons.user,
                                                    size: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 20),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 2),
                                                      Container(
                                                        width: 150,
                                                        child: Text(
                                                          '${snapshot.data![index].tenantFirstName} ${snapshot.data![index].tenantLastName}',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: blueColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 2),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width >
                                                                500
                                                            ? 200
                                                            : 150,
                                                        child: Text(
                                                          '${snapshot.data![index].rentalAddress}',
                                                          maxLines:
                                                              4, // Set maximum number of lines
                                                          overflow: TextOverflow
                                                              .ellipsis, // Handle overflow with ellipsis
                                                          style: TextStyle(
                                                            fontSize: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .width <
                                                                    500
                                                                ? 13
                                                                : 18,
                                                            color: blueColor,
                                                          ),
                                                        ),
                                                      ),
                                                      // Text(
                                                      //   snapshot.data!.data!.rentalAddress!,
                                                      //   style: const TextStyle(
                                                      //     fontSize: 15,
                                                      //     color: Color(0xFF8A95A8),
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const Spacer(),
                                              if (snapshot.data![index]
                                                      .moveoutDate ==
                                                  "")
                                                InkWell(
                                                  onTap: () async {
                                                    // showDialog(
                                                    //   context: context,
                                                    //   builder: (BuildContext
                                                    //       context) {
                                                    //     bool isChecked =
                                                    //         false; // Moved isChecked inside the StatefulBuilder
                                                    //     return StatefulBuilder(
                                                    //       builder: (BuildContext
                                                    //               context,
                                                    //           StateSetter
                                                    //               setState) {
                                                    //         return Dialog(
                                                    //           backgroundColor:
                                                    //               Colors.white,
                                                    //           surfaceTintColor:
                                                    //               Colors.white,
                                                    //           shape: RoundedRectangleBorder(
                                                    //               borderRadius:
                                                    //                   BorderRadius
                                                    //                       .circular(
                                                    //                           10.0)),
                                                    //           child: Padding(
                                                    //             padding:
                                                    //                 const EdgeInsets
                                                    //                     .only(
                                                    //                     left:
                                                    //                         16,
                                                    //                     right:
                                                    //                         16,
                                                    //                     top: 10,
                                                    //                     bottom:
                                                    //                         10),
                                                    //             child:
                                                    //                 Container(
                                                    //                     // width: MediaQuery.of(context).size.width - 10,
                                                    //                     width:
                                                    //                         900,
                                                    //                     child: buildMoveout(
                                                    //                         snapshot.data![
                                                    //                             index],
                                                    //                         tenants:
                                                    //                             snapshot.data)),
                                                    //           ),
                                                    //         );
                                                    //       },
                                                    //     );
                                                    //   },
                                                    // );
                                                    final result =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            MoveoutScreen(
                                                          tenant: snapshot
                                                              .data![index],
                                                          leaseId:
                                                              widget.leaseId,
                                                          tenants: leasetenant,
                                                          enddate:
                                                              widget.enddate ??
                                                                  "",
                                                          moveOutDate:
                                                              moveOutDate ?? "",
                                                        ),
                                                      ),
                                                    );
                                                    if (result == true) {
                                                      setState(() {
                                                        futureLeasetenant =
                                                            LeaseRepository
                                                                .fetchLeaseTenants(
                                                                    widget
                                                                        .leaseId);
                                                      });
                                                    }
                                                  },
                                                  child: Row(
                                                    children: [
                                                      FaIcon(
                                                        FontAwesomeIcons
                                                            .rightFromBracket,
                                                        size: 17,
                                                        color: blueColor,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "Move out",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: blueColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              //   if(isMovedOut || status == 'Expired')
                                              if (snapshot.data![index]
                                                      .moveoutDate !=
                                                  "")
                                                InkWell(
                                                  onTap: () async {
                                                    String? tenantId = snapshot
                                                                .data?[index]
                                                                .tenantId !=
                                                            null
                                                        ? snapshot.data![index]
                                                            .tenantId
                                                        : null;
                                                    SharedPreferences prefs =
                                                        await SharedPreferences
                                                            .getInstance();
                                                    String? id = prefs
                                                        .getString("adminId");
                                                    LeaseMoveoutRepository()
                                                        .addMoveInTenant(
                                                      adminId: id!,
                                                      tenantId: tenantId,
                                                      leaseId: snapshot
                                                          .data![index].leaseId,
                                                    )
                                                        .then((value) {
                                                      setState(() {
                                                        futureLeasetenant =
                                                            LeaseRepository
                                                                .fetchLeaseTenants(
                                                                    widget
                                                                        .leaseId);
                                                        isLoading = false;
                                                        // isMovedOut = true;
                                                      });

                                                      Navigator.pop(
                                                          context, true);
                                                    }).catchError((e) {
                                                      setState(() {
                                                        isLoading = false;
                                                      });
                                                    });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      FaIcon(
                                                        FontAwesomeIcons
                                                            .circleArrowLeft,
                                                        size: 17,
                                                        color: blueColor,
                                                      ),
                                                      const SizedBox(width: 5),
                                                      Text(
                                                        "Move In",
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: blueColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              // if(MediaQuery.of(context).size.width < 350)
                                              //   SizedBox(width: 5),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            children: [
                                              const SizedBox(width: 65),
                                              Text(
                                                ' ${dateProvider.formatCurrentDate('${snapshot.data![index].startDate}')} to',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: blueColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              Text(
                                                ' ${dateProvider.formatCurrentDate('${snapshot.data![index].endDate}')}',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: blueColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const SizedBox(width: 65),
                                              FaIcon(
                                                FontAwesomeIcons.phone,
                                                size: 15,
                                                color: blueColor,
                                              ),
                                              const SizedBox(width: 5),
                                              Text(
                                                formatPhoneNumber(
                                                    '${snapshot.data![index].tenantPhoneNumber}'),
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: blueColor,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              const SizedBox(width: 65),
                                              FaIcon(
                                                FontAwesomeIcons.solidEnvelope,
                                                size: 15,
                                                color: blueColor,
                                              ),
                                              const SizedBox(width: 5),
                                              Expanded(
                                                child: Text(
                                                  '${snapshot.data![index].tenantEmail}',
                                                  maxLines:
                                                      3, // Set maximum number of lines
                                                  overflow: TextOverflow
                                                      .ellipsis, // Handle overflow with ellipsis
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),

                                              // Text(
                                              //   '${snapshot.data!.data!.tenantData![index].tenantEmail}',
                                              //   style: const TextStyle(
                                              //     fontSize: 15,
                                              //     color: blueColor,
                                              //     fontWeight: FontWeight.w500,
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                          if (snapshot
                                                  .data![index].moveoutDate !=
                                              "")
                                            const SizedBox(height: 15),
                                          if (snapshot
                                                  .data![index].moveoutDate !=
                                              "")
                                            Row(
                                              children: [
                                                const SizedBox(width: 65),
                                                Text(
                                                  'Notice Date : ',
                                                  maxLines:
                                                      3, // Set maximum number of lines
                                                  overflow: TextOverflow
                                                      .ellipsis, // Handle overflow with ellipsis
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  formatDate(
                                                      '${snapshot.data![index].moveoutNoticeGivenDate}'),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: blueColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          if (snapshot
                                                  .data![index].moveoutDate !=
                                              "")
                                            const SizedBox(height: 15),
                                          if (snapshot
                                                  .data![index].moveoutDate !=
                                              "")
                                            Row(
                                              children: [
                                                const SizedBox(width: 65),
                                                Text(
                                                  'Move out : ',
                                                  maxLines:
                                                      3, // Set maximum number of lines
                                                  overflow: TextOverflow
                                                      .ellipsis, // Handle overflow with ellipsis
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: blueColor,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                Text(
                                                  formatDate(
                                                      '${snapshot.data![index].moveoutDate}'),
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: blueColor,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    );
            }
          },
        );
      },
    );
  }

  Widget buildMoveout(LeaseTenant tenant, {List<LeaseTenant>? tenants}) {
    // moveOutDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    // moveOutDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(widget.enddate!));

    // Convert to stateful list to track selection changes
    Map<String, TextEditingController> startDateControllers = {};
    Map<String, TextEditingController> moveoutDateControllers = {};
    Map<String, String> moveOutDates = {};

    List<LeaseTenant> selectedTenants =
        tenants!.where((t) => t.moveoutDate == "").toList();

    for (var t in selectedTenants!) {
      if (!startDateControllers.containsKey(t.tenantId)) {
        startDateControllers[t.tenantId!] = TextEditingController();
      }
      if (!moveoutDateControllers.containsKey(t.tenantId)) {
        moveoutDateControllers[t.tenantId!] = TextEditingController();
      }

      // Set default values for each tenant
      startDateControllers[t.tenantId!]!.text =
          DateFormat('yyyy-MM-dd').format(DateTime.now());
      moveoutDateControllers[t.tenantId!]!.text = formatDate(t.endDate!);

      // Set default selection
      t!.isSelected = (t.tenantId == tenant.tenantId);
    }

    moveOutDate = formatDate(widget.enddate!); // Store the original format

    //startdateController.text = moveOutDate;
    startdateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return StatefulBuilder(builder: (context, setState) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Move out Tenants",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: blueColor,
                  fontSize: MediaQuery.of(context).size.width < 500 ? 18 : 22),
            ),
            const SizedBox(height: 13),
            Text(
              "Select tenants to move out. If everyone is moving, the lease will end on the last move-out date. If some tenants are staying, you’ll need to renew the lease. Note: Renters insurance policies will be permanently deleted upon move-out.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: MediaQuery.of(context).size.width < 500 ? 14 : 18,
                color: const Color(0xFF8A95A8),
              ),
            ),
            const SizedBox(height: 15),
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Property Details',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              MediaQuery.of(context).size.width < 500 ? 16 : 20,
                          color: blueColor),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: blueColor),
                  ),
                  child: Table(
                    //border: TableBorder.all(color:blueColor),
                    border: TableBorder(
                      horizontalInside: BorderSide(
                        color: blueColor,
                        width: 1.0,
                      ),
                    ),
                    columnWidths: {
                      0: const FlexColumnWidth(2),
                      1: const FlexColumnWidth(3),
                    },
                    children: [
                      TableRow(
                        children: [
                          buildTableCell(Text(
                            'Address/Unit',
                            style: TextStyle(
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width < 500
                                  ? 15
                                  : 17,
                            ),
                          )),
                          buildTableCell(Text('${tenant.rentalAddress}')),
                        ],
                      ),
                      TableRow(
                        children: [
                          buildTableCell(Text('Lease Type',
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 17,
                              ))),
                          buildTableCell(Text('${tenant.leaseType}')),
                        ],
                      ),
                      TableRow(
                        children: [
                          buildTableCell(Text('Start End',
                              style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 17,
                              ))),
                          buildTableCell(
                              Text('${tenant.startDate} ${tenant.endDate}')),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Text(
                      'Tenant Details',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              MediaQuery.of(context).size.width < 500 ? 16 : 20,
                          color: blueColor),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Column(
                  children: selectedTenants.map((tenant) {
                    return Column(
                      children: [
                        Container(
                          //color: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 0.0),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 20.0,
                                height: 20.0,
                                child: Checkbox(
                                  value: tenant!.isSelected ?? false,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      tenant!.isSelected = value ?? false;
                                    });
                                  },
                                  activeColor: blueColor,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "${tenant.tenantFirstName} ${tenant.tenantLastName}",
                                style: TextStyle(
                                    color: blueColor,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        // if (tenant!.isSelected!)
                        Padding(
                          padding: const EdgeInsets.only(top: 10, bottom: 10),
                          child: Table(
                            border: TableBorder.all(color: blueColor),
                            columnWidths: {
                              0: const FlexColumnWidth(2),
                              1: const FlexColumnWidth(3),
                            },
                            children: [
                              TableRow(
                                children: [
                                  buildTableCell(Text('Tenants',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 15
                                                : 17,
                                      ))),
                                  buildTableCell(Text(
                                      '${tenant.tenantFirstName} ${tenant.tenantLastName}')),
                                ],
                              ),
                              TableRow(
                                children: [
                                  buildTableCell(Text('Notice Given Date',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 15
                                                : 17,
                                      ))),
                                  buildTableCell(buildDateField(
                                    startDateControllers[tenant.tenantId]!,
                                    enabled: tenant.isSelected!,
                                  )),
                                ],
                              ),
                              TableRow(
                                children: [
                                  buildTableCell(Text('Move-Out Date',
                                      style: TextStyle(
                                        color: blueColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 15
                                                : 17,
                                      ))),
                                  buildTableCell(buildDateField(
                                    moveoutDateControllers[tenant.tenantId]!,
                                    enabled: tenant.isSelected!,
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Material(
                    elevation: 3,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    child: Container(
                      height: MediaQuery.of(context).size.width < 500 ? 40 : 50,
                      width: 90,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Center(
                          child: Text(
                        "Close",
                        style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: MediaQuery.of(context).size.width < 500
                                ? 15
                                : 18,
                            color: blueColor),
                      )),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () async {
                    String? tenantId =
                        tenant.tenantId != null ? tenant.tenantId! : null;
                    SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                    String? id = prefs.getString("adminId");
                    List<Map<String, dynamic>> multipletenant = [];
                    for (tenant in selectedTenants) {
                      if (tenant.isSelected!) {
                        String moveoutNoticeGivenDate =
                            startDateControllers[tenant.tenantId!]!.text;
                        String moveoutdate =
                            moveoutDateControllers[tenant.tenantId!]!.text;
                        multipletenant.add({
                          'admin_id': id,
                          'tenant_id': tenant.tenantId!,
                          'lease_id': tenant.leaseId,
                          'moveout_notice_given_date': moveoutNoticeGivenDate!,
                          'moveout_date': moveoutdate!,
                        });
                      }
                    }

                    await LeaseMoveoutRepository()
                        .addMoveoutTenant(
                            adminId: id!,
                            tenantId: tenantId,
                            leaseId: tenant.leaseId,
                            moveoutDate: moveOutDate,
                            moveoutNoticeGivenDate: startdateController.text,
                            multitenantdata: multipletenant)
                        .then((value) {
                      setState(() {
                        futureLeasetenant =
                            LeaseRepository.fetchLeaseTenants(widget.leaseId);

                        isLoading = false;
                        isMovedOut = true;
                      });

                      reload_screen();
                      Navigator.pop(context, true);
                    }).catchError((e) {
                      setState(() {
                        isLoading = false;
                      });
                    });
                  },
                  child: Material(
                    elevation: 3,
                    borderRadius: const BorderRadius.all(Radius.circular(5)),
                    child: Container(
                      height: MediaQuery.of(context).size.width < 500 ? 40 : 50,
                      width:
                          MediaQuery.of(context).size.width < 500 ? 100 : 130,
                      decoration: BoxDecoration(
                        color: blueColor,
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5)),
                      ),
                      child: Center(
                          child: Text(
                        "Move Out",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize:
                              MediaQuery.of(context).size.width < 500 ? 15 : 17,
                        ),
                      )),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
          ],
        ),
      );
    });
  }

  Widget buildTableCell(Widget child) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: child,
      ),
    );
  }

  reload_screen() {
    setState(() {});
  }

  Widget buildDateField(TextEditingController controller,
      {bool enabled = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 2),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
          // border: Border.all(color: grey),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Select Date',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      builder: (BuildContext context, Widget? child) {
                        return Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme: const ColorScheme.light(
                              primary: Color.fromRGBO(
                                  21, 43, 83, 1), // header background color
                              onPrimary: Colors.white, // header text color
                              onSurface: Color.fromRGBO(
                                  21, 43, 83, 1), // body text color
                            ),
                            textButtonTheme: TextButtonThemeData(
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: const Color.fromRGBO(
                                    21, 43, 83, 1), // button text color
                              ),
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      // setState(() {
                      controller.text = moveOutDate!;
                      controller.text =
                          DateFormat('dd-MM-yyyy').format(pickedDate);
                      //  });
                    }
                  },
                ),
              ),
              readOnly: true,
            ),
          ),
        ),
      ),
    );
  }
}
