import 'dart:convert';
import 'dart:io';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/repository/setting.dart';
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/enterCharge.dart';
import '../../../../constant/constant.dart';
import '../../../../model/LeaseSummary.dart';

import '../../../repository/lease.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

import 'SummeryPageLease.dart';
import 'newAddLease.dart';

class Evict_tenant extends StatefulWidget {
  LeaseSummary? lease;
  String leaseId;
  String? startdate;
  String? enddate;

  String? leasetype;
  String? rentamount;
  Evict_tenant(
      {super.key,
      required this.leaseId,
      this.lease,
      this.rentamount,
      this.startdate,
      this.enddate,
      this.leasetype});

  @override
  State<Evict_tenant> createState() => _Evict_tenantState();
}

class _Evict_tenantState extends State<Evict_tenant> {
  List formDataRecurringList = [];
  late Future<LeaseSummary> futureLeaseSummary;
  final GlobalKey<FormState> _subFormKey = GlobalKey<FormState>();
  TabController? _tabController;
  bool isError = false;
  bool isChecked = false;
  late LeaseSummary leasegetdata;
  final TextEditingController damageAmountController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> tenants = [];
  List<Map<String, dynamic>> filteredTenants = [];
  List<String> selectedTenantIds =
      []; // Add back selectedTenantIds list but don't initialize with current tenants

  void filterTenants(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredTenants = List.from(tenants);
      } else {
        filteredTenants = tenants.where((tenant) {
          final fullName =
              '${tenant['tenant_firstName'] ?? ''} ${tenant['tenant_lastName'] ?? ''}'
                  .toLowerCase();
          return fullName.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  void initState() {
    futureLeaseSummary = LeaseRepository.fetchLeaseSummary(widget.leaseId);
    _selectedLeaseType = widget.leasetype;
    startDateController.text = formatDate(widget.enddate!) ?? "";
    DateTime endDate = formatDates(widget.enddate!);
    DateTime startDate = endDate;
    DateTime newEndDate =
        DateTime(endDate.year, endDate.month + 1, endDate.day);

    endDateController.text =
        formatDate(DateFormat('yyyy-MM-dd').format(newEndDate).toString());
    rent.text = widget.rentamount ?? "";

    searchController.addListener(() {
      filterTenants(searchController.text);
    });

    // Add listener to damage amount controller to update button state
    damageAmountController.addListener(() {
      setState(() {
        // This will trigger a rebuild and update the button state
      });
    });

    fetchTenant();

    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
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

    return parsedDate!;
  }

  TextEditingController rent = TextEditingController();
  TextEditingController securitydeposit = TextEditingController();
  final TextEditingController startDateController = TextEditingController();
  DateTime? _startDate;
  final TextEditingController endDateController = TextEditingController();
  String moveOutDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
  bool isLoading = false;
  bool isMovedOut = false;
  String? _selectedLeaseType;
  final List<String> leaseTypeitems = [
    'Fixed',
    'Fixed w/rollover',
    'At-will(month to month)',
  ];

  bool hasError = false;
  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
        ),
      ],
    );
  }

  List<FocusNode> focusNodes = [];
  Map<String, List<String>> categorizedData = {};
  final FocusNode _nodeText1 = FocusNode();
  List<Map<String, dynamic>> rows = [];
  double totalAmount = 0.0;

  Future<void> updatenewrenewallease(Map<String, dynamic> renewlease) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String adminId = prefs.getString('adminId') ?? '';
      String? token = prefs.getString('token');
      print(token);
      print('lease ${renewlease}');
      String? id = prefs.getString("adminId");
      final response =
          await http.post(Uri.parse('$Api_url/api/leases/renew_lease'),
              headers: {
                "authorization": "CRM $token",
                "id": "CRM $id",
                'Content-Type': 'application/json',
              },
              body: json.encode(renewlease));
      print(' lease renew ${response.body}');
      if (response.statusCode == 200) {
        Fluttertoast.showToast(msg: "Lease Renewal Successfully");
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => SummeryPageLease(
                  leaseId: widget.leaseId,
                )));
      } else {
        Fluttertoast.showToast(msg: "Renewal Lease not success");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchTenant() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? adminId = prefs.getString("adminId");
    String? token = prefs.getString("token");

    final response = await http.get(
      Uri.parse("${Api_url}/api/tenant/lease-tenant/$adminId"),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $adminId",
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tenant = data['data'] as List;

      setState(() {
        tenants = tenant.cast<Map<String, dynamic>>();
        filteredTenants = List.from(tenants);
      });
    } else {
      print("Failed to load templates");
    }
  }

  bool determineStatus(String? startDate, String? endDate) {
    if (startDate == null || endDate == null) return false;

    DateTime start = formatDates(startDate);
    DateTime end = formatDates(endDate);
    DateTime today = DateTime.now();

    if (today.isAfter(end)) {
      return true;
    } else {
      return false;
    }
  }

  bool isEvicting = false;

  bool isFormValid() {
    // Check if at least one tenant is selected
    if (selectedTenantIds.isEmpty) {
      return false;
    }

    // Check if damage amount is entered and valid
    if (damageAmountController.text.isEmpty) {
      return false;
    }

    // Check if damage amount is a valid number
    try {
      double.parse(damageAmountController.text);
    } catch (e) {
      return false;
    }

    return true;
  }

  Future<void> evictTenant() async {
    if (!isFormValid()) {
      Fluttertoast.showToast(
          msg:
              "Please select at least one tenant and enter a valid damage amount");
      return;
    }

    setState(() {
      isEvicting = true;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? adminId = prefs.getString("adminId");
      String? id = prefs.getString("staff_id");
      String? token = prefs.getString("token");

      // Process each selected tenant
      for (String tenantId in selectedTenantIds) {
        Map<String, dynamic> evictData = {
          "tenant_id": tenantId,
          "damage_amount": damageAmountController.text.isEmpty
              ? "0"
              : damageAmountController.text,
          "charge_of_lease_balance": isChecked,
          "lease_id": widget.leaseId,
          "admin_id": adminId,
        };

        final response = await http.post(
          Uri.parse("$Api_url/api/tenant/evict-tenant"),
          headers: {
            "authorization": "CRM $token",
            "id": "CRM $id",
            'Content-Type': 'application/json',
          },
          body: jsonEncode(evictData),
        );
        print("post data evict tenant ${response.body}");
        if (response.statusCode == 200) {
          Fluttertoast.showToast(msg: "Tenant evicted successfully");
          Navigator.of(context).pop();
        } else {
          Fluttertoast.showToast(
              msg: "Failed to evict tenant. Please try again.");
        }
      }
    } catch (e) {
      print(e);
      Fluttertoast.showToast(msg: "An error occurred. Please try again.");
    } finally {
      setState(() {
        isEvicting = false;
      });
    }
  }

  leaseData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String? id = prefs.getString("adminId");

    print('$Api_url/api/leases/lease_summary/${widget.leaseId}');
    final response = await http.get(
      Uri.parse('$Api_url/api/leases/lease_summary/${widget.leaseId}'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        leasegetdata = LeaseSummary.fromJson(jsonDecode(response.body));
        print("Renew lease ${leasegetdata.data!.renewLeases!.length}");
        if (determineStatus(
            leasegetdata.data!.startDate, leasegetdata.data!.endDate)) {
          // Lease is expired
          startDateController.text = formatDate(DateTime.now().toString());

          // Set the end date to one month from today's date
          DateTime newEndDate = DateTime(DateTime.now().year,
              DateTime.now().month + 1, DateTime.now().day);
          endDateController.text = formatDate(
              DateFormat('yyyy-MM-dd').format(newEndDate).toString());
        }
        if (leasegetdata.data!.renewLeases != null &&
            leasegetdata.data!.renewLeases!.isNotEmpty) {
          // Lease is active
          if (!determineStatus(leasegetdata.data!.renewLeases!.last.startDate!,
              leasegetdata.data!.renewLeases!.last.endDate!)) {
            DateTime endDate =
                formatDates(leasegetdata.data!.renewLeases!.last.endDate!);

            // Set start date to the current lease's end date
            startDateController.text =
                formatDate(DateFormat('yyyy-MM-dd').format(endDate).toString());

            // Extend the lease for one month from the current lease's end date
            DateTime newEndDate =
                DateTime(endDate.year, endDate.month + 1, endDate.day);
            endDateController.text = formatDate(
                DateFormat('yyyy-MM-dd').format(newEndDate).toString());
          }
        }
      });
    } else {
      throw Exception('Failed to load lease summary');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302_Staff.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawerStaff(
        currentpage: "Leases",
        dropdown: true,
      ),
      body: ListView(
        children: [
          SizedBox(height: 25),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Container(
                height: 50.0,
                padding: const EdgeInsets.only(top: 10, left: 10),
                width: MediaQuery.of(context).size.width * .91,
                margin: const EdgeInsets.only(bottom: 6.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: blueColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0),
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Text(
                  'Evict Tenant',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Container(
            child: FutureBuilder<LeaseSummary>(
              future: futureLeaseSummary,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * .35,
                    ),
                    child: Center(
                      child: SpinKitFadingCircle(
                        color: blueColor,
                        size: 40.0,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No data found'));
                } else {
                  final leasesummery = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 10,
                      bottom: 20,
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Material(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: blueColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  top: 10,
                                  bottom: 30,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(width: 6),
                                        Text(
                                          'Balance Amount :-',
                                          style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 17,
                                          ),
                                        ),
                                        SizedBox(width: 6),
                                        Text(
                                          '\$${leasesummery.data?.amount}',
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(width: 6),
                                        Text(
                                          'Damage Amount',
                                          style: TextStyle(
                                            color: blueColor,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8),
                                    Container(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      child: TextField(
                                        controller: damageAmountController,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                decimal: true),
                                        decoration: InputDecoration(
                                          hintText: 'Enter damage amount',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide:
                                                BorderSide(color: Colors.grey),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 12,
                                          ),
                                        ),
                                        onChanged: (value) {
                                          String newValue = value.replaceAll(
                                              RegExp(r'[^0-9.]'), '');
                                          newValue = newValue.replaceAll(
                                              RegExp(r'\..*\.'), '.');

                                          if (newValue != value) {
                                            damageAmountController.text =
                                                newValue;
                                            damageAmountController.selection =
                                                TextSelection.fromPosition(
                                              TextPosition(
                                                  offset: newValue.length),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(width: 7),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 24
                                              : 50,
                                          height: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 24
                                              : 50,
                                          child: Checkbox(
                                            value: isChecked,
                                            onChanged: (value) {
                                              setState(() {
                                                isChecked = value ?? false;
                                              });
                                            },
                                            activeColor: isChecked
                                                ? blueColor
                                                : Colors.black,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "Charge off lease balance",
                                          style: TextStyle(
                                            color: blueColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Material(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: blueColor),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  right: 8,
                                  top: 10,
                                  bottom: 30,
                                ),
                                child: Column(
                                  children: [
                                    SizedBox(height: 10),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade300),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: TextField(
                                                controller: searchController,
                                                decoration: InputDecoration(
                                                  hintText: 'Search tenants...',
                                                  prefixIcon: Icon(Icons.search,
                                                      color: blueColor),
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    horizontal: 15,
                                                    vertical: 12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(10),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 3,
                                                  child: Text(
                                                    'Tenant Name',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: blueColor,
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'Phone',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 15,
                                                      color: blueColor,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(width: 50),
                                              ],
                                            ),
                                          ),
                                          Divider(height: 1),
                                          if (tenants.isNotEmpty)
                                            ...filteredTenants.map((tenant) {
                                              return Column(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            '${tenant['tenant_firstName'] ?? ''} ${tenant['tenant_lastName'] ?? ''}',
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text(
                                                            tenant['tenant_phoneNumber'] ??
                                                                '-',
                                                            style: TextStyle(
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                        Checkbox(
                                                          value: selectedTenantIds
                                                              .contains(tenant[
                                                                  'tenant_id']),
                                                          onChanged:
                                                              (bool? checked) {
                                                            final tenantId =
                                                                tenant[
                                                                    'tenant_id'];
                                                            if (tenantId !=
                                                                null) {
                                                              setState(() {
                                                                if (checked ==
                                                                    true) {
                                                                  selectedTenantIds
                                                                      .add(
                                                                          tenantId);
                                                                } else {
                                                                  selectedTenantIds
                                                                      .remove(
                                                                          tenantId);
                                                                }
                                                              });
                                                            }
                                                          },
                                                          activeColor:
                                                              blueColor,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Divider(height: 1),
                                                ],
                                              );
                                            }).toList(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 15),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: isEvicting || !isFormValid()
                                    ? null
                                    : evictTenant,
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.width < 500
                                          ? 40
                                          : 45,
                                  // width: MediaQuery.of(context).size.width < 500
                                  //     ? 90
                                  //     : 150,
                                  decoration: BoxDecoration(
                                    color: isEvicting || !isFormValid()
                                        ? Colors.grey
                                        : blueColor,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: isEvicting
                                          ? SpinKitFadingCircle(
                                              color: Colors.white,
                                              size: 25.0,
                                            )
                                          : Text(
                                              'Evict Tenant',
                                              style: TextStyle(
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width <
                                                        500
                                                    ? 16
                                                    : 18,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.width < 500
                                          ? 35
                                          : 45,
                                  width: MediaQuery.of(context).size.width < 500
                                      ? 120
                                      : 165,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 16
                                                : 18,
                                        fontWeight: FontWeight.bold,
                                        color: blueColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
