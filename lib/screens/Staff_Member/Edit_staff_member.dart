import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:keyboard_actions/keyboard_actions_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/widgets/appbar.dart';
import '../../constant/constant.dart';
import '../../model/staffmember.dart';
import '../../repository/Staffmember.dart';
import '../../widgets/drawer_tiles.dart';
import '../../widgets/custom_drawer.dart';
class Edit_staff_member extends StatefulWidget {
  Staffmembers? staff;
  Edit_staff_member({super.key, this.staff});

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
    // password.text = widget.staff!.staffmemberPassword.toString();
  }

  bool isLoading = false;
  final FocusNode _nodeText1 = FocusNode();
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget_302.App_Bar(context: context),
      backgroundColor: Colors.white,
      drawer:CustomDrawer(currentpage: "Add Staff Member",dropdown: false,),
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
                margin:  EdgeInsets.only(bottom: 6.0),
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
                  "Edit Staff Member",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width < 500 ? 18 : 20
                  ),
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
                            "New Staff Member",
                            style: TextStyle(
                                color: blueColor,
                                fontWeight: FontWeight.bold,
                                // fontSize: 18
                                fontSize:
                                MediaQuery.of(context).size.width < 500 ? 20 : 25),
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
                            "Staff Member Name *",
                            style: TextStyle(
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width < 500 ? 15 : 20),
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
                                height: 55,
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
                                        blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter staff member name",
                                          hintStyle: TextStyle(
                                            fontSize:MediaQuery.of(context).size.width < 500 ? 15 : 20,
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
                            "Designation",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width < 500 ? 15 : 20),
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
                                        blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter designation",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 20,
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
                            "Phone Number *",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width < 500 ? 15 : 20),
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
                                        focusNode: _nodeText1,
                                        controller: phonenumber,
                                        keyboardType: TextInputType.numberWithOptions(signed: true,decimal: true),
                                        cursorColor:
                                        blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter phone number",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 20,
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
                            "Email *",
                            style: TextStyle(
                              // color: Colors.grey,
                                color: Color(0xFF8A95A8),
                                fontWeight: FontWeight.bold,
                                fontSize:
                                MediaQuery.of(context).size.width < 500 ? 15 : 20),
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
                                        keyboardType:
                                        TextInputType.emailAddress,
                                        controller: email,
                                        cursorColor:
                                        blueColor,
                                        decoration: InputDecoration(
                                          hintText: "Enter email",
                                          hintStyle: TextStyle(
                                            fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 20,
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
                        height: 20,
                      ),
                      Row(
                        children: [
                          if(MediaQuery.of(context).size.width < 500 )
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.01),
                          if(MediaQuery.of(context).size.width > 500 )
                            SizedBox(
                                width: MediaQuery.of(context).size.width * 0.004),
                          GestureDetector(

                            onTap: () async {
                              // Validate Name Field
                              if (name.text.isEmpty) {
                                setState(() {
                                  nameerror = true;
                                  namemessage = "Name is required";
                                });
                              } else {
                                setState(() {
                                  nameerror = false;
                                });
                              }

                              // Validate Designation Field
                              if (designation.text.isEmpty) {
                                setState(() {
                                  designationerror = true;
                                  designationmessage = "Designation is required";
                                });
                              } else {
                                setState(() {
                                  designationerror = false;
                                });
                              }

                              // Validate Phone Number Field
                              if (phonenumber.text.isEmpty) {
                                setState(() {
                                  phonenumbererror = true;
                                  phonenumbermessage = "Phone number is required";
                                });
                              } else {
                                setState(() {
                                  phonenumbererror = false;
                                });
                              }

                              // Validate Email Field
                              if (email.text.isEmpty) {
                                setState(() {
                                  emailerror = true;
                                  emailmessage = "Email is required";
                                });
                              } else {
                                setState(() {
                                  emailerror = false;
                                });
                              }

                              // If any validation fails, return early and do not proceed with API call or navigation
                              if (nameerror || designationerror || phonenumbererror || emailerror) {
                                return; // This prevents the navigation and edit if any field is invalid
                              }

                              // Show loading spinner while waiting for API call
                              setState(() {
                                isLoading = true;
                              });

                              // Get the adminId from shared preferences
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              String? adminId = prefs.getString("adminId");

                              if (adminId != null) {
                                try {
                                  // API call to edit staff member
                                  await StaffMemberRepository().Edit_staff_member(
                                    adminId: adminId,
                                    staffmemberName: name.text,
                                    staffmemberDesignation: designation.text,
                                    staffmemberPhoneNumber: phonenumber.text,
                                    staffmemberEmail: email.text,
                                    Sid: widget.staff!.staffmemberId,
                                  );

                                  // Update the staff details after successful edit
                                  setState(() {
                                    widget.staff?.staffmemberName = name.text;
                                    widget.staff?.staffmemberDesignation = designation.text;
                                    widget.staff?.staffmemberPhoneNumber = phonenumber.text;
                                    widget.staff?.staffmemberEmail = email.text;
                                    widget.staff?.staffmemberId = widget.staff!.staffmemberId;
                                    widget.staff?.adminId = adminId;
                                    isLoading = false;
                                  });

                                  // Navigate back with success response
                                  Navigator.of(context).pop(true);

                                } catch (e) {
                                  // Handle error and stop the loading spinner
                                  setState(() {
                                    isLoading = false;
                                  });
                                  // You can add further error handling here
                                }
                              }
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(5.0),
                              child: Container(
                                height:
                                MediaQuery.of(context).size.height * .05,
                                width: MediaQuery.of(context).size.width < 500 ? 150 : 180,
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
                                  child: isLoading
                                      ? SpinKitFadingCircle(
                                    color: Colors.white,
                                    size: 25.0,
                                  )
                                      : Text(
                                    "Edit Staff Member",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 18),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Text("Cancel",style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: MediaQuery.of(context).size.width < 500 ? 15 : 18),)),
                        ],
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
        ],
      ),
    );
  }
}
