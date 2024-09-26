import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/screens/Leasing/RentalRoll/enterCharge.dart';
import '../../../constant/constant.dart';
import '../../../model/LeaseSummary.dart';
import '../../../model/get_lease.dart';
import '../../../repository/lease.dart';
import '../../../widgets/CustomTableShimmer.dart';
import '../../../widgets/appbar.dart';
import '../../../widgets/custom_drawer.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';

class Renewlease extends StatefulWidget {
  LeaseSummary lease;
  String leaseId;

  Renewlease({super.key, required this.leaseId, required this.lease});

  @override
  State<Renewlease> createState() => _RenewleaseState();
}

class _RenewleaseState extends State<Renewlease> {
  List formDataRecurringList = [];
  late Future<LeaseSummary> futureLeaseSummary;

  TabController? _tabController;
  @override
  void initState() {
    // TODO: implement initState
    futureLeaseSummary = LeaseRepository.fetchLeaseSummary(widget.leaseId);
    // _tabController = TabController(length: 3, vsync: this);
    _selectedLeaseType = widget.lease.data?.leaseType;
    startDateController.text = widget.lease.data!.startDate ?? "";
    endDateController.text = widget.lease.data!.endDate ?? "";
    rent.text = widget.lease.data!.amount.toString();
    fetchDropdownData();
    super.initState();
  }

  TextEditingController rent = TextEditingController();
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
  void addRow() {
    setState(() {
      rows.add({
        'account': null,
        'charge_type': null,
        'amount': 0.0,

      });
      focusNodes.add(FocusNode());
    });
  }

  void deleteRow(int index) {
    setState(() {
      totalAmount -= rows[index]['amount'];
      rows.removeAt(index);
      focusNodes.removeAt(index);
    });

    validateAmounts();
  }

  void updateAmount(int index, String value) {
    setState(() {
      double amount = double.tryParse(value) ?? 0.0;
      totalAmount -= rows[index]['amount'];
      rows[index]['amount'] = amount;
      totalAmount += amount;
    });
    validateAmounts();
  }
  final TextEditingController Amount = TextEditingController();
  String? validationMessage;
  void validateAmounts() {
    double enteredAmount = double.tryParse(Amount.text) ?? 0.0;
    print(enteredAmount);
    print(totalAmount);
    if (enteredAmount != totalAmount) {
      setState(() {
        validationMessage =
        "The charge's amount must match the total applied to balance. The difference is ${(enteredAmount - totalAmount).abs().toStringAsFixed(2)}";
      });
    } else {
      setState(() {
        validationMessage = null;
      });
    }
  }
  Future<void> fetchDropdownData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String adminId = prefs.getString('adminId') ?? '';
      String? token = prefs.getString('token');
      print(token);
      print('lease ${widget.leaseId}');
      String? id = prefs.getString("adminId");
      final response = await http.get(
        Uri.parse('$Api_url/api/accounts/accounts/$adminId'),
        headers: {
          "authorization": "CRM $token",
          "id": "CRM $id",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body)['data'];
        Map<String, List<String>> fetchedData = {};
        // Adding static items to the "LIABILITY ACCOUNT" category
        fetchedData["Liability Account"] = [
          "Late Fee Income",
          "Pre-payments",
          "Security Deposit",
          'Rent Income'
        ];

        for (var item in jsonResponse) {
          String chargeType = item['charge_type'];
          String account = item['account'];

          if (!fetchedData.containsKey(chargeType)) {
            fetchedData[chargeType] = [];
          }
          fetchedData[chargeType]!.add(account);
        }

        setState(() {
          categorizedData = fetchedData;
          isLoading = false;
        });
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "Rent Roll",
        dropdown: true,
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 25,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Container(
                height: 50.0,
                padding: const EdgeInsets.only(top: 10, left: 10),
                width: MediaQuery.of(context).size.width * .91,
                margin: const EdgeInsets.only(bottom: 6.0),
                //Same as `blurRadius` i guess
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: const Color.fromRGBO(21, 43, 81, 1),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: const Text(
                  "Renew Lease",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            child: FutureBuilder<LeaseSummary>(
              future: futureLeaseSummary,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData) {
                  return Center(child: Text('No data found'));
                } else {
                  final leasesummery = snapshot.data!;
                  //final data = leaseLedger.data!.toList();
                  return Padding(
                    padding: const EdgeInsets.only(
                        left: 20, right: 20, top: 10, bottom: 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                '${leasesummery.data?.rentalAddress}',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: blueColor),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Material(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color.fromRGBO(21, 43, 81, 1)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 10, bottom: 30),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: grey,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8))),
                                      child: Column(
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "Current terms",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Table(
                                      children: [
                                        TableRow(children: [
                                          TableCell(
                                              child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              'Lease Type',
                                              style: TextStyle(
                                                  color:
                                                      const Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${leasesummery.data?.leaseType}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          TableCell(
                                              child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              'Start - End ',
                                              style: TextStyle(
                                                  color:
                                                      const Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${leasesummery.data?.startDate} to ${leasesummery.data?.endDate}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                        TableRow(children: [
                                          TableCell(
                                              child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Text(
                                              'Rent',
                                              style: TextStyle(
                                                  color:
                                                      const Color(0xFF8A95A8),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                            ),
                                          )),
                                          TableCell(
                                              child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 12),
                                            child: Text(
                                              '${leasesummery.data?.amount}',
                                              style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                  color: blueColor),
                                            ),
                                          )),
                                        ]),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Material(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color.fromRGBO(21, 43, 81, 1)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 10, bottom: 30),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 40,
                                      decoration: BoxDecoration(
                                          color: grey,
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(8),
                                              topRight: Radius.circular(8))),
                                      child: Column(
                                        // crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            children: [
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                "Offer",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 15,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Lease Type',
                                          style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: FormField<String>(
                                            initialValue: _selectedLeaseType,
                                            builder:
                                                (FormFieldState<String> state) {
                                              return Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  DropdownButtonHideUnderline(
                                                    child:
                                                        DropdownButton2<String>(
                                                      isExpanded: true,
                                                      hint: const Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 4,
                                                          ),
                                                          Expanded(
                                                            child: Text(
                                                              'Type',
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      items: leaseTypeitems
                                                          .map(
                                                            (String item) =>
                                                                DropdownMenuItem<
                                                                    String>(
                                                              value: item,
                                                              child: Text(
                                                                item,
                                                                style:
                                                                    const TextStyle(
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                            ),
                                                          )
                                                          .toList(),
                                                      value: _selectedLeaseType,
                                                      onChanged: (value) {
                                                        // Update the FormField state
                                                        setState(() {
                                                          _selectedLeaseType =
                                                              value;
                                                          state
                                                              .didChange(value);
                                                        });
                                                        state.reset();
                                                      },
                                                      buttonStyleData:
                                                          ButtonStyleData(
                                                        height: 50,
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                                left: 14,
                                                                right: 14),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                          border: Border.all(
                                                            color:
                                                                Colors.black26,
                                                          ),
                                                          color: Colors.white,
                                                        ),
                                                        elevation: 3,
                                                      ),
                                                      dropdownStyleData:
                                                          DropdownStyleData(
                                                        maxHeight: 200,
                                                        width: 200,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(14),
                                                        ),
                                                        offset: const Offset(
                                                            -20, 0),
                                                        scrollbarTheme:
                                                            ScrollbarThemeData(
                                                          radius: const Radius
                                                              .circular(40),
                                                          thickness:
                                                              MaterialStateProperty
                                                                  .all(6),
                                                          thumbVisibility:
                                                              MaterialStateProperty
                                                                  .all(true),
                                                        ),
                                                      ),
                                                      menuItemStyleData:
                                                          const MenuItemStyleData(
                                                        height: 40,
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 14,
                                                                right: 14),
                                                      ),
                                                    ),
                                                  ),
                                                  if (state.hasError)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 14, top: 8),
                                                      child: Text(
                                                        state.errorText!,
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                            validator: (value) {
                                              if (_selectedLeaseType == null) {
                                                return 'Please select a lease type';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text('Start Date *',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor)),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomTextField(
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101),
                                            locale: const Locale('en', 'US'),
                                            builder: (BuildContext context,
                                                Widget? child) {
                                              return Theme(
                                                data:
                                                    ThemeData.light().copyWith(
                                                  colorScheme:
                                                      const ColorScheme.light(
                                                    primary: Color.fromRGBO(
                                                        21,
                                                        43,
                                                        83,
                                                        1), // header background color
                                                    onPrimary: Colors
                                                        .white, // header text color
                                                    onSurface: Color.fromRGBO(
                                                        21,
                                                        43,
                                                        83,
                                                        1), // body text color
                                                  ),
                                                  textButtonTheme:
                                                      TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor: const Color
                                                          .fromRGBO(21, 43, 83,
                                                          1), // button text color
                                                    ),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (pickedDate != null) {
                                            // String formattedStartDate =
                                            //     "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                            String formattedStartDate =
                                                "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                            DateTime endDate = DateTime(
                                                pickedDate.year,
                                                pickedDate.month + 1,
                                                pickedDate.day);

                                            // String formattedEndDate =
                                            //     "${endDate.day.toString().padLeft(2, '0')}-${endDate.month.toString().padLeft(2, '0')}-${endDate.year}";
                                            setState(() {
                                              startDateController.text =
                                                  formattedStartDate;
                                              _startDate = pickedDate;
                                            });
                                          }
                                        },
                                        readOnnly: true,
                                        suffixIcon: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                                Icons.date_range_rounded)),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select start date';
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.text,
                                        hintText: 'dd-mm-yyyy',
                                        controller: startDateController,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text('End Date *',
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: blueColor)),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: CustomTextField(
                                        onTap: () async {
                                          DateTime? pickedDate =
                                              await showDatePicker(
                                            context: context,
                                            initialDate: DateTime.now(),
                                            firstDate: DateTime(2000),
                                            lastDate: DateTime(2101),
                                            locale: const Locale('en', 'US'),
                                            builder: (BuildContext context,
                                                Widget? child) {
                                              return Theme(
                                                data:
                                                    ThemeData.light().copyWith(
                                                  colorScheme:
                                                      const ColorScheme.light(
                                                    primary: Color.fromRGBO(
                                                        21,
                                                        43,
                                                        83,
                                                        1), // header background color
                                                    onPrimary: Colors
                                                        .white, // header text color
                                                    onSurface: Color.fromRGBO(
                                                        21,
                                                        43,
                                                        83,
                                                        1), // body text color
                                                  ),
                                                  textButtonTheme:
                                                      TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor: const Color
                                                          .fromRGBO(21, 43, 83,
                                                          1), // button text color
                                                    ),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );

                                          if (pickedDate != null) {
                                            // String formattedDate =
                                            //     "${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')}";
                                            String formattedDate =
                                                "${pickedDate.day.toString().padLeft(2, '0')}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.year}";
                                            setState(() {
                                              endDateController.text =
                                                  formattedDate;
                                            });
                                          }
                                        },
                                        readOnnly: true,
                                        suffixIcon: IconButton(
                                            onPressed: () {},
                                            icon: const Icon(
                                                Icons.date_range_rounded)),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please select end date';
                                          }
                                          return null;
                                        },
                                        optional: true,
                                        keyboardType: TextInputType.text,
                                        hintText: 'dd-mm-yyyy',
                                        controller: endDateController,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          'Rent',
                                          style: TextStyle(
                                              color: blueColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                    CustomTextField(
                                      keyboardType: TextInputType.emailAddress,
                                      hintText: 'Enter rent',
                                      controller: rent,
                                    ),

                                    SizedBox(
                                      height: 20,
                                    ),
                                    isLoading
                                        ? const Center(
                                      child: SpinKitFadingCircle(
                                        color: Colors.black,
                                        size: 50.0,
                                      ),
                                    )
                                        : hasError
                                        ? const Center(child: Text('Failed to load data'))
                                        : Table(
                                      border: TableBorder.all(width: 1),
                                      columnWidths: const {
                                        0: FlexColumnWidth(2),
                                        1: FlexColumnWidth(2),
                                        2: FlexColumnWidth(1),
                                      },
                                      children: [
                                        const TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Center(
                                              child: Text('Account',
                                                  style: TextStyle(
                                                      color:
                                                      Color.fromRGBO(21, 43, 83, 1),
                                                      fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Center(
                                              child: Text('Amount',
                                                  style: TextStyle(
                                                      color:
                                                      Color.fromRGBO(21, 43, 83, 1),
                                                      fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.all(5.0),
                                            child: Center(
                                              child: Text('Actions',
                                                  style: TextStyle(
                                                      color:
                                                      Color.fromRGBO(21, 43, 83, 1),
                                                      fontWeight: FontWeight.bold)),
                                            ),
                                          ),
                                        ]),
                                        ...rows.asMap().entries.map((entry) {
                                          int index = entry.key;
                                          Map<String, dynamic> row = entry.value;
                                          return TableRow(children: [
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: DropdownButtonHideUnderline(
                                                child: DropdownButton2<String>(
                                                  isExpanded: true,
                                                  style: TextStyle(fontSize: 14),
                                                  value: row['account'],
                                                  items: [
                                                    ...categorizedData.entries
                                                        .expand((entry) {
                                                      return [
                                                        DropdownMenuItem<String>(
                                                          enabled: false,
                                                          child: Text(
                                                            entry.key,
                                                            style: const TextStyle(
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: Color.fromRGBO(
                                                                  21, 43, 81, 1),
                                                            ),
                                                          ),
                                                        ),
                                                        ...entry.value.map((item) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: item,
                                                            child: Padding(
                                                              padding:
                                                              const EdgeInsets.only(
                                                                  left: 0.0),
                                                              child: Text(
                                                                item,
                                                                style: const TextStyle(
                                                                  color: Colors.black,
                                                                  fontWeight:
                                                                  FontWeight.w400,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      ];
                                                    }).toList(),
                                                  ],
                                                  onChanged: (value) {
                                                    String? chargeType;
                                                    for (var entry
                                                    in categorizedData.entries) {
                                                      if (entry.value.contains(value)) {
                                                        chargeType = entry.key;
                                                        break;
                                                      }
                                                    }

                                                    setState(() {
                                                      rows[index]['account'] = value;
                                                      rows[index]['charge_type'] =
                                                          chargeType;
                                                    });
                                                  },
                                                  buttonStyleData: ButtonStyleData(
                                                    height: 50,
                                                    width: 220,
                                                    padding: const EdgeInsets.only(
                                                        left: 8, right: 5),
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(6),
                                                      color: Colors.white,
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  iconStyleData: const IconStyleData(
                                                    icon: Icon(Icons.arrow_drop_down),
                                                    iconSize: 24,
                                                    iconEnabledColor: Color(0xFFb0b6c3),
                                                    iconDisabledColor: Colors.grey,
                                                  ),
                                                  dropdownStyleData: DropdownStyleData(
                                                    width: 250,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                      BorderRadius.circular(6),
                                                      color: Colors.white,
                                                    ),
                                                    scrollbarTheme: ScrollbarThemeData(
                                                      radius: const Radius.circular(6),
                                                      thickness:
                                                      MaterialStateProperty.all(6),
                                                      thumbVisibility:
                                                      MaterialStateProperty.all(
                                                          true),
                                                    ),
                                                  ),
                                                  hint: const Text('Select an account'),
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(top: 5),
                                              child: Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: SizedBox(
                                                  height: 50,
                                                  child: KeyboardActions(
                                                    config: _buildConfig(context),
                                                    child: TextFormField(
                                                      initialValue: widget.leaseId !=
                                                          null
                                                          ? rows[index]["amount"]
                                                          .toString()
                                                          : "0", // Make sure 0 is a string,
                                                      focusNode: focusNodes[index],
                                                      keyboardType:
                                                      TextInputType.number,
                                                      onChanged: (value) =>
                                                          updateAmount(index, value),
                                                      decoration: const InputDecoration(
                                                          border: OutlineInputBorder(),
                                                          hintText: 'Enter amount',
                                                          hintStyle:
                                                          TextStyle(fontSize: 14),
                                                          contentPadding:
                                                          EdgeInsets.only(
                                                              top: 7, left: 7)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: Colors.red),
                                                onPressed: () => deleteRow(index),
                                              ),
                                            ),
                                          ]);
                                        }).toList(),
                                        TableRow(children: [
                                          const Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text('Total',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                '\$${totalAmount.toStringAsFixed(2)}'),
                                          ),
                                          const SizedBox.shrink(),
                                        ]),
                                        TableRow(children: [
                                          Padding(
                                            padding: EdgeInsets.only(
                                                left:
                                                MediaQuery.of(context).size.width <
                                                    500
                                                    ? 16
                                                    : 70,
                                                right:
                                                MediaQuery.of(context).size.width <
                                                    500
                                                    ? 16
                                                    : 70,
                                                top: 10,
                                                bottom: 10),
                                            child: Container(
                                              height: 40,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(width: 1),
                                                  borderRadius:
                                                  BorderRadius.circular(5.0)),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                    shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                        BorderRadius.circular(
                                                            5.0)),
                                                    elevation: 0,
                                                    backgroundColor: Colors.white),
                                                onPressed: addRow,
                                                child: Text(
                                                  'Add Row',
                                                  style: TextStyle(
                                                    fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                        500
                                                        ? 14
                                                        : 18,
                                                    color:
                                                    Color.fromRGBO(21, 43, 83, 1),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox.shrink(),
                                          const SizedBox.shrink(),
                                        ]),
                                      ],
                                    ),

                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                    height:
                                        MediaQuery.of(context).size.width < 500
                                            ? 40
                                            : 45,
                                    width:
                                        MediaQuery.of(context).size.width < 500
                                            ? 90
                                            : 150,
                                    decoration: BoxDecoration(
                                        color: blueColor,
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: Center(
                                      child: Text(
                                        'Ok',
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 16
                                                : 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    )),
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
                                    width:
                                        MediaQuery.of(context).size.width < 500
                                            ? 120
                                            : 165,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(5.0)),
                                    child: Center(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 16
                                                : 18,
                                            fontWeight: FontWeight.bold,
                                            color: blueColor),
                                      ),
                                    )),
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
