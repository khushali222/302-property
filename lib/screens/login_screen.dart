import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:three_zero_two_property/screens/changepassword.dart';
import 'package:three_zero_two_property/screens/signup_main.dart';
import 'package:three_zero_two_property/screens/signup_screen.dart';
import 'package:http/http.dart' as http;

import 'dashboard_one.dart';
import 'forgotpassword.dart';



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
  // Widget build(BuildContext context) {
  //   double width = MediaQuery.of(context).size.width;
  //   double height = MediaQuery.of(context).size.height;
  //   return
  //     SafeArea(
  //     child: Scaffold(
  //       body: Form(
  //         key: formkey,
  //         child: ListView(
  //           children: [
  //             SizedBox(
  //               height: 90,
  //             ),
  //             Image(
  //               image: AssetImage('assets/images/logo.png'),
  //               height: 40,
  //               width: width * 0.9,
  //             ),
  //             SizedBox(
  //               height: 20,
  //             ),
  //             // Welcome
  //             Center(
  //               child: Text(
  //                 "Welcome to 302 Rentals",
  //                 style: TextStyle(
  //                   color: Colors.black,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 19,
  //                 ),
  //               ),
  //             ),
  //             SizedBox(
  //               height: 10,
  //             ),
  //             // Login text
  //             Center(
  //               child: Text(
  //                 "Please login here...",
  //                 style: TextStyle(color: Colors.black),
  //               ),
  //             ),
  //             SizedBox(
  //               height: 20,
  //             ),
  //             // Email
  //             Row(
  //               children: [
  //                 SizedBox(
  //                   width: MediaQuery.of(context).size.width * 0.099,
  //                 ),
  //                 Container(
  //                   height: 50,
  //                   width: MediaQuery.of(context).size.width * 0.8,
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(10),
  //                     color: Color.fromRGBO(196, 196, 196, .3),
  //                   ),
  //                   child: Stack(
  //                     children: [
  //                       Positioned.fill(
  //                         child: TextField(
  //                           onChanged: (value) {
  //                             setState(() {
  //                               emailerror = false;
  //                             });
  //                           },
  //                           controller: email,
  //                           cursorColor: Color.fromRGBO(21, 43, 81, 1),
  //                           decoration: InputDecoration(
  //                             border: InputBorder.none,
  //                             enabledBorder: emailerror
  //                                 ? OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(10),
  //                                     borderSide: BorderSide(
  //                                         color: Colors
  //                                             .red), // Set border color here
  //                                   )
  //                                 : InputBorder.none,
  //                             contentPadding: EdgeInsets.all(10),
  //                             prefixIcon: Container(
  //                                 height: 20,
  //                                 width: 20,
  //                                 padding: EdgeInsets.all(13),
  //                                 child: Image.asset(
  //                                     "assets/icons/email_icon.png")),
  //                             hintText: "Business Email",
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   width: 25,
  //                 ),
  //               ],
  //             ),
  //             emailerror
  //                 ? Center(
  //                     child: Text(
  //                     emailmessage,
  //                     style: TextStyle(color: Colors.red),
  //                   ))
  //                 : Container(),
  //
  //             SizedBox(
  //               height: 25,
  //             ),
  //             // Password
  //             Row(
  //               children: [
  //                 SizedBox(
  //                   width: MediaQuery.of(context).size.width * 0.099,
  //                 ),
  //                 Container(
  //                   height: 50,
  //                   width: MediaQuery.of(context).size.width * 0.8,
  //                   decoration: BoxDecoration(
  //                     borderRadius: BorderRadius.circular(10),
  //                     color: Color.fromRGBO(196, 196, 196, .3),
  //                   ),
  //                   child: Stack(
  //                     children: [
  //                       Positioned.fill(
  //                         child: TextField(
  //                           onChanged: (value) {
  //                             setState(() {
  //                               passworderror = false;
  //                             });
  //                           },
  //                           controller: password,
  //                           obscureText: visiable_password,
  //                           cursorColor: Color.fromRGBO(21, 43, 81, 1),
  //                           decoration: InputDecoration(
  //                             enabledBorder: passworderror
  //                                 ? OutlineInputBorder(
  //                                     borderRadius: BorderRadius.circular(10),
  //                                     borderSide: BorderSide(
  //                                         color: Colors
  //                                             .red), // Set border color here
  //                                   )
  //                                 : InputBorder.none,
  //                             border: InputBorder.none,
  //                             contentPadding: EdgeInsets.all(10),
  //                             prefixIcon: Icon(
  //                               Icons.lock_open,
  //                               size: 22,
  //                               color: Colors.grey,
  //                             ),
  //                             hintText: "Password",
  //                             suffixIcon: InkWell(
  //                               onTap: () {
  //                                 setState(() {
  //                                   visiable_password = !visiable_password;
  //                                 });
  //                               },
  //                               child: Icon(
  //                                 visiable_password
  //                                     ? Icons.remove_red_eye_outlined
  //                                     : Icons.visibility_off_outlined,
  //                                 color: Colors.grey,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   width: 25,
  //                 ),
  //               ],
  //             ),
  //             passworderror
  //                 ? Center(
  //                     child: Text(
  //                     passwordmessage,
  //                     style: TextStyle(color: Colors.red),
  //                   ))
  //                 : Container(),
  //
  //             SizedBox(
  //               height: 15,
  //             ),
  //             // Forgot password
  //             Row(
  //               children: [
  //                 SizedBox(
  //                   width: MediaQuery.of(context).size.width * 0.099,
  //                 ),
  //                 Container(
  //                   height: 20,
  //                   width: 20,
  //                   decoration: BoxDecoration(
  //                     color: Colors.white,
  //                     borderRadius: BorderRadius.circular(5),
  //                     border: Border.all(
  //                       color: Colors.grey,
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(
  //                   width: 10,
  //                 ),
  //                 Text(
  //                   "Remember me ",
  //                   style: TextStyle(fontSize: 12, color: Colors.black),
  //                 ),
  //                 Spacer(),
  //                 Text(
  //                   "Forgot password?",
  //                   style: TextStyle(fontSize: 12, color: Colors.blue),
  //                 ),
  //                 SizedBox(
  //                   width: MediaQuery.of(context).size.width * 0.099,
  //                 ),
  //               ],
  //             ),
  //             Spacer(),
  //             // Login button
  //             SizedBox(
  //               height: 150,
  //             ),
  //             GestureDetector(
  //               onTap: () {
  //                 setState(() {
  //                   if (email.text.isEmpty) {
  //                     setState(() {
  //                       emailerror = true;
  //                       emailmessage = "Email is required";
  //                     });
  //                   } else if (!EmailValidator.validate(email.text)) {
  //                     setState(() {
  //                       emailerror = true;
  //                       emailmessage = "Email is not valid";
  //                     });
  //                   } else {
  //                     setState(() {
  //                       emailerror = false;
  //                       //firstnamemessage = "Firstname is required";
  //                     });
  //                   }
  //                   if (password.text.isEmpty) {
  //                     setState(() {
  //                       passworderror = true;
  //                       passwordmessage = "Password is required";
  //                     });
  //                   } else {
  //                     setState(() {
  //                       passworderror = false;
  //                       //firstnamemessage = "Firstname is required";
  //                     });
  //                   }
  //                 });
  //
  //                 if (emailerror == false && passworderror == false) {
  //                   loginsubmit();
  //                 }
  //                 /* Navigator.push(
  //                     context, MaterialPageRoute(builder: (context) => Signup()));*/
  //               },
  //               child: Center(
  //                 child: Container(
  //                   height: MediaQuery.of(context).size.height * 0.06,
  //                   width: MediaQuery.of(context).size.width * 0.8,
  //                   decoration: BoxDecoration(
  //                     color: Colors.black,
  //                     borderRadius: BorderRadius.circular(10),
  //                   ),
  //                   child: Center(
  //                     child: loading
  //                         ? CircularProgressIndicator(
  //                             color: Colors.white,
  //                           )
  //                         : Row(
  //                             mainAxisAlignment: MainAxisAlignment.center,
  //                             children: [
  //                               Text(
  //                                 "Login",
  //                                 style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontWeight: FontWeight.bold,
  //                                 ),
  //                               ),
  //                               SizedBox(
  //                                 height: 10,
  //                               ),
  //                               Icon(
  //                                 Icons.keyboard_arrow_right_outlined,
  //                                 color: Colors.white,
  //                                 size: 20,
  //                               ),
  //                             ],
  //                           ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //             SizedBox(
  //               height: 20,
  //             ),
  //             // Register now
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               children: [
  //                 Text(
  //                   "Don't have an account ? ",
  //                   style: TextStyle(
  //                     color: Colors.black,
  //                   ),
  //                 ),
  //                 GestureDetector(
  //                   onTap: () {
  //                     Navigator.push(context,
  //                         MaterialPageRoute(builder: (context) => Signup()));
  //                   },
  //                   child: Container(
  //                     child: Text(
  //                       "Register now",
  //                       style: TextStyle(
  //                         fontWeight: FontWeight.bold,
  //                         color: Colors.blue,
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             // SizedBox(
  //             //   height: 90,
  //             // ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                  "Please login here...",
                  style: TextStyle(color: Colors.black,fontSize: MediaQuery.of(context).size.width * 0.03),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              // Email
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.099,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.065,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(196, 196, 196, .3),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Center(
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
                                border: InputBorder.none,
                                enabledBorder: emailerror
                                    ? OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(
                                      color: Colors
                                          .red), // Set border color here
                                )
                                    : InputBorder.none,
                                contentPadding: EdgeInsets.all(15),
                                prefixIcon:
                                Padding(
                                  padding: const EdgeInsets.all(17.0),
                                  child: Image.asset(
                                          "assets/icons/email_icon.png"),
                                ),
                                hintText: "Business Email",
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.05,
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

              SizedBox(
                height: MediaQuery.of(context).size.height * 0.025,
              ),
              // Password
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.099,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.065,
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(196, 196, 196, .3),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Center(
                            child: TextField(

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
                                contentPadding: EdgeInsets.all(15),
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Image.asset('assets/icons/pasword.png'),
                                ),
                                hintText: "Password",
                                suffixIcon:
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      visiable_password = !visiable_password;
                                    });
                                  },
                                  child: Icon(
                                    visiable_password
                                        ? Icons.remove_red_eye_outlined
                                        : Icons.visibility_off_outlined,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.05,
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
                  Spacer(),
                  GestureDetector(
                    onTap: (){
                      Navigator.push(
                          context, MaterialPageRoute(builder: (context) => changepassword()));
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
                height: MediaQuery.of(context).size.height * 0.1,
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
                    loginsubmit();
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
                          ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                                fontSize: MediaQuery.of(context).size.width * 0.04
                            ),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.width * 0.01,
                          ),
                          Icon(
                            Icons.keyboard_arrow_right_outlined,
                            color: Colors.white,
                            size: MediaQuery.of(context).size.width * 0.04,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              // Register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account ? ",
                    style: TextStyle(
                      color: Colors.black,
                        fontSize: MediaQuery.of(context).size.width * 0.03
                    ),
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
                            fontSize: MediaQuery.of(context).size.width * 0.03
                        ),
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


  Future<void> loginsubmit() async {
    setState(() {
      loading = true;
    });
    final response = await http.post(
        Uri.parse('https://saas.cloudrentalmanager.com/api/admin/login'),
        body: {"email": email.text, "password": password.text});
    print(response.statusCode);
    final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200) {
      print(jsonData);
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => Dashboard()));
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
