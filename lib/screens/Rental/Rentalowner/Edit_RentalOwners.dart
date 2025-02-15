import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/constant/constant.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:http/http.dart' as http;
import '../../../Model/RentalOwnersData.dart';
import '../../../model/rentalOwner.dart';
import '../../../model/rentalowners_summery.dart';
import '../../../repository/Rental_ownersData.dart';
import '../../../repository/Staffmember.dart';
import '../../../widgets/drawer_tiles.dart';
import '../../../widgets/custom_drawer.dart';

class Edit_rentalowners extends StatefulWidget {
  RentalOwnerData rentalOwner;
  Edit_rentalowners({super.key, required this.rentalOwner});

  @override
  State<Edit_rentalowners> createState() => _Edit_rentalownersState();
}

class _Edit_rentalownersState extends State<Edit_rentalowners> {
  TextEditingController name = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController comname = TextEditingController();
  TextEditingController primaryemail = TextEditingController();
  TextEditingController alternativeemail = TextEditingController();
  TextEditingController phonenum = TextEditingController();
  TextEditingController homenum = TextEditingController();
  TextEditingController officenum = TextEditingController();
  TextEditingController street2 = TextEditingController();
  TextEditingController city2 = TextEditingController();
  TextEditingController state2 = TextEditingController();
  TextEditingController county2 = TextEditingController();
  TextEditingController code2 = TextEditingController();
  TextEditingController proid = TextEditingController();
  TextEditingController taxtype = TextEditingController();
  TextEditingController taxid = TextEditingController();

  bool nameerror = false;
  bool lastnameerror = false;
  bool comnameerror = false;
  bool primaryemailerror = false;
  bool alternativeerror = false;
  bool phonenumerror = false;
  bool homenumerror = false;
  bool officenumerror = false;
  bool street2error = false;
  bool city2error = false;
  bool state2error = false;
  bool county2error = false;
  bool code2error = false;
  bool proiderror = false;
  bool taxtypeerror = false;
  bool taxiderror = false;

  String namemessage = "";
  String lastnamemessage = "";
  String comnamemessage = "";
  String primaryemailmessage = "";
  String alternativemessage = "";
  String phonenummessage = "";
  String homenummessage = "";
  String officenummessage = "";
  String street2message = "";
  String city2message = "";
  String state2message = "";
  String county2message = "";
  String code2message = "";
  String proidmessage = "";
  String taxtypemessage = "";
  String taxidmessage = "";

  bool isLoading = false;
  bool isloading = false;
  Map<int, TextEditingController> _controllers = {};

  String? initialName;
  String? initialCompanyName;
  String? initialPrimaryEmail;
  String? initialAlternativeEmail;
  String? initialPhoneNumber;
  String? initialHomeNumber;
  String? initialOfficeNumber;
  String? initialStreetAddress;
  String? initialCity;
  String? initialState;
  String? initialCountry;
  String? initialPostalCode;
  String? initialTaxId;
  String? initialTaxType;
  String? initialStartDate;
  String? initialEndDate;
  List<ProcessorList>? initialprocessorList;

  @override
  void initState() {
    super.initState();
    // Initialize with one text field
    _controllers[0] = TextEditingController();
    name.text = widget.rentalOwner.rentalOwnername!;
    comname.text = widget.rentalOwner.rentalOwnerCompanyName!;
    // comname.text = widget.rentalOwner.rentalOwnerCompanyName!;
    primaryemail.text = widget.rentalOwner.rentalOwnerPrimaryEmail!;
    alternativeemail.text = widget.rentalOwner.rentalOwnerAlternateEmail!;
    phonenum.text = formatPhoneNumberedit(widget.rentalOwner.rentalOwnerPhoneNumber!);
    homenum.text = formatPhoneNumberedit(widget.rentalOwner.rentalOwnerHomeNumber!);
    officenum.text = formatPhoneNumberedit(widget.rentalOwner.rentalOwnerBusinessNumber!);
    street2.text = widget.rentalOwner.streetAddress!;
    city2.text = widget.rentalOwner.city!;
    state2.text = widget.rentalOwner.state!;
    county2.text = widget.rentalOwner.country!;
    code2.text = widget.rentalOwner.postalCode!;
    //proid.text = widget.rentalOwner.processorLists.toString();
    taxtype.text = widget.rentalOwner.textIdentityType!;
    taxid.text = widget.rentalOwner.texpayerId!;
    //birthdateController.text = widget.rentalOwner.b;
    startdateController.text =formatDate( widget.rentalOwner.startDate!);
    enddateController.text =formatDate( widget.rentalOwner.endDate!);

    if (widget.rentalOwner.processorList != null) {
      for (int i = 0; i < widget.rentalOwner.processorList!.length; i++) {
        _controllers[i] = TextEditingController(
          text: widget.rentalOwner.processorList![i].processorId,
        );
      }
    } else {
      _controllers[0] = TextEditingController();
    }
    initialName = widget.rentalOwner.rentalOwnername;
    initialCompanyName = widget.rentalOwner.rentalOwnerCompanyName;
    initialPrimaryEmail = widget.rentalOwner.rentalOwnerPrimaryEmail;
    initialAlternativeEmail = widget.rentalOwner.rentalOwnerAlternateEmail;
    initialPhoneNumber = widget.rentalOwner.rentalOwnerPhoneNumber;
    initialHomeNumber = widget.rentalOwner.rentalOwnerHomeNumber;
    initialOfficeNumber = widget.rentalOwner.rentalOwnerBusinessNumber;
    initialStreetAddress = widget.rentalOwner.streetAddress;
    initialCity = widget.rentalOwner.city;
    initialState = widget.rentalOwner.state;
    initialCountry = widget.rentalOwner.country;
    initialPostalCode = widget.rentalOwner.postalCode;
    initialTaxId = widget.rentalOwner.texpayerId;
    initialTaxType = widget.rentalOwner.textIdentityType;
    initialStartDate = formatDate( widget.rentalOwner.startDate!);
    initialEndDate = formatDate( widget.rentalOwner.endDate!);

    fetchPaymentSettings();
  }

  // Add a text field
  void _addTextField() {
    int nextIndex = _controllers.length;
    setState(() {
      _controllers[nextIndex] = TextEditingController();
    });
  }

  // Remove a text field
  void _removeTextField(int index) {
    setState(() {
      _controllers.remove(index);
    });
  }

  //TextEditingController birthdateController = TextEditingController();
  TextEditingController startdateController = TextEditingController();
  TextEditingController enddateController = TextEditingController();

  // bool birthdateerror = false;
  bool startdatederror = false;
  bool enddatederror = false;

  //String birthdatemessage = "";
  String startdatemessage = "";
  String enddatemessage = "";

  //DateTime? birthdate;
  DateTime? startdate;
  DateTime? enddate;

  Future<void> _startDate(BuildContext context) async {


    DateTime initialDate = startdateController.text.isNotEmpty
        ? DateFormat('dd-MM-yyyy').parse(startdateController.text)
        : DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
    //  initialDate: startdate ?? DateTime.now(),
      firstDate:  DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor:
                 blueColor, // Header background color
            // accentColor: Colors.white, // Button text color
            colorScheme:  ColorScheme.light(
              primary: blueColor, // Selection color
              onPrimary: Colors.white, // Text color
              surface: Colors.white, // Calendar background color
              onSurface: Colors.black, // Calendar text color
            ),
            dialogBackgroundColor: Colors.white, // Background color
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != startdate) {
      setState(() {
        startdate = picked;
        // startdateController.text = DateFormat('yyyy-MM-dd').format(picked);
        startdateController.text = DateFormat('dd-MM-yyyy').format(picked);
        // Use this format (yyyy-MM-dd) when passing it to your API or saving it
        String dateForApi = DateFormat('yyyy-MM-dd').format(picked);
        print(dateForApi);
      });
    }
  }

  // Future<void> _endDate(BuildContext context) async {
  //   // DateTime initialEndDate = enddateController.text.isNotEmpty
  //   //     ? DateFormat('dd-MM-yyyy').parse(enddateController.text)
  //   //     : DateTime.now();
  //   // if (initialEndDate.isBefore(startdate ?? DateTime.now())) {
  //   //   initialEndDate = startdate ?? DateTime.now();  // Use start date if end date is invalid
  //   // }
  //   DateTime initialEndDate;
  //   try {
  //     initialEndDate = enddateController.text.isNotEmpty
  //         ? DateFormat('dd-MM-yyyy').parse(enddateController.text)
  //         : DateTime.now();
  //   } catch (e) {
  //     // In case of parsing failure, fallback to DateTime.now()
  //     initialEndDate = DateTime.now();
  //   }
  //
  //   // Ensure initialStartDate is after the firstDate constraint
  //   if (initialEndDate.isBefore(DateTime(2015, 8, 1))) {
  //     initialEndDate = DateTime(2015, 8, 1);  // Set to the minimum allowed date
  //   }
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: initialEndDate,
  //     //initialDate: enddate ?? DateTime.now(),
  //     firstDate: startdate ?? DateTime.now(),
  //     // firstDate: DateTime(2015, 8),
  //     lastDate: DateTime(2101),
  //     builder: (BuildContext context, Widget? child) {
  //       return Theme(
  //         data: ThemeData.light().copyWith(
  //           primaryColor:
  //                blueColor, // Header background color
  //           // accentColor: Colors.white, // Button text color
  //           colorScheme:  ColorScheme.light(
  //             primary: blueColor, // Selection color
  //             onPrimary: Colors.white, // Text color
  //             surface: Colors.white, // Calendar background color
  //             onSurface: Colors.black, // Calendar text color
  //           ),
  //           dialogBackgroundColor: Colors.white, // Background color
  //         ),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null && picked != enddate) {
  //     setState(() {
  //       enddate = picked;
  //       //birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
  //       //startdateController.text = DateFormat('yyyy-MM-dd').format(picked);
  //       enddateController.text = DateFormat('dd-MM-yyyy').format(picked);
  //     });
  //   }
  // }
  Future<void> _endDate(BuildContext context) async {


    DateTime initialDate = startdateController.text.isNotEmpty
        ? DateFormat('dd-MM-yyyy').parse(startdateController.text)
        : DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: initialDate, // Dynamically set based on startdate
      //firstDate: DateTime(2015, 8), // Dynamically set based on startdate
      lastDate: DateTime(2101), // Far future date as upper limit
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: blueColor, // Header background color
            colorScheme: ColorScheme.light(
              primary: blueColor, // Selection color
              onPrimary: Colors.white, // Text color
              surface: Colors.white, // Calendar background color
              onSurface: Colors.black, // Calendar text color
            ),
            dialogBackgroundColor: Colors.white, // Background color
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != enddate) {
      setState(() {
        enddate = picked;
        enddateController.text = DateFormat('dd-MM-yyyy').format(picked);
        String dateForApi = DateFormat('yyyy-MM-dd').format(picked);
        print(dateForApi); // For API usage
      });
    }
  }


  final FocusNode _nodeText1 = FocusNode();
  final FocusNode _nodeText2 = FocusNode();
  final FocusNode _nodeText3 = FocusNode();
  final FocusNode _nodeText4 = FocusNode();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      keyboardBarColor: Colors.grey[200],
      nextFocus: true,
      actions: [
        KeyboardActionsItem(
          focusNode: _nodeText1,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText2,
          //  displayCloseWidget: false,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText3,
        ),
        KeyboardActionsItem(
          focusNode: _nodeText4,
        ),
      ],
    );
  }

  //for card payment

  bool creditcard = false;
  bool debitcard = false;

  Future<void> fetchPaymentSettings() async {
    print("calling");
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    String? token = prefs.getString('token');
    final response = await http.get(
      Uri.parse('${Api_url}/api/payment/rental_owner/setting/${widget.rentalOwner.rentalownerId}'),
      headers: {
        "authorization": "CRM $token",
        "id": "CRM $id",
      },
    );
    final jsonData = json.decode(response.body);
    print(' rental added ${jsonData}');
    if (jsonData["statusCode"] == 200 || jsonData["statusCode"] == 201) {

      print(creditcard);
      print(creditcard);
      setState(() {
        creditcard = jsonData['data']['creditCardAccepted'];
        debitcard = jsonData['data']['debitCardAccepted'];
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  //for update payment

  Future<void> updatePaymentSettings() async {
    setState(() {
      isloading = true; // Show loading indicator
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    String?  id = prefs.getString('adminId');
    final url = '${Api_url}/api/payment/rental_owner/setting';
    final headers = {
      "authorization": "CRM $token",
      "id":"CRM $id",
      'Content-Type': 'application/json; charset=UTF-8',

    };
    final body = json.encode({
      "creditCardAccepted": creditcard,
      "debitCardAccepted": debitcard,
      "rentalOwnerId":widget.rentalOwner.rentalownerId,
    });

    try {
      final response = await http.post(Uri.parse(url), headers: headers, body: body);

      var responseData = json.decode(response.body);
     print('update card type ${responseData}');
     print('update card type ${response.body}');
      if (responseData["statusCode"] == 200) {
        Fluttertoast.showToast(msg: responseData["message"]);
        return json.decode(response.body);

      } else {
        Fluttertoast.showToast(msg: responseData["message"]);
        throw Exception('Failed to update card type');
      }
    } catch (error) {
      // Handle network error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $error')),
      );
    } finally {
      setState(() {
        isloading = false; // Hide loading indicator
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: CustomDrawer(
        currentpage: "RentalOwner",
        dropdown: true,
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: Container(
                height: 50.0,
                padding: EdgeInsets.only(top: 9, left: 10),
                width: MediaQuery.of(context).size.width * .91,
                margin: const EdgeInsets.only(bottom: 6.0),
                //Same as `blurRadius` i guess
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: blueColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Text(
                  "Edit Rental Owners ",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                ),
              ),
            ),
          ),
          //Personal information
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: blueColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Personal information",
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 20
                                        : 25),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      //first name
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Name",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              // borderRadius: BorderRadius.circular(8),
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  //color: Colors.white,
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            nameerror = false;
                                          });
                                        },
                                        controller: name,
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter first name",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 19,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: nameerror
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(
                                              MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 14
                                                  : 11),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      nameerror
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  namemessage,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      //company name
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Company Name",
                            style: TextStyle(
                                // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            comnameerror = false;
                                          });
                                        },
                                        controller: comname,
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter company name",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 19,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: comnameerror
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(
                                              MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 14
                                                  : 11),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      comnameerror
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  comnamemessage,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          //merchent id
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: blueColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Merchant Id",
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 20
                                        : 25),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Processor Id",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 1, right: 1),
                        child: Column(
                          children: [
                            Column(
                              children: _controllers.entries.map((entry) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Material(
                                          elevation: 3,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Color(0xFF8A95A8)),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: TextField(
                                                    controller: entry.value,
                                                    cursorColor: blueColor


,
                                                    decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.only(
                                                              top: 12.5,
                                                              bottom: 12.5,
                                                              left: 15),
                                                      hintText:
                                                          "Enter processor",
                                                      hintStyle: TextStyle(
                                                        color:
                                                            Color(0xFF8A95A8),
                                                        fontSize: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 15
                                                            : 19,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .02),
                                   /*   InkWell(
                                        onTap: () {
                                          _removeTextField(entry.key);
                                        },
                                        child: Container(
                                          padding: EdgeInsets.zero,
                                          child: FaIcon(
                                            FontAwesomeIcons.trashCan,
                                            size: 20,
                                            color:
                                                blueColor,
                                          ),
                                        ),
                                      ),*/
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            /*Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    _addTextField();
                                  },
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: Container(
                                      height:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 35
                                              : 40,
                                      width: MediaQuery.of(context).size.width <
                                              500
                                          ? 120
                                          : 180,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        color: blueColor,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey,
                                            offset: Offset(0.0, 1.0), //(x,y)
                                            blurRadius: 6.0,
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Add another",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 13
                                                  : 20),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),*/
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          //management agreement
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: blueColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Management Agreement ",
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 20
                                        : 25),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      //start date
                      if (MediaQuery.of(context).size.width < 500)
                        Row(
                          children: [
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              "Start Date",
                              style: TextStyle(
                                  color: Color(0xFF8A95A8),
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 15
                                          : 20),
                            ),
                          ],
                        ),
                      if (MediaQuery.of(context).size.width < 500)
                        SizedBox(
                          height: 5,
                        ),
                      if (MediaQuery.of(context).size.width < 500)
                        Row(
                          children: [
                            SizedBox(width: 2),
                            Expanded(
                              child: Material(
                                elevation: 4,
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width * .6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: Color(0xFF8A95A8),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: TextField(
                                          onChanged: (value) {
                                            setState(() {
                                              startdatederror = false;
                                              // _selectDate(context);
                                            });
                                          },
                                          controller: startdateController,
                                          cursorColor:
                                              blueColor,
                                          decoration: InputDecoration(
                                            hintText: "dd - mm - yyyy",
                                            hintStyle: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 15
                                                  : 18,
                                              color: Color(0xFF8A95A8),
                                            ),
                                            enabledBorder: startdatederror
                                                ? OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
                                                    borderSide: BorderSide(
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                : InputBorder.none,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(12),
                                            suffixIcon: IconButton(
                                              icon: Icon(Icons.calendar_today),
                                              onPressed: () {
                                                _startDate(context);
                                                setState(() {
                                                  startdatederror = false;
                                                });
                                              },
                                            ),
                                          ),
                                          readOnly: true,
                                          onTap: () {
                                            _startDate(context);
                                            setState(() {
                                              startdatederror = false;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 2),
                          ],
                        ),
                      if (MediaQuery.of(context).size.width < 500)
                        startdatederror
                            ? Row(
                                children: [
                                  Spacer(),
                                  Text(
                                    startdatemessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .035),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                ],
                              )
                            : Container(),
                      if (MediaQuery.of(context).size.width < 500)
                        SizedBox(
                          height: 10,
                        ),
                      //enddate
                      if (MediaQuery.of(context).size.width < 500)
                        Row(
                          children: [
                            SizedBox(
                              width: 3,
                            ),
                            Text(
                              "End Date",
                              style: TextStyle(
                                  // color: Colors.grey,
                                  color: Color(0xFF8A95A8),
                                  fontWeight: FontWeight.bold,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 500
                                          ? 15
                                          : 20),
                            ),
                          ],
                        ),
                      if (MediaQuery.of(context).size.width < 500)
                        SizedBox(
                          height: 5,
                        ),
                      if (MediaQuery.of(context).size.width < 500)
                        Row(
                          children: [
                            SizedBox(width: 2),
                            Expanded(
                              child: Material(
                                elevation: 4,
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width * .6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(2),
                                    border: Border.all(
                                      color: Color(0xFF8A95A8),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: TextField(
                                          onChanged: (value) {
                                            setState(() {
                                              enddatederror = false;
                                              // _selectDate(context);
                                            });
                                          },
                                          controller: enddateController,
                                          cursorColor:
                                              blueColor,
                                          decoration: InputDecoration(
                                            hintText: "dd - mm - yyyy",
                                            hintStyle: TextStyle(
                                              fontSize: MediaQuery.of(context)
                                                          .size
                                                          .width <
                                                      500
                                                  ? 15
                                                  : 18,
                                              color: Color(0xFF8A95A8),
                                            ),
                                            enabledBorder: enddatederror
                                                ? OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
                                                    borderSide: BorderSide(
                                                      color: Colors.red,
                                                    ),
                                                  )
                                                : InputBorder.none,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(12),
                                            suffixIcon: IconButton(
                                              icon: Icon(Icons.calendar_today),
                                              onPressed: () =>
                                                  _endDate(context),
                                            ),
                                          ),
                                          readOnly: true,
                                          onTap: () {
                                            _endDate(context);
                                            setState(() {
                                              enddatederror = false;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 2),
                          ],
                        ),
                      if (MediaQuery.of(context).size.width < 500)
                        enddatederror
                            ? Row(
                                children: [
                                  Spacer(),
                                  Text(
                                    enddatemessage,
                                    style: TextStyle(
                                        color: Colors.red,
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    500
                                                ? 15
                                                : 19),
                                  ),
                                  SizedBox(
                                    width: 2,
                                  ),
                                ],
                              )
                            : Container(),

                      if (MediaQuery.of(context).size.width > 500)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // First Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Start Date",
                                      style: TextStyle(
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 15
                                              : 20),
                                    ),
                                    SizedBox(height: 5),
                                    Material(
                                      elevation: 4,
                                      child: Container(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .6,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          border: Border.all(
                                            color: Color(0xFF8A95A8),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: TextField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    startdatederror = false;
                                                    // _selectDate(context);
                                                  });
                                                },
                                                controller: startdateController,
                                                cursorColor: blueColor


,
                                                decoration: InputDecoration(
                                                  hintText: "dd - mm - yyyy",
                                                  hintStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 15
                                                            : 18,
                                                    color: Color(0xFF8A95A8),
                                                  ),
                                                  enabledBorder: startdatederror
                                                      ? OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors.red,
                                                          ),
                                                        )
                                                      : InputBorder.none,
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.all(12),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                        Icons.calendar_today),
                                                    onPressed: () {
                                                      _startDate(context);
                                                      setState(() {
                                                        startdatederror = false;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                readOnly: true,
                                                onTap: () {
                                                  _startDate(context);
                                                  setState(() {
                                                    startdatederror = false;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    startdatederror
                                        ? Row(
                                            children: [
                                              Spacer(),
                                              Text(
                                                startdatemessage,
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 15
                                                            : 19),
                                              ),
                                              SizedBox(
                                                width: 2,
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              // Second Column
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "End Date",
                                      style: TextStyle(
                                          // color: Colors.grey,
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: MediaQuery.of(context)
                                                      .size
                                                      .width <
                                                  500
                                              ? 15
                                              : 20),
                                    ),
                                    SizedBox(height: 5),
                                    Material(
                                      elevation: 4,
                                      child: Container(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .6,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(2),
                                          border: Border.all(
                                            color: Color(0xFF8A95A8),
                                          ),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: TextField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    enddatederror = false;
                                                    // _selectDate(context);
                                                  });
                                                },
                                                controller: enddateController,
                                                cursorColor: blueColor


,
                                                decoration: InputDecoration(
                                                  hintText: "dd - mm - yyyy",
                                                  hintStyle: TextStyle(
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 15
                                                            : 18,
                                                    color: Color(0xFF8A95A8),
                                                  ),
                                                  enabledBorder: enddatederror
                                                      ? OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(3),
                                                          borderSide:
                                                              BorderSide(
                                                            color: Colors.red,
                                                          ),
                                                        )
                                                      : InputBorder.none,
                                                  border: InputBorder.none,
                                                  contentPadding:
                                                      EdgeInsets.all(12),
                                                  suffixIcon: IconButton(
                                                    icon: Icon(
                                                        Icons.calendar_today),
                                                    onPressed: () =>
                                                        _endDate(context),
                                                  ),
                                                ),
                                                readOnly: true,
                                                onTap: () {
                                                  _endDate(context);
                                                  setState(() {
                                                    enddatederror = false;
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 5),
                                    enddatederror
                                        ? Row(
                                            children: [
                                              Spacer(),
                                              Text(
                                                enddatemessage,
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize:
                                                        MediaQuery.of(context)
                                                                    .size
                                                                    .width <
                                                                500
                                                            ? 15
                                                            : 19),
                                              ),
                                              SizedBox(
                                                width: 2,
                                              ),
                                            ],
                                          )
                                        : Container(),
                                  ],
                                ),
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
          SizedBox(
            height: 10,
          ),
          //contact information
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: blueColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Contact information",
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 20
                                        : 25),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      //primary email
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Primary E-mail *",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            primaryemailerror = false;
                                          });
                                        },
                                        controller: primaryemail,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter primary e-mail",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 18,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: primaryemailerror
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      primaryemailerror
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  primaryemailmessage,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      //alternative email
                      Row(
                        children: [
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            "Alternative E-mail",
                            style: TextStyle(
                                // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            alternativeerror = false;
                                          });
                                        },
                                        controller: alternativeemail,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter alternative e-mail ",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 18,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: alternativeerror
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      alternativeerror
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  alternativemessage,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      //phonenumber
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Phone Number *",
                            style: TextStyle(
                                // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                          PhoneNumberFormatter(),
                                        ],
                                        focusNode: _nodeText1,
                                        onChanged: (value) {
                                          setState(() {
                                            phonenumerror = false;
                                          });
                                        },
                                        controller: phonenum,
                                        keyboardType: TextInputType.number,
                                        // keyboardType:
                                        //     TextInputType.numberWithOptions(
                                        //         signed: true, decimal: true),
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter phone number",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 18,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: phonenumerror
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      phonenumerror
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  phonenummessage,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      //homenumber
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Home Number",
                            style: TextStyle(
                                // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                          PhoneNumberFormatter(),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            homenumerror = false;
                                          });
                                        },
                                        controller: homenum,
                                        focusNode: _nodeText2,
                                        keyboardType: TextInputType.number,
                                        // keyboardType:
                                        //     TextInputType.numberWithOptions(
                                        //         signed: true, decimal: true),
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter home number",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 18,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: homenumerror
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      homenumerror
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  homenummessage,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      //office number
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Office Number",
                            style: TextStyle(
                                // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                          PhoneNumberFormatter(),
                                        ],
                                        focusNode: _nodeText3,
                                        onChanged: (value) {
                                          setState(() {
                                            officenumerror = false;
                                          });
                                        },
                                        controller: officenum,
                                        keyboardType: TextInputType.number,
                                        // keyboardType:
                                        //     TextInputType.numberWithOptions(
                                        //         signed: true, decimal: true),
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter office number",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 18,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: officenumerror
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      officenumerror
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  officenummessage,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      //street address
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Street Address",
                            style: TextStyle(
                                // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            street2error = false;
                                          });
                                        },
                                        controller: street2,
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter street address",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 18,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: street2error
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      street2error
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  street2message,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      //enter city
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "City",
                            style: TextStyle(
                                // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        keyboardType: TextInputType.text,
                                        onChanged: (value) {
                                          setState(() {
                                            city2error = false;
                                          });
                                        },
                                        controller: city2,
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter city",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 18,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: city2error
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      city2error
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  city2message,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      //emter state
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "State",
                            style: TextStyle(
                                // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        keyboardType: TextInputType.text,
                                        onChanged: (value) {
                                          setState(() {
                                            state2error = false;
                                          });
                                        },
                                        controller: state2,
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter state",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 18,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: state2error
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      state2error
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  state2message,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      //enter country
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Country",
                            style: TextStyle(
                                // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        keyboardType: TextInputType.text,
                                        onChanged: (value) {
                                          setState(() {
                                            county2error = false;
                                          });
                                        },
                                        controller: county2,
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter country",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 18,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: county2error
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      county2error
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  county2message,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      //postal code
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Zip Code",
                            style: TextStyle(
                                // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        focusNode: _nodeText4,
                                        onChanged: (value) {
                                          setState(() {
                                            code2error = false;
                                          });
                                        },
                                        keyboardType:
                                           TextInputType.text,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                                          TextInputFormatter.withFunction((oldValue, newValue) {
                                            return TextEditingValue(
                                              text: newValue.text.toUpperCase(),
                                              selection: newValue.selection,
                                            );
                                          }),
                                        ],
                                        controller: code2,
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter zip code",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 18,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: code2error
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      code2error
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  code2message,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          //tax payer information
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: blueColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Tax Payer Information ",
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 20
                                        : 25),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Tax Identify Type",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            taxtypeerror = false;
                                          });
                                        },
                                        controller: taxtype,
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter tax identify type",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 18,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: taxtypeerror
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      taxtypeerror
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  taxtypemessage,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 3,
                          ),
                          Text(
                            "Tax PayerId",
                            style: TextStyle(
                                // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    MediaQuery.of(context).size.width < 500
                                        ? 15
                                        : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          Expanded(
                            child: Material(
                              elevation: 4,
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width * .6,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2),
                                  border: Border.all(
                                    color: Color(0xFF8A95A8),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: TextField(
                                        onChanged: (value) {
                                          setState(() {
                                            taxiderror = false;
                                          });
                                        },
                                        controller: taxid,
                                        cursorColor:
                                            blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter SSN or EIN",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                        .size
                                                        .width <
                                                    500
                                                ? 15
                                                : 18,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: taxiderror
                                              ? OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                  borderSide: BorderSide(
                                                    color: Colors.red,
                                                  ),
                                                )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      taxiderror
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  taxidmessage,
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontSize:
                                          MediaQuery.of(context).size.width <
                                                  500
                                              ? 15
                                              : 19),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              if (MediaQuery.of(context).size.width < 500)
                SizedBox(width: MediaQuery.of(context).size.width * 0.063),
              if (MediaQuery.of(context).size.width > 500)
                SizedBox(
                  width: 25,
                ),
              GestureDetector(
                onTap: () async {
                  bool isFormValid = true;

                  // Validate each field and update the state accordingly
                  if (name.text.trim().isEmpty) {
                    setState(() {
                      nameerror = true;
                      namemessage = "required";
                      isFormValid = false;
                    });
                  } else {
                    setState(() {
                      nameerror = false;
                    });
                  }

                  if (comname.text.trim().isEmpty) {
                    setState(() {
                      comnameerror = true;
                      comnamemessage = "required";
                      isFormValid = false;
                    });
                  } else {
                    setState(() {
                      comnameerror = false;
                    });
                  }

                  if (primaryemail.text.trim().isEmpty) {
                    setState(() {
                      primaryemailerror = true;
                      primaryemailmessage = "required";
                      isFormValid = false;
                    });
                  } else if (!EmailValidator.validate(primaryemail.text)) {
                    setState(() {
                      primaryemailerror = true;
                      primaryemailmessage = "Email is not valid";
                      isFormValid = false;
                    });
                  } else {
                    setState(() {
                      primaryemailerror = false;
                    });
                  }
                  if (alternativeemail.text.trim().isNotEmpty) {
                    if (alternativeemail.text.trim() == primaryemail.text.trim()) {
                      setState(() {
                        alternativeerror = true;
                        alternativemessage = "Email cannot be the same";
                        isFormValid = false;
                      });
                    } else if (!EmailValidator.validate(alternativeemail.text.trim())) {
                      setState(() {
                        alternativeerror = true;
                        alternativemessage = "Email is not valid";
                        isFormValid = false;
                      });
                    } else {
                      setState(() {
                        alternativeerror = false;
                      });
                    }
                  }
                  String formattedPhoneNumber = phonenum.text.replaceAll(RegExp(r'\D'), '');
                  if (formattedPhoneNumber.isEmpty) {
                    setState(() {
                      isFormValid = false;
                      phonenumerror = true;
                      phonenummessage = "required";
                    });
                  } else if (formattedPhoneNumber.length != 10) {
                    setState(() {
                      isFormValid = false;
                      phonenumerror = true;
                      phonenummessage = "Phone number must be 10 digits";
                    });
                  }else {
                    setState(() {
                      phonenumerror = false;
                    });
                  }
                  String formattedhomeNumber = homenum.text.replaceAll(RegExp(r'\D'), '');
                  if (formattedhomeNumber.isEmpty) {
                    setState(() {
                      homenumerror = false;

                    });
                  }else if(formattedhomeNumber.length != 10){
                    setState(() {
                      isFormValid = false;
                      homenumerror = true;
                      homenummessage = "Phone number must be 10 digits";
                    });
                  } else if(formattedhomeNumber == formattedPhoneNumber){
                    setState(() {
                      isFormValid = false;
                      homenumerror = true;
                      homenummessage = " number cannot be the same";
                    });
                  }else {
                    setState(() {
                      homenumerror = false;
                    });
                  }
                  String formattedofficeNumber = officenum.text.replaceAll(RegExp(r'\D'), '');
                  if (formattedofficeNumber.isEmpty) {
                    setState(() {
                      officenumerror = false;
                    });
                  }else if(formattedofficeNumber.length != 10){
                    setState(() {
                      isFormValid = false;
                      officenumerror = true;
                      officenummessage = "Phone number must be 10 digits";
                    });
                  }else if(formattedofficeNumber == formattedhomeNumber){
                    setState(() {
                      isFormValid = false;
                      officenumerror = true;
                      officenummessage = " number cannot be the same";
                    });
                  } else {
                    setState(() {
                      officenumerror = false;
                    });
                  }

                  // Validate other fields similarly...
                  String? isProcessorListChanged =
                      widget.rentalOwner.processorList != null && widget.rentalOwner.processorList!.isNotEmpty ? widget.rentalOwner.processorList!.first.processorId:"";
                  print("Processor List Changed: $isProcessorListChanged");


                  // Check for changes
                  bool hasChanges = name.text != initialName ||
                      comname.text != initialCompanyName ||
                      primaryemail.text != initialPrimaryEmail ||
                      alternativeemail.text != initialAlternativeEmail ||
                      phonenum.text != initialPhoneNumber ||
                      homenum.text != initialHomeNumber ||
                      officenum.text != initialOfficeNumber ||
                      street2.text != initialStreetAddress ||
                      city2.text != initialCity ||
                      state2.text != initialState ||
                      county2.text != initialCountry ||
                      code2.text != initialPostalCode ||
                      taxid.text != initialTaxId ||
                      taxtype.text != initialTaxType ||
                      startdateController.text != initialStartDate ||
                      enddateController.text != initialEndDate || _controllers[0]!.text != isProcessorListChanged;

                  // controller.text = widget.processorid;
                  //
                  //
                  // if(!controller.text == widget.processorid)
                  if (!hasChanges) {
                    print("No changes made, API call not necessary.");
                    Navigator.of(context).pop(false); // Optionally navigate back
                    return;
                  }

                  if (!isFormValid) {
                    return; // Exit early if the form is not valid
                  }

                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  String? adminId = prefs.getString("adminId");

                  // Prepare the processor list
                  List<ProcessorList> processorList = [];
                  _controllers.forEach((key, controller) {
                    if (controller.text.trim().isNotEmpty) {
                      processorList.add(ProcessorList(processorId: controller.text));
                    }
                  });

                  try {
                    setState(() {
                      isLoading = true;
                    });
                    await RentalOwnerService().Edit_Rentalowners(
                      adminId: adminId,
                      rentalownerId: widget.rentalOwner.rentalownerId,
                      rentalOwnerName: name.text.trim(),
                      rentalOwnerCompanyName: comname.text.trim(),
                      rentalOwnerPrimaryEmail: primaryemail.text.trim(),
                      rentalOwnerAlternateEmail: alternativeemail.text.trim(),
                      rentalOwnerPhoneNumber: phonenum.text.trim(),
                      rentalOwnerHomeNumber: homenum.text.trim(),
                      rentalOwnerBusinessNumber: officenum.text.trim(),
                      startDate:reverseFormatDate(startdateController.text.trim()),
                      endDate: reverseFormatDate(enddateController.text.trim()),
                      texpayerId: taxid.text.trim(),
                      textIdentityType: taxtype.text.trim(),
                      city: city2.text.trim(),
                      state: state2.text.trim(),
                      streetAddress: street2.text.trim(),
                      country: county2.text.trim(),
                      postalCode: code2.text.trim(),
                      processorList: processorList,
                    );

                    setState(() {
                      widget.rentalOwner.rentalOwnername = name.text;
                      widget.rentalOwner.rentalOwnerCompanyName = comname.text;
                      widget.rentalOwner.rentalOwnerPrimaryEmail = primaryemail.text;
                      widget.rentalOwner.rentalOwnerAlternateEmail = alternativeemail.text;
                      widget.rentalOwner.rentalOwnerPhoneNumber = phonenum.text;
                      widget.rentalOwner.rentalOwnerHomeNumber = homenum.text;
                      widget.rentalOwner.rentalOwnerBusinessNumber = officenum.text;
                      widget.rentalOwner.startDate = startdateController.text;
                      widget.rentalOwner.endDate = enddateController.text;
                      widget.rentalOwner.texpayerId = taxid.text;
                      widget.rentalOwner.textIdentityType = taxtype.text;
                      widget.rentalOwner.city = city2.text;
                      widget.rentalOwner.state = state2.text;
                      widget.rentalOwner.streetAddress = street2.text;
                      widget.rentalOwner.country = county2.text;
                      widget.rentalOwner.postalCode = code2.text;
                      widget.rentalOwner.processorList = processorList;
                      isLoading = false;
                    });

                    Navigator.pop(context, true);
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    // Handle error
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * .045,
                    width: MediaQuery.of(context).size.width < 500 ? 160 : 190,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: blueColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: isLoading ?SpinKitFadingCircle(
                        color: Colors.white,
                        size: 20.0,
                      ):  Text(
                          "Edit  Rental Owner",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width < 500
                                ? 15
                                : 20),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text("Cancel")),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          //card transaction type
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: blueColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Card Transaction Type \nManagement ",
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                MediaQuery.of(context).size.width < 500
                                    ? 20
                                    : 25),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Select the type of card you wish to \naccept",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width < 500
                                    ? 15
                                    : 20),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Container(

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(value: creditcard, onChanged: (value) {
                                setState(() {

                                  creditcard = value!;
                                });
                              },activeColor: blueColor,),
                            ),
                            SizedBox(width: 10),
                            Text("Credit Card",style: TextStyle(
                                fontSize: 16,
                              color: blueColor,
                                fontWeight: FontWeight.bold
                            ),)

                          ],
                        ),
                      ),
                      Container(

                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(value: debitcard, onChanged: (value) {
                                setState(() {
                                  debitcard = value!;
                                });
                              },activeColor: blueColor),
                            ),
                            SizedBox(width: 10),
                            Text("Debit Card",style: TextStyle(
                                fontSize: 16,
                              color: blueColor,
                              fontWeight: FontWeight.bold,
                            ),)

                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              updatePaymentSettings();
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height: MediaQuery.of(context).size.height * .045,
                                width: MediaQuery.of(context).size.width < 500 ? 120 : 190,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: blueColor,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 6.0,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: isloading ?SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 20.0,
                                  ):  Text(
                                    "Update",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width < 500
                                            ? 15
                                            : 20),
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
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  reload_Screen() {
    setState(() {});
  }
}
