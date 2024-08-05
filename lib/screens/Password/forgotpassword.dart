import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../constant/constant.dart';
import '../../widgets/test.dart';
import 'otp_vrify.dart';
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {

  bool _isEmailSubmitted = false;
  bool _hasMultipleCompanies = false;
  bool loading = false;
  List<Map<String, String>> _companies = [];
  String _selectedCompany = '';
  String admin_id = "";
  String selectedrole = '';
  String passwordmessage = "";
  String companymessage = "";
  String emailmessage = "";
  String rolemessage = "";
  bool get isEmailSubmitted => _isEmailSubmitted;
  bool get hasMultipleCompanies => _hasMultipleCompanies;
  List<Map<String, String>> get companies => _companies;
  String get selectedCompany => _selectedCompany;
  Future<void> submitEmail() async {

    print("Calling  ${email.text}");
    // Make API call to check email
    final response = await http.post(
      Uri.parse('${Api_url}/api/admin/check_role'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email.text}),
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List<dynamic> roles = data['data'];
      print(roles.length);
      if (roles.isEmpty) {
        Fluttertoast.showToast(msg: "Email does not exist");
      } else {
        if (roles.length > 1) {
          setState(() {
            _hasMultipleCompanies = true;
            _companies = roles

                .map<Map<String, String>>((role) => {
              'company': role['company_name'],
              'admin_id':role['admin_id'],
              'role': role['role']
            })
                .toList();
            _isEmailSubmitted = true;
          });

        } else {
          setState(() {
            if(roles[0]['role'] =="admin"){
              _hasMultipleCompanies = false;
              //_selectedCompany = roles[0]['company_name'];
              selectedrole = roles[0]['role']; // Set role directly
              admin_id = roles[0]['admin_id'];
              _isEmailSubmitted = true;
            }
            else{
              print(roles[0]['role']);
              _hasMultipleCompanies = false;
              _selectedCompany = roles[0]['company_name'];
              selectedrole = roles[0]['role']; // Set role directly
              admin_id = roles[0]['admin_id'];
              _isEmailSubmitted = true;
            }

          });
          sendOTP(email.text);
        }
      }
    } else {
      Fluttertoast.showToast(msg: "Email is not exist");
    }
  }
  TextEditingController email = TextEditingController();
  bool emailerror = false;

  final GlobalKey formkey = GlobalKey<FormState>();
  void sendOTP(String email) async {
    setState(() {
      loading = true; // Show loading indicator while sending OTP
    });

    final response = await http.post(
      Uri.parse('${Api_url}/api/admin/sendOTP'),
      body: {'email': email,'admin_id':admin_id,'role':selectedrole},
    );
    print(response.body);
    setState(() {
      loading = false; // Hide loading indicator after receiving response
    });

    final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200) {
      print(jsonData);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => otp_verify(email: email,admin_id: admin_id,role: selectedrole,)),
      );
      Fluttertoast.showToast(msg: "OTP sent successfully");
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
  void selectCompany(String company, String role,String adminid) {

    _selectedCompany = company;
    selectedrole = role; // Set role when selecting company
    admin_id = adminid;
    print(selectedrole);
    print(selectedCompany);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
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
                  height: MediaQuery.of(context).size.height * 0.02,
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
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                // Login text
                Center(
                  child: Text(
                    "Forgot Your Password ?",
                    style: TextStyle(color: Colors.black,fontSize: MediaQuery.of(context).size.width * 0.034),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                ),
                Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.099,
                    ),
                    Expanded(
                      child: Text(
                        "Enter your email address below, and we'll sent you the link to reset your password",
                        style: TextStyle(color: Colors.black38,fontSize: MediaQuery.of(context).size.width * 0.034),
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.099,
                    ),
                  ],
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.028,
                ),
               // Email
               //  Row(
               //    children: [
               //      SizedBox(
               //        width: MediaQuery.of(context).size.width * 0.099,
               //      ),
               //      Container(
               //        height: MediaQuery.of(context).size.height * 0.065,
               //        width: MediaQuery.of(context).size.width * 0.8,
               //        decoration: BoxDecoration(
               //          borderRadius: BorderRadius.circular(10),
               //          color: Color.fromRGBO(196, 196, 196, .3),
               //        ),
               //        child: Stack(
               //          children: [
               //            Positioned.fill(
               //              child: Center(
               //                child: TextField(
               //                  keyboardType: TextInputType.emailAddress,
               //                  onChanged: (value) {
               //                    setState(() {
               //                      emailerror = false;
               //                    });
               //                  },
               //                  controller: email,
               //                  cursorColor: Color.fromRGBO(21, 43, 81, 1),
               //                  decoration: InputDecoration(
               //                    border: InputBorder.none,
               //                    enabledBorder: emailerror
               //                        ? OutlineInputBorder(
               //                      borderRadius: BorderRadius.circular(10),
               //                      borderSide: BorderSide(
               //                          color: Colors
               //                              .red), // Set border color here
               //                    )
               //                        : InputBorder.none,
               //                    contentPadding: EdgeInsets.all(15),
               //                    prefixIcon:
               //                    Padding(
               //                      padding: const EdgeInsets.all(17.0),
               //                      child: Image.asset(
               //                          "assets/icons/email_icon.png"),
               //                    ),
               //                    hintText: "Email",
               //                  ),
               //                ),
               //              ),
               //            ),
               //          ],
               //        ),
               //      ),
               //      SizedBox(
               //        width: MediaQuery.of(context).size.width * 0.05,
               //      ),
               //    ],
               //  ),
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
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  setState(() {
                                    emailerror = false;
                                    _isEmailSubmitted = false;
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
                                  hintText: "Email",
                                  hintStyle: TextStyle(color:Colors.grey[600],fontSize: 15 ),
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
                emailerror
                    ? Center(
                    child: Text(
                      emailmessage,
                      style: TextStyle(color: Colors.red,),
                    ))
                    : Container(),
                if(isEmailSubmitted)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      /*  SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025,
                      ),*/
            
                   /*   Row(
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
                          : Container(),*/
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025,
                      ),
                      if (hasMultipleCompanies) ...[
            
                        SingleSelectionButtons(
                          buttonOptions: companies,
                          onSelected: (index) {
                            selectCompany(companies[index]["company"]!,companies[index]["role"]!,companies[index]["admin_id"]!);
                          },
                        ),
                      ],
            
            
                   /*   SizedBox(
                        height: MediaQuery.of(context).size.height * 0.015,
                      ),
                      // Forgot password
                      Row(
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.11,
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
                      ),*/
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025,
                      ),
                      // Login button
                      /*SizedBox(
                    height: MediaQuery.of(context).size.height * 0.16,
                  ),*/
                 /*     GestureDetector(
                    *//*    onTap: () async {
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
                            if(selectedrole == null){
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
                            if(selectedrole != "1" && selectedrole != null && company.text.isEmpty){
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
            
                          if (emailerror == false && passworderror == false ) {
            
                            if(selectedrole == "admin")
                              await loginsubmit();
                            if(selectedrole != "admin")
                              await checkCompany(selectedCompany);
                            // Save authentication status to SharedPreferences
                            *//**//* // Navigate to the appropriate screen based on authentication status
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Dashboard(),
                          ),
                        );*//**//*
                          }
                        },*//*
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
                      ),*/
                    ],
                  ),
            
                // Spacer(),
                // Login button
               /* SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),*/
                if(isEmailSubmitted)
                Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.01,
                    ),
                    GestureDetector(
                      onTap: () {
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
                        });
                        if (!emailerror) {
                          // If email is valid, send OTP
                          sendOTP(email.text);
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
                                ?  SpinKitFadingCircle(
                              color: Colors.white,
                              size: 40.0,
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Submit",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).size.width * 0.045
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
                if(!isEmailSubmitted)
                Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.06,
                    ),
                    GestureDetector(
                      onTap: () {
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
                        });
                        if (!emailerror) {
                          // If email is valid, send OTP
                          submitEmail();
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
                                ?  SpinKitFadingCircle(
                              color: Colors.white,
                              size: 40.0,
                            )
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Submit",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: MediaQuery.of(context).size.width * 0.045
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
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.02,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.06,
                      width: MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.black)
                      ),
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Cancel",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.045
                            ),
                          ),
            
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.01,
                ),
            
              ],
            ),
          ),
        ),
      ),
    );
  }
}
