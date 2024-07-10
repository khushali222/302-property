import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:three_zero_two_property/screens/Password/changepassword.dart';

import 'package:three_zero_two_property/screens/Signup/signup_screen.dart';
import 'package:http/http.dart' as http;

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
  TextEditingController password = TextEditingController();
  // TextEditingController lastname = TextEditingController();
  TextEditingController email = TextEditingController();

  bool passworderror = false;
  bool visiable_password = true;
  bool emailerror = false;

  bool loading = false;
  String passwordmessage = "";
  // String lastnamemessage = "";
  String emailmessage = "";
  final GlobalKey formkey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: formkey,
          child: ListView(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
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
              // Email
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.099,
                  ),
                  // Container(
                  //   height: MediaQuery.of(context).size.height * 0.065,
                  //   width: MediaQuery.of(context).size.width * 0.8,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10),
                  //     color: Color.fromRGBO(196, 196, 196, .3),
                  //   ),
                  //   child: Stack(
                  //     children: [
                  //       Positioned.fill(
                  //         child: Center(
                  //           child: TextField(
                  //             keyboardType: TextInputType.emailAddress,
                  //             onChanged: (value) {
                  //               setState(() {
                  //                 emailerror = false;
                  //               });
                  //             },
                  //             controller: email,
                  //             cursorColor: Color.fromRGBO(21, 43, 81, 1),
                  //             decoration: InputDecoration(
                  //               border: InputBorder.none,
                  //               enabledBorder: emailerror
                  //                   ? OutlineInputBorder(
                  //                       borderRadius: BorderRadius.circular(10),
                  //                       borderSide: BorderSide(
                  //                           color: Colors
                  //                               .red), // Set border color here
                  //                     )
                  //                   : InputBorder.none,
                  //               contentPadding: EdgeInsets.all(15),
                  //               prefixIcon: Padding(
                  //                 padding: const EdgeInsets.all(17.0),
                  //                 child: Image.asset(
                  //                     "assets/icons/email_icon.png"),
                  //               ),
                  //               hintText: "Business Email",
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
                                contentPadding: EdgeInsets.all(10),
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
              // Password
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.099,
                  ),
                  // Container(
                  //   height: MediaQuery.of(context).size.height * 0.065,
                  //   width: MediaQuery.of(context).size.width * 0.8,
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(10),
                  //     color: Color.fromRGBO(196, 196, 196, .3),
                  //   ),
                  //   child: Stack(
                  //     children: [
                  //       Positioned.fill(
                  //         child: Center(
                  //           child: TextField(
                  //             onChanged: (value) {
                  //               setState(() {
                  //                 passworderror = false;
                  //               });
                  //             },
                  //             controller: password,
                  //             obscureText: visiable_password,
                  //             cursorColor: Color.fromRGBO(21, 43, 81, 1),
                  //             decoration: InputDecoration(
                  //               enabledBorder: passworderror
                  //                   ? OutlineInputBorder(
                  //                 borderRadius: BorderRadius.circular(10),
                  //                 borderSide: BorderSide(
                  //                     color: Colors
                  //                         .red), // Set border color here
                  //               )
                  //                   : InputBorder.none,
                  //               border: InputBorder.none,
                  //               contentPadding: EdgeInsets.all(15),
                  //               prefixIcon: Padding(
                  //                 padding: const EdgeInsets.all(15.0),
                  //                 child: Image.asset('assets/icons/pasword.png'),
                  //               ),
                  //               hintText: "Password",
                  //               suffixIcon:
                  //               InkWell(
                  //                 onTap: () {
                  //                   setState(() {
                  //                     visiable_password = !visiable_password;
                  //                   });
                  //                 },
                  //                 child: Icon(
                  //                   visiable_password
                  //                       ? Icons.remove_red_eye_outlined
                  //                       : Icons.visibility_off_outlined,
                  //                   color: Colors.grey,
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
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
                                contentPadding: EdgeInsets.all(10),
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
                  // Spacer(),
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
              Spacer(),
              // Login button
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.16,
              ),
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
                  });

                  if (emailerror == false && passworderror == false) {
                    await loginsubmit();

                    // Save authentication status to SharedPreferences
                    /*// Navigate to the appropriate screen based on authentication status
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
          ),
        ),
      ),
    );
  }

  Future<void> checkToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // String? token = prefs.getString('token');
    String? adminId = prefs.getString('adminId').toString();

    final response = await http.post(
        Uri.parse('${Api_url}/api/admin/token_check_api'),
        headers: {"authorization": "CRM $token",},
        body: {"token": token});
    print(response.body);
    final jsonData = json.decode(response.body);
    if (jsonData['id'] != "") {
      print(jsonData);
      //prefs.setString('checkedToken',jsonData["token"]);
      String? adminId = jsonData['data']['admin_id'];
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
