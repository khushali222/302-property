import 'package:credit_card_type_detector/credit_card_type_detector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/Model/Preminum%20Plans/GetCardDetailModel.dart';
import 'package:three_zero_two_property/Model/Preminum%20Plans/customAddSubscriptionModel.dart';
import 'package:three_zero_two_property/Model/Preminum%20Plans/purchaseFormModel.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/provider/Plan%20Purchase/plancheckProvider.dart';
import 'package:three_zero_two_property/repository/Preminum%20Plans/CustomAddSubscriptionService.dart';
import 'package:three_zero_two_property/repository/Preminum%20Plans/purchaseFormService.dart';
import 'package:three_zero_two_property/screens/Dashboard/dashboard_one.dart';
import 'package:three_zero_two_property/screens/Rental/Tenants/add_tenants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:three_zero_two_property/screens/test_table/add_lease.dart';
import 'package:three_zero_two_property/widgets/titleBar.dart';
import '../../widgets/appbar.dart';
import '../../widgets/drawer_tiles.dart';

class PreminumPlanForm extends StatefulWidget {
  CardData plan;
  PreminumPlanForm({required this.plan});

  @override
  State<PreminumPlanForm> createState() => _PreminumPlanFormState();
}

class _PreminumPlanFormState extends State<PreminumPlanForm> {
  bool isLoading = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _PayMentformKey = GlobalKey<FormState>();

  final TextEditingController streetaddress1 = TextEditingController();
  final TextEditingController streetaddress2 = TextEditingController();
  final TextEditingController city = TextEditingController();
  final TextEditingController state = TextEditingController();
  final TextEditingController postalcode = TextEditingController();
  final TextEditingController country = TextEditingController();
  // final TextEditingController cardNumber = TextEditingController();
  final TextEditingController cVV = TextEditingController();
  final TextEditingController cardHolderName = TextEditingController();

  String? _selectedExpiringMonth;
  String? _selectedExpiringYear;
  List<String> expiringMonth = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12'
  ];
  List<String> expiringYear =
      List.generate(12, (index) => (2024 + index).toString());
  String yearmessage = "";
  String selectedCountry = '';
  bool yearerror = false;
  bool isShowStep2Details = false;

  List<String> countries = [];

  String? planStartDate;
  String? planExpireDate;

  TextEditingController cardNumberController = TextEditingController();
  String carderrorMessage = '';
  String? cardLogo;

  @override
  void initState() {
    super.initState();
    fetchCountries();
    calculateDateOfExpire();
  }

  @override
  void dispose() {
    cardNumberController.dispose();
    super.dispose();
  }

  String? finalStringCardType;

  void setCardNumber(String value) async {
    setState(() {
      cardNumberController.text = value;
    });

    // Clean the card number
    final sanitizedValue = value.replaceAll(RegExp(r'\D'), '');

    // Detect the card type
    final cardTypes = detectCCType(sanitizedValue);

    if (cardTypes.isNotEmpty) {
      // Get the first card type
      final cardType = cardTypes[0];
      final cardTypeName = cardType.type
          .toLowerCase(); // Access the 'type' property and convert to lowercase

      // Remove underscores from cardTypeName
      finalStringCardType = cardTypeName.replaceAll('_', '');

      final logoUrl = 'https://logo.clearbit.com/$finalStringCardType.com';
      print('https://logo.clearbit.com/$cardTypeName.com');

      try {
        final response = await http.get(Uri.parse(logoUrl));
        if (response.statusCode == 200) {
          setState(() {
            cardLogo = logoUrl;
          });
        } else {
          setState(() {
            cardLogo = '';
          });
        }
      } catch (e) {
        print('Error fetching logo: $e');
        setState(() {
          cardLogo = '';
        });
      }
    } else {
      setState(() {
        cardLogo = '';
      });
    }
  }

  bool isValidLuhn(String number) {
    int sum = 0;
    bool alternate = false;

    for (int i = number.length - 1; i >= 0; i--) {
      int n = int.parse(number[i]);

      if (alternate) {
        n *= 2;
        if (n > 9) {
          n -= 9;
        }
      }

      sum += n;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  void _validateInput() {
    setState(() {
      String input = cardNumberController.text.trim();
      if (input.isEmpty) {
        carderrorMessage = 'This field cannot be empty';
      } else if (!isValidLuhn(input)) {
        carderrorMessage = 'Invalid card number';
      } else {
        carderrorMessage = '';
      }
    });
  }

  String? formattedThreeMonthsFromNow;
  String? expiringPlanDate;
  Future<void> calculateDateOfExpire() async {
    DateTime today = DateTime.now();

    // Format the current date
    String formattedToday = DateFormat('dd MMMM yyyy').format(today);
    DateTime? threeMonthsFromNow;
    // Calculate the date three months from now
    if (widget.plan.planName == 'Golden Plan') {
      threeMonthsFromNow = DateTime(today.year, today.month + 1, today.day);
    } else if (widget.plan.planName == 'Premium Plan') {
      threeMonthsFromNow = DateTime(today.year, today.month + 3, today.day);
    } else if (widget.plan.planName == 'Silver Plan') {
      threeMonthsFromNow = DateTime(today.year, today.month + 3, today.day);
    }

    // Format the date three months from now
    formattedThreeMonthsFromNow =
        DateFormat('dd MMMM yyyy').format(threeMonthsFromNow!);
    expiringPlanDate = DateFormat('yyyy-MM-dd').format(threeMonthsFromNow!);

    print(formattedToday); // Print today's date
    print(formattedThreeMonthsFromNow); // Print date three months from now

    // You can set these values to state variables if needed
    setState(() {
      planStartDate = formattedToday;
      planExpireDate = formattedThreeMonthsFromNow;
    });
  }

  Future<void> fetchCountries() async {
    final response = await http
        .get(Uri.parse('https://restcountries.com/v3.1/all?fields=name'));
    final List<dynamic> data = jsonDecode(response.body);
    setState(() {
      countries = data
          .map((country) => country['name']['common'])
          .toList()
          .cast<String>();
      countries.sort(); // Sort countries alphabetically
      if (countries.isNotEmpty) {
        selectedCountry = countries[0];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: widget_302.App_Bar(context: context),
        backgroundColor: Colors.white,
        drawer: Drawer(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Image.asset("assets/images/logo.png"),
                ),
                const SizedBox(height: 40),
                buildListTile(
                    context,
                    const Icon(
                      CupertinoIcons.circle_grid_3x3,
                      color: Colors.white,
                    ),
                    "Dashboard",
                    true),
                buildListTile(
                    context,
                    const Icon(
                      CupertinoIcons.house,
                      color: Colors.black,
                    ),
                    "Add Property Type",
                    false),
                buildListTile(
                    context,
                    const Icon(
                      CupertinoIcons.person_add,
                      color: Colors.black,
                    ),
                    "Add Staff Member",
                    false),
                buildDropdownListTile(
                    context,
                    const FaIcon(
                      FontAwesomeIcons.key,
                      size: 20,
                      color: Colors.black,
                    ),
                    "Rental",
                    ["Properties", "RentalOwner", "Tenants"]),
                buildDropdownListTile(
                    context,
                    const FaIcon(
                      FontAwesomeIcons.thumbsUp,
                      size: 20,
                      color: Colors.black,
                    ),
                    "Leasing",
                    ["Rent Roll", "Applicants"]),
                buildDropdownListTile(
                    context,
                    Image.asset("assets/icons/maintence.png",
                        height: 20, width: 20),
                    "Maintenance",
                    ["Vendor", "Work Order"]),
              ],
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(children: [
            const SizedBox(
              height: 16,
            ),
            titleBar(
              title: 'Preminum Plans',
              width: MediaQuery.of(context).size.width * .91,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Text(
                          "1. Enter the company Address",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color.fromRGBO(21, 43, 81, 1)),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    const Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Enter the company's headquarter to ensure accurate tax information",
                            style: TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    Text(
                      "Street Address 1 * ${widget.plan.planName}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      hintText: 'Enter street address 1',
                      controller: streetaddress1,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Street address 1 is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    // const Text(
                    //   "Street Address 2 *",
                    //   style: TextStyle(
                    //       fontWeight: FontWeight.bold,
                    //       color: Color.fromRGBO(21, 43, 81, 1)),
                    // ),
                    // const SizedBox(
                    //   height: 10,
                    // ),
                    // CustomTextField(
                    //   hintText: 'Enter street address 2',
                    //   controller: streetaddress2,
                    //   validator: (value) {
                    //     if (value == null || value.isEmpty) {
                    //       return 'Street address 2 is required';
                    //     }
                    //     return null;
                    //   },
                    // ),
                    // SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    const Text(
                      "City *",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      hintText: 'Enter city',
                      controller: city,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'City is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    const Text(
                      "State *",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      hintText: 'Enter state',
                      controller: state,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'State is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    const Text(
                      "Postal Code *",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomTextField(
                      keyboardType: TextInputType.number,
                      hintText: 'Enter postal code',
                      controller: postalcode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Postal code is required';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    const Text(
                      "Country *",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(21, 43, 81, 1)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 40,
                                width: 285,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Center(
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      value: selectedCountry,
                                      hint: const Text('Select a country'),
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedCountry = newValue!;
                                          yearerror = false;
                                        });
                                      },
                                      items: countries
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                              if (yearerror)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    yearmessage,
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              .02,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * .099,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Form is valid
                          setState(() {
                            isShowStep2Details = true;
                          });
                        } else {
                          isShowStep2Details = false;
                        }
                      },
                      style:
                          ElevatedButton.styleFrom(backgroundColor: blueColor),
                      child: const Text('Continue'),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    if (isShowStep2Details)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              // SizedBox(
                              //   width:
                              //       MediaQuery.of(context).size.width * .099,
                              // ),
                              Expanded(
                                child: Text(
                                  "2.Review the subscription and enter the payment information",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(21, 43, 81, 1),
                                  ),
                                ),
                              ),
                              // SizedBox(
                              //   width:
                              //       MediaQuery.of(context).size.width * .099,
                              // ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          Container(
                            // margin: EdgeInsets.all(16.0),
                            padding: const EdgeInsets.all(8.0),
                            // height:
                            //     MediaQuery.of(context).size.height * .24,
                            width: MediaQuery.of(context).size.width * .99,
                            decoration: BoxDecoration(
                              border: Border.all(color: blueColor),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                const Row(
                                  children: [
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      "Subtotal",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(21, 43, 81, 1),
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: Divider(
                                    // Add Divider widget here
                                    color: Colors.grey,
                                    thickness: 1,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        "Plan Price:",
                                        style: TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                      Text(
                                        "${widget.plan.planPrice}",
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${widget.plan.billingInterval} - Annual Subscription % Discount",
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                      Text(
                                        "${widget.plan.annualDiscount ?? '0'}",
                                        style: const TextStyle(
                                            color: Colors.grey,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      "Plan - ${planStartDate} to ${planExpireDate}",
                                      style: const TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 12,
                                    ),
                                    const Text(
                                      "Total:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(21, 43, 81, 1),
                                          fontSize: 13),
                                    ),
                                    const Spacer(),
                                    Text(
                                      "\$${widget.plan.planPrice}",
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(21, 43, 81, 1),
                                          fontSize: 13),
                                    ),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          Container(
                            // margin: EdgeInsets.all(16.0),
                            padding: const EdgeInsets.all(8.0),
                            // height:
                            //     MediaQuery.of(context).size.height * .24,
                            width: MediaQuery.of(context).size.width * .99,
                            decoration: BoxDecoration(
                              border: Border.all(color: blueColor),
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                const Row(
                                  children: [
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Text(
                                      "Payment information",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color.fromRGBO(21, 43, 81, 1),
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  child: Divider(
                                    // Add Divider widget here
                                    color: Colors.grey,
                                    thickness: 1,
                                    height: 1,
                                  ),
                                ),
                                Form(
                                  key: _PayMentformKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: const Text(
                                          "Card Number",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Material(
                                                    elevation: 2,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8.0),
                                                    child: Container(
                                                      height: 50,
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 16.0,
                                                              vertical: 0),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8.0),
                                                        //border: Border.all(color: blueColor),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.2),
                                                            offset:
                                                                Offset(4, 4),
                                                            blurRadius: 3,
                                                          ),
                                                        ],
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          Positioned.fill(
                                                            child: TextField(
                                                              keyboardType:
                                                                  TextInputType
                                                                      .number,
                                                              decoration:
                                                                  InputDecoration(
                                                                hintStyle: TextStyle(
                                                                    fontSize:
                                                                        13,
                                                                    color: Color(
                                                                        0xFFb0b6c3)),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                                hintText:
                                                                    "Enter number...*",
                                                              ),
                                                              onChanged:
                                                                  (value) {
                                                                _validateInput();
                                                                setCardNumber(
                                                                    value);
                                                              },
                                                              controller:
                                                                  cardNumberController,
                                                              cursorColor:
                                                                  const Color
                                                                      .fromRGBO(
                                                                      21,
                                                                      43,
                                                                      81,
                                                                      1),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Container(
                                                  height: 40,
                                                  width: 40,
                                                  child: cardLogo != null &&
                                                          cardLogo!.isNotEmpty
                                                      ? Image.network(
                                                          cardLogo!,
                                                          height: 35,
                                                          errorBuilder:
                                                              (context, error,
                                                                  stackTrace) {
                                                            return Container();
                                                          },
                                                        )
                                                      : Container(),
                                                ),
                                              ],
                                            ),
                                            carderrorMessage != null
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      carderrorMessage!,
                                                      style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.04),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: const Text(
                                          "CVV",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CustomTextField(
                                          keyboardType: TextInputType.number,
                                          hintText: 'Enter CVV',
                                          controller: cVV,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'CVV required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: const Text(
                                          "Cardholder Name",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CustomTextField(
                                          hintText: 'Enter Cardholder Name',
                                          controller: cardHolderName,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Cardholder Name 1 is required';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: const Text(
                                          "Expiration Month",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CustomDropdown(
                                          items: expiringMonth,
                                          labelText: 'Month',
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedExpiringMonth = value;
                                            });
                                          },
                                          selectedValue: _selectedExpiringMonth,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please select a month';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: const Text(
                                          "Expiration Year",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CustomDropdown(
                                          items: expiringYear,
                                          labelText: 'Year',
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedExpiringYear = value;
                                            });
                                          },
                                          selectedValue: _selectedExpiringYear,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please select a year';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (_PayMentformKey.currentState!.validate()) {
                                print(widget.plan.planId);
                                print(cardNumberController.text);
                                print(
                                    '${_selectedExpiringMonth}/${_selectedExpiringYear}');
                                print(cardHolderName.text);

                                print(streetaddress1.text);
                                print(city.text);
                                print(state.text);
                                print(postalcode.text);

                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? adminId = prefs.getString("adminId");
                                String? firstName =
                                    prefs.getString('first_name');
                                String? lastName = prefs.getString('last_name');
                                // String? firstName =
                                //     prefs.getString('first_name');
                                String? email = prefs.getString('email');
                                String? superadmin_id = prefs.getString('superadminId');

                                customAddSubscriptionModel
                                    customaddSubscription =
                                    customAddSubscriptionModel(
                                  adminId: superadmin_id,
                                  planId: widget.plan.planId,
                                  ccnumber: cardNumberController.text,
                                  ccexp:
                                      "${_selectedExpiringMonth}/${_selectedExpiringYear} ",
                                  firstName: firstName,
                                  lastName: lastName,
                                  address: streetaddress1.text,
                                  email: email,
                                  city: city.text,
                                  state: state.text,
                                  zip: postalcode.text,
                                );

                                DateTime now = DateTime.now();
                                String currentDate =
                                    DateFormat('yyyy-MM-dd').format(now);

                                CustomAddSubscriptionService service =
                                    CustomAddSubscriptionService();
                                setState(() {
                                  isLoading = true;
                                });
                                CustomAddSubscriptionResponse? response =
                                    await service.postCustomAddSubscription(
                                        customaddSubscription);

                                String subscriptionId =
                                    response!.subscriptionId!;
                                String responseCode = response.responseCode!;
                                print('subscriptionId $subscriptionId');

                                purchaseFormModel purchaseformmodel =
                                    purchaseFormModel(
                                  adminId: adminId,
                                  planId: widget.plan.planId,
                                  planAmount: widget.plan.planPrice.toString(),
                                  purchaseDate: currentDate,
                                  expirationDate: expiringPlanDate,
                                  planDurationMonths:
                                      widget.plan.billingInterval,
                                  status: '',
                                  address: streetaddress1.text,
                                  city: city.text,
                                  state: state.text,
                                  postalCode: postalcode.text,
                                  country: selectedCountry,
                                  cardType: finalStringCardType,
                                  cardNumber: cardNumberController.text,
                                  cvv: cVV.text,
                                  cardholderName: cardHolderName.text,
                                  isActive: true,
                                  dayOfMonth: widget.plan.dayOfMonth.toString(),
                                  billingInterval: widget.plan.billingInterval,
                                  subscriptionId: subscriptionId,
                                );

                                print(
                                    'json oooohhhhh :${jsonEncode(purchaseformmodel.toJson())}');

                                purchaseFormService purchaseService =
                                    purchaseFormService();
                                int? purchaseResponse = await purchaseService
                                    .postPurchaseForm(purchaseformmodel);
                                if (purchaseResponse == 200) {
                                  Fluttertoast.showToast(
                                      msg: 'Plan Purchase Successfully');
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (!mounted) return;

                                  await Provider.of<checkPlanPurchaseProiver>(
                                          context,
                                          listen: false)
                                      .fetchPlanPurchaseDetail();

                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Dashboard()),
                                  );
                                } else {
                                  Fluttertoast.showToast(
                                      msg:
                                          'failed to purachase $purchaseResponse');
                                  setState(() {
                                    isLoading = false;
                                  });
                                }
                              } else {}
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: blueColor),
                            child: isLoading
                                ? SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 15.0,
                                  )
                                : Text('Submit'),
                          ),
                        ],
                      )
                  ],
                ),
              ),
            ),
          ]),
        ));
  }
}
