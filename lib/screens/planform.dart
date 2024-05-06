import 'package:flutter/material.dart';
import 'package:three_zero_two_property/screens/reviewscreen.dart';
import 'package:three_zero_two_property/screens/signup_screen.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

void main() {
  runApp(MaterialApp(home: Planform()));
}

class Planform extends StatefulWidget {
  const Planform({super.key});

  @override
  State<Planform> createState() => _PlanformState();
}

class _PlanformState extends State<Planform> {
  TextEditingController streetaddress1 = TextEditingController();
  TextEditingController streetaddress2 = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController postalcode = TextEditingController();
  TextEditingController country = TextEditingController();
  bool streetaddress1error = false;
  bool streetaddress2error = false;
  bool cityerror = false;
  bool stateerror = false;
  bool postalcodeerror = false;
  bool countryerror = false;
  bool loading = false;
  String streetaddress1message = "";
  String streetaddress2message = "";
  String cityerrormessage = "";
  String statemessage = "";
  String postalcodemessage = "";
  String countrymessage = "";
  bool showStep2Details = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: Container(
                  height: 50.0,
                  padding: EdgeInsets.only(top: 8, left: 10),
                  width: MediaQuery.of(context).size.width * .91,
                  margin: const EdgeInsets.only(
                      bottom: 6.0), //Same as `blurRadius` i guess
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
                    "Preminum Plans",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
                Text(
                  "1.Enter the company Address",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(21, 43, 81, 1)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
                Expanded(
                  child: Text(
                    "Enter the company's headquarter to ensure accurate tax information",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
                Text(
                  "Street Address *",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(21, 43, 81, 1)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      //  color: Color.fromRGBO(196, 196, 196, .3),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                streetaddress1error = false;
                              });
                            },
                            controller: streetaddress1,
                            cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            decoration: InputDecoration(
                              enabledBorder: streetaddress1error
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(2),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .red), // Set border color here
                                    )
                                  : InputBorder.none,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                              hintText: "Enter the street address here 1...*",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
              ],
            ),
            streetaddress1error
                ? Center(
                    child: Text(
                    streetaddress1message,
                    style: TextStyle(color: Colors.red),
                  ))
                : Container(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      //  color: Color.fromRGBO(196, 196, 196, .3),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                streetaddress2error = false;
                              });
                            },
                            controller: streetaddress2,
                            cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            decoration: InputDecoration(
                              enabledBorder: streetaddress2error
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(2),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .red), // Set border color here
                                    )
                                  : InputBorder.none,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                              hintText: "Enter the street address here 2..*",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
              ],
            ),
            streetaddress2error
                ? Center(
                    child: Text(
                    streetaddress2message,
                    style: TextStyle(color: Colors.red),
                  ))
                : Container(),
            // SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            // Row(
            //   children: [
            //     SizedBox(
            //       width: MediaQuery.of(context).size.width * .099,
            //     ),
            //     Text(
            //       "City *",
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //           color: Color.fromRGBO(21, 43, 81, 1)),
            //     ),
            //     SizedBox(
            //       width: MediaQuery.of(context).size.width * .1,
            //     ),
            //     Text(
            //       "State *",
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //           color: Color.fromRGBO(21, 43, 81, 1)),
            //     ),
            //     SizedBox(
            //       width: MediaQuery.of(context).size.width * .1,
            //     ),
            //     Text(
            //       "Posatal code *",
            //       style: TextStyle(
            //           fontWeight: FontWeight.bold,
            //           color: Color.fromRGBO(21, 43, 81, 1)),
            //     ),
            //     SizedBox(
            //       width: MediaQuery.of(context).size.width * .099,
            //     ),
            //   ],
            // ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            //city,state,postalcode

            //  SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
                Text(
                  "Country *",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(21, 43, 81, 1)),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      //  color: Color.fromRGBO(196, 196, 196, .3),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                countryerror = false;
                              });
                            },
                            controller: country,
                            cursorColor: Color.fromRGBO(21, 43, 81, 1),
                            decoration: InputDecoration(
                              enabledBorder: countryerror
                                  ? OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(2),
                                      borderSide: BorderSide(
                                          color: Colors
                                              .red), // Set border color here
                                    )
                                  : InputBorder.none,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(10),
                              hintText: "Select the country here..*",
                              suffixIcon: Icon(
                                Icons.arrow_drop_down,
                                color: Color.fromRGBO(21, 43, 81, 1),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * .099,
                ),
              ],
            ),
            countryerror
                ? Center(
                    child: Text(
                    countrymessage,
                    style: TextStyle(color: Colors.red),
                  ))
                : Container(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            GestureDetector(
              onTap: () {
                if (streetaddress1.text.isEmpty) {
                  setState(() {
                    streetaddress1error = true;
                    streetaddress1message = "Street address 1 is required";
                  });
                } else {
                  setState(() {
                    streetaddress1error = false;
                  });
                }
                if (streetaddress2.text.isEmpty) {
                  setState(() {
                    streetaddress2error = true;
                    streetaddress2message = "Address 2 is required";
                  });
                } else {
                  setState(() {
                    streetaddress2error = false;
                  });
                }
                if (country.text.isEmpty) {
                  setState(() {
                    countryerror = true;
                    countrymessage = "Country is required";
                  });
                } else {
                  setState(() {
                    countryerror = false;
                  });
                }

                if (!streetaddress1error &&
                    !streetaddress2error &&
                    !countryerror) {
                  setState(() {
                    showStep2Details =
                        true; // Set to true to show step 2 details
                  });
                }
              },
              child: Container(
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.width * 0.3,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (showStep2Details)
              Column(
               // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .099,
                  ),
                  Text(
                    "2 Review the subscription and enter the payment information",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * .099,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
