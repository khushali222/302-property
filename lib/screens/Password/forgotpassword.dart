import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart'as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'otp_vrify.dart';
class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController email = TextEditingController();
  bool emailerror = false;
  bool loading = false;
  String emailmessage = "";
  final GlobalKey formkey = GlobalKey<FormState>();
  void sendOTP(String email) async {
    setState(() {
      loading = true; // Show loading indicator while sending OTP
    });

    final response = await http.post(
      Uri.parse('http://192.168.1.32:4000/api/admin/sendOTP'),
      body: {'email': email},
    );

    setState(() {
      loading = false; // Hide loading indicator after receiving response
    });

    final jsonData = json.decode(response.body);
    if (jsonData["statusCode"] == 200) {
      print(jsonData);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => otp_verify(email: email,)),
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
  @override
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
                                hintText: "Email",
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

              Spacer(),
              // Login button
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
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
                        size: 50.0,
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
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.02,
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.01,
              ),
              GestureDetector(
                onTap: () {

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
                    child: Center(
                      child: loading
                          ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Row(
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
              ),

            ],
          ),
        ),
      ),
    );
  }
}
