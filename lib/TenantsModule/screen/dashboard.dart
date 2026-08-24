import 'dart:async';
import 'package:three_zero_two_property/services/app_log.dart';
import 'dart:convert';
import 'dart:core';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/TenantsModule/screen/financial/payment/make_payment.dart';
import 'package:three_zero_two_property/TenantsModule/screen/recurringpayment.dart';
import 'package:three_zero_two_property/TenantsModule/screen/work_order/workorder_table.dart';
import 'package:three_zero_two_property/TenantsModule/widgets/appbar.dart';
import 'package:three_zero_two_property/TenantsModule/widgets/custom_drawer.dart';
import '../../provider/dateProvider.dart';
import '../repository/permission_provider.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/services/api_helpers.dart';
import '../../constant/constant.dart';
import 'financial/financial_table.dart';
import 'package:three_zero_two_property/widgets/no_internet_view.dart';
import 'package:three_zero_two_property/provider/network_retry_state.dart';

class DashboardData {
  // int tenantCount = 0;
  // int rentalCount = 0;
  // int vendorCount = 0;
  // int applicantCount = 0;
  // int workOrderCount = 0;

  List<dynamic> countList = [];
  List<int> amountList = [];

  List<String> ico = [
    // "assets/images/Properti-icon.svg",
    "assets/images/workorder-icon.svg",
    "assets/images/tenants/balance.svg",
    "assets/images/tenants/rent.svg",
    "assets/images/tenants/duedate.svg",
    "assets/images/tenants/leaseicon.svg",
  ];

  List<IconData> icons = [
    // "assets/images/Properti-icon.svg",
    Icons.event_note_rounded,
    Icons.monetization_on_outlined,
    CupertinoIcons.money_dollar,
    Icons.hourglass_bottom_rounded,
    Icons.calendar_month
  ];

  List<String> titles = [
    "Work Orders",
    "Balance",
    "Monthly Rent", // This will be updated dynamically
    "Due Date",
    "Lease End Date",
  ];

  List<Color> colorc = [
    blueColor,
    const Color.fromRGBO(40, 60, 95, 1),
    const Color.fromRGBO(50, 75, 119, 1),
    const Color.fromRGBO(60, 89, 142, 1),
    const Color.fromRGBO(90, 134, 213, 1),
  ];

  List<Color> colors = [
    blueColor,
    const Color.fromRGBO(40, 60, 95, 1),
    const Color.fromRGBO(50, 75, 119, 1),
    const Color.fromRGBO(60, 89, 142, 1),
    const Color.fromRGBO(90, 134, 213, 1),
  ];

  DashboardData({required this.countList, required this.amountList});
}

class Dashboard_tenants extends StatefulWidget {
  Dashboard_tenants({super.key});

  @override
  State<Dashboard_tenants> createState() => _Dashboard_tenantsState();
}

class _Dashboard_tenantsState extends State<Dashboard_tenants>
    with NetworkRetryState {
  GlobalKey<ScaffoldState> key = GlobalKey<ScaffoldState>();
  String firstname = '';
  String lastname = '';
  bool loading = false;
  String lease_id = '';
  String tenantId = '';
  String rentCycle = 'Monthly'; // Default value
  Future<void> fetchDatacount() async {
    /*setState(() {
      loading = true;
    });*/
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
      String? token = prefs.getString('token');

      final response = await http
          .get(Uri.parse('${Api_url}/api/tenant/count/${id!}'), headers: {
        "id": "CRM $id",
        "authorization": "CRM $token",
        "Content-Type": "application/json"
      });
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        setState(() {
          //  countList[0] = jsonData["data"]['all_workorders'] ?? 0;
          countList[0] = jsonData["data"]['workOrder'] ?? 0;
          //  countList[1] = jsonData['rentalCount'];
          countList[2] = jsonData["data"]['rent'];
          countList[3] =
              convertDateFormat(jsonData["data"]['rentDueDate'].toString());
          countList[4] =
              convertDateFormat(jsonData["data"]['end_date'].toString());
          countList[5] =
              convertDateFormat(jsonData["data"]['start_date'].toString());
          countList[1] = formatMoney(jsonData["data"]['balance']);
          rentCycle = jsonData["data"]['rentCycle'] ??
              'Monthly'; // Store rent cycle from API
          lease_id = jsonData["data"]['lease_id'];
          tenantId = id;
          loading = false;
        });
        fetchUpcomingPayments(jsonData["data"]['lease_id']);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      logError(e);
      setState(() {
        countList[0] = 0;
        countList[2] = 0;
        countList[3] = "--/--/----";
        countList[4] = "--/--/----";
        countList[5] = "--/--/----";
      });
      logError('Error fetching data: $e');
    } finally {}
  }

  Future<void> fetchDatafinancial() async {
    /*setState(() {
      loading = true;
    });*/
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
      String? token = prefs.getString('token');
      final response = await apiGet(
          Uri.parse('${Api_url}/api/payment/tenant_financial/${id!}'),
          headers: {
            "id": "CRM $id",
            "authorization": "CRM $token",
            "Content-Type": "application/json"
          });
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        setState(() {
          // countList[0] = jsonData['property_staffMember'];

          /*  countList[2] = jsonData['vendorCount'];
          countList[3] = jsonData['applicantCount'];
          countList[1] = jsonData['workorder_staffMember'];*/
          loading = false;
        });
      } else {
        //throw Exception('Failed to load data');
      }
    } catch (e) {
      logError('Error fetching data: $e');
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  int newworkorder = 0;
  int overdueworkorder = 0;
  double currentMonthRentDue = 0.0;
  double lastMonthRentDue = 0.0;
  double currentMonthRentPaid = 0.0;
  double lastMonthRentPaid = 0.0;
  double totalRentPastDue = 0.0;

  // Dynamic data for upcoming payments and recent transactions
  List<dynamic> upcomingPayments = [];
  List<dynamic> recentTransactions = [];

  Future<void> fetchData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("tenant_id");
    String? admin_id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await apiGet(
        Uri.parse('${Api_url}/api/tenant/dashboard_workorder/$id'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
          "Content-Type": "application/json"
        });
    //print('${Api_url}/api/payment/admin_balance/$id');
    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData["statusCode"] == 200) {
        final data = jsonData["data"];
        setState(() {
          var newwork = data["new_workorders"];
          var overdue = data["overdue_workorders"];
          newworkorder = newwork;
          overdueworkorder = overdue;
          // countList[0] is now set from fetchDatacount() - don't overwrite it
          // countList[0] = data["all_workorders"];
        });
      } else {
        throw Exception('Failed to load data');
      }
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> fetchUpcomingPayments(String lease_id) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
      String? token = prefs.getString('token');

      final response = await apiGet(
          Uri.parse('${Api_url}/api/tenant/upcoming-tenant-payment/$lease_id'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
            "Content-Type": "application/json"
          });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          setState(() {
            upcomingPayments = jsonData["data"] ?? [];
          });
        }
      }
    } catch (e) {
      logError('Error fetching upcoming payments: $e');
    }
  }

  Future<void> fetchRecentTransactions() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? id = prefs.getString("tenant_id");
      String? token = prefs.getString('token');

      final response = await apiGet(
          Uri.parse('${Api_url}/api/tenant/tenant-recent-payments/$id'),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
            "Content-Type": "application/json"
          });

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData["statusCode"] == 200) {
          setState(() {
            recentTransactions = jsonData["data"] ?? [];
          });
        }
      }
    } catch (e) {
      logError('Error fetching recent transactions: $e');
    }
  }

  Future<bool> _showExitPopup(BuildContext context) async {
    bool exitConfirmed = false;

    await Alert(
      context: context,
      type: AlertType.warning,
      title: "Exit App",
      desc: "Do you want to exit the app?",
      style: AlertStyle(
        backgroundColor: Colors.white,
        titleStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
        descStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black54,
        ),
        animationType: AnimationType.grow,
        isOverlayTapDismiss: false,
        overlayColor: Colors.black.withOpacity(0.5),
        alertBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
          side: const BorderSide(color: Colors.blue, width: 2),
        ),
        alertPadding: const EdgeInsets.all(16.0),
      ),
      buttons: [
        DialogButton(
          child: const Text(
            "No",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          color: Colors.red,
          radius: BorderRadius.circular(8.0),
        ),
        DialogButton(
          child: const Text(
            "Yes",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: () {
            exitConfirmed = true;
            if (Platform.isAndroid) {
              SystemNavigator.pop();
            } else if (Platform.isIOS) {
              exit(0);
            }
          },
          color: Colors.green,
          radius: BorderRadius.circular(8.0),
        ),
      ],
    ).show();

    return exitConfirmed;
  }

  late DashboardData dashboardData;
  List<dynamic> countList = [0, 0, 0, "", "", ""];
  List<int> amountList = List.filled(2, 0);
  String convertDateFormat(String dateStr) {
    final dateProvider = Provider.of<DateProvider>(context, listen: false);
    if (dateStr.isEmpty || dateStr == 'null') {
      return 'N/A';
    }
    return dateProvider.formatCurrentDate(dateStr);
  }

  ConnectivityResult? _connectivityResult;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }

  /// Required by [NetworkRetryState]: re-issue this screen's own load.
  /// The four loads initState makes; the dashboardData seed is not repeated.
  @override
  Future<void> reloadData() async {
    if (!mounted) return;
    fetchDatacount();
    fetchData();
    _loadName();
    fetchRecentTransactions();
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
    dashboardData =
        DashboardData(countList: [0, 0, 0, "", "", ""], amountList: [0, 0]);
    fetchDatacount();
    fetchData();
    _loadName();
    //fetchDatafinancial();
    fetchRecentTransactions();
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

  Future<void> _loadName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      firstname = prefs.getString('first_name') ?? '';
      lastname = prefs.getString('last_name') ?? '';
    });
  }

  var appBarHeight = AppBar().preferredSize.height;
  @override
  Widget build(BuildContext context) {
    final permissionProvider = Provider.of<PermissionProvider>(context);
    final permissions = permissionProvider.permissions;
    final dateProvider = Provider.of<DateProvider>(context);
    return WillPopScope(
      onWillPop: () async {
        return await _showExitPopup(context);
      },
      child: Scaffold(
        key: key,
        backgroundColor: const Color(0xFFF5F5F5), // Light gray background
        drawer: CustomDrawer(
          currentpage: 'Dashboard',
        ),
        appBar: widget_302.App_Bar(
            context: context,
            onDrawerIconPressed: () {
              key.currentState!.openDrawer();
            }),
        body: !isOffline
            ? loading
                ? const Center(
                    child: SpinKitFadingCircle(
                      color: Colors.black,
                      size: 50.0,
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome message

                        const SizedBox(height: 10),

                        // Main information cards
                        _buildInfoCards(context, permissions),

                        const SizedBox(height: 20),

                        // Recent Transactions
                        _buildRecentTransactions(dateProvider),

                        const SizedBox(height: 20),

                        // Scheduled and Recurring Payments
                        _buildScheduledPayments(dateProvider),
                      ],
                    ),
                  )
            : _buildNoInternetView(),
      ),
    );
  }

  Widget _buildInfoCards(BuildContext context, dynamic permissions) {
    return Column(
      children: [
        // Monthly Rent Card
        _buildInfoCard(
          icon: Icons.account_balance_wallet,
          iconColor: const Color(0xFF8B4513),
          title: "Monthly Rent",
          leftLabel: "Rent Amount",
          leftValue: formatMoney(countList[2]),
          rightLabel: "Next Due Date",
          rightValue: countList[3].toString(),
          onTap: () {},
        ),

        const SizedBox(height: 16),

        // Lease Card
        _buildInfoCard(
          icon: Icons.description,
          iconColor: const Color(0xFF4CAF50),
          title: "Lease",
          leftLabel: "Start Date",
          leftValue: countList[5].toString(),
          rightLabel: "End Date",
          rightValue: countList[4].toString(),
          onTap: () {},
        ),

        const SizedBox(height: 16),

        // Balance Card
        _buildInfoCard(
          icon: Icons.account_balance,
          iconColor: const Color(0xFF2196F3),
          title: "Balance",
          leftLabel: "Remaining Balance",
          leftValue: countList[1].toString(),
          rightLabel: "",
          rightValue: "",
          onTap: () {
            if (permissions?.financialView == true) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => FinancialTable()),
              );
            }
          },
        ),

        const SizedBox(height: 16),

        // Work Orders Card
        _buildInfoCard(
          icon: Icons.assignment,
          iconColor: const Color(0xFF2196F3),
          title: "Work Orders",
          leftLabel: "Open Work Orders",
          leftValue: countList[0].toString(),
          rightLabel: "",
          rightValue: "",
          onTap: () {
            if (permissions?.workorderView == true) {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => WorkOrderTable()),
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                const Icon(Icons.keyboard_arrow_right, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (leftLabel.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leftLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        leftValue,
                        style: const TextStyle(
                          fontSize: 15,
                          // fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                if (rightLabel.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        rightLabel,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        rightValue,
                        style: const TextStyle(
                          fontSize: 15,
                          //  fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPaymentAmount(dynamic amount) {
    // Upcoming-payment amounts arrive either as a plain value or wrapped in a
    // single-element list; both render through the shared currency helper.
    if (amount is List) {
      return amount.isEmpty ? formatMoney(0) : formatMoney(amount.first);
    }
    return formatMoney(amount);
  }

  Widget _buildRecentTransactions(DateProvider dateProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Recent Transactions",
                style: TextStyle(
                  fontSize: 16,
                  letterSpacing: 0.5,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => FinancialTable()));
                },
                child: const Text(
                  "See All",
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 0.5,
                    color: Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (recentTransactions.isEmpty)
            const Center(
              child: Text(
                "No recent transactions found",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            )
          else
            ...recentTransactions
                .take(3)
                .map(
                  (transaction) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2196F3).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.payment,
                            color: Color(0xFF2196F3),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction['tenant_name'] ?? 'Unknown',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "${transaction['payment_type'] ?? 'Payment'} - ${transaction['date'] != null && transaction['date'].toString().isNotEmpty ? dateProvider.formatCurrentDate(transaction['date'].toString()) : ''}",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                              if (transaction['responseText'] != null)
                                Text(
                                  transaction['responseText'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: transaction['state'] == 'settling'
                                        ? Colors.orange
                                        : Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Text(
                          formatMoney(transaction['total_amount']),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  Widget _buildScheduledPayments(DateProvider dateProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Upcoming Payments",
            style: TextStyle(
              fontSize: 16,
              letterSpacing: 0.5,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) =>
                          MakePayment(leaseId: lease_id, tenantId: tenantId),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3DA600),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Schedule a Payment",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigator.of(context).push(MaterialPageRoute(
                    //   builder: (context) =>
                    //       RecurringPayment(leaseData: leaseData),
                    // ));
                    // You can add your navigation or functionality here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF3F7FF),
                    foregroundColor: const Color(0xFF2196F3),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.autorenew,
                        color: Colors.black,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      // put in Text span for different color of text
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Setup",
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            TextSpan(
                              text: " Auto",
                              style: TextStyle(
                                color: blueColor,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                            TextSpan(
                              text: "pay",
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 14,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (upcomingPayments.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  "No upcoming payments scheduled",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...upcomingPayments
                .map(
                  (payment) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2196F3).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.home,
                                color: Color(0xFF2196F3),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    payment['tenant_name'] ?? 'Unknown',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Due Date – ${payment['date'] != null && payment['date'].toString().isNotEmpty ? dateProvider.formatCurrentDate(payment['date'].toString()) : ''}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF9C27B0),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                payment['payment_type'] ?? 'Recurring',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF9C27B0),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatPaymentAmount(payment['amount']),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

  Widget _buildNoInternetView() {
    return NoInternetView(onRetry: retryNow);
  }
}
