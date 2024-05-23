import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/model/setting.dart';
import 'package:three_zero_two_property/repository/setting.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import 'package:http/http.dart' as http;

import '../../repository/profile_repository.dart';
import '../../widgets/drawer_tiles.dart';

class TabBarExample extends StatefulWidget {
  @override
  State<TabBarExample> createState() => _TabBarExampleState();
}

class _TabBarExampleState extends State<TabBarExample> {
  int _selectedRadio = 1;
  TextEditingController credit = TextEditingController();
  TextEditingController debit = TextEditingController();
  TextEditingController percent = TextEditingController();
  TextEditingController flat = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchSurchargeData();
  }

  final SurchargeRepository surchargeRepository =
      SurchargeRepository(baseUrl: 'https://saas.cloudrentalmanager.com');
  Future<void> fetchSurchargeData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? id = prefs.getString("adminId");
    try {
      Setting1 surcharges =
          await surchargeRepository.fetchSurchargeData('$id');
      if (surcharges !=  null) {
        setState(() {
          credit.text = surcharges.surchargePercent.toString();
          debit.text = surcharges.surchargePercentDebit.toString();
          percent.text = surcharges.surchargePercentACH.toString();
          flat.text = surcharges.surchargeFlatACH.toString();
        });
      }
    } catch (e) {
      print('Failed to load surcharge data: $e');
    }
  }

  Future<void> updateSurcharge() async {
    print("calling");


    try {
      Map<String, dynamic> data = {
        "admin_id":"1714649182536",
        "surcharge_percent": credit.text.isNotEmpty ? int.parse(credit.text) : null,
        "surcharge_percent_debit": debit.text.isNotEmpty ? int.parse(debit.text) : null,
        "surcharge_percent_ACH": percent.text.isNotEmpty ? int.parse(percent.text) : null , // Add your logic to get this value
        "surcharge_flat_ACH": flat.text.isNotEmpty ? int.parse(flat.text) : null , // Add your logic to get this value
      };

      bool success = await surchargeRepository.AddSurgeData('1714649182536', data);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Surcharge Updated Successfully')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to Update Surcharge')));
      }
    } catch (e) {
      print('Failed to update surcharge data: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Number of tabs
      child: Scaffold(
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
                    ["Properties", "RentalOwner", "Tenants"]),
                buildDropdownListTile(
                    context,
                    FaIcon(
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
        body: Column(
          children: [
            TabBar(
              indicatorColor: Color.fromRGBO(21, 43, 81, 1),
              labelStyle: TextStyle(
                  color: Color.fromRGBO(21, 43, 81, 1),
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
              tabs: [
                Tab(text: 'Surcharge'),
                Tab(text: 'Late Fee Charge'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  //first tabbar
                  ListView(children: [
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 38.0,
                          padding: EdgeInsets.only(top: 8, left: 10),
                          width: MediaQuery.of(context).size.width * .91,
                          margin: const EdgeInsets.only(bottom: 6.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Color.fromRGBO(21, 43, 81, 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Text(
                            "Setting",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Color.fromRGBO(21, 43, 81, 1)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 20, bottom: 30),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Surcharge",
                                      style: TextStyle(
                                        color: Color.fromRGBO(21, 43, 81, 1),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .045,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "You can set default surcharge percentage from here",
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              .035,
                                      color: Color(0xFF8A95A8),
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Credit Card Surcharge Percent",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .035,
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: 50,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .6,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: TextField(
                                                  onChanged: (value) {
                                                    setState(() {
                                                      //  passworderror = false;
                                                    });
                                                  },
                                                  controller: credit,
                                                  cursorColor: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                  decoration: InputDecoration(
                                                    // hintText: "Enter password",
                                                    hintStyle: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                      color: Color(0xFF8A95A8),
                                                    ),
                                                    // enabledBorder: passworderror
                                                    //     ? OutlineInputBorder(
                                                    //   borderRadius:
                                                    //   BorderRadius.circular(2),
                                                    //   borderSide: BorderSide(
                                                    //     color: Colors.red,
                                                    //   ),
                                                    // )
                                                    //     : InputBorder.none,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(13),
                                                    suffixIcon: Icon(
                                                      Icons.percent,
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1),
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 100),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 5),
                                    Text(
                                      "Debit Card Surcharge Percent",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .035,
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: 50,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .6,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: TextField(
                                                  onChanged: (value) {
                                                    setState(() {
                                                      //  passworderror = false;
                                                    });
                                                  },
                                                  controller: debit,
                                                  cursorColor: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                  decoration: InputDecoration(
                                                    // hintText: "Enter password",
                                                    hintStyle: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                      color: Color(0xFF8A95A8),
                                                    ),
                                                    // enabledBorder: passworderror
                                                    //     ? OutlineInputBorder(
                                                    //   borderRadius:
                                                    //   BorderRadius.circular(2),
                                                    //   borderSide: BorderSide(
                                                    //     color: Colors.red,
                                                    //   ),
                                                    // )
                                                    //     : InputBorder.none,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(13),
                                                    suffixIcon: Icon(
                                                      Icons.percent,
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1),
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 100),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text(
                                  "You can set default ACH percentage or ACH flat fee or both from here",
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              .035,
                                      color: Color(0xFF8A95A8),
                                      fontWeight: FontWeight.bold),
                                ),
                                RadioListTile<int>(
                                  activeColor: Colors.black,
                                  title: Text(
                                    'Add ACH surcharge percentage',
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .035,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  value: 1,
                                  groupValue: _selectedRadio,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRadio = value!;
                                    });
                                  },
                                ),
                                RadioListTile<int>(
                                  activeColor: Colors.black,
                                  title: Text(
                                    'Add ACH flat fee',
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .035,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  value: 2,
                                  groupValue: _selectedRadio,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRadio = value!;
                                    });
                                  },
                                ),
                                RadioListTile<int>(
                                  activeColor: Colors.black,
                                  title: Text(
                                    'Add both ACH surcharge percentage and flat fee',
                                    style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .035,
                                        color: Color(0xFF8A95A8),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  value: 3,
                                  groupValue: _selectedRadio,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedRadio = value!;
                                    });
                                  },
                                ),
                                if (_selectedRadio == 1 ||
                                    _selectedRadio == 3) ...[
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        'Add ACH Surcharge Percentage',
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .035,
                                            color: Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),

                                  // TextField(
                                  //   decoration: InputDecoration(
                                  //     border: OutlineInputBorder(),
                                  //     labelText: 'ACH Surcharge Percentage',
                                  //   ),
                                  // ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Material(
                                          elevation: 4,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            height: 50,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .6,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: TextField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        //  passworderror = false;
                                                      });
                                                    },
                                                    controller: percent,
                                                    cursorColor: Color.fromRGBO(
                                                        21, 43, 81, 1),
                                                    decoration: InputDecoration(
                                                      // hintText: "Enter password",
                                                      hintStyle: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .037,
                                                        color:
                                                            Color(0xFF8A95A8),
                                                      ),
                                                      // enabledBorder: passworderror
                                                      //     ? OutlineInputBorder(
                                                      //   borderRadius:
                                                      //   BorderRadius.circular(2),
                                                      //   borderSide: BorderSide(
                                                      //     color: Colors.red,
                                                      //   ),
                                                      // )
                                                      //     : InputBorder.none,
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.all(13),
                                                      suffixIcon: Icon(
                                                        Icons.percent,
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1),
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 90),
                                    ],
                                  ),
                                ],
                                if (_selectedRadio == 2 ||
                                    _selectedRadio == 3) ...[
                                  SizedBox(height: 20),
                                  Row(
                                    children: [
                                      SizedBox(width: 5),
                                      Text(
                                        'Add ACH Flat Fee',
                                        style: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .035,
                                            color: Color(0xFF8A95A8),
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  // TextField(
                                  //   decoration: InputDecoration(
                                  //     border: OutlineInputBorder(),
                                  //     labelText: 'ACH Flat Fee',
                                  //   ),
                                  // ),
                                  SizedBox(height: 10),
                                  Row(
                                    children: [
                                      SizedBox(width: 5),
                                      Expanded(
                                        child: Material(
                                          elevation: 4,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            height: 50,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .6,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Stack(
                                              children: [
                                                Positioned.fill(
                                                  child: TextField(
                                                    onChanged: (value) {
                                                      setState(() {
                                                        //  passworderror = false;
                                                      });
                                                    },
                                                    controller: flat,
                                                    cursorColor: Color.fromRGBO(
                                                        21, 43, 81, 1),
                                                    decoration: InputDecoration(
                                                      // hintText: "Enter password",
                                                      hintStyle: TextStyle(
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .037,
                                                        color:
                                                            Color(0xFF8A95A8),
                                                      ),
                                                      // enabledBorder: passworderror
                                                      //     ? OutlineInputBorder(
                                                      //   borderRadius:
                                                      //   BorderRadius.circular(2),
                                                      //   borderSide: BorderSide(
                                                      //     color: Colors.red,
                                                      //   ),
                                                      // )
                                                      //     : InputBorder.none,
                                                      border: InputBorder.none,
                                                      contentPadding:
                                                          EdgeInsets.all(13),
                                                      suffixIcon: Icon(
                                                        Icons.percent,
                                                        color: Color.fromRGBO(
                                                            21, 43, 81, 1),
                                                        size: 18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 90),
                                    ],
                                  ),
                                ],
                                SizedBox(height: 30),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    GestureDetector(
                                      onTap: () async{
                                       await updateSurcharge();
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .05,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .25,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
                                                blurRadius: 6.0,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Update",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .035),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .05,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .2,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                            child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                  //second tabbar
                  ListView(children: [
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          height: 38.0,
                          padding: EdgeInsets.only(top: 8, left: 10),
                          width: MediaQuery.of(context).size.width * .91,
                          margin: const EdgeInsets.only(bottom: 6.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            color: Color.fromRGBO(21, 43, 81, 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 1.0),
                                blurRadius: 6.0,
                              ),
                            ],
                          ),
                          child: Text(
                            "Setting",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                      child: Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Color.fromRGBO(21, 43, 81, 1)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 25, right: 25, top: 20, bottom: 30),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      "Late Fee Charge",
                                      style: TextStyle(
                                        color: Color.fromRGBO(21, 43, 81, 1),
                                        fontWeight: FontWeight.bold,
                                        fontSize:
                                            MediaQuery.of(context).size.width *
                                                .045,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(
                                  "You can set default Late fee charge from here",
                                  style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                              .035,
                                      color: Color(0xFF8A95A8),
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Percentage",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .035,
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: 50,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .6,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: TextField(
                                                  onChanged: (value) {
                                                    setState(() {
                                                      //  passworderror = false;
                                                    });
                                                  },
                                                  //  controller: password,
                                                  cursorColor: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                  decoration: InputDecoration(
                                                    // hintText: "Enter password",
                                                    hintStyle: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                      color: Color(0xFF8A95A8),
                                                    ),
                                                    // enabledBorder: passworderror
                                                    //     ? OutlineInputBorder(
                                                    //   borderRadius:
                                                    //   BorderRadius.circular(2),
                                                    //   borderSide: BorderSide(
                                                    //     color: Colors.red,
                                                    //   ),
                                                    // )
                                                    //     : InputBorder.none,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(13),
                                                    suffixIcon: Icon(
                                                      Icons.percent,
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1),
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 90),
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Text(
                                      "Duration",
                                      style: TextStyle(
                                          fontSize: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .035,
                                          color: Color(0xFF8A95A8),
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    SizedBox(width: 5),
                                    Expanded(
                                      child: Material(
                                        elevation: 4,
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          height: 50,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .6,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Stack(
                                            children: [
                                              Positioned.fill(
                                                child: TextField(
                                                  onChanged: (value) {
                                                    setState(() {
                                                      //  passworderror = false;
                                                    });
                                                  },
                                                  //  controller: password,
                                                  cursorColor: Color.fromRGBO(
                                                      21, 43, 81, 1),
                                                  decoration: InputDecoration(
                                                    // hintText: "Enter password",
                                                    hintStyle: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .037,
                                                      color: Color(0xFF8A95A8),
                                                    ),
                                                    // enabledBorder: passworderror
                                                    //     ? OutlineInputBorder(
                                                    //   borderRadius:
                                                    //   BorderRadius.circular(2),
                                                    //   borderSide: BorderSide(
                                                    //     color: Colors.red,
                                                    //   ),
                                                    // )
                                                    //     : InputBorder.none,
                                                    border: InputBorder.none,
                                                    contentPadding:
                                                        EdgeInsets.all(13),
                                                    suffixIcon: Icon(
                                                      Icons.percent,
                                                      color: Color.fromRGBO(
                                                          21, 43, 81, 1),
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 90),
                                  ],
                                ),
                                SizedBox(height: 30),
                                Row(
                                  children: [
                                    SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.02),
                                    GestureDetector(
                                      onTap: () async{
                                         await updateSurcharge();
                                      },
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .05,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .25,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey,
                                                offset:
                                                    Offset(0.0, 1.0), //(x,y)
                                                blurRadius: 6.0,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              "Update",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          .035),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 15,
                                    ),
                                    Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                .05,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .2,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Color.fromRGBO(21, 43, 81, 1),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Center(
                                            child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
