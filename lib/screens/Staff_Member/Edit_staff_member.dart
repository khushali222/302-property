import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import '../../model/staffmember.dart';
import '../../repository/Staffmember.dart';
import '../../widgets/drawer_tiles.dart';

class Edit_staff_member extends StatefulWidget {
  Staffmembers? staff;
   Edit_staff_member({super.key,this.staff});

  @override
  State<Edit_staff_member> createState() => _Edit_staff_memberState();
}

class _Edit_staff_memberState extends State<Edit_staff_member> {
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    name.text = widget.staff!.staffmemberName!;
    designation.text = widget.staff!.staffmemberDesignation!;
    phonenumber.text = widget.staff!.staffmemberPhoneNumber!.toString();
    email.text = widget.staff!.staffmemberEmail.toString();
    password.text = widget.staff!.staffmemberPassword.toString();
  }

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
                  "Edit Staff Members",
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
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Edit Staff Member",
                            style: TextStyle(
                                color: Color.fromRGBO(21, 43, 81, 1),
                                fontWeight: FontWeight.bold,
                                fontSize:
    MediaQuery.of(context).size.width * .05),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          SizedBox(
                            width: 2,
                          ),
                          Text(
                            "Staff Member Name",
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
                                            nameerror = false;
                                          });
                                        },
                                        controller: name,
                                        cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText:
                                          "Enter a staff member name",
                                          hintStyle: TextStyle(
                                            fontSize:MediaQuery.of(context)
                                              .size
                                              .width *
                                          .037,
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
                            style: TextStyle(color: Colors.red,fontSize: MediaQuery.of(context).size.width *
                                .035),
                          ),
                          SizedBox(width: 2,),
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
                            "Designation",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:  MediaQuery.of(context).size.width * .036),
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
                                            designationerror = false;
                                          });
                                        },
                                        controller: designation,
                                        cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter Designation",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
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
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      designationerror
                          ? Row(
                        children: [
                           Spacer(),
                          Text(
                            designationmessage,
                            style: TextStyle(color: Colors.red,fontSize: MediaQuery.of(context).size.width *
                                .035),
                          ),
                          SizedBox(width: 2,),
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
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:  MediaQuery.of(context).size.width * .036),
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
                                            phonenumbererror = false;
                                          });
                                        },
                                        controller: phonenumber,
                                        cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText:
                                          "Enter Phone Number",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
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
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      phonenumbererror
                          ? Row(
                        children: [
                         Spacer(),
                          Text(
                            phonenumbermessage,
                            style: TextStyle(color: Colors.red,fontSize: MediaQuery.of(context).size.width *
                                .035),
                          ),
                          SizedBox(width: 2,),
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
                            "Email",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:  MediaQuery.of(context).size.width * .036),
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
                                            emailerror = false;
                                          });
                                        },
                                        controller: email,
                                        cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter Email",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
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
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      emailerror
                          ? Row(
                        children: [
                         Spacer(),
                          Text(
                            emailmessage,
                            style: TextStyle(color: Colors.red,fontSize: MediaQuery.of(context).size.width *
                                .035),
                          ),
                          SizedBox(width: 2,),
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
                            "Password",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:  MediaQuery.of(context).size.width * .036),
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
                                            passworderror = false;
                                          });
                                        },
                                        controller: password,
                                        cursorColor:
                                        Color.fromRGBO(21, 43, 81, 1),
                                        decoration: InputDecoration(
                                          hintText: "Enter Password",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context)
                                                .size
                                                .width *
                                                .037,
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
                          ),
                          SizedBox(width: 2),
                        ],
                      ),
                      passworderror
                          ? Row(
                        children: [
                        Spacer(),
                          Text(
                            passwordmessage,
                            style: TextStyle(color: Colors.red,fontSize: MediaQuery.of(context).size.width *
                                .035),
                          ),
                          SizedBox(width: 2,),
                        ],
                      )
                          : Container(),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        children: [
                          SizedBox(
                              width:
                              MediaQuery.of(context).size.width * 0.01),
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
                                  await StaffMemberRepository().Edit_staff_member(
                                      adminId: adminId,
                                      staffmemberName: name.text,
                                      staffmemberDesignation: designation.text,
                                      staffmemberPhoneNumber: phonenumber.text,
                                      staffmemberEmail: email.text,
                                      staffmemberPassword: password.text,
                                      Sid: widget.staff!.staffmemberId
                                  );
                                  setState(() {
                                    loading = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    loading = false;
                                  });
                                  // Handle error
                                }
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height: 40.0,
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
                                    "Edit staff Member",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
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
