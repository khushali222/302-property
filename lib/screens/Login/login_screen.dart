import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/VendorModule/screen/dashboard.dart';
import 'package:three_zero_two_property/screens/Password/changepassword.dart';

import 'package:three_zero_two_property/screens/Signup/signup_screen.dart';
import 'package:http/http.dart' as http;

import '../../StaffModule/repository/staffpermission_provider.dart';
import '../../StaffModule/screen/dashboard.dart';
import '../../TenantsModule/repository/permission_provider.dart';
import '../../TenantsModule/screen/dashboard.dart';
import '../../constant/constant.dart';
import '../Dashboard/dashboard_one.dart';
import '../Password/forgotpassword.dart';
import '../Password/otp_vrify.dart';

class Login_Screen extends StatefulWidget {
  const Login_Screen({super.key});

  @override
  State<Login_Screen> createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  String? selectedRole; // Initially, no role is selected

  final List<Map<String, String>> roles = [
    {'role_id': '1', 'role_name': 'Admin'},
    {'role_id': '2', 'role_name': 'Staffmember'},
    {'role_id': '3', 'role_name': 'Tenant'},
    {'role_id': '4', 'role_name': 'Vendor'}
  ];

  TextEditingController password = TextEditingController();
   TextEditingController company = TextEditingController();
  TextEditingController email = TextEditingController();

  bool passworderror = false;
  bool visiable_password = true;
  bool emailerror = false;
  bool companyerror = false;
  bool roleerror = false;

  bool loading = false;
  String passwordmessage = "";
   String companymessage = "";
  String emailmessage = "";
  String rolemessage = "";
  final GlobalKey formkey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: formkey,
        child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (constraints.maxWidth > 600) {
                return ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Image(
                      image: AssetImage('assets/images/logo.png'),
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.9,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    // Welcome
                    Center(
                      child: Text(
                        "Welcome to 302 Rentals",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.04,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    // Login text
                    Center(
                      child: Text(
                        "Please login here...",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.036),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: const Text('Select Role'),
                              value: selectedRole,
                              items: roles.map((role) {
                                return DropdownMenuItem<String>(
                                  value: role['role_id'],
                                  child: Text(role['role_name']!),
                                );
                              }).toList(),
                              style: TextStyle(
                                fontSize: 23,
                                color:Colors.grey.shade900,

                              ),
                              onChanged: (value) {
                                setState(() {
                                  selectedRole = value;
                                  roleerror = false;
                                });
                                print('Selected role_id: $selectedRole');
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 60,
                                width: 170,
                                padding: const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                ),
                                iconSize: 24,
                                iconEnabledColor: Color(0xFFb0b6c3),
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(6),
                                  thickness: MaterialStateProperty.all(6),
                                  thumbVisibility: MaterialStateProperty.all(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                      ],
                    ),
                    roleerror
                        ? Center(
                        child: Text(
                          rolemessage,
                          style: TextStyle(color: Colors.red),
                        ))
                        : Container(),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    // Email
                    Row(
                      children: [

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromRGBO(196, 196, 196, .3),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: TextField(
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (value) {
                                      setState(() {
                                        emailerror = false;
                                      });
                                    },
                                    controller: email,
                                    cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                    decoration: InputDecoration(
                                      enabledBorder: emailerror
                                          ? OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors
                                                .red), // Set border color here
                                      )
                                          : InputBorder.none,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(15),
                                      prefixIcon: Container(
                                        height: 25,
                                        width: 25,
                                        padding: EdgeInsets.all(13),
                                        child: FaIcon(
                                          FontAwesomeIcons.envelope,
                                          size: 25,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      hintText: "Business Email",
                                      hintStyle: TextStyle(
                                          color: Colors.grey[600], fontSize: 20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.095,
                        ),
                      ],
                    ),
                    emailerror
                        ? Center(
                        child: Text(
                          emailmessage,
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ))
                        : Container(),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    if(selectedRole !="1" && selectedRole != null)
                      Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.099,
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color.fromRGBO(196, 196, 196, .3),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: TextField(
                                          keyboardType: TextInputType.emailAddress,
                                          onChanged: (value) {
                                            setState(() {
                                              companyerror = false;
                                            });
                                          },
                                          controller: company,
                                          cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                          decoration: InputDecoration(
                                            enabledBorder: companyerror
                                                ? OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .red), // Set border color here
                                            )
                                                : InputBorder.none,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(14),
                                            prefixIcon: Container(
                                              height: 25,
                                              width: 25,
                                              padding: EdgeInsets.all(13),
                                              child: FaIcon(
                                                FontAwesomeIcons.businessTime,
                                                size: 23,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            hintText: "Company Name",
                                            hintStyle: TextStyle(
                                                color: Colors.grey[600], fontSize: 20),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.095,
                              ),
                            ],
                          ),
                          companyerror
                              ? Center(
                              child: Text(
                                companymessage,
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ))
                              : Container(),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.025,
                          ),
                        ],
                      ),

                    // Password
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                        Expanded(

                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromRGBO(196, 196, 196, .3),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: TextField(
                                    keyboardType: TextInputType.text,
                                    onChanged: (value) {
                                      setState(() {
                                        passworderror = false;
                                      });
                                    },
                                    controller: password,
                                    obscureText: visiable_password,
                                    cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                    decoration: InputDecoration(
                                      enabledBorder: passworderror
                                          ? OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors
                                                .red), // Set border color here
                                      )
                                          : InputBorder.none,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(14),
                                      prefixIcon: Container(
                                        height: 25,
                                        width: 25,
                                        // color: Colors.blue,
                                        padding: EdgeInsets.all(13),
                                        child: FaIcon(
                                          FontAwesomeIcons.lock,
                                          size: 25,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      hintText: "Password",
                                      hintStyle: TextStyle(
                                          color: Colors.grey[600], fontSize: 20),
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          setState(() {
                                            visiable_password = !visiable_password;
                                          });
                                        },
                                        child: Icon(
                                          visiable_password
                                              ? Icons.remove_red_eye_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 30,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                      ],
                    ),
                    passworderror
                        ? Center(
                        child: Text(
                          passwordmessage,
                          style: TextStyle(color: Colors.red),
                        ))
                        : Container(),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),
                    // Forgot password
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.03,
                          width: MediaQuery.of(context).size.width * 0.04,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        Text(
                          "Remember me ",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.025,
                              color: Colors.black),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPassword()));
                          },
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.025,
                                color: Colors.blue),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    // Login button
                    /*SizedBox(
                  height: MediaQuery.of(context).size.height * 0.16,
                ),*/
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          if (email.text.isEmpty) {
                            setState(() {
                              emailerror = true;
                              emailmessage = "Email is required";
                            });
                          } else if (!EmailValidator.validate(email.text)) {
                            setState(() {
                              emailerror = true;
                              emailmessage = "Email is not valid";
                            });
                          } else {
                            setState(() {
                              emailerror = false;
                              //firstnamemessage = "Firstname is required";
                            });
                          }
                          if (password.text.isEmpty) {
                            setState(() {
                              passworderror = true;
                              passwordmessage = "Password is required";
                            });
                          } else {
                            setState(() {
                              passworderror = false;
                              //firstnamemessage = "Firstname is required";
                            });
                          }
                          if(selectedRole == null){
                            setState(() {
                              roleerror = true;
                              rolemessage = "Please select the role";
                            });
                          }
                          else{
                            setState(() {
                              roleerror = false;
                              //firstnamemessage = "Firstname is required";
                            });
                          }
                          if(selectedRole != "1" && selectedRole != null && company.text.isEmpty){
                            setState(() {
                              companyerror = true;
                              companymessage = "Company Name is required";
                            });
                          }
                          else{
                            setState(() {
                              companyerror = false;
                              //firstnamemessage = "Firstname is required";
                            });
                          }


                        });

                        if (emailerror == false && passworderror == false && roleerror == false && companyerror == false) {

                          if(selectedRole == "1")
                            await loginsubmit();
                          if(selectedRole != "1")
                            await checkCompany(company.text);
                          // Save authentication status to SharedPreferences
                          /* // Navigate to the appropriate screen based on authentication status
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Dashboard(),
                        ),
                      );*/
                        }
                      },
                      child: Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: loading
                                ? SpinKitFadingCircle(
                              color: Colors.white,
                              size: 40.0,
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                      MediaQuery.of(context).size.width *
                                          0.035),
                                ),
                                SizedBox(
                                  height:
                                  MediaQuery.of(context).size.width * 0.015,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_sharp,
                                  color: Colors.white,
                                  size:
                                  MediaQuery.of(context).size.width * 0.030,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    // Register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account ? ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width * 0.03),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => Signup()));
                          },
                          child: Container(
                            child: Text(
                              "Register now",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize:
                                  MediaQuery.of(context).size.width * 0.03),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * 0.1,
                    // ),
                  ],
                );
              }
              else{

                return ListView(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Image(
                      image: AssetImage('assets/images/logo.png'),
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.width * 0.9,
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    // Welcome
                    Center(
                      child: Text(
                        "Welcome to 302 Rentals",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.of(context).size.width * 0.05,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.02,
                    ),
                    // Login text
                    Center(
                      child: Text(
                        "Please login here...",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: MediaQuery.of(context).size.width * 0.036),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                        Expanded(

                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              hint: const Text('Select Role'),
                              value: selectedRole,
                              items: roles.map((role) {
                                return DropdownMenuItem<String>(
                                  value: role['role_id'],
                                  child: Text(role['role_name']!),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedRole = value;
                                  roleerror = false;
                                });
                                print('Selected role_id: $selectedRole');
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 45,
                                width: 170,
                                padding: const EdgeInsets.only(left: 14, right: 14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                elevation: 2,
                              ),
                              iconStyleData: const IconStyleData(
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                ),
                                iconSize: 24,
                                iconEnabledColor: Color(0xFFb0b6c3),
                                iconDisabledColor: Colors.grey,
                              ),
                              dropdownStyleData: DropdownStyleData(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: Colors.white,
                                ),
                                scrollbarTheme: ScrollbarThemeData(
                                  radius: const Radius.circular(6),
                                  thickness: MaterialStateProperty.all(6),
                                  thumbVisibility: MaterialStateProperty.all(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 40,
                                padding: EdgeInsets.only(left: 14, right: 14),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                      ],
                    ),
                    roleerror
                        ? Center(
                        child: Text(
                          rolemessage,
                          style: TextStyle(color: Colors.red),
                        ))
                        : Container(),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    // Email
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromRGBO(196, 196, 196, .3),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: TextField(
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (value) {
                                      setState(() {
                                        emailerror = false;
                                      });
                                    },
                                    controller: email,
                                    cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                    decoration: InputDecoration(
                                      enabledBorder: emailerror
                                          ? OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors
                                                .red), // Set border color here
                                      )
                                          : InputBorder.none,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(14),
                                      prefixIcon: Container(
                                        height: 20,
                                        width: 20,
                                        padding: EdgeInsets.all(13),
                                        child: FaIcon(
                                          FontAwesomeIcons.envelope,
                                          size: 20,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      hintText: "Business Email",
                                      hintStyle: TextStyle(
                                          color: Colors.grey[600], fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.095,
                        ),
                      ],
                    ),
                    emailerror
                        ? Center(
                        child: Text(
                          emailmessage,
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ))
                        : Container(),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    if(selectedRole !="1" && selectedRole != null)
                      Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.099,
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Color.fromRGBO(196, 196, 196, .3),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: TextField(
                                          keyboardType: TextInputType.emailAddress,
                                          onChanged: (value) {
                                            setState(() {
                                              companyerror = false;
                                            });
                                          },
                                          controller: company,
                                          cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                          decoration: InputDecoration(
                                            enabledBorder: companyerror
                                                ? OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                              borderSide: BorderSide(
                                                  color: Colors
                                                      .red), // Set border color here
                                            )
                                                : InputBorder.none,
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(14),
                                            prefixIcon: Container(
                                              height: 20,
                                              width: 20,
                                              padding: EdgeInsets.all(13),
                                              child: FaIcon(
                                                FontAwesomeIcons.businessTime,
                                                size: 20,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                            hintText: "Company Name",
                                            hintStyle: TextStyle(
                                                color: Colors.grey[600], fontSize: 15),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.095,
                              ),
                            ],
                          ),
                          companyerror
                              ? Center(
                              child: Text(
                                companymessage,
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ))
                              : Container(),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.025,
                          ),
                        ],
                      ),

                    // Password
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                        Expanded(

                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Color.fromRGBO(196, 196, 196, .3),
                            ),
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: TextField(
                                    keyboardType: TextInputType.text,
                                    onChanged: (value) {
                                      setState(() {
                                        passworderror = false;
                                      });
                                    },
                                    controller: password,
                                    obscureText: visiable_password,
                                    cursorColor: Color.fromRGBO(21, 43, 81, 1),
                                    decoration: InputDecoration(
                                      enabledBorder: passworderror
                                          ? OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10),
                                        borderSide: BorderSide(
                                            color: Colors
                                                .red), // Set border color here
                                      )
                                          : InputBorder.none,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.all(14),
                                      prefixIcon: Container(
                                        height: 20,
                                        width: 20,
                                        // color: Colors.blue,
                                        padding: EdgeInsets.all(13),
                                        child: FaIcon(
                                          FontAwesomeIcons.lock,
                                          size: 20,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      hintText: "Password",
                                      hintStyle: TextStyle(
                                          color: Colors.grey[600], fontSize: 15),
                                      suffixIcon: InkWell(
                                        onTap: () {
                                          setState(() {
                                            visiable_password = !visiable_password;
                                          });
                                        },
                                        child: Icon(
                                          visiable_password
                                              ? Icons.remove_red_eye_outlined
                                              : Icons.visibility_off_outlined,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                      ],
                    ),
                    passworderror
                        ? Center(
                        child: Text(
                          passwordmessage,
                          style: TextStyle(color: Colors.red),
                        ))
                        : Container(),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.015,
                    ),
                    // Forgot password
                    Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.03,
                          width: MediaQuery.of(context).size.width * 0.05,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.02,
                        ),
                        Text(
                          "Remember me ",
                          style: TextStyle(
                              fontSize: MediaQuery.of(context).size.width * 0.03,
                              color: Colors.black),
                        ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPassword()));
                          },
                          child: Text(
                            "Forgot password?",
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width * 0.03,
                                color: Colors.blue),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.099,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.025,
                    ),
                    // Login button
                    /*SizedBox(
                  height: MediaQuery.of(context).size.height * 0.16,
                ),*/
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          if (email.text.isEmpty) {
                            setState(() {
                              emailerror = true;
                              emailmessage = "Email is required";
                            });
                          } else if (!EmailValidator.validate(email.text)) {
                            setState(() {
                              emailerror = true;
                              emailmessage = "Email is not valid";
                            });
                          } else {
                            setState(() {
                              emailerror = false;
                              //firstnamemessage = "Firstname is required";
                            });
                          }
                          if (password.text.isEmpty) {
                            setState(() {
                              passworderror = true;
                              passwordmessage = "Password is required";
                            });
                          } else {
                            setState(() {
                              passworderror = false;
                              //firstnamemessage = "Firstname is required";
                            });
                          }
                          if(selectedRole == null){
                            setState(() {
                              roleerror = true;
                              rolemessage = "Please select the role";
                            });
                          }
                          else{
                            setState(() {
                              roleerror = false;
                              //firstnamemessage = "Firstname is required";
                            });
                          }
                          if(selectedRole != "1" && selectedRole != null && company.text.isEmpty){
                            setState(() {
                              companyerror = true;
                              companymessage = "Company Name is required";
                            });
                          }
                          else{
                            setState(() {
                              companyerror = false;
                              //firstnamemessage = "Firstname is required";
                            });
                          }


                        });

                        if (emailerror == false && passworderror == false && roleerror == false && companyerror == false) {

                          if(selectedRole == "1")
                            await loginsubmit();
                          if(selectedRole != "1")
                            await checkCompany(company.text);
                          // Save authentication status to SharedPreferences
                          /* // Navigate to the appropriate screen based on authentication status
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Dashboard(),
                        ),
                      );*/
                        }
                      },
                      child: Center(
                        child: Container(
                          height: MediaQuery.of(context).size.height * 0.06,
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: loading
                                ? SpinKitFadingCircle(
                              color: Colors.white,
                              size: 40.0,
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Login",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize:
                                      MediaQuery.of(context).size.width *
                                          0.045),
                                ),
                                SizedBox(
                                  height:
                                  MediaQuery.of(context).size.width * 0.015,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios_sharp,
                                  color: Colors.white,
                                  size:
                                  MediaQuery.of(context).size.width * 0.045,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.04,
                    ),
                    // Register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account ? ",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: MediaQuery.of(context).size.width * 0.04),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) => Signup()));
                          },
                          child: Container(
                            child: Text(
                              "Register now",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                  fontSize:
                                  MediaQuery.of(context).size.width * 0.037),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * 0.1,
                    // ),
                  ],
                );
              }

          }
        ),
      ),
    );
  }

  Future<void> checkToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = prefs.getString('token');
    List<Map<String,dynamic>> selectedroledata = roles.where((element) => element["role_id"] == selectedRole).toList();
    String rolename  =selectedroledata.first["role_name"];

    final response = await http.post(
      Uri.parse('${Api_url}/api/admin/token_check_api'),
      headers: {
       // "authorization": "CRM $token",
        //"id":"CRM $id",
        "Content-Type": "application/json"
      },
      body: json.encode({"token": token}),
    );
    print(response.body);
    final jsonData = json.decode(response.body);
    if (jsonData['id'] != "") {
      print(jsonData);
      //prefs.setString('checkedToken',jsonData["token"]);
      String? adminId = jsonData['data']['admin_id'];
      prefs.setString("role", "Admin");
      print('Admin ID: $adminId');
      prefs.setString('checkedToken', token);
      prefs.setString('adminId', adminId!);
      prefs.setString('first_name', jsonData['data']['first_name']);
      prefs.setString('last_name', jsonData['data']['last_name']);
      prefs.setString('first_name', jsonData['data']['first_name']);
      prefs.setString('last_name', jsonData['data']['last_name']);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Dashboard()));
    } else {
      print('Failed to check token');
    }
  }
  Future<void> checkTokenStaff(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = prefs.getString('token');
    List<Map<String,dynamic>> selectedroledata = roles.where((element) => element["role_id"] == selectedRole).toList();
    String rolename  =selectedroledata.first["role_name"];

    final response = await http.post(
      Uri.parse('${Api_url}/api/${rolename.toLowerCase()}/token_check'),
      headers: {
        // "authorization": "CRM $token",
        //"id":"CRM $id",
        "Content-Type": "application/json"
      },
      body: json.encode({"token": token}),
    );
    print(response.body);
    final jsonData = json.decode(response.body);
    if (jsonData['id'] != "") {
      print(jsonData);
      //prefs.setString('checkedToken',jsonData["token"]);
      // String? adminId = jsonData['data']['admin_id'];
      // print('Admin ID: $adminId');
      await Provider.of<StaffPermissionProvider>(context, listen: false).fetchPermissions();
      prefs.setString("staff_id", jsonData["${rolename.toLowerCase()}_id"]);
      prefs.setString("role", rolename);
      print(jsonData["${rolename.toLowerCase()}_firstName"]);

      prefs.setString('checkedToken', token);
      //  prefs.setString('adminId', adminId!);
      String stafffirstname = jsonData['staffmember_name'];
      List<String> firstname =stafffirstname.split(" ") ;
      print(firstname);
      prefs.setString('first_name', firstname.first);
      prefs.setString('last_name', firstname[1]);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Dashboard_staff()));
    } else {
      print('Failed to check token');
    }
  }
  Future<void> checkTokenTenant(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = prefs.getString('token');
    List<Map<String,dynamic>> selectedroledata = roles.where((element) => element["role_id"] == selectedRole).toList();
    String rolename  =selectedroledata.first["role_name"];

    final response = await http.post(
      Uri.parse('${Api_url}/api/${rolename.toLowerCase()}/token_check'),
      headers: {
        // "authorization": "CRM $token",
        //"id":"CRM $id",
        "Content-Type": "application/json"
      },
      body: json.encode({"token": token}),
    );
    print(response.body);
    final jsonData = json.decode(response.body);
    if (jsonData['id'] != "") {
      print(jsonData);
      //prefs.setString('checkedToken',jsonData["token"]);
      // String? adminId = jsonData['data']['admin_id'];
      // print('Admin ID: $adminId');
      prefs.setString("role", rolename);

      print(jsonData["${rolename.toLowerCase()}_firstName"]);
      prefs.setString("tenant_id", jsonData["${rolename.toLowerCase()}_id"]);
      prefs.setString('checkedToken', token);
      //  prefs.setString('adminId', adminId!);
       prefs.setString('first_name', jsonData['${rolename.toLowerCase()}_firstName']);
      prefs.setString('last_name', jsonData['${rolename.toLowerCase()}_lastName']);
      prefs.setString('email', jsonData['tenant_email']);
      await Provider.of<PermissionProvider>(context, listen: false).fetchPermissions();
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Dashboard_tenants()));
    } else {
      print('Failed to check token');
    }
  }
  Future<void> checkTokenVendor(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = prefs.getString('token');
    List<Map<String,dynamic>> selectedroledata = roles.where((element) => element["role_id"] == selectedRole).toList();
    String rolename  =selectedroledata.first["role_name"];
print('${Api_url}/api/${rolename.toLowerCase()}/token_check');
    final response = await http.post(
      Uri.parse('${Api_url}/api/${rolename.toLowerCase()}/token_check'),
      headers: {
        // "authorization": "CRM $token",
        //"id":"CRM $id",
        "Content-Type": "application/json"
      },
      body: json.encode({"token": token}),
    );
    print("vendor token ${response.body}");
    final jsonData = json.decode(response.body);
    if (jsonData['id'] != "") {
      print(jsonData);
      //prefs.setString('checkedToken',jsonData["token"]);
      // String? adminId = jsonData['data']['admin_id'];
      // print('Admin ID: $adminId');
      String stafffirstname = jsonData['vendor_name'];
      List<String> firstname =stafffirstname.split(" ") ;
      print(firstname);
      await Provider.of<PermissionProvider>(context, listen: false).fetchPermissions();
      prefs.setString('first_name', firstname.first);
      prefs.setString('last_name', firstname[1]);
      prefs.setString("role", rolename);
      print(jsonData["${rolename.toLowerCase()}_firstName"]);
      prefs.setString("vendor_id", jsonData["${rolename.toLowerCase()}_id"]);
      prefs.setString('checkedToken', token);
      //  prefs.setString('adminId', adminId!);
      // prefs.setString('first_name', jsonData['${rolename.toLowerCase()}_firstName']);
      // prefs.setString('last_name', jsonData['${rolename.toLowerCase()}_lastName']);
      prefs.setString('email', jsonData['vendor_email']);
     // prefs.setString('checkedToken', token);
      //  prefs.setString('adminId', adminId!);
      /* prefs.setString('first_name', jsonData['${rolename.toLowerCase()}_firstName']);
      prefs.setString('last_name', jsonData['${rolename.toLowerCase()}_lastname']);
*/
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Dashboard_vendors()));
    } else {
      print('Failed to check token');
    }
  }
  Future<void> checkCompany(String token) async {
    setState(() {
      loading = true;
    });
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('${Api_url}/api/admin/check_company/${token}'),
      headers: {
        // "authorization": "CRM $token",
        //"id":"CRM $id",
        "Content-Type": "application/json"
      },
     // body: json.encode({"token": token}),
    );
    print(response.body);
    final jsonData = json.decode(response.body);
    //if (jsonData["data"]['id'] != "") {
      print(jsonData);
     if(jsonData["statusCode"] ==200)
       {
         //prefs.setString('checkedToken',jsonData["token"]);
         String? adminId = jsonData['data']['admin_id'];
         print('Admin ID: $adminId');
         prefs.setString('checkedToken', token);
         prefs.setString('adminId', adminId!);
         /*prefs.setString('first_name', jsonData['data']['first_name']);
      prefs.setString('last_name', jsonData['data']['last_name']);
      prefs.setString('first_name', jsonData['data']['first_name']);
      prefs.setString('last_name', jsonData['data']['last_name']);*/
         /* Navigator.push(
          context, MaterialPageRoute(builder: (context) => Dashboard()));*/
         loginsubmit_usingrole(adminId);
       }
      else{
        setState(() {
          companyerror = true;
          companymessage = "Company is not found";
          loading = false;
        });
     }

  }
  Future<void> loginsubmit_usingrole(String adminId) async {
    setState(() {
      loading = true;
    });
    List<Map<String,dynamic>> selectedroledata = roles.where((element) => element["role_id"] == selectedRole).toList();
    String rolename  =selectedroledata.first["role_name"];

    print("${Api_url}/api/${rolename.toLowerCase()}/login");
    print({"email": email.text, "password": password.text,"admin_id":adminId,"company":company.text});
    final response = await http.post(Uri.parse('${Api_url}/api/${rolename.toLowerCase()}/login'),
        body: {"email": email.text, "password": password.text,"admin_id":adminId,"company":company.text});
    print(response.body);
    final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200) {
      print(jsonData);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isAuthenticated', true);
      prefs.setString('token', jsonData["token"]);
      prefs.setString('adminId', adminId);
      print(rolename);
      if(rolename == "Staffmember")
      await checkTokenStaff(jsonData["token"]);
      if(rolename == "Tenant")
        await checkTokenTenant(jsonData["token"]);
      if(rolename == "Vendor")
        await checkTokenVendor(jsonData["token"]);


      //  await checkToken("token", "id");
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => Dashboard()));
      /*final List<dynamic> data = jsonData['data'];
      List<String> urls = [];
      List<String> banners = [];
      List<bool> banner_status = [];
      for (var item in data) {
        urls.add(item['url']);
        banners.add(item['id']);
        banner_status.add(item['status']);
      }
      for (var i = 0 ; i < banner_status.length;i++){
        setState(() {
          if(banner_status[i])
            selectedIndex = i;
        });
      }
      setState(() {
        imageUrls = urls;
        bannerid = banners;
        bannerstatus = banner_status;
        isLoading = false;
      });
      print(imageUrls);*/
      setState(() {
        loading = false;
      });
    } else {
      Fluttertoast.showToast(msg: jsonData["message"]);
      setState(() {
        loading = false;
      });
    }
  }
  Future<void> loginsubmit() async {
    setState(() {
      loading = true;
    });
    final response = await http.post(Uri.parse('${Api_url}/api/admin/login'),
        body: {"email": email.text, "password": password.text});
    print(response.body);
    final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200) {
      print(jsonData);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('isAuthenticated', true);
      prefs.setString('token', jsonData["token"]);

       await checkToken(jsonData["token"]);
     //  await checkToken("token", "id");
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => Dashboard()));
      /*final List<dynamic> data = jsonData['data'];
      List<String> urls = [];
      List<String> banners = [];
      List<bool> banner_status = [];
      for (var item in data) {
        urls.add(item['url']);
        banners.add(item['id']);
        banner_status.add(item['status']);
      }
      for (var i = 0 ; i < banner_status.length;i++){
        setState(() {
          if(banner_status[i])
            selectedIndex = i;
        });
      }
      setState(() {
        imageUrls = urls;
        bannerid = banners;
        bannerstatus = banner_status;
        isLoading = false;
      });
      print(imageUrls);*/
      setState(() {
        loading = false;
      });
    } else {
      Fluttertoast.showToast(msg: jsonData["message"]);
      setState(() {
        loading = false;
      });
    }
  }
}
