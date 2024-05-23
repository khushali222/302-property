import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/repository/Staffmember.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';

import '../../repository/Property_type.dart';
import '../../widgets/drawer_tiles.dart';

class Add_staffmember extends StatefulWidget {
  const Add_staffmember({super.key});

  @override
  State<Add_staffmember> createState() => _Add_staffmemberState();
}

class _Add_staffmemberState extends State<Add_staffmember> {
  TextEditingController name = TextEditingController();
  TextEditingController designation = TextEditingController();
  TextEditingController phonenumber = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  bool nameerror = false;
  bool designationerror = false;
  bool phonenumbererror = false;
  bool emailerror = false;
  bool passworderror = false;

  String namemessage = "";
  String designationmessage = "";
  String phonenumbermessage = "";
  String emailmessage = "";
  String passwordmessage = "";

  bool loading = false;
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
                    color: Colors.white,
                  ),
                  "Add Staff Member",
                  true),
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
                  "Add Staff Members",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 22),
                ),
              ),
            ),
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
                  border: Border.all(color: Color.fromRGBO(21, 43, 81, 1)),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 25, right: 25, top: 20, bottom: 30),
                  child:
                  Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "New Staff Member",
                            style: TextStyle(
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 15,
                          ),
                          Text(
                            "Staff member name..*",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 15),
                          Material(
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
                                          nameerror = false;
                                        });
                                      },
                                      controller: name,
                                      cursorColor:
                                      Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        hintText:
                                        "Enter a staff member name here..*",
                                        hintStyle: TextStyle(
                                          fontSize: 13,
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
                                        contentPadding: EdgeInsets.all(12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                        ],
                      ),
                      nameerror
                          ? Row(
                        children: [
                          SizedBox(
                            width: 117,
                          ),
                          Text(
                            namemessage,
                            style: TextStyle(color: Colors.red),
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
                            width: 15,
                          ),
                          Text(
                            "Designation...*",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 15),
                          Material(
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
                                          designationerror = false;
                                        });
                                      },
                                      controller: designation,
                                      cursorColor:
                                      Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        hintText: "Enter Designation here..*",
                                        hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF8A95A8),
                                        ),
                                        enabledBorder: designationerror
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
                          SizedBox(width: 20),
                        ],
                      ),
                      designationerror
                          ? Row(
                        children: [
                          SizedBox(
                            width: 117,
                          ),
                          Text(
                            designationmessage,
                            style: TextStyle(color: Colors.red),
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
                            width: 15,
                          ),
                          Text(
                            "Phone Number...",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 15),
                          Material(
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
                                          phonenumbererror = false;
                                        });
                                      },
                                      controller: phonenumber,
                                      cursorColor:
                                      Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        hintText:
                                        "Enter Phone Number here..*",
                                        hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF8A95A8),
                                        ),
                                        enabledBorder: phonenumbererror
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
                          SizedBox(width: 20),
                        ],
                      ),
                      phonenumbererror
                          ? Row(
                        children: [
                          SizedBox(
                            width: 117,
                          ),
                          Text(
                            phonenumbermessage,
                            style: TextStyle(color: Colors.red),
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
                            width: 15,
                          ),
                          Text(
                            "Email...*",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 15),
                          Material(
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
                                          emailerror = false;
                                        });
                                      },
                                      controller: email,
                                      cursorColor:
                                      Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        hintText: "Enter Email here..*",
                                        hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF8A95A8),
                                        ),
                                        enabledBorder: emailerror
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
                          SizedBox(width: 20),
                        ],
                      ),
                      emailerror
                          ? Row(
                        children: [
                          SizedBox(
                            width: 117,
                          ),
                          Text(
                            emailmessage,
                            style: TextStyle(color: Colors.red),
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
                            width: 15,
                          ),
                          Text(
                            "Password...*",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize: 13),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(width: 15),
                          Material(
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
                                          passworderror = false;
                                        });
                                      },
                                      controller: password,
                                      cursorColor:
                                      Color.fromRGBO(21, 43, 81, 1),
                                      decoration: InputDecoration(
                                        hintText: "Enter Password here..*",
                                        hintStyle: TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF8A95A8),
                                        ),
                                        enabledBorder: passworderror
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
                          SizedBox(width: 20),
                        ],
                      ),
                      passworderror
                          ? Row(
                        children: [
                          SizedBox(
                            width: 117,
                          ),
                          Text(
                            passwordmessage,
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      )
                          : Container(),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (name.text.isEmpty) {
                            setState(() {
                              nameerror = true;
                              namemessage = "name is required";
                            });
                          } else {
                            setState(() {
                              nameerror = false;
                            });
                          }
                          if (designation.text.isEmpty) {
                            setState(() {
                              designationerror = true;
                              designationmessage = "designation is required";
                            });
                          } else {
                            setState(() {
                              designationerror = false;
                            });
                          }
                          if (phonenumber.text.isEmpty) {
                            setState(() {
                              phonenumbererror = true;
                              phonenumbermessage = "number is required";
                            });
                          } else {
                            setState(() {
                              phonenumbererror = false;
                            });
                          }
                          if (email.text.isEmpty) {
                            setState(() {
                              emailerror = true;
                              emailmessage = "email is required";
                            });
                          } else {
                            setState(() {
                              emailerror = false;
                            });
                          }
                          if (password.text.isEmpty) {
                            setState(() {
                              passworderror = true;
                              passwordmessage = "password is required";
                            });
                          } else {
                            setState(() {
                              passworderror = false;
                            });
                          }
                          if (!nameerror &&
                              !designationerror &&
                              !phonenumbererror &&
                              !emailerror &&
                              !phonenumbererror) {
                            setState(() {
                              loading = true;
                            });
                          }
                          SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                          String? adminId = prefs.getString("adminId");
                          if (adminId != null) {
                            try {
                              await StaffMemberRepository().addStaffMember(
                                adminId: adminId,
                                staffmemberName: name.text,
                                staffmemberDesignation: designation.text,
                                staffmemberPhoneNumber: phonenumber.text,
                                staffmemberEmail: email.text,
                                staffmemberPassword: password.text,
                              );
                              setState(() {
                                loading = false;
                              });
                              Navigator.of(context).pop(true);
                            } catch (e) {
                              setState(() {
                                loading = false;
                              });
                              // Handle error
                            }
                          }
                        },
                        child: Row(
                          children: [
                            SizedBox(
                                width:
                                MediaQuery.of(context).size.width * 0.05),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height: 30.0,
                                width:
                                MediaQuery.of(context).size.width * .36,
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
                                    "Add staff Member",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13),
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
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
