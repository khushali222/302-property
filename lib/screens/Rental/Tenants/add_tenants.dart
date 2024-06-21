import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../../widgets/drawer_tiles.dart';

class Add_Tenants extends StatefulWidget {
  const Add_Tenants({super.key});

  @override
  State<Add_Tenants> createState() => _Add_TenantsState();
}

class _Add_TenantsState extends State<Add_Tenants> {

  TextEditingController firstname = TextEditingController();
  TextEditingController lastname = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController primaryemail = TextEditingController();
  TextEditingController alternativeemail = TextEditingController();
  TextEditingController phonenum = TextEditingController();
  TextEditingController worknum = TextEditingController();
  TextEditingController contactname = TextEditingController();
  TextEditingController tenant = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController phonenum2 = TextEditingController();
  TextEditingController taxid = TextEditingController();
  TextEditingController birthdateController = TextEditingController();

  bool firstnameerror = false;
  bool lastnameerror = false;
  bool passworderror = false;
  bool primaryemailerror = false;
  bool alternativeerror = false;
  bool phonenumerror = false;
  bool workerror = false;
  bool contactnameerror = false;
  bool tenanterror = false;
  bool emailerror = false;
  bool county2error = false;
  bool code2error = false;
  bool proiderror = false;
  bool taxtypeerror = false;
  bool taxiderror = false;
  bool birthdateerror = false;

  String firstnamemessage = "";
  String lastnamemessage = "";
  String comnamemessage = "";
  String primaryemailmessage = "";
  String alternativemessage = "";
  String phonenummessage = "";
  String homenummessage = "";
  String businessnummessage = "";
  String officenummessage = "";
  String street2message = "";
  String city2message = "";
  String state2message = "";
  String county2message = "";
  String code2message = "";
  String proidmessage = "";
  String taxtypemessage = "";
  String taxidmessage = "";
  String birthdatemessage = "";

  bool loading = false;
  Map<int, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize with one text field
    _controllers[0] = TextEditingController();
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

  DateTime? birthdate;


  Future<void> _birthDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthdate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color.fromRGBO(21, 43, 83, 1), // Header background color
            // accentColor: Colors.white, // Button text color
            colorScheme: ColorScheme.light(
              primary: Color.fromRGBO(21, 43, 83, 1), // Selection color
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
    if (picked != null && picked != birthdate) {
      setState(() {
        birthdate = picked;
        birthdateController.text = DateFormat('yyyy-MM-dd').format(picked);
        //startdateController.text = DateFormat('yyyy-MM-dd').format(picked);
        //enddateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: widget302.,
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer: Drawer(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset("assets/images/logo.png"),
              ),
              SizedBox(height: 40),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.circle_grid_3x3,
                    color: Colors.black,
                  ),
                  "Dashboard",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.house,
                    color: Colors.black,
                  ),
                  "Add Property Type",
                  false),
              buildListTile(
                  context,
                  Icon(
                    CupertinoIcons.person_add,
                    color: Colors.black,
                  ),
                  "Add Staff Member",
                  false),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.key,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Rental",
                  ["Properties", "RentalOwner", "Tenants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  FaIcon(
                    FontAwesomeIcons.thumbsUp,
                    size: 20,
                    color: Colors.black,
                  ),
                  "Leasing",
                  ["Rent Roll", "Applicants"],
                  selectedSubtopic: "Properties"),
              buildDropdownListTile(
                  context,
                  Image.asset("assets/icons/maintence.png",
                      height: 20, width: 20),
                  "Maintenance",
                  ["Vendor", "Work Order"],
                  selectedSubtopic: "Properties"),
            ],
          ),
        ),
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
                padding: EdgeInsets.only(top: 8, left: 10),
                width: MediaQuery.of(context).size.width * .91,
                margin: const EdgeInsets.only(bottom: 6.0),
                //Same as `blurRadius` i guess
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Color.fromRGBO(21, 43, 81, 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 1.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Text(
                  "Add Rental Owners",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
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
                  border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child: Column(
                    children: [

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
                            "First Name",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
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
                                            firstnameerror = false;
                                          });
                                        },
                                        controller: firstname,
                                        cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter first name",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: firstnameerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(11),
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
                      firstnameerror
                          ? Row(
                        children: [
                          Spacer(),
                          Text(
                            firstnamemessage,
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
                      SizedBox(
                        height: 10,
                      ),
                      //last name
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Last Name",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
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
                                            lastnameerror = false;
                                          });
                                        },
                                        controller: lastname,
                                        cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter company name",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: lastnameerror
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
                      lastnameerror
                          ? Row(
                        children: [
                          Spacer(),
                          Text(
                            lastnamemessage,
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
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Phone Number",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
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
                                            phonenumerror = false;
                                          });
                                        },
                                        controller: phonenum,
                                        cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter first name",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
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
                                          contentPadding: EdgeInsets.all(11),
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
                                MediaQuery.of(context).size.width *
                                    .035),
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
                            width: 2,
                          ),
                          Text(
                            "First Name",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
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
                                            firstnameerror = false;
                                          });
                                        },
                                        controller: firstname,
                                        cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter first name",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: firstnameerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(11),
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
                      firstnameerror
                          ? Row(
                        children: [
                          Spacer(),
                          Text(
                            firstnamemessage,
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
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "First Name",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
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
                                            firstnameerror = false;
                                          });
                                        },
                                        controller: firstname,
                                        cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter first name",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: firstnameerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(11),
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
                      firstnameerror
                          ? Row(
                        children: [
                          Spacer(),
                          Text(
                            firstnamemessage,
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
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "First Name",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
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
                                            firstnameerror = false;
                                          });
                                        },
                                        controller: firstname,
                                        cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter first name",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: firstnameerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(11),
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
                      firstnameerror
                          ? Row(
                        children: [
                          Spacer(),
                          Text(
                            firstnamemessage,
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
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "First Name",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
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
                                            firstnameerror = false;
                                          });
                                        },
                                        controller: firstname,
                                        cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter first name",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
                                            color: Color(0xFF8A95A8),
                                          ),
                                          enabledBorder: firstnameerror
                                              ? OutlineInputBorder(
                                            borderRadius:
                                            BorderRadius.circular(2),
                                            borderSide: BorderSide(
                                              color: Colors.red,
                                            ),
                                          )
                                              : InputBorder.none,
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(11),
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
                      firstnameerror
                          ? Row(
                        children: [
                          Spacer(),
                          Text(
                            firstnamemessage,
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
                      SizedBox(
                        height: 10,
                      ),
                      //birth date
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Date Of Birth",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      // Row(
                      //   children: [
                      //     SizedBox(width: 2),
                      //     Expanded(
                      //       child: Material(
                      //         elevation: 4,
                      //         child: Container(
                      //           height: 50,
                      //           width: MediaQuery.of(context).size.width * .6,
                      //           decoration: BoxDecoration(
                      //             borderRadius: BorderRadius.circular(2),
                      //             border: Border.all(
                      //               color: Color(0xFF8A95A8),
                      //             ),
                      //           ),
                      //           child: Stack(
                      //             children: [
                      //               Positioned.fill(
                      //                 child: TextField(
                      //                   onChanged: (value) {
                      //
                      //                     setState(() {
                      //                       birthdateerror = false;
                      //                       // _selectDate(context);
                      //                     });
                      //                   },
                      //                   controller: birthdateController,
                      //                   cursorColor:
                      //                   Color.fromRGBO(21, 43, 81, 1),
                      //                   decoration: InputDecoration(
                      //                     hintText: "yyyy/mm/dd",
                      //                     hintStyle: TextStyle(
                      //                       fontSize: MediaQuery.of(context)
                      //                           .size
                      //                           .width *
                      //                           .037,
                      //                       color: Color(0xFF8A95A8),
                      //                     ),
                      //                     enabledBorder: birthdateerror
                      //                         ? OutlineInputBorder(
                      //                       borderRadius:
                      //                       BorderRadius.circular(3),
                      //                       borderSide: BorderSide(
                      //                         color: Colors.red,
                      //                       ),
                      //                     )
                      //                         : InputBorder.none,
                      //                     border: InputBorder.none,
                      //                     contentPadding: EdgeInsets.all(12),
                      //                     suffixIcon: IconButton(
                      //                       icon: Icon(Icons.calendar_today),
                      //                       onPressed: () => _birthDate(context),
                      //                     ),
                      //                   ),
                      //                   readOnly: true,
                      //                   onTap: () {
                      //                     _birthDate(context);
                      //                     setState(() {
                      //                       birthdateerror = false;
                      //                     });
                      //                   },
                      //                 ),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(width: 2),
                      //   ],
                      // ),
                      // birthdateerror
                      //     ? Row(
                      //   children: [
                      //     Spacer(),
                      //     Text(
                      //       birthdatemessage,
                      //       style: TextStyle(
                      //           color: Colors.red,
                      //           fontSize:
                      //           MediaQuery.of(context).size.width *
                      //               .035),
                      //     ),
                      //     SizedBox(
                      //       width: 2,
                      //     ),
                      //   ],
                      // )
                      //     : Container(),
                      // SizedBox(
                      //   height: 5,
                      // ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 10,
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
                  border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
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
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                MediaQuery.of(context).size.width * .045),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      //start date
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
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
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
          //contact information
          // Padding(
          //   padding: const EdgeInsets.only(left: 25, right: 25),
          //   child: Material(
          //     elevation: 6,
          //     borderRadius: BorderRadius.circular(10),
          //     child: Container(
          //       decoration: BoxDecoration(
          //         color: Colors.white,
          //         borderRadius: BorderRadius.circular(10),
          //         border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
          //       ),
          //       child: Padding(
          //         padding: const EdgeInsets.only(
          //             left: 25, right: 25, top: 20, bottom: 30),
          //         child: Column(
          //           children: [
          //             Row(
          //               children: [
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //                 Text(
          //                   "Contact information",
          //                   style: TextStyle(
          //                       color: Color.fromRGBO(21, 43, 81, 1),
          //                       fontWeight: FontWeight.bold,
          //                       // fontSize: 18
          //                       fontSize:
          //                       MediaQuery.of(context).size.width * .045),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             //primary email
          //             Row(
          //               children: [
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //                 Text(
          //                   "Primary E-mail",
          //                   style: TextStyle(
          //                       color: Color(0xFF8A95A8),
          //                       fontWeight: FontWeight.bold,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width * .036),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(
          //               height: 5,
          //             ),
          //             Row(
          //               children: [
          //                 SizedBox(width: 2),
          //                 Expanded(
          //                   child: Material(
          //                     elevation: 4,
          //                     child: Container(
          //                       height: 50,
          //                       width: MediaQuery.of(context).size.width * .6,
          //                       decoration: BoxDecoration(
          //                         borderRadius: BorderRadius.circular(2),
          //                         border: Border.all(
          //                           color: Color(0xFF8A95A8),
          //                         ),
          //                       ),
          //                       child: Stack(
          //                         children: [
          //                           Positioned.fill(
          //                             child: TextField(
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   primaryemailerror = false;
          //                                 });
          //                               },
          //                               controller: primaryemail,
          //                               cursorColor:
          //                               Color.fromRGBO(21, 43, 81, 1),
          //                               decoration: InputDecoration(
          //                                 hintText: "Enter primary e-mail",
          //                                 hintStyle: TextStyle(
          //                                   fontSize: MediaQuery.of(context)
          //                                       .size
          //                                       .width *
          //                                       .037,
          //                                   color: Color(0xFF8A95A8),
          //                                 ),
          //                                 enabledBorder: primaryemailerror
          //                                     ? OutlineInputBorder(
          //                                   borderRadius:
          //                                   BorderRadius.circular(2),
          //                                   borderSide: BorderSide(
          //                                     color: Colors.red,
          //                                   ),
          //                                 )
          //                                     : InputBorder.none,
          //                                 border: InputBorder.none,
          //                                 contentPadding: EdgeInsets.all(12),
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 SizedBox(width: 2),
          //               ],
          //             ),
          //             primaryemailerror
          //                 ? Row(
          //               children: [
          //                 Spacer(),
          //                 Text(
          //                   primaryemailmessage,
          //                   style: TextStyle(
          //                       color: Colors.red,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width *
          //                           .035),
          //                 ),
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //               ],
          //             )
          //                 : Container(),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             //alternative email
          //             Row(
          //               children: [
          //                 SizedBox(
          //                   width: 3,
          //                 ),
          //                 Text(
          //                   "Alternative E-mail",
          //                   style: TextStyle(
          //                     // color: Colors.grey,
          //                       color: Color(0xFF8A95A8),
          //                       fontWeight: FontWeight.bold,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width * .036),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(
          //               height: 5,
          //             ),
          //             Row(
          //               children: [
          //                 SizedBox(width: 2),
          //                 Expanded(
          //                   child: Material(
          //                     elevation: 4,
          //                     child: Container(
          //                       height: 50,
          //                       width: MediaQuery.of(context).size.width * .6,
          //                       decoration: BoxDecoration(
          //                         borderRadius: BorderRadius.circular(2),
          //                         border: Border.all(
          //                           color: Color(0xFF8A95A8),
          //                         ),
          //                       ),
          //                       child: Stack(
          //                         children: [
          //                           Positioned.fill(
          //                             child: TextField(
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   alternativeerror = false;
          //                                 });
          //                               },
          //                               controller: alternativeemail,
          //                               cursorColor:
          //                               Color.fromRGBO(21, 43, 81, 1),
          //                               decoration: InputDecoration(
          //                                 hintText: "Enter alternative e-mail ",
          //                                 hintStyle: TextStyle(
          //                                   fontSize: MediaQuery.of(context)
          //                                       .size
          //                                       .width *
          //                                       .037,
          //                                   color: Color(0xFF8A95A8),
          //                                 ),
          //                                 enabledBorder: alternativeerror
          //                                     ? OutlineInputBorder(
          //                                   borderRadius:
          //                                   BorderRadius.circular(2),
          //                                   borderSide: BorderSide(
          //                                     color: Colors.red,
          //                                   ),
          //                                 )
          //                                     : InputBorder.none,
          //                                 border: InputBorder.none,
          //                                 contentPadding: EdgeInsets.all(12),
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 SizedBox(width: 2),
          //               ],
          //             ),
          //             alternativeerror
          //                 ? Row(
          //               children: [
          //                 Spacer(),
          //                 Text(
          //                   alternativemessage,
          //                   style: TextStyle(
          //                       color: Colors.red,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width *
          //                           .035),
          //                 ),
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //               ],
          //             )
          //                 : Container(),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             //phonenumber
          //             Row(
          //               children: [
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //                 Text(
          //                   "Phone Number",
          //                   style: TextStyle(
          //                     // color: Colors.grey,
          //                       color: Color(0xFF8A95A8),
          //                       fontWeight: FontWeight.bold,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width * .036),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(
          //               height: 5,
          //             ),
          //             Row(
          //               children: [
          //                 SizedBox(width: 2),
          //                 Expanded(
          //                   child: Material(
          //                     elevation: 4,
          //                     child: Container(
          //                       height: 50,
          //                       width: MediaQuery.of(context).size.width * .6,
          //                       decoration: BoxDecoration(
          //                         borderRadius: BorderRadius.circular(2),
          //                         border: Border.all(
          //                           color: Color(0xFF8A95A8),
          //                         ),
          //                       ),
          //                       child: Stack(
          //                         children: [
          //                           Positioned.fill(
          //                             child: TextField(
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   phonenumerror = false;
          //                                 });
          //                               },
          //                               controller: phonenum,
          //                               cursorColor:
          //                               Color.fromRGBO(21, 43, 81, 1),
          //                               decoration: InputDecoration(
          //                                 hintText: "Enter phone number",
          //                                 hintStyle: TextStyle(
          //                                   fontSize: MediaQuery.of(context)
          //                                       .size
          //                                       .width *
          //                                       .037,
          //                                   color: Color(0xFF8A95A8),
          //                                 ),
          //                                 enabledBorder: phonenumerror
          //                                     ? OutlineInputBorder(
          //                                   borderRadius:
          //                                   BorderRadius.circular(2),
          //                                   borderSide: BorderSide(
          //                                     color: Colors.red,
          //                                   ),
          //                                 )
          //                                     : InputBorder.none,
          //                                 border: InputBorder.none,
          //                                 contentPadding: EdgeInsets.all(12),
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 SizedBox(width: 2),
          //               ],
          //             ),
          //             phonenumerror
          //                 ? Row(
          //               children: [
          //                 Spacer(),
          //                 Text(
          //                   phonenummessage,
          //                   style: TextStyle(
          //                       color: Colors.red,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width *
          //                           .035),
          //                 ),
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //               ],
          //             )
          //                 : Container(),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             //homenumber
          //             Row(
          //               children: [
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //                 Text(
          //                   "Home Number",
          //                   style: TextStyle(
          //                     // color: Colors.grey,
          //                       color: Color(0xFF8A95A8),
          //                       fontWeight: FontWeight.bold,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width * .036),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(
          //               height: 5,
          //             ),
          //             Row(
          //               children: [
          //                 SizedBox(width: 2),
          //                 Expanded(
          //                   child: Material(
          //                     elevation: 4,
          //                     child: Container(
          //                       height: 50,
          //                       width: MediaQuery.of(context).size.width * .6,
          //                       decoration: BoxDecoration(
          //                         borderRadius: BorderRadius.circular(2),
          //                         border: Border.all(
          //                           color: Color(0xFF8A95A8),
          //                         ),
          //                       ),
          //                       child: Stack(
          //                         children: [
          //                           Positioned.fill(
          //                             child: TextField(
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   homenumerror = false;
          //                                 });
          //                               },
          //                               controller: homenum,
          //                               cursorColor:
          //                               Color.fromRGBO(21, 43, 81, 1),
          //                               decoration: InputDecoration(
          //                                 hintText: "Enter home number",
          //                                 hintStyle: TextStyle(
          //                                   fontSize: MediaQuery.of(context)
          //                                       .size
          //                                       .width *
          //                                       .037,
          //                                   color: Color(0xFF8A95A8),
          //                                 ),
          //                                 enabledBorder: homenumerror
          //                                     ? OutlineInputBorder(
          //                                   borderRadius:
          //                                   BorderRadius.circular(2),
          //                                   borderSide: BorderSide(
          //                                     color: Colors.red,
          //                                   ),
          //                                 )
          //                                     : InputBorder.none,
          //                                 border: InputBorder.none,
          //                                 contentPadding: EdgeInsets.all(12),
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 SizedBox(width: 2),
          //               ],
          //             ),
          //             homenumerror
          //                 ? Row(
          //               children: [
          //                 Spacer(),
          //                 Text(
          //                   homenummessage,
          //                   style: TextStyle(
          //                       color: Colors.red,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width *
          //                           .035),
          //                 ),
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //               ],
          //             )
          //                 : Container(),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             //office number
          //             Row(
          //               children: [
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //                 Text(
          //                   "Office Number",
          //                   style: TextStyle(
          //                     // color: Colors.grey,
          //                       color: Color(0xFF8A95A8),
          //                       fontWeight: FontWeight.bold,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width * .036),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(
          //               height: 5,
          //             ),
          //             Row(
          //               children: [
          //                 SizedBox(width: 2),
          //                 Expanded(
          //                   child: Material(
          //                     elevation: 4,
          //                     child: Container(
          //                       height: 50,
          //                       width: MediaQuery.of(context).size.width * .6,
          //                       decoration: BoxDecoration(
          //                         borderRadius: BorderRadius.circular(2),
          //                         border: Border.all(
          //                           color: Color(0xFF8A95A8),
          //                         ),
          //                       ),
          //                       child: Stack(
          //                         children: [
          //                           Positioned.fill(
          //                             child: TextField(
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   officenumerror = false;
          //                                 });
          //                               },
          //                               controller: officenum,
          //                               cursorColor:
          //                               Color.fromRGBO(21, 43, 81, 1),
          //                               decoration: InputDecoration(
          //                                 hintText: "Enter office number",
          //                                 hintStyle: TextStyle(
          //                                   fontSize: MediaQuery.of(context)
          //                                       .size
          //                                       .width *
          //                                       .037,
          //                                   color: Color(0xFF8A95A8),
          //                                 ),
          //                                 enabledBorder: officenumerror
          //                                     ? OutlineInputBorder(
          //                                   borderRadius:
          //                                   BorderRadius.circular(2),
          //                                   borderSide: BorderSide(
          //                                     color: Colors.red,
          //                                   ),
          //                                 )
          //                                     : InputBorder.none,
          //                                 border: InputBorder.none,
          //                                 contentPadding: EdgeInsets.all(12),
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 SizedBox(width: 2),
          //               ],
          //             ),
          //             officenumerror
          //                 ? Row(
          //               children: [
          //                 Spacer(),
          //                 Text(
          //                   officenummessage,
          //                   style: TextStyle(
          //                       color: Colors.red,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width *
          //                           .035),
          //                 ),
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //               ],
          //             )
          //                 : Container(),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             //street address
          //             Row(
          //               children: [
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //                 Text(
          //                   "Street Address",
          //                   style: TextStyle(
          //                     // color: Colors.grey,
          //                       color: Color(0xFF8A95A8),
          //                       fontWeight: FontWeight.bold,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width * .036),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(
          //               height: 5,
          //             ),
          //             Row(
          //               children: [
          //                 SizedBox(width: 2),
          //                 Expanded(
          //                   child: Material(
          //                     elevation: 4,
          //                     child: Container(
          //                       height: 50,
          //                       width: MediaQuery.of(context).size.width * .6,
          //                       decoration: BoxDecoration(
          //                         borderRadius: BorderRadius.circular(2),
          //                         border: Border.all(
          //                           color: Color(0xFF8A95A8),
          //                         ),
          //                       ),
          //                       child: Stack(
          //                         children: [
          //                           Positioned.fill(
          //                             child: TextField(
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   street2error = false;
          //                                 });
          //                               },
          //                               controller: street2,
          //                               cursorColor:
          //                               Color.fromRGBO(21, 43, 81, 1),
          //                               decoration: InputDecoration(
          //                                 hintText: "Enter street address",
          //                                 hintStyle: TextStyle(
          //                                   fontSize: MediaQuery.of(context)
          //                                       .size
          //                                       .width *
          //                                       .037,
          //                                   color: Color(0xFF8A95A8),
          //                                 ),
          //                                 enabledBorder: street2error
          //                                     ? OutlineInputBorder(
          //                                   borderRadius:
          //                                   BorderRadius.circular(2),
          //                                   borderSide: BorderSide(
          //                                     color: Colors.red,
          //                                   ),
          //                                 )
          //                                     : InputBorder.none,
          //                                 border: InputBorder.none,
          //                                 contentPadding: EdgeInsets.all(12),
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 SizedBox(width: 2),
          //               ],
          //             ),
          //             street2error
          //                 ? Row(
          //               children: [
          //                 Spacer(),
          //                 Text(
          //                   street2message,
          //                   style: TextStyle(
          //                       color: Colors.red,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width *
          //                           .035),
          //                 ),
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //               ],
          //             )
          //                 : Container(),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             //enter city
          //             Row(
          //               children: [
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //                 Text(
          //                   "City",
          //                   style: TextStyle(
          //                     // color: Colors.grey,
          //                       color: Color(0xFF8A95A8),
          //                       fontWeight: FontWeight.bold,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width * .036),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(
          //               height: 5,
          //             ),
          //             Row(
          //               children: [
          //                 SizedBox(width: 2),
          //                 Expanded(
          //                   child: Material(
          //                     elevation: 4,
          //                     child: Container(
          //                       height: 50,
          //                       width: MediaQuery.of(context).size.width * .6,
          //                       decoration: BoxDecoration(
          //                         borderRadius: BorderRadius.circular(2),
          //                         border: Border.all(
          //                           color: Color(0xFF8A95A8),
          //                         ),
          //                       ),
          //                       child: Stack(
          //                         children: [
          //                           Positioned.fill(
          //                             child: TextField(
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   city2error = false;
          //                                 });
          //                               },
          //                               controller: city2,
          //                               cursorColor:
          //                               Color.fromRGBO(21, 43, 81, 1),
          //                               decoration: InputDecoration(
          //                                 hintText: "Enter city",
          //                                 hintStyle: TextStyle(
          //                                   fontSize: MediaQuery.of(context)
          //                                       .size
          //                                       .width *
          //                                       .037,
          //                                   color: Color(0xFF8A95A8),
          //                                 ),
          //                                 enabledBorder: city2error
          //                                     ? OutlineInputBorder(
          //                                   borderRadius:
          //                                   BorderRadius.circular(2),
          //                                   borderSide: BorderSide(
          //                                     color: Colors.red,
          //                                   ),
          //                                 )
          //                                     : InputBorder.none,
          //                                 border: InputBorder.none,
          //                                 contentPadding: EdgeInsets.all(12),
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 SizedBox(width: 2),
          //               ],
          //             ),
          //             city2error
          //                 ? Row(
          //               children: [
          //                 Spacer(),
          //                 Text(
          //                   city2message,
          //                   style: TextStyle(
          //                       color: Colors.red,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width *
          //                           .035),
          //                 ),
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //               ],
          //             )
          //                 : Container(),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             //emter state
          //             Row(
          //               children: [
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //                 Text(
          //                   "State",
          //                   style: TextStyle(
          //                     // color: Colors.grey,
          //                       color: Color(0xFF8A95A8),
          //                       fontWeight: FontWeight.bold,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width * .036),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(
          //               height: 5,
          //             ),
          //             Row(
          //               children: [
          //                 SizedBox(width: 2),
          //                 Expanded(
          //                   child: Material(
          //                     elevation: 4,
          //                     child: Container(
          //                       height: 50,
          //                       width: MediaQuery.of(context).size.width * .6,
          //                       decoration: BoxDecoration(
          //                         borderRadius: BorderRadius.circular(2),
          //                         border: Border.all(
          //                           color: Color(0xFF8A95A8),
          //                         ),
          //                       ),
          //                       child: Stack(
          //                         children: [
          //                           Positioned.fill(
          //                             child: TextField(
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   state2error = false;
          //                                 });
          //                               },
          //                               controller: state2,
          //                               cursorColor:
          //                               Color.fromRGBO(21, 43, 81, 1),
          //                               decoration: InputDecoration(
          //                                 hintText: "Enter state",
          //                                 hintStyle: TextStyle(
          //                                   fontSize: MediaQuery.of(context)
          //                                       .size
          //                                       .width *
          //                                       .037,
          //                                   color: Color(0xFF8A95A8),
          //                                 ),
          //                                 enabledBorder:state2error
          //                                     ? OutlineInputBorder(
          //                                   borderRadius:
          //                                   BorderRadius.circular(2),
          //                                   borderSide: BorderSide(
          //                                     color: Colors.red,
          //                                   ),
          //                                 )
          //                                     : InputBorder.none,
          //                                 border: InputBorder.none,
          //                                 contentPadding: EdgeInsets.all(12),
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 SizedBox(width: 2),
          //               ],
          //             ),
          //             state2error
          //                 ? Row(
          //               children: [
          //                 Spacer(),
          //                 Text(
          //                   state2message,
          //                   style: TextStyle(
          //                       color: Colors.red,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width *
          //                           .035),
          //                 ),
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //               ],
          //             )
          //                 : Container(),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             //enter country
          //             Row(
          //               children: [
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //                 Text(
          //                   "Country",
          //                   style: TextStyle(
          //                     // color: Colors.grey,
          //                       color: Color(0xFF8A95A8),
          //                       fontWeight: FontWeight.bold,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width * .036),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(
          //               height: 5,
          //             ),
          //             Row(
          //               children: [
          //                 SizedBox(width: 2),
          //                 Expanded(
          //                   child: Material(
          //                     elevation: 4,
          //                     child: Container(
          //                       height: 50,
          //                       width: MediaQuery.of(context).size.width * .6,
          //                       decoration: BoxDecoration(
          //                         borderRadius: BorderRadius.circular(2),
          //                         border: Border.all(
          //                           color: Color(0xFF8A95A8),
          //                         ),
          //                       ),
          //                       child: Stack(
          //                         children: [
          //                           Positioned.fill(
          //                             child: TextField(
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   county2error = false;
          //                                 });
          //                               },
          //                               controller: county2,
          //                               cursorColor:
          //                               Color.fromRGBO(21, 43, 81, 1),
          //                               decoration: InputDecoration(
          //                                 hintText: "Enter country",
          //                                 hintStyle: TextStyle(
          //                                   fontSize: MediaQuery.of(context)
          //                                       .size
          //                                       .width *
          //                                       .037,
          //                                   color: Color(0xFF8A95A8),
          //                                 ),
          //                                 enabledBorder: county2error
          //                                     ? OutlineInputBorder(
          //                                   borderRadius:
          //                                   BorderRadius.circular(2),
          //                                   borderSide: BorderSide(
          //                                     color: Colors.red,
          //                                   ),
          //                                 )
          //                                     : InputBorder.none,
          //                                 border: InputBorder.none,
          //                                 contentPadding: EdgeInsets.all(12),
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 SizedBox(width: 2),
          //               ],
          //             ),
          //             county2error
          //                 ? Row(
          //               children: [
          //                 Spacer(),
          //                 Text(
          //                   county2message,
          //                   style: TextStyle(
          //                       color: Colors.red,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width *
          //                           .035),
          //                 ),
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //               ],
          //             )
          //                 : Container(),
          //             SizedBox(
          //               height: 10,
          //             ),
          //             //postal code
          //             Row(
          //               children: [
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //                 Text(
          //                   "Postal Code",
          //                   style: TextStyle(
          //                     // color: Colors.grey,
          //                       color: Color(0xFF8A95A8),
          //                       fontWeight: FontWeight.bold,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width * .036),
          //                 ),
          //               ],
          //             ),
          //             SizedBox(
          //               height: 5,
          //             ),
          //             Row(
          //               children: [
          //                 SizedBox(width: 2),
          //                 Expanded(
          //                   child: Material(
          //                     elevation: 4,
          //                     child: Container(
          //                       height: 50,
          //                       width: MediaQuery.of(context).size.width * .6,
          //                       decoration: BoxDecoration(
          //                         borderRadius: BorderRadius.circular(2),
          //                         border: Border.all(
          //                           color: Color(0xFF8A95A8),
          //                         ),
          //                       ),
          //                       child: Stack(
          //                         children: [
          //                           Positioned.fill(
          //                             child: TextField(
          //                               onChanged: (value) {
          //                                 setState(() {
          //                                   code2error = false;
          //                                 });
          //                               },
          //                               controller: code2,
          //                               cursorColor:
          //                               Color.fromRGBO(21, 43, 81, 1),
          //                               decoration: InputDecoration(
          //                                 hintText: "Enter postal code",
          //                                 hintStyle: TextStyle(
          //                                   fontSize: MediaQuery.of(context)
          //                                       .size
          //                                       .width *
          //                                       .037,
          //                                   color: Color(0xFF8A95A8),
          //                                 ),
          //                                 enabledBorder: code2error
          //                                     ? OutlineInputBorder(
          //                                   borderRadius:
          //                                   BorderRadius.circular(2),
          //                                   borderSide: BorderSide(
          //                                     color: Colors.red,
          //                                   ),
          //                                 )
          //                                     : InputBorder.none,
          //                                 border: InputBorder.none,
          //                                 contentPadding: EdgeInsets.all(12),
          //                               ),
          //                             ),
          //                           ),
          //                         ],
          //                       ),
          //                     ),
          //                   ),
          //                 ),
          //                 SizedBox(width: 2),
          //               ],
          //             ),
          //             code2error
          //                 ? Row(
          //               children: [
          //                 Spacer(),
          //                 Text(
          //                   code2message,
          //                   style: TextStyle(
          //                       color: Colors.red,
          //                       fontSize:
          //                       MediaQuery.of(context).size.width *
          //                           .035),
          //                 ),
          //                 SizedBox(
          //                   width: 2,
          //                 ),
          //               ],
          //             )
          //                 : Container(),
          //           ],
          //         ),
          //       ),
          //     ),
          //   ),
          // ),
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
                  border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
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
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                MediaQuery.of(context).size.width * .045),
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
                                MediaQuery.of(context).size.width * .036),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 2),
                          // Expanded(
                          //   child: Material(
                          //     elevation: 4,
                          //     child: Container(
                          //       height: 50,
                          //       width: MediaQuery.of(context).size.width * .6,
                          //       decoration: BoxDecoration(
                          //         borderRadius: BorderRadius.circular(2),
                          //         border: Border.all(
                          //           color: Color(0xFF8A95A8),
                          //         ),
                          //       ),
                          //       child: Stack(
                          //         children: [
                          //           Positioned.fill(
                          //             child: TextField(
                          //               onChanged: (value) {
                          //                 setState(() {
                          //                   taxtypeerror = false;
                          //                 });
                          //               },
                          //              // controller: taxtype,
                          //               cursorColor:
                          //               Color.fromRGBO(21, 43, 81, 1),
                          //               decoration: InputDecoration(
                          //                 hintText: "Enter tax identify type",
                          //                 hintStyle: TextStyle(
                          //                   fontSize: MediaQuery.of(context)
                          //                       .size
                          //                       .width *
                          //                       .037,
                          //                   color: Color(0xFF8A95A8),
                          //                 ),
                          //                 enabledBorder: taxtypeerror
                          //                     ? OutlineInputBorder(
                          //                   borderRadius:
                          //                   BorderRadius.circular(2),
                          //                   borderSide: BorderSide(
                          //                     color: Colors.red,
                          //                   ),
                          //                 )
                          //                     : InputBorder.none,
                          //                 border: InputBorder.none,
                          //                 contentPadding: EdgeInsets.all(12),
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
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
                                MediaQuery.of(context).size.width *
                                    .035),
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
                                MediaQuery.of(context).size.width * .036),
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
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter SSN or EIN",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
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
                                MediaQuery.of(context).size.width *
                                    .035),
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
              SizedBox(
                  width:
                  MediaQuery.of(context).size.width * 0.065),
              GestureDetector(
                // onTap: () async {
                //   if (name.text.isEmpty) {
                //     setState(() {
                //       nameerror = true;
                //       namemessage = "required";
                //     });
                //   } else {
                //     setState(() {
                //       nameerror = false;
                //     });
                //   }
                //   if (comname.text.isEmpty) {
                //     setState(() {
                //       comnameerror = true;
                //       comnamemessage = "required";
                //     });
                //   } else {
                //     setState(() {
                //       comnameerror = false;
                //     });
                //   }
                //   if (birthdateController.text.isEmpty) {
                //     setState(() {
                //       birthdateerror = true;
                //       birthdatemessage = "required";
                //     });
                //   } else {
                //     setState(() {
                //       birthdateerror = false;
                //     });
                //   }
                //   if (startdateController.text.isEmpty) {
                //     setState(() {
                //       startdatederror = true;
                //       startdatemessage = "required";
                //     });
                //   } else {
                //     setState(() {
                //       startdatederror = false;
                //     });
                //   }
                //   if (enddateController.text.isEmpty) {
                //     setState(() {
                //       enddatederror = true;
                //       enddatemessage = "required";
                //     });
                //   } else {
                //     setState(() {
                //       enddatederror = false;
                //     });
                //   }
                //   if (primaryemail.text.isEmpty) {
                //     setState(() {
                //       primaryemailerror = true;
                //       primaryemailmessage = "required";
                //     });
                //   } else {
                //     setState(() {
                //       primaryemailerror = false;
                //     });
                //   }
                //   if (alternativeemail.text.isEmpty) {
                //     setState(() {
                //       alternativeerror = true;
                //       alternativemessage = "required";
                //     });
                //   } else {
                //     setState(() {
                //       alternativeerror = false;
                //     });
                //   }
                //   if (phonenum.text.isEmpty) {
                //     setState(() {
                //       phonenumerror = true;
                //       phonenummessage = "required";
                //     });
                //   } else {
                //     setState(() {
                //       phonenumerror = false;
                //     });
                //   }
                //   if (homenum.text.isEmpty) {
                //     setState(() {
                //       homenumerror = true;
                //       homenummessage = "required";
                //     });
                //   } else {
                //     setState(() {
                //       homenumerror = false;
                //     });
                //   }
                //   if (officenum.text.isEmpty) {
                //     setState(() {
                //       officenumerror = true;
                //       officenummessage = "required";
                //     });
                //   } else {
                //     setState(() {
                //       officenumerror = false;
                //     });
                //   }
                //   if (street2.text.isEmpty) {
                //     setState(() {
                //       street2error = true;
                //       street2message = "required";
                //     });
                //   } else {
                //     setState(() {
                //       street2error = false;
                //     });
                //   }
                //   if (city2.text.isEmpty) {
                //     setState(() {
                //       city2error = true;
                //       city2message = "required";
                //     });
                //   } else {
                //     setState(() {
                //       city2error = false;
                //     });
                //   }
                //   if (state2.text.isEmpty) {
                //     setState(() {
                //       state2error = true;
                //       state2message = "required";
                //     });
                //   } else {
                //     setState(() {
                //       state2error = false;
                //     });
                //   }
                //   if (city2.text.isEmpty) {
                //     setState(() {
                //       city2error = true;
                //       city2message = "required";
                //     });
                //   } else {
                //     setState(() {
                //       city2error = false;
                //     });
                //   }
                //   if (county2.text.isEmpty) {
                //     setState(() {
                //       county2error = true;
                //       county2message = "required";
                //     });
                //   } else {
                //     setState(() {
                //       county2error = false;
                //     });
                //   }
                //   if (code2.text.isEmpty) {
                //     setState(() {
                //       code2error = true;
                //       code2message = "required";
                //     });
                //   } else {
                //     setState(() {
                //       code2error = false;
                //     });
                //   }
                //   if (taxtype.text.isEmpty) {
                //     setState(() {
                //       taxtypeerror = true;
                //       taxtypemessage = "required";
                //     });
                //   } else {
                //     setState(() {
                //       taxtypeerror = false;
                //     });
                //   }
                //   if (taxid.text.isEmpty) {
                //     setState(() {
                //       taxiderror = true;
                //       taxidmessage = "required";
                //     });
                //   } else {
                //     setState(() {
                //       taxiderror = false;
                //     });
                //   }
                //   if (!nameerror &&
                //       !comnameerror &&
                //       !primaryemailerror &&
                //       !alternativeerror &&
                //       !phonenumerror &&
                //       !homenumerror &&
                //       !officenumerror &&
                //       !street2error &&
                //       !city2error &&
                //       !state2error &&
                //       !county2error &&
                //       !code2error &&
                //       !taxtypeerror &&
                //       !taxiderror &&
                //       !birthdateerror &&
                //       !startdatederror &&
                //       !enddatederror
                //   ) {
                //     setState(() {
                //       loading = true;
                //     });
                //
                //     List<ProcessorList> processor  = [];
                //     for(var i=0;i<_controllers.length;i++){
                //       if(_controllers.isNotEmpty)
                //         processor.add(ProcessorList(
                //             processorId:_controllers[i]!.text
                //         ));
                //     }
                //     SharedPreferences prefs = await SharedPreferences.getInstance();
                //     var adminId = prefs.getString("adminId");
                //     final RentalOwnerData rentalOwner = RentalOwnerData(
                //       adminId:adminId ,
                //       rentalOwnerFirstName: name.text,
                //       rentalOwnerLastName: lastname.text,
                //       rentalOwnerCompanyName: comname.text,
                //       birthDate: birthdateController.text,
                //       startDate: startdateController.text,
                //       endDate: enddateController.text,
                //       rentalOwnerPrimaryEmail: primaryemail.text,
                //       rentalOwnerAlternateEmail: alternativeemail.text,
                //       rentalOwnerPhoneNumber: phonenum.text,
                //       rentalOwnerHomeNumber: homenum.text,
                //       rentalOwnerBusinessNumber: businessnum.text,
                //       streetAddress: street2.text,
                //       city: city2.text,
                //       state: state2.text,
                //       postalCode: code2.text,
                //       country: county2.text,
                //       processorList: processor,
                //       textIdentityType: taxtype.text,
                //       texpayerId: taxid.text,
                //     );
                //     var result =   await RentalOwnerService().addRentalOwner(rentalOwner);
                //     if(result){
                //       Navigator.of(context).pop(result);
                //     }
                //   }
                //   // SharedPreferences prefs =
                //   // await SharedPreferences.getInstance();
                //   // String? adminId = prefs.getString("adminId");
                //   // if (adminId != null) {
                //   //   try {
                //   //     await StaffMemberRepository().addStaffMember(
                //   //       adminId: adminId,
                //   //       staffmemberName: name.text,
                //   //       staffmemberDesignation: designation.text,
                //   //       staffmemberPhoneNumber: phonenumber.text,
                //   //       staffmemberEmail: email.text,
                //   //       staffmemberPassword: password.text,
                //   //     );
                //   //     setState(() {
                //   //       loading = false;
                //   //     });
                //   //     Navigator.of(context).pop(true);
                //   //   } catch (e) {
                //   //     setState(() {
                //   //       loading = false;
                //   //     });
                //   //     // Handle error
                //   //   }
                //   // }
                // },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Container(
                    height:
                    MediaQuery.of(context).size.height * .045,
                    width: MediaQuery.of(context).size.width * .36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Color.fromRGBO(21, 43, 81, 1),
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
                        "Add Rental Owner",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:
                            MediaQuery.of(context).size.width *
                                .034),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 15,
              ),
              Text("Cancel"),
            ],
          ),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );;
  }
}
